#Requires AutoHotkey 2.0+

#include "lib\ahk\imageput.ahk"
#include "imgutil.ahk"


/*
    innermost:            200x200  0x0000ff (blue) rectangle
    contained in:         400x400  0xff0000 (green) rectangle
    contained in:         600x600  0x00ff00 (red) rectangle   
    contained in:         800x800  0x000000 (black) rectangle
    contained in:       1000x1000  0x101010 (dark gray) rectangle
    contained in:       1200x1200  0x000000 (black) rectangle
*/

test()

test() {
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
    MsgBox("all done.")

    test_rect(img, bgc, t, r, res) {
        y := imgutil_find_row_match(        img, bgc, r.y,              t, r.x, r.x + r.w)
        if y != res[1]
            throw("test error")
        x := imgutil_find_column_match(     img, bgc, r.x,              t, r.y, r.y + r.h)    
        if x != res[2] 
            throw("test error")
        y := imgutil_find_row_match_rev(    img, bgc, r.y + r.h - 1,    t, r.x, r.x + r.w)
        if y != res[3]
            throw("test error")
        x := imgutil_find_column_match_rev( img, bgc, r.x + r.w - 1,    t, r.y, r.y + r.h)
        if x != res[4]
            throw("test error")

        y := imgutil_find_row_mismatch(        img, bgc, r.y,              t, r.x, r.x + r.w)
        if y != res[5]
            throw("test error")
        x := imgutil_find_column_mismatch(     img, bgc, r.x,              t, r.y, r.y + r.h)    
        if x != res[6] 
            throw("test error")
        y := imgutil_find_row_mismatch_rev(    img, bgc, r.y + r.h - 1,    t, r.x, r.x + r.w)
        if y != res[7]
            throw("test error")
        x := imgutil_find_column_mismatch_rev( img, bgc, r.x + r.w - 1,    t, r.y, r.y + r.h)
        if x != res[8]
            throw("test error")
    }
}

class pixel {
    __New(color) {
        this.r := (color >> 16) & 0xff
        this.g := (color >> 8) & 0xff
        this.b := color & 0xff
    }
}
