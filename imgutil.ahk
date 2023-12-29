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
    i_use_single_thread := false                    ; used for testing purposes, forces srch/blit to use a single thread
    i_threads := 0                                  ; number of threads to use for srch/blit
    i_tolerance := 8                                ; tolerance used by all pixel matching functions
    i_gdip_token := 0                               ; gdiplus token

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
    ; scalar only, this is just for benchmarking comparison and not meant to be used. v0 is below the psabi 
    ; baseline, there's no equivalent psabi level and get_cpu_psabi_level should never return it.
    ; (theoretically it might, if e.g. SSE has been masked off from CPUID in a VM, so... eh?)
    ;########################################################################################################
    i_get_mcode_map_v0() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 6752 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VlNEi0FASItBCEhjcSBBD6/QRIuQwAAAAEGJ0YnQMdJB9/Ix0kGJw0ONBAhEi0E0QffySGNROExjSTBMY1EYRQHYRA+vwk1jwE0ByEyLSShPjQSBRItJHEUB2UQPr85NY8lN"
    . "AdFMi1EQT40MikE5w31GRItRPEiNHJUAAAAASMHmAkWF0nQxZg8fhAAAAAAAMdJmDx9EAABBiwyQQYkMkUiDwgFMOdJ170GDwwFJAdhJAfFEOdh12Fteww8fRAAAV1ZTi1wk"
    . "SESJyEhj8kiJz0hjTCRAD7bERYnIQYnCi0QkWEHB6BAPr8ZImEgByEyNHIeLRCRQD6/GSJhIAchIjQyHTDnZc2mD/gFFD7bARQ+20kUPtsl0EetmZg8fRAAASIPBBEw52XNH"
    . "D7ZBAUQp0Jkx0CnQD7ZRAkQpwonWwf4fMfIp8jnQD0zCD7YRRCnKidbB/h8x8inyOdAPTMI5w32+McBbXl/DDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusSZi4PH4QA"
    . "AAAAAEgB8Uw52XPYD7ZBAkQpwJkx0CnQD7ZRAUQp0onXwf8fMfop+jnQD0zCD7YRRCnKidfB/x8x+in6OdAPTMI5w32/McDrj2ZmLg8fhAAAAAAAVlMPr1QkOItcJEBIY9JI"
    . "ic5IY0wkUEWJykSJyEHB6hAPtsRIAdFMjRyOSGNMJEhIAcpIjQyWTDnZc2VFD7bSRA+2wEUPtsnrEA8fgAAAAABIg8EETDnZc0cPtkECRCnQmTHQKdAPtlEBRCnCidbB/h8x"
    . "8inyOdAPTMIPthFEKcqJ1sH+HzHyKfI50A9MwjnDfb4xwFtew2YPH4QAAAAAALgBAAAAW17DDx+EAAAAAABBV0FWQVVBVFVXVlNIgey4AgAADxG0JBACAAAPEbwkIAIAAEQP"
    . "EYQkMAIAAEQPEYwkQAIAAEQPEZQkUAIAAEQPEZwkYAIAAEQPEaQkcAIAAEQPEawkgAIAAEQPEbQkkAIAAEQPEbwkoAIAAA+2hCQgAwAARGngAAEBAEmJyonXQQnEQYHMAAAA"
    . "/0SJ4EWJ5kSJ5kHB7hAPtsSF0kGJw0SJ8w+OEQgAAIP6EA+OcwcAAEUPtuRFD7b2RQ+26/NED289SxYAAEyJ4EyJ8fNED281TBYAAGYP7/9IweAISMHhCPNED28tRxYAAGZF"
    . "D3bbjWr/TAnwTAnp80QPbyVwFgAASMHgCEjB4QhMiepMCeFMCehIweIISMHgCEjB4QhMCeJMCeBMCfFIweIISMHgCEjB4QhMCfJMCfBMCelIweAISMHhCEwJ4UwJ6EjB4AhI"
    . "weEITAngTAnxSMHgCEjB4QhMCfBMCelIweIITAnqSIkEJEjB4ghIiUwkCEwJ4kiJTCQQTInRSMHiCEiJRCQoTInITAnySMHiCEwJ6kjB4ghMCeJBiexBwewESIlUJBhJweQG"
    . "SIlUJCBMicJNAdQPH0AA8w9vMUiDwUBIg8JASIPAQPMPb1HQZg84ADXCFAAA8w9vaeBmD2/C8w9vZCQgZg84ABXKFAAAZg84AAWxFAAAZg/r8GYPb8VmDzgALdAUAABmD/zm"
    . "8w9vXCQQZkQPb9ZmDzgABagUAABmD+vQ8w9vQfBmRA/4VCQgZkQPb8pmD/za8w9vDCRmRA/4TCQQZg84AAWaFAAAZg/r6GYPb8ZmRA9vxWYP2MRmD/zNZg90x2ZED/gEJGYP"
    . "2+BmQQ/fw2YP68RmD2/iZg/Y42YPdOdmD9vcZkEP3+NmD+vjZg9v3WYP2NlmD3TfZg/by2ZBD9/bZg/r2WZBD2/KZg/YzmZBD2/xZg90z2YP2PJmQQ9v0GYP2NVmD3T3Zg90"
    . "12ZBD9vKZkQPxekAZkSJasBmD2/pDxGMJAACAABmQQ/b8UQPtqwkAgIAAGYPOAAt8hMAAGZBD9vQRIhqwmZED8XtAGYPb+lmRIlqxGZBDzgA7w8RjCTwAQAARA+2rCT1AQAA"
    . "RIhqxmZED8XpA2ZEiWrIDxGMJOABAABED7asJOgBAABEiGrKZkQPxe0AZg9v7mZEiWrMZkEPOADtDxGMJNABAABED7asJNsBAABEiGrOZkQPxekGZkSJatAPEYwkwAEAAGZB"
    . "DzgAzkQPtqwkzgEAAGYP681EiGrSZkQPxekAZg9vzmYPOAANeBMAAGZEiWrUDxG0JLABAABED7asJLEBAABEiGrWZkQPxe4BZkSJatgPEbQkoAEAAEQPtqwkpAEAAESIatpm"
    . "RA/F6QBmD2/OZg84AA07EwAAZkSJatwPEbQkkAEAAEQPtqwklwEAAESIat5mRA/F7gRmRIlq4A8RtCSAAQAARA+2rCSKAQAARIhq4mZED8XpAGYPb8pmDzgADf4SAABmRIlq"
    . "5A8RtCRwAQAARA+2rCR9AQAARIhq5mZED8XuB2ZEiWroZkEPftVEiGrqZkQPxekAZg9vymZEiWrsZkEPOADMDxGUJGABAABED7asJGMBAABEiGruZkQPxeoCZkSJavAPEZQk"
    . "UAEAAEQPtqwkVgEAAESIavJmRA/F6QBmD2/KZg84AA2TEgAAZkSJavQPEZQkQAEAAEQPtqwkSQEAAESIavZmRA/F6gVmRIlq+A8RlCQwAQAARA+2rCQ8AQAARIhq+mZED8Xp"
    . "AGYPb8hmRIlq/A8RlCQgAQAARA+2rCQvAQAAxkLDAMZCxwDGQssARIhq/mZED8XoAMZCzwDGQtMAxkLXAMZC2wDGQt8AxkLjAMZC5wDGQusAxkLvAMZC8wDGQvcAxkL7AMZC"
    . "/wBmDzgADWYRAABmRIlowA8RhCQQAQAARA+2rCQSAQAARIhowmZED8XpAGYPb8hmRIloxGZBDzgAzw8RhCQAAQAARA+2rCQFAQAARIhoxmZED8XoA2ZEiWjIDxGEJPAAAABE"
    . "D7asJPgAAABEiGjKZkQPxekAZg9vzGZEiWjMZkEPOADNDxGEJOAAAABED7asJOsAAABEiGjOZkQPxegGZkSJaNAPEYQk0AAAAGZBDzgAxkQPtqwk3gAAAGYP68FEiGjSZkQP"
    . "xegAZg9vxGYPOAAF2xAAAGZEiWjUDxGkJMAAAABED7asJMEAAABEiGjWZkQPxewBZkSJaNgPEaQksAAAAEQPtqwktAAAAESIaNpmRA/F6ABmD2/EZkSJaNwPEaQkoAAAAEQP"
    . "tqwkpwAAAGYPOAAFiBAAAESIaN5mRA/F7ARmRIlo4A8RpCSQAAAARA+2rCSaAAAARIho4mZED8XoAGYPb8NmDzgABWEQAABmRIlo5A8RpCSAAAAARA+2rCSNAAAARIho5mZE"
    . "D8XsB2ZEiWjoZkEPft1EiGjqZkQPxegAZg9vw2ZEiWjsZkEPOADEDxFcJHBED7ZsJHNEiGjuZkQPxesCZkSJaPAPEVwkYEQPtmwkZkSIaPJmRA/F6ABmD2/DZg84AAUCEAAA"
    . "ZkSJaPQPEVwkUEQPtmwkWUSIaPZmRA/F6wVmRIlo+A8RXCRARA+2bCRMRIho+mZED8XoAGZEiWj8DxFcJDBED7ZsJD/GQMP/xkDH/8ZAy/9EiGj+xkDP/8ZA0//GQNf/xkDb"
    . "/8ZA3//GQOP/xkDn/8ZA6//GQO//xkDz/8ZA9//GQPv/xkD//0w54Q+Fsfn//4Pl8InoKe9IweACSQHCSQHASQHBjUf/Mf9JjWyBBA8fAEEPtgpBxkED/0UPtnoBQcZAAwBF"
    . "D7ZqAkGJzEEo9ESJ+kQPQudEKNpBD7bEQYnURA9C50SJ4kWJ7EEo3IjURIn6RA9C50AA8WZBiQBEiehFGPZECfFEANpFiGACRRj2QYgJRAnyANhBiFEBGNJJg8EESYPCBAnQ"
    . "SYPABEGIQf5MOc0PhXj///8PELQkEAIAADHADxC8JCACAABEDxCEJDACAABEDxCMJEACAABEDxCUJFACAABEDxCcJGACAABEDxCkJHACAABEDxCsJIACAABEDxC0JJACAABE"
    . "DxC8JKACAABIgcS4AgAAW15fXUFcQV1BXkFfw2YuDx+EAAAAAABBV0FWQVVBVFVXVlNIgewYAQAADxF0JHAPEbwkgAAAAEQPEYQkkAAAAEQPEYwkoAAAAEQPEZQksAAAAEQP"
    . "EZwkwAAAAEQPEaQk0AAAAEQPEawk4AAAAEQPEbQk8AAAAEQPEbwkAAEAAESLrCSIAQAARIuMJJABAABEi5wkmAEAAEiLnCSoAQAARInoQQ+vwYnGiUQkSEEPvsMPr8ZIi7Qk"
    . "gAEAAExj0MH4H01p0h+F61FJwfolQSnCQYD7ZLgBAAAAD0WEJKABAABEiVQkOEQPtlYBQYnDSIuEJIABAABBweIID7ZAAsHgEEQJ0EQPthZECdANAAAA/0UpyInHRIlEJGQP"
    . "iIMIAABIY9JNY8VmD+/ASIlMJEBIidBmD2/w80QPbz05DQAAiXwkTEiNNJUAAAAATCnAi1QkOGYPOAA1TQ0AAEyNNIUAAAAAi0QkSEiJ92YP1nQkCE6NJDFEielMiXQkWE2J"
    . "4ESJXCQ8SYncOdAPncKFwA+VwCHCQYnSQY1V/4nQwegESMHgBkiJRCQYidCD4PBMjTyFAAAAACnBiUQkFInQTI00hQQAAACJTCQQTIn+MclMiXQkaEGJ1kiLRCRASTnASInC"
    . "D4KnBwAARItMJDxFhckPhLIHAACLRCRMD7bsicPB6BCJbCQgQYnBRIn1TInARIt0JCBIKdBIwfgCg/j/D4xcBwAAg8ABSIlUJChMjXyCBEiJ0OsQDx8ASIPABEw5+A+ENQcA"
    . "AEQ6SAJBD5PDRDpwAQ+TwkGE03TfOhhy20GJ7kmJx0iLVCRYSInziUwkYEiLRCRoRIn2SIl8JFBMiflEiFQkKEmJ3kyJRCQwTImkJKgBAACAfCQoAItsJDgPhG0GAABIi7wk"
    . "gAEAAEiJy0iJTCQgRItkJEiLbCQ480QPfjWzCwAADx8ARYXtD44pBgAAg/4PD4aIBgAATIt8JBhIiflJidhmRQ/v7WZFD+/kTY0MPw8fRAAA80EPbxBmQQ9vz2ZBD2/HZkEP"
    . "b//zRQ9vUBBmQQ9v92ZFD2/fSIPBQPNBD29oIGYP28pmD3HSCEmDwEDzRQ9vSPBmQQ/bwmYPZ8hmQQ9vx/NED29B0GYP2/1mQQ9x0ghmQQ/bwfMPb1nAZkEPcdEIZg9n+GYP"
    . "cdUI8w9vYeBmQQ9n0mZBD9vX8w9vQfBmQQ9n6WZED2/KZkEP2/DzD29RwGZBD9vfZg9n3mZBD2/3Zg/b9GZED9vYZkEPcdAIZkEPZ/NmD3HQCGZBD9vvZkQPZ81JOclmD3HS"
    . "CGYPb+5mQQ/b92YPcdQIZkEPZ9BmQQ/b12YPZ+BmD2/BZkEP2+dmD2fUZg9v52YPcdAIZkEP2/9mQQ/a0WYPcdQIZkEP289mD2fPZg/v/2YPZ8RmD2/jZg9x1QhmQQ/b32YP"
    . "cdQIZg9n3mYP2tlmD2flZg/a4GYPdMtmD3TEZkEPdNFmD9vQZg/b0WYP2xUlCgAAZg9vwmYPYMdmD2/IZg9o12ZBD2nEZkEPYcxmD/7BZg9vymZBD2nUZkEPYcxmD/7RZg/+"
    . "wmZED/7oD4VW/v//RItEJBROjRQ3ZkEPb8VmD3PYCESLfCQQTo0MM2ZBD/7FZg9vyGYPc9kEZg/+wWYPfsFBDxLFZkQP/uhBifNFKcNBg/sHD4YqAgAAScHgAmZBD2/OZkEP"
    . "b8ZKjQwDZkEPb/5JAfjzD34RZkEPb95mQQ9v9mZFD2/W80QPfmEIQYPj+PMPfmkQZg/bymYPcdIIRSnf80QPflkYZkEP28RmD2fIZkEPb8bzRQ9+SAhmD9v9ZkEPcdQIZg9w"
    . "yQhmQQ/bw2YPZ/jzQQ9+AGYPcdUI80EPfmAQZkEP2/FmQQ9n1GZBD3HTCPNFD35AGGYP29hmD2feZkEPb/ZmD9v0Zg9x0AhmD3DSCGZBD2frZkUP29BmQQ9x0QhmD3DtCGZB"
    . "D9vWZg9x1AhmQQ/b7mZBD2fBZg9n1WZBD3HQCGYPcNIIZg9wwAhmQQ/bxmZBD2fgZg9w5AhmQQ/b5mYPZ8RmD3DACGYP2sJmD3D/CGYPb+dmD3TCZg9v0WYPcNsIZkEPZ/Jm"
    . "D3HUCGYPcPYIZg9v7mZBD9v+Zg9x0ghmQQ/b9mZBD9vOZg9nz2YPZ9RmD2/jScHjAmYPcdUIZg9x1AhmD3DSCE0B2mYPcMkIZg9n5WZBD9veZg9w5AhNAdlmD2feZg/a4mYP"
    . "cNsIZg/a2WYPdNRmD+/t8w9+fCQI8w9+NeYHAABmD3TLZg/v22YP28JmD9vIZg/bzmYPb9FmD2DLZg9g02YPcMlOZg9v2WYPb8FmD2/KZg9h3WYPYcVmD2HVZg9hzWYPcMBO"
    . "Zg9w0k5mD/7DZg/+0WYP/sJmQQ/+xWYPb8hmDzgADY0HAABmD+vPZg/+wWYPfsFFD7ZZAkU4WgJFD7ZZAUEPk8BFOFoBQQ+Tw0Uhw0UPtgFFOAJBD5PARQ+2wEUh2EQBwUGD"
    . "/wEPhJ8BAABFD7ZZBUU4WgVFD7ZZBkEPk8BFOFoGQQ+Tw0Uhw0UPtkEERThCBEEPk8BFD7bARSHYRAHBQYP/Ag+EYQEAAEUPtlkKRThaCkUPtlkJQQ+TwEU4WglBD5PDRSHD"
    . "RQ+2QQhFOEIIQQ+TwEUPtsBFIdhEAcFBg/8DD4QjAQAARQ+2WQ5FOFoORQ+2WQ1BD5PARThaDUEPk8NFIcNFD7ZBDEU4QgxBD5PARQ+2wEUh2EQBwUGD/wQPhOUAAABFD7ZZ"
    . "EkU4WhJFD7ZZEUEPk8BFOFoRQQ+Tw0Uhw0UPtkEQRThCEEEPk8BFD7bARSHYRAHBQYP/BQ+EpwAAAEUPtlkWRThaFkUPtlkVQQ+TwEU4WhVBD5PDRSHDRQ+2QRRFOEIUQQ+T"
    . "wEUPtsBFIdhEAcFBg/8GdG1FD7ZZGkU4WhpFD7ZZGUEPk8BFOFoZQQ+Tw0Uhw0UPtkEYRThCGEEPk8BFD7bARSHYRAHBQYP/B3QzRQ+2eR5FOHoeRQ+2eR1BD5PARTh6HUUP"
    . "tnkcQQ+Tw0UxyUUh2EU4ehxBD5PBRSHBRAHJSAHDSAHHKc1IAdNFKex0CUE57A+Nvfn//0iLTCQghe0PjtYAAABIg8EESDlMJDAPgqAAAABEi0QkPEWFwA+EX/n//0yJ8EiJ"
    . "ykGJ9kiLfCRQRA+2VCQoSInGTItEJDCLTCRgTIukJKgBAADpk/j//0mJ2UmJ+kWJ72ZFD+/tRTHAMcnpY/v//0iLVCQoSAH6STnQD4OA+P//QYnuSAF8JECDwQFJAfg5TCRk"
    . "D40z+P//McnrXEmJwesHDx9AAEyJyE2FyQ+FswAAAEyNDDhNOchz6+vHTInwSIt8JFBBifaLTCRgSInGRA+2VCQoTItEJDBMi6QkqAEAAOugSIucJKgBAABIhdt0CItEJDgp"
    . "6IkDDxB0JHBIicgPELwkgAAAAEQPEIQkkAAAAEQPEIwkoAAAAEQPEJQksAAAAEQPEJwkwAAAAEQPEKQk0AAAAEQPEKwk4AAAAEQPELQk8AAAAEQPELwkAAEAAEiBxBgBAABb"
    . "Xl9dQVxBXUFeQV/DTInI6en3//+QVlNIg+xox0QkXAAAAABIjXQkXEiJy+tPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQkOItDQIlE"
    . "JChIi0M4SIlEJCBMi0sw6D71//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9CESJQxBI"
    . "iUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwi4QkwAAAAEiLnCTQAAAAZg9ujCS4AAAAZkgPbtJmSA9uwYhEJGhmQQ9u2WYPbMIPEUQkOGZBD27Ai4QkyAAA"
    . "AGYPYsNmD9ZEJEjzD36EJKAAAABMjUQkIMdEJCAAAAAASI0VxP7//w8WhCSoAAAASMdEJCgAAAAADxFEJFBmD26EJLAAAABIx0QkMAAAAABmD2LBiUQkbGYP1kQkYP+RyAAA"
    . "AEiF23QGi0QkMIkDSItEJChIg8RwW8NmkFZTMfZEi1QkSExjXCRAi1wkYESJwEQJ0EQJ2AnQD4iBAAAAi0QkWIXAD46BAAAAhdt+fUUPr8FIY9JNY8lED69UJFBKjTSNAAAA"
    . "AExjTCRQSWPASAHQSItUJDhMjQSBSWPCRItUJFhMAdhJweECRTHbSI0Mgg8fADHAZg8fRAAAixSBQYkUgEiDwAFJOcJ18EGDwwFJAfBMAclEOdt/2b4BAAAAifBbXsMPH4AA"
    . "AAAAMfaJ8Ftew2YPH4QAAAAAAEiD7HiLhCSgAAAAZg9ujCTAAAAAZg9ulCS4AAAAiUQkQGZID27aZkgPbsFIi4QkqAAAAGYPbMNmQQ9u4Q8RRCQoZkEPbsBmD2LEZg/WRCQ4"
    . "Zg9uhCTIAAAATI1EJCDHRCQgAAAAAEiNFSPn//9IiUQkSIuEJNAAAABmD2LIZg9uhCSwAAAAZg9iwmYPbMEPEUQkUIlEJGD/kcgAAAC4AQAAAEiDxHjDZg8fhAAAAAAAMcDD"
    . "ZmYuDx+EAAAAAABmkAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQYICQoMDQ6AgICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICAgICAgAAB"
    . "AgQFBggJCgwNDgMEAgMEBQYHCAkKCwwNDg8JCgIDBAUGBwgJCgsMDQ4PD4CAgICAgICAgICAgICAgIAAAgMEBQYHCAkKCwwNDg8FBgIDBAUGBwgJCgsMDQ4PCwwCAwQFBgcI"
    . "CQoLDA0ODwECAgMEBQYHCAkKCwwNDg8HCAIDBAUGBwgJCgsMDQ4PDQ4CAwQFBgcICQoLDA0OD/8A/wD/AP8A/wD/AP8A/wABAQEBAQEBAQEBAQEBAQEBBAUGB4CAgICAgICA"
    . "gICAgICAgIAAAQIDgICAgICAgIA="
    mcode_imgutil_column_uniform := 0x0000c0 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0001e0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000290 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000bc0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0016f0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x0017b0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x001870 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x001920 ; u32 get_blob_psabi_level()
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

    ;############################################################################################################
    ; -march=x86-64 baseline optimized machine code blob
    ;############################################################################################################
    i_get_mcode_map_v1() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3056 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIwAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
    . "Y9JIAcpJi0sQTI0MkUE5wg+N1QAAAA8fgAAAAABBi1s8g/sDD47LAAAAjWv8MdKJ7sHuAo1OAUjB4QRmkPNBD28EEEEPEQQRSIPCEEg50XXs995JjTwJTAHBjVS1AEGLazhB"
    . "i3MghdJ0HkSLMUSJN4P6AXQTRItxBESJdwSD+gJ0BotRCIlXCEhj1UhjzkGDwgFIweICSMHhAkkB0EkByUQ50HRGg/sDD49v////RYtbPA8fAEWF23QiQYsYQYkZQYP7AXQW"
    . "QYtYBEGJWQRBg/sCdAhBi1gIQYlZCEGDwgFJAdBJAclEOdB/ylteX11BXsMPHwCJ2kyJz0yJwelk////ZmYuDx+EAAAAAABXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQ"
    . "QYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJ"
    . "zvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj3"
    . "2A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB"
    . "0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45"
    . "yA9MwTnDfcAxwFteww8fALgBAAAAW17DRA+2VCQoQWnCAAEBAEQJ0A0AAAD/Zg9u4GYPcNwAg/oDflFEjVr8Zg9vyzHARYnaQcHqAkGNUgFIweIEDx9AAPMPbwQBZg9v0GYP"
    . "3MFmD9jRQQ8RBAFBDxEUAEiDwBBIOdB13EH32kgBwUkBwUkBwEONFJOF0nReZg9uAWYPb8hmD9zDZg/Yy2ZBD34BZkEPfgiD+gF0P2YPbkEEZg9vyGYP3MNmD9jLZkEPfkEE"
    . "ZkEPfkgEg/oCdB1mD25JCGYPb8FmD9jDZg/c2WZBD35ACGZBD35ZCDHAww8fgAAAAABBV0FWQVVBVFVXVlNIg+xYDxF0JECLvCTIAAAAi5wk2AAAAEiLhCToAAAAif5Nic9E"
    . "i4wk0AAAAEmJykhjyg++00EPr/EPr9aJdCQwSIu0JMAAAABMY9rB+h9NadsfhetRScH7JUEp04D7ZLoBAAAAD0WUJOAAAABEiVwkLEUPtl8BQYnWQQ+2VwJBweMIweIQRAna"
    . "RQ+2H0QJ2kQPtl4BZg9u0g+2VgJBweMIZg9w0gDB4hBECdpED7YeRAnagcoAAAD/RSnIZg9uykSJRCQ8Zg9wyQAPiJ4AAACLdCQwSGPXSInNi1wkLEgp1UjB4QJmD3bbx0Qk"
    . "OAAAAABIweUCOd5IiYQk6AAAAEEPncCF9g+VwkEh0ESIRCQ3RI1H/ESJwsHqAkSNWgH32kWNJJBJweMESYnISInpTInSTAHRciRMidBFhfZ0CulTAQAAZpBIidBIhdIPhbIB"
    . "AABKjRQASDnRc+uDRCQ4AYtMJDxNAcKLRCQ4Och+vTHS6dACAABNAdpNAdlMAdtEieCFwA+EuQAAAGZBD24pZg9uM2ZBD24iZg9vxWYP3uVmD97GZg905WYPdMZmD9vEZg92"
    . "w2YP19CD4gFBAdCD+AF0c2ZBD25pBGYPbnMEZkEPbmIEZg9vxWYP3uVmD97GZg905WYPdMZmD9vEZg92w2YP19CD4gFBAdCD+AJ0N2YPbmMIZkEPbkEIZkEPbmoIZg9v9GYP"
    . "3uhmD97wZg90xWYPdOZmD9vEZg92w2YP19CD4gFBAdBIweACSQHCSAHDSQHBSItEJAhEKcZJAcFBKf10CUQ57g+O6gAAAEiLVCQQhfYPjsgBAABIi0QkGEiDwgRIOdAPguQB"
    . "AABFhfYPhJUAAABIi2wkCEyLRCQgTYn6SYnPSInBSInTSInISInaSCnYSMH4AoPAAYP4A38X6SQBAABmkIPoBEiDwhCD+AMPjhIBAADzD28CZg9v6mYPb+FmD97gZg/e6GYP"
    . "dMVmD3ThZg/bxGYPdsNmRA/XyEWFyXTC80UPvMlBwfkCSWPBSI0UgkiJbCQITIlEJCBIiUwkGEyJ+U2J14B8JDcAi3QkLA+EOf///0iJVCQQRItsJDBJidFJicpIi5wkwAAA"
    . "AIt0JCxmkDHSRTHAifiD/wMPjiz+///zQQ9vBBHzQQ9vNBLzD28sE/MPbyQTSIPCEGYP3vBmD97oZg90xmYPdOVmD9vEZg92w2YP18CJxdHtgeVVVVVVKeiJxcHoAoHlMzMz"
    . "MyUzMzMzAeiJxcHtBAHFgeUPDw8PiejB6AgB6InFwe0QAejB6AKD4A9BAcBMOdp1g+me/f//hcB0REyNDILrDQ8fQABIg8IETDnKdDFmD24CZg9v6mYPb+FmD97gZg/e6GYP"
    . "dMVmD3ThZg/bxGYPdsNmD9fAqAF0y+nk/v//TAHDSDnZD4Nu/v//6Sr9//9Ii4Qk6AAAAEiFwHQIi0wkLCnxiQgPEHQkQEiJ0EiDxFhbXl9dQVxBXUFeQV/DTYn6SItsJAhM"
    . "i0QkIEmJz+nn/P//ZpBWU0iD7GjHRCRcAAAAAEiJy0iNdCRc608PH4QAAAAAAItTKEiLSyBIiXQkSA+vwkiYSI0MgYtDTIlEJEAPvkNIRIlEJDCJRCQ4i0NAiUQkKEiLQzhI"
    . "iUQkIEyLSzDoHvv//0iFwHUhuAEAAADwD8EDRItDRItTLEQpwjnCfaJIg8RoW17DDx8ASI1TFEG4AQAAAGYPH0QAAESJwYYKhMl190SLRCRcRDlDEH0IRIlDEEiJQwiGCotD"
    . "QA+vQ0Q7RCRcf6SLQyyHA+udZg8fRAAAU0iD7HBIi4QkoAAAAEiLnCTQAAAASIlEJFBIi4QkqAAAAEiJVCRASI0VAv///0iJRCRYi4QksAAAAESJRCRITI1EJCCJRCRgi4Qk"
    . "uAAAAMdEJCAAAAAAiUQkZIuEJMAAAABIx0QkKAAAAACIRCRoi4QkyAAAAEjHRCQwAAAAAEiJTCQ4RIlMJEyJRCRs/5HIAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbww8fgAAA"
    . "AABBVkFUVVdWUzH/RItUJGhMY1wkYItcJHiLtCSAAAAARInARAnQRAnYCdAPiMcAAACF2w+O0AAAAIX2D47IAAAARQ+vwUhj0k1jyUhjfCRwRA+vVCRwSo0sjQAAAABEjUv8"
    . "SMHnAkljwEgB0EiLVCRYSI0MgUljwkwB2EUx20iNFIJEicjB6AJEjUAB99hJweAERY0kgQ8fADHAg/sDfnmQ8w9vBAIPEQQBSIPAEEw5wHXuSo0EAk6NFAFFheR0JEWJ4USL"
    . "MEWJMkGD+QF0FUSLcARFiXIEQYP5AnQHi0AIQYlCCEGDwwFIAelIAfpEOd5/pr8BAAAAifhbXl9dQVxBXsNmDx9EAAAx/4n4W15fXUFcQV7DDx8AQYnZSYnKSInQ659mZi4P"
    . "H4QAAAAAAGaQSIPseGYPbowkwAAAAIuEJKAAAABmD26UJMgAAABmD26EJLAAAABmD26cJLgAAABmD2LKiUQkQEiLhCSoAAAAZg9iw2YPbMFIiVQkMEiNFW30//9IiUQkSIuE"
    . "JNAAAABEiUQkOEyNRCQgx0QkIAAAAABIiUwkKESJTCQ8iUQkYA8RRCRQ/5HIAAAAuAEAAABIg8R4w2ZmLg8fhAAAAAAAkLgBAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000170 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000290 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000330 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000410 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x000960 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000a10 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000b40 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
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

    ;############################################################################################################
    ; -march=x86-64-v2 optimized SSE4 machine code blob
    ;############################################################################################################
    i_get_mcode_map_v2() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3008 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIwAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
    . "Y9JIAcpJi0sQTI0MkUE5wg+N1QAAAA8fgAAAAABBi1s8g/sDD47LAAAAjWv8MdKJ7sHuAo1OAUjB4QRmkPNBD28EEEEPEQQRSIPCEEg50XXs995JjTwJTAHBjVS1AEGLazhB"
    . "i3MghdJ0HkSLMUSJN4P6AXQTRItxBESJdwSD+gJ0BotRCIlXCEhj1UhjzkGDwgFIweICSMHhAkkB0EkByUQ50HRGg/sDD49v////RYtbPA8fAEWF23QiQYsYQYkZQYP7AXQW"
    . "QYtYBEGJWQRBg/sCdAhBi1gIQYlZCEGDwgFJAdBJAclEOdB/ylteX11BXsMPHwCJ2kyJz0yJwelk////ZmYuDx+EAAAAAABXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQ"
    . "QYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJ"
    . "zvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj3"
    . "2A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB"
    . "0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45"
    . "yA9MwTnDfcAxwFteww8fALgBAAAAW17DRA+2VCQoQWnCAAEBAEQJ0A0AAAD/Zg9u4GYPcNwAg/oDflFEjVr8Zg9vyzHARYnaQcHqAkGNUgFIweIEDx9AAPMPbwQBZg9v0GYP"
    . "3MFmD9jRQQ8RBAFBDxEUAEiDwBBIOdB13EH32kgBwUkBwUkBwEONFJOF0nReZg9uAWYPb8hmD9zDZg/Yy2ZBD34BZkEPfgiD+gF0P2YPbkEEZg9vyGYP3MNmD9jLZkEPfkEE"
    . "ZkEPfkgEg/oCdB1mD25JCGYPb8FmD9jDZg/c2WZBD35ACGZBD35ZCDHAww8fgAAAAABBV0FWQVVBVFVXVlNIg+xYDxF0JECLvCTIAAAAi5wk2AAAAIn+TYnPRIuMJNAAAABI"
    . "icgPvstBidJIi5Qk6AAAAEEPr/EPr86JdCQwSIu0JMAAAABMY9nB+R9NadsfhetRScH7JUEpy4D7ZLkBAAAAD0WMJOAAAABEiVwkLEUPtl8BQYnOQQ+2TwJBweMIweEQRAnZ"
    . "RQ+2H0QJ2UQPtl4BZg9u0Q+2TgJBweMIZg9w0gDB4RBECdlED7YeRAnZgckAAAD/RSnIZg9uyUSJRCQ8Zg9wyQAPiJoAAABJY8qLdCQwTGPHi1wkLEiJzUjB4QJJicJmD3bb"
    . "TCnFx0QkOAAAAABJidVIweUCOd5BD53BhfZBD5XARSHBRI1H/ESJwESITCQ3RYnxwegCRI1YAffYScHjBEWNJIBIiepMidBMAdJyHk2J0EWFyXQI6SoCAABJicBIhcB1dEmN"
    . "BAhIOcJz74NEJDgBi3QkPEkByotEJDg58H7DMcDpxAIAAA8fQABFhcAPhIYCAABKjRyA6w6QSIPABEg52A+EcgIAAGYPbgBmD2/qZg9v4WYP3uBmD97oZg90xWYPdOFmD9vE"
    . "Zg92w2ZED9fAQYPgAXTESIlMJBhNiehIiVQkEEyJVCQggHwkNwCLdCQsD4RdAQAASIlEJAhEi3QkMEmJwkyJ+0yLrCTAAAAAi3QkLA8fgAAAAAAxwDHJg/8DD47rAQAADx8A"
    . "80EPbwQC8w9vNAPzQQ9vbAUA80EPb2QFAEiDwBBmD97wZg/e6GYPdMZmD3TlZg/bxGYPdsNmD9fQ8w+40sH6AgHRTDnYdblMAdtNAdpNAd1EieCFwA+EtwAAAGZBD24qZkEP"
    . "bnUAZg9uI2YPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBAdGD+AF0cWZBD25qBGZBD251BGYPbmMEZg9vxWYP3uVmD97GZg905WYPdMZmD9vEZg92w2YP19CD"
    . "4gEB0YP4AnQ2ZkEPbmUIZkEPbkIIZg9uawhmD2/0Zg/e6GYP3vBmD3TFZg905mYP28RmD3bDZg/X0IPiAQHRSMHgAkgBw0kBxUkBwinOSQHqQSn+dAlEOfYPjsv+//9Ii0Qk"
    . "CIX2D47gAAAASItUJBBIg8AESDnCD4K8AAAARYXJD4Rx/v//SItMJBhMi1QkIE2JxUiJxkmJ0EiJ8Ekp8EnB+AJBg8ABQYP4A38e6ef9//8PH4AAAAAAQYPoBEiDwBBBg/gD"
    . "D47O/f//8w9vAGYPb+pmD2/hZg/e4GYP3uhmD3TFZg904WYP28RmD3bDZg/X2IXbdMLzD7zbSIlMJBjB+wJIiVQkEExjw0yJVCQgSo0EgE2J6Onb/f//Dx9EAACJ+Olk/v//"
    . "SAHOSDnyD4Ni////6UH9//9Ii0wkGEyLVCQgTYnF6S/9//9NhcB0CYtMJCwp8UGJCA8QdCRASIPEWFteX11BXEFdQV5BX8NmLg8fhAAAAAAAVlNIg+xox0QkXAAAAABIictI"
    . "jXQkXOtPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6D77//9IhcB1IbgBAAAA8A/BA0SLQ0SL"
    . "UyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwSIuE"
    . "JKAAAABIi5wk0AAAAEiJRCRQSIuEJKgAAABIiVQkQEiNFQL///9IiUQkWIuEJLAAAABEiUQkSEyNRCQgiUQkYIuEJLgAAADHRCQgAAAAAIlEJGSLhCTAAAAASMdEJCgAAAAA"
    . "iEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+RyAAAAEiF23QGi0QkMIkDSItEJChIg8RwW8MPH4AAAAAAQVZBVFVXVlMx/0SLVCRoTGNcJGCLXCR4i7QkgAAA"
    . "AESJwEQJ0EQJ2AnQD4jHAAAAhdsPjtAAAACF9g+OyAAAAEUPr8FIY9JNY8lIY3wkcEQPr1QkcEqNLI0AAAAARI1L/EjB5wJJY8BIAdBIi1QkWEiNDIFJY8JMAdhFMdtIjRSC"
    . "RInIwegCRI1AAffYScHgBEWNJIEPHwAxwIP7A355kPMPbwQCDxEEAUiDwBBMOcB17kqNBAJOjRQBRYXkdCRFieFEizBFiTJBg/kBdBVEi3AERYlyBEGD+QJ0B4tACEGJQghB"
    . "g8MBSAHpSAH6RDnef6a/AQAAAIn4W15fXUFcQV7DZg8fRAAAMf+J+FteX11BXEFeww8fAEGJ2UmJykiJ0OufZmYuDx+EAAAAAABmkEiD7HhmD26MJMAAAACLhCSgAAAAZg86"
    . "IowkyAAAAAFmD26EJLAAAABmDzoihCS4AAAAAYlEJEBIi4QkqAAAAGYPbMFIiVQkMEiNFZH0//9IiUQkSIuEJNAAAABEiUQkOEyNRCQgx0QkIAAAAABIiUwkKESJTCQ8iUQk"
    . "YA8RRCRQ/5HIAAAAuAEAAABIg8R4w7gCAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000170 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000290 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000330 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000410 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x000940 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x0009f0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000b20 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000bb0 ; u32 get_blob_psabi_level()
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

    ;############################################################################################################
    ; -march=x86-64-v3 optimized AVX2 machine code blob
    ;############################################################################################################
    i_get_mcode_map_v3() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3376 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTSInLi0lASItDCA+v0USLiMAAAABBidCJ0DHSQffxMdKJx0KNBAFIY0swQffxi1M0AfoPr1M4SGPSSAHKSItLKEyNFJGLUxxIY0sYAfoPr1MgSGPSSAHKSItLEEyNDJE5"
    . "xw+NowAAAGYPH0QAAItTPIP6Bw+OnAAAAESNQvgx0kSJxsHuA41OAUjB4QWQxMF+bwQSxMF+fwQRSIPCIEg50XXr995NjRwKTAHJQY0U8IP6A34VxMF6bwtIg8EQSYPDEIPq"
    . "BMX6f0nwhdJ0H0WLA0SJAYP6AXQURYtDBESJQQSD+gJ0B0GLUwiJUQhIY1M4g8cBTY0UkkhjUyBNjQyROfgPhWb////F+HdbXl/DDx+AAAAAAEyJyU2J0+uSV1ZTi1wkSESJ"
    . "yEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhIAdBIjRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPCBEw52nNHD7ZK"
    . "AUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusSZi4PH4QAAAAA"
    . "AEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItcJEBIY9JIic5I"
    . "Y0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2wEUPtsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFEKcGJzvfeD0nO"
    . "OcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0QPtlQkKEFpwgABAQBECdANAAAA/8X5btDE4n1Y0oP6B35Pg+oIxf1vyjHAQYnTQcHrA0WNUwFJ"
    . "weIFDx9EAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQBSIPAIEw50HXeQffbSAHBSQHBSQHAQo0U2sX5b8KD+gN+J8X6byFJg8EQSIPBEEmDwBCD6gTF2djKxMF6f0jwxenc"
    . "zMTBen9J8IXSdFLF+W4JxfHY0MX53MnEwXl+EMTBeX4Jg/oBdDfF+W5JBMXx2NDF+dzJxMF5flAExMF5fkkEg/oCdBnF+W5RCMXp2MjF+dzCxMF5fkgIxMF5fkEIMcDF+HfD"
    . "ZpBBV0FWQVVBVFVXVlNIgey4AAAAxfgRdCRAxfgRfCRQxXgRRCRgxXgRTCRwxXgRlCSAAAAAxXgRnCSQAAAAxXgRpCSgAAAAi7wkKAEAAESLnCQwAQAAi7QkOAEAAIn4QQ+v"
    . "w0xj0kAPvtZNic9Mi4wkSAEAAA+v0Ehj2sH6H0hp2x+F61FIwfslKdNAgP5kugEAAAAPRZQkQAEAAIlcJChBD7ZfAYnVQQ+2VwLB4wjB4hAJ2kEPth8J2kiLnCQgAQAAxXlu"
    . "wg+2UwIPtlsBxEJ9WMDB4wjB4hAJ2kiLnCQgAQAAD7YbCdpEicOBygAAAP/F+W76xOJ9WP9EKdsPiBYEAABIY9dNidSLdCQoiVwkPEkp1MXtdtLF8XbJQYnuScHkAjnwxXl/"
    . "xUyJzUqNFJUAAAAAQQ+dwoXAQQ+VwMV5f8ZFIcJEiFQkL0SNV/hFidBBwegDRY1YAUH32EeNLMJJweMFRTHATInjxflv38X5b+dJicpIAcsPgocDAABIiUwkMEiJ6USJ9USJ"
    . "RCQ46xZNhdIPhQcDAABNjRQRTDnTD4JPAwAATYnRhe1040mJ2U0p0UnB+QJBg8EBQYP5Bw+OUwIAAMRBfW/YxX1v102J0OsYZg8fRAAAQYPpCEmDwCBBg/kHD44wAgAAxMF+"
    . "bwDFLd7IxSXe4MWddMDEQTV0ysW128DF/XbCxf3X8IX2dMjzD7z2SIlUJCBIiYwkSAEAAIPmPE2NFDCAfCQvAIt0JCgPhKQBAACJRCQMi3QkKEyJ0kyJ+UiJXCQQTIuEJCAB"
    . "AABBicZMiVQkGGYPH0QAADHARTHSQYn5g/8HfkoPHwDF/m8EAsRBfd4MAMV93hQBxEE1dAwASIPAIMWtdMDFtdvAxf12wsV918jzRQ+4yUHB+QJFAcpMOdh1xUwB2U0B2EwB"
    . "2kWJ6UGD+QMPjk8BAADF+m8CQYPpBEiDwRBJg8AQxEF53kjwxXneUfBIg8IQxEExdEjwxal0wMWx28DF+XbBxfnXwPMPuMDB+AJFhckPhLEAAADFeW4SxEF5bhjFeW4JxEEp"
    . "3snEwSnew8WhdMDEQTF0ysWx28DF+XbBxfnX2IPjAQHYQYP5AXRtxXluUgTEQXluWATFeW5JBMRBKd7JxMEp3sPFoXTAxEExdMrFsdvAxfl2wcX519iD4wEB2EGD+QJ0M8X5"
    . "bkIIxEF5bkgIxXluUQjFMd7YxEF53tLFqXTAxEExdMvFsdvAxfl2wcX519iD4wEB2EnB4QJMAclNAchMAcpEAdBMAeIpxkEp/nQJRDn2D46T/v//i0QkDEiLXCQQTItUJBiF"
    . "9g+ObQEAAEmDwgRMOdMPgi0BAACF7Q+EMP7//0iLVCQgSIuMJEgBAADpov3//2YPH0QAADHA6eb+//9NidBBg/kDfi7EwXpvAMVh3sjFed7Vxal0wMRBYXTJxbHbwMX5dsHF"
    . "+dfwhfZ1ckmDwBBBg+kERYXJD4SRAAAAS400iOsMDx8ASYPABEk58HR0xMF5bgDFWd7IxUne0MWpdMDFMXTMxbHbwMX5dsHFedfIQYPhAXTQTYnRTYnCTYXSD4T5/P//SIlU"
    . "JCBIiYwkSAEAAOl3/f//Dx+AAAAAAGbzRA+8zkiJVCQgZkHB6QJIiYwkSAEAAEUPt8lPjRSI6Uv9//9FMcBNidFNicLrrkkB0kw50w+DuPz//0GJ7kSLRCQ4SInNSItMJDCL"
    . "XCQ8QYPAAUgB0UE52A+OTvz//0Ux0utJRItEJDhIi1QkIEGJ7kiLTCQwi1wkPEGDwAFIi6wkSAEAAEgB0UE52A+OG/z//+vLDx8ATIuMJEgBAABNhcl0CYtEJCgp8EGJAcX4"
    . "d8X4EHQkQMX4EHwkUEyJ0MV4EEQkYMV4EEwkcMV4EJQkgAAAAMV4EJwkkAAAAMV4EKQkoAAAAEiBxLgAAABbXl9dQVxBXUFeQV/DZmYuDx+EAAAAAABmkFZTSIPsaMdEJFwA"
    . "AAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOje+f//SIXAdSG4AQAAAPAP"
    . "wQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABT"
    . "SIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBIjRUC////SIlEJFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRki4QkwAAAAEjH"
    . "RCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlEJGz/kcgAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAAEFWQVRVV1ZTMf9Ei1QkaExjXCRgi1wk"
    . "eIu0JIAAAABEicBECdBECdgJ0A+I8AAAAIXbD474AAAAhfYPjvAAAABFD6/BSGPSTWPJSGN8JHBED69UJHBKjSyNAAAAAESNS/hIwecCSWPASAHQSItUJFhIjQyBSWPCTAHY"
    . "SI0UgkSJyMHoA0SNQAH32EWNJMFJweAFRTHJDx8AMcCD+wcPjp0AAAAPH0QAAMX+bwQCxf5/BAFIg8AgSTnAde1OjRQCSo0EAUWJ40GD/AN+FsTBem8KSIPAEEmDwhBBg+sE"
    . "xfp/SPBFhdt0IkWLMkSJMEGD+wF0FkWLcgREiXAEQYP7AnQIRYtSCESJUAhBg8EBSAHpSAH6RDnOf4C/AQAAAMX4d4n4W15fXUFcQV7DDx9EAAAx/4n4W15fXUFcQV7DDx8A"
    . "QYnbSInISYnSg/sDD496////65NmZi4PH4QAAAAAAJBIg+x4xflulCTAAAAAi4QkoAAAAMTjaSKMJMgAAAABxflunCSwAAAAxONhIoQkuAAAAAGJRCRASIuEJKgAAADF+WzB"
    . "SIlUJDBIjRUx8///SIlEJEiLhCTQAAAARIlEJDhMjUQkIMdEJCAAAAAASIlMJChEiUwkPIlEJGDF+n9EJFD/kcgAAAC4AQAAAEiDxHjDZmYuDx+EAAAAAAAPH0AAuAMAAADD"
    . "kJCQkJCQkJCQkA=="
    mcode_imgutil_column_uniform := 0x000120 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000240 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x0002e0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x0003e0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x000a70 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000b20 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000c80 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000d20 ; u32 get_blob_psabi_level()
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

    ;############################################################################################################
    ; -march=x86-64-v4 optimized AVX512 machine code blob
    ;############################################################################################################
    i_get_mcode_map_v4() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3008 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VVdWU0SLQUBIi0EIRIuQwAAAAEEPr9BBidGJ0DHSQffyMdKJw0ONBAhMY0EwQffyi1E0AdoPr1E4SGPSTAHCTItBKE2NDJCLURxMY0EYAdoPr1EgSGPSTAHCTItBEE2NFJA5"
    . "ww+NgwAAAL4BAAAAkItRPIP6Dw+OnwAAAESNWvAx0kSJ38HvBESNRwFJweAGYtH+SG8MEWLR/kh/DBJIg8JASTnQdenB5wREidpLjSwBTQHQKfqF0nQ+xOJp99aNev+DwwHF"
    . "+JLPYvF+yW9FAGLRfkl/AEhjUThNjQyRSGNRIE2NFJI5w3WGxfh3W15fXcNmDx9EAABIY1E4g8MBTY0MkUhjUSBNjRSSOdh024tRPIP6Dw+PYf///02J0EyJzeuTZmYuDx+E"
    . "AAAAAABmkFdWU0SLVCRITGPCi1QkWESJyEWJy0xjTCRAD7bcQcHrEEEPr9BIY9JMAcpIjTSRi1QkUEEPr9BIY9JMAcpIjRSRSDnyc2pFD7bbD7bbRA+2yEGD+AF0EutnDx+A"
    . "AAAAAEiDwgRIOfJzRw+2SgEp2YnI99gPSMEPtkoCRCnZQYnIQffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteX8MPH0AAuAEAAABbXl/DDx+AAAAA"
    . "AEnB4ALrEmYuDx+EAAAAAABMAcJIOfJz2A+2SgJEKdmJyPfYD0jBD7ZKASnZic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBQTnCfcExwOuVZmYuDx+EAAAAAABmkFZT"
    . "D69UJDhMY0QkUESLVCRASGPSSQHQRInIRInLSo00gUxjRCRID7bEwesQTAHCSI0UkUg58nNgD7bbRA+22EUPtsnrDA8fAEiDwgRIOfJzRw+2SgIp2YnI99gPSMEPtkoBRCnZ"
    . "QYnIQffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteww8fRAAAuAEAAABbXsNED7ZUJChBacIAAQEARAnQDQAAAP9i8n1IfNCD+g9+WoPqEGLx/Uhv"
    . "yjHAQYnTQcHrBEWNUwFJweIGZg8fRAAAYvF/SG8cAWLxZUjYwWLR/kh/BABi8XVI3MNi0f5IfwQBSIPAQEw50HXWQcHjBEgBwUkBwUkBwEQp2oXSdC+4AQAAAMTiaffAg+gB"
    . "xfiSyGLxfslvAWLxfUjYymLxfUjcwmLRfkl/CGLRfkl/ATHAxfh3w2ZmLg8fhAAAAAAAZpBBV0FWQVVBVFVXVlNIg+w4i7wkqAAAAESLnCS4AAAATIu8JMgAAACJ+0yJjCSY"
    . "AAAAidZBD77TRIuMJLAAAABIici5AQAAAEEPr9kPr9OJXCQYSIucJJgAAABMY9LB+h9NadIfhetRScH6JUEp0g+2UwJBgPtkD0WMJMAAAABEiVQkFEQPtlMBweIQQcHiCEQJ"
    . "0kQPthNIi5wkoAAAAEQJ0kQPtlMBYvJ9SHzqD7ZTAkHB4gjB4hBECdJED7YTRInDRAnSgcoAAAD/YvJ9SHziRCnLD4g0AwAATGPGSGPXi3QkFESNZ/BMicVJicFEieBBid5I"
    . "KdWLVCQYTo0shQAAAABi83VIJcn/SMHlAjnyQQ+dwIXSD5XCwegERTHSRI1YAcHgBEEh0EEpxESJwknB4wZNichEiWQkLEGJ0UiJ6kyJwGLx/Uhv3UwBwg+CqwIAAEyJbCQI"
    . "TYnERYnVSYnQRYnKi1QkLEyJ++shDx9AAEmJx0iFwA+FhQAAAEiLRCQITAH4STnAD4KEAgAAhcl032Lx/Uhv1E2JwUiJxkkpwUnB+QJBg8EBQYP5D38c6dABAAAPH0QAAEGD"
    . "6RBIg8ZAQYP5Dw+OuQEAAGLxf0hvBmLzfUg+ywVi831JPsoCYvJ+SCjBYvN9SB/BAMX4mMB0x8X4k8Bm8w+8wA+3wEiNBIZMiQQkSYnBRIlsJBxEiXQkKEyJZCQgSImcJMgA"
    . "AACJy4tEJBRFhNIPhP4AAACLRCQUi3QkGE2JzU2JzEyLvCSgAAAATIu0JJgAAABBidGJwonwDx9EAAAxyTH2TGPHg/8PfkoPH0AAYtF/SG9UDQBi021IPgwOBWLTbUk+DA8C"
    . "SIPBQGLyfkgowWLzfUgf2QDFeJPD80UPuMBEAcZJOct1xk0B3k0B300B3U1jwUWFwA+EuQAAALkBAAAAKfjE4jn3yYPpAUnB4ALF+5LJYtF+yW9FAGLBfslvDk0BxmLRfslv"
    . "F00Bx0kB6GKzfUg+0QVNAcVi831KPtICYvJ+SCjCYvN9SR/hAMX4k8xm8w+4yQ+3yQHxKco5wn8IhcAPhTT///+J0ESJyk2J4YXAD448AQAASYPBBEw5DCQPgvYAAACF2w+E"
    . "1/7//4nZTIsEJESLbCQcTInIRIt0JChMi2QkIEiLnCTIAAAA6SL+//+QKfJJAe0p+HSrOcIPjtf+///roUWFyXRVQb8BAAAAxEIx989Bg+kBxMF4ksli4X7JbwZi831APtUF"
    . "YvN9Qj7EAmLifkgowGLzfUEfyQDF+JjJdBrFeJPJZvNFD7zJSYnHRQ+3yUqNBI7plv3//0iLdCQISAHwSTnAD4Op/f//RYnRTYngRYnqSYnfSYn1QYPCAU0B6EU58g+OMP3/"
    . "/zHA63pFidFFiepMi2wkCE2J4EGDwgFJid9NAehFOfIPjgv9///r2Q8fQABFidFEi1QkHEyLbCQIidlMi0QkIESLdCQoQYPCAUyLvCTIAAAATQHoRTnyD47U/P//66IPH0QA"
    . "AEyLvCTIAAAAicZMichNhf90CYtUJBQp8kGJF8X4d0iDxDhbXl9dQVxBXUFeQV/DkFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhI"
    . "jQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOj++v//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8f"
    . "RAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBI"
    . "jRUC////SIlEJFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRki4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlE"
    . "JGz/kcgAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAAEFVQVRVV1ZTMf9Ei1QkaEhjdCRgRItcJHiLnCSAAAAARInARAnQCfAJ0A+IsgAAAEWF2w+OtwAAAIXbD46v"
    . "AAAARQ+vwUhj0kGNe/BNY8lED69UJHBBvAEAAABJY8BIAdBIi1QkWEiNDIFJY8JFMdJIAfBKjTSNAAAAAExjTCRwSI0Ugon4wegEScHhAkSNQAHB4ARJweAGKcdmDx9EAAAx"
    . "wEGD+w8PjoQAAAAPH0AAYvH+SG8MAmLx/kh/DAFIg8BASTnAdemF/3U1QYPCAUgB8UwBykQ503/GvwEAAADF+HeJ+FteX11BXEFdww8fADH/ifhbXl9dQVxBXcMPHwBOjSwC"
    . "So0sAYn4xMJ598SD6AHF+JLIYtF+yW9FAGLxfkl/RQDrpWYuDx+EAAAAAABEidhIic1JidXrzw8fRAAASIPseIuEJKAAAADF+W6UJMAAAADF+W6cJLAAAADE42kijCTIAAAA"
    . "AcTjYSKEJLgAAAABiUQkQEiLhCSoAAAAxflswUiJVCQwSI0VofT//0iJRCRIi4Qk0AAAAESJRCQ4TI1EJCDHRCQgAAAAAEiJTCQoRIlMJDyJRCRgxfp/RCRQ/5HIAAAAuAEA"
    . "AABIg8R4w2ZmLg8fhAAAAAAADx9AALgEAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000130 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000250 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x0002f0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x0003b0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x000920 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x0009d0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000b10 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000bb0 ; u32 get_blob_psabi_level()
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

    ;############################################################################################################
    ; base code, independent of optimization level/architecture
    ;############################################################################################################
    i_get_mcode_map_base() {
        ; this can't be part of the main blob as we don't want GCC to taint it with
        ; vectorization or the use of other instructions that may not be available
        ; on older CPUs
        static b64 := ""
    . "" ; imgutil_lib.c
    . "" ; 2656 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VVdWU0iD7Di/AQAAAEiJy/APwbnEAAAASIuRiAAAAEhjx0iNdCQg8w9+BMJIjSzFAAAAAA8WgZAAAAAPEUQkIOsjZg8fRAAASIuLuAAAAIn6/5OwAAAASIuDmAAAAEiLDCj/"
    . "U2hFMcBBuf////9IifK5AgAAAP+TgAAAAIXAdMgxwEiDxDhbXl9dww8fRAAAVlNIg+woMcBIictIhcl1EEiDxChbXsNmDx+EAAAAAABIh5GwAAAATIeBuAAAAIuJwAAAAIXJ"
    . "dCQx9mYPH0QAAEiLg4gAAABIiwzwSIPGAf9TaIuLwAAAADnOcuRIi5OYAAAAQbn/////QbgBAAAA/5OAAAAAuAEAAABIg8QoW17DZmYuDx+EAAAAAAAPH0AAQVVBVFVXVlNI"
    . "g+wYRTHJnJxngTQkAAAgAJ2cWGczBCSdJQAAIACFwA+EgQAAAEyNFSsHAABEichEickx/w+iSY2q0AEAAEGJxESJybgAAACAD6JBicVBi0IMRYsCQTnBRA9CyEGB+AAAAIB2"
    . "U0U5xXJYRDsFtwgAAEWLWghJY3IEdB1EicCJ+USJBaEIAAAPookEJIlcJASJTCQIiVQkDEQjHLR0JEmDwhBJOep1p0SJyEiDxBhbXl9dQVxBXcOQRTnEc61FhcB4qEGD6QFE"
    . "ichIg8QYW15fXUFcQV3DZpBlSIsEJWAAAABIi0AYSItAIEiLAEiLAEiLQCDDR2V0UHJvY0FkZHJlc3MADx9EAABWU0mJy0yJ2YtBPEgByEiNQBhIjUBwSIvAixBIjQQRi1gY"
    . "i1Aghdt0U0Ux0kmNNBNCixSWQbhHAAAATI0Nq////0wB2g+2CoTJdR7rJg8fAEQ4wXUeD7ZKAUiDwgFJg8EBRQ+2AYTJdAVFhMB14kQ4wXQOSYPCAUk52nW0McBbXsOLUCRL"
    . "jQxTi0AcD7cUEUmNFJOLBAJMAdhbXsMPH0AAV1ZTSIPsMDHbx0QkLAAAAABIic5IjXwkLOswDx9EAAD/VjCD+HoPhYQAAABIhdt0BkiJ2f9WKItUJCy5QAAAAP9WIEiJw0iF"
    . "wHRlSIn6SInZ/1ZIhcB0yItEJCyD+B92W0SNQOAx0kiJ2EWJwUHB6QVBjUkBSMHhBUgB2Q8fQACDeAgBg9IASIPAIEg5wXXwQcHhBUSJwInXRCnIiUQkLEiJ2f9WKIn4SIPE"
    . "MFteX8Mx/4n4SIPEMFteX8Mx/+vgR2xvYmFsRnJlZQBHbG9iYWxBbGxvYwBMb2FkTGlicmFyeUEARnJlZUxpYnJhcnkAR2V0TG9naWNhbFByb2Nlc3NvckluZm9ybWF0aW9u"
    . "AEdldExhc3RFcnJvcgBRdWVyeVBlcmZvcm1hbmNlQ291bnRlcgBRdWVyeVBlcmZvcm1hbmNlRnJlcXVlbmN5AENyZWF0ZVRocmVhZABXYWl0Rm9yU2luZ2xlT2JqZWN0AENy"
    . "ZWF0ZUV2ZW50QQBTZXRFdmVudABSZXNldEV2ZW50AENsb3NlSGFuZGxlAFdhaXRGb3JNdWx0aXBsZU9iamVjdHMAZmYuDx+EAAAAAABmkEFVQVRVV1ZTSIPsOGVIiwQlYAAA"
    . "AEiLQBhIi0AgSIsASIsASItAIEiJxonNSIXAD4TSAgAASInB6GP9//9IjRW8/v//SInxSInH/9BIjRW4/v//SInxSYnF/9e60AAAALlAAAAASYnE/9BIicNIhcAPhJECAABI"
    . "jQWD+///SI0Vk/7//0iJ8UiJM0iJg8gAAABMiWMgSIl7CEyJayj/10iNFX7+//9IifFIiUMQ/9dIjRV6/v//SInxSIlDGP/XSI0Vif7//0iJ8UiJQ0j/10iNFYb+//9IifFI"
    . "iUMw/9dIjRWO/v//SInxSIlDOP/XSI0VmP7//0iJ8UiJQ0D/10iNFZX+//9IifFIiUNQ/9dIjRWZ/v//SInxSIlDWP/XSI0Vlv7//0iJ8UiJQ2D/10iNFY/+//9IifFIiUNo"
    . "/9dIjRWK/v//SInxSIlDcP/XSI0Vhv7//0iJ8UiJQ3j/10iJg4AAAACF7Q+EWgEAAI0U7QAAAAC5QAAAAImrwAAAAEH/1LlAAAAASImDoAAAAIuDwAAAAI0UxQAAAABB/9S5"
    . "QAAAAEiJg4gAAACLg8AAAACNFMUAAAAAQf/UMclFMclFMcBIiYOYAAAAugEAAAD/U2BIg7ugAAAAAEjHg7AAAAAAAAAASImDkAAAAEiLi4gAAABIx4O4AAAAAAAAAMeDxAAA"
    . "AAAAAAAPhNIAAABIhckPhMkAAABIi4OYAAAASIXAD4S5AAAAi5PAAAAAhdIPhHwAAAAx7UyNJTL5///rB0iLg5gAAABIjTTtAAAAAEUxyUUxwDHSSI08MDHJSIPFAf9TYEUx"
    . "yUUxwDHSSIkHSIu7iAAAADHJ/1NgSYnZTYngMdJIAfcxyUiJB0gDs6AAAABIx0QkKAAAAADHRCQgAAAAAP9TUEiJBjurwAAAAHKPSInYSIPEOFteX11BXEFdww8fgAAAAABI"
    . "idnocPv//4nF6Zf+//9mDx+EAAAAAAD/U3hIi4uYAAAA/1MoSIuLoAAAAP9TKEiLi6gAAAD/UyhIidlB/9Ux20iJ2EiDxDhbXl9dQVxBXcMPH4AAAAAAVlNIg+woSInLSIXJ"
    . "D4SuAAAASIuJkAAAAP9TaEiLk6AAAACLi8AAAABBuf////9BuAEAAAD/k4AAAABIi4uQAAAA/1N4i4PAAAAAhcB0PzH2Dx+AAAAAAEiLg6AAAABIiwzw/1N4SIuDmAAAAEiL"
    . "DPD/U3hIi4OIAAAASIsM8EiDxgH/U3g7s8AAAAByykiLi5gAAAD/UyhIi4uIAAAA/1MoSIuLoAAAAP9TKEiLQyhIidlIg8QoW15I/+APH0AASIPEKFtew2YPH4QAAAAAAAEA"
    . "AAADAAAAAQAAAAEAAAABAAAAAwAAAAABAAABAAAAAQAAAAMAAAAACAAAAQAAAAEAAAADAAAAAIAAAAEAAAABAAAAAwAAAAAAAAEBAAAAAQAAAAMAAAAAAIAAAQAAAAEAAAAD"
    . "AAAAAAAAAQEAAAABAAAAAwAAAAAAAAIBAAAAAQAAAAMAAAAAAAAEAQAAAAEAAAACAAAAAQAAAAIAAAABAAAAAgAAAAAgAAACAAAAAQAAAAIAAAAAAAgAAgAAAAEAAAACAAAA"
    . "AAAQAAIAAAABAAAAAgAAAAAAgAACAAAAAQAAgAIAAAABAAAAAgAAAAEAAAACAAAAABAAAAMAAAABAAAAAgAAAAAAQAADAAAAAQAAAAIAAAAAAAAIAwAAAAEAAAACAAAAAAAA"
    . "EAMAAAABAAAAAgAAAAAAACADAAAAAQAAgAIAAAAgAAAAAwAAAAcAAAABAAAACAAAAAMAAAAHAAAAAQAAACAAAAADAAAABwAAAAEAAAAAAQAAAwAAAAcAAAABAAAAAAABAAQA"
    . "AAAHAAAAAQAAAAAAAgAEAAAABwAAAAEAAAAAAAAQBAAAAAcAAAABAAAAAAAAQAQAAAAHAAAAAQAAAAAAAIAEAAAA/////5CQkJCQkJCQkJCQkA=="
    mcode_mt_run                := 0x000090 ; u32 mt_run(mt_ctx *ctx, mt_client_worker_t worker, ptr param)
    mcode_get_cpu_psabi_level   := 0x000120 ; int get_cpu_psabi_level()
    mcode_gpa_getkernel32       := 0x000200 ; 
    mcode_gpa_getgetprocaddress := 0x000230 ; 
    mcode_mt_get_cputhreads     := 0x0002d0 ; 
    mcode_mt_init               := 0x000490 ; mt_ctx *mt_init(u32 num_threads)
    mcode_mt_deinit             := 0x0007b0 ; void mt_deinit(mt_ctx *ctx)
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
            return pic
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
        h := pic.height - t
        if h <= 0
            return pic
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
        w := pic.width - t
        if w <= 0
            return pic
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_mism_l(pic, refc) {
        t := this.get_col_match(pic, refc, 0)
        w := pic.width - t
        if t <= 0
            return pic
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
        t := this.get_col_mism(pic, refc, t)
        w := pic.width - t
        if w <= 0
            return pic
        return this.crop(pic, t, 0, w, pic.height)
    }
    chop_mism_then_match_r(pic, refc, minimumGap := 1) {
        t := imgu.get_col_match_rev(pic, refc, pic.width - 1,,, minimumGap)
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
        if img.HasOwnProp("origin")
            new.origin := {x: img.origin.x + x, y: img.origin.y + y}
        return new
    }
    
    ;########################################################################################################
    ; screenshot
    ;########################################################################################################
    screengrab(x, y, w, h) {
        img := ImagePutBuffer([x, y, w, h])
        img.origin := {x: x, y: y}
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
        haystack := checkInputImg(haystack)
        needle   := checkInputImg(needle)
        
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
    from_screen(rect := 0) {
        return imgutil.img(this).from_screen(rect)
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
        __Item[x, y] {
            get => NumGet(this.ptr + y * this.stride + x * 4, "uint")
            set => NumPut("uint", value, this.ptr + y * this.stride + x * 4)
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
            if this.origin {
                obj.origin := {x: this.origin.x + x, y: this.origin.y + y}
            }
            return obj
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
            ret := false
            if !rect
                rect := imgutil.rect(0, 0, A_ScreenWidth, A_ScreenHeight)

            ; initialize the environment if needed
            if this.init(rect) {

                while true {
                    if !release_frame_early
                        ComCall(IDXGIOutputDuplication_ReleaseFrame, this.s.ptr_dxgi_dup, "uint")
                    ; call the duplication API to get the next frame. don't wait for any new updates;
                    ; if there are none, we'll use our permanent buffer from the last frame
                    time_start := A_TickCount
                    hr := ComCall(IDXGIOutputDuplication_AcquireNextFrame, this.s.ptr_dxgi_dup, 
                        "uint", release_frame_early ? 0 : 50,
                        "ptr", this.s.DXGI_OUTDUPL_FRAME_INFO, 
                        "ptr*", &ptr_dxgi_resource:=0, 
                        "uint")
                    OutputDebug "IDXGIOutputDuplication_AcquireNextFrame took " Format("{:016d}", A_TickCount - time_start) . " ms`r`n"

                    if !(hr & 0x80000000) {

                        ; has this frame been presented (i.e. is it an actual update that needs to be processed?)
                        if NumGet(this.s.DXGI_OUTDUPL_FRAME_INFO, 0, "int64")  = 0 {
                            OutputDebug "IDXGIOutputDuplication_AcquireNextFrame: update has never been presented, retrying`r`n"
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
                        time_from_last_screenshot := A_TickCount - last_screenshot_taken
                        OutputDebug "IDXGIOutputDuplication_AcquireNextFrame timed out, using last frame from " Format("{:016d}", time_from_last_screenshot) . " ms ago`r`n"
                    } else if hr & 0x80000000 {
                        ; if we flat out failed, we'll need to reinit; the assumption is that the
                        ; monitor, desktop, lock state, etc. changed
                        OutputDebug "IDXGIOutputDuplication_AcquireNextFrame failed: " Format("0x{:8x}", hr)
                        this.cleanup_static(true)
                        return false
                    }

                    ; a legit buffer should never return 0x00000000 pixels due to the 0xff alpha channel value
                    if (c := NumGet(this.s.texture_screen_ptr, 0, "uint")) = 0 {
                        OutputDebug "Bamboozled! Got a null framebuffer at " Format("{:016d}", A_TickCount) . " ms`r`n"
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
                    last_screenshot_taken := A_TickCount
                    break
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
    }
    __Delete() {
        ; clean up completely
        this.provider.cleanup_static()
    }
}
