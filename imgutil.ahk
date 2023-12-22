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
imgu.init()

class imgutil {

    ; mcode function map for name -> address in memory
    i_mcode_map := this.i_get_mcode_map()
    multithread_ctx := 0
    use_single_thread := false

    ; initialize the library
    init() {
        this.multithread_ctx := DllCall(this.i_mcode_map["mt_init_ctx"], "int", 0, "ptr")
    }

    __Delete() {
        DllCall(this.i_mcode_map["mt_deinit_ctx"], "ptr", this.multithread_ctx)
    }

    ; determines the correct version of machine code blobs to use,
    ; decodes them from base64, and returns a map of function names
    ; to addresses in memory
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

    ; -march=core2 scalar, this is just for comparison and not meant to be used
    ; v0 is below the baseline, no real world need for it
    i_get_mcode_map_v0() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 6528 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyMH4HzHBKcExwEE5yA+dwMNmZi4PH4QAAAAAAJBWU4nIidPB6hDB6BAPttIPtvcPtsAPttsp0Jkx0CnQD7bVKfJBidFBwfkfRDHKRCnKOdAPTMIPttEp2onRwfkfMcop"
        . "yjnQD0zCQTnAD53AD7bAW17DZmYuDx+EAAAAAABXVlOLXCRIRInISGPySInPSGNMJEAPtsRFichBicKLRCRYQcHoEA+vxkiYSAHITI0ch4tEJFAPr8ZImEgByEiNDIdMOdlz"
        . "aYP+AUUPtsBFD7bSRQ+2yXQR62ZmDx9EAABIg8EETDnZc0cPtkEBRCnQmTHQKdAPtlECRCnCidbB/h8x8inyOdAPTMIPthFEKcqJ1sH+HzHyKfI50A9MwjnDfb4xwFteX8MP"
        . "H4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHxTDnZc9gPtkECRCnAmTHQKdAPtlEBRCnSidfB/x8x+in6OdAPTMIPthFEKcqJ18H/HzH6Kfo50A9M"
        . "wjnDfb8xwOuPZmYuDx+EAAAAAABWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRYnKRInIQcHqEA+2xEgB0UyNHI5IY0wkSEgBykiNDJZMOdlzZUUPttJED7bARQ+2yesQDx+AAAAA"
        . "AEiDwQRMOdlzRw+2QQJEKdCZMdAp0A+2UQFEKcKJ1sH+HzHyKfI50A9Mwg+2EUQpyonWwf4fMfIp8jnQD0zCOcN9vjHAW17DZg8fhAAAAAAAuAEAAABbXsMPH4QAAAAAAFZT"
        . "QQ+v0EiJyEiNNJUAAAAATI0cMUw52XM+RQ+2yWaQRA+2UQHGQQP/RA+2QQJFAdBED7YRRQHQRTnID5PCSIPBBPfaD7baiFH+iNdmiVn8TDnZcstIAfBbXsMPH0QAAFZTQY1A"
        . "/0iJzg+vwkSNFJUAAAAASI0MgUg5znNHidJMjRyVAAAAAEiJ8kyJ20j320WF0nQvDx8AMcBmDx9EAABEiwSCRIsMgUSJDIJEiQSBSIPAAUQ50HLnTAHaSAHZSDnKctRIifBb"
        . "XsNmDx9EAABBV0FWQVVBVFVXVlNIgey4AgAADxG0JBACAAAPEbwkIAIAAEQPEYQkMAIAAEQPEYwkQAIAAEQPEZQkUAIAAEQPEZwkYAIAAEQPEaQkcAIAAEQPEawkgAIAAEQP"
        . "EbQkkAIAAEQPEbwkoAIAAA+2hCQgAwAARGngAAEBAEmJyonXQQnEQYHMAAAA/0SJ4EWJ5kSJ5kHB7hAPtsSF0kGJw0SJ8w+OEQgAAIP6EA+OcwcAAEUPtuRFD7b2RQ+26/NE"
        . "D2892xQAAEyJ4EyJ8fNED2813BQAAGYP7/9IweAISMHhCPNED28t1xQAAGZFD3bbjWr/TAnwTAnp80QPbyUAFQAASMHgCEjB4QhMiepMCeFMCehIweIISMHgCEjB4QhMCeJM"
        . "CeBMCfFIweIISMHgCEjB4QhMCfJMCfBMCelIweAISMHhCEwJ4UwJ6EjB4AhIweEITAngTAnxSMHgCEjB4QhMCfBMCelIweIITAnqSIkEJEjB4ghIiUwkCEwJ4kiJTCQQTInR"
        . "SMHiCEiJRCQoTInITAnySMHiCEwJ6kjB4ghMCeJBiexBwewESIlUJBhJweQGSIlUJCBMicJNAdQPH0AA8w9vMUiDwUBIg8JASIPAQPMPb1HQZg84ADVSEwAA8w9vaeBmD2/C"
        . "8w9vZCQgZg84ABVaEwAAZg84AAVBEwAAZg/r8GYPb8VmDzgALWATAABmD/zm8w9vXCQQZkQPb9ZmDzgABTgTAABmD+vQ8w9vQfBmRA/4VCQgZkQPb8pmD/za8w9vDCRmRA/4"
        . "TCQQZg84AAUqEwAAZg/r6GYPb8ZmRA9vxWYP2MRmD/zNZg90x2ZED/gEJGYP2+BmQQ/fw2YP68RmD2/iZg/Y42YPdOdmD9vcZkEP3+NmD+vjZg9v3WYP2NlmD3TfZg/by2ZB"
        . "D9/bZg/r2WZBD2/KZg/YzmZBD2/xZg90z2YP2PJmQQ9v0GYP2NVmD3T3Zg9012ZBD9vKZkQPxekAZkSJasBmD2/pDxGMJAACAABmQQ/b8UQPtqwkAgIAAGYPOAAtghIAAGZB"
        . "D9vQRIhqwmZED8XtAGYPb+lmRIlqxGZBDzgA7w8RjCTwAQAARA+2rCT1AQAARIhqxmZED8XpA2ZEiWrIDxGMJOABAABED7asJOgBAABEiGrKZkQPxe0AZg9v7mZEiWrMZkEP"
        . "OADtDxGMJNABAABED7asJNsBAABEiGrOZkQPxekGZkSJatAPEYwkwAEAAGZBDzgAzkQPtqwkzgEAAGYP681EiGrSZkQPxekAZg9vzmYPOAANCBIAAGZEiWrUDxG0JLABAABE"
        . "D7asJLEBAABEiGrWZkQPxe4BZkSJatgPEbQkoAEAAEQPtqwkpAEAAESIatpmRA/F6QBmD2/OZg84AA3LEQAAZkSJatwPEbQkkAEAAEQPtqwklwEAAESIat5mRA/F7gRmRIlq"
        . "4A8RtCSAAQAARA+2rCSKAQAARIhq4mZED8XpAGYPb8pmDzgADY4RAABmRIlq5A8RtCRwAQAARA+2rCR9AQAARIhq5mZED8XuB2ZEiWroZkEPftVEiGrqZkQPxekAZg9vymZE"
        . "iWrsZkEPOADMDxGUJGABAABED7asJGMBAABEiGruZkQPxeoCZkSJavAPEZQkUAEAAEQPtqwkVgEAAESIavJmRA/F6QBmD2/KZg84AA0jEQAAZkSJavQPEZQkQAEAAEQPtqwk"
        . "SQEAAESIavZmRA/F6gVmRIlq+A8RlCQwAQAARA+2rCQ8AQAARIhq+mZED8XpAGYPb8hmRIlq/A8RlCQgAQAARA+2rCQvAQAAxkLDAMZCxwDGQssARIhq/mZED8XoAMZCzwDG"
        . "QtMAxkLXAMZC2wDGQt8AxkLjAMZC5wDGQusAxkLvAMZC8wDGQvcAxkL7AMZC/wBmDzgADfYPAABmRIlowA8RhCQQAQAARA+2rCQSAQAARIhowmZED8XpAGYPb8hmRIloxGZB"
        . "DzgAzw8RhCQAAQAARA+2rCQFAQAARIhoxmZED8XoA2ZEiWjIDxGEJPAAAABED7asJPgAAABEiGjKZkQPxekAZg9vzGZEiWjMZkEPOADNDxGEJOAAAABED7asJOsAAABEiGjO"
        . "ZkQPxegGZkSJaNAPEYQk0AAAAGZBDzgAxkQPtqwk3gAAAGYP68FEiGjSZkQPxegAZg9vxGYPOAAFaw8AAGZEiWjUDxGkJMAAAABED7asJMEAAABEiGjWZkQPxewBZkSJaNgP"
        . "EaQksAAAAEQPtqwktAAAAESIaNpmRA/F6ABmD2/EZkSJaNwPEaQkoAAAAEQPtqwkpwAAAGYPOAAFGA8AAESIaN5mRA/F7ARmRIlo4A8RpCSQAAAARA+2rCSaAAAARIho4mZE"
        . "D8XoAGYPb8NmDzgABfEOAABmRIlo5A8RpCSAAAAARA+2rCSNAAAARIho5mZED8XsB2ZEiWjoZkEPft1EiGjqZkQPxegAZg9vw2ZEiWjsZkEPOADEDxFcJHBED7ZsJHNEiGju"
        . "ZkQPxesCZkSJaPAPEVwkYEQPtmwkZkSIaPJmRA/F6ABmD2/DZg84AAWSDgAAZkSJaPQPEVwkUEQPtmwkWUSIaPZmRA/F6wVmRIlo+A8RXCRARA+2bCRMRIho+mZED8XoAGZE"
        . "iWj8DxFcJDBED7ZsJD/GQMP/xkDH/8ZAy/9EiGj+xkDP/8ZA0//GQNf/xkDb/8ZA3//GQOP/xkDn/8ZA6//GQO//xkDz/8ZA9//GQPv/xkD//0w54Q+Fsfn//4Pl8InoKe9I"
        . "weACSQHCSQHASQHBjUf/Mf9JjWyBBA8fAEEPtgpBxkED/0UPtnoBQcZAAwBFD7ZqAkGJzEEo9ESJ+kQPQudEKNpBD7bEQYnURA9C50SJ4kWJ7EEo3IjURIn6RA9C50AA8WZB"
        . "iQBEiehFGPZECfFEANpFiGACRRj2QYgJRAnyANhBiFEBGNJJg8EESYPCBAnQSYPABEGIQf5MOc0PhXj///8PELQkEAIAADHADxC8JCACAABEDxCEJDACAABEDxCMJEACAABE"
        . "DxCUJFACAABEDxCcJGACAABEDxCkJHACAABEDxCsJIACAABEDxC0JJACAABEDxC8JKACAABIgcS4AgAAW15fXUFcQV1BXkFfw2YuDx+EAAAAAABBV0FWQVVBVFVXVlNIgewY"
        . "AQAADxF0JHAPEbwkgAAAAEQPEYQkkAAAAEQPEYwkoAAAAEQPEZQksAAAAEQPEZwkwAAAAEQPEaQk0AAAAEQPEawk4AAAAEQPEbQk8AAAAEQPEbwkAAEAAESLrCSIAQAARIuM"
        . "JJABAABEi5wkmAEAAEiLnCSoAQAARInoQQ+vwYnGiUQkSEEPvsMPr8ZIi7QkgAEAAExj0MH4H01p0h+F61FJwfolQSnCQYD7ZLgBAAAAD0WEJKABAABEiVQkOEQPtlYBQYnD"
        . "SIuEJIABAABBweIID7ZAAsHgEEQJ0EQPthZECdANAAAA/0UpyInHRIlEJGQPiIMIAABIY9JNY8VmD+/ASIlMJEBIidBmD2/w80QPbz3JCwAAiXwkTEiNNJUAAAAATCnAi1Qk"
        . "OGYPOAA13QsAAEyNNIUAAAAAi0QkSEiJ92YP1nQkCE6NJDFEielMiXQkWE2J4ESJXCQ8SYncOdAPncKFwA+VwCHCQYnSQY1V/4nQwegESMHgBkiJRCQYidCD4PBMjTyFAAAA"
        . "ACnBiUQkFInQTI00hQQAAACJTCQQTIn+MclMiXQkaEGJ1kiLRCRASTnASInCD4KnBwAARItMJDxFhckPhLIHAACLRCRMD7bsicPB6BCJbCQgQYnBRIn1TInARIt0JCBIKdBI"
        . "wfgCg/j/D4xcBwAAg8ABSIlUJChMjXyCBEiJ0OsQDx8ASIPABEw5+A+ENQcAAEQ6SAJBD5PDRDpwAQ+TwkGE03TfOhhy20GJ7kmJx0iLVCRYSInziUwkYEiLRCRoRIn2SIl8"
        . "JFBMiflEiFQkKEmJ3kyJRCQwTImkJKgBAACAfCQoAItsJDgPhG0GAABIi7wkgAEAAEiJy0iJTCQgRItkJEiLbCQ480QPfjVDCgAADx8ARYXtD44pBgAAg/4PD4aIBgAATIt8"
        . "JBhIiflJidhmRQ/v7WZFD+/kTY0MPw8fRAAA80EPbxBmQQ9vz2ZBD2/HZkEPb//zRQ9vUBBmQQ9v92ZFD2/fSIPBQPNBD29oIGYP28pmD3HSCEmDwEDzRQ9vSPBmQQ/bwmYP"
        . "Z8hmQQ9vx/NED29B0GYP2/1mQQ9x0ghmQQ/bwfMPb1nAZkEPcdEIZg9n+GYPcdUI8w9vYeBmQQ9n0mZBD9vX8w9vQfBmQQ9n6WZED2/KZkEP2/DzD29RwGZBD9vfZg9n3mZB"
        . "D2/3Zg/b9GZED9vYZkEPcdAIZkEPZ/NmD3HQCGZBD9vvZkQPZ81JOclmD3HSCGYPb+5mQQ/b92YPcdQIZkEPZ9BmQQ/b12YPZ+BmD2/BZkEP2+dmD2fUZg9v52YPcdAIZkEP"
        . "2/9mQQ/a0WYPcdQIZkEP289mD2fPZg/v/2YPZ8RmD2/jZg9x1QhmQQ/b32YPcdQIZg9n3mYP2tlmD2flZg/a4GYPdMtmD3TEZkEPdNFmD9vQZg/b0WYP2xW1CAAAZg9vwmYP"
        . "YMdmD2/IZg9o12ZBD2nEZkEPYcxmD/7BZg9vymZBD2nUZkEPYcxmD/7RZg/+wmZED/7oD4VW/v//RItEJBROjRQ3ZkEPb8VmD3PYCESLfCQQTo0MM2ZBD/7FZg9vyGYPc9kE"
        . "Zg/+wWYPfsFBDxLFZkQP/uhBifNFKcNBg/sHD4YqAgAAScHgAmZBD2/OZkEPb8ZKjQwDZkEPb/5JAfjzD34RZkEPb95mQQ9v9mZFD2/W80QPfmEIQYPj+PMPfmkQZg/bymYP"
        . "cdIIRSnf80QPflkYZkEP28RmD2fIZkEPb8bzRQ9+SAhmD9v9ZkEPcdQIZg9wyQhmQQ/bw2YPZ/jzQQ9+AGYPcdUI80EPfmAQZkEP2/FmQQ9n1GZBD3HTCPNFD35AGGYP29hm"
        . "D2feZkEPb/ZmD9v0Zg9x0AhmD3DSCGZBD2frZkUP29BmQQ9x0QhmD3DtCGZBD9vWZg9x1AhmQQ/b7mZBD2fBZg9n1WZBD3HQCGYPcNIIZg9wwAhmQQ/bxmZBD2fgZg9w5Ahm"
        . "QQ/b5mYPZ8RmD3DACGYP2sJmD3D/CGYPb+dmD3TCZg9v0WYPcNsIZkEPZ/JmD3HUCGYPcPYIZg9v7mZBD9v+Zg9x0ghmQQ/b9mZBD9vOZg9nz2YPZ9RmD2/jScHjAmYPcdUI"
        . "Zg9x1AhmD3DSCE0B2mYPcMkIZg9n5WZBD9veZg9w5AhNAdlmD2feZg/a4mYPcNsIZg/a2WYPdNRmD+/t8w9+fCQI8w9+NXYGAABmD3TLZg/v22YP28JmD9vIZg/bzmYPb9Fm"
        . "D2DLZg9g02YPcMlOZg9v2WYPb8FmD2/KZg9h3WYPYcVmD2HVZg9hzWYPcMBOZg9w0k5mD/7DZg/+0WYP/sJmQQ/+xWYPb8hmDzgADR0GAABmD+vPZg/+wWYPfsFFD7ZZAkU4"
        . "WgJFD7ZZAUEPk8BFOFoBQQ+Tw0Uhw0UPtgFFOAJBD5PARQ+2wEUh2EQBwUGD/wEPhJ8BAABFD7ZZBUU4WgVFD7ZZBkEPk8BFOFoGQQ+Tw0Uhw0UPtkEERThCBEEPk8BFD7bA"
        . "RSHYRAHBQYP/Ag+EYQEAAEUPtlkKRThaCkUPtlkJQQ+TwEU4WglBD5PDRSHDRQ+2QQhFOEIIQQ+TwEUPtsBFIdhEAcFBg/8DD4QjAQAARQ+2WQ5FOFoORQ+2WQ1BD5PARTha"
        . "DUEPk8NFIcNFD7ZBDEU4QgxBD5PARQ+2wEUh2EQBwUGD/wQPhOUAAABFD7ZZEkU4WhJFD7ZZEUEPk8BFOFoRQQ+Tw0Uhw0UPtkEQRThCEEEPk8BFD7bARSHYRAHBQYP/BQ+E"
        . "pwAAAEUPtlkWRThaFkUPtlkVQQ+TwEU4WhVBD5PDRSHDRQ+2QRRFOEIUQQ+TwEUPtsBFIdhEAcFBg/8GdG1FD7ZZGkU4WhpFD7ZZGUEPk8BFOFoZQQ+Tw0Uhw0UPtkEYRThC"
        . "GEEPk8BFD7bARSHYRAHBQYP/B3QzRQ+2eR5FOHoeRQ+2eR1BD5PARTh6HUUPtnkcQQ+Tw0UxyUUh2EU4ehxBD5PBRSHBRAHJSAHDSAHHKc1IAdNFKex0CUE57A+Nvfn//0iL"
        . "TCQghe0PjtYAAABIg8EESDlMJDAPgqAAAABEi0QkPEWFwA+EX/n//0yJ8EiJykGJ9kiLfCRQRA+2VCQoSInGTItEJDCLTCRgTIukJKgBAADpk/j//0mJ2UmJ+kWJ72ZFD+/t"
        . "RTHAMcnpY/v//0iLVCQoSAH6STnQD4OA+P//QYnuSAF8JECDwQFJAfg5TCRkD40z+P//McnrXEmJwesHDx9AAEyJyE2FyQ+FswAAAEyNDDhNOchz6+vHTInwSIt8JFBBifaL"
        . "TCRgSInGRA+2VCQoTItEJDBMi6QkqAEAAOugSIucJKgBAABIhdt0CItEJDgp6IkDDxB0JHBIicgPELwkgAAAAEQPEIQkkAAAAEQPEIwkoAAAAEQPEJQksAAAAEQPEJwkwAAA"
        . "AEQPEKQk0AAAAEQPEKwk4AAAAEQPELQk8AAAAEQPELwkAAEAAEiBxBgBAABbXl9dQVxBXUFeQV/DTInI6en3//+QVlNIg+xox0QkXAAAAABIjXQkXEiJy+tPDx+EAAAAAACL"
        . "UyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6D71//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFte"
        . "ww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwi4QkwAAAAEiLnCTQAAAAZg9u"
        . "jCS4AAAAZkgPbtJmSA9uwYhEJGhmQQ9u2WYPbMIPEUQkOGZBD27Ai4QkyAAAAGYPYsNmD9ZEJEjzD36EJKAAAABMjUQkIMdEJCAAAAAASI0VxP7//w8WhCSoAAAASMdEJCgA"
        . "AAAADxFEJFBmD26EJLAAAABIx0QkMAAAAABmD2LBiUQkbGYP1kQkYP+RAAEAAEiF23QGi0QkMIkDSItEJChIg8RwW8NmkDHAw2ZmLg8fhAAAAAAAZpAAAQIEBQYICQoMDQ6A"
        . "gICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICAgICAgAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQYICQoMDQ4DBAIDBAUGBwgJCgsMDQ4P"
        . "CQoCAwQFBgcICQoLDA0ODw+AgICAgICAgICAgICAgICAAAIDBAUGBwgJCgsMDQ4PBQYCAwQFBgcICQoLDA0ODwsMAgMEBQYHCAkKCwwNDg8BAgIDBAUGBwgJCgsMDQ4PBwgC"
        . "AwQFBgcICQoLDA0ODw0OAgMEBQYHCAkKCwwNDg//AP8A/wD/AP8A/wD/AP8AAQEBAQEBAQEBAQEBAQEBAQQFBgeAgICAgICAgICAgICAgICAAAECA4CAgICAgICA"
        mcode_imgutil_channel_match  := 0x000000 ; i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        mcode_imgutil_pixels_match   := 0x000020 ; u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        mcode_imgutil_column_uniform := 0x000080 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        mcode_imgutil_row_uniform    := 0x0001a0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        mcode_imgutil_makebw         := 0x000250 ; argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        mcode_imgutil_flip_vert      := 0x0002b0 ; argb *imgutil_flip_vert(argb *p, u32 w, u32 h)
        mcode_imgutil_make_sat_masks := 0x000320 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        mcode_imgutil_imgsrch        := 0x000c50 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
        mcode_imgutil_imgsrch_multi  := 0x001780 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
        mcode_get_blob_psabi_level   := 0x001840 ; u32 get_blob_psabi_level()
        ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + mcode_imgutil_channel_match
                    , "imgutil_pixels_match",      code + mcode_imgutil_pixels_match
                    , "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_makebw",            code + mcode_imgutil_makebw
                    , "imgutil_filp_vert",         code + mcode_imgutil_flip_vert
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
        . "" ; 2560 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RBFD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEP"
        . "TNEpyInB99kPScE5wg9M0DHAQTnQD53AW8MPHwBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUP"
        . "tsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4P"
        . "H4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5"
        . "w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAA"
        . "AEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteww8fALgBAAAAW17DVlNBD6/QSInISI00lQAAAABM"
        . "jRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECxkED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNBjUD/SInORI0UlQAAAAAPr8JI"
        . "jQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGYPH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtlQkKEFp"
        . "wgABAQBECdANAAAA/2YPbuBmD3DcAIP6A35RRI1a/GYPb8sxwEWJ2kHB6gJBjVIBSMHiBA8fQADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnQddxB99pIAcFJ"
        . "AcFJAcBDjRSThdJ0XmYPbgFmD2/IZg/cw2YP2MtmQQ9+AWZBD34Ig/oBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35BBGZBD35IBIP6AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+"
        . "QAhmQQ9+WQgxwMMPH4AAAAAAQVdBVkFVQVRVV1ZTSIPsWA8RdCRAi7wkyAAAAIucJNgAAABIi4Qk6AAAAIn+TYnPRIuMJNAAAABJicpIY8oPvtNBD6/xD6/WiXQkMEiLtCTA"
        . "AAAATGPawfofTWnbH4XrUUnB+yVBKdOA+2S6AQAAAA9FlCTgAAAARIlcJCxFD7ZfAUGJ1kEPtlcCQcHjCMHiEEQJ2kUPth9ECdpED7ZeAWYPbtIPtlYCQcHjCGYPcNIAweIQ"
        . "RAnaRA+2HkQJ2oHKAAAA/0UpyGYPbspEiUQkPGYPcMkAD4ieAAAAi3QkMEhj10iJzYtcJCxIKdVIweECZg9228dEJDgAAAAASMHlAjneSImEJOgAAABBD53AhfYPlcJBIdBE"
        . "iEQkN0SNR/xEicLB6gJEjVoB99pFjSSQScHjBEmJyEiJ6UyJ0kwB0XIkTInQRYX2dArpUwEAAGaQSInQSIXSD4WyAQAASo0UAEg50XPrg0QkOAGLTCQ8TQHCi0QkODnIfr0x"
        . "0unQAgAATQHaTQHZTAHbRInghcAPhLkAAABmQQ9uKWYPbjNmQQ9uImYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBQQHQg/gBdHNmQQ9uaQRmD25zBGZBD25i"
        . "BGYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBQQHQg/gCdDdmD25jCGZBD25BCGZBD25qCGYPb/RmD97oZg/e8GYPdMVmD3TmZg/bxGYPdsNmD9fQg+IBQQHQ"
        . "SMHgAkkBwkgBw0kBwUiLRCQIRCnGSQHBQSn9dAlEOe4PjuoAAABIi1QkEIX2D47IAQAASItEJBhIg8IESDnQD4LkAQAARYX2D4SVAAAASItsJAhMi0QkIE2J+kmJz0iJwUiJ"
        . "00iJyEiJ2kgp2EjB+AKDwAGD+AN/F+kkAQAAZpCD6ARIg8IQg/gDD44SAQAA8w9vAmYPb+pmD2/hZg/e4GYP3uhmD3TFZg904WYP28RmD3bDZkQP18hFhcl0wvNFD7zJQcH5"
        . "AkljwUiNFIJIiWwkCEyJRCQgSIlMJBhMiflNideAfCQ3AIt0JCwPhDn///9IiVQkEESLbCQwSYnRSYnKSIucJMAAAACLdCQsZpAx0kUxwIn4g/8DD44s/v//80EPbwQR80EP"
        . "bzQS8w9vLBPzD28kE0iDwhBmD97wZg/e6GYPdMZmD3TlZg/bxGYPdsNmD9fAicXR7YHlVVVVVSnoicXB6AKB5TMzMzMlMzMzMwHoicXB7QQBxYHlDw8PD4nowegIAeiJxcHt"
        . "EAHowegCg+APQQHATDnadYPpnv3//4XAdERMjQyC6w0PH0AASIPCBEw5ynQxZg9uAmYPb+pmD2/hZg/e4GYP3uhmD3TFZg904WYP28RmD3bDZg/XwKgBdMvp5P7//0wBw0g5"
        . "2Q+Dbv7//+kq/f//SIuEJOgAAABIhcB0CItMJCwp8YkIDxB0JEBIidBIg8RYW15fXUFcQV1BXkFfw02J+kiLbCQITItEJCBJic/p5/z//2aQVlNIg+xox0QkXAAAAABIictI"
        . "jXQkXOtPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6B77//9IhcB1IbgBAAAA8A/BA0SLQ0SL"
        . "UyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwSIuE"
        . "JKAAAABIi5wk0AAAAEiJRCRQSIuEJKgAAABIiVQkQEiNFQL///9IiUQkWIuEJLAAAABEiUQkSEyNRCQgiUQkYIuEJLgAAADHRCQgAAAAAIlEJGSLhCTAAAAASMdEJCgAAAAA"
        . "iEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+RAAEAAEiF23QGi0QkMIkDSItEJChIg8RwW8MPH4AAAAAAuAEAAADDkJCQkJCQkJCQkA=="
        mcode_imgutil_channel_match  := 0x000000 ; i32 imgutil_channel_match (i32 a, i32 b, i32 t);
        mcode_imgutil_pixels_match   := 0x000020 ; u32 imgutil_pixels_match (argb p1, argb p2, i32 t);
        mcode_imgutil_column_uniform := 0x000080 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
        mcode_imgutil_row_uniform    := 0x0001a0 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
        mcode_imgutil_makebw         := 0x000240 ; argb *imgutil_makebw (argb *start, u32 w, u32 h, u8 threshold);
        mcode_imgutil_flip_vert      := 0x0002a0 ; argb *imgutil_flip_vert (argb *p, u32 w, u32 h);
        mcode_imgutil_make_sat_masks := 0x000310 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
        mcode_imgutil_imgsrch        := 0x0003f0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_imgutil_imgsrch_multi  := 0x000940 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_get_blob_psabi_level   := 0x0009f0 ; u32 get_blob_psabi_level (void);
        ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        cmap := Map(  "imgutil_channel_match",     code + mcode_imgutil_channel_match
                    , "imgutil_pixels_match",      code + mcode_imgutil_pixels_match
                    , "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_makebw",            code + mcode_imgutil_makebw
                    , "imgutil_flip_vert",         code + mcode_imgutil_flip_vert
                    , "imgutil_make_sat_masks",    code + mcode_imgutil_make_sat_masks
                    , "imgutil_imgsrch",           code + mcode_imgutil_imgsrch
                    , "imgutil_imgsrch_multi",     code + mcode_imgutil_imgsrch_multi
                    , "get_blob_psabi_level",      code + mcode_get_blob_psabi_level
                    )
        return cmap
    }

    ; -march=x86-64-v2 optimized SSE4 machine code blob
    i_get_mcode_map_v2() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2528 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RBFD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEP"
        . "TNEpyInB99kPScE5wg9M0DHAQTnQD53AW8MPHwBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUP"
        . "tsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4P"
        . "H4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5"
        . "w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAA"
        . "AEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteww8fALgBAAAAW17DVlNBD6/QSInISI00lQAAAABM"
        . "jRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECxkED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNBjUD/SInORI0UlQAAAAAPr8JI"
        . "jQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGYPH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtlQkKEFp"
        . "wgABAQBECdANAAAA/2YPbuBmD3DcAIP6A35RRI1a/GYPb8sxwEWJ2kHB6gJBjVIBSMHiBA8fQADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnQddxB99pIAcFJ"
        . "AcFJAcBDjRSThdJ0XmYPbgFmD2/IZg/cw2YP2MtmQQ9+AWZBD34Ig/oBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35BBGZBD35IBIP6AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+"
        . "QAhmQQ9+WQgxwMMPH4AAAAAAQVdBVkFVQVRVV1ZTSIPsWA8RdCRAi7wkyAAAAIucJNgAAACJ/k2Jz0SLjCTQAAAASInID77LQYnSSIuUJOgAAABBD6/xD6/OiXQkMEiLtCTA"
        . "AAAATGPZwfkfTWnbH4XrUUnB+yVBKcuA+2S5AQAAAA9FjCTgAAAARIlcJCxFD7ZfAUGJzkEPtk8CQcHjCMHhEEQJ2UUPth9ECdlED7ZeAWYPbtEPtk4CQcHjCGYPcNIAweEQ"
        . "RAnZRA+2HkQJ2YHJAAAA/0UpyGYPbslEiUQkPGYPcMkAD4iaAAAASWPKi3QkMExjx4tcJCxIic1IweECSYnCZg9220wpxcdEJDgAAAAASYnVSMHlAjneQQ+dwYX2QQ+VwEUh"
        . "wUSNR/xEicBEiEwkN0WJ8cHoAkSNWAH32EnB4wRFjSSASInqTInQTAHSch5NidBFhcl0COkqAgAASYnASIXAdXRJjQQISDnCc++DRCQ4AYt0JDxJAcqLRCQ4OfB+wzHA6cQC"
        . "AAAPH0AARYXAD4SGAgAASo0cgOsOkEiDwARIOdgPhHICAABmD24AZg9v6mYPb+FmD97gZg/e6GYPdMVmD3ThZg/bxGYPdsNmRA/XwEGD4AF0xEiJTCQYTYnoSIlUJBBMiVQk"
        . "IIB8JDcAi3QkLA+EXQEAAEiJRCQIRIt0JDBJicJMiftMi6wkwAAAAIt0JCwPH4AAAAAAMcAxyYP/Aw+O6wEAAA8fAPNBD28EAvMPbzQD80EPb2wFAPNBD29kBQBIg8AQZg/e"
        . "8GYP3uhmD3TGZg905WYP28RmD3bDZg/X0PMPuNLB+gIB0Uw52HW5TAHbTQHaTQHdRInghcAPhLcAAABmQQ9uKmZBD251AGYPbiNmD2/FZg/e5WYP3sZmD3TlZg90xmYP28Rm"
        . "D3bDZg/X0IPiAQHRg/gBdHFmQQ9uagRmQQ9udQRmD25jBGYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBAdGD+AJ0NmZBD25lCGZBD25CCGYPbmsIZg9v9GYP"
        . "3uhmD97wZg90xWYPdOZmD9vEZg92w2YP19CD4gEB0UjB4AJIAcNJAcVJAcIpzkkB6kEp/nQJRDn2D47L/v//SItEJAiF9g+O4AAAAEiLVCQQSIPABEg5wg+CvAAAAEWFyQ+E"
        . "cf7//0iLTCQYTItUJCBNicVIicZJidBIifBJKfBJwfgCQYPAAUGD+AN/Hunn/f//Dx+AAAAAAEGD6ARIg8AQQYP4Aw+Ozv3///MPbwBmD2/qZg9v4WYP3uBmD97oZg90xWYP"
        . "dOFmD9vEZg92w2YP19iF23TC8w+820iJTCQYwfsCSIlUJBBMY8NMiVQkIEqNBIBNiejp2/3//w8fRAAAifjpZP7//0gBzkg58g+DYv///+lB/f//SItMJBhMi1QkIE2Jxekv"
        . "/f//TYXAdAmLTCQsKfFBiQgPEHQkQEiDxFhbXl9dQVxBXUFeQV/DZi4PH4QAAAAAAFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhI"
        . "jQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOg++///SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8f"
        . "RAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBI"
        . "jRUC////SIlEJFiLhCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRki4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlE"
        . "JGz/kQABAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAALgCAAAAw5CQkJCQkJCQkJA="
        mcode_imgutil_channel_match  := 0x000000 ; i32 imgutil_channel_match (i32 a, i32 b, i32 t);
        mcode_imgutil_pixels_match   := 0x000020 ; u32 imgutil_pixels_match (argb p1, argb p2, i32 t);
        mcode_imgutil_column_uniform := 0x000080 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
        mcode_imgutil_row_uniform    := 0x0001a0 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
        mcode_imgutil_makebw         := 0x000240 ; argb *imgutil_makebw (argb *start, u32 w, u32 h, u8 threshold);
        mcode_imgutil_flip_vert      := 0x0002a0 ; argb *imgutil_flip_vert (argb *p, u32 w, u32 h);
        mcode_imgutil_make_sat_masks := 0x000310 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
        mcode_imgutil_imgsrch        := 0x0003f0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_imgutil_imgsrch_multi  := 0x000920 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_get_blob_psabi_level   := 0x0009d0 ; u32 get_blob_psabi_level (void);
        ;----------------- end of ahkmcodegen auto-generated section ------------------   

        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + mcode_imgutil_channel_match
                    , "imgutil_pixels_match",      code + mcode_imgutil_pixels_match
                    , "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_makebw",            code + mcode_imgutil_makebw
                    , "imgutil_flip_vert",         code + mcode_imgutil_flip_vert
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
        . "" ; 2912 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RBFD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEP"
        . "TNEpyInB99kPScE5wg9M0DHAQTnQD53AW8MPHwBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUP"
        . "tsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4P"
        . "H4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5"
        . "w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAA"
        . "AEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteww8fALgBAAAAW17DVlNBD6/QSInISI00lQAAAABM"
        . "jRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECxkED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNBjUD/SInORI0UlQAAAAAPr8JI"
        . "jQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGYPH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtlQkKEFp"
        . "wgABAQBECdANAAAA/8X5btDE4n1Y0oP6B35Pg+oIxf1vyjHAQYnTQcHrA0WNUwFJweIFDx9EAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQBSIPAIEw50HXeQffbSAHBSQHB"
        . "SQHAQo0U2sX5b8KD+gN+J8X6byFJg8EQSIPBEEmDwBCD6gTF2djKxMF6f0jwxenczMTBen9J8IXSdFLF+W4JxfHY0MX53MnEwXl+EMTBeX4Jg/oBdDfF+W5JBMXx2NDF+dzJ"
        . "xMF5flAExMF5fkkEg/oCdBnF+W5RCMXp2MjF+dzCxMF5fkgIxMF5fkEIMcDF+HfDZpBBV0FWQVVBVFVXVlNIgey4AAAAxfgRdCRAxfgRfCRQxXgRRCRgxXgRTCRwxXgRlCSA"
        . "AAAAxXgRnCSQAAAAxXgRpCSgAAAAi7wkKAEAAESLnCQwAQAAi7QkOAEAAIn4QQ+vw0xj0kAPvtZNic9Mi4wkSAEAAA+v0Ehj2sH6H0hp2x+F61FIwfslKdNAgP5kugEAAAAP"
        . "RZQkQAEAAIlcJChBD7ZfAYnVQQ+2VwLB4wjB4hAJ2kEPth8J2kiLnCQgAQAAxXluwg+2UwIPtlsBxEJ9WMDB4wjB4hAJ2kiLnCQgAQAAD7YbCdpEicOBygAAAP/F+W76xOJ9"
        . "WP9EKdsPiBYEAABIY9dNidSLdCQoiVwkPEkp1MXtdtLF8XbJQYnuScHkAjnwxXl/xUyJzUqNFJUAAAAAQQ+dwoXAQQ+VwMV5f8ZFIcJEiFQkL0SNV/hFidBBwegDRY1YAUH3"
        . "2EeNLMJJweMFRTHATInjxflv38X5b+dJicpIAcsPgocDAABIiUwkMEiJ6USJ9USJRCQ46xZNhdIPhQcDAABNjRQRTDnTD4JPAwAATYnRhe1040mJ2U0p0UnB+QJBg8EBQYP5"
        . "Bw+OUwIAAMRBfW/YxX1v102J0OsYZg8fRAAAQYPpCEmDwCBBg/kHD44wAgAAxMF+bwDFLd7IxSXe4MWddMDEQTV0ysW128DF/XbCxf3X8IX2dMjzD7z2SIlUJCBIiYwkSAEA"
        . "AIPmPE2NFDCAfCQvAIt0JCgPhKQBAACJRCQMi3QkKEyJ0kyJ+UiJXCQQTIuEJCABAABBicZMiVQkGGYPH0QAADHARTHSQYn5g/8HfkoPHwDF/m8EAsRBfd4MAMV93hQBxEE1"
        . "dAwASIPAIMWtdMDFtdvAxf12wsV918jzRQ+4yUHB+QJFAcpMOdh1xUwB2U0B2EwB2kWJ6UGD+QMPjk8BAADF+m8CQYPpBEiDwRBJg8AQxEF53kjwxXneUfBIg8IQxEExdEjw"
        . "xal0wMWx28DF+XbBxfnXwPMPuMDB+AJFhckPhLEAAADFeW4SxEF5bhjFeW4JxEEp3snEwSnew8WhdMDEQTF0ysWx28DF+XbBxfnX2IPjAQHYQYP5AXRtxXluUgTEQXluWATF"
        . "eW5JBMRBKd7JxMEp3sPFoXTAxEExdMrFsdvAxfl2wcX519iD4wEB2EGD+QJ0M8X5bkIIxEF5bkgIxXluUQjFMd7YxEF53tLFqXTAxEExdMvFsdvAxfl2wcX519iD4wEB2EnB"
        . "4QJMAclNAchMAcpEAdBMAeIpxkEp/nQJRDn2D46T/v//i0QkDEiLXCQQTItUJBiF9g+ObQEAAEmDwgRMOdMPgi0BAACF7Q+EMP7//0iLVCQgSIuMJEgBAADpov3//2YPH0QA"
        . "ADHA6eb+//9NidBBg/kDfi7EwXpvAMVh3sjFed7Vxal0wMRBYXTJxbHbwMX5dsHF+dfwhfZ1ckmDwBBBg+kERYXJD4SRAAAAS400iOsMDx8ASYPABEk58HR0xMF5bgDFWd7I"
        . "xUne0MWpdMDFMXTMxbHbwMX5dsHFedfIQYPhAXTQTYnRTYnCTYXSD4T5/P//SIlUJCBIiYwkSAEAAOl3/f//Dx+AAAAAAGbzRA+8zkiJVCQgZkHB6QJIiYwkSAEAAEUPt8lP"
        . "jRSI6Uv9//9FMcBNidFNicLrrkkB0kw50w+DuPz//0GJ7kSLRCQ4SInNSItMJDCLXCQ8QYPAAUgB0UE52A+OTvz//0Ux0utJRItEJDhIi1QkIEGJ7kiLTCQwi1wkPEGDwAFI"
        . "i6wkSAEAAEgB0UE52A+OG/z//+vLDx8ATIuMJEgBAABNhcl0CYtEJCgp8EGJAcX4d8X4EHQkQMX4EHwkUEyJ0MV4EEQkYMV4EEwkcMV4EJQkgAAAAMV4EJwkkAAAAMV4EKQk"
        . "oAAAAEiBxLgAAABbXl9dQVxBXUFeQV/DZmYuDx+EAAAAAABmkFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQkQA++"
        . "Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOje+f//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqEyXX3"
        . "RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABTSIPscEiLhCSgAAAASIucJNAAAABIiUQkUEiLhCSoAAAASIlUJEBIjRUC////SIlEJFiL"
        . "hCSwAAAARIlEJEhMjUQkIIlEJGCLhCS4AAAAx0QkIAAAAACJRCRki4QkwAAAAEjHRCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlEJGz/kQABAABIhdt0"
        . "BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAALgDAAAAw5CQkJCQkJCQkJA="
        mcode_imgutil_channel_match  := 0x000000 ; i32 imgutil_channel_match (i32 a, i32 b, i32 t);
        mcode_imgutil_pixels_match   := 0x000020 ; u32 imgutil_pixels_match (argb p1, argb p2, i32 t);
        mcode_imgutil_column_uniform := 0x000080 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
        mcode_imgutil_row_uniform    := 0x0001a0 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
        mcode_imgutil_makebw         := 0x000240 ; argb *imgutil_makebw (argb *start, u32 w, u32 h, u8 threshold);
        mcode_imgutil_flip_vert      := 0x0002a0 ; argb *imgutil_flip_vert (argb *p, u32 w, u32 h);
        mcode_imgutil_make_sat_masks := 0x000310 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
        mcode_imgutil_imgsrch        := 0x000410 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_imgutil_imgsrch_multi  := 0x000aa0 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_get_blob_psabi_level   := 0x000b50 ; u32 get_blob_psabi_level (void);
        ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + mcode_imgutil_channel_match
                    , "imgutil_pixels_match",      code + mcode_imgutil_pixels_match
                    , "imgutil_column_uniform",    code + mcode_imgutil_column_uniform  
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_makebw",            code + mcode_imgutil_makebw
                    , "imgutil_flip_vert",         code + mcode_imgutil_flip_vert
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
        . "" ; 2560 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RBFD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEP"
        . "TNEpyInB99kPScE5wg9M0DHAQTnQD53AW8MPHwBXVlNEi1QkSExjwotUJFhEichFictMY0wkQA+23EHB6xBBD6/QSGPSTAHKSI00kYtUJFBBD6/QSGPSTAHKSI0UkUg58nNq"
        . "RQ+22w+220QPtshBg/gBdBLrZw8fgAAAAABIg8IESDnyc0cPtkoBKdmJyPfYD0jBD7ZKAkQp2UGJyEH32EEPScg5yA9MwQ+2CkQpyUGJyEH32EEPScg5yA9MwUE5wn26McBb"
        . "Xl/DDx9AALgBAAAAW15fww8fgAAAAABJweAC6xJmLg8fhAAAAAAATAHCSDnyc9gPtkoCRCnZicj32A9IwQ+2SgEp2YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9MwUE5"
        . "wn3BMcDrlWZmLg8fhAAAAAAAZpBWUw+vVCQ4TGNEJFBEi1QkQEhj0kkB0ESJyESJy0qNNIFMY0QkSA+2xMHrEEwBwkiNFJFIOfJzYA+220QPtthFD7bJ6wwPHwBIg8IESDny"
        . "c0cPtkoCKdmJyPfYD0jBD7ZKAUQp2UGJyEH32EEPScg5yA9MwQ+2CkQpyUGJyEH32EEPScg5yA9MwUE5wn26McBbXsMPH0QAALgBAAAAW17DVlNED6/CSInISo00hQAAAABM"
        . "jRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECxkED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNBjUD/SInORI0UlQAAAAAPr8JI"
        . "jQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGYPH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtlQkKEFp"
        . "wgABAQBECdANAAAA/2LyfUh80IP6D35ag+oQYvH9SG/KMcBBidNBwesERY1TAUnB4gZmDx9EAABi8X9IbxwBYvFlSNjBYtH+SH8EAGLxdUjcw2LR/kh/BAFIg8BATDnQddZB"
        . "weMESAHBSQHBSQHARCnahdJ0L7gBAAAAxOJp98CD6AHF+JLIYvF+yW8BYvF9SNjKYvF9SNzCYtF+SX8IYtF+SX8BMcDF+HfDZmYuDx+EAAAAAABmkEFXQVZBVUFUVVdWU0iD"
        . "7DiLvCSoAAAARIucJLgAAABMi7wkyAAAAIn7TImMJJgAAACJ1kEPvtNEi4wksAAAAEiJyLkBAAAAQQ+v2Q+v04lcJBhIi5wkmAAAAExj0sH6H01p0h+F61FJwfolQSnSD7ZT"
        . "AkGA+2QPRYwkwAAAAESJVCQURA+2UwHB4hBBweIIRAnSRA+2E0iLnCSgAAAARAnSRA+2UwFi8n1IfOoPtlMCQcHiCMHiEEQJ0kQPthNEicNECdKBygAAAP9i8n1IfOJEKcsP"
        . "iDQDAABMY8ZIY9eLdCQURI1n8EyJxUmJwUSJ4EGJ3kgp1YtUJBhOjSyFAAAAAGLzdUglyf9IweUCOfJBD53AhdIPlcLB6ARFMdJEjVgBweAEQSHQQSnERInCScHjBk2JyESJ"
        . "ZCQsQYnRSInqTInAYvH9SG/dTAHCD4KrAgAATIlsJAhNicRFidVJidBFicqLVCQsTIn76yEPH0AASYnHSIXAD4WFAAAASItEJAhMAfhJOcAPgoQCAACFyXTfYvH9SG/UTYnB"
        . "SInGSSnBScH5AkGDwQFBg/kPfxzp0AEAAA8fRAAAQYPpEEiDxkBBg/kPD465AQAAYvF/SG8GYvN9SD7LBWLzfUk+ygJi8n5IKMFi831IH8EAxfiYwHTHxfiTwGbzD7zAD7fA"
        . "SI0EhkyJBCRJicFEiWwkHESJdCQoTIlkJCBIiZwkyAAAAInLi0QkFEWE0g+E/gAAAItEJBSLdCQYTYnNTYnMTIu8JKAAAABMi7QkmAAAAEGJ0YnCifAPH0QAADHJMfZMY8eD"
        . "/w9+Sg8fQABi0X9Ib1QNAGLTbUg+DA4FYtNtST4MDwJIg8FAYvJ+SCjBYvN9SB/ZAMV4k8PzRQ+4wEQBxkk5y3XGTQHeTQHfTQHdTWPBRYXAD4S5AAAAuQEAAAAp+MTiOffJ"
        . "g+kBScHgAsX7ksli0X7Jb0UAYsF+yW8OTQHGYtF+yW8XTQHHSQHoYrN9SD7RBU0BxWLzfUo+0gJi8n5IKMJi831JH+EAxfiTzGbzD7jJD7fJAfEpyjnCfwiFwA+FNP///4nQ"
        . "RInKTYnhhcAPjjwBAABJg8EETDkMJA+C9gAAAIXbD4TX/v//idlMiwQkRItsJBxMichEi3QkKEyLZCQgSIucJMgAAADpIv7//5Ap8kkB7Sn4dKs5wg+O1/7//+uhRYXJdFVB"
        . "vwEAAADEQjH3z0GD6QHEwXiSyWLhfslvBmLzfUA+1QVi831CPsQCYuJ+SCjAYvN9QR/JAMX4mMl0GsV4k8lm80UPvMlJicdFD7fJSo0EjumW/f//SIt0JAhIAfBJOcAPg6n9"
        . "//9FidFNieBFiepJid9JifVBg8IBTQHoRTnyD44w/f//McDrekWJ0UWJ6kyLbCQITYngQYPCAUmJ300B6EU58g+OC/3//+vZDx9AAEWJ0USLVCQcTItsJAiJ2UyLRCQgRIt0"
        . "JChBg8IBTIu8JMgAAABNAehFOfIPjtT8///rog8fRAAATIu8JMgAAACJxkyJyE2F/3QJi1QkFCnyQYkXxfh3SIPEOFteX11BXEFdQV5BX8OQVlNIg+xox0QkXAAAAABIictI"
        . "jXQkXOtPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQkOItDQIlEJChIi0M4SIlEJCBMi0sw6P76//9IhcB1IbgBAAAA8A/BA0SLQ0SL"
        . "UyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMIhgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwSIuE"
        . "JKAAAABIi5wk0AAAAEiJRCRQSIuEJKgAAABIiVQkQEiNFQL///9IiUQkWIuEJLAAAABEiUQkSEyNRCQgiUQkYIuEJLgAAADHRCQgAAAAAIlEJGSLhCTAAAAASMdEJCgAAAAA"
        . "iEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+RAAEAAEiF23QGi0QkMIkDSItEJChIg8RwW8MPH4AAAAAAuAQAAADDkJCQkJCQkJCQkA=="
        mcode_imgutil_channel_match  := 0x000000 ; i32 imgutil_channel_match (i32 a, i32 b, i32 t);
        mcode_imgutil_pixels_match   := 0x000020 ; u32 imgutil_pixels_match (argb p1, argb p2, i32 t);
        mcode_imgutil_column_uniform := 0x000080 ; u32 imgutil_column_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax);
        mcode_imgutil_row_uniform    := 0x0001a0 ; i32 imgutil_row_uniform (argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax);
        mcode_imgutil_makebw         := 0x000240 ; argb *imgutil_makebw (argb *start, u32 w, u32 h, u8 threshold);
        mcode_imgutil_flip_vert      := 0x0002a0 ; argb *imgutil_flip_vert (argb *p, u32 w, u32 h);
        mcode_imgutil_make_sat_masks := 0x000310 ; u32 imgutil_make_sat_masks (u32 *needle, i32 pixelcount, u32 *needle_lo, u32 *needle_hi, u8 t);
        mcode_imgutil_imgsrch        := 0x0003d0 ; argb *imgutil_imgsrch (argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_imgutil_imgsrch_multi  := 0x000940 ; argb *imgutil_imgsrch_multi (mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched);
        mcode_get_blob_psabi_level   := 0x0009f0 ; u32 get_blob_psabi_level (void);
        ;----------------- end of ahkmcodegen auto-generated section ------------------
                                    
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + mcode_imgutil_channel_match
                    , "imgutil_pixels_match",      code + mcode_imgutil_pixels_match
                    , "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_makebw",            code + mcode_imgutil_makebw
                    , "imgutil_flip_vert",         code + mcode_imgutil_flip_vert
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
        . "" ; 2688 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "SIsFcQoAAEiJQTy4AQAAAMcBAwAAAMNmDx+EAAAAAABIi0oQSP9iCA8fhAAAAAAAV1ZTSIPsQEiJy0iFyXR5SIlMJCBIiVQkKEiNVCQgTIlEJDBMi4HoAAAASI0Nv/////+T"
        . "gAAAAEiJx0iFwHRJi4P4AAAAhcB0GzH2Dx9EAABIifmDxgH/k4gAAAA7s/gAAABy7DHSSIn5/5OoAAAASIn5/5O4AAAAuAEAAABIg8RAW15fww8fADHASIPEQFteX8NmZi4P"
        . "H4QAAAAAAA8fAEFVQVRVV1ZTSIPsGEUxyZycZ4E0JAAAIACdnFhnMwQknSUAACAAhcAPhIEAAABMjRWbBwAARInIRInJMf8PokmNqtABAABBicREicm4AAAAgA+iQYnFQYtC"
        . "DEWLAkE5wUQPQshBgfgAAACAdlNFOcVyWEQ7BScJAABFi1oISWNyBHQdRInAiflEiQURCQAAD6KJBCSJXCQEiUwkCIlUJAxEIxy0dCRJg8IQSTnqdadEichIg8QYW15fXUFc"
        . "QV3DkEU5xHOtRYXAeKhBg+kBRInISIPEGFteX11BXEFdw2aQZUiLBCVgAAAASItAGEiLQCBIiwBIiwBIi0Agw0dldFByb2NBZGRyZXNzAA8fRAAAVlNJictMidmLQTxIAchI"
        . "jUAYSI1AcEiLwIsQSI0EEYtYGItQIIXbdFNFMdJJjTQTQosUlkG4RwAAAEyNDav///9MAdoPtgqEyXUe6yYPHwBEOMF1Hg+2SgFIg8IBSYPBAUUPtgGEyXQFRYTAdeJEOMF0"
        . "DkmDwgFJOdp1tDHAW17Di1AkS40MU4tAHA+3FBFJjRSTiwQCTAHYW17DDx9AAFdWU0iD7DAx28dEJCwAAAAASInOSI18JCzrMw8fRAAA/5bQAAAAg/h6D4WRAAAASIXbdAZI"
        . "idn/ViiLVCQsuUAAAAD/ViBIicNIhcB0ckiJ+kiJ2f+WyAAAAIXAdMKLRCQsg/gfdmVEjUDgMdJIidhFicFBwekFQY1JAUjB4QVIAdlmDx9EAACDeAgBg9IASIPAIEg5wXXw"
        . "QcHhBUSJwInXRCnIiUQkLEiJ2f9WKIn4SIPEMFteX8MPH4QAAAAAADH/ifhIg8QwW15fwzH/69hHbG9iYWxGcmVlAEdsb2JhbEFsbG9jAExvYWRMaWJyYXJ5QQBGcmVlTGli"
        . "cmFyeQBDcmVhdGVFdmVudEEAQ2xvc2VIYW5kbGUAU2V0RXZlbnQAUmVzZXRFdmVudABXYWl0Rm9yU2luZ2xlT2JqZWN0AFdhaXRGb3JNdWx0aXBsZU9iamVjdHMAQ3JlYXRl"
        . "VGhyZWFkcG9vbABTZXRUaHJlYWRwb29sVGhyZWFkTWF4aW11bQBTZXRUaHJlYWRwb29sVGhyZWFkTWluaW11bQBDcmVhdGVUaHJlYWRwb29sV2FpdABDcmVhdGVUaHJlYWRw"
        . "b29sV29yawBTZXRUaHJlYWRwb29sV2FpdABTdWJtaXRUaHJlYWRwb29sV29yawBXYWl0Rm9yVGhyZWFkcG9vbFdvcmtDYWxsYmFja3MAkFdhaXRGb3JUaHJlYWRwb29sV2Fp"
        . "dENhbGxiYWNrcwBDbG9zZVRocmVhZHBvb2xXYWl0AENsb3NlVGhyZWFkcG9vbFdvcmsAQ2xvc2VUaHJlYWRwb29sAJBHZXRMb2dpY2FsUHJvY2Vzc29ySW5mb3JtYXRpb24A"
        . "R2V0TGFzdEVycm9yAFF1ZXJ5UGVyZm9ybWFuY2VDb3VudGVyAFF1ZXJ5UGVyZm9ybWFuY2VGcmVxdWVuY3kAZi4PH4QAAAAAAEFVQVRVV1ZTSIPsKGVIiwQlYAAAAEiLQBhI"
        . "i0AgSIsASIsASItAIEiJx4nNSIXAD4SjAgAASInB6FP8//9IjRW8/f//SIn5SInG/9BJicVIhfYPhIACAABIjRWs/f//SIn5/9a6CAEAALlAAAAASYnE/9BIicNIhcAPhFMC"
        . "AABIjQVa+v//SI0Viv3//0iJ+UiJO0iJgwABAABMiWMgSIlzCEyJayj/1kiNFXX9//9IiflIiUMQ/9ZIjRVx/f//SIn5SIlDGP/WSI0Vbv3//0iJ+UiJQzD/1kiNFWr9//9I"
        . "iflIiUM4/9ZIjRVj/f//SIn5SIlDQP/WSI0VXv3//0iJ+UiJQ0j/1kiNFWL9//9IiflIiUNQ/9ZIjRVp/f//SIn5SIlDWEiNBYP5//9IiUNg/9ZIjRVf/f//SIn5SIlDaP/W"
        . "SI0Vav3//0iJ+UiJQ3D/1kiNFXX9//9IiflIiUN4/9ZIjRV6/f//SIn5SImDkAAAAP/WSI0VfP3//0iJ+UiJg4AAAAD/1kiNFXv9//9IiflIiYOYAAAA/9ZIjRV9/f//SIn5"
        . "SImDiAAAAP/WSI0Viv3//0iJ+UiJg6gAAAD/1kiNFZb9//9IiflIiYOgAAAA/9ZIjRWX/f//SIn5SImDsAAAAP/WSI0VmP3//0iJ+UiJg7gAAAD/1kiNFZb9//9IiflIiYPA"
        . "AAAA/9ZIjRWi/f//SIn5SImDyAAAAP/WSI0VnP3//0iJ+UiJg9AAAAD/1kiNFaH9//9IiflIiYPYAAAA/9a5QAAAALpIAAAASImD4AAAAEH/1EiJg+gAAABIicFIhcB0aP9T"
        . "YDHJ/1NoSImD8AAAAEiJwUiFwHRHhe10a4nqiav4AAAA/1Nwi5P4AAAASIuL8AAAAP9TeEiLg+gAAABIi5PwAAAASIlQCEiJ2EiDxChbXl9dQVxBXcNmDx9EAABIi4voAAAA"
        . "/1MoSInZQf/VMdtIidhIg8QoW15fXUFcQV3DZg8fRAAASInZ6Dj6//9Ii4vwAAAAicXrgmZmLg8fhAAAAAAAZpBTSIPsIEiJy0iFyXQjSIuJ8AAAAP+TwAAAAEiLQyhIidlI"
        . "g8QgW0j/4A8fgAAAAABIg8QgW8NmLg8fhAAAAAAAAQAAAAMAAAABAAAAAQAAAAEAAAADAAAAAAEAAAEAAAABAAAAAwAAAAAIAAABAAAAAQAAAAMAAAAAgAAAAQAAAAEAAAAD"
        . "AAAAAAAAAQEAAAABAAAAAwAAAAAAgAABAAAAAQAAAAMAAAAAAAABAQAAAAEAAAADAAAAAAAAAgEAAAABAAAAAwAAAAAAAAQBAAAAAQAAAAIAAAABAAAAAgAAAAEAAAACAAAA"
        . "ACAAAAIAAAABAAAAAgAAAAAACAACAAAAAQAAAAIAAAAAABAAAgAAAAEAAAACAAAAAACAAAIAAAABAACAAgAAAAEAAAACAAAAAQAAAAIAAAAAEAAAAwAAAAEAAAACAAAAAABA"
        . "AAMAAAABAAAAAgAAAAAAAAgDAAAAAQAAAAIAAAAAAAAQAwAAAAEAAAACAAAAAAAAIAMAAAABAACAAgAAACAAAAADAAAABwAAAAEAAAAIAAAAAwAAAAcAAAABAAAAIAAAAAMA"
        . "AAAHAAAAAQAAAAABAAADAAAABwAAAAEAAAAAAAEABAAAAAcAAAABAAAAAAACAAQAAAAHAAAAAQAAAAAAABAEAAAABwAAAAEAAAAAAABABAAAAAcAAAABAAAAAAAAgAQAAAD/"
        . "////Dx9AAAEAAABIAAAA"
        mcode_mt_run_threads                     := 0x000030 ; u32 mt_run_threads (mt_ctx *, mt_worker_thread_t, ptr);
        mcode_get_cpu_psabi_level                := 0x0000d0 ; int get_cpu_psabi_level (void);
        mcode_get_kernel32_modulehandle          := 0x0001b0 ; ptr get_kernel32_modulehandle (void);
        mcode_get_getprocaddress                 := 0x0001e0 ; GetProcAddress_t get_getprocaddress (ptr modulehandle);
        mcode_get_cpu_threads                    := 0x000280 ; int get_cpu_threads (mt_ctx *ctx);
        mcode_mt_init_ctx                        := 0x000550 ; mt_ctx *mt_init_ctx (u32);
        mcode_mt_deinit_ctx                      := 0x000860 ; void mt_deinit_ctx (mt_ctx *);
        ;----------------- end of ahkmcodegen auto-generated section ------------------
        
        static code := this.i_b64decode(b64)
        codemap := Map( "get_cpu_psabi_level",       code + mcode_get_cpu_psabi_level
                      , "get_cpu_threads",           code + mcode_get_cpu_threads
                      , "mt_init_ctx",               code + mcode_mt_init_ctx
                      , "mt_deinit_ctx",             code + mcode_mt_deinit_ctx
                      , "mt_run_threads",            code + mcode_mt_run_threads
                      )
        return codemap
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

    pixels_matched := 0
    result := 0
    if (imgu.use_single_thread) {
        result := DllCall(imgu.i_mcode_map["imgutil_imgsrch"],
             "ptr", haystack.ptr, "int", haystack.width, "int", haystack.height,
             "ptr", imgutil_mask_lo, "ptr", imgutil_mask_hi, "int", needle.width, "int", needle.height,
             "char", min_percent_match, "int", force_topleft_pixel_match, "int*", pixels_matched, "ptr") 
    } else {
        result := DllCall(imgu.i_mcode_map["imgutil_imgsrch_multi"], "ptr", imgu.multithread_ctx,
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imgutil_get_pixel_magnitude(px) {
    r := (px & 0x00FF0000) >> 16
    g := (px & 0x0000ff00) >>  8
    b := (px & 0x000000ff)
    return r + g + b
}
