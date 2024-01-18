/*
    imgutil.ahk
    a simple and effficient image manipulation library
    (C) 2023, MIT License, https://github.com/martona/imgutil
    12/17/2023, 0.1.0, initial release

    methods:

    imgutil_pixels_match(a, b, t)
        returns true if the RGB values of a and b are within t of each other
    imgutil_column_uniform(px, refc, x, t, yf, yt) 
        returns true if all pixels of px in column x, between rows yf and yt, 
        are within t of refc
    imgutil_row_uniform(px, refc, y, t, xf, xt) 
        returns true if all pixels of px in row y, between columns xf and xt, 
        are within t of refc        
*/

#Requires AutoHotkey v2.0+
#DllLoad "Gdiplus.dll"
#DllLoad "ole32.dll"
#include "imgutil_image_provider.ahk"

;############################################################################################################
; some global defines
;############################################################################################################
imgu_GPTR := 0x40
imgu_GDIP_OK := 0

;############################################################################################################
; a global instance of the class. you should only ever need this one.
;############################################################################################################
imgu := imgutil()

;############################################################################################################
; the class definition
;############################################################################################################
class imgutil {

    i_mcode_map := 0                                ; mcode function map for name -> address in memory
    i_multithread_ctx := 0                          ; multithread context
    i_use_single_thread := false                    ; used for testing purposes, forces srch/blit to use a single thread
    i_threads := 0                                  ; number of threads to use for srch/blit
    i_tolerance := 8                                ; tolerance used by all pixel matching functions
    i_gdip_token := 0                               ; gdiplus token

    ; i_get_mcode_map_vX functions:
    #include "imgutil_get_mcode_map_vx.ahk"
    ; pixel scanning and related manipulation functions
    #include "imgutil_pixelmatch-chop-grab.ahk"

    ;############################################################################################################
    ; initialize the library
    ;############################################################################################################
    __New() {
        ; set up the mcode blocks
        this.i_mcode_map        := this.i_get_mcode_map()
        ; set up multithreading
        this.i_multithread_ctx  := DllCall(this.i_mcode_map["mt_init"], "int", 0, "ptr")
        this.i_threads          := DllCall(this.i_mcode_map["mt_get_cputhreads"], "ptr", this.i_multithread_ctx, "int")
        si := Buffer(24, 0)
        NumPut("int", 1, si)
        token := 0
        DllCall("Gdiplus.dll\GdiplusStartup", "ptr*", &token, "ptr", si.ptr, "ptr", 0, "uint")
        this.i_gdip_token := token
    }

    ;############################################################################################################
    ; deinit
    ;############################################################################################################
    __Delete() {
        DllCall(this.i_mcode_map["mt_deinit"], "ptr", this.i_multithread_ctx)
        DllCall("Gdiplus.dll\GdiplusShutdown", "ptr", this.i_gdip_token)
     }

     set_threads(threads) {
        if (this.i_multithread_ctx)
            DllCall(this.i_mcode_map["mt_deinit"], "ptr", this.i_multithread_ctx)
        this.i_multithread_ctx := DllCall(this.i_mcode_map["mt_init"], "int", threads, "ptr")
        this.i_threads := threads
     }

    ;########################################################################################################
    ; determines the correct version of machine code blobs to use,
    ; decodes them from base64, and returns a map of function names
    ; to addresses in memory. (internal only)
    ;########################################################################################################
    i_get_mcode_map(psabi_level := -1) {

        map_base := this.i_get_mcode_map_base()
        if (psabi_level = -1)
            psabi_level := DllCall(map_base["get_cpu_psabi_level"], "int")

        ; get the correct machine code blob
        if (psabi_level = 4) {
            cmap := this.i_get_mcode_map_v4()
        } else if (psabi_level = 3) {
            cmap := this.i_get_mcode_map_v3()
        } else if (psabi_level = 2) {
            cmap := this.i_get_mcode_map_v2()
        } else if (psabi_level = 1) {
            cmap := this.i_get_mcode_map_v1()
        } else if (psabi_level = 0) {
            cmap := this.i_get_mcode_map_v0()
        } else {
            throw("imgutil: unsupported psabi level: " . psabi_level)
        }

        ; check that we got what we asked for
        psabi_level_blob := DllCall(cmap["get_blob_psabi_level"], "int")
        cmap["_psabi_level"] := psabi_level_blob
        if psabi_level_blob != psabi_level
            throw("imgutil: incompatible blob psabi level; expected " . psabi_level . ", got " . psabi_level_blob)
        ; append the ever-so-important base library
        for k, v in map_base
            cmap[k] := v
        return cmap
    }

    ;########################################################################################################
    ; simple b64 decode;
    ; allocates a PAGE_EXECUTE_READWRITE and gets crytp32 to decode the b64 string into it
    ;########################################################################################################    
    i_b64decode(s) {
        len := strlen(s)*3//4
        code := DllCall("GlobalAlloc", "uint", 0, "ptr", len, "ptr")
        if code {
            if DllCall("crypt32\CryptStringToBinary", "str", s, "uint", 0, "uint", 0x1, "ptr", code, "uint*", len, "ptr", 0, "ptr", 0, "int") {
                ; make the memory executable (PAGE_EXECUTE_READWRITE)
                if DllCall("VirtualProtect", "ptr", code, "ptr", len, "uint", 0x40, "uint*", 0, "int") {
                    return code
                }
            }
            DllCall("GlobalFree", "ptr", code, "ptr")
        }
        return 0
    }

    ;########################################################################################################
    ; get/set tolerance (a value between 0 and 255 that can relax pixel matching criteria on a per-color 
    ; channel basis.)
    ;########################################################################################################
    tolerance_set(t) {
        this.i_tolerance := t
    }
    tolerance_get() {
        return this.i_tolerance
    }

    ;########################################################################################################
    ; crop
    ;########################################################################################################
    crop(img, x, y, w, h) {
        new := img.crop(x, y, w, h)
        if img.HasOwnProp("origin") && img.origin
            new.origin := {x: img.origin.x + x, y: img.origin.y + y}
        return new
    }
    
    ;########################################################################################################
    ; imagesearch
    ;########################################################################################################
    srch(&fx, &fy,                      ; output coordinates if image found
        haystack,                       ; img object, file name, or screen rect
        needle,                         ; img object, file name, or screen rect
        tolerance := 0,                 ; pixels that differ by this much still match
        min_percent_match := 100,       ; percentage of pixels needed to return a match
        force_topleft_pixel_match := 1) ; top left pixel must match? (tolerance applies)
    {
        haystack := checkInputImg(haystack)
        needle   := checkInputImg(needle)
        
        ;; TODO eventually we should do something about this
        if (needle.w * 4 != needle.stride)
            throw "imgutil.srch: needle stride must be needle.w * 4"
        if (haystack.w * 4 != haystack.stride)
            throw "imgutil.srch: haystack stride must be haystack.w * 4"

        imgutil_mask_lo := Buffer(needle.w * needle.h * 4)
        imgutil_mask_hi := Buffer(needle.w * needle.h * 4)
        DllCall(this.i_mcode_map["imgutil_make_sat_masks"], 
            "ptr", needle.ptr, "uint", needle.w * needle.h,
            "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "char", tolerance, "int")

        pixels_matched := 0
        result := 0
        if (this.i_use_single_thread) {
            result := DllCall(this.i_mcode_map["imgutil_imgsrch"],
                "ptr", haystack.ptr, "int", haystack.w, "int", haystack.h,
                "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "int", needle.w, "int", needle.h,
                "char", min_percent_match, "int", force_topleft_pixel_match, "int*", pixels_matched, "ptr") 
        } else {
            result := DllCall(this.i_mcode_map["imgutil_imgsrch_multi"], "ptr", imgu.i_multithread_ctx,
                "ptr", haystack.ptr, "int", haystack.w, "int", haystack.h,
                "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "int", needle.w, "int", needle.h,
                "char", min_percent_match, "int", force_topleft_pixel_match, "int*", pixels_matched, "ptr")
        }

        if result {
            offset := (result - haystack.ptr) // 4
            fx := mod(offset, haystack.w)
            fy := offset // haystack.w
        }
        return result

        checkInputImg(x) {
            if Type(x) = "imgutil.img"
                return x
            if Type(x) = "ImagePut.BitmapBuffer"
                return this.from_imageputbuffer(x)
            if Type(x) = "imgutil.rect"
                return this.from_screen(x)
            if Type(x) = "Array" && x.Length = 4
                return this.from_screen(imgutil.rect(x[1], x[2], x[3], x[4]))
            if Type(x) = "String"
                return this.from_file(x)
            Throw "Invalid input to imgutil.srch: " . x
        }
    }

    ;########################################################################################################
    ; copy a rectangle from one image to another
    ; 
    ;   dst       - destination pointer
    ;   dx        - destination x
    ;   dy        - destination y
    ;   dstride   - destination stride in pixels
    ;   src       - source pointer
    ;   sx        - source x
    ;   sy        - source y
    ;   sstride   - source stride in pixels
    ;   w         - width of the rectangle
    ;   h         - height of the rectangle
    ;   _force_mt - testing/benchmarking, 1 for single-threaded, 2 for multithreaded
    ;########################################################################################################
    blit(dst, dx, dy, dstride, src, sx, sy, sstride, w, h, _force_mt := 0) {
        ; both on my laptop and my desktop, the break-even point for multithreading is around 600x600 pixels.
        ; below that, single-threaded is faster, above that, multithreaded is faster.
        ; i'm not sure how you'd determine this efficently for the current processor on the fly, so i'm just
        ; going to use a fixed value which does more good than harm.
        if (_force_mt = 1) || (w*h < 360000 && _force_mt != 2) {
            return DllCall(this.i_mcode_map["imgutil_blit"], 
                "ptr", dst, "int", dx, "int", dy, "int", dstride, 
                "ptr", src, "int", sx, "int", sy, "int", sstride, 
                "int", w, "int", h)
        } else {
            return DllCall(this.i_mcode_map["imgutil_blit_multi"], "ptr", imgu.i_multithread_ctx,
                "ptr", dst, "int", dx, "int", dy, "int", dstride, 
                "ptr", src, "int", sx, "int", sy, "int", sstride, 
                "int", w, "int", h)
        }
    }

    ;########################################################################################################
    ; load an image from disk
    ;########################################################################################################
    from_file(fname) {
        return imgutil.img(this).from_file(fname)
    }

    ;########################################################################################################
    ; capture the screen
    ;########################################################################################################
    from_screen(x := 0, y := 0, w := 0, h := 0) {
        rect := 0
        if Type(x) = "imgutil.rect"
            rect := x
        else if Type(x) = "Array" && x.Length = 4
            rect := imgutil.rect(x[1], x[2], x[3], x[4])
        else 
            rect := imgutil.rect(x, y, w, h)
        if rect.w = 0 || rect.h = 0
            rect := 0
        return imgutil.img(this).from_screen(rect)
    }

    ;########################################################################################################
    ; create blank image
    ;########################################################################################################
    from_nothing(w, h) {
        return imgutil.img(this).from_nothing(w, h)
    }

    ;########################################################################################################
    ; convert any in-memory source
    ;########################################################################################################
    from_memory(ptr, w, h, stride) {
        return imgutil.img(this).from_memory(ptr, w, h, stride)
    }

    ;########################################################################################################
    ; convert an ImagePutBuffer 
    ;########################################################################################################
    from_imageputbuffer(obj) {
        return imgutil.img(this).from_imageputbuffer(obj)
    }

    ;########################################################################################################
    ; convert a windows bitmap
    ;########################################################################################################
    from_hbitmap(hbmp) {
        return imgutil.img(this).from_hbitmap(hbmp)
    }

    ;########################################################################################################
    ; pixel brightness (naive, good enough)
    ;########################################################################################################
    get_pixel_magnitude(px) {
        r := (px & 0x00FF0000) >> 16
        g := (px & 0x0000ff00) >>  8
        b := (px & 0x000000ff)
        return r + g + b
    }

    ;########################################################################################################
    ; the img class, does a lot of the heavy lifting
    ;########################################################################################################
    class img {
        ptr     := 0     ; pointer to ARGB flat pixel data
        w       := 0     ; width of image
        h       := 0     ; height of image
        stride  := 0     ; stride of image in bytes (usually equals to w*4)
        origin  := 0     ; origin of image relative to screen(0,0)
        width   := 0     ; alias for w
        height  := 0     ; alias for h

        i_imgu      := 0     ; internal variable holding a reference to the imgutil object                    
        i_provider  := 0     ; provider object

        ;########################################################################################################
        ; ctor/dtor
        ;########################################################################################################
        __New(imgu) {
            this.i_imgu := imgu
        }

        __Delete() {
        }

        ;########################################################################################################
        ; 
        ;########################################################################################################
        from_provider(provider, origin := 0) {
            this.i_provider       := provider
            this.ptr              := provider.ptr
            this.w := this.width  := provider.w
            this.h := this.height := provider.h
            this.stride           := provider.stride
            if origin
                this.origin := origin
            return this
        }

        ;########################################################################################################
        ; object from file
        ;########################################################################################################
        from_file(fname) {
            i_provider := image_provider.gdip.file()
            if i_provider.get_image(fname)
                return this.from_provider(i_provider)
            return false
        }

        ;########################################################################################################
        ; access individual pixel valus
        ;########################################################################################################
        __Item[x, y, pretty := false] {
            get => pretty ? Format("0x{:08X}", this.get_pixel(x, y)) : this.get_pixel(x, y)
            set => this.set_pixel(x, y, value)
         }  

        ;########################################################################################################
        ; create blank image
        ;########################################################################################################
        from_nothing(w, h) {
            i_provider := image_provider.nothing()
            if i_provider.get_image(w, h)
                return this.from_provider(i_provider)
            return false
        }

        ;########################################################################################################
        ; object from memory location
        ;########################################################################################################
        from_memory(ptr, w, h, stride) {
            i_provider := image_provider.gdip.memory()
            if i_provider.get_image(ptr, w, h, stride)
                return this.from_provider(i_provider)
            return false
        }
        
        ;########################################################################################################
        ; object from screen
        ;########################################################################################################
        from_screen(rect := 0) { 
            ; try with directx first (fast), otherwise try with gdi (sloooow)
            providers := [image_provider.dx_screen(), image_provider.gdi_screen()]
            for provider in providers {
                if origin := provider.get_image(rect)
                    return this.from_provider(provider, origin)
            }
        }

        ;########################################################################################################
        ; object from ImagePutBuffer
        ;########################################################################################################
        from_imageputbuffer(obj) {
            i_provider := image_provider.imageputbuffer()
            if i_provider.get_image(obj)
                return this.from_provider(i_provider)
            return false
        }

        ;########################################################################################################
        ; object from hbitmap
        ;########################################################################################################
        from_hbitmap(hbmp) {
            ; TODO
            ; i_provider := image_provider.gdip.hbitmap()
            ; if i_provider.get_image(hbmp)
            ;     return this.from_provider(i_provider)
            ; return false
        }

        ;########################################################################################################
        ; convert the image to an hbitmap
        ;########################################################################################################
        to_hbitmap() {
            if (this.stride != this.w * 4)
                throw "to_hbitmap() requires stride == width*4"
            return DllCall("gdi32\CreateBitmap", "int", this.w, "int", this.h, "uint", 1, "uint", 32, "ptr", this.ptr)
        }

        ;########################################################################################################
        ; save the image to a file, the type is based on the extension  
        ;########################################################################################################
        to_file(fname) {
            ret  := false
            pbmp := 0
            ; create a gdiplus bitmap object from our memory buffer
            if imgu_GDIP_OK = DllCall("gdiplus\GdipCreateBitmapFromScan0", 
                "uint", this.w, "uint", this.h, "int", this.stride, 
                "uint", 0x0026200a,     ; PixelFormat32bppARGB
                "ptr" , this.ptr, 
                "ptr*", &pbmp) 
            {
                dotidx := InStr(fname, ".",, -1)
                if dotidx {
                    extension := SubStr(fname, dotidx+1)
                    ; get available codecs
                    num_codecs := 0
                    size_codecs := 0
                    if imgu_GDIP_OK = DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &num_codecs, "uint*", &size_codecs, "uint") {
                        buf_codecs := Buffer(size_codecs)
                        if imgu_GDIP_OK = DllCall("gdiplus\GdipGetImageEncoders", "uint", num_codecs, "uint", size_codecs, "ptr", buf_codecs.ptr) {
                            i := 0
                            while (i < num_codecs) {
                                pcodec := buf_codecs.ptr + i*104            ; the current codec entry
                                strptr := NumGet(pcodec + 32+3*8, "ptr")    ; pointer to the unicode string describing extensions handled by this codec
                                codecexts := StrGet(strptr, "UTF-16")       ; now an ahk string
                                if (RegExMatch(codecexts, "i).*\*\." . extension . "\b")) {
                                    ; we matched and pcodec points to the clsid
                                    if imgu_GDIP_OK = DllCall("gdiplus\GdipSaveImageToFile", "ptr", pbmp, "wstr", fname, "ptr", pcodec, "ptr", 0, "ptr")
                                        ret := true
                                    break
                                }
                                i++
                            }
                        }
                    }
                }
                DllCall("gdiplus\GdipDisposeImage", "ptr", pbmp)
            }
            return ret
        }

        ;############################################################################################################
        ; crop the image
        ;############################################################################################################
        crop(x, y, w, h) {
            obj := this.i_imgu.from_memory(this.ptr + (y * this.stride) + (x * 4), w, h, this.stride)
            if this.origin
                obj.origin := {x: this.origin.x + x, y: this.origin.y + y}
            return obj
        }

        ;############################################################################################################
        ; get a pixel from the image
        ;############################################################################################################
        get_pixel(x, y) {
            return NumGet(this.ptr + (y * this.stride) + (x * 4), "uint")
        }

        ;############################################################################################################
        ; set a pixel in the image
        ;############################################################################################################
        set_pixel(x, y, px) {
            NumPut("uint", px, this.ptr + (y * this.stride) + (x * 4))
        }

        ;############################################################################################################
        ; extract glyphs from an image
        ;   the image is assumed to be a line of glyphs, such as a captured image of one row of text
        ;############################################################################################################
        extract_glyphs(*) {
            old_tolerance := imgu.tolerance_get()
            imgu.tolerance_set(160)
            glyphs := []
            x := 0
            bgc := this[0, 0, true]
            while (x < this.w) {
                xl := imgu.get_col_mism(this, bgc, x)
                if xl < 0
                    break
                xr := imgu.get_col_match(this, bgc, xl)
                if xr < 0
                    break
                w := xr - xl
                glyph := this.crop(xl, 0, w, this.h)
                glyph := imgu.chop_match_t(glyph, bgc)
                glyph := imgu.chop_match_b(glyph, bgc)
                glyphs.push(glyph)
                x := xr
            }
            imgu.tolerance_set(old_tolerance)
            return glyphs
        }

        ;############################################################################################################
        ; blit - copy another image into this one
        ;############################################################################################################
        blit(srcimg, dx, dy) {
            return this.i_imgu.blit(this.ptr, dx, dy, this.stride//4, srcimg.ptr, 0, 0, srcimg.stride//4, srcimg.w, srcimg.h)
        }

        ;############################################################################################################
        ; fill - fill the image with a color within the given coordinates
        ;############################################################################################################
        fill(x, y, w, h, color) {
            newimg := this.i_imgu.from_memory(this.ptr, this.w, this.h, this.stride)
            newimg.origin := this.origin
            DllCall(this.i_imgu.i_mcode_map["imgutil_fill"], 
                "ptr", newimg.ptr, "int", newimg.w, "int", newimg.h, "int", newimg.stride//4,
                "uint", color, "int", x, "int", y, "int", w, "int", h)
            return newimg
        }

        ;########################################################################################################
        ; convert an image to grayscale
        ;########################################################################################################
        grayscale() {
            newimg := this.i_imgu.from_memory(this.ptr, this.w, this.h, this.stride)
            newimg.origin := this.origin
            DllCall(this.i_imgu.i_mcode_map["imgutil_grayscale"], 
                "ptr", newimg.ptr, "int", newimg.w, "int", newimg.h, "int", newimg.stride//4)
            return newimg
        }

        ;########################################################################################################
        ; replace a color with another within the image
        ;########################################################################################################
        replace_color(color, replacement, tolerance := 0) {
            newimg := this.i_imgu.from_memory(this.ptr, this.w, this.h, this.stride)
            newimg.origin := this.origin
            DllCall(this.i_imgu.i_mcode_map["imgutil_replace_color"], 
                "ptr", newimg.ptr, "int", newimg.w, "int", newimg.h, "int", newimg.stride//4,
                "uint", color, "uint", replacement, "char", tolerance)
            return newimg
        }

        ;########################################################################################################
        ; display the image in a gui
        ;########################################################################################################
        show(w := 0, h := 0, title := "imgutil") {
            if (w = 0 || h = 0) {
                w := this.w
                h := this.h
            }
            _gui := Gui()
            ctl := _gui.Add("pic", "w" . w . " h" . h)
            ; determine correct aspect ratio and adjust control size accordingly
            ctlRatio := w / h
            picRatio := this.w / this.h
            if (ctlRatio > picRatio)
                ctl.move(, , floor(h * picRatio), h)
            else
                ctl.move(, , w, floor(w / picRatio))
            hbm := this.to_hbitmap()
            ctl.Value := "HBITMAP:" . hbm
            DllCall("gdi32\DeleteObject", "ptr", hbm)
            _gui.Show()
            return gui
        }

    } ; end of img class

    ;############################################################################################################
    ; a simple rectangle class to wrap up all the x/y/w/h nonsense
    ;############################################################################################################
    class rect {
        x := 0
        y := 0
        w := 0
        h := 0
        __New(x:=0, y:=0, w:=0, h:=0) {
            this.x := x
            this.y := y
            this.w := w
            this.h := h
        }
        r() {
            return this.x + this.w
        }
        b() {
            return this.y + this.h
        }
        contains(r) {
            return (r.x >= this.x) && (r.y >= this.y) && (r.r() <= this.r()) && (r.b() <= this.b())
        }
        gdiplus_rect() {
            gdirect := Buffer(16, 0)
            NumPut("int", this.x, gdirect.ptr +  0)
            NumPut("int", this.y, gdirect.ptr +  4)
            NumPut("int", this.w, gdirect.ptr +  8)
            NumPut("int", this.h, gdirect.ptr + 12)
            return gdirect
        }
        d3d_box() {
            d3dbox := Buffer(24, 0)
            NumPut("int", this.x,   d3dbox.ptr +  0)
            NumPut("int", this.y,   d3dbox.ptr +  4)
            NumPut("int", 0,        d3dbox.ptr +  8)
            NumPut("int", this.r(), d3dbox.ptr + 12)
            NumPut("int", this.b(), d3dbox.ptr + 16)
            NumPut("int", 1,        d3dbox.ptr + 20)
            return d3dbox
        }
    }
}

;########################################################################################################
; a global instance of the dx_screen provider, to ensure cleanup on program exit
;########################################################################################################
_dx_screen_helper := dx_screen_helper()
class dx_screen_helper {
    provider := 0
    __New() {
        this.provider := image_provider.dx_screen()
    }
    __Delete() {
        ; clean up completely
        this.provider.cleanup_static()
    }
}

;########################################################################################################
; helper class for bitmap-related functions
;########################################################################################################
class i_BITMAPINFOHEADER {
    __New(w := 0, h := 0) {
        this.buffer             := Buffer(40, 0)
        this.biSize             := 40
        this.biWidth            :=  w
        this.biHeight           :=  h
        this.biPlanes           :=  1
        this.biBitCount         := 32
        ; stuff below can be left zeroed
        ; this.biCompression      :=  0 ; BI_RGB=0
        ; this.biSizeImage        :=  0 ; can be 0 for BI_RGB
        ; this.biXPelsPerMeter    :=  0 
        ; this.biYPelsPerMeter    :=  0
        ; this.biClrUsed          :=  0
        ; this.biClrImportant     :=  0
    }
    __Delete() {
    }
    set_w(w) {
        this.biWidth := w
        return this
    }
    set_h(h) {
        this.biHeight := h
        return this
    }
    reset() {
        this.biWidth            :=  0
        this.biHeight           :=  0
        return this
    }
    get() {
        NumPut("int",   this.biSize,     this.buffer,  0)
        NumPut("int",   this.biWidth,    this.buffer,  4)
        NumPut("int",   this.biHeight,   this.buffer,  8)
        NumPut("short", this.biPlanes,   this.buffer, 12)
        NumPut("short", this.biBitCount, this.buffer, 14)
        return this.buffer        
    }
}
