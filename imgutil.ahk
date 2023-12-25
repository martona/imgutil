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
    . "" ; 6192 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTi1wkSESJyEhj8kiJz0hjTCRAD7bERYnIQYnCi0QkWEHB6BAPr8ZImEgByEyNHIeLRCRQD6/GSJhIAchIjQyHTDnZc2mD/gFFD7bARQ+20kUPtsl0EetmZg8fRAAASIPB"
    . "BEw52XNHD7ZBAUQp0Jkx0CnQD7ZRAkQpwonWwf4fMfIp8jnQD0zCD7YRRCnKidbB/h8x8inyOdAPTMI5w32+McBbXl/DDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusS"
    . "Zi4PH4QAAAAAAEgB8Uw52XPYD7ZBAkQpwJkx0CnQD7ZRAUQp0onXwf8fMfop+jnQD0zCD7YRRCnKidfB/x8x+in6OdAPTMI5w32/McDrj2ZmLg8fhAAAAAAAVlMPr1QkOItc"
    . "JEBIY9JIic5IY0wkUEWJykSJyEHB6hAPtsRIAdFMjRyOSGNMJEhIAcpIjQyWTDnZc2VFD7bSRA+2wEUPtsnrEA8fgAAAAABIg8EETDnZc0cPtkECRCnQmTHQKdAPtlEBRCnC"
    . "idbB/h8x8inyOdAPTMIPthFEKcqJ1sH+HzHyKfI50A9MwjnDfb4xwFtew2YPH4QAAAAAALgBAAAAW17DDx+EAAAAAABBV0FWQVVBVFVXVlNIgey4AgAADxG0JBACAAAPEbwk"
    . "IAIAAEQPEYQkMAIAAEQPEYwkQAIAAEQPEZQkUAIAAEQPEZwkYAIAAEQPEaQkcAIAAEQPEawkgAIAAEQPEbQkkAIAAEQPEbwkoAIAAA+2hCQgAwAARGngAAEBAEmJyonXQQnE"
    . "QYHMAAAA/0SJ4EWJ5kSJ5kHB7hAPtsSF0kGJw0SJ8w+OEQgAAIP6EA+OcwcAAEUPtuRFD7b2RQ+26/NED2892xQAAEyJ4EyJ8fNED2813BQAAGYP7/9IweAISMHhCPNED28t"
    . "1xQAAGZFD3bbjWr/TAnwTAnp80QPbyUAFQAASMHgCEjB4QhMiepMCeFMCehIweIISMHgCEjB4QhMCeJMCeBMCfFIweIISMHgCEjB4QhMCfJMCfBMCelIweAISMHhCEwJ4UwJ"
    . "6EjB4AhIweEITAngTAnxSMHgCEjB4QhMCfBMCelIweIITAnqSIkEJEjB4ghIiUwkCEwJ4kiJTCQQTInRSMHiCEiJRCQoTInITAnySMHiCEwJ6kjB4ghMCeJBiexBwewESIlU"
    . "JBhJweQGSIlUJCBMicJNAdQPH0AA8w9vMUiDwUBIg8JASIPAQPMPb1HQZg84ADVSEwAA8w9vaeBmD2/C8w9vZCQgZg84ABVaEwAAZg84AAVBEwAAZg/r8GYPb8VmDzgALWAT"
    . "AABmD/zm8w9vXCQQZkQPb9ZmDzgABTgTAABmD+vQ8w9vQfBmRA/4VCQgZkQPb8pmD/za8w9vDCRmRA/4TCQQZg84AAUqEwAAZg/r6GYPb8ZmRA9vxWYP2MRmD/zNZg90x2ZE"
    . "D/gEJGYP2+BmQQ/fw2YP68RmD2/iZg/Y42YPdOdmD9vcZkEP3+NmD+vjZg9v3WYP2NlmD3TfZg/by2ZBD9/bZg/r2WZBD2/KZg/YzmZBD2/xZg90z2YP2PJmQQ9v0GYP2NVm"
    . "D3T3Zg9012ZBD9vKZkQPxekAZkSJasBmD2/pDxGMJAACAABmQQ/b8UQPtqwkAgIAAGYPOAAtghIAAGZBD9vQRIhqwmZED8XtAGYPb+lmRIlqxGZBDzgA7w8RjCTwAQAARA+2"
    . "rCT1AQAARIhqxmZED8XpA2ZEiWrIDxGMJOABAABED7asJOgBAABEiGrKZkQPxe0AZg9v7mZEiWrMZkEPOADtDxGMJNABAABED7asJNsBAABEiGrOZkQPxekGZkSJatAPEYwk"
    . "wAEAAGZBDzgAzkQPtqwkzgEAAGYP681EiGrSZkQPxekAZg9vzmYPOAANCBIAAGZEiWrUDxG0JLABAABED7asJLEBAABEiGrWZkQPxe4BZkSJatgPEbQkoAEAAEQPtqwkpAEA"
    . "AESIatpmRA/F6QBmD2/OZg84AA3LEQAAZkSJatwPEbQkkAEAAEQPtqwklwEAAESIat5mRA/F7gRmRIlq4A8RtCSAAQAARA+2rCSKAQAARIhq4mZED8XpAGYPb8pmDzgADY4R"
    . "AABmRIlq5A8RtCRwAQAARA+2rCR9AQAARIhq5mZED8XuB2ZEiWroZkEPftVEiGrqZkQPxekAZg9vymZEiWrsZkEPOADMDxGUJGABAABED7asJGMBAABEiGruZkQPxeoCZkSJ"
    . "avAPEZQkUAEAAEQPtqwkVgEAAESIavJmRA/F6QBmD2/KZg84AA0jEQAAZkSJavQPEZQkQAEAAEQPtqwkSQEAAESIavZmRA/F6gVmRIlq+A8RlCQwAQAARA+2rCQ8AQAARIhq"
    . "+mZED8XpAGYPb8hmRIlq/A8RlCQgAQAARA+2rCQvAQAAxkLDAMZCxwDGQssARIhq/mZED8XoAMZCzwDGQtMAxkLXAMZC2wDGQt8AxkLjAMZC5wDGQusAxkLvAMZC8wDGQvcA"
    . "xkL7AMZC/wBmDzgADfYPAABmRIlowA8RhCQQAQAARA+2rCQSAQAARIhowmZED8XpAGYPb8hmRIloxGZBDzgAzw8RhCQAAQAARA+2rCQFAQAARIhoxmZED8XoA2ZEiWjIDxGE"
    . "JPAAAABED7asJPgAAABEiGjKZkQPxekAZg9vzGZEiWjMZkEPOADNDxGEJOAAAABED7asJOsAAABEiGjOZkQPxegGZkSJaNAPEYQk0AAAAGZBDzgAxkQPtqwk3gAAAGYP68FE"
    . "iGjSZkQPxegAZg9vxGYPOAAFaw8AAGZEiWjUDxGkJMAAAABED7asJMEAAABEiGjWZkQPxewBZkSJaNgPEaQksAAAAEQPtqwktAAAAESIaNpmRA/F6ABmD2/EZkSJaNwPEaQk"
    . "oAAAAEQPtqwkpwAAAGYPOAAFGA8AAESIaN5mRA/F7ARmRIlo4A8RpCSQAAAARA+2rCSaAAAARIho4mZED8XoAGYPb8NmDzgABfEOAABmRIlo5A8RpCSAAAAARA+2rCSNAAAA"
    . "RIho5mZED8XsB2ZEiWjoZkEPft1EiGjqZkQPxegAZg9vw2ZEiWjsZkEPOADEDxFcJHBED7ZsJHNEiGjuZkQPxesCZkSJaPAPEVwkYEQPtmwkZkSIaPJmRA/F6ABmD2/DZg84"
    . "AAWSDgAAZkSJaPQPEVwkUEQPtmwkWUSIaPZmRA/F6wVmRIlo+A8RXCRARA+2bCRMRIho+mZED8XoAGZEiWj8DxFcJDBED7ZsJD/GQMP/xkDH/8ZAy/9EiGj+xkDP/8ZA0//G"
    . "QNf/xkDb/8ZA3//GQOP/xkDn/8ZA6//GQO//xkDz/8ZA9//GQPv/xkD//0w54Q+Fsfn//4Pl8InoKe9IweACSQHCSQHASQHBjUf/Mf9JjWyBBA8fAEEPtgpBxkED/0UPtnoB"
    . "QcZAAwBFD7ZqAkGJzEEo9ESJ+kQPQudEKNpBD7bEQYnURA9C50SJ4kWJ7EEo3IjURIn6RA9C50AA8WZBiQBEiehFGPZECfFEANpFiGACRRj2QYgJRAnyANhBiFEBGNJJg8EE"
    . "SYPCBAnQSYPABEGIQf5MOc0PhXj///8PELQkEAIAADHADxC8JCACAABEDxCEJDACAABEDxCMJEACAABEDxCUJFACAABEDxCcJGACAABEDxCkJHACAABEDxCsJIACAABEDxC0"
    . "JJACAABEDxC8JKACAABIgcS4AgAAW15fXUFcQV1BXkFfw2YuDx+EAAAAAABBV0FWQVVBVFVXVlNIgewYAQAADxF0JHAPEbwkgAAAAEQPEYQkkAAAAEQPEYwkoAAAAEQPEZQk"
    . "sAAAAEQPEZwkwAAAAEQPEaQk0AAAAEQPEawk4AAAAEQPEbQk8AAAAEQPEbwkAAEAAESLrCSIAQAARIuMJJABAABEi5wkmAEAAEiLnCSoAQAARInoQQ+vwYnGiUQkSEEPvsMP"
    . "r8ZIi7QkgAEAAExj0MH4H01p0h+F61FJwfolQSnCQYD7ZLgBAAAAD0WEJKABAABEiVQkOEQPtlYBQYnDSIuEJIABAABBweIID7ZAAsHgEEQJ0EQPthZECdANAAAA/0UpyInH"
    . "RIlEJGQPiIMIAABIY9JNY8VmD+/ASIlMJEBIidBmD2/w80QPbz3JCwAAiXwkTEiNNJUAAAAATCnAi1QkOGYPOAA13QsAAEyNNIUAAAAAi0QkSEiJ92YP1nQkCE6NJDFEielM"
    . "iXQkWE2J4ESJXCQ8SYncOdAPncKFwA+VwCHCQYnSQY1V/4nQwegESMHgBkiJRCQYidCD4PBMjTyFAAAAACnBiUQkFInQTI00hQQAAACJTCQQTIn+MclMiXQkaEGJ1kiLRCRA"
    . "STnASInCD4KnBwAARItMJDxFhckPhLIHAACLRCRMD7bsicPB6BCJbCQgQYnBRIn1TInARIt0JCBIKdBIwfgCg/j/D4xcBwAAg8ABSIlUJChMjXyCBEiJ0OsQDx8ASIPABEw5"
    . "+A+ENQcAAEQ6SAJBD5PDRDpwAQ+TwkGE03TfOhhy20GJ7kmJx0iLVCRYSInziUwkYEiLRCRoRIn2SIl8JFBMiflEiFQkKEmJ3kyJRCQwTImkJKgBAACAfCQoAItsJDgPhG0G"
    . "AABIi7wkgAEAAEiJy0iJTCQgRItkJEiLbCQ480QPfjVDCgAADx8ARYXtD44pBgAAg/4PD4aIBgAATIt8JBhIiflJidhmRQ/v7WZFD+/kTY0MPw8fRAAA80EPbxBmQQ9vz2ZB"
    . "D2/HZkEPb//zRQ9vUBBmQQ9v92ZFD2/fSIPBQPNBD29oIGYP28pmD3HSCEmDwEDzRQ9vSPBmQQ/bwmYPZ8hmQQ9vx/NED29B0GYP2/1mQQ9x0ghmQQ/bwfMPb1nAZkEPcdEI"
    . "Zg9n+GYPcdUI8w9vYeBmQQ9n0mZBD9vX8w9vQfBmQQ9n6WZED2/KZkEP2/DzD29RwGZBD9vfZg9n3mZBD2/3Zg/b9GZED9vYZkEPcdAIZkEPZ/NmD3HQCGZBD9vvZkQPZ81J"
    . "OclmD3HSCGYPb+5mQQ/b92YPcdQIZkEPZ9BmQQ/b12YPZ+BmD2/BZkEP2+dmD2fUZg9v52YPcdAIZkEP2/9mQQ/a0WYPcdQIZkEP289mD2fPZg/v/2YPZ8RmD2/jZg9x1Qhm"
    . "QQ/b32YPcdQIZg9n3mYP2tlmD2flZg/a4GYPdMtmD3TEZkEPdNFmD9vQZg/b0WYP2xW1CAAAZg9vwmYPYMdmD2/IZg9o12ZBD2nEZkEPYcxmD/7BZg9vymZBD2nUZkEPYcxm"
    . "D/7RZg/+wmZED/7oD4VW/v//RItEJBROjRQ3ZkEPb8VmD3PYCESLfCQQTo0MM2ZBD/7FZg9vyGYPc9kEZg/+wWYPfsFBDxLFZkQP/uhBifNFKcNBg/sHD4YqAgAAScHgAmZB"
    . "D2/OZkEPb8ZKjQwDZkEPb/5JAfjzD34RZkEPb95mQQ9v9mZFD2/W80QPfmEIQYPj+PMPfmkQZg/bymYPcdIIRSnf80QPflkYZkEP28RmD2fIZkEPb8bzRQ9+SAhmD9v9ZkEP"
    . "cdQIZg9wyQhmQQ/bw2YPZ/jzQQ9+AGYPcdUI80EPfmAQZkEP2/FmQQ9n1GZBD3HTCPNFD35AGGYP29hmD2feZkEPb/ZmD9v0Zg9x0AhmD3DSCGZBD2frZkUP29BmQQ9x0Qhm"
    . "D3DtCGZBD9vWZg9x1AhmQQ/b7mZBD2fBZg9n1WZBD3HQCGYPcNIIZg9wwAhmQQ/bxmZBD2fgZg9w5AhmQQ/b5mYPZ8RmD3DACGYP2sJmD3D/CGYPb+dmD3TCZg9v0WYPcNsI"
    . "ZkEPZ/JmD3HUCGYPcPYIZg9v7mZBD9v+Zg9x0ghmQQ/b9mZBD9vOZg9nz2YPZ9RmD2/jScHjAmYPcdUIZg9x1AhmD3DSCE0B2mYPcMkIZg9n5WZBD9veZg9w5AhNAdlmD2fe"
    . "Zg/a4mYPcNsIZg/a2WYPdNRmD+/t8w9+fCQI8w9+NXYGAABmD3TLZg/v22YP28JmD9vIZg/bzmYPb9FmD2DLZg9g02YPcMlOZg9v2WYPb8FmD2/KZg9h3WYPYcVmD2HVZg9h"
    . "zWYPcMBOZg9w0k5mD/7DZg/+0WYP/sJmQQ/+xWYPb8hmDzgADR0GAABmD+vPZg/+wWYPfsFFD7ZZAkU4WgJFD7ZZAUEPk8BFOFoBQQ+Tw0Uhw0UPtgFFOAJBD5PARQ+2wEUh"
    . "2EQBwUGD/wEPhJ8BAABFD7ZZBUU4WgVFD7ZZBkEPk8BFOFoGQQ+Tw0Uhw0UPtkEERThCBEEPk8BFD7bARSHYRAHBQYP/Ag+EYQEAAEUPtlkKRThaCkUPtlkJQQ+TwEU4WglB"
    . "D5PDRSHDRQ+2QQhFOEIIQQ+TwEUPtsBFIdhEAcFBg/8DD4QjAQAARQ+2WQ5FOFoORQ+2WQ1BD5PARThaDUEPk8NFIcNFD7ZBDEU4QgxBD5PARQ+2wEUh2EQBwUGD/wQPhOUA"
    . "AABFD7ZZEkU4WhJFD7ZZEUEPk8BFOFoRQQ+Tw0Uhw0UPtkEQRThCEEEPk8BFD7bARSHYRAHBQYP/BQ+EpwAAAEUPtlkWRThaFkUPtlkVQQ+TwEU4WhVBD5PDRSHDRQ+2QRRF"
    . "OEIUQQ+TwEUPtsBFIdhEAcFBg/8GdG1FD7ZZGkU4WhpFD7ZZGUEPk8BFOFoZQQ+Tw0Uhw0UPtkEYRThCGEEPk8BFD7bARSHYRAHBQYP/B3QzRQ+2eR5FOHoeRQ+2eR1BD5PA"
    . "RTh6HUUPtnkcQQ+Tw0UxyUUh2EU4ehxBD5PBRSHBRAHJSAHDSAHHKc1IAdNFKex0CUE57A+Nvfn//0iLTCQghe0PjtYAAABIg8EESDlMJDAPgqAAAABEi0QkPEWFwA+EX/n/"
    . "/0yJ8EiJykGJ9kiLfCRQRA+2VCQoSInGTItEJDCLTCRgTIukJKgBAADpk/j//0mJ2UmJ+kWJ72ZFD+/tRTHAMcnpY/v//0iLVCQoSAH6STnQD4OA+P//QYnuSAF8JECDwQFJ"
    . "Afg5TCRkD40z+P//McnrXEmJwesHDx9AAEyJyE2FyQ+FswAAAEyNDDhNOchz6+vHTInwSIt8JFBBifaLTCRgSInGRA+2VCQoTItEJDBMi6QkqAEAAOugSIucJKgBAABIhdt0"
    . "CItEJDgp6IkDDxB0JHBIicgPELwkgAAAAEQPEIQkkAAAAEQPEIwkoAAAAEQPEJQksAAAAEQPEJwkwAAAAEQPEKQk0AAAAEQPEKwk4AAAAEQPELQk8AAAAEQPELwkAAEAAEiB"
    . "xBgBAABbXl9dQVxBXUFeQV/DTInI6en3//+QVlNIg+xox0QkXAAAAABIjXQkXEiJy+tPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQk"
    . "OItDQIlEJChIi0M4SIlEJCBMi0sw6D71//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9"
    . "CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwi4QkwAAAAEiLnCTQAAAAZg9ujCS4AAAAZkgPbtJmSA9uwYhEJGhmQQ9u2WYPbMIPEUQkOGZBD27A"
    . "i4QkyAAAAGYPYsNmD9ZEJEjzD36EJKAAAABMjUQkIMdEJCAAAAAASI0VxP7//w8WhCSoAAAASMdEJCgAAAAADxFEJFBmD26EJLAAAABIx0QkMAAAAABmD2LBiUQkbGYP1kQk"
    . "YP+RsAAAAEiF23QGi0QkMIkDSItEJChIg8RwW8NmkDHAw2ZmLg8fhAAAAAAAZpAAAQIEBQYICQoMDQ6AgICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICA"
    . "gICAgAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQYICQoMDQ4DBAIDBAUGBwgJCgsMDQ4PCQoCAwQFBgcICQoLDA0ODw+AgICAgICAgICAgICAgICAAAIDBAUG"
    . "BwgJCgsMDQ4PBQYCAwQFBgcICQoLDA0ODwsMAgMEBQYHCAkKCwwNDg8BAgIDBAUGBwgJCgsMDQ4PBwgCAwQFBgcICQoLDA0ODw0OAgMEBQYHCAkKCwwNDg//AP8A/wD/AP8A"
    . "/wD/AP8AAQEBAQEBAQEBAQEBAQEBAQQFBgeAgICAgICAgICAgICAgICAAAECA4CAgICAgICA"
    mcode_imgutil_column_uniform := 0x000000 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000120 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x0001d0 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x000b00 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x001630 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_get_blob_psabi_level   := 0x0016f0 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    }

    ; -march=x86-64 baseline optimized machine code blob (mmx huh)
    i_get_mcode_map_v1() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 2224 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTi1wkSESJyEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhIAdBIjRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPC"
    . "BEw52nNHD7ZKAUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusS"
    . "Zi4PH4QAAAAAAEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItc"
    . "JEBIY9JIic5IY0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2wEUPtsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFE"
    . "KcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0QPtlQkKEFpwgABAQBECdANAAAA/2YPbuBmD3DcAIP6A35RRI1a/GYPb8sxwEWJ"
    . "2kHB6gJBjVIBSMHiBA8fQADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnQddxB99pIAcFJAcFJAcBDjRSThdJ0XmYPbgFmD2/IZg/cw2YP2MtmQQ9+AWZBD34I"
    . "g/oBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35BBGZBD35IBIP6AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+QAhmQQ9+WQgxwMMPH4AAAAAAQVdBVkFVQVRVV1ZTSIPsWA8RdCRA"
    . "i7wkyAAAAIucJNgAAABIi4Qk6AAAAIn+TYnPRIuMJNAAAABJicpIY8oPvtNBD6/xD6/WiXQkMEiLtCTAAAAATGPawfofTWnbH4XrUUnB+yVBKdOA+2S6AQAAAA9FlCTgAAAA"
    . "RIlcJCxFD7ZfAUGJ1kEPtlcCQcHjCMHiEEQJ2kUPth9ECdpED7ZeAWYPbtIPtlYCQcHjCGYPcNIAweIQRAnaRA+2HkQJ2oHKAAAA/0UpyGYPbspEiUQkPGYPcMkAD4ieAAAA"
    . "i3QkMEhj10iJzYtcJCxIKdVIweECZg9228dEJDgAAAAASMHlAjneSImEJOgAAABBD53AhfYPlcJBIdBEiEQkN0SNR/xEicLB6gJEjVoB99pFjSSQScHjBEmJyEiJ6UyJ0kwB"
    . "0XIkTInQRYX2dArpUwEAAGaQSInQSIXSD4WyAQAASo0UAEg50XPrg0QkOAGLTCQ8TQHCi0QkODnIfr0x0unQAgAATQHaTQHZTAHbRInghcAPhLkAAABmQQ9uKWYPbjNmQQ9u"
    . "ImYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBQQHQg/gBdHNmQQ9uaQRmD25zBGZBD25iBGYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBQQHQ"
    . "g/gCdDdmD25jCGZBD25BCGZBD25qCGYPb/RmD97oZg/e8GYPdMVmD3TmZg/bxGYPdsNmD9fQg+IBQQHQSMHgAkkBwkgBw0kBwUiLRCQIRCnGSQHBQSn9dAlEOe4PjuoAAABI"
    . "i1QkEIX2D47IAQAASItEJBhIg8IESDnQD4LkAQAARYX2D4SVAAAASItsJAhMi0QkIE2J+kmJz0iJwUiJ00iJyEiJ2kgp2EjB+AKDwAGD+AN/F+kkAQAAZpCD6ARIg8IQg/gD"
    . "D44SAQAA8w9vAmYPb+pmD2/hZg/e4GYP3uhmD3TFZg904WYP28RmD3bDZkQP18hFhcl0wvNFD7zJQcH5AkljwUiNFIJIiWwkCEyJRCQgSIlMJBhMiflNideAfCQ3AIt0JCwP"
    . "hDn///9IiVQkEESLbCQwSYnRSYnKSIucJMAAAACLdCQsZpAx0kUxwIn4g/8DD44s/v//80EPbwQR80EPbzQS8w9vLBPzD28kE0iDwhBmD97wZg/e6GYPdMZmD3TlZg/bxGYP"
    . "dsNmD9fAicXR7YHlVVVVVSnoicXB6AKB5TMzMzMlMzMzMwHoicXB7QQBxYHlDw8PD4nowegIAeiJxcHtEAHowegCg+APQQHATDnadYPpnv3//4XAdERMjQyC6w0PH0AASIPC"
    . "BEw5ynQxZg9uAmYPb+pmD2/hZg/e4GYP3uhmD3TFZg904WYP28RmD3bDZg/XwKgBdMvp5P7//0wBw0g52Q+Dbv7//+kq/f//SIuEJOgAAABIhcB0CItMJCwp8YkIDxB0JEBI"
    . "idBIg8RYW15fXUFcQV1BXkFfw02J+kiLbCQITItEJCBJic/p5/z//2aQVlNIg+xox0QkXAAAAABIictIjXQkXOtPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJ"
    . "RCRAD75DSESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6B77//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGG"
    . "CoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwSIuEJKAAAABIi5wk0AAAAEiJRCRQSIuEJKgAAABIiVQkQEiNFQL///9I"
    . "iUQkWIuEJLAAAABEiUQkSEyNRCQgiUQkYIuEJLgAAADHRCQgAAAAAIlEJGSLhCTAAAAASMdEJCgAAAAAiEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+RsAAA"
    . "AEiF23QGi0QkMIkDSItEJChIg8RwW8MPH4AAAAAAuAEAAADDkJCQkJCQkJCQkA=="
    mcode_imgutil_column_uniform := 0x000000 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000120 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x0001c0 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x0002a0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x0007f0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_get_blob_psabi_level   := 0x0008a0 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                   
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    }

    ; -march=x86-64-v2 optimized SSE4 machine code blob
    i_get_mcode_map_v2() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 2192 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTi1wkSESJyEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhIAdBIjRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPC"
    . "BEw52nNHD7ZKAUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusS"
    . "Zi4PH4QAAAAAAEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItc"
    . "JEBIY9JIic5IY0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2wEUPtsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFE"
    . "KcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0QPtlQkKEFpwgABAQBECdANAAAA/2YPbuBmD3DcAIP6A35RRI1a/GYPb8sxwEWJ"
    . "2kHB6gJBjVIBSMHiBA8fQADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnQddxB99pIAcFJAcFJAcBDjRSThdJ0XmYPbgFmD2/IZg/cw2YP2MtmQQ9+AWZBD34I"
    . "g/oBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35BBGZBD35IBIP6AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+QAhmQQ9+WQgxwMMPH4AAAAAAQVdBVkFVQVRVV1ZTSIPsWA8RdCRA"
    . "i7wkyAAAAIucJNgAAACJ/k2Jz0SLjCTQAAAASInID77LQYnSSIuUJOgAAABBD6/xD6/OiXQkMEiLtCTAAAAATGPZwfkfTWnbH4XrUUnB+yVBKcuA+2S5AQAAAA9FjCTgAAAA"
    . "RIlcJCxFD7ZfAUGJzkEPtk8CQcHjCMHhEEQJ2UUPth9ECdlED7ZeAWYPbtEPtk4CQcHjCGYPcNIAweEQRAnZRA+2HkQJ2YHJAAAA/0UpyGYPbslEiUQkPGYPcMkAD4iaAAAA"
    . "SWPKi3QkMExjx4tcJCxIic1IweECSYnCZg9220wpxcdEJDgAAAAASYnVSMHlAjneQQ+dwYX2QQ+VwEUhwUSNR/xEicBEiEwkN0WJ8cHoAkSNWAH32EnB4wRFjSSASInqTInQ"
    . "TAHSch5NidBFhcl0COkqAgAASYnASIXAdXRJjQQISDnCc++DRCQ4AYt0JDxJAcqLRCQ4OfB+wzHA6cQCAAAPH0AARYXAD4SGAgAASo0cgOsOkEiDwARIOdgPhHICAABmD24A"
    . "Zg9v6mYPb+FmD97gZg/e6GYPdMVmD3ThZg/bxGYPdsNmRA/XwEGD4AF0xEiJTCQYTYnoSIlUJBBMiVQkIIB8JDcAi3QkLA+EXQEAAEiJRCQIRIt0JDBJicJMiftMi6wkwAAA"
    . "AIt0JCwPH4AAAAAAMcAxyYP/Aw+O6wEAAA8fAPNBD28EAvMPbzQD80EPb2wFAPNBD29kBQBIg8AQZg/e8GYP3uhmD3TGZg905WYP28RmD3bDZg/X0PMPuNLB+gIB0Uw52HW5"
    . "TAHbTQHaTQHdRInghcAPhLcAAABmQQ9uKmZBD251AGYPbiNmD2/FZg/e5WYP3sZmD3TlZg90xmYP28RmD3bDZg/X0IPiAQHRg/gBdHFmQQ9uagRmQQ9udQRmD25jBGYPb8Vm"
    . "D97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBAdGD+AJ0NmZBD25lCGZBD25CCGYPbmsIZg9v9GYP3uhmD97wZg90xWYPdOZmD9vEZg92w2YP19CD4gEB0UjB4AJIAcNJ"
    . "AcVJAcIpzkkB6kEp/nQJRDn2D47L/v//SItEJAiF9g+O4AAAAEiLVCQQSIPABEg5wg+CvAAAAEWFyQ+Ecf7//0iLTCQYTItUJCBNicVIicZJidBIifBJKfBJwfgCQYPAAUGD"
    . "+AN/Hunn/f//Dx+AAAAAAEGD6ARIg8AQQYP4Aw+Ozv3///MPbwBmD2/qZg9v4WYP3uBmD97oZg90xWYPdOFmD9vEZg92w2YP19iF23TC8w+820iJTCQYwfsCSIlUJBBMY8NM"
    . "iVQkIEqNBIBNiejp2/3//w8fRAAAifjpZP7//0gBzkg58g+DYv///+lB/f//SItMJBhMi1QkIE2Jxekv/f//TYXAdAmLTCQsKfFBiQgPEHQkQEiDxFhbXl9dQVxBXUFeQV/D"
    . "Zi4PH4QAAAAAAFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQg"
    . "TItLMOg++///SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69D"
    . "RDtEJFx/pItDLIcD651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBIjRUC////SIlEJFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAA"
    . "x0QkIAAAAACJRCRki4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlEJGz/kbAAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAALgC"
    . "AAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000000 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000120 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x0001c0 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x0002a0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x0007d0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_get_blob_psabi_level   := 0x000880 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
    
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    }

    ; -march=x86-64-v3 optimized AVX2 machine code blob
    i_get_mcode_map_v3() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 2576 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTi1wkSESJyEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhIAdBIjRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPC"
    . "BEw52nNHD7ZKAUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusS"
    . "Zi4PH4QAAAAAAEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItc"
    . "JEBIY9JIic5IY0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2wEUPtsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFE"
    . "KcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0QPtlQkKEFpwgABAQBECdANAAAA/8X5btDE4n1Y0oP6B35Pg+oIxf1vyjHAQYnT"
    . "QcHrA0WNUwFJweIFDx9EAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQBSIPAIEw50HXeQffbSAHBSQHBSQHAQo0U2sX5b8KD+gN+J8X6byFJg8EQSIPBEEmDwBCD6gTF2djK"
    . "xMF6f0jwxenczMTBen9J8IXSdFLF+W4JxfHY0MX53MnEwXl+EMTBeX4Jg/oBdDfF+W5JBMXx2NDF+dzJxMF5flAExMF5fkkEg/oCdBnF+W5RCMXp2MjF+dzCxMF5fkgIxMF5"
    . "fkEIMcDF+HfDZpBBV0FWQVVBVFVXVlNIgey4AAAAxfgRdCRAxfgRfCRQxXgRRCRgxXgRTCRwxXgRlCSAAAAAxXgRnCSQAAAAxXgRpCSgAAAAi7wkKAEAAESLnCQwAQAAi7Qk"
    . "OAEAAIn4QQ+vw0xj0kAPvtZNic9Mi4wkSAEAAA+v0Ehj2sH6H0hp2x+F61FIwfslKdNAgP5kugEAAAAPRZQkQAEAAIlcJChBD7ZfAYnVQQ+2VwLB4wjB4hAJ2kEPth8J2kiL"
    . "nCQgAQAAxXluwg+2UwIPtlsBxEJ9WMDB4wjB4hAJ2kiLnCQgAQAAD7YbCdpEicOBygAAAP/F+W76xOJ9WP9EKdsPiBYEAABIY9dNidSLdCQoiVwkPEkp1MXtdtLF8XbJQYnu"
    . "ScHkAjnwxXl/xUyJzUqNFJUAAAAAQQ+dwoXAQQ+VwMV5f8ZFIcJEiFQkL0SNV/hFidBBwegDRY1YAUH32EeNLMJJweMFRTHATInjxflv38X5b+dJicpIAcsPgocDAABIiUwk"
    . "MEiJ6USJ9USJRCQ46xZNhdIPhQcDAABNjRQRTDnTD4JPAwAATYnRhe1040mJ2U0p0UnB+QJBg8EBQYP5Bw+OUwIAAMRBfW/YxX1v102J0OsYZg8fRAAAQYPpCEmDwCBBg/kH"
    . "D44wAgAAxMF+bwDFLd7IxSXe4MWddMDEQTV0ysW128DF/XbCxf3X8IX2dMjzD7z2SIlUJCBIiYwkSAEAAIPmPE2NFDCAfCQvAIt0JCgPhKQBAACJRCQMi3QkKEyJ0kyJ+UiJ"
    . "XCQQTIuEJCABAABBicZMiVQkGGYPH0QAADHARTHSQYn5g/8HfkoPHwDF/m8EAsRBfd4MAMV93hQBxEE1dAwASIPAIMWtdMDFtdvAxf12wsV918jzRQ+4yUHB+QJFAcpMOdh1"
    . "xUwB2U0B2EwB2kWJ6UGD+QMPjk8BAADF+m8CQYPpBEiDwRBJg8AQxEF53kjwxXneUfBIg8IQxEExdEjwxal0wMWx28DF+XbBxfnXwPMPuMDB+AJFhckPhLEAAADFeW4SxEF5"
    . "bhjFeW4JxEEp3snEwSnew8WhdMDEQTF0ysWx28DF+XbBxfnX2IPjAQHYQYP5AXRtxXluUgTEQXluWATFeW5JBMRBKd7JxMEp3sPFoXTAxEExdMrFsdvAxfl2wcX519iD4wEB"
    . "2EGD+QJ0M8X5bkIIxEF5bkgIxXluUQjFMd7YxEF53tLFqXTAxEExdMvFsdvAxfl2wcX519iD4wEB2EnB4QJMAclNAchMAcpEAdBMAeIpxkEp/nQJRDn2D46T/v//i0QkDEiL"
    . "XCQQTItUJBiF9g+ObQEAAEmDwgRMOdMPgi0BAACF7Q+EMP7//0iLVCQgSIuMJEgBAADpov3//2YPH0QAADHA6eb+//9NidBBg/kDfi7EwXpvAMVh3sjFed7Vxal0wMRBYXTJ"
    . "xbHbwMX5dsHF+dfwhfZ1ckmDwBBBg+kERYXJD4SRAAAAS400iOsMDx8ASYPABEk58HR0xMF5bgDFWd7IxUne0MWpdMDFMXTMxbHbwMX5dsHFedfIQYPhAXTQTYnRTYnCTYXS"
    . "D4T5/P//SIlUJCBIiYwkSAEAAOl3/f//Dx+AAAAAAGbzRA+8zkiJVCQgZkHB6QJIiYwkSAEAAEUPt8lPjRSI6Uv9//9FMcBNidFNicLrrkkB0kw50w+DuPz//0GJ7kSLRCQ4"
    . "SInNSItMJDCLXCQ8QYPAAUgB0UE52A+OTvz//0Ux0utJRItEJDhIi1QkIEGJ7kiLTCQwi1wkPEGDwAFIi6wkSAEAAEgB0UE52A+OG/z//+vLDx8ATIuMJEgBAABNhcl0CYtE"
    . "JCgp8EGJAcX4d8X4EHQkQMX4EHwkUEyJ0MV4EEQkYMV4EEwkcMV4EJQkgAAAAMV4EJwkkAAAAMV4EKQkoAAAAEiBxLgAAABbXl9dQVxBXUFeQV/DZmYuDx+EAAAAAABmkFZT"
    . "SIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOje+f//SIXA"
    . "dSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD"
    . "651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBIjRUC////SIlEJFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRk"
    . "i4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlEJGz/kbAAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAALgDAAAAw5CQkJCQkJCQ"
    . "kJA="
    mcode_imgutil_column_uniform := 0x000000 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000120 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x0001c0 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x0002c0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x000950 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_get_blob_psabi_level   := 0x000a00 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform  
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                )
    } 

    ; -march=x86-64-v4 optimized AVX512 machine code blob
    i_get_mcode_map_v4() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 2224 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTRItUJEhMY8KLVCRYRInIRYnLTGNMJEAPttxBwesQQQ+v0Ehj0kwBykiNNJGLVCRQQQ+v0Ehj0kwBykiNFJFIOfJzakUPttsPtttED7bIQYP4AXQS62cPH4AAAAAASIPC"
    . "BEg58nNHD7ZKASnZicj32A9IwQ+2SgJEKdlBichB99hBD0nIOcgPTMEPtgpEKclBichB99hBD0nIOcgPTMFBOcJ9ujHAW15fww8fQAC4AQAAAFteX8MPH4AAAAAAScHgAusS"
    . "Zi4PH4QAAAAAAEwBwkg58nPYD7ZKAkQp2YnI99gPSMEPtkoBKdmJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTMFBOcJ9wTHA65VmZi4PH4QAAAAAAGaQVlMPr1QkOExj"
    . "RCRQRItUJEBIY9JJAdBEichEictKjTSBTGNEJEgPtsTB6xBMAcJIjRSRSDnyc2APtttED7bYRQ+2yesMDx8ASIPCBEg58nNHD7ZKAinZicj32A9IwQ+2SgFEKdlBichB99hB"
    . "D0nIOcgPTMEPtgpEKclBichB99hBD0nIOcgPTMFBOcJ9ujHAW17DDx9EAAC4AQAAAFtew0QPtlQkKEFpwgABAQBECdANAAAA/2LyfUh80IP6D35ag+oQYvH9SG/KMcBBidNB"
    . "wesERY1TAUnB4gZmDx9EAABi8X9IbxwBYvFlSNjBYtH+SH8EAGLxdUjcw2LR/kh/BAFIg8BATDnQddZBweMESAHBSQHBSQHARCnahdJ0L7gBAAAAxOJp98CD6AHF+JLIYvF+"
    . "yW8BYvF9SNjKYvF9SNzCYtF+SX8IYtF+SX8BMcDF+HfDZmYuDx+EAAAAAABmkEFXQVZBVUFUVVdWU0iD7DiLvCSoAAAARIucJLgAAABMi7wkyAAAAIn7TImMJJgAAACJ1kEP"
    . "vtNEi4wksAAAAEiJyLkBAAAAQQ+v2Q+v04lcJBhIi5wkmAAAAExj0sH6H01p0h+F61FJwfolQSnSD7ZTAkGA+2QPRYwkwAAAAESJVCQURA+2UwHB4hBBweIIRAnSRA+2E0iL"
    . "nCSgAAAARAnSRA+2UwFi8n1IfOoPtlMCQcHiCMHiEEQJ0kQPthNEicNECdKBygAAAP9i8n1IfOJEKcsPiDQDAABMY8ZIY9eLdCQURI1n8EyJxUmJwUSJ4EGJ3kgp1YtUJBhO"
    . "jSyFAAAAAGLzdUglyf9IweUCOfJBD53AhdIPlcLB6ARFMdJEjVgBweAEQSHQQSnERInCScHjBk2JyESJZCQsQYnRSInqTInAYvH9SG/dTAHCD4KrAgAATIlsJAhNicRFidVJ"
    . "idBFicqLVCQsTIn76yEPH0AASYnHSIXAD4WFAAAASItEJAhMAfhJOcAPgoQCAACFyXTfYvH9SG/UTYnBSInGSSnBScH5AkGDwQFBg/kPfxzp0AEAAA8fRAAAQYPpEEiDxkBB"
    . "g/kPD465AQAAYvF/SG8GYvN9SD7LBWLzfUk+ygJi8n5IKMFi831IH8EAxfiYwHTHxfiTwGbzD7zAD7fASI0EhkyJBCRJicFEiWwkHESJdCQoTIlkJCBIiZwkyAAAAInLi0Qk"
    . "FEWE0g+E/gAAAItEJBSLdCQYTYnNTYnMTIu8JKAAAABMi7QkmAAAAEGJ0YnCifAPH0QAADHJMfZMY8eD/w9+Sg8fQABi0X9Ib1QNAGLTbUg+DA4FYtNtST4MDwJIg8FAYvJ+"
    . "SCjBYvN9SB/ZAMV4k8PzRQ+4wEQBxkk5y3XGTQHeTQHfTQHdTWPBRYXAD4S5AAAAuQEAAAAp+MTiOffJg+kBScHgAsX7ksli0X7Jb0UAYsF+yW8OTQHGYtF+yW8XTQHHSQHo"
    . "YrN9SD7RBU0BxWLzfUo+0gJi8n5IKMJi831JH+EAxfiTzGbzD7jJD7fJAfEpyjnCfwiFwA+FNP///4nQRInKTYnhhcAPjjwBAABJg8EETDkMJA+C9gAAAIXbD4TX/v//idlM"
    . "iwQkRItsJBxMichEi3QkKEyLZCQgSIucJMgAAADpIv7//5Ap8kkB7Sn4dKs5wg+O1/7//+uhRYXJdFVBvwEAAADEQjH3z0GD6QHEwXiSyWLhfslvBmLzfUA+1QVi831CPsQC"
    . "YuJ+SCjAYvN9QR/JAMX4mMl0GsV4k8lm80UPvMlJicdFD7fJSo0EjumW/f//SIt0JAhIAfBJOcAPg6n9//9FidFNieBFiepJid9JifVBg8IBTQHoRTnyD44w/f//McDrekWJ"
    . "0UWJ6kyLbCQITYngQYPCAUmJ300B6EU58g+OC/3//+vZDx9AAEWJ0USLVCQcTItsJAiJ2UyLRCQgRIt0JChBg8IBTIu8JMgAAABNAehFOfIPjtT8///rog8fRAAATIu8JMgA"
    . "AACJxkyJyE2F/3QJi1QkFCnyQYkXxfh3SIPEOFteX11BXEFdQV5BX8OQVlNIg+xox0QkXAAAAABIictIjXQkXOtPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJ"
    . "RCRAD75DSESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6P76//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGG"
    . "CoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwSIuEJKAAAABIi5wk0AAAAEiJRCRQSIuEJKgAAABIiVQkQEiNFQL///9I"
    . "iUQkWIuEJLAAAABEiUQkSEyNRCQgiUQkYIuEJLgAAADHRCQgAAAAAIlEJGSLhCTAAAAASMdEJCgAAAAAiEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+RsAAA"
    . "AEiF23QGi0QkMIkDSItEJChIg8RwW8MPH4AAAAAAuAQAAADDkJCQkJCQkJCQkA=="
    mcode_imgutil_column_uniform := 0x000000 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
    mcode_imgutil_row_uniform    := 0x000120 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
    mcode_imgutil_make_sat_masks := 0x0001c0 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
    mcode_imgutil_imgsrch        := 0x000280 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_imgutil_imgsrch_multi  := 0x0007f0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
    mcode_get_blob_psabi_level   := 0x0008a0 ; u32 get_blob_psabi_level (void);
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                                                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                    )
    }

    i_get_mcode_map_base() {
        ; this can't be part of the main blob as we don't want GCC to taint it with
        ; vectorization or the use of other instructions that may not be available
        ; on older CPUs
        static b64 := ""
        . "" ; imgutil_lib.c
        . "" ; 2272 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "SIsF0QgAAEiJQTy4AQAAAMcBAwAAAMNmDx+EAAAAAABIi0oQSP9iCA8fhAAAAAAAV1ZTSIPsQEiJy0iFyXRxSIlMJCBIiVQkKEiNVCQgTIlEJDBMi4GYAAAASI0Nv/////9T"
        . "UEiJx0iFwHREi4OoAAAAhcB0GzH2Dx+EAAAAAABIifmDxgH/U1g7s6gAAABy7zHSSIn5/1NgSIn5/1NouAEAAABIg8RAW15fww8fQAAxwEiDxEBbXl/DZg8fRAAAQVVBVFVX"
        . "VlNIg+wYRTHJnJxngTQkAAAgAJ2cWGczBCSdJQAAIACFwA+EgQAAAEyNFQsGAABEichEickx/w+iSY2q0AEAAEGJxESJybgAAACAD6JBicVBi0IMRYsCQTnBRA9CyEGB+AAA"
        . "AIB2U0U5xXJYRDsFlwcAAEWLWghJY3IEdB1EicCJ+USJBYEHAAAPookEJIlcJASJTCQIiVQkDEQjHLR0JEmDwhBJOep1p0SJyEiDxBhbXl9dQVxBXcOQRTnEc61FhcB4qEGD"
        . "6QFEichIg8QYW15fXUFcQV3DZpBlSIsEJWAAAABIi0AYSItAIEiLAEiLAEiLQCDDR2V0UHJvY0FkZHJlc3MADx9EAABWU0mJy0yJ2YtBPEgByEiNQBhIjUBwSIvAixBIjQQR"
        . "i1gYi1Aghdt0U0Ux0kmNNBNCixSWQbhHAAAATI0Nq////0wB2g+2CoTJdR7rJg8fAEQ4wXUeD7ZKAUiDwgFJg8EBRQ+2AYTJdAVFhMB14kQ4wXQOSYPCAUk52nW0McBbXsOL"
        . "UCRLjQxTi0AcD7cUEUmNFJOLBAJMAdhbXsMPH0AAV1ZTSIPsMDHbx0QkLAAAAABIic5IjXwkLOszDx9EAAD/loAAAACD+HoPhYEAAABIhdt0BkiJ2f9WKItUJCy5QAAAAP9W"
        . "IEiJw0iFwHRiSIn6SInZ/1Z4hcB0xYtEJCyD+B92WESNQOAx0kiJ2EWJwUHB6QVBjUkBSMHhBUgB2ZCDeAgBg9IASIPAIEg5wXXwQcHhBUSJwInXRCnIiUQkLEiJ2f9WKIn4"
        . "SIPEMFteX8Mx/4n4SIPEMFteX8Mx/+vgR2xvYmFsRnJlZQBHbG9iYWxBbGxvYwBMb2FkTGlicmFyeUEARnJlZUxpYnJhcnkAQ3JlYXRlVGhyZWFkcG9vbABTZXRUaHJlYWRw"
        . "b29sVGhyZWFkTWF4aW11bQBTZXRUaHJlYWRwb29sVGhyZWFkTWluaW11bQBDcmVhdGVUaHJlYWRwb29sV29yawBTdWJtaXRUaHJlYWRwb29sV29yawAPH4AAAAAAV2FpdEZv"
        . "clRocmVhZHBvb2xXb3JrQ2FsbGJhY2tzAENsb3NlVGhyZWFkcG9vbFdvcmsAQ2xvc2VUaHJlYWRwb29sAA8fRAAAR2V0TG9naWNhbFByb2Nlc3NvckluZm9ybWF0aW9uAEdl"
        . "dExhc3RFcnJvcgBRdWVyeVBlcmZvcm1hbmNlQ291bnRlcgBRdWVyeVBlcmZvcm1hbmNlRnJlcXVlbmN5AGaQQVVBVFVXVlNIg+woZUiLBCVgAAAASItAGEiLQCBIiwBIiwBI"
        . "i0AgSInGic1IhcAPhNsBAABIicHoE/3//0iNFWz+//9IifFIicf/0EiNFWj+//9IifFJicX/17q4AAAAuUAAAABJicT/0EiJw0iFwA+EmgEAAEiNBTP7//9IjRVD/v//SInx"
        . "SIkzSImDsAAAAEyJYyBIiXsITIlrKP/XSI0VLv7//0iJ8UiJQxD/10iNFSr+//9IifFIiUMYSI0FvPr//0iJQzD/10iNFSD+//9IifFIiUM4/9dIjRUr/v//SInxSIlDQP/X"
        . "SI0VNv7//0iJ8UiJQ0j/10iNFTv+//9IifFIiUNQ/9dIjRVH/v//SInxSIlDWP/XSI0VVv7//0iJ8UiJQ2D/10iNFVr+//9IifFIiUNo/9dIjRVf/v//SInxSIlDcP/XSI0V"
        . "bv7//0iJ8UiJQ3j/10iNFWv+//9IifFIiYOAAAAA/9dIjRVw/v//SInxSImDiAAAAP/XuUAAAAC6SAAAAEiJg5AAAABB/9RIiYOYAAAASInBSIXAdGf/UzAxyf9TOEiJg6AA"
        . "AABIicFIhcB0RoXtdGqJ6omrqAAAAP9TQIuTqAAAAEiLi6AAAAD/U0hIi4OYAAAASIuToAAAAEiJUAhIidhIg8QoW15fXUFcQV3DDx9EAABIi4uYAAAA/1MoSInZQf/VMdtI"
        . "idhIg8QoW15fXUFcQV3DZg8fRAAASInZ6MD7//9Ii4ugAAAAicXrgw8fRAAAU0iD7CBIictIhcl0I0iLiaAAAAD/U3BIi0MoSInZSIPEIFtI/+BmLg8fhAAAAAAASIPEIFvD"
        . "Zi4PH4QAAAAAAAEAAAADAAAAAQAAAAEAAAABAAAAAwAAAAABAAABAAAAAQAAAAMAAAAACAAAAQAAAAEAAAADAAAAAIAAAAEAAAABAAAAAwAAAAAAAAEBAAAAAQAAAAMAAAAA"
        . "AIAAAQAAAAEAAAADAAAAAAAAAQEAAAABAAAAAwAAAAAAAAIBAAAAAQAAAAMAAAAAAAAEAQAAAAEAAAACAAAAAQAAAAIAAAABAAAAAgAAAAAgAAACAAAAAQAAAAIAAAAAAAgA"
        . "AgAAAAEAAAACAAAAAAAQAAIAAAABAAAAAgAAAAAAgAACAAAAAQAAgAIAAAABAAAAAgAAAAEAAAACAAAAABAAAAMAAAABAAAAAgAAAAAAQAADAAAAAQAAAAIAAAAAAAAIAwAA"
        . "AAEAAAACAAAAAAAAEAMAAAABAAAAAgAAAAAAACADAAAAAQAAgAIAAAAgAAAAAwAAAAcAAAABAAAACAAAAAMAAAAHAAAAAQAAACAAAAADAAAABwAAAAEAAAAAAQAAAwAAAAcA"
        . "AAABAAAAAAABAAQAAAAHAAAAAQAAAAAAAgAEAAAABwAAAAEAAAAAAAAQBAAAAAcAAAABAAAAAAAAQAQAAAAHAAAAAQAAAAAAAIAEAAAA/////w8fQAABAAAASAAAAA=="
        mcode_mt_run                             := 0x000030 ; u32 mt_run (mt_ctx *, mt_worker_t, ptr);
        mcode_get_cpu_psabi_level                := 0x0000c0 ; int get_cpu_psabi_level (void);
        mcode_gpa_getkernel32                    := 0x0001a0 ; ptr gpa_getkernel32 (void);
        mcode_gpa_getgetprocaddress              := 0x0001d0 ; GetProcAddress_t gpa_getgetprocaddress (ptr modulehandle);
        mcode_mt_get_cputhreads                  := 0x000270 ; int mt_get_cputhreads (mt_ctx *ctx);
        mcode_mt_init                            := 0x000480 ; mt_ctx *mt_init (u32);
        mcode_mt_deinit                          := 0x0006c0 ; void mt_deinit (mt_ctx *);
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
    } ;; end of img class

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
            NumPut("int", this.r(), d3dbox.ptr +  8)
            NumPut("int", this.b(), d3dbox.ptr + 12)
            NumPut("int", 0,        d3dbox.ptr + 16)
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
    ; with dx11 screengrabs, we get a copy of the entire screen (really fast). we could muck around and
    ; copy the rectangle of interest into a new buffer, or we can just keep track of the coordinate
    ; offsets and have caller do the math. we have caller do the math. this is the origin of the image 
    ; relative to the screen.
    offs_x  := 0            ; x offset of image 
    offs_y  := 0            ; y offset of image 

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
        static d3d_device  := 0
        static d3d_context := 0
        static ptr_dxgi_output1 := 0
        static ptr_dxgi_dup := 0
        static using_system_memory := 0

        static init_successful := 0
        static last_init_attempt := 0
        static last_monitor_rect := 0

        static D3D11_TEXTURE2D_DESC            := Buffer(44, 0)
        static D3D11_TEXTURE2D_DESC_subregion  := Buffer(44, 0)
        static DXGI_OUTDUPL_FRAME_INFO         := Buffer(48, 0)
        static D3D11_MAPPED_SUBRESOURCE        := Buffer(16, 0)
        static DXGI_OUTPUT_DESC                := Buffer(96, 0)
        static DXGI_OUTDUPL_DESC               := Buffer(36, 0)
        static riid                            := Buffer(16, 0)

        ptr_dxgi_resource := 0
        buffer_subregion := 0

        __New() {
            super.__New()
        }

        __Delete() {
            this.cleanup()
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
                                ; this is the texture buffer that will receive our subregion of interest from the buffer
                                ; defined above (which is the entire screen). note that this is only useful if the data
                                ; is in GPU memory.
                                static access_flags := D3D11_CPU_ACCESS_READ ;| D3D11_CPU_ACCESS_WRITE
                                NumPut("uint",                          1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion,  8)   ; MipLevels
                                NumPut("uint",                          1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 12)   ; ArraySize
                                NumPut("uint", DXGI_FORMAT_B8G8R8A8_UNORM, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 16)   ; Format
                                NumPut("uint",                          1, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 20)   ; SampleDescCount
                                NumPut("uint",        D3D11_USAGE_STAGING, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 28)   ; Usage
                                NumPut("uint",               access_flags, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 36)   ; CPUAccessFlags
                                ret := true
                            }
                        }
                    }
                }
            }
            image_provider.dx_screen.init_successful := ret
            if !ret
                this.cleanup(true)
            return ret
        }

        cleanup(partial := false) {
            image_provider.dx_screen.last_monitor_rect := 0
            image_provider.dx_screen.init_successful := 0
            image_provider.dx_screen.using_system_memory := 0
            if this.ptr_dxgi_resource {
                ObjRelease(this.ptr_dxgi_resource)
                this.ptr_dxgi_resource := 0
            }
            if this.buffer_subregion {
                ObjRelease(this.buffer_subregion)
                this.buffer_subregion := 0
            }
            if image_provider.dx_screen.ptr_dxgi_dup {
                ObjRelease(image_provider.dx_screen.ptr_dxgi_dup)
                image_provider.dx_screen.ptr_dxgi_dup := 0
            }
            ; this came from ComQuery and that returns wrappers, so we need to release them
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

            static IDXGIOutputDuplication_AcquireNextFrame  := 8
            static DXGI_ERROR_WAIT_TIMEOUT                  := 0x887a0027
            static ID3D11DeviceContext_Unmap                := 15
            static D3D11_MAP_READ                           := 1
            static D3D11_MAP_WRITE                          := 2
            static D3D11_MAP_READ_WRITE                     := 3
            ret := false
            if !rect
                rect := imgutil.rect(0, 0, A_ScreenWidth, A_ScreenHeight)

            ; initialize the environment if needed
            if this.init(rect) {

                can_reuse_resource := false
                ; call the duplication API to get the next frame
                hr := ComCall(IDXGIOutputDuplication_AcquireNextFrame, image_provider.dx_screen.ptr_dxgi_dup, 
                    ; if we have not called it before we need to give it a timeout value to actually return non-blank data
                    "uint", this.ptr_dxgi_resource ? 0 : 500,
                    "ptr", image_provider.dx_screen.DXGI_OUTDUPL_FRAME_INFO, 
                    "ptr*", &ptr_dxgi_res:=0, 
                    "int")

                ; have we previously succeeded here? if so, we can reuse the old resource
                if this.ptr_dxgi_resource {
                    if (hr = DXGI_ERROR_WAIT_TIMEOUT) {
                        can_reuse_resource := true
                        hr := 0
                    } else if (hr >= 0) && (NumGet(image_provider.dx_screen.DXGI_OUTDUPL_FRAME_INFO, 0, "int64") > 0) {
                        can_reuse_resource := true
                    }
                }
                if can_reuse_resource {
                    ObjRelease(ptr_dxgi_res)
                } else {
                    if (this.ptr_dxgi_resource)
                        ObjRelease(this.ptr_dxgi_resource)
                    this.ptr_dxgi_resource := ptr_dxgi_res
                }

                ; if we flat out failed, we'll need to reinit; the assumption is that the
                ; monitor, desktop, lock state, etc. changed}
                if hr < 0 {
                    OutputDebug "IDXGIOutputDuplication_AcquireNextFrame failed: " hr
                    this.cleanup(true)
                    return false
                }

                if !image_provider.dx_screen.using_system_memory {
                    if (this.buffer_subregion) {
                        ComCall(ID3D11DeviceContext_Unmap, image_provider.dx_screen.d3d_context, "ptr", this.buffer_subregion, "uint", 0)
                        ObjRelease(this.buffer_subregion)
                        this.buffer_subregion := 0
                    }
                    ; create the texture that holds only the subregion of interest
                    NumPut("uint", rect.w, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 0)
                    NumPut("uint", rect.h, image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, 4)
                    if ComCall(ID3D11Device_CreateTexture2D := 5, image_provider.dx_screen.d3d_device, "ptr", image_provider.dx_screen.D3D11_TEXTURE2D_DESC_subregion, "ptr", 0, "ptr*", &buffer_subregion:=0, "int") >= 0 {
                        this.buffer_subregion := buffer_subregion
                        ; get the texture from the resource
                        texture_buffer2 := ComObjQuery(this.ptr_dxgi_resource, "{6f15aaf2-d208-4e89-9ab4-489535d34f9c}") ; ID3D11Texture2D
                        if texture_buffer2 {
                            region_box := rect.d3d_box()
                            ; copy the resource texture's relevant parts into the subregion texture
                            if ComCall(ID3D11DeviceContext_CopySubresourceRegion := 46, image_provider.dx_screen.d3d_context, 
                                "ptr", buffer_subregion, "uint", 0, "uint", 0, "uint", 0, "uint", 0, 
                                "ptr", texture_buffer2, "uint", 0, "ptr", region_box.ptr, "int") >= 0 
                            {
                                ; map the subregion texture
                                if (hr := ComCall(ID3D11DeviceContext_Map := 14, image_provider.dx_screen.d3d_context, 
                                    "ptr", buffer_subregion, "uint", 0, 
                                    "uint", D3D11_MAP_READ_WRITE, "uint", 0, 
                                    "ptr", image_provider.dx_screen.D3D11_MAPPED_SUBRESOURCE, "int")) >= 0
                                {
                                    ptr    := NumGet(image_provider.dx_screen.D3D11_MAPPED_SUBRESOURCE, 0, "ptr")
                                    stride := NumGet(image_provider.dx_screen.D3D11_MAPPED_SUBRESOURCE, 8, "int")
                                    super.get_image(ptr, rect.w, rect.h, stride, 0, 0)
                                    ret := {x: rect.x, y: rect.y}
                                }
                            }
                        }
                    }
                }
            }
            return ret
        } ; end of get_image
    } ; end of image_provider.dx_screen class
} ; end of image_provider class
