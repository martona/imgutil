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

; a global instance of the class. you should only ever need this one.
imgu := imgutil()

class imgutil {

    ; mcode function map for name -> address in memory
    i_mcode_map := this.i_get_mcode_map()

    ; determines the correct version of machine code blobs to use,
    ; decodes them from base64, and returns a map of function names
    ; to addresses in memory
    i_get_mcode_map() {
        ; determine the correct CPU level from cpuinfo
        psabi_level_expected := 0 ; this.i_get_psabi_level()

        ; get the correct machine code blob
        if (psabi_level_expected = 4) {
            cmap := this.i_get_mcode_map_v4()
        } else if (psabi_level_expected = 3) {
            cmap := this.i_get_mcode_map_v3()
        } else if (psabi_level_expected = 2) {
            cmap := this.i_get_mcode_map_v2()
        } else if (psabi_level_expected = 1) {
            cmap := this.i_get_mcode_map_v1()
        } else if (psabi_level_expected = 0) {
            cmap := this.i_get_mcode_map_v0()
        } else if (psabi_level_expected = -1) {
            cmap := this.i_get_mcode_map_vs()
        } else {
            throw("imgutil: unsupported psabi level: " . psabi_level_expected)
        }

        ; check that we got what we asked for
        psabi_level := DllCall(cmap["get_blob_psabi_level"], "int")
        if psabi_level != psabi_level_expected
            throw("imgutil: incompatible blob psabi level; expected " . psabi_level_expected . ", got " . psabi_level)
        return cmap
    }


    ; -march=core2 below baseline, mmx
    i_get_mcode_map_vs() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 4144 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=core2 -D MARCH_x86_64_vs -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyMH4HzHBKcExwEE5yA+dwMNmZi4PH4QAAAAAAJBTichBidHB6BBBwekQRQ+2yQ+2wEQpyEG"
        . "JwUHB+R9EMchEKchFMclBOcB8NQ+2xQ+23inYQYnCQcH6H0Qx0EQp0EE5wHwbD7bJD7bSRTHJKd"
        . "GJyMH4HzHBKcFBOchBD53BRInIW8NmLg8fhAAAAAAAVlNEi0QkQEiJy4tMJFBEichFictMY0wkO"
        . "A+29MHoEEGJ8g+vykhjyUwByUiNNIuLTCRID6/KSGPJTAHJSI0Mi0g58Q+DpwAAAIP6AUQPtsh1"
        . "Rg+2QQJEKciZMdAp0EE5wHwtD7ZBAUEPttIp0Jkx0CnQQTnAfBkPtgFBD7bTKdCZMdAp0EE5wH1"
        . "2Zg8fRAAAMcBbXsMPHwAPtkECRCnIicPB+x8x2CnYQTnAfOMPtkEBQQ+22inYicPB+x8x2CnYQT"
        . "nAfMsPtgFBD7bbKdiJw8H7HzHYKdhBOcB8tEhjwkiNDIFIOfFysA8fhAAAAAAAuAEAAADrm2YPH"
        . "4QAAAAAAEiDwQRIOfEPgkX////r4ZBTD69UJDBEi0QkOEhj0kSJyEWJy0xjTCRID7bcwegQQYna"
        . "SQHRSo0ciUxjTCRATAHKSI0UkUg52nNRRA+2yA+2QgJEKciJwcH5HzHIKchBOcB8RQ+2QgFBD7b"
        . "KKciJwcH5HzHIKchBOcB8LQ+2AkEPtsspyInBwfkfMcgpyEE5wHwWSIPCBEg52nKzuAEAAABbw2"
        . "YPH0QAADHAW8MPH0AAVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAcZBA/9ED"
        . "7ZBAkUB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAQVdB"
        . "VkFVQVRVV1ZTSIHsuAIAAA8RtCQQAgAADxG8JCACAABEDxGEJDACAABEDxGMJEACAABEDxGUJFA"
        . "CAABEDxGcJGACAABEDxGkJHACAABEDxGsJIACAABEDxG0JJACAABEDxG8JKACAAAPtoQkIAMAAE"
        . "Rp4AABAQCJ10EJxEGBzAAAAP9EieBFieZEieZBwe4QD7bEhdJBicJFifMPjgwIAACD+hAPjnYHA"
        . "ABFD7bkRQ+29kUPturzRA9vPT4MAABMieBMifPzRA9vNX8MAABmD+//SMHgCEjB4wjzRA9vLXoM"
        . "AABmRQ92241q/0wJ8EwJ6/NED28lcwwAAEjB4AhIweMITInqTAnjTAnoSMHiCEjB4AhIweMITAn"
        . "iTAngTAnzSMHiCEjB4AhIweMITAnyTAnwTAnrSMHgCEjB4whMCeNMCehIweAISMHjCEwJ4EwJ80"
        . "jB4AhIweMITAnwTAnrSMHiCEwJ6kiJBCRIweIISIlcJAhMCeJIiVwkEEiJy0jB4ghIiUQkKEyJy"
        . "EwJ8kjB4ghMCepIweIITAniQYnsQcHsBEiJVCQYScHkBkiJVCQgTInCSQHMDx+AAAAAAPMPbzPG"
        . "QgMASIPDQEiDwkDzD29T0MZCxwBIg8BA8w9va+DGQssAZg84ADWxCgAAZg9vwvMPb2QkIMZCzwB"
        . "mDzgAFboKAABmDzgABaEKAABmD+vwZg9vxWYPOAAtwAoAAGYP/ObzD29cJBBmRA9v1mYPOAAFmA"
        . "oAAGYP69DzD29D8GZED/hUJCBmRA9vymYP/NrzD28MJGZED/hMJBDGQtMAZg84AAWGCgAAZg/r6"
        . "GYPb8bGQtcAZg/YxGYP/M3GQtsAZkQPb8VmD3THZkQP+AQkxkLfAMZC4wDGQucAZg/b4GZBD9/D"
        . "Zg/rxGYPb+JmD9jjxkLrAGYPdOfGQu8AxkLzAMZC9wBmD9vcZkEP3+NmD+vjZg9v3WYP2NnGQvs"
        . "AZg9038ZC/wBmD9vLZkEP39tmD+vZZkEPb8pmD9jOZkEPb/FmD3TPZg/Y8mZBD2/QZg/Y1WYPdP"
        . "dmD3TXZkEP28pmRA/F6QBmRIlqwGYPb+kPEYwkAAIAAGZBDzgA72ZBD9vxRA+2rCQCAgAAZkEP2"
        . "9BEiGrCZkQPxe0AZg9v6WYPOAAtqQkAAGZEiWrEDxGMJPABAABED7asJPUBAABEiGrGZkQPxekD"
        . "ZkSJasgPEYwk4AEAAEQPtqwk6AEAAESIaspmRA/F7QBmD2/uZg84AC18CQAAZkSJaswPEYwk0AE"
        . "AAEQPtqwk2wEAAESIas5mRA/F6QZmRIlq0A8RjCTAAQAARA+2rCTOAQAAZg84AA0tCQAAZg/rzU"
        . "SIatJmRA/F6QBmD2/OZg84AA0yCQAAZkSJatQPEbQksAEAAEQPtqwksQEAAESIatZmRA/F7gFmR"
        . "Ilq2A8RtCSgAQAARA+2rCSkAQAARIhq2mZED8XpAGYPb85mRIlq3GZBDzgAzg8RtCSQAQAARA+2"
        . "rCSXAQAARIhq3mZED8XuBGZEiWrgDxG0JIABAABED7asJIoBAABEiGriZkQPxekAZg9vymZEiWr"
        . "kZkEPOADNDxG0JHABAABED7asJH0BAABEiGrmZkQPxe4HZkSJauhmQQ9+1USIaupmRA/F6QBmD2"
        . "/KZkSJauxmQQ84AMwPEZQkYAEAAEQPtqwkYwEAAESIau5mRA/F6gJmRIlq8A8RlCRQAQAARA+2r"
        . "CRWAQAARIhq8mZED8XpAGYPb8pmDzgADVMIAABmRIlq9A8RlCRAAQAARA+2rCRJAQAARIhq9mZE"
        . "D8XqBWZEiWr4DxGUJDABAABED7asJDwBAABEiGr6ZkQPxekAZg9vyGZEiWr8ZkEPOADPDxGUJCA"
        . "BAABED7asJC8BAABEiGr+ZkQPxegAxkDD/8ZAx//GQMv/xkDP/8ZA0//GQNf/xkDb/8ZA3//GQO"
        . "P/xkDn/8ZA6//GQO//xkDz/8ZA9//GQPv/xkD//2ZEiWjADxGEJBABAABED7asJBIBAABEiGjCZ"
        . "kQPxekAZg9vyGYPOAANDAcAAGZEiWjEDxGEJAABAABED7asJAUBAABEiGjGZkQPxegDZkSJaMgP"
        . "EYQk8AAAAEQPtqwk+AAAAESIaMpmRA/F6QBmD2/MZkSJaMwPEYQk4AAAAEQPtqwk6wAAAESIaM5"
        . "mRA/F6AZmDzgADb8GAABmRIlo0A8RhCTQAAAARA+2rCTeAAAAZg84AAWQBgAAZg/rwUSIaNJmRA"
        . "/F6ABmD2/EZg84AAWVBgAAZkSJaNQPEaQkwAAAAEQPtqwkwQAAAESIaNZmRA/F7AFmRIlo2A8Rp"
        . "CSwAAAARA+2rCS0AAAARIho2mZED8XoAGYPb8RmRIlo3GZBDzgAxg8RpCSgAAAARA+2rCSnAAAA"
        . "RIho3mZED8XsBGZEiWjgDxGkJJAAAABED7asJJoAAABEiGjiZkQPxegAZg9vw2ZEiWjkZkEPOAD"
        . "FDxGkJIAAAABED7asJI0AAABEiGjmZkQPxewHZkSJaOhmQQ9+3USIaOpmRA/F6ABmD2/DZkSJaO"
        . "xmQQ84AMQPEVwkcEQPtmwkc0SIaO5mRA/F6wJmRIlo8A8RXCRgRA+2bCRmRIho8mZED8XoAGYPb"
        . "8NmDzgABcIFAABmRIlo9A8RXCRQRA+2bCRZRIho9mZED8XrBWZEiWj4DxFcJEBED7ZsJExEiGj6"
        . "ZkQPxegAZkSJaPwPEVwkMEQPtmwkP0SIaP5MOeMPhbH5//+D5fCJ6CnvSMHgAkgBwUkBwEkBwY1"
        . "H/zHSTY10gQQPHwAPtkECQcZBA/9BxkADAInFRCjdD0LqRADYRRjkQQnED7ZBAUGIaAJFiGECQY"
        . "nFRSjVRA9C6kQA0EAY/zHbCccPtgFBiHkBiAQkQCjwQYnHRInoRA9C+kSI+4jHD7YEJGZBiRhAA"
        . "PBAGP9Jg8EESIPBBAn4SYPABEGIQfxNOc51gA8QtCQQAgAAMcAPELwkIAIAAEQPEIQkMAIAAEQP"
        . "EIwkQAIAAEQPEJQkUAIAAEQPEJwkYAIAAEQPEKQkcAIAAEQPEKwkgAIAAEQPELQkkAIAAEQPELw"
        . "koAIAAEiBxLgCAABbXl9dQVxBXUFeQV/DZpBBV0FWQVVBVFVXVlNIg+xYRIukJMgAAABEi5wk2A"
        . "AAAEiLnCTAAAAATImMJLgAAABFiedMY9JEicdEi4wk0AAAAEEPvsNFD6/5QQ+vx0hj0MH4H0hp0"
        . "h+F61FIwfolKcJBgPtkuAEAAABED7ZbAQ9FhCTgAAAAQYnWiUQkMEiLhCS4AAAAQcHjCA+2UAIP"
        . "tkABweIQweAICcJIi4QkuAAAAA+2AAnCSIuEJMAAAAAPtkACweAQRAnYRA+2G0QJ2A0AAAD/RCn"
        . "PD4heAgAATYnQTWPMQYnTiXwkTEqNHJUAAAAATSnIMfZEiXwkFEiJXCQgSInLQYnCifdBjUwk/0"
        . "SJdCQQSIneSI0sjQQAAAAPts7B6hBOjSyFAAAAAIlMJDSJ0Q+21IlUJDjB6BBMiWwkCEiLXCQIS"
        . "YnwSAHzD4LUAQAAi1QkMIXSD4VUAQAASInySIXSdRlIi1QkIEwBwkg50w+CrwEAAEiF0kmJ0HTn"
        . "RIhcJEpMicJFidNBicFIiVwkKIl8JDxIiXQkQIhMJEuLXCQQOVwkFEGJ2A+MvgAAAESLVCQUSIn"
        . "QSIlUJBhEidtIi7wkwAAAAEiLtCS4AAAARTH/RYXkSYnFfnRMjSwoSIn6SInxSIk8JEUx/w8fQA"
        . "APtnoCSIPABEiDwQRIg8IERA+2WP5ED7Zx/kQ433IxRTjzcixED7ZY/UQ4Wv1yIUQ6Wf1yG0QPt"
        . "lj8RDha/HIQRDpZ/EGD3/8PH4QAAAAAAEk5xXWrSIs8JEgB7kgB70iLRCQIRSn4RSniTAHoRTnQ"
        . "D45q////SItUJBhBidtFhcAPjuUAAABIi1wkKEiDwgRIOdMPgrcAAACLRCQwhcAPhAr///9Fidq"
        . "LfCQ8SYnQRInISIt0JEAPtkwkS0QPtlwkSkiJ2kSLfCQ0TCnCRIt0JDhIwfoChdJ4T4nSTY1skA"
        . "RMicIPH0AARA+2SgJEOMhyLkE4yXIpRA+2SgFFOM5yH0U4+XIaRA+2CkU4ynIRRTjZD4N3/v//D"
        . "x+EAAAAAABIg8IESTnVdb9Ii1QkIEkB0Ew5w3OMSItcJCCDxwFIAd45fCRMD40G/v//RTHJ6x9F"
        . "idqLfCQ8RInISIt0JEAPtkwkS0QPtlwkSuvKSYnRTInISIPEWFteX11BXEFdQV5BX8NmZi4PH4Q"
        . "AAAAAAGaQuP/////DZi4PH4QAAAAAAAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQ"
        . "YICQoMDQ6AgICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICAgICAgAABAgQFB"
        . "ggJCgwNDgMEAgMEBQYHCAkKCwwNDg8JCgIDBAUGBwgJCgsMDQ4PD4CAgICAgICAgICAgICAgIAA"
        . "AgMEBQYHCAkKCwwNDg8FBgIDBAUGBwgJCgsMDQ4PCwwCAwQFBgcICQoLDA0ODwECAgMEBQYHCAk"
        . "KCwwNDg8HCAIDBAUGBwgJCgsMDQ4PDQ4CAwQFBgcICQoLDA0ODw=="
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000090: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x000bc0: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x000f30: get_blob_psabi_level  : u32 get_blob_psabi_level()
                static code := this.i_b64decode(b64)
        cmap := Map(  "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000090
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_make_sat_masks",    code + 0x0002a0
                    , "imgutil_imgsrch",           code + 0x000bc0
                    , "get_blob_psabi_level",      code + 0x000f30
                    )
        return cmap
    }
        

    ; -march=core2 below baseline, (mmx)
    i_get_mcode_map_v0() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 4032 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyMH4HzHBKcExwEE5yA+dwMNmZi4PH4QAAAAAAJBTichBidHB6BBBwekQRQ+2yQ+2wEQpyEG"
        . "JwUHB+R9EMchEKchFMclBOcB8NQ+2xQ+23inYQYnCQcH6H0Qx0EQp0EE5wHwbD7bJD7bSRTHJKd"
        . "GJyMH4HzHBKcFBOchBD53BRInIW8NmLg8fhAAAAAAAVlNEi0QkQEiJy4tMJFBEichFictMY0wkO"
        . "A+29MHoEEGJ8g+vykhjyUwByUiNNIuLTCRID6/KSGPJTAHJSI0Mi0g58Q+DpwAAAIP6AUQPtsh1"
        . "Rg+2QQJEKciZMdAp0EE5wHwtD7ZBAUEPttIp0Jkx0CnQQTnAfBkPtgFBD7bTKdCZMdAp0EE5wH1"
        . "2Zg8fRAAAMcBbXsMPHwAPtkECRCnIicPB+x8x2CnYQTnAfOMPtkEBQQ+22inYicPB+x8x2CnYQT"
        . "nAfMsPtgFBD7bbKdiJw8H7HzHYKdhBOcB8tEhjwkiNDIFIOfFysA8fhAAAAAAAuAEAAADrm2YPH"
        . "4QAAAAAAEiDwQRIOfEPgkX////r4ZBTD69UJDBEi0QkOEhj0kSJyEWJy0xjTCRID7bcwegQQYna"
        . "SQHRSo0ciUxjTCRATAHKSI0UkUg52nNRRA+2yA+2QgJEKciJwcH5HzHIKchBOcB8RQ+2QgFBD7b"
        . "KKciJwcH5HzHIKchBOcB8LQ+2AkEPtsspyInBwfkfMcgpyEE5wHwWSIPCBEg52nKzuAEAAABbw2"
        . "YPH0QAADHAW8MPH0AAVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAcZBA/9ED"
        . "7ZBAkUB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAQVZV"
        . "V1ZTi0QkUEQPttgPtsBJicqJ0WnQAAEBAEwJ2kjB4iBMCdpBicPB4AhBweMQSJhNY9tMCdpICcJ"
        . "IuAAAAP8AAAD/SAnCg/kBflKNWf5mSA9uyjHAQYnbQdHrQY1LAUjB4QMPHwDzQQ9+BAJmD2/QZg"
        . "/cwWYP2NFmQQ/WBAFmQQ/WFABIg8AISDnBddlB99tJAcpJAclJAchCjQxbD3dIidBBidMPtt5Iw"
        . "egQg/kBdWdBD7ZSAjH2QcZAAwBBxkED/4nRKMEPQs4A0EAY/wnHQQ+2QgFBiEgCQYh5AonFQCjd"
        . "D0LuAMNBD7YCGNIJ2jHbQYnWiepBicJFiHEBRSjaRA9C1kEAwxjARIjTRAnYiNdBiAFmQYkYMcB"
        . "bXl9dQV7DZmYuDx+EAAAAAABmkEFXQVZBVUFUVVdWU0iB7BgBAAAPEXQkcA8RvCSAAAAARA8RhC"
        . "SQAAAARA8RjCSgAAAARA8RlCSwAAAARA8RnCTAAAAARA8RpCTQAAAARA8RrCTgAAAARA8RtCTwA"
        . "AAARA8RvCQAAQAARIusJIgBAACLtCSYAQAASIusJIABAABIicuLjCSQAQAARYnsTImMJHgBAABA"
        . "D77GD7Z9AkQPr+FBD6/ETGPIwfgfTWnJH4XrUUnB+SVFicpBKcJAgP5kuAEAAABIi7QkeAEAAA9"
        . "FhCSgAQAAwecQQYnBSIuEJHgBAAAPtnYBD7ZAAsHmCMHgEAnwSIu0JHgBAABImA+2NkgJ8EiJxk"
        . "jB5iBIAfAPtnUBD7ZtAEiJRCQIifhIY//B5ggJ8Ehj9kgJ6EjB4CBICehICfhICfBIvgAAAP8AA"
        . "AD/SAnwRInGKc5IiUQkOA+ISgkAAEhj0k1jxWYP78lmD2/ZSInQRIlkJCxmDzgAHW4KAABMKcBJ"
        . "idhmD9YcJEyNHIUAAAAASI0ElQAAAABMiVwkYEGNVf9IiUQkQEqNBBtEietIiUQkIInQwegESMH"
        . "gBkiJRCQYidCD4PBMjTyFAAAAACnDiUQkKInQTI00hQQAAAAxwIlcJBRMif9BicOJ0InyTIn2TI"
        . "t0JAhMOUQkIEyJRCQI80QPbz2zCQAAD4KACAAAidNJif9EidpMi5wkeAEAAInH6ylIi0wkCEiDf"
        . "CQIAA+FUAkAAEiLRCRASAHISDlEJCBIiUQkCA+COQgAAEWFyXTS8w9+XCQ4ZkkPbuZmD+/S8w9+"
        . "LUwJAABIi0QkIEiLTCQISCnISMH4AoP4AYnFD466CAAASInI6xwPHwBIwekgg/n/dFKD7QJIg8A"
        . "Ig/0BD47/BgAA8w9+AGYPb8hmD2/wZg/YzGYPdPRmD3TKZg/rzmYPb/NmD9jwZg90w2YPdPJmD+"
        . "vwZg/bzmYPds1mSA9+yYP5/3WliVQkSEiLVCRgTIn4QYn/iVwkaEyJRCRQTIl0JFhEOVQkLEWJ1"
        . "A+MNQYAAEiLXCQITInfRIlUJDBEi3QkLEyJnCR4AQAA80QPfjWHCAAARIlMJDRmkDHJRYXtD47c"
        . "BQAAQYP/Dw+GOwYAAEyLVCQYSIn5SYnYZkUP7+1mRQ/v5E2NDDpmkPNFD29AEGZBD2/PZkEPb/d"
        . "mQQ9v//NBD28YZkUPb99Ig8FASYPAQPNBD29g4GZBD9vIZkEPcdAI80EPb0DwZkEP299mD2fZZk"
        . "EPb8/zD29RwGYP2/RmD3HUCPNED29R0GYP28hmD2fxZkEPb8/zD29p4GYP28pmD3HSCPNED29J8"
        . "GZBD9v6Zg9nz2ZBD2//Zg/b/WZBD3HSCGZFD9vZZg9x1QhmQQ9n0mZBD9vXZkEPcdEIZkEPZ/tm"
        . "QQ9n6WZED2/K80EPb1DAZg9x0AhmD2fgZg9vwWZBD9vnZkEP2+9mD3HSCGZED2fNZg9v7mZBD9v"
        . "PZkEPZ9BmQQ/b12YPZ9RmD2/nZg9x1AhmQQ/b92ZBD9rRZkEP2/9mD3HQCGYPZ89JOclmD2fEZg"
        . "9v42YPcdUIZkEP299mD3HUCGYPZ95mD9rZZg/v9mYPZ+VmD9rgZg90y2YPdMRmQQ900WYP29BmD"
        . "9vRZg/bFfQGAABmD2/CZg9gxmYPb8hmD2jWZkEPYcRmQQ9pzGYP/sFmD2/KZkEPYdRmQQ9pzGYP"
        . "/tFmD/7CZkQP/ugPhVX+//9Ei0QkKEyNDAdmQQ9vxWYPc9gIi2wkFEyNFANmQQ/+xWYPb8hmD3P"
        . "ZBGYP/sFBDxLNZg9+wWZBD2/FZkQPb+lmRA/+6EWJ+0Upw0GD+wcPhiUCAABJweACZkEPb95mQQ"
        . "9vxkqNDANmQQ9v/kkB+PMPfglmQQ9v1mZBD2/2ZkUPb9bzRA9+YQhBg+P48w9+aRBmD9vZZg9x0"
        . "QhEKd3zRA9+WRhmQQ/bxGYPZ9hmQQ9vxvNFD35ICGYP2/1mQQ9x1AhmD3DbCGZBD9vDZg9n+PNB"
        . "D34AZg9x1QjzQQ9+YBBmQQ/b8WZBD2fMZkEPcdMI80UPfkAYZg/b0GYPZ9ZmQQ9v9mYP2/RmD3H"
        . "QCGYPcMkIZkEPZ+tmRQ/b0GZBD3HRCGYPcO0IZkEP285mD3HUCGZBD9vuZkEPZ8FmD2fNZkEPcd"
        . "AIZg9wyQhmD3DACGZBD9vGZkEPZ+BmD3DkCGZBD9vmZg9nxGYPcMAIZg/ayGYPb+NmD3D/CGYPd"
        . "MFmD2/PZg9w0ghmQQ9n8mYPcdEIZg9w9ghmD2/uZkEP2/5mD3HUCGZBD9veZkEP2/ZmD2ffZg9n"
        . "4WYPb8pmD3HVCGYPcOQIZg9x0QhmD3DbCGYP7/9JweMCZg9nzWZBD9vWZg9wyQhNAdlmD9rhZg9"
        . "n1mYPcNIIZg/a2mYPdMxmD+/tTQHaZg900/MPfh2qBAAAZg/bwWYP29BmD9vTZg9vwmYPYNVmD2"
        . "DFZg9w0k5mD2/YZg9vymYPYc9mD2HfZg9hx2YPYddmD3DATmYPcNJOZg/+w/MPfiwkZg/+0WYP/"
        . "sJmQQ/+xWYPb8hmDzgADVgEAABmD+vNZg/+wWYPfsFFD7ZZAUU4WgFFD7ZBAkEPk8NFOEICQQ+T"
        . "wEWEw3QKRQ+2GUU4GoPZ/4P9AQ+EWwEAAEUPtlkGRThaBkUPtkEFQQ+Tw0U4QgVBD5PARYTDdAx"
        . "FD7ZZBEU4WgSD2f+D/QIPhCcBAABFD7ZZCUU4WglFD7ZBCkEPk8NFOEIKQQ+TwEWEw3QMRQ+2WQ"
        . "hFOFoIg9n/g/0DD4TzAAAARQ+2WQ5FOFoORQ+2QQ1BD5PDRThCDUEPk8BFhMN0DEUPtlkMRThaD"
        . "IPZ/4P9BA+EvwAAAEUPtlkRRThaEUUPtkESQQ+Tw0U4QhJBD5PARYTDdAxFD7ZZEEU4WhCD2f+D"
        . "/QUPhIsAAABFD7ZZFUU4WhVFD7ZBFkEPk8NFOEIWQQ+TwEWEw3QMRQ+2WRRFOFoUg9n/g/0GdFt"
        . "FD7ZZGUU4WhlFD7ZBGkEPk8NFOEIaQQ+TwEWEw3QMRQ+2WRhFOFoYg9n/g/0HdCtFD7ZZHkU4Wh"
        . "5FD7ZBHUEPk8NFOEIdQQ+TwEWEw3QMRQ+2SRxFOEocg9n/SAH3SAHzQSnMRSnuSAHTRTn0D44H+"
        . "v//RItUJDBMi5wkeAEAAESLTCQ0RYXkD45iAQAASINEJAgESIt8JAhIOXwkIA+CugEAAEWFyQ+E"
        . "lfn//0SJ/4tUJEhJiceLXCRoTItEJFBMi3QkWOnF+P//SYnaSYn5RIntZkUP7+1FMcAxyem3+//"
        . "/TInxRIh0JGgPts1IiUwkUEyJ8UjB6RCITCQ0SItMJDhJicyITCRYD7bNSIlMJEhMieFIwekQiE"
        . "wkMA+2SAFED7ZgAkQ4ZCQwiEwkbg+2CIhMJG9yN0Q6ZCQ0cjAPtkwkbjhMJEhyJUQPtmQkUEQ44"
        . "XIaD7ZMJG84TCRYcg9ED7ZkJGhEOOEPg14BAACD/QF1Ng+2SAY4TCQwD7ZoBQ+2QARyJDpMJDRy"
        . "HkA4bCRIchdAOmwkUHIQOEQkWHIKOkQkaA+DfPj//0iLTCRASAFMJAhIi0QkCEg5RCQgD4Pj9//"
        . "/QYnTifiJ2kyJ/0iLXCRAQYPDAUgBXCQgSQHYQTnTD45N9///SMdEJAgAAAAASItEJAgPEHQkcA"
        . "8QvCSAAAAARA8QhCSQAAAARA8QjCSgAAAARA8QlCSwAAAARA8QnCTAAAAARA8QpCTQAAAARA8Qr"
        . "CTgAAAARA8QtCTwAAAARA8QvCQAAQAASIHEGAEAAFteX11BXEFdQV5BX8NIicdEi1wkSESJ+ItU"
        . "JGhMi0QkUEyLdCRY6VH///+FwA+IJf///0yJ8ESIdCRoD7bESIlEJFBMifBIwegQiEQkNEiLRCQ"
        . "4D7bMiEQkWEjB6BCIRCQwSItEJAhIiUwkSOla/v//SIlMJAjpWff//0iLTCQISIlEJAjpi/b//2"
        . "ZmLg8fhAAAAAAADx9AADHAww8fRAAA////////////AP8A/wD/AP8A/wD/AP8AAQEBAQEBAQEBA"
        . "QEBAQEBAQQFBgeAgICAgICAgICAgICAgICAAAECA4CAgICAgICA"
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000090: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x0003d0: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x000f70: get_blob_psabi_level  : u32 get_blob_psabi_level()
        static code := this.i_b64decode(b64)
        cmap := Map(  "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000090
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_make_sat_masks",    code + 0x0002a0
                    , "imgutil_imgsrch",           code + 0x0003d0
                    , "get_blob_psabi_level",      code + 0x000f70
                    )
        return cmap
    }

    ; -march=x86-64 baseline optimized machine code blob (mmx huh)
    i_get_mcode_map_v1() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 4416 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTichBidHB6BBBwekQRQ+2yQ+2wEQpyEG"
        . "JwUH32UEPScFFMclBOcB8MA+2xQ+23inYQYnCQffaQQ9JwkE5wHwZD7bJD7bSKdGJyPfYD0jBRT"
        . "HJQTnAQQ+dwUSJyFvDZpBWU0hjdCQ4SYnIi0wkUESJyESLTCRAD7bcQYnDwegQD6/KQYnaSGPJS"
        . "AHxSY0ciItMJEgPr8pIY8lIAfFJjQyISDnZD4O3AAAAD7bAg/oBdVcPtlECKcJBidBB99hBD0nQ"
        . "QTnRfDoPtlEBRQ+2wkQpwkGJ0EH32EEPSdBBOdF8IA+2EUUPtsNEKcJBidBB99hBD0nQQTnRfXc"
        . "PH4AAAAAAMcBbXsMPHwBED7ZBAkEpwESJxvfeRA9JxkU5wXziRA+2QQFBD7byQSnwRInG995ED0"
        . "nGRTnBfMhED7YBQQ+280Ep8ESJxvfeRA9JxkU5wXyvTGPCSo0MgUg52XKrDx8AuAEAAADrm2YPH"
        . "4QAAAAAAEiDwQRIOdkPgjT////r4ZBTD69UJDBMY0QkSEhj0kSJyEkB0ESLTCQ4D7bcQYnDwegQ"
        . "QYnaSo0cgUxjRCRATAHCTI0EkUk52HNMD7bAQQ+2UAIpwonR99kPSdFBOdF8QEEPtlABQQ+2yin"
        . "KidH32Q9J0UE50XwpQQ+2EEEPtsspyonR99kPSdFBOdF8E0mDwARJOdhyt7gBAAAAW8MPHwAxwF"
        . "vDZmYuDx+EAAAAAACQVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAQVdB"
        . "VkFVQVRVV1ZTSIHs+AUAAA8RtCRgBQAADxG8JHAFAABEDxGEJIAFAABEDxGMJJAFAABEDxGUJKA"
        . "FAABEDxGcJLAFAABEDxGkJMAFAABEDxGsJNAFAABEDxG0JOAFAACJ1Q+2lCRgBgAASImMJEAGAA"
        . "BpwgABAQAJ0A0AAAD/D7bUicZBidKJwsHqEEGJ04XtD44TCgAAg/0QD45mCQAARI1t/2ZED27SZ"
        . "kQPbsBJic9mRQ9u2mZFD2DSSY1QA0WJ7GZFD2DbZkUPYMBBwewEZkUPYdJmRQ9h20nB5AZmRQ9h"
        . "wPMPbzWTDQAA80QPbw2aDQAAZkUPcNIAZkUPcNsASQHMZkUPcMAASY1BA2YP7/9mRQ925A8fhAA"
        . "AAAAA80EPbw/zQQ9vRxAx/8YCAGYPb97GQgQASYPHQEiDwkBmD9vGZg/bzmZFD2/x80EPb1fwZg"
        . "9nyPNBD29H4PNBD29n8MZCyABmD9vWxkLMAGYP28ZmD3HUCMZC0ABmD2fCZg9v1sZC1ABmD9vYZ"
        . "g/b0cZC2ABmD3HQCGYPcdEIZg9n08ZC3ADzQQ9vX9BmD2fI80EPb0fAxkLgAGZED2/qxkLkAGYP"
        . "cdMIZg9x0AhmRQ/46MZC6ABmD2fD80EPb1/gxkLsAGYP28bGQvAAZg9x0wjGQvQAZg9n3GYPb+H"
        . "GQvgAZkEP+OJmD9vexkL8AGYPZ8NmD2/cZg/Y2WYPb+hmD3TfZkEP+OtmD9vcZg9v4WZBD/ziZg"
        . "/YzGYPdM9mD9vhZkEP38xmD+vMZg9v5WYP2OBmD3TnZg/b5WYPb+hmQQ/862ZED9/0Zg/YxWYPd"
        . "MdmD9voZkEP38RmD+vFZkEPb+1mD9jqZg9072ZBD9vtZkQPb+pmRQ/86GZBD37uZkEP2NVEiPdm"
        . "QQ9+5mYPdNdEifOJ+YjdZolKvWZED9vqZkEP39RmQQ/r1WZED2/tZkEPc90BZkEPftZmRQ/b6WZ"
        . "FD+vuZkEPxf0AZol6wTH/DxGsJFAFAABAirwkUgUAAA8RpCRABQAAifmKrCRCBQAAMf9miUrFDx"
        . "GsJDAFAABAirwkMwUAAA8RpCQgBQAAifmKrCQjBQAAMf9miUrJDxGsJBAFAABAirwkFAUAAA8Rp"
        . "CQABQAAifmKrCQEBQAAMf9miUrNDxGsJPAEAABAirwk9QQAAA8RpCTgBAAAifmKrCTlBAAAMf9m"
        . "iUrRDxGsJNAEAABAirwk1gQAAA8RpCTABAAAifmKrCTGBAAAMf9miUrVDxGsJLAEAABAirwktwQ"
        . "AAA8RpCSgBAAAifmKrCSnBAAAMf9miUrZDxGsJJAEAABAirwkmAQAAA8RpCSABAAAifmKrCSIBA"
        . "AAMf9miUrdDxGsJHAEAABAirwkeQQAAA8RpCRgBAAAifmKrCRpBAAAMf9miUrhDxGsJFAEAABAi"
        . "rwkWgQAAA8RpCRABAAAifmKrCRKBAAAMf9miUrlDxGsJDAEAABAirwkOwQAAA8RpCQgBAAAifmK"
        . "rCQrBAAAMf9miUrpDxGsJBAEAABAirwkHAQAAA8RpCQABAAAifmKrCQMBAAAMf9miUrtDxGsJPA"
        . "DAABAirwk/QMAAA8RpCTgAwAAifmKrCTtAwAAMf9miUrxDxGsJNADAABAirwk3gMAAA8RpCTAAw"
        . "AAifmKrCTOAwAAMf9miUr1DxGsJLADAABAirwkvwMAAA8RpCSgAwAAZkEPb+GJ+YqsJK8DAABmD"
        . "37fZg/f4GaJSvlAiHq/DxGcJJADAAAPtrwkkQMAAECIesMPEZwkgAMAAA+2vCSCAwAAQIh6xw8R"
        . "nCRwAwAAD7a8JHMDAABAiHrLDxGcJGADAAAPtrwkZAMAAECIes8PEZwkUAMAAA+2vCRVAwAAQIh"
        . "60w8RnCRAAwAAD7a8JEYDAABAiHrXDxGcJDADAAAPtrwkNwMAAECIetsPEZwkIAMAAA+2vCQoAw"
        . "AAQIh63w8RnCQQAwAAD7a8JBkDAABAiHrjDxGcJAADAAAPtrwkCgMAAECIeucPEZwk8AIAAA+2v"
        . "CT7AgAAQIh66w8RnCTgAgAAD7a8JOwCAABAiHrvDxGcJNACAAAPtrwk3QIAAECIevMPEZwkwAIA"
        . "AA+2vCTOAgAAQIh69w8RnCSwAgAAD7a8JL8CAABmD2/aZg9z2wHGAP9AiHr7Mf9mQQ/b2USI92Z"
        . "BD37GZg/r3MZABP+J+USJ82YPxfsAxkAI/4jdZol4ATH/ZolI/cZADP/GQBD/xkAU/8ZAGP/GQB"
        . "z/xkAg/8ZAJP/GQCj/xkAs/8ZAMP/GQDT/xkA4/8ZAPP8PEZQkoAIAAECKvCSiAgAADxGEJJACA"
        . "ACJ+YqsJJICAAAx/2aJSAUPEZQkgAIAAECKvCSDAgAADxGEJHACAACJ+YqsJHMCAAAx/2aJSAkP"
        . "EZQkYAIAAECKvCRkAgAADxGEJFACAACJ+YqsJFQCAAAx/2aJSA0PEZQkQAIAAECKvCRFAgAADxG"
        . "EJDACAACJ+YqsJDUCAAAx/2aJSBEPEZQkIAIAAECKvCQmAgAADxGEJBACAACJ+YqsJBYCAAAx/2"
        . "aJSBUPEZQkAAIAAECKvCQHAgAADxGEJPABAACJ+YqsJPcBAAAx/2aJSBkPEZQk4AEAAECKvCToA"
        . "QAADxGEJNABAACJ+YqsJNgBAAAx/2aJSB0PEZQkwAEAAECKvCTJAQAADxGEJLABAACJ+YqsJLkB"
        . "AAAx/2aJSCEPEZQkoAEAAECKvCSqAQAADxGEJJABAACJ+YqsJJoBAAAx/2aJSCUPEZQkgAEAAEC"
        . "KvCSLAQAADxGEJHABAACJ+YqsJHsBAAAx/2aJSCkPEZQkYAEAAECKvCRsAQAADxGEJFABAACJ+Y"
        . "qsJFwBAAAx/2aJSC0PEZQkQAEAAECKvCRNAQAADxGEJDABAACJ+YqsJD0BAAAx/2aJSDEPEZQkI"
        . "AEAAECKvCQuAQAADxGEJBABAACJ+YqsJB4BAAAx/0iDwEBmiUj1DxGUJAABAABAirwkDwEAAA8R"
        . "hCTwAAAAifmKrCT/AAAAZg9+z0CIeL9miUj5DxGMJOAAAAAPtrwk4QAAAECIeMMPEYwk0AAAAA+"
        . "2vCTSAAAAQIh4xw8RjCTAAAAAD7a8JMMAAABAiHjLDxGMJLAAAAAPtrwktAAAAECIeM8PEYwkoA"
        . "AAAA+2vCSlAAAAQIh40w8RjCSQAAAAD7a8JJYAAABAiHjXDxGMJIAAAAAPtrwkhwAAAECIeNsPE"
        . "UwkcA+2fCR4QIh43w8RTCRgD7Z8JGlAiHjjDxFMJFAPtnwkWkCIeOcPEUwkQA+2fCRLQIh46w8R"
        . "TCQwD7Z8JDxAiHjvDxFMJCAPtnwkLUCIePMPEUwkEA+2fCQeQIh49w8RDCQPtnwkD0CIePtNOec"
        . "PhTT3//9Bg+XwRInoRCntSMHgAkgBhCRABgAASQHASQHBjUX/MdJJjVyBBGYPH0QAAEiLhCRABg"
        . "AAQcZBA/9BxkADAA+2QAKJxUQo3Q9C6kQA2EUY5EEJxEiLhCRABgAAQYhoAkWIYQIPtkABQYnFR"
        . "SjVRA9C6kQA0EAY/wnHSIuEJEAGAABFiGgBQYh5AQ+2AEGJxkEo9kQPQvJAAPBAGP9Jg8EESYPA"
        . "BAn4RYhw/EGIQfxIg4QkQAYAAARMOcsPhWz///8PELQkYAUAADHADxC8JHAFAABEDxCEJIAFAAB"
        . "EDxCMJJAFAABEDxCUJKAFAABEDxCcJLAFAABEDxCkJMAFAABEDxCsJNAFAABEDxC0JOAFAABIgc"
        . "T4BQAAW15fXUFcQV1BXkFfw2ZmLg8fhAAAAAAADx9AAEFXQVZBVUFUVVdWU0iD7FhEi6QkyAAAA"
        . "A++hCTYAAAASIu0JMAAAABFieYPtl4BTYnPRIuMJNAAAABMY9JEicfB4whFD6/xQQ+vxkhj0MH4"
        . "H0hp0h+F61FIwfolKcJBD7ZHAUGJ00EPtlcCweAIweIQCcJBD7YHCcJIi4QkwAAAAA+2QALB4BA"
        . "J2A+2HgnYDQAAAP9EKc8PiGwCAABNidBIictNY8xEiXQkMEGNTCT/TSnIiFQkTkqNNJUAAAAASI"
        . "0sjQQAAAAPts5IiXQkKEGJwolMJDQPtswx9sHqEE6NLIUAAAAAiUwkOMHoEEyJbCQITIm8JLgAA"
        . "ABEiVwkFEmJ20yLRCQITInZTQHYD4LjAQAARIuMJOAAAABFhckPhV8BAABNidlMi2wkKE2FyXUV"
        . "To0MKU05yA+CuAEAAEyJyU2FyXTriXwkPEWJ1UyJRCQgiXQkSIhUJE9MiVwkQEGJw4t0JBRBifA"
        . "5dCQwD4zOAAAASIlMJBhEi1QkMEiJyESJ60iLvCTAAAAASIu0JLgAAABFidlmLg8fhAAAAAAASY"
        . "nFRTH/RYXkfnRIiTwkTI0sKEiJ+kiJ8UUx/w8fQAAPtnoCSIPABEiDwQRIg8IERA+2WP5ED7Zx/"
        . "kQ433IxRTjzcixED7ZY/UQ4Wv1yIUQ6Wf1yG0QPtlj8RDha/HIQRDpZ/EGD3/8PH4QAAAAAAEk5"
        . "xXWrSIs8JEgB7kgB70iLRCQIRSn4RSniTAHoRTnQD45q////SItMJBhBid1FictFhcAPjsEAAAB"
        . "Mi0QkIEiDwQRJOcgPgsMAAACLhCTgAAAAhcAPhPf+//9EidiLfCQ8i3QkSEWJ6g+2VCRPTItcJE"
        . "BNicFEi3wkNESLdCQ4SSnJScH5AkWFyXhNRYnJTo1siQRJiclmDx+EAAAAAABBD7ZZAjjYcic40"
        . "3IjQQ+2WQFBON5yGUQ4+3IUQQ+2GUE42nILOlwkTg+DZ/7//5BJg8EETTnNdcdIi1wkKEgB2Uk5"
        . "yHONSItcJCiDxgFJAds59w+N+f3//zHJSInISIPEWFteX11BXEFdQV5BX8OLdCRISItcJChEidh"
        . "FiepMi1wkQIt8JDyDxgEPtlQkT0kB2zn3D424/f//670PH0AAuAEAAADDZi4PH4QAAAAAAP8A/w"
        . "D/AP8A/wD/AP8A/wD/AAAAAAAAAAAAAAAAAAAA"
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x000dc0: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x001110: get_blob_psabi_level  : u32 get_blob_psabi_level()

        static code := this.i_b64decode(b64)
        cmap := Map(  "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_make_sat_masks",    code + 0x0002a0
                    , "imgutil_imgsrch",           code + 0x000dc0
                    , "get_blob_psabi_level",      code + 0x001110
                    )
        return cmap
    }

    ; -march=x86-64-v2 optimized SSE4 machine code blob
    i_get_mcode_map_v2() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2640 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTichBidHB6BBBwekQRQ+2yQ+2wEQpyEG"
        . "JwUH32UEPScFFMclBOcB8MA+2xQ+23inYQYnCQffaQQ9JwkE5wHwZD7bJD7bSKdGJyPfYD0jBRT"
        . "HJQTnAQQ+dwUSJyFvDZpBWU0hjdCQ4SYnIi0wkUESJyESLTCRAD7bcQYnDwegQD6/KQYnaSGPJS"
        . "AHxSY0ciItMJEgPr8pIY8lIAfFJjQyISDnZD4O3AAAAD7bAg/oBdVcPtlECKcJBidBB99hBD0nQ"
        . "QTnRfDoPtlEBRQ+2wkQpwkGJ0EH32EEPSdBBOdF8IA+2EUUPtsNEKcJBidBB99hBD0nQQTnRfXc"
        . "PH4AAAAAAMcBbXsMPHwBED7ZBAkEpwESJxvfeRA9JxkU5wXziRA+2QQFBD7byQSnwRInG995ED0"
        . "nGRTnBfMhED7YBQQ+280Ep8ESJxvfeRA9JxkU5wXyvTGPCSo0MgUg52XKrDx8AuAEAAADrm2YPH"
        . "4QAAAAAAEiDwQRIOdkPgjT////r4ZBTD69UJDBMY0QkSEhj0kSJyEkB0ESLTCQ4D7bcQYnDwegQ"
        . "QYnaSo0cgUxjRCRATAHCTI0EkUk52HNMD7bAQQ+2UAIpwonR99kPSdFBOdF8QEEPtlABQQ+2yin"
        . "KidH32Q9J0UE50XwpQQ+2EEEPtsspyonR99kPSdFBOdF8E0mDwARJOdhyt7gBAAAAW8MPHwAxwF"
        . "vDZmYuDx+EAAAAAACQVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAQVZB"
        . "VUFUVVdWU0GJ0w+2VCRgacIAAQEACdANAAAA/2YPbuBmD3DcAEGD+wN+VkGD6wRmD2/LMcBFidp"
        . "BweoCQY1SAUjB4gRmDx+EAAAAAADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnCdd"
        . "xB99pIAdFJAdFJAdBHjRyTZg86FNgAZg86FNoBZkEPOhTaAkWF2w+ONgEAAA+2cQIx20HGQAMAQ"
        . "cZBA/+J9UQo1Q9C60QA1kUY5EEJ9A+2cQFBiGgCRYhhAkGJ9UEo1UQPQutAANZAGP8J9w+2MUWI"
        . "aAFBiHkBQYn2QSjGRA9C80AAxkAY/wn+RYgwQYgxQYP7AQ+EygAAAA+2cQZBxkAHAEHGQQf/ifV"
        . "EKNUPQutEANZFGORBCfQPtnEFQYhoBkWIYQZBifVBKNVED0LrQADWQBj/CfcPtnEERYhoBUGIeQ"
        . "VBifZBKMZED0LzQADGQBj/Cf5FiHAEQYhxBEGD+wJ0YUQPtlkKQcZACwBBxkEL/0SJ3kQo1g9C8"
        . "0UA2kUY20UJ00QPtlEJQYhwCkWIWQpEiddAKNcPQvtEANJFGNJBCdIPtlEIQYh4CUWIUQmJ0SjB"
        . "D0LLANAY0gnQQYhICEGIQQgxwFteX11BXEFdQV7DZmYuDx+EAAAAAABmkEFXQVZBVUFUVVdWU0i"
        . "D7FgPEXQkMA8RfCRAi7QkyAAAAA++hCTYAAAAQYn3TImMJLgAAABEi4wk0AAAAEiLvCS4AAAARQ"
        . "+v+UEPr8dMY9DB+B9NadIfhetRScH6JUEpwkiLhCS4AAAARYnWRA+2VwEPtkACQcHiCMHgEEQJ0"
        . "EQPthdIi7wkwAAAAEQJ0EQPtlcBZg9u0EiLhCTAAAAAQcHiCGYPcNIAD7ZAAsHgEEQJ0EQPthdE"
        . "CdANAAAA/2YPbshmD3DJAEUpyA+IWwQAAEhj0khjxmYPdttmDzoUVCQpAEiJ1WYPOhRUJCoBZg8"
        . "6FFQkKwJIKcVIjQSVAAAAAEiJyo1O/EiJRCQgSMHlAonIwegCRI1IAffYRI0kgWYPOhTIAEnB4Q"
        . "QxyYlEJCxJie1IiddJAdUPgtoDAABEi5Qk4AAAAEiLRCQgRYXSdBHp9gEAAEiJx0k5xQ+CtwMAA"
        . "EiF/3Tv6wNIid2JTCQYSInQRIlEJBxFifNFOfcPjJcBAABEiXwkCEiJ+kSJ+0yLhCTAAAAARIl0"
        . "JAxIi4wkuAAAAEyJbCQQZi4PH4QAAAAAAEUx7UUx0oP+Aw+OEQIAAJDzQg9vBCrzQg9vNCnzQw9"
        . "vLCjzQw9vJChJg8UQZg/e8GYP3uhmD3TGZg905WYP28RmD3bDZkQP1/DzRQ+49kHB/gJFAfJNOc"
        . "11tkwByU0ByEwByk1j7EWF7Q+OoQEAAEQPtnICRDpxAg+CigEAAEU4cAIPgoABAABED7ZyAUQ6c"
        . "QEPgnEBAABFOHABD4JnAQAARA+2MkQ6MUEPk8dFODBBD5PGRQ+29kUh/kGD/QF0eEQPtnoGRDp5"
        . "BnItRTh4BnInRA+2egVEOnkFchxFOHgFchZED7Z6BEQ6eQRyC0U4eARBg97/Dx8AQYP9AnQ6RA+"
        . "2egpFOHgKci9EOnkKcilED7Z6CUU4eAlyHkQ6eQlyGEQPtnoIRTh4CHINRDp5CEGD3v8PH0QAAE"
        . "nB5QJMAelNAehMAepFKdMp80gB6kUp80E52w+Op/7//0SLfCQIRIt0JAxMi2wkEEWF2w+OCwIAA"
        . "EiDxwRJOf0PglcCAACLlCTgAAAAhdIPhDj+//+LTCQYRItEJBxIicJmD2/yZg9v4UiJ60yJ6Egp"
        . "+EjB+AJBicKD+AMPjuABAABIifjrD5BBg+oESIPAEEGD+gN+WvMPbwBmD2/uZg9v/GYP3uhmD97"
        . "4Zg90xWYPb+9mD3TsZg/bxWYPdsNmRA/X2EWF23TA6bH9//8PHwBFMfbpqv7//0Ux9ukt////Dx"
        . "+EAAAAAABMY+7pPv7//0QPtlwkKQ+2bCQsZg86FEwkEAFmDzoUTCQIAkSIXCQcRA+2XCQqQIhsJ"
        . "BhEiFwkDEQPtlwkKw+2aAJEON1yLkA4bCQIcicPtmgBQDpsJAxyHEA4bCQQchUPtihAOmwkHHIL"
        . "QDhsJBgPgyH9//9FhdIPhLQAAAAPtmgGRDjdci9AOGwkCHIoD7ZoBUA6bCQMch1AOGwkEHIWD7Z"
        . "oBEA6bCQccgtAOGwkGA+D4Pz//0GD+gF0dg+2aApEON1yL0A4bCQIcigPtmgJQDpsJAxyHUA4bC"
        . "QQchYPtmgIQDpsJBxyC0A4bCQYD4Oi/P//QYP6AnQ4RA+2UA5EOFQkCHIsRTjacidED7ZQDUQ4V"
        . "CQQchtEOlQkDHIUD7ZADDhEJBhyCjpEJBwPg2T8//9Ii0QkIEgBx0k5/Q+DQf7//0iJ3UiLRCQg"
        . "g8EBSAHCRDnBD44D/P//Mf8PEHQkMA8QfCRASIn4SIPEWFteX11BXEFdQV5BX8OFwHi0ZkEPOhT"
        . "TAkiJ+GYPOhRUJBwAZg86FFQkDAFmDzoUTCQYAGYPOhRMJBABZg86FEwkCALpif7//4tMJBhIic"
        . "JEi0QkHEiLRCQgg8EBSAHCRDnBD46I+///64NmDx+EAAAAAAC4AgAAAMOQkJCQkJCQkJCQ"
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x000490: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x000a40: get_blob_psabi_level  : u32 get_blob_psabi_level()       
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_make_sat_masks",    code + 0x0002a0
                    , "imgutil_imgsrch",           code + 0x000490
                    , "get_blob_psabi_level",      code + 0x000a40
                    )
    }

    ; -march=x86-64-v3 optimized AVX2 machine code blob
    i_get_mcode_map_v3() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2816 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTichBidHB6BBBwekQRQ+2yQ+2wEQpyEG"
        . "JwUH32UEPScFFMclBOcB8MA+2xQ+23inYQYnCQffaQQ9JwkE5wHwZD7bJD7bSKdGJyPfYD0jBRT"
        . "HJQTnAQQ+dwUSJyFvDZpBWU0hjdCQ4SYnIi0wkUESJyESLTCRAD7bcQYnDwegQD6/KQYnaSGPJS"
        . "AHxSY0ciItMJEgPr8pIY8lIAfFJjQyISDnZD4O3AAAAD7bAg/oBdVcPtlECKcJBidBB99hBD0nQ"
        . "QTnRfDoPtlEBRQ+2wkQpwkGJ0EH32EEPSdBBOdF8IA+2EUUPtsNEKcJBidBB99hBD0nQQTnRfXc"
        . "PH4AAAAAAMcBbXsMPHwBED7ZBAkEpwESJxvfeRA9JxkU5wXziRA+2QQFBD7byQSnwRInG995ED0"
        . "nGRTnBfMhED7YBQQ+280Ep8ESJxvfeRA9JxkU5wXyvTGPCSo0MgUg52XKrDx8AuAEAAADrm2YPH"
        . "4QAAAAAAEiDwQRIOdkPgjT////r4ZBTD69UJDBMY0QkSEhj0kSJyEkB0ESLTCQ4D7bcQYnDwegQ"
        . "QYnaSo0cgUxjRCRATAHCTI0EkUk52HNMD7bAQQ+2UAIpwonR99kPSdFBOdF8QEEPtlABQQ+2yin"
        . "KidH32Q9J0UE50XwpQQ+2EEEPtsspyonR99kPSdFBOdF8E0mDwARJOdhyt7gBAAAAW8MPHwAxwF"
        . "vDZmYuDx+EAAAAAACQVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAQVZB"
        . "VUFUVVdWU0QPtlQkYEFpwgABAQBECdANAAAA/8X5btDE4n1Y0oP6B35VRI1a+MX9b8oxwEWJ2kH"
        . "B6gNBjVIBSMHiBWYuDx+EAAAAAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQBSIPAIEg5wnXeQf"
        . "faSAHRSQHQSQHRQ40U04P6A34nxfpvIUmDwRBIg8EQSYPAEIPqBMXZ2MrF6dzExMF6f0jwxMF6f"
        . "0HwxON5FNAAxMN5FNIBxMN5FNMChdIPjjABAAAPtnECMdtBxkADAEHGQQP/ifVEKN0PQutEAN5F"
        . "GORBCfQPtnEBQYhoAkWIYQJBifVFKNVED0LrRADWQBj/CfcPtjFFiGgBQYh5AUGJ9kEoxkQPQvN"
        . "AAMZAGP8J/kWIMEGIMYP6AQ+ExQAAAA+2cQZBxkAHAEHGQQf/ifVEKN0PQutEAN5FGORBCfQPtn"
        . "EFQYhoBkWIYQZBifVFKNVED0LrRADWQBj/CfcPtnEERYhoBUGIeQVBifZBKMZED0LzQADGQBj/C"
        . "f5FiHAEQYhxBIP6AnRdD7ZRCkHGQAsAQcZBC/+J1kQo3g9C80QA2kUY20EJ0w+2UQlBiHAKRYhZ"
        . "ConXRCjXD0L7RADSRRjSQQnSD7ZRCEGIeAlFiFEJidEowQ9CywDCGMAJ0EGISAhBiEEIMcDF+Hd"
        . "bXl9dQVxBXUFeww8fhAAAAAAAQVdBVkFVQVRVV1ZTSIHsmAAAAMX4EXQkUMX4EXwkYMV4EUQkcM"
        . "V4EYwkgAAAAIu8JAgBAABEi5wkGAEAAEGJ/UEPvsNMiYwk+AAAAExj0kSJxkSLjCQQAQAASIucJ"
        . "PgAAABFD6/pQQ+vxUhj0MH4H0hp0h+F61FIwfolKcJBgPtkuAEAAABED7ZbAQ9FhCQgAQAAQcHj"
        . "CEGJxkiLhCT4AAAAD7ZAAsHgEEQJ2EQPthtIi5wkAAEAAEQJ2EQPtlsBxflu4EiLhCQAAQAAQcH"
        . "jCMTifVjkD7ZAAsHgEEQJ2EQPthtECdgNAAAA/8X5bujE4n1Y7UQpzg+ItQQAAEhjx0yJ1USNR/"
        . "hEiWwkOEgpxYlUJBzF+W/0xflvzUqNBJUAAAAASMHlAsTDeRTsAIl0JExIiUQkMESJwMTjeRRkJ"
        . "D0AxON5FGQkPgHB6ANIiWwkIESNWAH32EiJTCRAScHjBUWNPMBFMcCJvCQIAQAARIlEJEhMiVwk"
        . "KESIZCQ/SIt8JEBIi0QkIEgB+EmJ+kiJRCQID4L7AwAARYX2D4RJBAAARIl0JBAPtlwkPcTDeRT"
        . "xAg+2fCQ+RA+2dCQ/SItEJAhMKdBIwfgCicKD+AcPjoECAADFfW/Mxf1v3cRBPXbATInQ6xMPHw"
        . "CD6ghIg8Agg/oHD45fAgAAxf5vAMXl3tDFtd74xf10x8XtdNPF/dvCxb12wMX918iFyXTMRIt0J"
        . "BBIi2wkIEyLXCQoxeV228XpdtKLvCQIAQAAi1wkHIneOVwkOA+MuQEAAEyJVCQQTIuEJAABAABM"
        . "idBIi4wk+AAAAESLZCQ4Zg8fhAAAAAAAMdJFMdJBifmD/wd+Sg8fAMX+bwQQxMF93jwQxX3eBBH"
        . "EwUV0PBBIg8Igxb10wMX928fF/XbDxX3XyPNFD7jJQcH5AkUBykw52nXFTAHZTQHYTAHYRYn5QY"
        . "P5Aw+ObwEAAMX6bwBBg+kESIPBEEmDwBDEwXneePDFed5B8EiDwBDEwUF0ePDFuXTAxfnbx8X5d"
        . "sLF+dfQ8w+40sH6AkWFyQ+OOgEAAA+2WAI6WQIPgg0BAABBOFgCD4IDAQAAD7ZYATpZAQ+C9gAA"
        . "AEE4WAEPguwAAAAPthg6GUEPk8VBOBgPk8MPtttEIetBg/kBdHlED7ZoBkQ6aQZyLkU4aAZyKEQ"
        . "PtmgFRDppBXIdRThoBXIXRA+2aAREOmkEcgxFOGgEg9v/Dx9EAABBg/kCdDpED7ZoCkU4aApyL0"
        . "Q6aQpyKUQPtmgJRThoCXIeRDppCXIYRA+2aAhFOGgIcg1EOmkIg9v/Zg8fRAAATWPJScHhAkwBy"
        . "U0ByEwByEQp1kEp/EgB6CnWKd5EOeYPjnL+//9Mi1QkEIX2D46qAQAASYPCBEw5VCQID4J5AQAA"
        . "RYX2D4QX/v//6Xn9//8PH4QAAAAAADHb6SL///9mDx+EAAAAAAAx0kWFyQ+Py/7//w8fRAAAMdv"
        . "rlEyJ0IP6Aw+OpQEAAMX6bwDF0d7Qxfne3MXpdNXF+XTDxfnbwsXpdtLF+XbCxfnXyIXJD4WQ/f"
        . "//SIPAEIPqBEGJ24n9RInJRIn2xMN5FMwBxMN5FMgCRA+2aAJBOM1yJkU46HIhRA+2aAFBOO1yF"
        . "0U47HISRA+2KEU43XIJRDjuD4NC/f//hdIPhJkAAABED7ZoBkE4zXInRTjociJED7ZoBUE47XIY"
        . "RTjschNED7ZoBEU43XIJRDjuD4MJ/f//g/oBdGNED7ZoCkE4zXInRTjociJED7ZoCUE47XIYRTj"
        . "schNED7ZoCEU43XIJRDjuD4PT/P//g/oCdC0PtlAOQTjQciQ4ynIgD7ZQDUE41HIXQDjqchIPtk"
        . "AMQDjGcglEONgPg6H8//9Ii0QkMEkBwkw5VCQID4Mu/P//RIt0JBCDRCRIAYt8JEyLRCRISItcJ"
        . "DBIAVwkQDn4D47L+///RTHSxfh3xfgQdCRQxfgQfCRgTInQxXgQjCSAAAAAxXgQRCRwSIHEmAAA"
        . "AFteX11BXEFdQV5BX8NJicFIi0QkME2F0g+FJvz//0mJwkk5wXPv646F0g+Ibv///8TDeRTjAMT"
        . "jeRTlAcTjeRThAsTjeRTuAMTDeRTsAcTDeRToAul0/v//Zi4PH4QAAAAAALgDAAAAw5CQkJCQkJ"
        . "CQkJA="
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match (i32 a, i32 b, i32 t);
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match (argb p1, argb p2, i32 t);
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw (argb *start, u32 w, u32 h, u8 threshold);
        . "" ; 0x0002a0: imgutil_make_sat_masks: u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
        . "" ; 0x0004b0: imgutil_imgsrch       : argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft);
        . "" ; 0x000af0: get_blob_psabi_level  : u32 get_blob_psabi_level (void);
        static code := this.i_b64decode(b64)
            return Map(   "imgutil_channel_match",     code + 0x000000
                        , "imgutil_pixels_match",      code + 0x000020
                        , "imgutil_column_uniform",    code + 0x000080
                        , "imgutil_row_uniform",       code + 0x0001a0
                        , "imgutil_makebw",            code + 0x000240
                        , "imgutil_make_sat_masks",    code + 0x0002a0
                        , "imgutil_imgsrch",           code + 0x0004b0
                        , "get_blob_psabi_level",      code + 0x000af0
                    )
    } 

    ; -march=x86-64-v4 optimized AVX512 machine code blob
    i_get_mcode_map_v4() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 3280 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
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
        . "vDZmYuDx+EAAAAAACQVlNED6/CSInISo00hQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAQVZB"
        . "VUFUVVdWU0QPtlQkYEFpwgABAQBECdANAAAA/2LyfUh80IP6D35bRI1a8GLx/UhvyjHARYnaQcH"
        . "qBEGNUgFIweIGDx8AYvF/SG8cAWLxZUjYwWLR/kh/BABi8XVI3MNi0f5IfwQBSIPAQEg5wnXWSA"
        . "HRSQHQSQHRQcHiBESJ2kQp0oP6A35zxfpvIUSNUvzF2djKxMF6fwjF6dzMxMF6fwlBg/oDfjfF+"
        . "m9pEMXR2MrEwXp/SBDF6dzNxMF6f0kQg/oLfhnF+m9pIMXR2MrF6dzFxMF6f0ggxMF6f0EgRInS"
        . "weoCjUIB99pIweAEQY0UkkgBwUkBwEkBwcTjeRTQAMTDeRTSAcTDeRTTAoXSD444AQAAD7ZxAjH"
        . "bQcZAAwBBxkED/4n3RCjfD0L7RADeQBjtCfUPtnEBQYn+RYhwAon3QYhpAkQo1w9C+0QA1kGJ/U"
        . "AY/wn3D7YxRYhoAUGIeQFBifRBKMRED0LjQADGQBj/Cf5FiCBBiDGD+gEPhMoAAAAPtnEGQcZAB"
        . "wBBxkEH/4n3RCjfD0L7RADeQBjtCfUPtnEFQYn+RYhwBon3QYhpBkQo1w9C+0QA1kGJ/UAY/wn3"
        . "D7ZxBEWIaAVBiHkFQYn0QSjERA9C40AAxkAY/wn+RYhgBEGIcQSD+gJ0Xw+2UQpBxkALAEHGQQv"
        . "/idZEKN4PQvNEANpFGNtBCdMPtlEJifdBiHgKidZFiFkKRCjWD0LzRADSRRjSQQnSD7ZRCEGIcA"
        . "lFiFEJidEowQ9CywDCGMAJ0EGISAhBiEEIMcDF+HdbXl9dQVxBXUFew5BBV0FWQVVBVFVXVlNIg"
        . "+xYxfgRdCQwxfgRfCRARIukJMgAAABEi5Qk0AAAAA++hCTYAAAARYnmRQ+v8kyJjCS4AAAASIuc"
        . "JLgAAABBD6/GTGPIwfgfTWnJH4XrUUnB+SVFictED7ZLAUEpw0iLhCS4AAAAQcHhCA+2QALB4BB"
        . "ECchED7YLSIucJMAAAABECchED7ZLAWLyfUh84EiLhCTAAAAAQcHhCA+2QALB4BBECchED7YLRA"
        . "nIDQAAAP9i8n1IfOhFKdAPiLkAAABIY9JJY8TE43kU7QBEidtJidXF+ZLNRIn1xflv1UkpxWLh/"
        . "ShvzGLh/ShvxUiNBJUAAAAASInKQY1MJPBJweUCSIlEJCiJyMHoBESNUAHB4AQpwUnB4gbE43kU"
        . "4ABBic8xycX5ktBNie5JidFJAdZyOESLnCTgAAAARYXbD4UTBAAATItcJChIidDrCw8fhAAAAAA"
        . "ATInITYXJD4VDBgAATo0MGE05znPrSItEJCiDwQFIAcJBOch9rUUxwOmuBQAADx8AQYP7Aw+O1g"
        . "UAAMX6bwBisX0I3vTFyXTwxenewMX5dMLF+dvGxfl2x8X51/CF9g+F9AAAAEGNc/yD/gMPjo0FA"
        . "ADF+m9AEGKxfQje9MXJdPDF6d7Axfl0wsX528bF+XbHxfnX8IX2D4W8AAAAQY1z+IP+Aw+OXgUA"
        . "AMX6b3AgYrFNCN7Excl0wMXp3vbFyXTyxfnbxsXBdsDF+dfwhfYPhYQAAABIg8AwQY1z9GLjfQg"
        . "UzwLF+ZFUJBxi430IFEwkDAHF+ZFMJBBi430IFEQkGAFi430IFEQkCAJED7ZYAkE4+w+CoAMAAE"
        . "Q4XCQID4KVAwAARA+2WAFEOlwkDA+ChQMAAEQ4XCQYD4J6AwAARA+2GEQ6XCQcD4JrAwAARDhcJ"
        . "BAPgmADAACJTCQcTInIYvN1SCXJ/0GJ6UyJdCQQxeF220iJxUiJVCQgRIlEJBhBidhEicdFOcEP"
        . "jDACAABEiUwkCEiJ6EWJzkiLjCTAAAAARIlEJAxIi5QkuAAAAGaQRTHJRTHAQYP8Dw+O0AIAAGK"
        . "xf0hvPAhis0VIPhwKBWKzRUs+HAkCSYPBQGLyfkgow2LzfUgf4QDFeJPc80UPuNtFAdhNOcp1x0"
        . "1jz0wB0kwB0UwB0EGD+QMPjpECAADF+m8AxfneOkGNcfzFwXT4xfneAcX5dAHF+dvHxfl2w8X51"
        . "9jzD7jbwfsCg/4DfmrF+m9AEMX53noQxcF0+MX53kEQxfl0QRDF+dvHxfl2w8V519jzRQ+420HB"
        . "+wJEAdtBg/kLfjTF+m9wIMX6b3kgxcneQiDFwd7+xcl0wMXBdHEgxfnbxsX5dsPFedfI80UPuMl"
        . "BwfkCRAHLQYnzg+YDQcHrAkxjzkGDwwFJweMETAHaTAHZTAHYRYXJD47gAQAARA+2WAJEOFkCD4"
        . "KhAQAARDpaAg+ClwEAAEQPtlgBRDpaAQ+CiAEAAEQ4WQEPgn4BAABED7YYRDgZQA+TxkQ6GkEPk"
        . "8NFD7bbQSHzQYP5AXRvD7ZwBkA6cgZyLUA4cQZyJw+2cAVAOHEFch1AOnIFchcPtnAEQDpyBHIN"
        . "QDhxBEGD2/8PH0QAAEGD+QJ0Mg+2cApAOnIKcihAOHEKciIPtnAJQDpyCXIYQDhxCXISD7ZwCEA"
        . "6cghyCEA4cQhBg9v/ScHhAkwBykwByUwByEQpx0Up5kwB6CnfRCnfRDn3D478/f//RItMJAhEi0"
        . "QkDIX/D44SAgAATIt0JBBIg8UESTnuD4LQAQAAi4Qk4AAAAIXAD4Sb/f//SInoRInDi0wkHESLR"
        . "CQYSItUJCBEic1JicFi4f1Ib9Ri8f1Ib91i83VIJcn/YuH9CG/kxcF2/0yJ8EwpyEjB+AKD+A9B"
        . "icNMich/H+n4+///Dx+EAAAAAABBg+sQSIPAQEGD+w8Pjt77//9i8X9IbzBis01IPtoFYvNNSz7"
        . "bAmLyfkgow2LzfUgfwQDF+JjAdMfp2vz//2aQRTHb6ZP+//8PH4QAAAAAAE1jzEGD+QMPj3L9//"
        . "8PHwAx20WFyQ+PJf7//w8fRAAARTHb6eX+//+F9g+EuAAAAEQPtlgGQTj7cjFEOFwkCHIqRA+2W"
        . "AVEOlwkDHIeRDhcJBhyF0QPtlgERDpcJBxyC0Q4XCQQD4Nd/P//g/4BdHhED7ZYCkE4+3IxRDhc"
        . "JAhyKkQPtlgJRDpcJAxyHkQ4XCQYchdED7ZYCEQ6XCQccgtEOFwkEA+DHfz//4P+AnQ4RA+2WA5"
        . "EOFwkCHIsQTj7cidED7ZYDUQ4XCQYchtEOlwkDHIUD7ZADDhEJBByCjpEJBwPg+D7//9Ii0QkKE"
        . "kBwU05zg+Dlf7//0iLRCQog8EBSAHCQTnID401+v//6YP6//9mDx9EAACLTCQcSItUJCBEicNEi"
        . "c1Ii0QkKESLRCQYg8EBSAHCQTnID40C+v//6VD6//8PHwBJiejF+HfF+BB0JDDF+BB8JEBMicBI"
        . "g8RYW15fXUFcQV1BXkFfw0iDwBDp1fr//0iDwCDpzPr//0WF2w+IX////8TjeRTnAkSJ3sTjeRR"
        . "kJBwAxON5FGQkDAHE43kUbCQQAMTjeRRsJBgBxON5FGwkCALpu/r//0mJwekB+///Zg8fhAAAAA"
        . "AAuAQAAADDkJCQkJCQkJCQkA=="
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x000500: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x000cc0: get_blob_psabi_level  : u32 get_blob_psabi_level()
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_make_sat_masks",    code + 0x0002a0
                    , "imgutil_imgsrch",           code + 0x000500
                    , "get_blob_psabi_level",      code + 0x000cc0
                    )
    }

    i_get_psabi_level() {
        ; this can't be part of the main blob as we don't want GCC to taint it with
        ; vectorization or the use of other instructions that may not be available
        ; on older CPUs
        static b64 := ""
        . "" ; imgutil_cpuid.c
        . "" ; 704 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "QVVBVFVXVlNIg+wYRTHJnJxngTQkAAAgAJ2cWGczBCSdJQAAIACFwA+EgQAAAEyNFasAAABEich"
        . "Eickx/w+iSY2q0AEAAEGJxESJybgAAACAD6JBicVBi0IMRYsCQTnBRA9CyEGB+AAAAIB2U0U5xX"
        . "JYRDsFNwIAAEWLWghJY3IEdB1EicCJ+USJBSECAAAPookEJIlcJASJTCQIiVQkDEQjHLR0JEmDw"
        . "hBJOep1p0SJyEiDxBhbXl9dQVxBXcOQRTnEc61FhcB4qEGD6QFEichIg8QYW15fXUFcQV3DZpAB"
        . "AAAAAwAAAAEAAAABAAAAAQAAAAMAAAAAAQAAAQAAAAEAAAADAAAAAAgAAAEAAAABAAAAAwAAAAC"
        . "AAAABAAAAAQAAAAMAAAAAAAABAQAAAAEAAAADAAAAAACAAAEAAAABAAAAAwAAAAAAAAEBAAAAAQ"
        . "AAAAMAAAAAAAACAQAAAAEAAAADAAAAAAAABAEAAAABAAAAAgAAAAEAAAACAAAAAQAAAAIAAAAAI"
        . "AAAAgAAAAEAAAACAAAAAAAIAAIAAAABAAAAAgAAAAAAEAACAAAAAQAAAAIAAAAAAIAAAgAAAAEA"
        . "AIACAAAAAQAAAAIAAAABAAAAAgAAAAAQAAADAAAAAQAAAAIAAAAAAEAAAwAAAAEAAAACAAAAAAA"
        . "ACAMAAAABAAAAAgAAAAAAABADAAAAAQAAAAIAAAAAAAAgAwAAAAEAAIACAAAAIAAAAAMAAAAHAA"
        . "AAAQAAAAgAAAADAAAABwAAAAEAAAAgAAAAAwAAAAcAAAABAAAAAAEAAAMAAAAHAAAAAQAAAAAAA"
        . "QAEAAAABwAAAAEAAAAAAAIABAAAAAcAAAABAAAAAAAAEAQAAAAHAAAAAQAAAAAAAEAEAAAABwAA"
        . "AAEAAAAAAACABAAAAP////+QkJCQkJCQkJCQkJA="
        . "" ; 0x000000: get_cpu_psabi_level: int get_cpu_psabi_level()
                                                                                                                
        static code := this.i_b64decode(b64)
        return DllCall(code + 0x000000, "int")
    }


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
    return DllCall(imgu.i_mcode_map["imgutil_pixels_match"], "uint", a, "uint", b, "uint", t, "int")
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
    return DllCall(imgu.i_mcode_map["imgutil_column_uniform"]
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
    return DllCall(imgu.i_mcode_map["imgutil_row_uniform"]
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
    if t <= 0
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
    return DllCall(imgu.i_mcode_map["imgutil_make_bw"], 
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
    static code := imgu.i_b64decode(b64)
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
imgutil_imgsrch2(&fx, &fy, x, y, w, h, img) {
    return ImageSearch(&fx, &fy, x, y, x+w, y+h, "*4 " img)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_imgsrch(&fx, &fy,                       ; output coordinates if image found
                haystack,                       ; ImagePutBuffer or anything acceptef by ImagePut
                needle,                         ; ImagePutBuffer or anything accepted by ImagePut
                tolerance := 0,                 ; pixels that differ by this much still match
                min_percent_match := 100,       ; percentage of pixels needed to return a match
                force_topleft_pixel_match := 1) ; top left pixel must match? (tolerance applies)
{
    if !isImagePutBuffer(haystack)
        haystack := ImagePutBuffer(haystack)
    if (!isImagePutBuffer(needle))
        needle := ImagePutBuffer(needle)
    
    imgutil_mask_lo := Buffer(needle.width * needle.height * 4)
    imgutil_mask_hi := Buffer(needle.width * needle.height * 4)
    DllCall(imgu.i_mcode_map["imgutil_make_sat_masks"], 
        "ptr", needle.ptr, "uint", needle.width * needle.height, 
        "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "char", tolerance, "int")

    result := DllCall(imgu.i_mcode_map["imgutil_imgsrch"],
        "ptr", haystack.ptr, "int", haystack.width, "int", haystack.height,
        "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "int", needle.width, "int", needle.height,
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
