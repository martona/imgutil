#Requires AutoHotkey v2.0

;########################################################################################################
; a series of image providers that make it transparent to imgutil how various images are
; acquired; from a file, from a screenshot, etc.
;########################################################################################################
; abstract-ish base class
class image_provider {

    ptr     := 0            ; pointer to ARGB flat pixel data
    w       := 0            ; image width
    h       := 0            ; image height
    stride  := 0            ; image stride

    __New() {
    }

    __Delete() {
    }

    ; all derived providers end up calling this to provide the 4 basic image properties that we need
    ; to define an image
    get_image(ptr, w, h, stride) {
        this.ptr    := ptr
        this.w      := w
        this.h      := h
        this.stride := stride
        return true
    }

    ;############################################################################################################
    ; image provider for anything gdi+ based (file & memory)
    ;############################################################################################################
    class gdip extends image_provider {

        gdip_pBitmap        := 0
        gdip_bits_locked    := 0
        bits_buffer         := 0
        bitmapdata          := 0

        __New() {
            super.__New()
        }

        __Delete() {
            this.unlock()
            if (this.gdip_pBitmap) {
                DllCall("gdiplus\GdipDisposeImage", "ptr", this.gdip_pBitmap)
                this.gdip_pBitmap := 0
            }
            super.__Delete()
        }

        ; pry out the good bits from the gdi+ cruft
        ; (j/k gdi+ is ok)
        get_image(gdip_pBitmap) {
            ret := false
            if this.gdip_pBitmap := gdip_pBitmap {
                DllCall("gdiplus\GdipGetImageWidth",  "ptr", this.gdip_pBitmap, "uint*", &w:= 0)
                DllCall("gdiplus\GdipGetImageHeight", "ptr", this.gdip_pBitmap, "uint*", &h:= 0)
                if w && h {
                    if this.lock(w, h, w * 4) {
                        ret := super.get_image(this.bits_buffer.ptr, w, h, w * 4)
                    }
                }
            }
            return ret
        }

        ; lock the bitmap object's bits into memory, making the pixel data accessible
        lock(w, h, stride) {
            if (this.gdip_bits_locked)
                return true
            this.bits_buffer := Buffer(stride * h)
            ; the rectangle to be locked is the entire image
            gdirect := imgutil.rect(0, 0, w, h).gdiplus_rect()
            ; bitmapdata struct, only need stride and scan0
            this.bitmapdata := Buffer(32, 0)
            NumPut("int", stride,               this.bitmapdata.ptr +  8) ; bitmapdata->stride
            NumPut("ptr", this.bits_buffer.ptr, this.bitmapdata.ptr + 16) ; bitmapdata->scan0
            ; lock the bits
            if imgu_GDIP_OK = DllCall("gdiplus\GdipBitmapLockBits", 
                    "ptr", this.gdip_pBitmap, 
                    "ptr", gdirect.ptr,
                    "uint", 7,          ; ImageLockModeRead | ImageLockModeWrite | ImageLockModeUserInputBuf
                    "uint", 0x0026200a, ; PixelFormat32bppARGB
                    "ptr", this.bitmapdata.ptr,
                    "uint")
            {
                this.gdip_bits_locked := true
                return true
            }
            return false
        }

        ; unlock the bitmap object and merge any changes were made to the pixel data back into the object
        unlock() {
            if (this.gdip_bits_locked) {
                DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", this.gdip_pBitmap, "ptr", this.bitmapdata)
                ; release internal data
                this.bitmapdata         := 0
                this.bits_buffer        := 0
                this.gdip_bits_locked   := false
                ; also indicate to parent that its data is no longer valid
                super.get_image(0, 0, 0, 0)
            }
            return false
        }

        ;############################################################################################################
        ; gdiplus image provider for file sources
        ;############################################################################################################
        class file extends image_provider.gdip {

            __New() {
                super.__New()
            }

            __Delete() {
                super.__Delete()    
            }

            get_image(fname) {
                ret := false
                ; open the file
                fileobj := FileOpen(fname, "r")
                if fileobj.length = 0
                    return false
                ; read file into a blob
                data := Buffer(fileobj.length)
                fileobj.RawRead(data, fileobj.length)
                fileobj.Close()
                ; create an IStream from the blob
                pstream := DllCall("shlwapi.dll\SHCreateMemStream", "ptr", data.ptr, "uint", data.size, "ptr")
                if pstream {
                    ; get GDI+ to load it. if we use *FromFile it will keep the file locked
                    if (imgu_GDIP_OK = DllCall("gdiplus\GdipLoadImageFromStream", "ptr", pstream, "ptr*", &pbmp := 0)) {
                        ret := super.get_image(pbmp)
                    }
                    ObjRelease(pstream)
                }
                return ret
            }    
        } ; end of image_provider.gdip.file class

    } ; end of image_provider.gdip class


    ;############################################################################################################
    ; image provider for memory sources
    ;############################################################################################################
    class memory extends image_provider {

        buff := 0

        __New() {
            super.__New()
        }

        __Delete() {
            super.__Delete()    
        }

        get_image(ptr, w, h, stride) {
            this.buff := Buffer(w * h * 4)
            imgu.blit(this.buff.ptr, 0, 0, w, ptr, 0, 0, stride//4, w, h)
            return super.get_image(this.buff.ptr, w, h, w * 4)
        }

    } ; end of image_provider.memory class

    ;############################################################################################################
    ; image provider for ImagePutBuffer sources
    ;############################################################################################################
    class imageputbuffer extends image_provider {
        obj := 0
        __New() {
            super.__New()
        }

        __Delete() {
            super.__Delete()    
        }

        get_image(obj) {
            this.obj := obj
            return super.get_image(obj.ptr, obj.width, obj.height, obj.width * 4)
        }

    } ; end of image_provider.memory class

    ;############################################################################################################
    ; gdi screen capture provider
    ;############################################################################################################
    class gdi_screen extends image_provider {

        dibsection := 0             ; the gdi object returned from CreateDIBSection

        __New() {
            super.__New()
        }

        __Delete() {
            if (this.dibsection) {
                DllCall("gdi32\DeleteObject", "ptr", this.dibsection)
                this.dibsection := 0
            }            
            super.__Delete()    
        }

        get_image(rect := 0) {
            ret := false
            if !rect
                rect := imgutil.rect(0, 0, A_ScreenWidth, A_ScreenHeight)

            ; note: this is the slow '90s way, trudging through getdc/bit+blt
            if hdc := DllCall("gdi32\CreateCompatibleDC", "ptr", 0, "ptr") {
                bmp := DllCall("gdi32\CreateDIBSection", "ptr", hdc, 
                            "ptr", i_BITMAPINFOHEADER(rect.w, -rect.h).get(), 
                            "uint", 0, "ptr*", &bits := 0, 
                            "ptr", 0, "uint", 0, "ptr")
                if bmp {
                    if oldbmp := DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", bmp, "ptr") {
                        if screen_dc := DllCall("user32\GetDC", "ptr", 0, "ptr") {
                            DllCall("gdi32\BitBlt", "ptr", hdc, "int", 0, "int", 0, "int", rect.w, "int", rect.h,
                                        "ptr", screen_dc, "int", rect.x, "int", rect.y, 
                                        "uint", 0x40CC0020) ; SRCCOPY | CAPTUREBLT
                            ; our job here is done
                            this.dibsection := bmp
                            super.get_image(bits, rect.w, rect.h, rect.w * 4)
                            ret := {x: rect.x, y: rect.y}

                            DllCall("user32\ReleaseDC", "ptr", 0, "ptr", screen_dc)
                        }                        
                        DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", oldbmp)
                    }
                }
                DllCall("gdi32\DeleteDC", "ptr", hdc)        
            }
            return ret
        }
    } ; end of image_provider.gdi_screen class

    ;############################################################################################################
    ; directx screen capture provider
    ;############################################################################################################
    ; PREPARE FOR A MASSIVE WALL OF CODE
    ;############################################################################################################
    class dx_screen extends image_provider {

        buff := 0

        static hmod_dxgi            := 0
        static hmod_d3d11           := 0
        static ptr_dxgi_factory     := 0
        static ptr_dxgi_adapter     := 0
        static ptr_dxgi_output      := 0
        static d3d_device           := 0
        static d3d_context          := 0
        static ptr_dxgi_output1     := 0
        static ptr_dxgi_dup         := 0
        static using_system_memory  := 0

        static init_successful      := 0
        static last_init_attempt    := 0
        static last_monitor_rect    := 0

        static D3D11_TEXTURE2D_DESC        := Buffer(44, 0)
        static DXGI_OUTDUPL_FRAME_INFO     := Buffer(48, 0)
        static D3D11_MAPPED_SUBRESOURCE    := Buffer(16, 0)
        static DXGI_OUTPUT_DESC            := Buffer(96, 0)
        static DXGI_OUTDUPL_DESC           := Buffer(36, 0)
        static riid                        := Buffer(16, 0)

        static texture_screen           := 0
        static texture_screen_ptr       := 0
        static texture_screen_stride    := 0

        __New() {
            this.s := image_provider.dx_screen
            super.__New()
        }

        __Delete() {
            super.__Delete()    
        }

        ;############################################################################################################
        ; initialize dxgi
        ;############################################################################################################
        init(rect) {

            static D3D_DRIVER_TYPE_UNKNOWN      := 0
            static D3D11_SDK_VERSION            := 7
            static DXGI_FORMAT_B8G8R8A8_UNORM   := 87
            static D3D11_USAGE_STAGING          := 3
            static D3D11_CPU_ACCESS_WRITE       := 0x10000
            static D3D11_CPU_ACCESS_READ        := 0x20000
            static IDXGIFactory_EnumAdapters    := 7
            static IDXGIAdapter_EnumOutputs     := 7
            static IDXGIOutput_GetDesc          := 7
            static D3D11_MAP_READ               := 1
            static D3D11_MAP_WRITE              := 2
            static D3D11_MAP_READ_WRITE         := 3

            ; we don't need to do anything if we're already initialized and the monitor isn't changing
            if  this.s.init_successful && 
                this.s.last_monitor_rect && 
                this.s.last_monitor_rect.contains(rect)
                return true

            ; if the user is asking for a rectangle from a different monitor, we do a fast reinit.
            ; note that this is not optimal, reinit takes ages; the ideal solution would be to prepare
            ; an instance of the environment for each monitor that get_image touches. TODO
            if !(this.s.last_monitor_rect && this.s.last_monitor_rect.contains(rect))
                this.s.last_init_attempt := 0

            ; we're already initialized, but something is wrong (access lost, monitor change, etc)
            if this.s.init_successful
                this.cleanup(true)

            ; this whole initalization thing is expensive, so don't try it too often unless the user just 
            ; wants a screenshot from a different monitor TODO: that case needs to be handled better
            if A_TickCount - this.s.last_init_attempt < 2000
                return false
            this.s.last_init_attempt := A_TickCount

            ; load DLLs
            if !this.s.hmod_dxgi
                this.s.hmod_dxgi  := DllCall("LoadLibrary", "str", "DXGI")
            if !this.s.hmod_d3d11
                this.s.hmod_d3d11 := DllCall("LoadLibrary", "str", "D3D11")
            if !(this.s.hmod_dxgi && this.s.hmod_d3d11)
                return false

            ret := false
            DllCall("ole32\CLSIDFromString", "wstr", "{7b7166ec-21c7-44ae-b21a-c9ae321ae369}", "ptr", this.s.riid , "int")
            if DllCall("DXGI\CreateDXGIFactory1", "ptr", this.s.riid, "ptr*", &p:=0, "int") >= 0 {
                this.s.ptr_dxgi_factory := p
                loop {
                    if ComCall(IDXGIFactory_EnumAdapters, this.s.ptr_dxgi_factory, "uint", A_Index-1, "ptr*", &IDXGIAdapter:=0, "int") >= 0 {
                        loop {
                            if ComCall(IDXGIAdapter_EnumOutputs, IDXGIAdapter, "uint", A_Index-1, "ptr*", &IDXGIOutput:=0, "int") >= 0 {
                                if ComCall(IDXGIOutput_GetDesc, IDXGIOutput, "ptr", this.s.DXGI_OUTPUT_DESC, "int") >= 0 {
                                    x                 := NumGet(this.s.DXGI_OUTPUT_DESC, 64, "int")
                                    y                 := NumGet(this.s.DXGI_OUTPUT_DESC, 68, "int")
                                    Width             := NumGet(this.s.DXGI_OUTPUT_DESC, 72, "int")
                                    Height            := NumGet(this.s.DXGI_OUTPUT_DESC, 76, "int")
                                    AttachedToDesktop := NumGet(this.s.DXGI_OUTPUT_DESC, 80, "int")
                                    if (AttachedToDesktop = 1) {
                                        rect_monitor := imgutil.rect(x, y, Width, Height)
                                        ; we can't do rects that are not fully contained within the adapter's output
                                        if (rect_monitor.contains(rect)) {
                                            this.s.ptr_dxgi_adapter   := IDXGIAdapter
                                            this.s.ptr_dxgi_output    := IDXGIOutput
                                            this.s.last_monitor_rect  := rect_monitor
                                            break 2
                                        }
                                    }
                                }
                                ObjRelease(IDXGIOutput)
                            } else {
                                break
                            }
                        }
                        ObjRelease(IDXGIAdapter)
                    } else {
                        break
                    }
                }
                if !this.s.ptr_dxgi_output {
                    ; don't release DLLs
                    this.cleanup(true)
                    return false
                }

                if DllCall("D3D11\D3D11CreateDevice",
                    "ptr",  this.s.ptr_dxgi_adapter,   ; pAdapter
                    "int",  D3D_DRIVER_TYPE_UNKNOWN,   ; DriverType
                    "ptr",  0,                         ; Software
                    "uint", 0,                         ; Flags
                    "ptr",  0,                         ; pFeatureLevels
                    "uint", 0,                         ; FeatureLevels
                    "uint", D3D11_SDK_VERSION,         ; SDKVersion
                    "ptr*", &d3d_device:=0,            ; ppDevice
                    "ptr*", 0,                         ; pFeatureLevel
                    "ptr*", &d3d_context:=0,           ; ppImmediateContext
                    "int") >= 0 
                {
                    this.s.d3d_device  := d3d_device
                    this.s.d3d_context := d3d_context
                    ; Retrieve the desktop duplication API
                    if this.s.ptr_dxgi_output1 := ComObjQuery(this.s.ptr_dxgi_output, "{00cddea8-939b-4b83-a340-a685226666cc}") {
                        if ComCall(IDXGIOutput1_DuplicateOutput := 22, this.s.ptr_dxgi_output1, "ptr", this.s.d3d_device, "ptr*", &dup:=0, "int") >= 0 {
                            this.s.ptr_dxgi_dup := dup
                            if ComCall(IDXGIOutputDuplication_GetDesc := 7, this.s.ptr_dxgi_dup, "ptr", this.s.DXGI_OUTDUPL_DESC) >= 0 {
                                this.s.using_system_memory := NumGet(this.s.DXGI_OUTDUPL_DESC, 32, "uint")

                                NumPut("uint", this.s.last_monitor_rect.w, this.s.D3D11_TEXTURE2D_DESC,  0)   ; Width
                                NumPut("uint", this.s.last_monitor_rect.h, this.s.D3D11_TEXTURE2D_DESC,  4)   ; Height
                                NumPut("uint",                          1, this.s.D3D11_TEXTURE2D_DESC,  8)   ; MipLevels
                                NumPut("uint",                          1, this.s.D3D11_TEXTURE2D_DESC,  8)   ; MipLevels
                                NumPut("uint",                          1, this.s.D3D11_TEXTURE2D_DESC, 12)   ; ArraySize
                                NumPut("uint", DXGI_FORMAT_B8G8R8A8_UNORM, this.s.D3D11_TEXTURE2D_DESC, 16)
                                NumPut("uint",                          1, this.s.D3D11_TEXTURE2D_DESC, 20)   ; SampleDescCount
                                NumPut("uint",        D3D11_USAGE_STAGING, this.s.D3D11_TEXTURE2D_DESC, 28)
                                NumPut("uint",      D3D11_CPU_ACCESS_READ, this.s.D3D11_TEXTURE2D_DESC, 36)
                                ; create a permanent buffer to hold the screen captures going forward
                                if ComCall(ID3D11Device_CreateTexture2D := 5, this.s.d3d_device, "ptr", this.s.D3D11_TEXTURE2D_DESC, "ptr", 0, "ptr*", &texture_screen:=0, "int") >= 0 {
                                    this.s.texture_screen  := texture_screen
                                    ; map the texture into system memory. it might seem odd to do this here, but it's the "natural" state
                                    ; of the texture. it only gets unmapped to receive the new frame via CopyResource, and then gets
                                    ; mapped again. this way repeated screenshot requests don't have to map/unmap the texture every time.
                                    if ComCall(ID3D11DeviceContext_Map := 14, this.s.d3d_context, "ptr", 
                                        this.s.texture_screen, "uint", 0, 
                                        "uint", D3D11_MAP_READ, "uint", 0, 
                                        "ptr", this.s.D3D11_MAPPED_SUBRESOURCE, "int") >= 0
                                    {
                                        this.s.texture_screen_ptr     := NumGet(this.s.D3D11_MAPPED_SUBRESOURCE, 0, "ptr")
                                        this.s.texture_screen_stride  := NumGet(this.s.D3D11_MAPPED_SUBRESOURCE, 8, "int")
                                        this.s.init_successful := true
                                        ret := true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if !ret
                this.cleanup_static(true)
            return ret
        }

        ;############################################################################################################
        ; cleanup the environment (the statics, that is.)
        ;############################################################################################################
        cleanup_static(partial := false) {

            if this.s.texture_screen_ptr {
                ComCall(ID3D11DeviceContext_Unmap := 15, this.s.d3d_context, 
                    "ptr", this.s.texture_screen, "uint", 0, "int")
                    this.s.texture_screen_ptr := 0
            }

            if this.s.texture_screen {
                ObjRelease(this.s.texture_screen)
                this.s.texture_screen := 0
            }

            this.s.last_monitor_rect      := 0
            this.s.init_successful        := 0
            this.s.using_system_memory    := 0

            if this.s.ptr_dxgi_dup {
                ObjRelease(this.s.ptr_dxgi_dup)
                this.s.ptr_dxgi_dup := 0
            }

            ; ComObjQuery wrapper, no need to explicitly release
            this.s.ptr_dxgi_output1 := 0

            if this.s.d3d_context {
                ObjRelease(this.s.d3d_context)
                this.s.d3d_context := 0
            }

            if this.s.d3d_device {
                ObjRelease(this.s.d3d_device)
                this.s.d3d_device := 0
            }

            if this.s.ptr_dxgi_output {
                ObjRelease(this.s.ptr_dxgi_output)
                this.s.ptr_dxgi_output := 0
            }

            if this.s.ptr_dxgi_adapter {
                ObjRelease(this.s.ptr_dxgi_adapter)
                this.s.ptr_dxgi_adapter := 0
            }

            if this.s.ptr_dxgi_factory {
                ObjRelease(this.s.ptr_dxgi_factory)
                this.s.ptr_dxgi_factory := 0
            }

            ; don't release DLLs if we're not done for good
            if partial
                return

            if this.s.hmod_d3d11 {
                DllCall("FreeLibrary", "ptr", this.s.hmod_d3d11)
                this.s.hmod_d3d11 := 0
            }

            if this.s.hmod_dxgi {
                DllCall("FreeLibrary", "ptr", this.s.hmod_dxgi)
                this.s.hmod_dxgi := 0
            }
        }

        ;############################################################################################################
        ; paydirt, basically
        ;############################################################################################################
        get_image(rect := 0) {

            static IDXGIOutputDuplication_AcquireNextFrame  := 8
            static IDXGIOutputDuplication_ReleaseFrame      := 14
            ID3D11DeviceContext_Map                         := 14
            ID3D11DeviceContext_Unmap                       := 15
            ID3D11DeviceContext_CopyResource                := 47
            static DXGI_ERROR_WAIT_TIMEOUT                  := 0x887a0027
            static ID3D11DeviceContext_Unmap                := 15
            static D3D11_MAP_READ                           := 1
            static D3D11_MAP_WRITE                          := 2
            static D3D11_MAP_READ_WRITE                     := 3
            static release_frame_early                      := false
            static last_screenshot_taken                    := 0 
            static perf_freq                                := 0
            static attempt_start                            := 0
            static time_start                               := 0
            static time_now                                 := 0
            static debug_trace                              := false
            ret := false
            if !rect
                rect := imgutil.rect(0, 0, A_ScreenWidth, A_ScreenHeight)
            if (!perf_freq)
                DllCall("QueryPerformanceFrequency", "int64*", &perf_freq)
            if debug_trace
                DllCall("QueryPerformanceCounter", "int64*", &attempt_start)

            ; initialize the environment if needed
            if this.init(rect) {

                while true {
                    if !release_frame_early
                        ComCall(IDXGIOutputDuplication_ReleaseFrame, this.s.ptr_dxgi_dup, "uint")
                    ; call the duplication API to get the next frame. don't wait for any new updates;
                    ; if there are none, we'll use our permanent buffer from the last frame
                    hr := ComCall(IDXGIOutputDuplication_AcquireNextFrame, this.s.ptr_dxgi_dup, 
                        "uint", release_frame_early ? 0 : 0,
                        "ptr", this.s.DXGI_OUTDUPL_FRAME_INFO, 
                        "ptr*", &ptr_dxgi_resource:=0, 
                        "uint")

                    if !(hr & 0x80000000) {

                        ; has this frame been presented (i.e. is it an actual update that needs to be processed?)
                        if NumGet(this.s.DXGI_OUTDUPL_FRAME_INFO, 0, "int64")  = 0 {
                            if debug_trace
                                OutputDebug "IDXGIOutputDuplication_AcquireNextFrame: this fake update has never been presented, retrying`r`n"
                            if release_frame_early
                                ComCall(IDXGIOutputDuplication_ReleaseFrame, this.s.ptr_dxgi_dup, "uint")
                            Sleep 10
                            continue
                        }
                        ; copy the texture we just received into our permanent buffer

                        ; get the texture interface from the frame data
                        texture_screen_update := ComObjQuery(ptr_dxgi_resource, "{6f15aaf2-d208-4e89-9ab4-489535d34f9c}") ; ID3D11Texture2D
                        ObjRelease(ptr_dxgi_resource)
                        ; unmap the screen texture
                        hr := ComCall(ID3D11DeviceContext_Unmap, this.s.d3d_context, 
                            "ptr", this.s.texture_screen, "uint", 0, "int")
                        ; copy the new frame into our permanent buffer
                        hr := ComCall(ID3D11DeviceContext_CopyResource, this.s.d3d_context, 
                            "ptr", this.s.texture_screen, 
                            "ptr", texture_screen_update, 
                            "int")
                        ; and map the texture again
                        hr := ComCall(ID3D11DeviceContext_Map, this.s.d3d_context, 
                            "ptr", this.s.texture_screen, "uint", 0, 
                            "uint", D3D11_MAP_READ, "uint", 0, 
                            "ptr", this.s.D3D11_MAPPED_SUBRESOURCE, "int")
                        this.s.texture_screen_ptr     := NumGet(this.s.D3D11_MAPPED_SUBRESOURCE, 0, "ptr")
                        this.s.texture_screen_stride  := NumGet(this.s.D3D11_MAPPED_SUBRESOURCE, 8, "int")

                    } else if hr = DXGI_ERROR_WAIT_TIMEOUT {
                        DllCall("QueryPerformanceCounter", "int64*", &time_now)
                        time_from_last_screenshot := (time_now - last_screenshot_taken) * 1000000 / perf_freq
                        ; if the frame is at most 50ms old, we'll use it, otherwise we'll force a new one
                        if time_from_last_screenshot < 50000 {
                            if debug_trace                                  
                                OutputDebug "IDXGIOutputDuplication_AcquireNextFrame timed out, using last frame from " Format("{:d}us ago`r`n", time_from_last_screenshot)
                        } else {
                            if debug_trace
                                OutputDebug "IDXGIOutputDuplication_AcquireNextFrame timed out with a " Format("{:d}us", time_from_last_screenshot) " old frame, retrying`r`n"
                            Sleep 10
                            continue
                        }
                    } else if hr & 0x80000000 {
                        ; if we flat out failed, we'll need to reinit; the assumption is that the
                        ; monitor, desktop, lock state, etc. changed
                        if debug_trace
                            OutputDebug "IDXGIOutputDuplication_AcquireNextFrame failed: " Format("0x{:8x}", hr)
                        this.cleanup_static(true)
                        return false
                    }

                    ; a legit framebuffer should never contain 0x00000000 pixels due to the 0xff alpha channel value
                    if !NumGet(this.s.texture_screen_ptr, 0, "uint") {
                        if debug_trace
                            OutputDebug "Got a null framebuffer! Going back to complain to the manager."
                        if release_frame_early
                            ComCall(IDXGIOutputDuplication_ReleaseFrame, this.s.ptr_dxgi_dup, "uint")
                        Sleep 10
                        continue
                    }

                    if !this.s.using_system_memory {  ; TODO what if system memory is used?
                        ; map the texture into system memory
                        ; allocate the buffer we'll hold the data in
                        imgdata := Buffer(rect.w * rect.h * 4)
                        ; TODO: we need to rebase the rect to the monitor's origin
                        imgu.blit(imgdata.ptr, 0, 0, rect.w,      ; destination, top left corner of bufer with stride=width
                                this.s.texture_screen_ptr,        ; source, the screen buffer
                                rect.x, rect.y,                   ; source coordinates, whatever the user asked for
                                this.s.texture_screen_stride//4,  ; stride in pixels
                                rect.w, rect.h)                   ; dimensions as per user
                        this.buff := imgdata
                        super.get_image(imgdata.ptr, rect.w, rect.h, rect.w * 4)
                        ; return the origin to caller
                        ret := {x: rect.x, y: rect.y}
                    }
                    if release_frame_early
                        ComCall(IDXGIOutputDuplication_ReleaseFrame, this.s.ptr_dxgi_dup, "uint")
                    DllCall("QueryPerformanceCounter", "int64*", &last_screenshot_taken)
                    break
                }
            }
            if debug_trace {
                DllCall("QueryPerformanceCounter", "int64*", &time_now)
                OutputDebug "get_image took " . Format("{:d}us`r`n", (time_now - attempt_start) * 1000000 / perf_freq)
            }
            return ret
        } ; end of get_image
    } ; end of image_provider.dx_screen class
} ; end of image_provider class
