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
        this.benchmarkFileCtl := this.gui.Add("Text", "section xs", "Currently selected: " . this.benchmarkFileSelection)
        
        v := 0
        while v < 5 {
            this.gui.Add("Text", "section xs w0 h0")
            this.gui.Add("Button", "ys", "X86_X64_V" . v . "N" ).OnEvent("Click", this.benchmark.Bind(this, v, 0))
            this.gui.Add("Text", "ys wp vbenchdisplayN" . v, "")
            this.gui.Add("Button", "ys", "X86_X64_V" . v . "F" ).OnEvent("Click", this.benchmark.Bind(this, v, 1))
            this.gui.Add("Text", "ys wp vbenchdisplayF" . v, "")
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

        this.gui.Show()
    }

    benchmark(benchTarget, forcepixel, ctl, *) {
        imgu.i_mcode_map := imgu.i_get_mcode_map(benchTarget)
        this.ctlbench.Text := "Benchmarking..."
        this.ctlbench.Redraw()
        haystack := ImagePutBuffer("imgutil_test_haystack_with_needle" . this.benchmarkFileSelection . ".png")
        needle := ImagePutBuffer("imgutil_test_needle" . this.benchmarkFileSelection . ".png")
        iterations := 0
        start := A_TickCount
        time_taken := 0
        while time_taken < 5000 {
            iterations++
            imgu.srch(&x, &y, haystack, needle, 8, 95, forcepixel)
            time_taken := A_TickCount - start
        }
        this.ctlbench.Text := "Benchmark: " . iterations . " iterations in " . time_taken . "ms" . "`n" . "Average: " . Format("{:2.2f}", time_taken / iterations)  . "ms per iteration"
        for ctl in this.gui {
            if ctl.Name ~= "benchdisplay" . ((forcepixel) ? "F" : "N") . benchTarget {
                ctl.Text := Format("{:2.2f}", time_taken / iterations)  . "ms"
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
        DllCall(imgu.i_mcode_map["mt_deinit"], "ptr", imgu.i_multithread_ctx)
        imgu.i_multithread_ctx := DllCall(imgu.i_mcode_map["mt_init"], "int", t, "ptr")
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

    runTests(testTarget, ctl, *) {
        imgu.i_mcode_map := imgu.i_get_mcode_map(testTarget)
        this.test()
        MsgBox("all tests completed.")
    }

    test() {

        imgutil.img(imgu).grab_screen(imgutil.rect(0, 0, 200, 200)).save("imgutil_test.tmp.png")
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
