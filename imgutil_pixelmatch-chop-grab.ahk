    ;########################################################################################################
    ; column matching function
    ;########################################################################################################
    column_uniform(px, refc, x, yf := 0, yt := -1) {
        if yt = -1
            yt := px.height
        return DllCall(this.i_mcode_map["imgutil_column_uniform"]
            , "ptr", px.ptr, "int", px.width, "int", px.height
            , "int", refc
            , "int", x, "int", this.i_tolerance
            , "int", yf, "int", yt
            , "int"
        )
    }

    ;########################################################################################################
    ; row matching function
    ;########################################################################################################
    row_uniform(px, refc, y, xf := 0, xt := -1) {
        if xt = -1
            xt := px.width
        return DllCall(this.i_mcode_map["imgutil_row_uniform"]
            , "ptr", px.ptr, "int", px.width, "int", px.height
            , "int", refc
            , "int", y, "int", this.i_tolerance
            , "int", xf, "int", xt
            , "int"
        )
    }

    ;########################################################################################################
    ; column scanning functions
    ;########################################################################################################
    get_col_match(px, refc, x, yf:=0, yt:=-1, minimum_width := 1) {
        found_width := 0
        while(x < px.width) {
            if this.column_uniform(px, refc, x, yf, yt) {
                found_width++
                if (found_width >= minimum_width)
                    return x - found_width + 1
            } else {
                found_width := 0
            }
            x := x + 1
        }
        return -1
    }
    get_col_match_rev(px, refc, x, yf:=0, yt:=-1, minimum_width := 1) {
        found_width := 0
        while(x >= 0) {
            if this.column_uniform(px, refc, x, yf, yt) {
                found_width++
                if (found_width >= minimum_width)
                    return x - found_width + 1
            } else {
                found_width := 0
            }
            x := x - 1
        }
        return -1
    }
    get_col_mism(px, refc, x, yf:=0, yt:=-1) {
        if (yt = -1)
            yt := px.height
        while(x < px.width) {
            if !this.column_uniform(px, refc, x, yf, yt)
                return x
            x := x + 1
        }
        return -1
    }
    get_col_mism_rev(px, refc, x, yf:=0, yt:=-1) {
        while(x >= 0) {
            if !this.column_uniform(px, refc, x, yf, yt)
                return x
            x := x - 1
        }
        return -1
    }
    ;########################################################################################################
    ; row scanning functions
    ;########################################################################################################
    get_row_match(px, refc, y, xf:=0, xt:=-1) {
        while(y < px.height) {
            if this.row_uniform(px, refc, y, xf, xt)
                return y
            y := y + 1
        }
        return -1
    }
    get_row_match_rev(px, refc, y, xf:=0, xt:=-1) {
        while(y >= 0) {
            if this.row_uniform(px, refc, y, xf, xt)
                return y
            y := y - 1
        }
        return -1
    }
    get_row_mism(px, refc, y, xf:=0, xt:=-1) {
        while(y < px.height) {
            if !this.row_uniform(px, refc, y, xf, xt)
                return y
            y := y + 1
        }
        return -1
    }
    get_row_mism_rev(px, refc, y, xf:=0, xt:=-1) {
        while(y >= 0) {
            if !this.row_uniform(px, refc, y, xf, xt)
                return y
            y := y - 1
        }
        return -1
    }

    ;########################################################################################################
    ; crop-chop
    ;########################################################################################################
    chop_mism_t(pic, refc) {
        t := this.get_row_match(pic, refc, 0)
        if t <= 0
            return pic
        h := pic.height - t
        return this.crop(pic, 0, t, pic.width, h)
    }
    chop_mism_b(pic, refc) {
        b := this.get_row_match_rev(pic, refc, pic.height-1)
        if b <= 0
            return pic
        return this.crop(pic, 0, 0, pic.width, b)
    }
    chop_match_t(pic, refc) {
        t := this.get_row_mism(pic, refc, 0)
        if t <= 0
            return pic
        h := pic.height - t
        return this.crop(pic, 0, t, pic.width, pic.height - t)
    }
    chop_match_b(pic, refc) {
        b := this.get_row_mism_rev(pic, refc, pic.height-1)
        if b <= 0
            return pic
        return this.crop(pic, 0, 0, pic.width, b)
    }
    chop_match_l(pic, refc) {
        t := this.get_col_mism(pic, refc, 0)
        if t <= 0
            return pic
        w := pic.width - t
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_mism_l(pic, refc) {
        t := this.get_col_match(pic, refc, 0)
        if t <= 0
            return pic
        w := pic.width - t
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_match_r(pic, refc) {
        t := this.get_col_mism_rev(pic, refc, pic.width - 1)
        if t <= 0
            return pic
        return this.crop(pic, 0, 0, t, pic.height)
    }
    chop_mism_r(pic, refc) {
        t := this.get_col_match_rev(pic, refc, pic.width - 1)
        if t <= 0
            return pic
        return this.crop(pic, 0, 0, t, pic.height)
    }
    chop_mism_then_match_l(pic, refc, minimumGap := 1) {
        t := this.get_col_match(pic, refc, 0,,, minimumGap)
        if t <= 0
            return pic
        t := this.get_col_mism(pic, refc, t)
        if t <= 0
            return pic
        w := pic.width - t
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_mism_then_match_r(pic, refc, minimumGap := 1) {
        t := imgu.get_col_match_rev(pic, refc, pic.width - 1,,, minimumGap)
        if t <= 0
            return pic
        t := imgu.get_col_mism_rev(pic, refc, t)
        if t <= 0
            return pic
        return this.crop(pic, 0, 0, t, pic.height)
    }

    ;########################################################################################################
    ; crop-grab
    ;########################################################################################################
    grab_mism_t(pic, refc) {
        b := this.get_row_match(pic, refc, 0)
        if b <= 0
            return 0
        return this.crop(pic, 0, 0, pic.width, b)
    }
    
    grab_mism_b(pic, refc) {
        b := this.get_row_match_rev(pic, refc, pic.height-1)
        h := pic.height - b
        if h <= 0
            return 0
        return this.crop(pic, 0, b, pic.width, h)
    }
    
    grab_mism_l(pic, refc) {
        l := this.get_col_match(pic, refc, 0)
        if l <= 0
            return 0
        return this.crop(pic, 0, 0, l, pic.height)
    }
    
    grab_mism_r(pic, refc) {
        r := imgu.get_col_match_rev(pic, refc, pic.width-1)
        w := pic.width - r
        if r <= 0
            return 0
        return this.crop(pic, r, 0, pic.width-r, pic.height)
    }
    
