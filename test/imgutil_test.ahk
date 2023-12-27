#Requires AutoHotkey 2.0+

#include "..\lib\ahk\imageput.ahk"
#include "..\imgutil.ahk"


/*
    innermost:            200x200  0x0000ff (blue) rectangle
    contained in:         400x400  0xff0000 (green) rectangle
    contained in:         600x600  0x00ff00 (red) rectangle   
    contained in:         800x800  0x000000 (black) rectangle
    contained in:       1000x1000  0x101010 (dark gray) rectangle
    contained in:       1200x1200  0x000000 (black) rectangle
*/

imgutilTest().show()

class imgutilTest {

    gui := 0
    ctlbench := 0
    benchmarkFileCtl := 0
    benchmarkFileSelection := "01"
    benchmarkThreadCtlText := 0
    benchmarkThreadCtlEdit := 0
    benchmarkMultiCtl := 0

    show() {
        this.gui := Gui()
        this.gui.Add("Text", "section", "Tests")
        this.gui.Add("Text", "section xs w0 h0")
        this.gui.Add("Button", "", "X86_X64_V0").OnEvent("Click", this.runTests.Bind(this, 0))
        this.gui.Add("Button", "", "X86_X64_V1").OnEvent("Click", this.runTests.Bind(this, 1))
        this.gui.Add("Button", "", "X86_X64_V2").OnEvent("Click", this.runTests.Bind(this, 2))
        this.gui.Add("Button", "", "X86_X64_V3").OnEvent("Click", this.runTests.Bind(this, 3))
        this.gui.Add("Button", "", "X86_X64_V4").OnEvent("Click", this.runTests.Bind(this, 4))

        this.gui.Add("Text", "section xs", "Benchmarks")
        this.gui.Add("Text", "section xs w0 h0")
        this.gui.Add("Button", "ys", "Haystack/needle 01").OnEvent("Click", this.benchmarkFile.Bind(this, "01"))
        this.gui.Add("Button", "ys", "Haystack/needle 02").OnEvent("Click", this.benchmarkFile.Bind(this, "02"))
        this.gui.Add("Button", "ys", "Haystack/needle 03").OnEvent("Click", this.benchmarkFile.Bind(this, "03"))
        this.gui.Add("Button", "ys", "Haystack/needle 04").OnEvent("Click", this.benchmarkFile.Bind(this, "04"))
        this.benchmarkFileCtl := this.gui.Add("Text", "section xs", "Currently selected: " . this.benchmarkFileSelection)
        
        v := 0
        while v < 5 {
            this.gui.Add("Text", "section xs", "X86_X64_V" . v)
            this.gui.Add("Button", "ys", "srch (brute)"  ).OnEvent("Click", this.benchmark.Bind(this, v, 0))
            this.gui.Add("Edit", "ys w70 vbenchdisplay0" . v, "")
            this.gui.Add("Button", "ys", "srch (pixel)"  ).OnEvent("Click", this.benchmark.Bind(this, v, 1))
            this.gui.Add("Edit", "ys w70 vbenchdisplay1" . v, "")
            this.gui.Add("Button", "ys", "blit"          ).OnEvent("Click", this.benchmark.Bind(this, v, 2))
            this.gui.Add("Edit", "ys w70 vbenchdisplay2" . v, "")
            this.gui.Add("Button", "ys", "gdi_scrshot"   ).OnEvent("Click", this.benchmark.Bind(this, v, 3))
            this.gui.Add("Edit", "ys w70 vbenchdisplay3" . v, "")
            this.gui.Add("Button", "ys", "dxgi_scrshot"  ).OnEvent("Click", this.benchmark.Bind(this, v, 4))
            this.gui.Add("Edit", "ys w70 vbenchdisplay4" . v, "")
            v++
        }
        this.ctlbench := this.gui.Add("Text", "section xs w300 +Multi h40", "")
        this.benchmarkMultiCtl := this.gui.Add("Checkbox", "section xs checked", "Allow multiple threads")
        this.benchmarkMultiCtl.OnEvent("Click", this.benchmarkMulti.Bind(this))

        this.gui.Add("Text", "ys", "Threads:") 
        this.benchmarkThreadCtlText := this.gui.Add("Text", "ys", "000")
        this.benchmarkThreadCtlText.Value := DllCall(imgu.i_mcode_map["mt_get_cputhreads"], "ptr", imgu.i_multithread_ctx,  "int")
        this.benchmarkThreadCtlEdit := this.gui.Add("Edit", "ys w40", this.benchmarkThreadCtlText.Text)
        this.gui.Add("Button", "ys", "Set").OnEvent("Click", this.benchmarkThreadCtl.Bind(this))
        this.gui.Add("Button", "ys", "Find blt muti/single sweet spot").OnEvent("Click", this.blitSweetSpotFinder.Bind(this))

        this.gui.Show()
    }

    benchmark(benchTarget, target, ctl, *) {
        imgu.i_mcode_map := imgu.i_get_mcode_map(benchTarget)
        this.ctlbench.Text := "Benchmarking..."
        this.ctlbench.Redraw()
        iterations := 0
        start := A_TickCount
        time_taken := 0
        haystack := ImagePutBuffer("imgutil_test_haystack_with_needle" . this.benchmarkFileSelection . ".png")
        needle := ImagePutBuffer("imgutil_test_needle" . this.benchmarkFileSelection . ".png")
        if target = 0 {
            ;;; benchmark imgu.srch without forced top left pixel
            while time_taken < 5000 {
                iterations++
                imgu.srch(&x, &y, haystack, needle, 8, 95, 0)
                time_taken := A_TickCount - start
            }
        } else if target = 1 {
            ;;; benchmark imgu.srch with forced top left pixel
            while time_taken < 5000 {
                iterations++
                imgu.srch(&x, &y, haystack, needle, 8, 95, 1)
                time_taken := A_TickCount - start
            }
        } else if target = 2 {
            ;;; benchmark imgu.blit
            while time_taken < 5000 {
                iterations++
                imgu.blit(haystack.ptr, 0, 0, haystack.width, needle.ptr, 0, 0, needle.width, needle.width, needle.height)
                time_taken := A_TickCount - start
            }
        } else if target = 3 {
            ;;; benchmark screenshots (gdi)
            while time_taken < 5000 {
                iterations++
                image_provider.gdi_screen().get_image()
                time_taken := A_TickCount - start
            }
        } else if target = 4 {
            ;;; benchmark screenshots (dxgi)
            while time_taken < 5000 {
                iterations++
                image_provider.dx_screen().get_image()
                time_taken := A_TickCount - start
            }
        }
        iter_time := time_taken / iterations
        if (iter_time < 10)
            iter_text := Format("{:2.2f}", time_taken * 1000 / iterations) . "us"
        else
            iter_text := Format("{:2.2f}", time_taken / iterations) . "ms"

        this.ctlbench.Text := "Benchmark: " . iterations . " iterations in " . time_taken . "ms" . "`n" . "Average: " . iter_text . " per iteration"
        for ctl in this.gui {
            if ctl.Name ~= "benchdisplay" . target . benchTarget {
                ctl.Value := iter_text
            }
        }
        return
    }

    benchmarkThreadCtl(ctl, *) {
        t := this.benchmarkThreadCtlEdit.Text
        if (t < 1) 
            t := 1
        if t > DllCall(imgu.i_mcode_map["mt_get_cputhreads"], "ptr", imgu.i_multithread_ctx,  "int")
            t := DllCall(imgu.i_mcode_map["mt_get_cputhreads"], "ptr", imgu.i_multithread_ctx,  "int")
        this.benchmarkThreadCtlText.Text := t
        imgu.set_threads(t)
    }

    benchmarkMulti(ctl, *) {
        if this.benchmarkMultiCtl.Value {
            imgu.i_use_single_thread := false
        } else {
            imgu.i_use_single_thread := true
        }
    }

    benchmarkFile(selection, ctl, *) {
        this.benchmarkFileCtl.Text := "Currently selected: " . selection
        this.benchmarkFileSelection := selection
    }

    blitSweetSpotFinder(*) {
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; find the optimal thread count to use with blit
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        threads_lo := 1
        threads_hi := DllCall(imgu.i_mcode_map["mt_get_cputhreads"], "ptr", imgu.i_multithread_ctx,  "int")
        b := Buffer(4096 * 4096 * 4)
        imgu.set_threads(threads_lo)
        iters_lo := timeblit(4096, b)
        imgu.set_threads(threads_hi)
        iters_hi := timeblit(4096, b)
        iters := 0
        while(1) {
            OutputDebug iters . ": threads_lo: " . threads_lo . ", threads_hi: " . threads_hi . ", iters_lo: " . iters_lo . ", iters_hi: " . iters_hi . "`r`n"
            if (threads_lo = threads_hi) || iters > 20 {
                MsgBox("sweet spot found: " . threads_hi)
                break
            }
            threads_test := (threads_lo + threads_hi)//2
            imgu.set_threads(threads_test)
            iters_test := timeblit(4096, b)
            if (iters_test >= iters_lo) {
                threads_lo := threads_test
                iters_lo := iters_test
            } else if (iters_test >= iters_hi) {
                threads_hi := threads_test
                iters_hi := iters_test
            } else {
                OutputDebug "wtf: " . iters_test . ", " . iters_lo . ", " . iters_hi . "`r`n"
            }
            iters++
        }
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; find the cutoff point between single/multi thread performance with blit
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        size_lo := 128
        size_hi := 4096
        ratio_lo := get_ratio(size_lo)
        ratio_hi := get_ratio(size_hi)
        iters := 0
        while (1) {
            OutputDebug iters . ": size_lo: " . size_lo . ", size_hi: " . size_hi . ", ratio_lo: " . ratio_lo . ", ratio_hi: " . ratio_hi . "`r`n"
            if (abs(size_lo - size_hi) < 2) || iters > 20 {
                MsgBox("sweet spot found: " . size_lo . "/" . size_hi)
                return floor(size_lo)
            }
            size_test := (size_lo + size_hi) / 2
            ratio_test := get_ratio(size_test)
            if (ratio_test > 1) {
                size_lo := size_test
                ratio_lo := ratio_test
            } else {
                size_hi := size_test
                ratio_hi := ratio_test
            }
            iters++
        }

        get_ratio(size) {
            size := floor(size)
            b := Buffer(size * size * 4)
            imgu.i_use_single_thread := true
            iters_single := timeblit(size, b)
            imgu.i_use_single_thread := false
            iters_multi := timeblit(size, b)
            return iters_single / iters_multi
        }

        timeblit(size, buffer) {
            iterations := 0
            start := A_TickCount
            time_taken := 0
            while time_taken < 1000 {
                iterations++
                imgu.blit(buffer.ptr, 0, 0, size, buffer.ptr, 0, 0, size, size, size)
                time_taken := A_TickCount - start
            }
            return iterations
        }
    }

    runTests(testTarget, ctl, *) {
        imgu.i_mcode_map := imgu.i_get_mcode_map(testTarget)
        this.test()
        MsgBox("all tests completed.")
    }

    test() {

        imgutil.img(imgu).grab_screen(imgutil.rect(0, 0, 640, 480)).save("imgutil_test.tmp.png")
        img1 := ImagePutBuffer("imgutil_test.tmp.png")
        img2 := ImagePutBuffer("imgutil_test.tmp.png")
        FileDelete("imgutil_test.tmp.png")
        if !imgu.srch(&x, &y, img1, img2, 0, 100, 0)
            throw("test error")

        img := ImagePutBuffer("imgutil_test.png")

        bgc := 0x000000
        rect := {x: 0, y: 0, w: 1200, h: 1200}

        p := pixel(img[0,0])
        results := [0, 0, 1200-1, 1200-1, 300, 300, 1200-1-300, 1200-1-300]
        test_rect(img, bgc, 18, {x: 0, y: 0, w: 1200, h: 1200}, results)
        results := [0, 0, 1200-1, 1200-1, 100, 100, 1200-1-100, 1200-1-100]
        test_rect(img, bgc,  0, {x: 0, y: 0, w: 1200, h: 1200}, results)
        results := [0, 0, 1200-1, 1200-1, 300, 300, 1200-1-300, 1200-1-300]
        test_rect(img, bgc, 18, {x: 0, y: 0, w: 1200, h: 1200}, results)

        haystack := ImagePutBuffer("imgutil_test_haystack_with_needle01.png")
        needle := ImagePutBuffer("imgutil_test_needle01.png")

        ;TODO: need more of these tests
        if !imgu.srch(&x, &y, haystack, needle, 8, 95, 1)
            throw("test error")
        if x != 3840 - 64 || y != 2160 - 64
            throw("test error (x: " . x . ", y: " . y . ")")
        if !imgu.srch(&x, &y, needle, needle, 8, 95, 1)
            throw("test error")
        if x != 0 || y != 0
            throw("test error (x: " . x . ", y: " . y . ")")

        haystack := ImagePutBuffer("imgutil_test_haystack_with_needle02.png")
        needle := ImagePutBuffer("imgutil_test_needle02.png")

        ;TODO: need more of these tests
        if !imgu.srch(&x, &y, haystack, needle, 8, 100, 0)
            throw("test error")
        if x != 1787 || y != 2104
            throw("test error (x: " . x . ", y: " . y . ")")
        if !imgu.srch(&x, &y, needle, needle, 8, 95, 1)
            throw("test error")
        if x != 0 || y != 0
            throw("test error (x: " . x . ", y: " . y . ")")

        haystack := ImagePutBuffer("imgutil_test_haystack_with_needle03.png")
        needle := ImagePutBuffer("imgutil_test_needle03.png")

        ;TODO: need more of these tests
        if !imgu.srch(&x, &y, haystack, needle, 8, 100, 0)
            throw("test error")
        if x != 1925 || y != 2154
            throw("test error (x: " . x . ", y: " . y . ")")
        if !imgu.srch(&x, &y, needle, needle, 8, 95, 1)
            throw("test error")
        if x != 0 || y != 0
            throw("test error (x: " . x . ", y: " . y . ")")


        test_rect(img, bgc, t, r, res) {
            imgu.tolerance_set(t)
            y := imgu.get_row_match(    img, bgc, r.y,              r.x, r.x + r.w)
            if y != res[1]
                throw("test error")
            x := imgu.get_col_match(    img, bgc, r.x,              r.y, r.y + r.h)    
            if x != res[2] 
                throw("test error")
            y := imgu.get_row_match_rev(img, bgc, r.y + r.h - 1,    r.x, r.x + r.w)
            if y != res[3]
                throw("test error")
            x := imgu.get_col_match_rev(img, bgc, r.x + r.w - 1,    r.y, r.y + r.h)
            if x != res[4]
                throw("test error")

            y := imgu.get_row_mism(     img, bgc, r.y,              r.x, r.x + r.w)
            if y != res[5]
                throw("test error")
            x := imgu.get_col_mism(     img, bgc, r.x,              r.y, r.y + r.h)    
            if x != res[6] 
                throw("test error")
            y := imgu.get_row_mism_rev( img, bgc, r.y + r.h - 1,    r.x, r.x + r.w)
            if y != res[7]
                throw("test error")
            x := imgu.get_col_mism_rev( img, bgc, r.x + r.w - 1,    r.y, r.y + r.h)
            if x != res[8]
                throw("test error")
        }
    }
}


class pixel {
    __New(color) {
        this.r := (color >> 16) & 0xff
        this.g := (color >> 8) & 0xff
        this.b := color & 0xff
    }
}
