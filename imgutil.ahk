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
    i_use_single_thread := false                    ; used for testing purposes, forces srch to use a single thread
    i_tolerance := 8                                ; tolerance used by all pixel matching functions
    i_gdip_token := 0                               ; gdiplus token

    ; initialize the library
    __New() {
        this.i_mcode_map        := this.i_get_mcode_map()
        this.i_multithread_ctx  := DllCall(this.i_mcode_map["mt_init"], "int", 0, "ptr")
        si := Buffer(24, 0)
        NumPut("int", 1, si)
        token := 0
        DllCall("Gdiplus.dll\GdiplusStartup", "ptr*", &token, "ptr", si.ptr, "ptr", 0, "uint")
        this.i_gdip_token := token
    }

    ; deinit
    __Delete() {
        DllCall(this.i_mcode_map["mt_deinit"], "ptr", this.i_multithread_ctx)
        DllCall("Gdiplus.dll\GdiplusShutdown", "ptr", this.i_gdip_token)
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
    ; scalar only, this is just for benchmarking comparison and not meant to be used. v0 is below the psabi 
    ; baseline, there's no equivalent psabi level and get_cpu_psabi_level should never return it.
    ; (theoretically it might, if e.g. SSE has been masked off from CPUID in a VM, so... eh?)
    ;########################################################################################################
    i_get_mcode_map_v0() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 6704 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "uAEAAADwD8EBOUFAflqLUTRMY0EwAcIDQRwPr1E4D69BIEhj0kwBwkyLQShImE2NDJBIY1EYRItBPEgB0EiLURBFhcBMjRSCdLZFicAxwJBBixSBQYkUgkiDwAFMOcB17+ud"
    . "Dx9EAADDDx+AAAAAAFdWU4tcJEhEichIY/JIic9IY0wkQA+2xEWJyEGJwotEJFhBwegQD6/GSJhIAchMjRyHi0QkUA+vxkiYSAHISI0Mh0w52XNpg/4BRQ+2wEUPttJFD7bJ"
    . "dBHrZmYPH0QAAEiDwQRMOdlzRw+2QQFEKdCZMdAp0A+2UQJEKcKJ1sH+HzHyKfI50A9Mwg+2EUQpyonWwf4fMfIp8jnQD0zCOcN9vjHAW15fww8fhAAAAAAAuAEAAABbXl/D"
    . "Dx+AAAAAAEjB5gLrEmYuDx+EAAAAAABIAfFMOdlz2A+2QQJEKcCZMdAp0A+2UQFEKdKJ18H/HzH6Kfo50A9Mwg+2EUQpyonXwf8fMfop+jnQD0zCOcN9vzHA649mZi4PH4QA"
    . "AAAAAFZTD69UJDiLXCRASGPSSInOSGNMJFBFicpEichBweoQD7bESAHRTI0cjkhjTCRISAHKSI0Mlkw52XNlRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPBBEw52XNHD7ZBAkQp"
    . "0Jkx0CnQD7ZRAUQpwonWwf4fMfIp8jnQD0zCD7YRRCnKidbB/h8x8inyOdAPTMI5w32+McBbXsNmDx+EAAAAAAC4AQAAAFteww8fhAAAAAAAQVdBVkFVQVRVV1ZTSIHsuAIA"
    . "AA8RtCQQAgAADxG8JCACAABEDxGEJDACAABEDxGMJEACAABEDxGUJFACAABEDxGcJGACAABEDxGkJHACAABEDxGsJIACAABEDxG0JJACAABEDxG8JKACAAAPtoQkIAMAAERp"
    . "4AABAQBJicqJ10EJxEGBzAAAAP9EieBFieZEieZBwe4QD7bEhdJBicNEifMPjhEIAACD+hAPjnMHAABFD7bkRQ+29kUPtuvzRA9vPWsWAABMieBMifHzRA9vNWwWAABmD+//"
    . "SMHgCEjB4QjzRA9vLWcWAABmRQ92241q/0wJ8EwJ6fNED28lkBYAAEjB4AhIweEITInqTAnhTAnoSMHiCEjB4AhIweEITAniTAngTAnxSMHiCEjB4AhIweEITAnyTAnwTAnp"
    . "SMHgCEjB4QhMCeFMCehIweAISMHhCEwJ4EwJ8UjB4AhIweEITAnwTAnpSMHiCEwJ6kiJBCRIweIISIlMJAhMCeJIiUwkEEyJ0UjB4ghIiUQkKEyJyEwJ8kjB4ghMCepIweII"
    . "TAniQYnsQcHsBEiJVCQYScHkBkiJVCQgTInCTQHUDx9AAPMPbzFIg8FASIPCQEiDwEDzD29R0GYPOAA14hQAAPMPb2ngZg9vwvMPb2QkIGYPOAAV6hQAAGYPOAAF0RQAAGYP"
    . "6/BmD2/FZg84AC3wFAAAZg/85vMPb1wkEGZED2/WZg84AAXIFAAAZg/r0PMPb0HwZkQP+FQkIGZED2/KZg/82vMPbwwkZkQP+EwkEGYPOAAFuhQAAGYP6+hmD2/GZkQPb8Vm"
    . "D9jEZg/8zWYPdMdmRA/4BCRmD9vgZkEP38NmD+vEZg9v4mYP2ONmD3TnZg/b3GZBD9/jZg/r42YPb91mD9jZZg9032YP28tmQQ/f22YP69lmQQ9vymYP2M5mQQ9v8WYPdM9m"
    . "D9jyZkEPb9BmD9jVZg9092YPdNdmQQ/bymZED8XpAGZEiWrAZg9v6Q8RjCQAAgAAZkEP2/FED7asJAICAABmDzgALRIUAABmQQ/b0ESIasJmRA/F7QBmD2/pZkSJasRmQQ84"
    . "AO8PEYwk8AEAAEQPtqwk9QEAAESIasZmRA/F6QNmRIlqyA8RjCTgAQAARA+2rCToAQAARIhqymZED8XtAGYPb+5mRIlqzGZBDzgA7Q8RjCTQAQAARA+2rCTbAQAARIhqzmZE"
    . "D8XpBmZEiWrQDxGMJMABAABmQQ84AM5ED7asJM4BAABmD+vNRIhq0mZED8XpAGYPb85mDzgADZgTAABmRIlq1A8RtCSwAQAARA+2rCSxAQAARIhq1mZED8XuAWZEiWrYDxG0"
    . "JKABAABED7asJKQBAABEiGraZkQPxekAZg9vzmYPOAANWxMAAGZEiWrcDxG0JJABAABED7asJJcBAABEiGreZkQPxe4EZkSJauAPEbQkgAEAAEQPtqwkigEAAESIauJmRA/F"
    . "6QBmD2/KZg84AA0eEwAAZkSJauQPEbQkcAEAAEQPtqwkfQEAAESIauZmRA/F7gdmRIlq6GZBD37VRIhq6mZED8XpAGYPb8pmRIlq7GZBDzgAzA8RlCRgAQAARA+2rCRjAQAA"
    . "RIhq7mZED8XqAmZEiWrwDxGUJFABAABED7asJFYBAABEiGryZkQPxekAZg9vymYPOAANsxIAAGZEiWr0DxGUJEABAABED7asJEkBAABEiGr2ZkQPxeoFZkSJavgPEZQkMAEA"
    . "AEQPtqwkPAEAAESIavpmRA/F6QBmD2/IZkSJavwPEZQkIAEAAEQPtqwkLwEAAMZCwwDGQscAxkLLAESIav5mRA/F6ADGQs8AxkLTAMZC1wDGQtsAxkLfAMZC4wDGQucAxkLr"
    . "AMZC7wDGQvMAxkL3AMZC+wDGQv8AZg84AA2GEQAAZkSJaMAPEYQkEAEAAEQPtqwkEgEAAESIaMJmRA/F6QBmD2/IZkSJaMRmQQ84AM8PEYQkAAEAAEQPtqwkBQEAAESIaMZm"
    . "RA/F6ANmRIloyA8RhCTwAAAARA+2rCT4AAAARIhoymZED8XpAGYPb8xmRIlozGZBDzgAzQ8RhCTgAAAARA+2rCTrAAAARIhozmZED8XoBmZEiWjQDxGEJNAAAABmQQ84AMZE"
    . "D7asJN4AAABmD+vBRIho0mZED8XoAGYPb8RmDzgABfsQAABmRIlo1A8RpCTAAAAARA+2rCTBAAAARIho1mZED8XsAWZEiWjYDxGkJLAAAABED7asJLQAAABEiGjaZkQPxegA"
    . "Zg9vxGZEiWjcDxGkJKAAAABED7asJKcAAABmDzgABagQAABEiGjeZkQPxewEZkSJaOAPEaQkkAAAAEQPtqwkmgAAAESIaOJmRA/F6ABmD2/DZg84AAWBEAAAZkSJaOQPEaQk"
    . "gAAAAEQPtqwkjQAAAESIaOZmRA/F7AdmRIlo6GZBD37dRIho6mZED8XoAGYPb8NmRIlo7GZBDzgAxA8RXCRwRA+2bCRzRIho7mZED8XrAmZEiWjwDxFcJGBED7ZsJGZEiGjy"
    . "ZkQPxegAZg9vw2YPOAAFIhAAAGZEiWj0DxFcJFBED7ZsJFlEiGj2ZkQPxesFZkSJaPgPEVwkQEQPtmwkTESIaPpmRA/F6ABmRIlo/A8RXCQwRA+2bCQ/xkDD/8ZAx//GQMv/"
    . "RIho/sZAz//GQNP/xkDX/8ZA2//GQN//xkDj/8ZA5//GQOv/xkDv/8ZA8//GQPf/xkD7/8ZA//9MOeEPhbH5//+D5fCJ6CnvSMHgAkkBwkkBwEkBwY1H/zH/SY1sgQQPHwBB"
    . "D7YKQcZBA/9FD7Z6AUHGQAMARQ+2agJBicxBKPREifpED0LnRCjaQQ+2xEGJ1EQPQudEieJFiexBKNyI1ESJ+kQPQudAAPFmQYkARInoRRj2RAnxRADaRYhgAkUY9kGICUQJ"
    . "8gDYQYhRARjSSYPBBEmDwgQJ0EmDwARBiEH+TDnND4V4////DxC0JBACAAAxwA8QvCQgAgAARA8QhCQwAgAARA8QjCRAAgAARA8QlCRQAgAARA8QnCRgAgAARA8QpCRwAgAA"
    . "RA8QrCSAAgAARA8QtCSQAgAARA8QvCSgAgAASIHEuAIAAFteX11BXEFdQV5BX8NmLg8fhAAAAAAAQVdBVkFVQVRVV1ZTSIHsGAEAAA8RdCRwDxG8JIAAAABEDxGEJJAAAABE"
    . "DxGMJKAAAABEDxGUJLAAAABEDxGcJMAAAABEDxGkJNAAAABEDxGsJOAAAABEDxG0JPAAAABEDxG8JAABAABEi6wkiAEAAESLjCSQAQAARIucJJgBAABIi5wkqAEAAESJ6EEP"
    . "r8GJxolEJEhBD77DD6/GSIu0JIABAABMY9DB+B9NadIfhetRScH6JUEpwkGA+2S4AQAAAA9FhCSgAQAARIlUJDhED7ZWAUGJw0iLhCSAAQAAQcHiCA+2QALB4BBECdBED7YW"
    . "RAnQDQAAAP9FKciJx0SJRCRkD4iDCAAASGPSTWPFZg/vwEiJTCRASInQZg9v8PNED289WQ0AAIl8JExIjTSVAAAAAEwpwItUJDhmDzgANW0NAABMjTSFAAAAAItEJEhIifdm"
    . "D9Z0JAhOjSQxRInpTIl0JFhNieBEiVwkPEmJ3DnQD53ChcAPlcAhwkGJ0kGNVf+J0MHoBEjB4AZIiUQkGInQg+DwTI08hQAAAAApwYlEJBSJ0EyNNIUEAAAAiUwkEEyJ/jHJ"
    . "TIl0JGhBidZIi0QkQEk5wEiJwg+CpwcAAESLTCQ8RYXJD4SyBwAAi0QkTA+27InDwegQiWwkIEGJwUSJ9UyJwESLdCQgSCnQSMH4AoP4/w+MXAcAAIPAAUiJVCQoTI18ggRI"
    . "idDrEA8fAEiDwARMOfgPhDUHAABEOkgCQQ+Tw0Q6cAEPk8JBhNN03zoYcttBie5JicdIi1QkWEiJ84lMJGBIi0QkaESJ9kiJfCRQTIn5RIhUJChJid5MiUQkMEyJpCSoAQAA"
    . "gHwkKACLbCQ4D4RtBgAASIu8JIABAABIictIiUwkIESLZCRIi2wkOPNED3410wsAAA8fAEWF7Q+OKQYAAIP+Dw+GiAYAAEyLfCQYSIn5SYnYZkUP7+1mRQ/v5E2NDD8PH0QA"
    . "APNBD28QZkEPb89mQQ9vx2ZBD2//80UPb1AQZkEPb/dmRQ9v30iDwUDzQQ9vaCBmD9vKZg9x0ghJg8BA80UPb0jwZkEP28JmD2fIZkEPb8fzRA9vQdBmD9v9ZkEPcdIIZkEP"
    . "28HzD29ZwGZBD3HRCGYPZ/hmD3HVCPMPb2HgZkEPZ9JmQQ/b1/MPb0HwZkEPZ+lmRA9vymZBD9vw8w9vUcBmQQ/b32YPZ95mQQ9v92YP2/RmRA/b2GZBD3HQCGZBD2fzZg9x"
    . "0AhmQQ/b72ZED2fNSTnJZg9x0ghmD2/uZkEP2/dmD3HUCGZBD2fQZkEP29dmD2fgZg9vwWZBD9vnZg9n1GYPb+dmD3HQCGZBD9v/ZkEP2tFmD3HUCGZBD9vPZg9nz2YP7/9m"
    . "D2fEZg9v42YPcdUIZkEP299mD3HUCGYPZ95mD9rZZg9n5WYP2uBmD3TLZg90xGZBD3TRZg/b0GYP29FmD9sVRQoAAGYPb8JmD2DHZg9vyGYPaNdmQQ9pxGZBD2HMZg/+wWYP"
    . "b8pmQQ9p1GZBD2HMZg/+0WYP/sJmRA/+6A+FVv7//0SLRCQUTo0UN2ZBD2/FZg9z2AhEi3wkEE6NDDNmQQ/+xWYPb8hmD3PZBGYP/sFmD37BQQ8SxWZED/7oQYnzRSnDQYP7"
    . "Bw+GKgIAAEnB4AJmQQ9vzmZBD2/GSo0MA2ZBD2/+SQH48w9+EWZBD2/eZkEPb/ZmRQ9v1vNED35hCEGD4/jzD35pEGYP28pmD3HSCEUp3/NED35ZGGZBD9vEZg9nyGZBD2/G"
    . "80UPfkgIZg/b/WZBD3HUCGYPcMkIZkEP28NmD2f480EPfgBmD3HVCPNBD35gEGZBD9vxZkEPZ9RmQQ9x0wjzRQ9+QBhmD9vYZg9n3mZBD2/2Zg/b9GYPcdAIZg9w0ghmQQ9n"
    . "62ZFD9vQZkEPcdEIZg9w7QhmQQ/b1mYPcdQIZkEP2+5mQQ9nwWYPZ9VmQQ9x0AhmD3DSCGYPcMAIZkEP28ZmQQ9n4GYPcOQIZkEP2+ZmD2fEZg9wwAhmD9rCZg9w/whmD2/n"
    . "Zg90wmYPb9FmD3DbCGZBD2fyZg9x1AhmD3D2CGYPb+5mQQ/b/mYPcdIIZkEP2/ZmQQ/bzmYPZ89mD2fUZg9v40nB4wJmD3HVCGYPcdQIZg9w0ghNAdpmD3DJCGYPZ+VmQQ/b"
    . "3mYPcOQITQHZZg9n3mYP2uJmD3DbCGYP2tlmD3TUZg/v7fMPfnwkCPMPfjUGCAAAZg90y2YP79tmD9vCZg/byGYP285mD2/RZg9gy2YPYNNmD3DJTmYPb9lmD2/BZg9vymYP"
    . "Yd1mD2HFZg9h1WYPYc1mD3DATmYPcNJOZg/+w2YP/tFmD/7CZkEP/sVmD2/IZg84AA2tBwAAZg/rz2YP/sFmD37BRQ+2WQJFOFoCRQ+2WQFBD5PARThaAUEPk8NFIcNFD7YB"
    . "RTgCQQ+TwEUPtsBFIdhEAcFBg/8BD4SfAQAARQ+2WQVFOFoFRQ+2WQZBD5PARThaBkEPk8NFIcNFD7ZBBEU4QgRBD5PARQ+2wEUh2EQBwUGD/wIPhGEBAABFD7ZZCkU4WgpF"
    . "D7ZZCUEPk8BFOFoJQQ+Tw0Uhw0UPtkEIRThCCEEPk8BFD7bARSHYRAHBQYP/Aw+EIwEAAEUPtlkORThaDkUPtlkNQQ+TwEU4Wg1BD5PDRSHDRQ+2QQxFOEIMQQ+TwEUPtsBF"
    . "IdhEAcFBg/8ED4TlAAAARQ+2WRJFOFoSRQ+2WRFBD5PARThaEUEPk8NFIcNFD7ZBEEU4QhBBD5PARQ+2wEUh2EQBwUGD/wUPhKcAAABFD7ZZFkU4WhZFD7ZZFUEPk8BFOFoV"
    . "QQ+Tw0Uhw0UPtkEURThCFEEPk8BFD7bARSHYRAHBQYP/BnRtRQ+2WRpFOFoaRQ+2WRlBD5PARThaGUEPk8NFIcNFD7ZBGEU4QhhBD5PARQ+2wEUh2EQBwUGD/wd0M0UPtnke"
    . "RTh6HkUPtnkdQQ+TwEU4eh1FD7Z5HEEPk8NFMclFIdhFOHocQQ+TwUUhwUQByUgBw0gBxynNSAHTRSnsdAlBOewPjb35//9Ii0wkIIXtD47WAAAASIPBBEg5TCQwD4KgAAAA"
    . "RItEJDxFhcAPhF/5//9MifBIicpBifZIi3wkUEQPtlQkKEiJxkyLRCQwi0wkYEyLpCSoAQAA6ZP4//9JidlJifpFie9mRQ/v7UUxwDHJ6WP7//9Ii1QkKEgB+kk50A+DgPj/"
    . "/0GJ7kgBfCRAg8EBSQH4OUwkZA+NM/j//zHJ61xJicHrBw8fQABMichNhckPhbMAAABMjQw4TTnIc+vrx0yJ8EiLfCRQQYn2i0wkYEiJxkQPtlQkKEyLRCQwTIukJKgBAADr"
    . "oEiLnCSoAQAASIXbdAiLRCQ4KeiJAw8QdCRwSInIDxC8JIAAAABEDxCEJJAAAABEDxCMJKAAAABEDxCUJLAAAABEDxCcJMAAAABEDxCkJNAAAABEDxCsJOAAAABEDxC0JPAA"
    . "AABEDxC8JAABAABIgcQYAQAAW15fXUFcQV1BXkFfw0yJyOnp9///kFZTSIPsaMdEJFwAAAAASI10JFxIicvrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQk"
    . "QA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOg+9f//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqE"
    . "yXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABTSIPscIuEJMAAAABIi5wk0AAAAGYPbowkuAAAAGZID27SZkgPbsGIRCRoZkEPbtlm"
    . "D2zCDxFEJDhmQQ9uwIuEJMgAAABmD2LDZg/WRCRI8w9+hCSgAAAATI1EJCDHRCQgAAAAAEiNFcT+//8PFoQkqAAAAEjHRCQoAAAAAA8RRCRQZg9uhCSwAAAASMdEJDAAAAAA"
    . "Zg9iwYlEJGxmD9ZEJGD/kbAAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDZpAxwEQLRCQ4RAtEJDBMi0wkKESLXCRQQQnQeDuLRCRIhcB+PUWF2344RItEJEhFMdIxwGYPH0QA"
    . "AEGLFIGJFIFIg8ABSTnAdfBBg8IBRTnTf9+4AQAAAMNmDx+EAAAAAAAxwMNmZi4PH4QAAAAAAGaQU0iD7HCLnCTIAAAAZg9unCTAAAAAZg9ulCSwAAAATIuUJKgAAABmQQ9u"
    . "yWZBD27AZkgPbupEi4wk0AAAAGZID27hQYnYZg9s5WYPbutmD2LdZg9urCS4AAAARQ+vwWYPYtVmD2zTZg9v2GYPYtlFhcB+TYuEJKAAAADHRCQgAAAAAEyNRCQgDxFkJChI"
    . "jRWd5///Zg/WXCQ4TIlUJEiJRCRADxFUJFBEiUwkYP+RsAAAALgBAAAASIPEcFvDDx8Ai4wksAAAAGYPfshmQQ9+wwuMJLgAAAAJwTHARAnZeNeF2340RYXJfi9FMduJ2WaQ"
    . "McBmDx9EAABFiwSCRIkEgkiDwAFIOch170GDwwFFOdl/3uueDx9AADHA65sPH0AAMcDDZmYuDx+EAAAAAABmkAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQYI"
    . "CQoMDQ6AgICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICAgICAgAABAgQFBggJCgwNDgMEAgMEBQYHCAkKCwwNDg8JCgIDBAUGBwgJCgsMDQ4PD4CAgICA"
    . "gICAgICAgICAgIAAAgMEBQYHCAkKCwwNDg8FBgIDBAUGBwgJCgsMDQ4PCwwCAwQFBgcICQoLDA0ODwECAgMEBQYHCAkKCwwNDg8HCAIDBAUGBwgJCgsMDQ4PDQ4CAwQFBgcI"
    . "CQoLDA0OD/8A/wD/AP8A/wD/AP8A/wABAQEBAQEBAQEBAQEBAQEBBAUGB4CAgICAgICAgICAgICAgIAAAQIDgICAgICAgIA="
    mcode_imgutil_column_uniform := 0x000070 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000190 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x000240 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x000b70 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x0016a0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_blit           := 0x001760 ; i32 imgutil_blit (argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_imgutil_blit_multi     := 0x0017d0 ; i32 imgutil_blit_multi (mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_get_blob_psabi_level   := 0x0018f0 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "imgutil_blit",              code + mcode_imgutil_blit
                    , "imgutil_blit_multi",        code + mcode_imgutil_blit_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    }

    ; -march=x86-64 baseline optimized machine code blob (mmx huh)
    i_get_mcode_map_v1() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3088 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "uAEAAADwD8EBOUFAD46uAAAAi1E0TGNBMAHCD69ROANBHA+vQSBIY9JMAcJMi0EoSJhNjQyQSGNRGEgB0EiLURBMjQSCi0E8g/gDfjxEjVD8McBFidNBwesCQY1TAUjB4gRm"
    . "Dx9EAADzQQ9vBAFBDxEEAEiDwBBIOcJ17EH320kB0UkB0EONBJqFwA+Eb////0GLEUGJEIP4AQ+EYP///0GLUQRBiVAEg/gCD4RP////QYtBCEGJQAjpQv///2aQw2ZmLg8f"
    . "hAAAAAAADx9AAFdWU4tcJEhEichIY/JIY1QkQEWJyA+2xEHB6BBBicKLRCRYD6/GSJhIAdBMjRyBi0QkUA+vxkiYSAHQSI0UgUw52nNsRQ+2wEUPttJFD7bJg/4BdBTraWYP"
    . "H4QAAAAAAEiDwgRMOdpzRw+2SgFEKdGJyPfYD0jBD7ZKAkQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteX8NmLg8fhAAAAAAAuAEAAABbXl/DDx+A"
    . "AAAAAEjB5gLrEmYuDx+EAAAAAABIAfJMOdpz2A+2SgJEKcGJyPfYD0jBD7ZKAUQp0YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9MwTnDfcExwOuPZmYuDx+EAAAAAABm"
    . "kFZTD69UJDiLXCRASGPSSInOSGNMJFBEichFicoPtsRBweoQSAHRTI0cjkhjTCRISAHKSI0Ulkw52nNdRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPCBEw52nM/D7ZKAkQp0YnI"
    . "99gPSMEPtkoBRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW17DDx8AuAEAAABbXsNED7ZUJChBacIAAQEARAnQDQAAAP9mD27gZg9w3ACD+gN+UUSN"
    . "WvxmD2/LMcBFidpBweoCQY1SAUjB4gQPH0AA8w9vBAFmD2/QZg/cwWYP2NFBDxEEAUEPERQASIPAEEg50HXcQffaSAHBSQHBSQHAQ40Uk4XSdF5mD24BZg9vyGYP3MNmD9jL"
    . "ZkEPfgFmQQ9+CIP6AXQ/Zg9uQQRmD2/IZg/cw2YP2MtmQQ9+QQRmQQ9+SASD+gJ0HWYPbkkIZg9vwWYP2MNmD9zZZkEPfkAIZkEPflkIMcDDDx+AAAAAAEFXQVZBVUFUVVdW"
    . "U0iD7FgPEXQkQIu8JMgAAACLnCTYAAAASIuEJOgAAACJ/k2Jz0SLjCTQAAAASYnKSGPKD77TQQ+v8Q+v1ol0JDBIi7QkwAAAAExj2sH6H01p2x+F61FJwfslQSnTgPtkugEA"
    . "AAAPRZQk4AAAAESJXCQsRQ+2XwFBidZBD7ZXAkHB4wjB4hBECdpFD7YfRAnaRA+2XgFmD27SD7ZWAkHB4whmD3DSAMHiEEQJ2kQPth5ECdqBygAAAP9FKchmD27KRIlEJDxm"
    . "D3DJAA+IngAAAIt0JDBIY9dIic2LXCQsSCnVSMHhAmYPdtvHRCQ4AAAAAEjB5QI53kiJhCToAAAAQQ+dwIX2D5XCQSHQRIhEJDdEjUf8RInCweoCRI1aAffaRY0kkEnB4wRJ"
    . "ichIielMidJMAdFyJEyJ0EWF9nQK6VMBAABmkEiJ0EiF0g+FsgEAAEqNFABIOdFz64NEJDgBi0wkPE0BwotEJDg5yH69MdLp0AIAAE0B2k0B2UwB20SJ4IXAD4S5AAAAZkEP"
    . "bilmD24zZkEPbiJmD2/FZg/e5WYP3sZmD3TlZg90xmYP28RmD3bDZg/X0IPiAUEB0IP4AXRzZkEPbmkEZg9ucwRmQQ9uYgRmD2/FZg/e5WYP3sZmD3TlZg90xmYP28RmD3bD"
    . "Zg/X0IPiAUEB0IP4AnQ3Zg9uYwhmQQ9uQQhmQQ9uaghmD2/0Zg/e6GYP3vBmD3TFZg905mYP28RmD3bDZg/X0IPiAUEB0EjB4AJJAcJIAcNJAcFIi0QkCEQpxkkBwUEp/XQJ"
    . "RDnuD47qAAAASItUJBCF9g+OyAEAAEiLRCQYSIPCBEg50A+C5AEAAEWF9g+ElQAAAEiLbCQITItEJCBNifpJic9IicFIidNIichIidpIKdhIwfgCg8ABg/gDfxfpJAEAAGaQ"
    . "g+gESIPCEIP4Aw+OEgEAAPMPbwJmD2/qZg9v4WYP3uBmD97oZg90xWYPdOFmD9vEZg92w2ZED9fIRYXJdMLzRQ+8yUHB+QJJY8FIjRSCSIlsJAhMiUQkIEiJTCQYTIn5TYnX"
    . "gHwkNwCLdCQsD4Q5////SIlUJBBEi2wkMEmJ0UmJykiLnCTAAAAAi3QkLGaQMdJFMcCJ+IP/Aw+OLP7///NBD28EEfNBD280EvMPbywT8w9vJBNIg8IQZg/e8GYP3uhmD3TG"
    . "Zg905WYP28RmD3bDZg/XwInF0e2B5VVVVVUp6InFwegCgeUzMzMzJTMzMzMB6InFwe0EAcWB5Q8PDw+J6MHoCAHoicXB7RAB6MHoAoPgD0EBwEw52nWD6Z79//+FwHRETI0M"
    . "gusNDx9AAEiDwgRMOcp0MWYPbgJmD2/qZg9v4WYP3uBmD97oZg90xWYPdOFmD9vEZg92w2YP18CoAXTL6eT+//9MAcNIOdkPg27+///pKv3//0iLhCToAAAASIXAdAiLTCQs"
    . "KfGJCA8QdCRASInQSIPEWFteX11BXEFdQV5BX8NNifpIi2wkCEyLRCQgSYnP6ef8//9mkFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/C"
    . "SJhIjQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOge+///SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAA"
    . "Zg8fRAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlU"
    . "JEBIjRUC////SIlEJFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRki4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwk"
    . "TIlEJGz/kbAAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAAEFWQVRVV1ZTMcBEC0QkaEQLRCRgTItMJFiLXCR4i7wkgAAAAEEJ0A+IkgAAAIXbD46bAAAAhf8PjpMA"
    . "AABEjUP8RTHSRInAwegCjVAB99hIweIEQY00gE2NJBFIjSwRkEGJ20mJyEyJyIP7A34iMcDzQQ9vBAEPEQQBSIPAEEg5wnXthfZ0WUGJ80mJ6EyJ4ESLMEWJMEGD+wF0FUSL"
    . "cARFiXAEQYP7AnQHi0AIQYlACEGDwgFEOdd/prgBAAAAW15fXUFcQV7DDx+EAAAAAAAxwFteX11BXEFeww8fRAAAQYPCAUQ513+F688PH0QAAEFWQVRVV1ZTSIPseESLlCT4"
    . "AAAARIucJAABAABmD26MJPAAAABmD26EJOAAAABEidNmQQ9u2mYPbqQk6AAAAEEPr9tmD2LLZg9ixEiJyEiLjCTYAAAAZg9swYXbfmJIiVQkMIuUJNAAAABEiUQkOEyNRCQg"
    . "iVQkQEiNFSH1//9IiUwkSEiJwcdEJCAAAAAASIlEJChEiUwkPESJXCRgDxFEJFD/kLAAAABBuQEAAABEichIg8R4W15fXUFcQV7DkIuEJOAAAAALhCToAAAARAnIRTHJRAnA"
    . "eNZFhdIPjrYAAABFhdsPjq0AAABFjUr8MdtEidZEicjB6AJEjUAB99hJweAEQY08gUmJ0UiJyE6NJAFKjSwCQYP6A34qDx9AADHAZg8fRAAA8w9vFAEPERQCSIPAEEw5wHXu"
    . "hf90Son+SYnpTIngRIswRYkxg/4BdBREi3AERYlxBIP+AnQHi0AIQYlBCIPDAUE52w+OOP///0SJ1kmJ0UiJyEGD+gN/oOvEZg8fRAAAg8MBQTnbf5DpFP///w8fAEUxyekP"
    . "////uAEAAADDkJCQkJCQkJCQkA=="
    mcode_imgutil_column_uniform := 0x0000d0 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x0001f0 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x000290 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x000370 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x0008c0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_blit           := 0x000970 ; i32 imgutil_blit (argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_imgutil_blit_multi     := 0x000a60 ; i32 imgutil_blit_multi (mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_get_blob_psabi_level   := 0x000c00 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                   
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "imgutil_blit",              code + mcode_imgutil_blit
                    , "imgutil_blit_multi",        code + mcode_imgutil_blit_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    }

    ; -march=x86-64-v2 optimized SSE4 machine code blob
    i_get_mcode_map_v2() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3056 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "uAEAAADwD8EBOUFAD46uAAAAi1E0TGNBMAHCD69ROANBHA+vQSBIY9JMAcJMi0EoSJhNjQyQSGNRGEgB0EiLURBMjQSCi0E8g/gDfjxEjVD8McBFidNBwesCQY1TAUjB4gRm"
    . "Dx9EAADzQQ9vBAFBDxEEAEiDwBBIOcJ17EH320kB0UkB0EONBJqFwA+Eb////0GLEUGJEIP4AQ+EYP///0GLUQRBiVAEg/gCD4RP////QYtBCEGJQAjpQv///2aQw2ZmLg8f"
    . "hAAAAAAADx9AAFdWU4tcJEhEichIY/JIY1QkQEWJyA+2xEHB6BBBicKLRCRYD6/GSJhIAdBMjRyBi0QkUA+vxkiYSAHQSI0UgUw52nNsRQ+2wEUPttJFD7bJg/4BdBTraWYP"
    . "H4QAAAAAAEiDwgRMOdpzRw+2SgFEKdGJyPfYD0jBD7ZKAkQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteX8NmLg8fhAAAAAAAuAEAAABbXl/DDx+A"
    . "AAAAAEjB5gLrEmYuDx+EAAAAAABIAfJMOdpz2A+2SgJEKcGJyPfYD0jBD7ZKAUQp0YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9MwTnDfcExwOuPZmYuDx+EAAAAAABm"
    . "kFZTD69UJDiLXCRASGPSSInOSGNMJFBEichFicoPtsRBweoQSAHRTI0cjkhjTCRISAHKSI0Ulkw52nNdRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPCBEw52nM/D7ZKAkQp0YnI"
    . "99gPSMEPtkoBRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW17DDx8AuAEAAABbXsNED7ZUJChBacIAAQEARAnQDQAAAP9mD27gZg9w3ACD+gN+UUSN"
    . "WvxmD2/LMcBFidpBweoCQY1SAUjB4gQPH0AA8w9vBAFmD2/QZg/cwWYP2NFBDxEEAUEPERQASIPAEEg50HXcQffaSAHBSQHBSQHAQ40Uk4XSdF5mD24BZg9vyGYP3MNmD9jL"
    . "ZkEPfgFmQQ9+CIP6AXQ/Zg9uQQRmD2/IZg/cw2YP2MtmQQ9+QQRmQQ9+SASD+gJ0HWYPbkkIZg9vwWYP2MNmD9zZZkEPfkAIZkEPflkIMcDDDx+AAAAAAEFXQVZBVUFUVVdW"
    . "U0iD7FgPEXQkQIu8JMgAAACLnCTYAAAAif5Nic9Ei4wk0AAAAEiJyA++y0GJ0kiLlCToAAAAQQ+v8Q+vzol0JDBIi7QkwAAAAExj2cH5H01p2x+F61FJwfslQSnLgPtkuQEA"
    . "AAAPRYwk4AAAAESJXCQsRQ+2XwFBic5BD7ZPAkHB4wjB4RBECdlFD7YfRAnZRA+2XgFmD27RD7ZOAkHB4whmD3DSAMHhEEQJ2UQPth5ECdmByQAAAP9FKchmD27JRIlEJDxm"
    . "D3DJAA+ImgAAAEljyot0JDBMY8eLXCQsSInNSMHhAkmJwmYPdttMKcXHRCQ4AAAAAEmJ1UjB5QI53kEPncGF9kEPlcBFIcFEjUf8RInARIhMJDdFifHB6AJEjVgB99hJweME"
    . "RY0kgEiJ6kyJ0EwB0nIeTYnQRYXJdAjpKgIAAEmJwEiFwHV0SY0ECEg5wnPvg0QkOAGLdCQ8SQHKi0QkODnwfsMxwOnEAgAADx9AAEWFwA+EhgIAAEqNHIDrDpBIg8AESDnY"
    . "D4RyAgAAZg9uAGYPb+pmD2/hZg/e4GYP3uhmD3TFZg904WYP28RmD3bDZkQP18BBg+ABdMRIiUwkGE2J6EiJVCQQTIlUJCCAfCQ3AIt0JCwPhF0BAABIiUQkCESLdCQwSYnC"
    . "TIn7TIusJMAAAACLdCQsDx+AAAAAADHAMcmD/wMPjusBAAAPHwDzQQ9vBALzD280A/NBD29sBQDzQQ9vZAUASIPAEGYP3vBmD97oZg90xmYPdOVmD9vEZg92w2YP19DzD7jS"
    . "wfoCAdFMOdh1uUwB200B2k0B3USJ4IXAD4S3AAAAZkEPbipmQQ9udQBmD24jZg9vxWYP3uVmD97GZg905WYPdMZmD9vEZg92w2YP19CD4gEB0YP4AXRxZkEPbmoEZkEPbnUE"
    . "Zg9uYwRmD2/FZg/e5WYP3sZmD3TlZg90xmYP28RmD3bDZg/X0IPiAQHRg/gCdDZmQQ9uZQhmQQ9uQghmD25rCGYPb/RmD97oZg/e8GYPdMVmD3TmZg/bxGYPdsNmD9fQg+IB"
    . "AdFIweACSAHDSQHFSQHCKc5JAepBKf50CUQ59g+Oy/7//0iLRCQIhfYPjuAAAABIi1QkEEiDwARIOcIPgrwAAABFhckPhHH+//9Ii0wkGEyLVCQgTYnFSInGSYnQSInwSSnw"
    . "ScH4AkGDwAFBg/gDfx7p5/3//w8fgAAAAABBg+gESIPAEEGD+AMPjs79///zD28AZg9v6mYPb+FmD97gZg/e6GYPdMVmD3ThZg/bxGYPdsNmD9fYhdt0wvMPvNtIiUwkGMH7"
    . "AkiJVCQQTGPDTIlUJCBKjQSATYno6dv9//8PH0QAAIn46WT+//9IAc5IOfIPg2L////pQf3//0iLTCQYTItUJCBNicXpL/3//02FwHQJi0wkLCnxQYkIDxB0JEBIg8RYW15f"
    . "XUFcQV1BXkFfw2YuDx+EAAAAAABWU0iD7GjHRCRcAAAAAEiJy0iNdCRc608PH4QAAAAAAItTKEiLSyBIiXQkSA+vwkiYSI0MgYtDTIlEJEAPvkNIRIlEJDCJRCQ4i0NAiUQk"
    . "KEiLQzhIiUQkIEyLSzDoPvv//0iFwHUhuAEAAADwD8EDRItDRItTLEQpwjnCfaJIg8RoW17DDx8ASI1TFEG4AQAAAGYPH0QAAESJwYYKhMl190SLRCRcRDlDEH0IRIlDEEiJ"
    . "QwiGCotDQA+vQ0Q7RCRcf6SLQyyHA+udZg8fRAAAU0iD7HBIi4QkoAAAAEiLnCTQAAAASIlEJFBIi4QkqAAAAEiJVCRASI0VAv///0iJRCRYi4QksAAAAESJRCRITI1EJCCJ"
    . "RCRgi4QkuAAAAMdEJCAAAAAAiUQkZIuEJMAAAABIx0QkKAAAAACIRCRoi4QkyAAAAEjHRCQwAAAAAEiJTCQ4RIlMJEyJRCRs/5GwAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBb"
    . "ww8fgAAAAABBVkFUVVdWUzHARAtEJGhEC0QkYEyLTCRYi1wkeIu8JIAAAABBCdAPiJIAAACF2w+OmwAAAIX/D46TAAAARI1D/EUx0kSJwMHoAo1QAffYSMHiBEGNNIBNjSQR"
    . "SI0sEZBBidtJichMiciD+wN+IjHA80EPbwQBDxEEAUiDwBBIOcJ17YX2dFlBifNJiehMieBEizBFiTBBg/sBdBVEi3AERYlwBEGD+wJ0B4tACEGJQAhBg8IBRDnXf6a4AQAA"
    . "AFteX11BXEFeww8fhAAAAAAAMcBbXl9dQVxBXsMPH0QAAEGDwgFEOdcPj4H////ry5BBVkFUVVdWU0iD7HhEi5Qk+AAAAESLnCQAAQAAZg9ujCTwAAAAZg9uhCTgAAAAZg86"
    . "IoQk6AAAAAFEidNBD6/bZkEPOiLKAUiJyGYPbMFIi4wk2AAAAIXbfmZIiVQkMIuUJNAAAABEiUQkOEyNRCQgiVQkQEiNFUX1//9IiUwkSEiJwcdEJCAAAAAASIlEJChEiUwk"
    . "PESJXCRgDxFEJFD/kLAAAABBuQEAAABEichIg8R4W15fXUFcQV7DDx9EAACLhCTgAAAAC4Qk6AAAAEQJyEUxyUQJwHjSRYXSD462AAAARYXbD46tAAAARY1K/DHbRInWRInI"
    . "wegCRI1AAffYScHgBEGNPIFJidFIichOjSQBSo0sAkGD+gN+Kg8fQAAxwGYPH0QAAPMPbxQBDxEUAkiDwBBMOcB17oX/dEqJ/kmJ6UyJ4ESLMEWJMYP+AXQURItwBEWJcQSD"
    . "/gJ0B4tACEGJQQiDwwFBOdsPjjT///9EidZJidFIichBg/oDf6DrxGYPH0QAAIPDAUE523+Q6RD///8PHwBFMcnpC////7gCAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x0000d0 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x0001f0 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x000290 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x000370 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x0008a0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_blit           := 0x000950 ; i32 imgutil_blit (argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_imgutil_blit_multi     := 0x000a40 ; i32 imgutil_blit_multi (mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_get_blob_psabi_level   := 0x000be0 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
    
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "imgutil_blit",              code + mcode_imgutil_blit
                    , "imgutil_blit_multi",        code + mcode_imgutil_blit_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    }

    ; -march=x86-64-v3 optimized AVX2 machine code blob
    i_get_mcode_map_v3() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3536 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "SYnJDx9EAAC4AQAAAPBBD8EBQTlBQA+OzAAAAEGLUTRJY0kwAcJBD69ROEEDQRxBD69BIEhj0kgBykmLSShImEiNDJFJY1EYSAHQSYtREEiNFIJBi0E8g/gHfjxEjVD4McBF"
    . "idNBwesDRY1DAUnB4AUPH4AAAAAAxf5vBAHF/n8EAkiDwCBJOcB17UH320wBwUwBwkONBNqD+AN+FMX6bwlIg8IQSIPBEIPoBMX6f0rwhcAPhE////9EiwFEiQKD+AEPhED/"
    . "//9Ei0EERIlCBIP4Ag+EL////4tBCIlCCOkk////Dx9AAMX4d8MPH0AAV1ZTi1wkSESJyEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhI"
    . "AdBIjRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPCBEw52nNHD7ZKAUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zB"
    . "OcN9wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusSZi4PH4QAAAAAAEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJ"
    . "ic/33w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItcJEBIY9JIic5IY0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2"
    . "wEUPtsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0QPtlQk"
    . "KEFpwgABAQBECdANAAAA/8X5btDE4n1Y0oP6B35Pg+oIxf1vyjHAQYnTQcHrA0WNUwFJweIFDx9EAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQBSIPAIEw50HXeQffbSAHB"
    . "SQHBSQHAQo0U2sX5b8KD+gN+J8X6byFJg8EQSIPBEEmDwBCD6gTF2djKxMF6f0jwxenczMTBen9J8IXSdFLF+W4JxfHY0MX53MnEwXl+EMTBeX4Jg/oBdDfF+W5JBMXx2NDF"
    . "+dzJxMF5flAExMF5fkkEg/oCdBnF+W5RCMXp2MjF+dzCxMF5fkgIxMF5fkEIMcDF+HfDZpBBV0FWQVVBVFVXVlNIgey4AAAAxfgRdCRAxfgRfCRQxXgRRCRgxXgRTCRwxXgR"
    . "lCSAAAAAxXgRnCSQAAAAxXgRpCSgAAAAi7wkKAEAAESLnCQwAQAAi7QkOAEAAIn4QQ+vw0xj0kAPvtZNic9Mi4wkSAEAAA+v0Ehj2sH6H0hp2x+F61FIwfslKdNAgP5kugEA"
    . "AAAPRZQkQAEAAIlcJChBD7ZfAYnVQQ+2VwLB4wjB4hAJ2kEPth8J2kiLnCQgAQAAxXluwg+2UwIPtlsBxEJ9WMDB4wjB4hAJ2kiLnCQgAQAAD7YbCdpEicOBygAAAP/F+W76"
    . "xOJ9WP9EKdsPiBYEAABIY9dNidSLdCQoiVwkPEkp1MXtdtLF8XbJQYnuScHkAjnwxXl/xUyJzUqNFJUAAAAAQQ+dwoXAQQ+VwMV5f8ZFIcJEiFQkL0SNV/hFidBBwegDRY1Y"
    . "AUH32EeNLMJJweMFRTHATInjxflv38X5b+dJicpIAcsPgocDAABIiUwkMEiJ6USJ9USJRCQ46xZNhdIPhQcDAABNjRQRTDnTD4JPAwAATYnRhe1040mJ2U0p0UnB+QJBg8EB"
    . "QYP5Bw+OUwIAAMRBfW/YxX1v102J0OsYZg8fRAAAQYPpCEmDwCBBg/kHD44wAgAAxMF+bwDFLd7IxSXe4MWddMDEQTV0ysW128DF/XbCxf3X8IX2dMjzD7z2SIlUJCBIiYwk"
    . "SAEAAIPmPE2NFDCAfCQvAIt0JCgPhKQBAACJRCQMi3QkKEyJ0kyJ+UiJXCQQTIuEJCABAABBicZMiVQkGGYPH0QAADHARTHSQYn5g/8HfkoPHwDF/m8EAsRBfd4MAMV93hQB"
    . "xEE1dAwASIPAIMWtdMDFtdvAxf12wsV918jzRQ+4yUHB+QJFAcpMOdh1xUwB2U0B2EwB2kWJ6UGD+QMPjk8BAADF+m8CQYPpBEiDwRBJg8AQxEF53kjwxXneUfBIg8IQxEEx"
    . "dEjwxal0wMWx28DF+XbBxfnXwPMPuMDB+AJFhckPhLEAAADFeW4SxEF5bhjFeW4JxEEp3snEwSnew8WhdMDEQTF0ysWx28DF+XbBxfnX2IPjAQHYQYP5AXRtxXluUgTEQXlu"
    . "WATFeW5JBMRBKd7JxMEp3sPFoXTAxEExdMrFsdvAxfl2wcX519iD4wEB2EGD+QJ0M8X5bkIIxEF5bkgIxXluUQjFMd7YxEF53tLFqXTAxEExdMvFsdvAxfl2wcX519iD4wEB"
    . "2EnB4QJMAclNAchMAcpEAdBMAeIpxkEp/nQJRDn2D46T/v//i0QkDEiLXCQQTItUJBiF9g+ObQEAAEmDwgRMOdMPgi0BAACF7Q+EMP7//0iLVCQgSIuMJEgBAADpov3//2YP"
    . "H0QAADHA6eb+//9NidBBg/kDfi7EwXpvAMVh3sjFed7Vxal0wMRBYXTJxbHbwMX5dsHF+dfwhfZ1ckmDwBBBg+kERYXJD4SRAAAAS400iOsMDx8ASYPABEk58HR0xMF5bgDF"
    . "Wd7IxUne0MWpdMDFMXTMxbHbwMX5dsHFedfIQYPhAXTQTYnRTYnCTYXSD4T5/P//SIlUJCBIiYwkSAEAAOl3/f//Dx+AAAAAAGbzRA+8zkiJVCQgZkHB6QJIiYwkSAEAAEUP"
    . "t8lPjRSI6Uv9//9FMcBNidFNicLrrkkB0kw50w+DuPz//0GJ7kSLRCQ4SInNSItMJDCLXCQ8QYPAAUgB0UE52A+OTvz//0Ux0utJRItEJDhIi1QkIEGJ7kiLTCQwi1wkPEGD"
    . "wAFIi6wkSAEAAEgB0UE52A+OG/z//+vLDx8ATIuMJEgBAABNhcl0CYtEJCgp8EGJAcX4d8X4EHQkQMX4EHwkUEyJ0MV4EEQkYMV4EEwkcMV4EJQkgAAAAMV4EJwkkAAAAMV4"
    . "EKQkoAAAAEiBxLgAAABbXl9dQVxBXUFeQV/DZmYuDx+EAAAAAABmkFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQk"
    . "QA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOje+f//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqE"
    . "yXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBIjRUC////SIlE"
    . "JFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRki4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlEJGz/kbAAAABI"
    . "hdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAAEFWQVRVV1ZTMcBEC0QkaEQLRCRgTItMJFiLXCR4i7QkgAAAAEEJ0A+ItwAAAIXbD467AAAAhfYPjrMAAABEjUP4RTHbRInA"
    . "wegDjVAB99hIweIFQY08wE2NJBFIjSwRkDHAg/sHD46VAAAADx9EAADEwX5vBAHF/n8EAUiDwCBIOcJ17EGJ+oP/Aw+OgAAAAEiJ6E2J4MTBem8ISIPAEEmDwBBBg+oExfp/"
    . "SPBFhdJ0IkWLMESJMEGD+gF0FkWLcAREiXAEQYP6AnQIRYtACESJQAhBg8MBRDnef4S4AQAAAMX4d1teX11BXEFeww8fADHAW15fXUFcQV7DDx9EAABBidpIichNiciD+wN/"
    . "iOuhTYngSIno65QPH4QAAAAAAEFWQVRVV1ZTSIPseESLlCT4AAAARIucJAABAADF+W6cJPAAAADF+W6kJOAAAADE41kihCToAAAAAUSJ00EPr9vEw2EiygFIicjF+WzBSIuM"
    . "JNgAAACF235nSIlUJDCLlCTQAAAARIlEJDhMjUQkIIlUJEBIjRV28///SIlMJEhIicHHRCQgAAAAAEiJRCQoRIlMJDxEiVwkYMX6f0QkUP+QsAAAAEG5AQAAAESJyEiDxHhb"
    . "Xl9dQVxBXsMPH0QAAMX5fuALhCToAAAARAnIRTHJRAnAeNVFhdIPjskAAABFhdsPjsAAAABFjUr4MfZEicjB6ANEjUAB99hJweAFQY08wU6NJAFKjSwCZg8fRAAAMcBBg/oH"
    . "fngPH4QAAAAAAMX+bxQBxf5/FAJIg8AgSTnAde2J+02J4UiJ6IP/A34VxMF6bylIg8AQSYPBEIPrBMX6f2jwhdt0IEWLMUSJMIP7AXQVRYtxBESJcASD+wJ0CEWLSQhEiUgI"
    . "g8YBQTnzf4/F+HfpHP///w8fgAAAAABEidNJiclIidBBg/oDf6HruA8fgAAAAABFMcnp+/7//7gDAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x0000f0 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000210 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x0002b0 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x0003b0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x000a40 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_blit           := 0x000af0 ; i32 imgutil_blit (argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_imgutil_blit_multi     := 0x000c10 ; i32 imgutil_blit_multi (mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h);
    mcode_get_blob_psabi_level   := 0x000dc0 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform  
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "imgutil_blit",              code + mcode_imgutil_blit
                    , "imgutil_blit_multi",        code + mcode_imgutil_blit_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    } 

    ; -march=x86-64-v4 optimized AVX512 machine code blob
    i_get_mcode_map_v4() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3056 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "U0G7AQAAAGYPH4QAAAAAALgBAAAA8A/BATlBQA+OmAAAAItRNExjQTABwg+vUTgDQRwPr0EgSGPSTAHCTItBKEiYTY0MkEhjURhIAdBIi1EQTI0EgotRPIP6D344RI1S8DHA"
    . "RInTwesEjVMBSMHiBmLR/khvDAFi0f5IfwwASIPAQEg50HXpweMERInSSQHASQHBKdqF0g+Ec////8TCaffTjUL/xfiSyGLRfslvAWLRfkl/AOlW////xfh3W8OQV1ZTRItU"
    . "JEhMY8KLVCRYRInIRYnLTGNMJEAPttxBwesQQQ+v0Ehj0kwBykiNNJGLVCRQQQ+v0Ehj0kwBykiNFJFIOfJzakUPttsPtttED7bIQYP4AXQS62cPH4AAAAAASIPCBEg58nNH"
    . "D7ZKASnZicj32A9IwQ+2SgJEKdlBichB99hBD0nIOcgPTMEPtgpEKclBichB99hBD0nIOcgPTMFBOcJ9ujHAW15fww8fQAC4AQAAAFteX8MPH4AAAAAAScHgAusSZi4PH4QA"
    . "AAAAAEwBwkg58nPYD7ZKAkQp2YnI99gPSMEPtkoBKdmJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTMFBOcJ9wTHA65VmZi4PH4QAAAAAAGaQVlMPr1QkOExjRCRQRItU"
    . "JEBIY9JJAdBEichEictKjTSBTGNEJEgPtsTB6xBMAcJIjRSRSDnyc2APtttED7bYRQ+2yesMDx8ASIPCBEg58nNHD7ZKAinZicj32A9IwQ+2SgFEKdlBichB99hBD0nIOcgP"
    . "TMEPtgpEKclBichB99hBD0nIOcgPTMFBOcJ9ujHAW17DDx9EAAC4AQAAAFtew0QPtlQkKEFpwgABAQBECdANAAAA/2LyfUh80IP6D35ag+oQYvH9SG/KMcBBidNBwesERY1T"
    . "AUnB4gZmDx9EAABi8X9IbxwBYvFlSNjBYtH+SH8EAGLxdUjcw2LR/kh/BAFIg8BATDnQddZBweMESAHBSQHBSQHARCnahdJ0L7gBAAAAxOJp98CD6AHF+JLIYvF+yW8BYvF9"
    . "SNjKYvF9SNzCYtF+SX8IYtF+SX8BMcDF+HfDZmYuDx+EAAAAAABmkEFXQVZBVUFUVVdWU0iD7DiLvCSoAAAARIucJLgAAABMi7wkyAAAAIn7TImMJJgAAACJ1kEPvtNEi4wk"
    . "sAAAAEiJyLkBAAAAQQ+v2Q+v04lcJBhIi5wkmAAAAExj0sH6H01p0h+F61FJwfolQSnSD7ZTAkGA+2QPRYwkwAAAAESJVCQURA+2UwHB4hBBweIIRAnSRA+2E0iLnCSgAAAA"
    . "RAnSRA+2UwFi8n1IfOoPtlMCQcHiCMHiEEQJ0kQPthNEicNECdKBygAAAP9i8n1IfOJEKcsPiDQDAABMY8ZIY9eLdCQURI1n8EyJxUmJwUSJ4EGJ3kgp1YtUJBhOjSyFAAAA"
    . "AGLzdUglyf9IweUCOfJBD53AhdIPlcLB6ARFMdJEjVgBweAEQSHQQSnERInCScHjBk2JyESJZCQsQYnRSInqTInAYvH9SG/dTAHCD4KrAgAATIlsJAhNicRFidVJidBFicqL"
    . "VCQsTIn76yEPH0AASYnHSIXAD4WFAAAASItEJAhMAfhJOcAPgoQCAACFyXTfYvH9SG/UTYnBSInGSSnBScH5AkGDwQFBg/kPfxzp0AEAAA8fRAAAQYPpEEiDxkBBg/kPD465"
    . "AQAAYvF/SG8GYvN9SD7LBWLzfUk+ygJi8n5IKMFi831IH8EAxfiYwHTHxfiTwGbzD7zAD7fASI0EhkyJBCRJicFEiWwkHESJdCQoTIlkJCBIiZwkyAAAAInLi0QkFEWE0g+E"
    . "/gAAAItEJBSLdCQYTYnNTYnMTIu8JKAAAABMi7QkmAAAAEGJ0YnCifAPH0QAADHJMfZMY8eD/w9+Sg8fQABi0X9Ib1QNAGLTbUg+DA4FYtNtST4MDwJIg8FAYvJ+SCjBYvN9"
    . "SB/ZAMV4k8PzRQ+4wEQBxkk5y3XGTQHeTQHfTQHdTWPBRYXAD4S5AAAAuQEAAAAp+MTiOffJg+kBScHgAsX7ksli0X7Jb0UAYsF+yW8OTQHGYtF+yW8XTQHHSQHoYrN9SD7R"
    . "BU0BxWLzfUo+0gJi8n5IKMJi831JH+EAxfiTzGbzD7jJD7fJAfEpyjnCfwiFwA+FNP///4nQRInKTYnhhcAPjjwBAABJg8EETDkMJA+C9gAAAIXbD4TX/v//idlMiwQkRIts"
    . "JBxMichEi3QkKEyLZCQgSIucJMgAAADpIv7//5Ap8kkB7Sn4dKs5wg+O1/7//+uhRYXJdFVBvwEAAADEQjH3z0GD6QHEwXiSyWLhfslvBmLzfUA+1QVi831CPsQCYuJ+SCjA"
    . "YvN9QR/JAMX4mMl0GsV4k8lm80UPvMlJicdFD7fJSo0EjumW/f//SIt0JAhIAfBJOcAPg6n9//9FidFNieBFiepJid9JifVBg8IBTQHoRTnyD44w/f//McDrekWJ0UWJ6kyL"
    . "bCQITYngQYPCAUmJ300B6EU58g+OC/3//+vZDx9AAEWJ0USLVCQcTItsJAiJ2UyLRCQgRIt0JChBg8IBTIu8JMgAAABNAehFOfIPjtT8///rog8fRAAATIu8JMgAAACJxkyJ"
    . "yE2F/3QJi1QkFCnyQYkXxfh3SIPEOFteX11BXEFdQV5BX8OQVlNIg+xox0QkXAAAAABIictIjXQkXOtPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75D"
    . "SESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6P76//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdE"
    . "i0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwSIuEJKAAAABIi5wk0AAAAEiJRCRQSIuEJKgAAABIiVQkQEiNFQL///9IiUQkWIuE"
    . "JLAAAABEiUQkSEyNRCQgiUQkYIuEJLgAAADHRCQgAAAAAIlEJGSLhCTAAAAASMdEJCgAAAAAiEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+R0AAAAEiF23QG"
    . "i0QkMIkDSItEJChIg8RwW8MPH4AAAAAAQVVBVFVXVlMxwEQLRCRoRAtEJGBEi1wkeIucJIAAAABBidFIi1QkWEUJyA+IpAAAAEWF2w+OpgAAAIXbD46eAAAARY1T8EUxyb8B"
    . "AAAARInQwegERI1AAcHgBEnB4AZBKcJOjSQCSo0sAesvDx9AAESJ2EiJzkmJ1cTieffHg+gBQYPBAcX4kshi0X7Jb0UAYvF+SX8GRDnLfjJBg/sPfs8xwA8fRAAAYvH+SG8M"
    . "AmLx/kh/DAFIg8BASTnAdelFhdJ1LEGDwQFEOct/1LgBAAAAxfh3W15fXUFcQV3DZpAxwFteX11BXEFdww8fRAAARInQSInuTYnl6Xv///9mkEFVQVRVV1ZTSIPseESLnCT4"
    . "AAAAi5wkAAEAAMX5bpQk8AAAAEyLlCTYAAAAxflunCTgAAAARInYxONhIoQk6AAAAAEPr8PEw2kiywHF+WzBhcB+XIuEJNAAAABIiVQkMEiNFTn1//9EiUQkOEyNRCQgx0Qk"
    . "IAAAAABIiUwkKESJTCQ8iUQkQEyJVCRIiVwkYMX6f0QkUP+R0AAAALkBAAAAichIg8R4W15fXUFcQV3Dxfl+2AuEJOgAAAAxyUQJyEQJwHjcRYXbD46qAAAAhdsPjqIAAABF"
    . "jUvwRTHAvwEAAABEicjB6ASNSAHB4ARIweEGQSnBTY0kCkiNLArrLJBIidZNidVEidjE4nn3x4PoAUGDwAHF+JLIYtF+yW9FAGLxfkl/BkQ5w34yQYP7D37PMcAPH0QAAGLR"
    . "/khvJAJi8f5IfyQCSIPAQEg5wXXpRYXJdRRBg8ABRDnDf9TF+HfpN////w8fAEiJ7k2J5USJyOuWDx9EAAAxyeki////kLgEAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x0000c0 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0001e0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000280 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000340 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0008b0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000960 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000a60 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000be0 ; u32 get_blob_psabi_level()
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                                                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "imgutil_blit",              code + mcode_imgutil_blit
                    , "imgutil_blit_multi",        code + mcode_imgutil_blit_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                    )
    }

    i_get_mcode_map_base() {
        ; this can't be part of the main blob as we don't want GCC to taint it with
        ; vectorization or the use of other instructions that may not be available
        ; on older CPUs
        static b64 := ""
    . "" ; imgutil_lib.c
    . "" ; 2720 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "U0iD7CBIicvrPGYPH0QAAEiLA0iLiMAAAAD/kLgAAABIiwOLSwhIi5CoAAAASIsMyv9QaEiLA7r/////SIuImAAAAP9QWEiLA/CDgMgAAAABRTHAQbn/////uQIAAABIiwNI"
    . "jZCIAAAA/5CAAAAAhcB0nTHASIPEIFvDDx9EAABXVlNIg+wgMf9IictIhcl1D4n4SIPEIFteX8MPH0QAAEiHkbgAAABMh4HAAAAASIuJiAAAAP9TaEiLk6gAAACLi8wAAABB"
    . "uf////9BuAEAAAD/k4AAAABIi4uIAAAASI2zyAAAAP9TcIc+SIuLmAAAAP9TaIuDzAAAAIXAdAxmkIsGO4PMAAAAcvZIi4uYAAAAvwEAAAD/U3CJ+EiDxCBbXl/DZmYuDx+E"
    . "AAAAAABmkEFVQVRVV1ZTSIPsGEUxyZycZ4E0JAAAIACdnFhnMwQknSUAACAAhcAPhIEAAABMjRVbBwAARInIRInJMf8PokmNqtABAABBicREicm4AAAAgA+iQYnFQYtCDEWL"
    . "AkE5wUQPQshBgfgAAACAdlNFOcVyWEQ7BecIAABFi1oISWNyBHQdRInAiflEiQXRCAAAD6KJBCSJXCQEiUwkCIlUJAxEIxy0dCRJg8IQSTnqdadEichIg8QYW15fXUFcQV3D"
    . "kEU5xHOtRYXAeKhBg+kBRInISIPEGFteX11BXEFdw2aQZUiLBCVgAAAASItAGEiLQCBIiwBIiwBIi0Agw0dldFByb2NBZGRyZXNzAA8fRAAAVlNJictMidmLQTxIAchIjUAY"
    . "SI1AcEiLwIsQSI0EEYtYGItQIIXbdFNFMdJJjTQTQosUlkG4RwAAAEyNDav///9MAdoPtgqEyXUe6yYPHwBEOMF1Hg+2SgFIg8IBSYPBAUUPtgGEyXQFRYTAdeJEOMF0DkmD"
    . "wgFJOdp1tDHAW17Di1AkS40MU4tAHA+3FBFJjRSTiwQCTAHYW17DDx9AAFdWU0iD7DAx28dEJCwAAAAASInOSI18JCzrMA8fRAAA/1Ywg/h6D4WEAAAASIXbdAZIidn/ViiL"
    . "VCQsuUAAAAD/ViBIicNIhcB0ZUiJ+kiJ2f9WSIXAdMiLRCQsg/gfdltEjUDgMdJIidhFicFBwekFQY1JAUjB4QVIAdkPH0AAg3gIAYPSAEiDwCBIOcF18EHB4QVEicCJ10Qp"
    . "yIlEJCxIidn/ViiJ+EiDxDBbXl/DMf+J+EiDxDBbXl/DMf/r4Edsb2JhbEZyZWUAR2xvYmFsQWxsb2MATG9hZExpYnJhcnlBAEZyZWVMaWJyYXJ5AEdldExvZ2ljYWxQcm9j"
    . "ZXNzb3JJbmZvcm1hdGlvbgBHZXRMYXN0RXJyb3IAUXVlcnlQZXJmb3JtYW5jZUNvdW50ZXIAUXVlcnlQZXJmb3JtYW5jZUZyZXF1ZW5jeQBDcmVhdGVUaHJlYWQAV2FpdEZv"
    . "clNpbmdsZU9iamVjdABDcmVhdGVFdmVudEEAU2V0RXZlbnQAUmVzZXRFdmVudABDbG9zZUhhbmRsZQBXYWl0Rm9yTXVsdGlwbGVPYmplY3RzAGZmLg8fhAAAAAAAZpBBVUFU"
    . "VVdWU0iD7DhlSIsEJWAAAABIi0AYSItAIEiLAEiLAEiLQCBIicaJzUiFwA+E+QIAAEiJwehj/f//SI0VvP7//0iJ8UiJx//QSI0VuP7//0iJ8UmJxf/XutgAAAC5QAAAAEmJ"
    . "xP/QSInDSIXAD4S4AgAASI0FY/v//0iNFZP+//9IifFIiTNIiYPQAAAATIljIEiJewhMiWso/9dIjRV+/v//SInxSIlDEP/XSI0Vev7//0iJ8UiJQxj/10iNFYn+//9IifFI"
    . "iUNI/9dIjRWG/v//SInxSIlDMP/XSI0Vjv7//0iJ8UiJQzj/10iNFZj+//9IifFIiUNA/9dIjRWV/v//SInxSIlDUP/XSI0Vmf7//0iJ8UiJQ1j/10iNFZb+//9IifFIiUNg"
    . "/9dIjRWP/v//SInxSIlDaP/XSI0Viv7//0iJ8UiJQ3D/10iNFYb+//9IifFIiUN4/9dFMclFMcC6AQAAADHJSImDgAAAAP9TYEUxyUUxwLoBAAAAMclIiYOIAAAA/1NgRTHJ"
    . "RTHAugEAAABIiYOQAAAAMcn/U2BIiYOYAAAAhe0PhC0BAACNFO0AAAAAuUAAAACJq8wAAABB/9S5QAAAAEiJg6AAAACLg8wAAACNFMUAAAAAQf/Ui5PMAAAAuUAAAABIiYOo"
    . "AAAAweIEQf/USIO7oAAAAABIx4O4AAAAAAAAAEiJg7AAAABIx4PAAAAAAAAAAMeDyAAAAAAAAAAPhL8AAABIi5OoAAAASIXAD4SvAAAASIXSD4SmAAAAi4PMAAAAhcB0djH2"
    . "SI0tA/n//+sIkEiLk6gAAABIjTz1AAAAAEUxyUUxwDHJTI0kOjHS/1NgSYnxSYnoMdJJiQQkScHhBDHJTAOLsAAAAEGJcQhIA7ugAAAASIPGAUmJGUjHRCQoAAAAAMdEJCAA"
    . "AAAA/1NQSIkHO7PMAAAAcpZIidhIg8Q4W15fXUFcQV3DZg8fRAAASInZ6Fj7//+JxenE/v//kEiJwf9TKEiLi6gAAAD/UyhIi4ugAAAA/1MoSIuLiAAAAP9TeEiLi5gAAAD/"
    . "U3hIi4uQAAAA/1N4SInZQf/VMdtIidhIg8Q4W15fXUFcQV3DVlNIg+woSInLSIXJD4SuAAAASIuJkAAAAP9TaEiLk6AAAABBuf////9BuAEAAACLi8wAAAD/k4AAAABIi4uI"
    . "AAAA/1N4SIuLmAAAAP9TeEiLi5AAAAD/U3iLg8wAAACFwHQtMfYPHwBIi4OgAAAASIsM8P9TeEiLg6gAAABIiwzwSIPGAf9TeDuzzAAAAHLYSIuLsAAAAP9TKEiLi6gAAAD/"
    . "UyhIi4ugAAAA/1MoSItDKEiJ2UiDxChbXkj/4GaQSIPEKFtew2ZmLg8fhAAAAAAAZmYuDx+EAAAAAAAPHwABAAAAAwAAAAEAAAABAAAAAQAAAAMAAAAAAQAAAQAAAAEAAAAD"
    . "AAAAAAgAAAEAAAABAAAAAwAAAACAAAABAAAAAQAAAAMAAAAAAAABAQAAAAEAAAADAAAAAACAAAEAAAABAAAAAwAAAAAAAAEBAAAAAQAAAAMAAAAAAAACAQAAAAEAAAADAAAA"
    . "AAAABAEAAAABAAAAAgAAAAEAAAACAAAAAQAAAAIAAAAAIAAAAgAAAAEAAAACAAAAAAAIAAIAAAABAAAAAgAAAAAAEAACAAAAAQAAAAIAAAAAAIAAAgAAAAEAAIACAAAAAQAA"
    . "AAIAAAABAAAAAgAAAAAQAAADAAAAAQAAAAIAAAAAAEAAAwAAAAEAAAACAAAAAAAACAMAAAABAAAAAgAAAAAAABADAAAAAQAAAAIAAAAAAAAgAwAAAAEAAIACAAAAIAAAAAMA"
    . "AAAHAAAAAQAAAAgAAAADAAAABwAAAAEAAAAgAAAAAwAAAAcAAAABAAAAAAEAAAMAAAAHAAAAAQAAAAAAAQAEAAAABwAAAAEAAAAAAAIABAAAAAcAAAABAAAAAAAAEAQAAAAH"
    . "AAAAAQAAAAAAAEAEAAAABwAAAAEAAAAAAACABAAAAP////+QkJCQkJCQkJCQkJA="
    mcode_mt_run                := 0x000080 ; u32 mt_run(mt_ctx *ctx, mt_client_worker_t worker, ptr param)
    mcode_get_cpu_psabi_level   := 0x000130 ; int get_cpu_psabi_level()
    mcode_gpa_getkernel32       := 0x000210 ; 
    mcode_gpa_getgetprocaddress := 0x000240 ; 
    mcode_mt_get_cputhreads     := 0x0002e0 ; 
    mcode_mt_init               := 0x0004a0 ; mt_ctx *mt_init(u32 num_threads)
    mcode_mt_deinit             := 0x0007e0 ; void mt_deinit(mt_ctx *ctx)
    ;----------------- end of ahkmcodegen auto-generated section ------------------
            
        static code := this.i_b64decode(b64)
        codemap := Map( "get_cpu_psabi_level",       code + mcode_get_cpu_psabi_level
                      , "mt_get_cputhreads",         code + mcode_mt_get_cputhreads
                      , "mt_init",                   code + mcode_mt_init
                      , "mt_deinit",                 code + mcode_mt_deinit
                      )
        return codemap
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
    ; get/set tolerance
    ;########################################################################################################
    tolerance_set(t) {
        this.i_tolerance := t
    }
    tolerance_get() {
        return this.i_tolerance
    }

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
        h := pic.height - t
        if h <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, t, pic.width, h)
    }
    chop_mism_b(pic, refc) {
        b := this.get_row_match_rev(pic, refc, pic.height-1)
        if b <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, pic.width, b)
    }
    chop_match_t(pic, refc) {
        t := this.get_row_mism(pic, refc, 0)
        h := pic.height - t
        if h <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, t, pic.width, pic.height - t)
    }
    chop_match_b(pic, refc) {
        b := this.get_row_mism_rev(pic, refc, pic.height-1)
        if b <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, pic.width, b)
    }
    chop_match_l(pic, refc) {
        t := this.get_col_mism(pic, refc, 0)
        w := pic.width - t
        if w <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_mism_l(pic, refc) {
        t := this.get_col_match(pic, refc, 0)
        w := pic.width - t
        if t <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_match_r(pic, refc) {
        t := this.get_col_mism_rev(pic, refc, pic.width - 1)
        if t <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, t, pic.height)
    }
    chop_mism_r(pic, refc) {
        t := this.get_col_match_rev(pic, refc, pic.width - 1)
        if t <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, t, pic.height)
    }
    chop_mism_then_match_l(pic, refc, minimumGap := 1) {
        t := this.get_col_match(pic, refc, 0,,, minimumGap)
        t := this.get_col_mism(pic, refc, t)
        w := pic.width - t
        if w <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_mism_then_match_r(pic, refc, minimumGap := 1) {
        t := imgu.get_col_match_rev(pic, refc, pic.width - 1,,, minimumGap)
        t := imgu.get_col_mism_rev(pic, refc, t)
        if t <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, t, pic.height)
    }

    ;########################################################################################################
    ; crop-grab
    ;########################################################################################################
    grab_mism_t(pic, refc) {
        b := this.get_row_match(pic, refc, 0)
        if b <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, pic.width, b)
    }
    
    grab_mism_b(pic, refc) {
        b := this.get_row_match_rev(pic, refc, pic.height-1)
        h := pic.height - b
        if h <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, b, pic.width, h)
    }
    
    grab_mism_l(pic, refc) {
        l := this.get_col_match(pic, refc, 0)
        if l <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, 0, 0, l, pic.height)
    }
    
    grab_mism_r(pic, refc) {
        r := imgu.get_col_match_rev(pic, refc, pic.width-1)
        w := pic.width - r
        if r <= 0
            Throw Error("Fail", -1)
        return this.crop(pic, r, 0, pic.width-r, pic.height)
    }
    
    ;########################################################################################################
    ; crop
    ;########################################################################################################
    crop(img, x, y, w, h) {
        new := img.crop(x, y, w, h)
        if img.HasOwnProp("origins")
            new.origins := [img.origins[1] + x, img.origins[2] + y]
        return new
    }
    
    ;########################################################################################################
    ; screenshot
    ;########################################################################################################
    screengrab(x, y, w, h) {
        img := ImagePutBuffer([x, y, w, h])
        img.origins := [x, y]
        return img
    }

    ;########################################################################################################
    ; imagesearch
    ;########################################################################################################
    srch(&fx, &fy,                      ; output coordinates if image found
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
        DllCall(this.i_mcode_map["imgutil_make_sat_masks"], 
            "ptr", needle.ptr, "uint", needle.width * needle.height, 
            "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "char", tolerance, "int")

        pixels_matched := 0
        result := 0
        if (this.i_use_single_thread) {
            result := DllCall(this.i_mcode_map["imgutil_imgsrch"],
                "ptr", haystack.ptr, "int", haystack.width, "int", haystack.height,
                "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "int", needle.width, "int", needle.height,
                "char", min_percent_match, "int", force_topleft_pixel_match, "int*", pixels_matched, "ptr") 
        } else {
            result := DllCall(this.i_mcode_map["imgutil_imgsrch_multi"], "ptr", imgu.i_multithread_ctx,
                "ptr", haystack.ptr, "int", haystack.width, "int", haystack.height,
                "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "int", needle.width, "int", needle.height,
                "char", min_percent_match, "int", force_topleft_pixel_match, "int*", pixels_matched, "ptr")
        }

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

    ;########################################################################################################
    ; copy a rectangle from one image to another
    ; 
    ;   dst     - destination pointer
    ;   dx      - destination x
    ;   dy      - destination y
    ;   dstride - destination stride in pixels
    ;   src     - source pointer
    ;   sx      - source x
    ;   sy      - source y
    ;   sstride - source stride in pixels
    ;   w       - width of the rectangle
    ;   h       - height of the rectangle
    ; 
    ;########################################################################################################
    blit(dst, dx, dy, dstride, src, sx, sy, sstride, w, h) {
        if imgu.i_use_single_thread {
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
    load(fname) {
        return imgutil.img(this).load(fname)
    }

    ;########################################################################################################
    ; capture the screen
    ;########################################################################################################
    grab_screen(rect := 0) {
        return imgutil.img(this).grab_screen(rect)
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
    ;########################################################################################################
    ; the img class, does a lot of the heavy lifting
    ;########################################################################################################
    ;########################################################################################################
    class img {
        ptr     := 0     ; pointer to ARGB flat pixel data
        w       := 0     ; width of image
        h       := 0     ; height of image
        origin  := 0     ; origin of image relative to screen(0,0)

        i_imgu      := 0     ; internal variable holding the imgutil object

        i_vrect     := 0     ; virtual rectangle, affected by cropping and
                             ; observed by most operations (pixel scan, etc)
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
        ; object from file
        ;########################################################################################################
        load(fname) {
            i_provider := image_provider.gdip.file()
            if i_provider.get_image(fname) {
                this.i_provider := i_provider
                this.ptr        := i_provider.ptr
                this.w          := i_provider.w
                this.h          := i_provider.h
                return this
            }
            return false
        }

        ;########################################################################################################
        ; object from memory location
        ;########################################################################################################
        grab_memory(ptr, w, h, stride) {
            i_provider := image_provider.gdip.memory()
            if i_provider.get_image(ptr, w, h, stride) {
                this.i_provider := i_provider
                this.ptr        := i_provider.ptr
                this.w          := i_provider.w
                this.h          := i_provider.h
                return this
            }
            return false
        }
        
        ;########################################################################################################
        ; object from screen
        ;########################################################################################################
        grab_screen(rect := 0) { 
            ; try with directx first (fast), otherwise try with gdi (sloooow)
            providers := [image_provider.dx_screen(), image_provider.gdi_screen()]
            for provider in providers {
                if origin := provider.get_image(rect) {
                    this.i_provider := provider
                    this.ptr        := provider.ptr
                    this.w          := provider.w
                    this.h          := provider.h
                    this.origin     := origin
                    return this
                }
            }
        }
        
        ;########################################################################################################
        ; save the image to a file, the type is based on the extension  
        ;########################################################################################################
        save(fname) {
            ret := false
            ; create a new image object that copies our memory buffer into a gdi+ bitmap
            if image := imgutil.img(this.i_imgu).grab_memory(this.ptr, this.w, this.h, this.w*4) {
                ; get filename extension
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
                                    if imgu_GDIP_OK = DllCall("gdiplus\GdipSaveImageToFile", "ptr", image.i_provider.gdip_pBitmap, "wstr", fname, "ptr", pcodec, "ptr", 0, "ptr")
                                        ret := true
                                    break
                                }
                                i++
                            }
                        }
                    }
                }
            }
            return ret
        } 
    } ; end of img class

    ; a simple rectangle class to wrap up all the x/y/w/h nonsense
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
; a series of image providers that make it transparent to imgutil how various images are
; acquired; from a file, from a screenshot, etc.
;########################################################################################################
class image_provider {

    ptr     := 0            ; pointer to ARGB flat pixel data
    w       := 0            ; image width
    h       := 0            ; image height
    stride  := 0            ; image stride

    __New() {
    }

    __Delete() {
    }

    get_image(ptr, w, h, stride, offs_x, offs_y) {
        this.ptr    := ptr
        this.w      := w
        this.h      := h
        this.stride := stride
        this.offs_x := offs_x
        this.offs_y := offs_y
        return true
    }

    ; image provider for anything gdi+ based (file & memory)
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

        get_image(gdip_pBitmap) {
            ret := false
            if this.gdip_pBitmap := gdip_pBitmap {
                DllCall("gdiplus\GdipGetImageWidth",  "ptr", this.gdip_pBitmap, "uint*", &w:= 0)
                DllCall("gdiplus\GdipGetImageHeight", "ptr", this.gdip_pBitmap, "uint*", &h:= 0)
                if w && h {
                    if this.lock(w, h, w * 4) {
                        ret := super.get_image(this.bits_buffer.ptr, w, h, w * 4, 0, 0)
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
                super.get_image(0, 0, 0, 0, 0, 0)
            }
            return false
        }

        ; gdiplus image provider for file sources
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

        ; gdiplus image provider for memory sources (intended to serve as a gdip object 
        ; that we can use to save the memory to a file)
        class memory extends image_provider.gdip {
            
            __New() {
                super.__New()
            }

            __Delete() {
                super.__Delete()    
            }

            get_image(ptr, w, h, stride) {
                if imgu_GDIP_OK = DllCall("gdiplus\GdipCreateBitmapFromScan0", 
                        "uint", w, "uint", h, "int", stride, 
                        "uint", 0x0026200a,     ; PixelFormat32bppARGB
                        "ptr" , ptr, 
                        "ptr*", &pbmp := 0) 
                {
                    return super.get_image(pbmp)
                }
                return false
            }

        } ; end of image_provider.gdip.memory class

    } ; end of image_provider.gdip class

    ; gdi screen capture provider
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
                bmi := Buffer(40, 0)
                NumPut("int",   40,     bmi,  0) ; sizeof(BITMAPINFOHEADER)
                NumPut("int",   rect.w, bmi,  4) ; width
                NumPut("int",  -rect.h, bmi,  8) ; negative height means top-down bitmap
                NumPut("short", 1,      bmi, 12) ; planes
                NumPut("short", 32,     bmi, 14) ; bit depth
                bmp := DllCall("gdi32\CreateDIBSection", "ptr", hdc, "ptr", bmi, 
                    "uint", 0, "ptr*", &bits := 0, "ptr", 0, "uint", 0, "ptr")
                if bmp {
                    if oldbmp := DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", bmp, "ptr") {
                        if screen_dc := DllCall("user32\GetDC", "ptr", 0, "ptr") {
                            DllCall("gdi32\BitBlt", "ptr", hdc, "int", 0, "int", 0, "int", rect.w, "int", rect.h,
                                        "ptr", screen_dc, "int", rect.x, "int", rect.y, 
                                        "uint", 0x40CC0020) ; SRCCOPY | CAPTUREBLT
                            ; our job here is done
                            this.dibsection := bmp
                            super.get_image(bits, rect.w, rect.h, rect.w * 4, 0, 0)
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

    ; directx screen capture provider
    class dx_screen extends image_provider {

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

        static texture_screen    := 0
        static texture_subregion := 0

        __New() {
            super.__New()
        }

        __Delete() {
            super.__Delete()    
        }

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

            ; we don't need to do anything if we're already initialized and the monitor isn't changing
            if  image_provider.dx_screen.init_successful && 
                image_provider.dx_screen.last_monitor_rect && 
                image_provider.dx_screen.last_monitor_rect.contains(rect)
                return true

            ; if the user is asking for a rectangle from a different monitor, we do a fast reinit.
            ; note that this is not optimal, reinit takes ages; the ideal solution would be to prepare
            ; an instance of the environment for each monitor that get_image touches. TODO
            if !(image_provider.dx_screen.last_monitor_rect && image_provider.dx_screen.last_monitor_rect.contains(rect))
                image_provider.dx_screen.last_init_attempt := 0

            ; we're already initialized, but something is wrong (access lost, monitor change, etc)
            if image_provider.dx_screen.init_successful
                this.cleanup(true)

            ; this whole thing is expensive, so don't try it too often unless the user just wants a screenshot from a different monitor
            if A_TickCount - image_provider.dx_screen.last_init_attempt < 2000
                return false
            image_provider.dx_screen.last_init_attempt := A_TickCount

            ; load DLLs
            if !image_provider.dx_screen.hmod_dxgi
                image_provider.dx_screen.hmod_dxgi  := DllCall("LoadLibrary", "str", "DXGI")
            if !image_provider.dx_screen.hmod_d3d11
                image_provider.dx_screen.hmod_d3d11 := DllCall("LoadLibrary", "str", "D3D11")
            if !(image_provider.dx_screen.hmod_dxgi && image_provider.dx_screen.hmod_d3d11)
                return false
            ret := false
            DllCall("ole32\CLSIDFromString", "wstr", "{7b7166ec-21c7-44ae-b21a-c9ae321ae369}", "ptr", image_provider.dx_screen.riid , "int")
            if DllCall("DXGI\CreateDXGIFactory1", "ptr", image_provider.dx_screen.riid, "ptr*", &p:=0, "int") >= 0 {
                image_provider.dx_screen.ptr_dxgi_factory := p
                loop {
                    if ComCall(IDXGIFactory_EnumAdapters, image_provider.dx_screen.ptr_dxgi_factory, "uint", A_Index-1, "ptr*", &IDXGIAdapter:=0, "int") >= 0 {
                        loop {
                            if ComCall(IDXGIAdapter_EnumOutputs, IDXGIAdapter, "uint", A_Index-1, "ptr*", &IDXGIOutput:=0, "int") >= 0 {
                                if ComCall(IDXGIOutput_GetDesc, IDXGIOutput, "ptr", image_provider.dx_screen.DXGI_OUTPUT_DESC, "int") >= 0 {
                                    x                 := NumGet(image_provider.dx_screen.DXGI_OUTPUT_DESC, 64, "int")
                                    y                 := NumGet(image_provider.dx_screen.DXGI_OUTPUT_DESC, 68, "int")
                                    Width             := NumGet(image_provider.dx_screen.DXGI_OUTPUT_DESC, 72, "int")
                                    Height            := NumGet(image_provider.dx_screen.DXGI_OUTPUT_DESC, 76, "int")
                                    AttachedToDesktop := NumGet(image_provider.dx_screen.DXGI_OUTPUT_DESC, 80, "int")
                                    if (AttachedToDesktop = 1) {
                                        rect_monitor := imgutil.rect(x, y, Width, Height)
                                        ; we can't do rects that are not fully contained within the adapter's output
                                        if (rect_monitor.contains(rect)) {
                                            image_provider.dx_screen.ptr_dxgi_adapter   := IDXGIAdapter
                                            image_provider.dx_screen.ptr_dxgi_output    := IDXGIOutput
                                            image_provider.dx_screen.last_monitor_rect  := rect_monitor
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
                if !image_provider.dx_screen.ptr_dxgi_output {
                    ; don't release DLLs
                    this.cleanup(true)
                    return false
                }

                if DllCall("D3D11\D3D11CreateDevice",
                    "ptr",  image_provider.dx_screen.ptr_dxgi_adapter,   ; pAdapter
                    "int",  D3D_DRIVER_TYPE_UNKNOWN,                     ; DriverType
                    "ptr",  0,                                           ; Software
                    "uint", 0,                                           ; Flags
                    "ptr",  0,                                           ; pFeatureLevels
                    "uint", 0,                                           ; FeatureLevels
                    "uint", D3D11_SDK_VERSION,                           ; SDKVersion
                    "ptr*", &d3d_device:=0,                              ; ppDevice
                    "ptr*", 0,                                           ; pFeatureLevel
                    "ptr*", &d3d_context:=0,                             ; ppImmediateContext
                    "int") >= 0 
                {
                    image_provider.dx_screen.d3d_device  := d3d_device
                    image_provider.dx_screen.d3d_context := d3d_context
                    ; Retrieve the desktop duplication API
                    if image_provider.dx_screen.ptr_dxgi_output1 := ComObjQuery(image_provider.dx_screen.ptr_dxgi_output, "{00cddea8-939b-4b83-a340-a685226666cc}") {
                        if ComCall(IDXGIOutput1_DuplicateOutput := 22, image_provider.dx_screen.ptr_dxgi_output1, "ptr", image_provider.dx_screen.d3d_device, "ptr*", &dup:=0, "int") >= 0 {
                            image_provider.dx_screen.ptr_dxgi_dup := dup
                            if ComCall(IDXGIOutputDuplication_GetDesc := 7, image_provider.dx_screen.ptr_dxgi_dup, "ptr", image_provider.dx_screen.DXGI_OUTDUPL_DESC) >= 0 {
                                image_provider.dx_screen.using_system_memory := NumGet(image_provider.dx_screen.DXGI_OUTDUPL_DESC, 32, "uint")

                                NumPut("uint", image_provider.dx_screen.last_monitor_rect.w, image_provider.dx_screen.D3D11_TEXTURE2D_DESC,  0)   ; Width
                                NumPut("uint", image_provider.dx_screen.last_monitor_rect.h, image_provider.dx_screen.D3D11_TEXTURE2D_DESC,  4)   ; Height
                                NumPut("uint",                                            1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC,  8)   ; MipLevels
                                NumPut("uint",                                            1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC,  8)   ; MipLevels
                                NumPut("uint",                                            1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC, 12)   ; ArraySize
                                NumPut("uint",                   DXGI_FORMAT_B8G8R8A8_UNORM, image_provider.dx_screen.D3D11_TEXTURE2D_DESC, 16)
                                NumPut("uint",                                            1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC, 20)   ; SampleDescCount
                                NumPut("uint",                          D3D11_USAGE_STAGING, image_provider.dx_screen.D3D11_TEXTURE2D_DESC, 28)
                                NumPut("uint",                        D3D11_CPU_ACCESS_READ, image_provider.dx_screen.D3D11_TEXTURE2D_DESC, 36)

                                ; the thing about IDXGIOutputDuplication_AcquireNextFrame is that the first call to it always
                                ; immediately returns with success and a blank frame, no matter the timeout. the second call
                                ; will also return a blank frame, no matter how much time elapses between those two calls.
                                ; it works properly from the third call onwards. these two dummy calls look weird but help.
                                ComCall(IDXGIOutputDuplication_AcquireNextFrame := 8, image_provider.dx_screen.ptr_dxgi_dup, 
                                    "uint", 0, "ptr", image_provider.dx_screen.DXGI_OUTDUPL_FRAME_INFO, 
                                    "ptr*", &ptr_dxgi_resource:=0, "int")
                                if ptr_dxgi_resource
                                    ObjRelease(ptr_dxgi_resource)
                                ptr_dxgi_resource := 0
                                ; release "frame" (yeah right)
                                ComCall(IDXGIOutputDuplication_ReleaseFrame := 14, image_provider.dx_screen.ptr_dxgi_dup, "uint")
                                ; pretend to give a crap about the next one
                                ComCall(IDXGIOutputDuplication_AcquireNextFrame, image_provider.dx_screen.ptr_dxgi_dup, 
                                    "uint", 0, "ptr", image_provider.dx_screen.DXGI_OUTDUPL_FRAME_INFO, 
                                    "ptr*", &ptr_dxgi_resource:=0, "int")
                                if ptr_dxgi_resource
                                    ObjRelease(ptr_dxgi_resource)
                                ptr_dxgi_resource := 0
                                ; create a permanent buffer to hold the screen capture. 
                                if ComCall(ID3D11Device_CreateTexture2D := 5, image_provider.dx_screen.d3d_device, "ptr", image_provider.dx_screen.D3D11_TEXTURE2D_DESC, "ptr", 0, "ptr*", &texture_screen:=0, "int") >= 0 {
                                    image_provider.dx_screen.texture_screen := texture_screen
                                    image_provider.dx_screen.init_successful := true
                                    ret := true
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

        cleanup_static(partial := false) {


            if image_provider.dx_screen.texture_screen {
                ObjRelease(image_provider.dx_screen.texture_screen)
                image_provider.dx_screen.texture_screen := 0
            }

            image_provider.dx_screen.last_monitor_rect      := 0
            image_provider.dx_screen.init_successful        := 0
            image_provider.dx_screen.using_system_memory    := 0

            if image_provider.dx_screen.ptr_dxgi_dup {
                ObjRelease(image_provider.dx_screen.ptr_dxgi_dup)
                image_provider.dx_screen.ptr_dxgi_dup := 0
            }

            ; this came from ComQuery and that returns wrappers, 
            ; so removing the script reference will release the object
            image_provider.dx_screen.ptr_dxgi_output1 := 0

            if image_provider.dx_screen.d3d_context {
                ObjRelease(image_provider.dx_screen.d3d_context)
                image_provider.dx_screen.d3d_context := 0
            }

            if image_provider.dx_screen.d3d_device {
                ObjRelease(image_provider.dx_screen.d3d_device)
                image_provider.dx_screen.d3d_device := 0
            }

            if image_provider.dx_screen.ptr_dxgi_output {
                ObjRelease(image_provider.dx_screen.ptr_dxgi_output)
                image_provider.dx_screen.ptr_dxgi_output := 0
            }

            if image_provider.dx_screen.ptr_dxgi_adapter {
                ObjRelease(image_provider.dx_screen.ptr_dxgi_adapter)
                image_provider.dx_screen.ptr_dxgi_adapter := 0
            }

            if image_provider.dx_screen.ptr_dxgi_factory {
                ObjRelease(image_provider.dx_screen.ptr_dxgi_factory)
                image_provider.dx_screen.ptr_dxgi_factory := 0
            }

            ; don't release DLLs if we're not done for good
            if partial
                return

            if image_provider.dx_screen.hmod_d3d11 {
                DllCall("FreeLibrary", "ptr", image_provider.dx_screen.hmod_d3d11)
                image_provider.dx_screen.hmod_d3d11 := 0
            }

            if image_provider.dx_screen.hmod_dxgi {
                DllCall("FreeLibrary", "ptr", image_provider.dx_screen.hmod_dxgi)
                image_provider.dx_screen.hmod_dxgi := 0
            }
        }

        get_image(rect := 0) {

            static IDXGIOutputDuplication_AcquireNextFrame := 8
            static DXGI_ERROR_WAIT_TIMEOUT                 := 0x887a0027
            static ID3D11DeviceContext_Unmap               := 15
            static D3D11_MAP_READ                          := 1
            static D3D11_MAP_WRITE                         := 2
            static D3D11_MAP_READ_WRITE                    := 3
            ret := false
            if !rect
                rect := imgutil.rect(0, 0, A_ScreenWidth, A_ScreenHeight)

            ; initialize the environment if needed
            if this.init(rect) {

                reuse_resource := false
                ; we want to hold the previous frame as long as possible to disallow gpu access to the buffer, 
                ; and let data accumulate. (docs say so.)
                hr := ComCall(IDXGIOutputDuplication_ReleaseFrame := 14, image_provider.dx_screen.ptr_dxgi_dup, "uint")
                ; call the duplication API to get the next frame. don't wait for any new updates;
                ; if there are none, we'll use our permanent buffer from the last frame
                hr := ComCall(IDXGIOutputDuplication_AcquireNextFrame, image_provider.dx_screen.ptr_dxgi_dup, 
                    "uint", 0,
                    "ptr", image_provider.dx_screen.DXGI_OUTDUPL_FRAME_INFO, 
                    "ptr*", &ptr_dxgi_resource:=0, 
                    "uint")

                if !(hr & 0x80000000) {
                    if NumGet(image_provider.dx_screen.DXGI_OUTDUPL_FRAME_INFO, 0, "int64") > 0 {
                        ; copy the texture we just received into our permanent buffer
                        texture_screen_update := ComObjQuery(ptr_dxgi_resource, "{6f15aaf2-d208-4e89-9ab4-489535d34f9c}") ; ID3D11Texture2D
                        ObjRelease(ptr_dxgi_resource)
                        hr := ComCall(ID3D11DeviceContext_CopyResource := 47, image_provider.dx_screen.d3d_context, 
                            "ptr", image_provider.dx_screen.texture_screen, 
                            "ptr", texture_screen_update, 
                            "int")
                    }
                } else if hr = DXGI_ERROR_WAIT_TIMEOUT {
                    ; nop, we'll use the last frame from the buffer
                } else if hr & 0x80000000 {
                    ; if we flat out failed, we'll need to reinit; the assumption is that the
                    ; monitor, desktop, lock state, etc. changed
                    OutputDebug "IDXGIOutputDuplication_AcquireNextFrame failed: " Format("0x{:8x}", hr)
                    this.cleanup_static(true)
                    return false
                }

                if !image_provider.dx_screen.using_system_memory {  ; TODO what if system memory is used?
                    ; map the texture into system memory
                    if (hr := ComCall(ID3D11DeviceContext_Map := 14, image_provider.dx_screen.d3d_context, 
                        "ptr", image_provider.dx_screen.texture_screen, "uint", 0, 
                        "uint", D3D11_MAP_READ, "uint", 0, 
                        "ptr", image_provider.dx_screen.D3D11_MAPPED_SUBRESOURCE, "int")) >= 0
                    {
                        ptr    := NumGet(image_provider.dx_screen.D3D11_MAPPED_SUBRESOURCE, 0, "ptr")
                        stride := NumGet(image_provider.dx_screen.D3D11_MAPPED_SUBRESOURCE, 8, "int")
                        ; allocate the buffer we'll hold the data in
                        imgdata := Buffer(rect.w * rect.h * 4)
                        ; TODO: we need to rebase the rect to the monitor's origin
                        imgu.blit(imgdata.ptr, 0, 0, rect.w,        ; destination, top left corner of bufer with stride=width
                                  ptr, rect.x, rect.y, stride//4,   ; source, the screen buffer, stride in pixels
                                  rect.w, rect.h)                   ; dimensions
                        super.get_image(imgdata, rect.w, rect.h, rect.w * rect.h, 0, 0)
                        ; return the origins to caller
                        ret := {x: rect.x, y: rect.y}
                        ComCall(ID3D11DeviceContext_Unmap, image_provider.dx_screen.d3d_context, "ptr", image_provider.dx_screen.texture_screen, "uint", 0)
                    }
                }
            }
            return ret
        } ; end of get_image
    } ; end of image_provider.dx_screen class
} ; end of image_provider class

;########################################################################################################
; a global instance of the dx_screen provider, to keep the capture loop alive, and ensure cleanup on
; program exit
;########################################################################################################
_dx_screen_helper := dx_screen_helper()
class dx_screen_helper {
    provider := 0
    __New() {
        this.provider := image_provider.dx_screen()
        this.provider.init(imgutil.rect(0, 0, A_ScreenWidth, A_ScreenHeight))
    }
    __Delete() {
        ; clean up completely
        this.provider.cleanup_static()
    }
}













