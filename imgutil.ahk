#Requires AutoHotkey v2.0
/*
    imgutil_pixels_match(a, b, t)
        returns true if the ARGB values of a and b are within t of each other
    imgutil_column_uniform(px, refc, x, t, yf, yt) 
        returns true if all pixels of px in column x, between rows yf and yt, 
        are within t of refc
    imgutil_row_uniform(px, refc, y, t, xf, xt) 
        returns true if all pixels of px in row y, between columns xf and xt, 
        are within t of refc        
*/

i_imgutil_mcode_map := i_imgutil_generate_mcode_map()

i_imgutil_generate_mcode_map() {
    static b64 := ""
    . "" ; imgutil_various.c
    . "" ; 2624 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTichBidHB6BBBwekQRQ+2yQ+2wEQpyEG"
    . "JwUH32UQPSMhFMdJFOch8MA+2xQ+23inYQYnBQffZRA9IyEU5yHwZD7bJD7bSKdGJyPfYD0jBRT"
    . "HSQTnAQQ+dwkSJ0FvDZpBWU0SLRCRQSGNcJDhED6/CRInIRItMJEAPtvRBicPB6BBBifJNY8BJA"
    . "dhKjTSBRItEJEhED6/CTWPASQHYSo0MgUg58Q+DtgAAAA+2wIP6AXVWD7ZRAinCQYnQQffYRA9I"
    . "wkU5wXw5D7ZRAUUPtsJEKcJBidBB99hED0jCRTnBfB8PthFFD7bDRCnCQYnQQffYRA9IwkU5wX1"
    . "2Zg8fRAAAMcBbXsMPHwBED7ZBAkEpwESJw/fbQQ9I2EE52XziRA+2QQFBD7baQSnYRInD99tBD0"
    . "jYQTnZfMhED7YBQQ+220Ep2ESJw/fbQQ9I2EE52XyvTGPCSo0MgUg58XKrDx8AuAEAAADrm2YPH"
    . "4QAAAAAAEiDwQRIOfEPgjX////r4ZBTD69UJDBMY0QkSEhj0kSJyEkB0ESLTCQ4D7bcQYnDwegQ"
    . "QYnaSo0cgUxjRCRATAHCTI0EkUk52HNMD7bAQQ+2UAIpwonR99kPSMpBOcl8QEEPtlABQQ+2yin"
    . "KidH32Q9IykE5yXwpQQ+2EEEPtsspyonR99kPSMpBOcl8E0mDwARJOdhyt7gBAAAAW8MPHwAxwF"
    . "vDZmYuDx+EAAAAAACQVlNED6/CSInIScHgAk6NFAFMOdEPg7UFAABJg+gBRQ+2yUyJw0jB6wJMj"
    . "VsBSYH4/wAAAA+GtQUAAEyJwr4BAAAARTDAYuH/SG81sQUAAGLh/0hvFecFAABIweoIYuH/SG8t"
    . "GQYAAGLCfUh82WLxf0hvJUkGAABJAchi8X9Ibx18BgAAYvJ9SHzuYuH/SG8NrAYAAGKhRQDv/2L"
    . "h/0hvJdwGAABio31AJcD/Dx9EAABi8f9IbxFi8T1AcREISIHBAAEAAGLxLUBxUf8IYvJ+SDDRYg"
    . "J+SDDAYvH/SG9R/WICfkgw0mLyfkgw0GLx/0hvUf5i8/VIOsgBYpJ+SDDRYvH/SG9R/2KSfkgwy"
    . "2LxdUhx0Qhi8n5IMNBi8n5IMMliY7VAOsgBYvJ9SDDJYvF9SHFR/QhikW1IcdEIYgJ+SDDJYvJ+"
    . "SDDSYgJ9SDDJYvJ+SDDAYvJ9SDDSYmO9QDrAAWLxfUhxUf4IYgJ+SDDAYvJ+SDDAYgJ9SDDAYpP"
    . "9SDrCAWKRdUj9yGICfUgww2LyfkgwwGKRdUj9yGLyfUgwwGLxbUj90GLyfUgzwWLz/Ug7yQFis3"
    . "1IHssFYvJ9SDPJYpFtSP3RYvF9yW/FYrN1SB7LBWLyfUgzymLz/Ug70gFi8n1IM9JiYX3Jb8Vis"
    . "3VIHssFYpLNQH3AYiH9SG/AYvJ+SDDAYvF9yW/NYrNtSB7LBWLxfclv1WLyzUB9ymKx/Uhv0GLy"
    . "fkgwyWLz/Ug6wQFisf1Ib8hi8UVA+MBi8u1AfdBi8tVAfchiYt1AfcBi8nVIAMti8m1IANRiYu1"
    . "Ajchi8e1I69Fisf1Ib8hiYj1AAMNi8vVAfchi8vVAjcBi8nVIAMxiYn1IANRi8n1IAMNikfVI68"
    . "hiYjVAAMRiYjVAAMtiAb1A68FiYa1A69BiYf1Ib8pi8f1Ib8JiAtVAfchiku1AfcBiYjVAAMti8"
    . "n1IAMRikf1I68Fi8X9If0H8YvH9SG/CYpLdQH3QYpL1QH3AYvJtSADTYvJ9SADEYvH9SOvCYvH9"
    . "SG/RYvF/SH9B/WLx/UhvwWKS1UB90mKS7UB9wmLybUgA02LyfUgAxGLx/UjrwmLxf0h/Qf5i8f1"
    . "Ib8Fikt1AfcpikvVAfcJi8nVIAMti8n1IAMRi8f1I68Fi8X9If0H/TDnBD4VB/f//SInRSMHiCE"
    . "jB4QZIAcJIKctIg/sfD4YOAgAASI0MiEG4/wAAAGLSfSh86UiD4+Bi0n0oe9jF5dtJIMXl2wFBu"
    . "AEAAADF5dtRYGLxfSBxUQMISI0UmsX9Z8HF5dtJQMTj/QDA2MX1Z8rF5dvgxOP9AMnYxf1x0AjF"
    . "5dvRxfVx0QjF3WfiYvFtKHFRAQjF/WfBYvF1KHERCMTj/QDA2MTj/QDk2MX1Z8pi8W0ocVECCMT"
    . "j/QDJ2GKxbShn0MXl28nE4/0A0tjF5dvSxfVnysTifTDQxON9OcABxOP9AMnYxOJ9MMBi4n0oMM"
    . "HE4305yQFisW0o/dDE4n0wyWLifSgwxMTjfTnkAcX9/cFisW0o/dDE4n0w5MTjfTnRAWLCfSh8w"
    . "MX9/cTE4n0z4sTifTPJxOJ9M9DE4lU75MTiVTvJxON9OcABxdV25MTiVTvSxdV2ycXVdtLE4n0z"
    . "wMTiVTvAxdV26GKxXSjb4GKxdSjbyGKxbSjb0MX9b8RisVUo2+hi4f8obwUIAQAAYvL9IH3BYuL"
    . "tKHXFxfHvycXl28BiseUo29jF/WfDxeV228Tj/QDA2MX1+MDF5WDIxeVo2MTjfUbgAMTjdUbTIM"
    . "TjdUbLMcTjfUbAEcX+bx10AgAAxOJdAOPE4n0Aw8XtYNzF7WjUxONlRuIgxONlRtoxxfVg0MX1a"
    . "MDF/n8hxONtRsggxONtRtAxxf5/WSDF/n9JQMX+f1FgDx+AAAAAAEQPtkIBD7ZKAkQBwUQPtgLG"
    . "Av9EAcFEOclzJcZCAQBIg8IExkL+AMZC/wBMOdJy0EqNBJjF+HdbXsNmDx9EAADGQgH/SIPCBMZ"
    . "C/v/GQv//TDnScqvr2UiJyjHJ6YT9//8PH4AAAAAAAAACAAQABgAIAAoADAAOABAAEgAUABYAGA"
    . "AaABwAHgAgACIAJAAmACgAKgAsAC4AMAAyADQANgA4ADoAPAA+AAAAAAABAAEAAgACAAMAAwAEA"
    . "AQABQAFAAYABgAHAAcACAAIAAkACQAKAAoACwALAAwADAANAA0ADgAOAA8ADwAgACAAIQAhACIA"
    . "IgAjACMAJAAkACUAJQAmACYAJwAnACgAKAApACkAKgAqACsAKwAsACwALQAtAC4ALgAvAC8AAP8"
    . "D/wT/B/8I/wv/DP8P/wD/A/8E/wf/CP8L/wz/D/8A/wP/BP8H/wj/C/8M/w//AP8D/wT/B/8I/w"
    . "v/DP8P//8A/wP/BP8H/wj/C/8M/w//AP8D/wT/B/8I/wv/DP8P/wD/A/8E/wf/CP8L/wz/D/8A/"
    . "wP/BP8H/wj/C/8M/w8QABAAEQARABIAEgATABMAFAAUABUAFQAWABYAFwAXABgAGAAZABkAGgAa"
    . "ABsAGwAcABwAHQAdAB4AHgAfAB8AMAAwADEAMQAyADIAMwAzADQANAA1ADUANgA2ADcANwA4ADg"
    . "AOQA5ADoAOgA7ADsAPAA8AD0APQA+AD4APwA/AAAAAQECAgMDBAQFBQYGBwcICAkJCgoLCwwMDQ"
    . "0ODg8PkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJA="
    . "" ; 0x000000: imgutil_channel_match
    . "" ; 0x000020: imgutil_pixels_match
    . "" ; 0x000080: imgutil_column_uniform
    . "" ; 0x0001a0: imgutil_row_uniform
    . "" ; 0x000240: imgutil_makebw
            
        static code := b64code(b64)
        return Map("imgutil_channel_match",     code + 0x000000
                 , "imgutil_pixels_match",      code + 0x000020
                 , "imgutil_column_uniform",    code + 0x000080
                 , "imgutil_row_uniform",       code + 0x0001a0
                 , "imgutil_makebw",            code + 0x000240
                 )
 }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
imgutil_channel_match(a, b, t) {
    return ((a - t) <= b) && ((a + t) >= b)
}
imgutil_pixels_match(a, b, t) {
    r1 := (a & 0x00FF0000) >> 16
    r2 := (b & 0x00FF0000) >> 16
    g1 := (a & 0x0000ff00) >>  8
    g2 := (b & 0x0000ff00) >>  8
    b1 := (a & 0x000000ff)
    b2 := (b & 0x000000ff)
    return imgutil_channel_match(r1, r2, t) && imgutil_channel_match(g1, g2, t) && imgutil_channel_match(b1, b2, t)
}*/
imgutil_pixels_match(a, b, t) {
    return DllCall(i_imgutil_mcode_map["imgutil_pixels_match"], "uint", a, "uint", b, "uint", t, "int")
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
imgutil_column_uniform(px, refc, x, t, yf := 0, yt := -1) {
    if yt = -1
        yt := px.height
    y := yf
    while (y < yt) {
        if !imgutil_pixels_match(px[x, y], refc, t)
            return 0
        y := y + 1
    }
    return 1
}*/
imgutil_column_uniform(px, refc, x, t, yf := 0, yt := -1) {
    if yt = -1
        yt := px.height
    return DllCall(i_imgutil_mcode_map["imgutil_column_uniform"]
        , "ptr", px
        , "int", px.width
        , "int", px.height
        , "uint", refc
        , "int", x
        , "int", t
        , "int", yf
        , "int", yt
        , "int"
    )
}

/*
imgutil_row_uniform(px, refc, y, t, xf := 0, xt := -1) {
    if xt = -1
        xt := px.width
    x := xf
    while (x < px.width) {
        if !imgutil_pixels_match(px[x, y], refc, t)
            return 0
        x := x + 1
    }
    return 1
}*/
imgutil_row_uniform(px, refc, y, t, xf := 0, xt := -1) {
    if xt = -1
        xt := px.width
    return DllCall(i_imgutil_mcode_map["imgutil_row_uniform"]
        , "ptr", px
        , "int", px.width
        , "int", px.height
        , "uint", refc
        , "int", y
        , "int", t
        , "int", xf
        , "int", xt
        , "int"
    )
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;def find_column_match(img, px, refcolor, startx):
;    for x in range(startx, img.size[0]):
;        if column_uniform(img, px, refcolor, x):
;            return x
;    return -1
imgutil_find_column_match(px, refc, x, t, yf:=0, yt:=-1) {
    while(x < px.width) {
        if imgutil_column_uniform(px, refc, x, t, yf, yt)
            return x
        x := x + 1
    }
    return -1
}

;def find_column_match_rev(img, px, refcolor, startx):
;    for x in range(startx, -1, -1):
;        if column_uniform(img, px, refcolor, x):
;            return x
;    return -1
imgutil_find_column_match_rev(px, refc, x, t, yf:=0, yt:=-1) {
    while(x >= 0) {
        if imgutil_column_uniform(px, refc, x, t, yf, yt)
            return x
        x := x - 1
    }
    return -1
}

;def find_column_mismatch_rev(img, px, refcolor, startx):
;    for x in range(startx, -1, -1):
;        if not column_uniform(img, px, refcolor, x):
;            return x
;    return -1
imgutil_find_column_mismatch(px, refc, x, t, yf:=0, yt:=-1) {
    if (yt = -1)
        yt := px.height
    while(x < px.width) {
        if !imgutil_column_uniform(px, refc, x, t, yf, yt)
            return x
        x := x + 1
    }
    return -1
}

;def find_column_mismatch(img, px, refcolor, startx):
;    for x in range(startx, img.size[0]):
;        if not column_uniform(img, px, refcolor, x):
;            return x
;    return -1
imgutil_find_column_mismatch_rev(px, refc, x, t, yf:=0, yt:=-1) {
    while(x >= 0) {
        if !imgutil_column_uniform(px, refc, x, t, yf, yt)
            return x
        x := x - 1
    }
    return -1
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;def find_row_match(img, px, refcolor, starty):
;    for y in range(starty, img.size[1]):
;        if row_uniform(img, px, refcolor, y):
;            return y
;    return -1
imgutil_find_row_match(px, refc, y, t, xf:=0, xt:=-1) {
    while(y < px.height) {
        if imgutil_row_uniform(px, refc, y, t, xf, xt)
            return y
        y := y + 1
    }
    return -1
}

;def find_row_match_rev(img, px, refcolor, starty):
;    for y in range(starty, -1, -1):
;        if row_uniform(img, px, refcolor, y):
;            return y
;    return -1
imgutil_find_row_match_rev(px, refc, y, t, xf:=0, xt:=-1) {
    while(y >= 0) {
        if imgutil_row_uniform(px, refc, y, t, xf, xt)
            return y
        y := y - 1
    }
    return -1
}

;def find_row_mismatch(img, px, refcolor, starty):
;    for y in range(starty, img.size[1]):
;        if not row_uniform(img, px, refcolor, y):
;            return y
;    return -1
imgutil_find_row_mismatch(px, refc, y, t, xf:=0, xt:=-1) {
    while(y < px.height) {
        if !imgutil_row_uniform(px, refc, y, t, xf, xt)
            return y
        y := y + 1
    }
    return -1
}

;def find_row_mismatch_rev(img, px, refcolor, starty):
;    for y in range(starty, -1, -1):
;        if not row_uniform(img, px, refcolor, y):
;            return y
;    return -1
imgutil_find_row_mismatch_rev(px, refc, y, t, xf:=0, xt:=-1) {
    while(y >= 0) {
        if !imgutil_row_uniform(px, refc, y, t, xf, xt)
            return y
        y := y - 1
    }
    return -1
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_chop_mismatch_from_top(pic, refc, tolerance) {
    t := imgutil_find_row_match(pic, refc, 0, tolerance)
    h := pic.height - t
    if h <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, t, pic.width, h)
}

imgutil_chop_mismatch_from_bottom(pic, refc, tolerance) {
    b := imgutil_find_row_match_rev(pic, refc, pic.height-1, tolerance)
    if b <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, pic.width, b)
}

imgutil_chop_match_from_top(pic, refc, tolerance) {
    t := imgutil_find_row_mismatch(pic, refc, 0, tolerance)
    h := pic.height - t
    if h <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, t, pic.width, pic.height - t)
}

imgutil_chop_match_from_bottom(pic, refc, tolerance) {
    b := imgutil_find_row_mismatch_rev(pic, refc, pic.height-1, tolerance)
    if b <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, pic.width, b)
}

imgutil_chop_match_from_left(pic, refc, tolerance) {
    t := imgutil_find_column_mismatch(pic, refc, 0, tolerance)
    w := pic.width - t
    if w <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, t, 0, w, pic.height)
}

imgutil_chop_mismatch_from_left(pic, refc, tolerance) {
    t := imgutil_find_column_match(pic, refc, 0, tolerance)
    w := pic.width - t
    if w <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, t, 0, w, pic.height)
}

imgutil_chop_match_from_right(pic, refc, tolerance) {
    t := imgutil_find_column_mismatch_rev(pic, refc, pic.width - 1, tolerance)
    if t <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, t, pic.height)
}

imgutil_chop_mismatch_from_right(pic, refc, tolerance) {
    t := imgutil_find_column_match_rev(pic, refc, pic.width - 1, tolerance)
    if t <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, t, pic.height)
}

imgutil_chop_mismatch_then_match_left(pic, refc, tolerance) {
    t := imgutil_find_column_match(pic, refc, 0, tolerance)
    t := imgutil_find_column_mismatch(pic, refc, t, tolerance)
    w := pic.width - t
    if w <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, t, 0, w, pic.height)
}

imgutil_chop_mismatch_then_match_right(pic, refc, tolerance) {
    t := imgutil_find_column_match_rev(pic, refc, pic.width - 1, tolerance)
    t := imgutil_find_column_mismatch_rev(pic, refc, t, tolerance)
    if t <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, t, pic.height)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_grab_mismatch_from_top(pic, refc, tolerance) {
    b := imgutil_find_row_match(pic, refc, 0, tolerance)
    if b <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, pic.width, b)
}

imgutil_grab_mismatch_from_bottom(pic, refc, tolerance) {
    b := imgutil_find_row_match_rev(pic, refc, pic.height-1, tolerance)
    h := pic.height - b
    if h <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, b, pic.width, h)
}

imgutil_grab_mismatch_from_left(pic, refc, tolerance) {
    l := imgutil_find_column_match(pic, refc, 0, tolerance)
    if l <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, 0, 0, l, pic.height)
}

imgutil_grab_mismatch_from_right(pic, refc, tolerance) {
    r := imgutil_find_column_match_rev(pic, refc, pic.width-1, tolerance)
    w := pic.width - r
    if r <= 0
        Throw Error("Fail", -1)
    return imgutil_crop(pic, r, 0, pic.width-r, pic.height)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_crop(img, x, y, w, h) {
    new := img.crop(x, y, w, h)
    if img.HasOwnProp("origins")
        new.origins := [img.origins[1] + x, img.origins[2] + y]
    return new
}

imgutil_screengrab(x, y, w, h) {
    img := ImagePutBuffer([x, y, w, h])
    img.origins := [x, y]
    return img
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*imgutil_make_bw(pic, threshold := 100) {
    x := 0
    threshold := threshold * 3
    while (x < pic.width) {
        y := 0
        picptr := pic.ptr + x * 4
        stride := pic.width * 4
        black := 0xff000000
        white := 0xffffffff
        while (y < pic.height) {
            px := NumGet(picptr, "uint")
            r := (px & 0x00ff0000) >> 16
            g := (px & 0x0000ff00) >>  8
            b := (px & 0x000000ff)
            if (r + g + b) > threshold {
                NumPut("uint", white, picptr)
            } else {
                NumPut("uint", black, picptr)
            }
            y := y + 1
            picptr := picptr + stride
        }
        x := x + 1
    }
}*/

imgutil_make_bw(pic, threshold := 100) {
    return DllCall(i_imgutil_mcode_map["imgutil_make_bw"], 
        "ptr", pic.ptr, "uint", pic.width, "uint", pic.height, "char", threshold, "ptr")
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_mush_columns_mcode(pic, refc, tolerance, passes := 4) {
    ; generated with MCode Generator (bentschi)
    static b64 := ""
                . "QVdBVkFVQVRVV1ZTSIPsOIuEJKgAAACFwEiJjCSAAAAARYnLidFEi4wkoAAAAEWJxH41RInbiddEidjB"
                . "6xBBD6/4D7bED7bbRQ+2yUGJxUGJ2InFRAHLRSnIRCnNRQHNg/oBSGP/dRMxwEiDxDhbXl9dQVxBXUFe"
                . "QV/DSIuEJIAAAABBidJMi7QkgAAAAI1S/0nB4gJIY/KJ0kjB4gJIjQS4SAH3SMHmAkiJRCQYSIuEJIAA"
                . "AABJjTy+SIl8JChIifdJjXQ2/EwB90gp1jHSSIl8JCBMAdCFyUmJ9w+EXwEAAEUPtttIY8mJVCQUQ408"
                . "GUWJ3kjB4QJFKc6JfCQQTItcJBhMifox9kmJx0iLvCSAAAAARIl0JAgPH4AAAAAATDnfSYn+D4NPAQAA"
                . "SYn5iXQkBOs1Dx8AOdh/PonwD7bEOeh8NUQ56H8wi0QkCEAPtvY5xnwki0QkEDnGfxxJAclNOdkPgw0B"
                . "AABBizGJ8MHoEA+2wEQ5wH2+vgEAAABIg8cESYPDBEw5/3WUSIt0JCBMifhFMdtJiddMi0wkKESLdCQI"
                . "SIlMJAgPH4AAAAAATDnOSIn3D4OxAAAASInyRIlcJATrN2YuDx+EAAAAAAA5y3w6RInZD7bNOc1/MEE5"
                . "zXwrRQ+220U583wii0wkEEE5y38ZTAHSTDnKc2tEixpEidnB6RAPtslBOch+wkG7AQAAAEiD7gRJg+kE"
                . "TDn+dY+DRCQUAYt8JBQ5vCSoAAAASItMJAgPhcP+///pJ/7//4PCATmUJKgAAAAPhBf+//+DwgE5lCSo"
                . "AAAAdeTpBv7//2YPH0QAAESLXCQERYXbdTdFMdvrnYt0JASF9nUHMfbp+f7//0WF5HT0McAPHwBFi078"
                . "g8ABRYkOTQHWRDngde4x9unW/v//RYXkdMQx0otPBIPCAYkPTAHXRDnidfDrsA=="
    static code := b64code(b64)
    return DllCall(code, "ptr", pic.ptr, "uint", pic.width, "uint", pic.height, 
        "uint", refc, "char", tolerance, "int", passes, "uint")
}

imgutil_mush_columns(zcp, zcb, tol, passes := 4) {
    j := 0
    while (j < passes) {
        x := 0
        prevdirty := 0
        while x < zcp.width {
            if !imgutil_column_uniform(zcp, zcb, x, tol) {
                prevdirty := 1
            } else if (prevdirty) {
                i := 0
                while (i < zcp.height ) {
                    zcp[x, i] := zcp[x-1, i]
                    i++
                }
                prevdirty := 0
            }
            x++
        }
        x := zcp.width - 1
        prevdirty := 0
        while x >= 0 {
            if !imgutil_column_uniform(zcp, zcb, x, tol) {
                prevdirty := 1
            } else if (prevdirty) {
                i := 0
                while (i < zcp.height ) {
                    zcp[x, i] := zcp[x+1, i]
                    i++
                }
                prevdirty := 0
            }
            x--
        }
        j++
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
b64code(b64) {
    s64 := StrLen(RTrim(b64, "=")) * 3 // 4
    code := DllCall("GlobalAlloc", "uint", 0, "uptr", s64, "ptr")
    DllCall("crypt32\CryptStringToBinary", "str", b64, "uint", 0, "uint", 0x1, "ptr", code, "uint*", s64, "ptr", 0, "ptr", 0)
    DllCall("VirtualProtect", "ptr", code, "ptr", s64, "uint", 0x40, "uint*", 0)
    return code
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_imgsrch2(&fx, &fy, x, y, w, h, img) {
    return ImageSearch(&fx, &fy, x, y, x+w, y+h, "*4 " img)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
i_imgutil_imgsrch_make_sat_masks(&pic, t) {
    static b64 := ""
    . "" ; imgutil_make_sat_masks_v4.c
    . "" ; 608 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "" ; 0x000000: imgutil_make_sat_masks_v4
    . "QVRVV1ZTRA+2VCRQQWnCAAEBAEQJ0A0AAAD/YvJ9SHzQg/oPfl9EjVrwYvH9SG/KMcBFidpBweo"
    . "EQY1SAUjB4gYPH4AAAAAAYvF/SG8cAWLxZUjYwWLR/kh/BABi8XVI3MNi0f5IfwQBSIPAQEg5wn"
    . "XWSAHRSQHRSQHQQcHiBESJ2kQp0oP6A35zxfpvIUSNUvzF2djKxMF6fwjF6dzMxMF6fwlBg/oDf"
    . "jfF+m9pEMXR2MrEwXp/SBDF6dzNxMF6f0kQg/oLfhnF+m9pIMXR2MrF6dzFxMF6f0ggxMF6f0Eg"
    . "RInSweoCjUIB99pIweAEQY0UkkgBwUkBwUkBwMTjeRTQAIXSD45IAQAARA+2WQJFMdJBxkADAEH"
    . "GQQP/RInbKMNBD0LaQQDDQBj2RAneRA+2WQFBidxFiGACRInbQYhxAijDQQ9C2kEAw4ndGNtECd"
    . "tED7YZQYhoAUGIWQFEid9AKMdBD0L6QQDDGNtBCdtBiDhFiBmD+gEPhNQAAABED7ZZBkHGQAcAQ"
    . "cZBB/9Eidsow0EPQtpBAMNAGPZECd5ED7ZZBUGJ3EWIYAZEidtBiHEGKMNBD0LaQQDDid0Y20QJ"
    . "20QPtlkEQYhoBUGIWQVEid9AKMdBD0L6QQDDGNtBCdtBiHgERYhZBIP6AnRkD7ZRCkHGQAsAQcZ"
    . "BC/9BidNBKMNEid9BD0L6AMIY2wnTD7ZRCUGIeApBiFkKQYnTQSjDRIneQQ9C8gDCRRjbQQnTD7"
    . "ZRCEGIcAlFiFkJidEowUEPQsoA0BjSCdBBiEgIQYhBCDHAxfh3W15fXUFcw5A="
                                        
    static code := b64code(b64)
    pic.imgutil_mask_lo := Buffer(pic.width * pic.height * 4)
    pic.imgutil_mask_hi := Buffer(pic.width * pic.height * 4)
    DllCall(code, "ptr", pic.ptr, "uint", pic.width * pic.height, "ptr", pic.imgutil_mask_lo.ptr, "ptr", pic.imgutil_mask_hi.ptr, "char", t, "int")
    return
}

imgutil_imgsrch(&fx, &fy,                       ; output coordinates if image found
                haystack,                       ; ImagePutBuffer or anything acceptef by ImagePut
                needle,                         ; ImagePutBuffer or anything accepted by ImagePut
                tolerance := 0,                 ; pixels that differ by this much still match
                min_percent_match := 100,       ; percentage of pixels needed to return a match
                force_topleft_pixel_match := 1) ; top left pixel must match? (tolerance applies)
{
    static b64 := ""
    . "" ; imgutil_imgsrch_v4.c
    . "" ; 1984 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "" ; 0x000000: imgutil_imgsrch_v4
    . "QVdBVkFVQVRVV1ZTSIPsWMX4EXQkMMX4EXwkQESLpCTIAAAARIuUJNAAAAAPvoQk2AAAAEWJ5kU"
    . "Pr/JMiYwkuAAAAEiLnCS4AAAAQQ+vxkxjyMH4H01pyR+F61FJwfklRYnLRA+2SwFBKcNIi4QkuA"
    . "AAAEHB4QgPtkACweAQRAnIRA+2C0iLnCTAAAAARAnIRA+2SwFi8n1IfOBIi4QkwAAAAEHB4QgPt"
    . "kACweAQRAnIRA+2C0QJyA0AAAD/YvJ9SHzoRSnQD4i5AAAASGPSSWPExON5FO0ARInbSYnVxfmS"
    . "zUSJ9cX5b9VJKcVi4f0ob8xi4f0ob8VIjQSVAAAAAEiJykGNTCTwScHlAkiJRCQoicjB6AREjVA"
    . "BweAEKcFJweIGxON5FOAAQYnPMcnF+ZLQTYnuSYnRSQHWcjhEi5wk4AAAAEWF2w+FEwQAAEyLXC"
    . "QoSInQ6wsPH4QAAAAAAEyJyE2FyQ+FQwYAAE6NDBhNOc5z60iLRCQog8EBSAHCQTnIfa1FMcDpr"
    . "gUAAA8fAEGD+wMPjtYFAADF+m8AYrF9CN70xcl08MXp3sDF+XTCxfnbxsX5dsfF+dfwhfYPhfQA"
    . "AABBjXP8g/4DD46NBQAAxfpvQBBisX0I3vTFyXTwxenewMX5dMLF+dvGxfl2x8X51/CF9g+FvAA"
    . "AAEGNc/iD/gMPjl4FAADF+m9wIGKxTQjexMXJdMDF6d72xcl08sX528bFwXbAxfnX8IX2D4WEAA"
    . "AASIPAMEGNc/Ri430IFM8CxfmRVCQcYuN9CBRMJAwBxfmRTCQQYuN9CBREJBgBYuN9CBREJAgCR"
    . "A+2WAJBOPsPgqADAABEOFwkCA+ClQMAAEQPtlgBRDpcJAwPgoUDAABEOFwkGA+CegMAAEQPthhE"
    . "OlwkHA+CawMAAEQ4XCQQD4JgAwAAiUwkHEyJyGLzdUglyf9BielMiXQkEMXhdttIicVIiVQkIES"
    . "JRCQYQYnYRInHRTnBD4wwAgAARIlMJAhIiehFic5Ii4wkwAAAAESJRCQMSIuUJLgAAABmkEUxyU"
    . "UxwEGD/A8PjtACAABisX9IbzwIYrNFSD4cCgVis0VLPhwJAkmDwUBi8n5IKMNi831IH+EAxXiT3"
    . "PNFD7jbRQHYTTnKdcdNY89MAdJMAdFMAdBBg/kDD46RAgAAxfpvAMX53jpBjXH8xcF0+MX53gHF"
    . "+XQBxfnbx8X5dsPF+dfY8w+428H7AoP+A35qxfpvQBDF+d56EMXBdPjF+d5BEMX5dEEQxfnbx8X"
    . "5dsPFedfY80UPuNtBwfsCRAHbQYP5C340xfpvcCDF+m95IMXJ3kIgxcHe/sXJdMDFwXRxIMX528"
    . "bF+XbDxXnXyPNFD7jJQcH5AkQBy0GJ84PmA0HB6wJMY85Bg8MBScHjBEwB2kwB2UwB2EWFyQ+O4"
    . "AEAAEQPtlgCRDhZAg+CoQEAAEQ6WgIPgpcBAABED7ZYAUQ6WgEPgogBAABEOFkBD4J+AQAARA+2"
    . "GEQ4GUAPk8ZEOhpBD5PDRQ+220Eh80GD+QF0bw+2cAZAOnIGci1AOHEGcicPtnAFQDhxBXIdQDp"
    . "yBXIXD7ZwBEA6cgRyDUA4cQRBg9v/Dx9EAABBg/kCdDIPtnAKQDpyCnIoQDhxCnIiD7ZwCUA6cg"
    . "lyGEA4cQlyEg+2cAhAOnIIcghAOHEIQYPb/0nB4QJMAcpMAclMAchEKcdFKeZMAegp30Qp30Q59"
    . "w+O/P3//0SLTCQIRItEJAyF/w+OEgIAAEyLdCQQSIPFBEk57g+C0AEAAIuEJOAAAACFwA+Em/3/"
    . "/0iJ6ESJw4tMJBxEi0QkGEiLVCQgRInNSYnBYuH9SG/UYvH9SG/dYvN1SCXJ/2Lh/Qhv5MXBdv9"
    . "MifBMKchIwfgCg/gPQYnDTInIfx/p+Pv//w8fhAAAAAAAQYPrEEiDwEBBg/sPD47e+///YvF/SG"
    . "8wYrNNSD7aBWLzTUs+2wJi8n5IKMNi831IH8EAxfiYwHTH6dr8//9mkEUx2+mT/v//Dx+EAAAAA"
    . "ABNY8xBg/kDD49y/f//Dx8AMdtFhckPjyX+//8PH0QAAEUx2+nl/v//hfYPhLgAAABED7ZYBkE4"
    . "+3IxRDhcJAhyKkQPtlgFRDpcJAxyHkQ4XCQYchdED7ZYBEQ6XCQccgtEOFwkEA+DXfz//4P+AXR"
    . "4RA+2WApBOPtyMUQ4XCQIcipED7ZYCUQ6XCQMch5EOFwkGHIXRA+2WAhEOlwkHHILRDhcJBAPgx"
    . "38//+D/gJ0OEQPtlgORDhcJAhyLEE4+3InRA+2WA1EOFwkGHIbRDpcJAxyFA+2QAw4RCQQcgo6R"
    . "CQcD4Pg+///SItEJChJAcFNOc4Pg5X+//9Ii0QkKIPBAUgBwkE5yA+NNfr//+mD+v//Zg8fRAAA"
    . "i0wkHEiLVCQgRInDRInNSItEJChEi0QkGIPBAUgBwkE5yA+NAvr//+lQ+v//Dx8ASYnoxfh3xfg"
    . "QdCQwxfgQfCRATInASIPEWFteX11BXEFdQV5BX8NIg8AQ6dX6//9Ig8Ag6cz6//9FhdsPiF////"
    . "/E43kU5wJEid7E43kUZCQcAMTjeRRkJAwBxON5FGwkEADE43kUbCQYAcTjeRRsJAgC6bv6//9Ji"
    . "cHpAfv//5CQkJCQkJCQkA=="
               
    static code := b64code(b64)
    static cache := Map()

    if !isImagePutBuffer(haystack)
        haystack := ImagePutBuffer(haystack)
    if (!isImagePutBuffer(needle))
        needle := ImagePutBuffer(needle)

    ; this isn't meant to be a long-term thing; i thought sticking the 
    ; masks in the ImagePutBuffer object would be a good idea, since we
    ; *could* reuse them later, but what if the contents of the ImagePutBuffer
    ; object change, which would render the masks out of date?
    ; it's also very fast to initialize the masks compared to what happens
    ; later.
    ; but this member variable use needs to go away.
    i_imgutil_imgsrch_make_sat_masks(&needle, tolerance)

    result := DllCall(code, 
        "ptr", haystack.ptr, "int", haystack.width, "int", haystack.height,
        "ptr", needle.imgutil_mask_lo, "ptr", needle.imgutil_mask_hi, "int", needle.width, "int", needle.height,
        "char", min_percent_match, "int", force_topleft_pixel_match,
        "ptr")

    if result {
        offset := (result - haystack.ptr) // 4
        fx := mod(offset, haystack.width)
        fy := offset // haystack.width
    }
    return result

    isImagePutBuffer(x) {
        return Type(x) = "ImagePut.BitmapBuffer"
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_get_pixel_magnitude(px) {
    r := (px & 0x00FF0000) >> 16
    g := (px & 0x0000ff00) >>  8
    b := (px & 0x000000ff)
    return r + g + b
}