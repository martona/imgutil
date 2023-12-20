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
    i_get_mcode_map(psabi_level := this.i_get_psabi_level()) {

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
        return cmap
    }

    ; -march=core2 scalar, this is just for comparison and not meant to be used
    ; v0 is below the baseline, no real world need for it
    i_get_mcode_map_v0() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 6176 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyMH4HzHBKcExwEE5yA+dwMNmZi4PH4QAAAAAAJBWU4nIidPB6hDB6BAPttIPtvcPtsAPtts"
        . "p0Jkx0CnQD7bVKfJBidFBwfkfRDHKRCnKOdAPTMIPttEp2onRwfkfMcopyjnQD0zCQTnAD53AD7"
        . "bAW17DZmYuDx+EAAAAAABXVlOLXCRIRInISGPySInPSGNMJEAPtsRFichBicKLRCRYQcHoEA+vx"
        . "kiYSAHITI0ch4tEJFAPr8ZImEgByEiNDIdMOdlzaYP+AUUPtsBFD7bSRQ+2yXQR62ZmDx9EAABI"
        . "g8EETDnZc0cPtkEBRCnQmTHQKdAPtlECRCnCidbB/h8x8inyOdAPTMIPthFEKcqJ1sH+HzHyKfI"
        . "50A9MwjnDfb4xwFteX8MPH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASA"
        . "HxTDnZc9gPtkECRCnAmTHQKdAPtlEBRCnSidfB/x8x+in6OdAPTMIPthFEKcqJ18H/HzH6Kfo50"
        . "A9MwjnDfb8xwOuPZmYuDx+EAAAAAABWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRYnKRInIQcHqEA+2"
        . "xEgB0UyNHI5IY0wkSEgBykiNDJZMOdlzZUUPttJED7bARQ+2yesQDx+AAAAAAEiDwQRMOdlzRw+"
        . "2QQJEKdCZMdAp0A+2UQFEKcKJ1sH+HzHyKfI50A9Mwg+2EUQpyonWwf4fMfIp8jnQD0zCOcN9vj"
        . "HAW17DZg8fhAAAAAAAuAEAAABbXsMPH4QAAAAAAFZTQQ+v0EiJyEiNNJUAAAAATI0cMUw52XM+R"
        . "Q+2yWaQRA+2UQHGQQP/RA+2QQJFAdBED7YRRQHQRTnID5PCSIPBBPfaD7baiFH+iNdmiVn8TDnZ"
        . "cstIAfBbXsMPH0QAAFZTQY1A/0iJzg+vwkSNFJUAAAAASI0MgUg5znNHidJMjRyVAAAAAEiJ8ky"
        . "J20j320WF0nQvDx8AMcBmDx9EAABEiwSCRIsMgUSJDIJEiQSBSIPAAUQ50HLnTAHaSAHZSDnKct"
        . "RIifBbXsNmDx9EAABBV0FWQVVBVFVXVlNIgey4AgAADxG0JBACAAAPEbwkIAIAAEQPEYQkMAIAA"
        . "EQPEYwkQAIAAEQPEZQkUAIAAEQPEZwkYAIAAEQPEaQkcAIAAEQPEawkgAIAAEQPEbQkkAIAAEQP"
        . "EbwkoAIAAA+2hCQgAwAARGngAAEBAEmJyonXQQnEQYHMAAAA/0SJ4EWJ5kSJ5kHB7hAPtsSF0kG"
        . "Jw0SJ8w+OEQgAAIP6EA+OcwcAAEUPtuRFD7b2RQ+26/NED289exMAAEyJ4EyJ8fNED281fBMAAG"
        . "YP7/9IweAISMHhCPNED28tdxMAAGZFD3bbjWr/TAnwTAnp80QPbyWgEwAASMHgCEjB4QhMiepMC"
        . "eFMCehIweIISMHgCEjB4QhMCeJMCeBMCfFIweIISMHgCEjB4QhMCfJMCfBMCelIweAISMHhCEwJ"
        . "4UwJ6EjB4AhIweEITAngTAnxSMHgCEjB4QhMCfBMCelIweIITAnqSIkEJEjB4ghIiUwkCEwJ4ki"
        . "JTCQQTInRSMHiCEiJRCQoTInITAnySMHiCEwJ6kjB4ghMCeJBiexBwewESIlUJBhJweQGSIlUJC"
        . "BMicJNAdQPH0AA8w9vMUiDwUBIg8JASIPAQPMPb1HQZg84ADXyEQAA8w9vaeBmD2/C8w9vZCQgZ"
        . "g84ABX6EQAAZg84AAXhEQAAZg/r8GYPb8VmDzgALQASAABmD/zm8w9vXCQQZkQPb9ZmDzgABdgR"
        . "AABmD+vQ8w9vQfBmRA/4VCQgZkQPb8pmD/za8w9vDCRmRA/4TCQQZg84AAXKEQAAZg/r6GYPb8Z"
        . "mRA9vxWYP2MRmD/zNZg90x2ZED/gEJGYP2+BmQQ/fw2YP68RmD2/iZg/Y42YPdOdmD9vcZkEP3+"
        . "NmD+vjZg9v3WYP2NlmD3TfZg/by2ZBD9/bZg/r2WZBD2/KZg/YzmZBD2/xZg90z2YP2PJmQQ9v0"
        . "GYP2NVmD3T3Zg9012ZBD9vKZkQPxekAZkSJasBmD2/pDxGMJAACAABmQQ/b8UQPtqwkAgIAAGYP"
        . "OAAtIhEAAGZBD9vQRIhqwmZED8XtAGYPb+lmRIlqxGZBDzgA7w8RjCTwAQAARA+2rCT1AQAARIh"
        . "qxmZED8XpA2ZEiWrIDxGMJOABAABED7asJOgBAABEiGrKZkQPxe0AZg9v7mZEiWrMZkEPOADtDx"
        . "GMJNABAABED7asJNsBAABEiGrOZkQPxekGZkSJatAPEYwkwAEAAGZBDzgAzkQPtqwkzgEAAGYP6"
        . "81EiGrSZkQPxekAZg9vzmYPOAANqBAAAGZEiWrUDxG0JLABAABED7asJLEBAABEiGrWZkQPxe4B"
        . "ZkSJatgPEbQkoAEAAEQPtqwkpAEAAESIatpmRA/F6QBmD2/OZg84AA1rEAAAZkSJatwPEbQkkAE"
        . "AAEQPtqwklwEAAESIat5mRA/F7gRmRIlq4A8RtCSAAQAARA+2rCSKAQAARIhq4mZED8XpAGYPb8"
        . "pmDzgADS4QAABmRIlq5A8RtCRwAQAARA+2rCR9AQAARIhq5mZED8XuB2ZEiWroZkEPftVEiGrqZ"
        . "kQPxekAZg9vymZEiWrsZkEPOADMDxGUJGABAABED7asJGMBAABEiGruZkQPxeoCZkSJavAPEZQk"
        . "UAEAAEQPtqwkVgEAAESIavJmRA/F6QBmD2/KZg84AA3DDwAAZkSJavQPEZQkQAEAAEQPtqwkSQE"
        . "AAESIavZmRA/F6gVmRIlq+A8RlCQwAQAARA+2rCQ8AQAARIhq+mZED8XpAGYPb8hmRIlq/A8RlC"
        . "QgAQAARA+2rCQvAQAAxkLDAMZCxwDGQssARIhq/mZED8XoAMZCzwDGQtMAxkLXAMZC2wDGQt8Ax"
        . "kLjAMZC5wDGQusAxkLvAMZC8wDGQvcAxkL7AMZC/wBmDzgADZYOAABmRIlowA8RhCQQAQAARA+2"
        . "rCQSAQAARIhowmZED8XpAGYPb8hmRIloxGZBDzgAzw8RhCQAAQAARA+2rCQFAQAARIhoxmZED8X"
        . "oA2ZEiWjIDxGEJPAAAABED7asJPgAAABEiGjKZkQPxekAZg9vzGZEiWjMZkEPOADNDxGEJOAAAA"
        . "BED7asJOsAAABEiGjOZkQPxegGZkSJaNAPEYQk0AAAAGZBDzgAxkQPtqwk3gAAAGYP68FEiGjSZ"
        . "kQPxegAZg9vxGYPOAAFCw4AAGZEiWjUDxGkJMAAAABED7asJMEAAABEiGjWZkQPxewBZkSJaNgP"
        . "EaQksAAAAEQPtqwktAAAAESIaNpmRA/F6ABmD2/EZkSJaNwPEaQkoAAAAEQPtqwkpwAAAGYPOAA"
        . "FuA0AAESIaN5mRA/F7ARmRIlo4A8RpCSQAAAARA+2rCSaAAAARIho4mZED8XoAGYPb8NmDzgABZ"
        . "ENAABmRIlo5A8RpCSAAAAARA+2rCSNAAAARIho5mZED8XsB2ZEiWjoZkEPft1EiGjqZkQPxegAZ"
        . "g9vw2ZEiWjsZkEPOADEDxFcJHBED7ZsJHNEiGjuZkQPxesCZkSJaPAPEVwkYEQPtmwkZkSIaPJm"
        . "RA/F6ABmD2/DZg84AAUyDQAAZkSJaPQPEVwkUEQPtmwkWUSIaPZmRA/F6wVmRIlo+A8RXCRARA+"
        . "2bCRMRIho+mZED8XoAGZEiWj8DxFcJDBED7ZsJD/GQMP/xkDH/8ZAy/9EiGj+xkDP/8ZA0//GQN"
        . "f/xkDb/8ZA3//GQOP/xkDn/8ZA6//GQO//xkDz/8ZA9//GQPv/xkD//0w54Q+Fsfn//4Pl8InoK"
        . "e9IweACSQHCSQHASQHBjUf/Mf9JjWyBBA8fAEEPtgpBxkED/0UPtnoBQcZAAwBFD7ZqAkGJzEEo"
        . "9ESJ+kQPQudEKNpBD7bEQYnURA9C50SJ4kWJ7EEo3IjURIn6RA9C50AA8WZBiQBEiehFGPZECfF"
        . "EANpFiGACRRj2QYgJRAnyANhBiFEBGNJJg8EESYPCBAnQSYPABEGIQf5MOc0PhXj///8PELQkEA"
        . "IAADHADxC8JCACAABEDxCEJDACAABEDxCMJEACAABEDxCUJFACAABEDxCcJGACAABEDxCkJHACA"
        . "ABEDxCsJIACAABEDxC0JJACAABEDxC8JKACAABIgcS4AgAAW15fXUFcQV1BXkFfw2YuDx+EAAAA"
        . "AABBV0FWQVVBVFVXVlNIgewoAQAADxG0JIAAAAAPEbwkkAAAAEQPEYQkoAAAAEQPEYwksAAAAEQ"
        . "PEZQkwAAAAEQPEZwk0AAAAEQPEaQk4AAAAEQPEawk8AAAAEQPEbQkAAEAAEQPEbwkEAEAAESLvC"
        . "SYAQAATYnLRIuMJKABAABIichEif6LjCSoAQAATGPSQQ+2WwFBD6/xD77RD6/WiXQkKIlUJGCJ1"
        . "khj0khp0h+F61HB/h9IwfolKfKA+WRIi7QkkAEAAIlUJCy6AQAAAA9FlCSwAQAAweMIidFBD7ZT"
        . "AkUPthvB4hAJ2kQJ2kQPtl4BiddIi5QkkAEAAEHB4wgPtlICweIQRAnaRA+2HkQJ2oHKAAAA/0U"
        . "pyInWRIlEJGgPiIIIAABNY8dMidKLXCQsSIlEJEBMKcJmD+/AZg9v8PNED289RwoAAE6NBJUAAA"
        . "AASMHiAol8JFhmDzgANV4KAABIiVQkSItUJCjHRCRUAAAAAGYP1nQkCIl0JFw52kSJ+4lMJFBBD"
        . "53BhdIPlcJBIdFBjVf/RIhMJGeJ0IlUJGzB6ARIweAGSIlEJBiJ0IPg8EyNLIUAAAAAKcOJRCQU"
        . "idBMjTSFBAAAAIlcJBBMiWwkcEyJdCR4SItEJEBIi0wkSEmJwUgBwQ+CoAcAAESLVCRQRYXSdBj"
        . "p1AYAAA8fAE6NDABMOckPgoEHAABMichNhcl064B8JGcAD4Q7CAAASItUJEhMiUQkOESLdCRsSI"
        . "lMJDBIi0QkcEiLdCR4SIu8JJABAABMictMiUwkIItsJChEi2QkLPNED341MAkAAEWF/w+OJAYAA"
        . "EGD/g8Phj0HAABMi1QkGEiJ+UmJ2GZFD+/tZkUP7+RNjQw6Dx9AAPNBD28AZkEPb9dmQQ9vz2ZB"
        . "D2/380UPb0AQZkEPb99mQQ9v/2ZFD2/f80EPb2AgZg/b0GYPcdAISIPBQGZBD9vIZg9n0UmDwED"
        . "zQQ9vSPDzRA9vUdBmD9v0ZkEPcdAIZkEP289mD2fx8w9vScBmD3HUCPMPb2ngZkEP2/pmQQ9x0g"
        . "hmQQ9nwPNED29J8GYP29lmD2ffZkEPb/9mD9v9Zg9x0QhmQQ/bx2ZFD9vZZg9x1QhmQQ9nymZBD"
        . "9vPZkEPcdEIZkEPZ/tmQQ9n6WZBD9vvZg9nzfNBD29o8Ek5yWYPcdUIZg9n5WZBD9vnZg9nxGYP"
        . "2shmD3TBZg9v42YPb89mQQ/b32YPcdEIZg9v7mZBD9v/ZkEP2/dmD3HUCGYPZ99mD2fhZg9vymY"
        . "PcdUIZkEP29dmD3HRCGYPZ9ZmD9raZg/v9mYPZ81mD9rhZg9002YPdMxmD9vBZg/bwmYP2wWsBw"
        . "AAZg9vyGYPYM5mD2/RZg9oxmZBD2HMZkEPadRmD/7KZg9v0GZBD2HEZkEPadRmD/7CZg/+yGZED"
        . "/7pD4Vd/v//RItEJBRMjRQHZkEPb8VmD3PYCESLbCQQTI0MA2ZBD/7FZg9vyGYPc9kEZg/+wWYP"
        . "fsFBDxLFZkQP/uhFifNFKcNBg/sHD4YqAgAAScHgAmZBD2/OZkEPb8ZKjQwDZkEPb/5JAfjzD34"
        . "RZkEPb95mQQ9v9mZFD2/W80QPfmEIQYPj+PMPfmkQZg/bymYPcdIIRSnd80QPflkYZkEP28RmD2"
        . "fIZkEPb8bzRQ9+SAhmD9v9ZkEPcdQIZg9wyQhmQQ/bw2YPZ/jzQQ9+AGYPcdUI80EPfmAQZkEP2"
        . "/FmQQ9n1GZBD3HTCPNFD35AGGYP29hmD2feZkEPb/ZmD9v0Zg9x0AhmD3DSCGZBD2frZkUP29Bm"
        . "QQ9x0QhmD3DtCGZBD9vWZg9x1AhmQQ/b7mZBD2fBZg9n1WZBD3HQCGYPcNIIZg9wwAhmQQ/bxmZ"
        . "BD2fgZg9w5AhmQQ/b5mYPZ8RmD3DACGYP2sJmD3D/CGYPb+dmD3TCZg9v0WYPcNsIZkEPZ/JmD3"
        . "HUCGYPcPYIZg9v7mZBD9v+Zg9x0ghmQQ/b9mZBD9vOZg9nz2YPZ9RmD2/jZg9x1QhmD3DSCGYPc"
        . "dQIZg9wyQhmD+//ScHjAmYPZ+VmQQ/b3mYPcOQITQHaZg9n3mYP2uJmD3DbCE0B2WYP2tlmD3TU"
        . "8w9+NXMFAABmD3TLZg/v22YP28JmD9vIZg/bzmYPb9FmD2DLZg9g02YPcMlOZg9v2WYPb8FmD2/"
        . "KZg9h32YPYcdmD2HXZg9hz2YPcMBOZg9w0k5mD/7DZg/+0fMPflwkCGYP/sJmQQ/+xWYPb8hmDz"
        . "gADRQFAABmD+vLZg/+wWYPfsFFD7ZZAkU4WgJFD7ZZAUEPk8BFOFoBQQ+Tw0Uhw0UPtgFFOAJBD"
        . "5PARQ+2wEUh2EQBwUGD/QEPhKABAABFD7ZZBUU4WgVFD7ZZBkEPk8BFOFoGQQ+Tw0Uhw0UPtkEE"
        . "RThCBEEPk8BFD7bARSHYRAHBQYP9Ag+EYgEAAEUPtlkJRThaCUUPtlkKQQ+TwEU4WgpBD5PDRSH"
        . "DRQ+2QQhFOEIIQQ+TwEUPtsBFIdhEAcFBg/0DD4QkAQAARQ+2WQ5FOFoORQ+2WQ1BD5PARThaDU"
        . "EPk8NFIcNFD7ZBDEU4QgxBD5PARQ+2wEUh2EQBwUGD/QQPhOYAAABFD7ZZEkU4WhJFD7ZZEUEPk"
        . "8BFOFoRQQ+Tw0Uhw0UPtkEQRThCEEEPk8BFD7bARSHYRAHBQYP9BQ+EqAAAAEUPtlkWRThaFkUP"
        . "tlkVQQ+TwEU4WhVBD5PDRSHDRQ+2QRRFOEIUQQ+TwEUPtsBFIdhEAcFBg/0GdG5FD7ZZGkU4Whp"
        . "FD7ZZGUEPk8BFOFoZQQ+Tw0Uhw0UPtkEYRThCGEEPk8BFD7bARSHYRAHBQYP9B3Q0RQ+2WR5FOF"
        . "oeRQ+2WR1FD7ZJHEEPk8BFOFodQQ+Tw0Uh2EU4ShxBD5PBRQ+2yUUhwUQByUgB80gB90EpzEWF5"
        . "A+OMgEAAEgB00Qp/XQJRDnlD425+f//TItMJCBJg8EETDlMJDAPgoEBAACLTCRQhckPhHf5//9M"
        . "i0QkOEiLTCQwi0QkWA+21EGJxMHoEEGJw4tEJFyJVCQ4RIn6icUPtvTB6BBBicJIichEi2wkOEG"
        . "J9kwpyEjB+AKD+P98cYPAAUyJRCQgTY18gQRIiUwkMEyJyA8fRAAARA+2QAIPtlgBD7Y4RTjYD5"
        . "PBRTjCQQ+TwEEhyEE43g+TwUQhwUQ460EPk8BEIcFAOP1BD5PARITBdAlEOOcPg9oAAABIg8AET"
        . "Dn4dbNMi0QkIEiLTCQwTQHBTDnJD4Ns////QYnXg0QkVAGLVCRoi0QkVEwBRCRAOdAPjjD4//9F"
        . "MdLrIA8fAEmJ2UmJ+kWJ/WZFD+/tRTHAMcnppvr//0yLVCQgDxC0JIAAAABMidAPELwkkAAAAEQ"
        . "PEIQkoAAAAEQPEIwksAAAAEQPEJQkwAAAAEQPEJwk0AAAAEQPEKQk4AAAAEQPEKwk8AAAAEQPEL"
        . "QkAAEAAEQPELwkEAEAAEiBxCgBAABbXl9dQVxBXUFeQV/DTItEJDjpSP///0yLRCQgQYnXSYnBS"
        . "ItMJDDpuvf//4tEJGBEi1QkUIP4Y34XSYPBBEw5yQ+CGP///0WF0nTp6VH+//9NicrpRf///w8f"
        . "hAAAAAAAMcDDZmYuDx+EAAAAAABmkAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQY"
        . "ICQoMDQ6AgICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICAgICAgAABAgQFBg"
        . "gJCgwNDgMEAgMEBQYHCAkKCwwNDg8JCgIDBAUGBwgJCgsMDQ4PD4CAgICAgICAgICAgICAgIAAA"
        . "gMEBQYHCAkKCwwNDg8FBgIDBAUGBwgJCgsMDQ4PCwwCAwQFBgcICQoLDA0ODwECAgMEBQYHCAkK"
        . "CwwNDg8HCAIDBAUGBwgJCgsMDQ4PDQ4CAwQFBgcICQoLDA0OD/8A/wD/AP8A/wD/AP8A/wABAQE"
        . "BAQEBAQEBAQEBAQEBBAUGB4CAgICAgICAgICAgICAgIAAAQIDgICAgICAgIA="
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000250: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002b0: imgutil_flip_vert     : argb *imgutil_flip_vert(argb *p, u32 w, u32 h)
        . "" ; 0x000320: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x000c50: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x0016e0: get_blob_psabi_level  : u32 get_blob_psabi_level()
        
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000250
                    , "imgutil_filp_vert",         code + 0x0002b0
                    , "imgutil_make_sat_masks",    code + 0x000320
                    , "imgutil_imgsrch",           code + 0x000c50
                    , "get_blob_psabi_level",      code + 0x0016e0
                )
    }

    ; -march=x86-64 baseline optimized machine code blob (mmx huh)
    i_get_mcode_map_v1() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2304 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RB"
        . "FD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEPTNEpyInB99kPScE5wg"
        . "9M0DHAQTnQD53AW8MPHwBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYS"
        . "AHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABI"
        . "g8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcg"
        . "PTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASA"
        . "HyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPT"
        . "ME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHq"
        . "EEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+"
        . "2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwF"
        . "teww8fALgBAAAAW17DVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNB"
        . "jUD/SInORI0UlQAAAAAPr8JIjQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGY"
        . "PH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtl"
        . "QkKEFpwgABAQBECdANAAAA/2YPbuBmD3DcAIP6A35RRI1a/GYPb8sxwEWJ2kHB6gJBjVIBSMHiB"
        . "A8fQADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnQddxB99pIAcFJAcFJAcBDjRST"
        . "hdJ0XmYPbgFmD2/IZg/cw2YP2MtmQQ9+AWZBD34Ig/oBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35"
        . "BBGZBD35IBIP6AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+QAhmQQ9+WQgxwMMPH4AAAAAAQVdBVk"
        . "FVQVRVV1ZTSIPsWA8RdCQwDxF8JECLvCTIAAAARIuUJNgAAABIi5wkwAAAAE2JzkSLjCTQAAAAS"
        . "InISGPKifpBD6/RidaJVCQQQQ++0g+v8khj1kGJ80hp0h+F61FBwfsfSMH6JUQp2kGA+mRFD7ZW"
        . "AYlUJBS6AQAAAA9FlCTgAAAAQcHiCEGJ10EPtlYCweIQRAnSRQ+2FkQJ0kQPtlMBZg9uykiLlCT"
        . "AAAAAQcHiCGYPcMkAD7ZSAsHiEEQJ0kQPthNECdKBygAAAP9FKchmD27SRIlEJChmD3DSAA+Iiw"
        . "AAAEhj10iJzYtcJBRIweECSCnVi1QkEIl0JCxmD3bbSMHlAoXSQQ+VwDnaSInDD53CRYnCRTHtS"
        . "YnIQSHSjVf8idDB6AJEjVgB99hJweMERI0kgkiJ6UmJ2UgB2XIfSInaRYX/dAXrXEyJyk2FyQ+F"
        . "iQMAAE6NDAJMOclz64tEJChBg8UBTAHDQTnFfsYx0g8QdCQwDxB8JEBIidBIg8RYW15fXUFcQV1"
        . "BXkFfw4P4Yw+OTwMAAEmDwQRMOclyvkWF/3TpZg9v6kiJyEyJykwpyEjB+AKDwAGD+AN/Hel4Ag"
        . "AADx+EAAAAAACD6ARIg8IQg/gDD45gAgAA8w9vAmYPb/FmD2/lZg/e4GYP3vBmD3TGZg905WYP2"
        . "8RmD3bDZg/X8IX2dMTzD7z2wf4CTGPOSo0UiotEJCxJidFFhNIPhGn///9IiSwkRIhUJCNMiUQk"
        . "GESJbCQkSIlMJAhEiflJid9Ei2wkEIt0JBRJidFNifJMibQkuAAAAEiLnCTAAAAAZg8fhAAAAAA"
        . "ARTHARTH2ifiD/wMPjpIAAAAPH4AAAAAA80MPbwQB80MPbzwC80IPbzQD80IPbywDSYPAEGYP3v"
        . "hmD97wZg90x2YPdO5mD9vFZg92w2YP18CJxdHtgeVVVVVVKeiJxcHoAoHlMzMzMyUzMzMzAeiJx"
        . "cHtBAHFgeUPDw8PiejB6AgB6InFwe0QAejB6AKD4A9BAcZNOdh1gU0B2kwB200B2USJ4IXAD4S/"
        . "AAAAZkEPbilmD24zZkEPbiJmD2/FZg/e5WYP3sZmD3TlZg90xmYP28RmD3bDZkQP18BBg+ABRQH"
        . "Gg/gBdHdmQQ9uaQRmD25zBGZBD25iBGYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmRA/XwE"
        . "GD4AFFAcaD+AJ0OWYPbmMIZkEPbkEIZkEPbmoIZg9v9GYP3uhmD97wZg90xWYPdOZmD9vEZg92w"
        . "2ZED9fAQYPgAUUBxkjB4AJJAcJIAcNJAcFEKfaF9g+OkP3//0iLBCRJAcFBKf10CUQ57g+Odv7/"
        . "/0yLtCS4AAAASIPCBEg5VCQID4KfAAAAhckPhC/+//9MiftIiywkQYnPRA+2VCQjTItEJBhEi2w"
        . "kJEmJ0UiLTCQI6Wr9//+FwHRFZg9v8kiNNIIPH0AAZg9uAmYPb/lmD2/mZg/e4GYP3vhmD3THZg"
        . "905mYP28RmD3bDZg/XwKgBD4Wa/f//SIPCBEg58nXHTQHBTDnJD4MZ/f//i0QkKEGDxQFMAcNBO"
        . "cUPjpD8///pxfz//2aQRItsJCRMi0QkGEyJ+0GJz4tEJChIiywkQYPFAUQPtlQkI0wBw0E5xQ+O"
        . "W/z//+mQ/P//TInK6S/9//9Micrpgvz//2ZmLg8fhAAAAAAAZpC4AQAAAMOQkJCQkJCQkJCQ"
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_flip_vert     : argb *imgutil_flip_vert(argb *p, u32 w, u32 h)
        . "" ; 0x000310: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x0003f0: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x0008f0: get_blob_psabi_level  : u32 get_blob_psabi_level()
        
        static code := this.i_b64decode(b64)
        cmap := Map(  "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_flip_vert",         code + 0x0002a0
                    , "imgutil_make_sat_masks",    code + 0x000310
                    , "imgutil_imgsrch",           code + 0x0003f0
                    , "get_blob_psabi_level",      code + 0x0008f0
                    )
        return cmap
    }

    ; -march=x86-64-v2 optimized SSE4 machine code blob
    i_get_mcode_map_v2() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2160 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RB"
        . "FD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEPTNEpyInB99kPScE5wg"
        . "9M0DHAQTnQD53AW8MPHwBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYS"
        . "AHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABI"
        . "g8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcg"
        . "PTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASA"
        . "HyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPT"
        . "ME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHq"
        . "EEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+"
        . "2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwF"
        . "teww8fALgBAAAAW17DVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNB"
        . "jUD/SInORI0UlQAAAAAPr8JIjQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGY"
        . "PH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtl"
        . "QkKEFpwgABAQBECdANAAAA/2YPbuBmD3DcAIP6A35RRI1a/GYPb8sxwEWJ2kHB6gJBjVIBSMHiB"
        . "A8fQADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnQddxB99pIAcFJAcFJAcBDjRST"
        . "hdJ0XmYPbgFmD2/IZg/cw2YP2MtmQQ9+AWZBD34Ig/oBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35"
        . "BBGZBD35IBIP6AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+QAhmQQ9+WQgxwMMPH4AAAAAAQVdBVk"
        . "FVQVRVV1ZTSIPsWA8RdCQwDxF8JECLvCTIAAAARIuUJNgAAACJ+02JzkSLjCTQAAAASInISGPKQ"
        . "Q++0kEPr9mJXCQID6/aSGPTSIucJMAAAABIidZIadIfhetRQYnzQcH7H0jB+iVEKdpBgPpkRQ+2"
        . "VgGJVCQMugEAAAAPRZQk4AAAAEHB4ghBiddBD7ZWAsHiEEQJ0kUPthZECdJED7ZTAWYPbsoPtlM"
        . "CQcHiCGYPcMkAweIQRAnSRA+2E0QJ0oHKAAAA/0UpyGYPbtJEiUQkLGYPcNIAD4iTAAAAi1wkCE"
        . "hj10iJzUjB4QJIKdWLVCQMTYnxZg9220jB5QKF28dEJCgAAAAAQQ+VwDnTSInDD53CRYnCSYneQ"
        . "SHSjVf8idDB6AJEjVgB99hJweMERI0kgkiJ6k2J9UwB8nIfTInwRYX/dAXrXUyJ6E2F7Q+F/wIA"
        . "AEyNLAhMOepz64NEJCgBi1wkLEkBzotEJCg52H7CMcAPEHQkMA8QfCRASIPEWFteX11BXEFdQV5"
        . "BX8OD/mMPjsQCAABJg8UETDnqcr1Fhf906WYPb+pJidBMiehNKehJwfgCQYPAAUGD+AN/H+kXAg"
        . "AADx+EAAAAAABBg+gESIPAEEGD+AMPjv0BAADzD28AZg9v8WYPb+VmD97gZg/e8GYPdMZmD3TlZ"
        . "g/bxGYPdsNmD9fYhdt0wvMPvNvB+wJMY8NKjQSASYnFRYTSD4Rp////iXQkEESIVCQXSIlMJBhI"
        . "iRQkTIl0JCBEi3QkCESLbCQMSYnCTInLSIu0JMAAAABmDx+EAAAAAAAx0kUxwIP/Aw+OagEAAGa"
        . "Q80EPbwQS8w9vPBPzD280FvMPbywWSIPCEGYP3vhmD97wZg90x2YPdO5mD9vFZg92w2YP18jzD7"
        . "jJwfkCQQHITDnadbxMAdtMAd5NAdpEieKF0g+EtgAAAGZBD24qZg9uNmYPbiNmD2/FZg/e5WYP3"
        . "sZmD3TlZg90xmYP28RmD3bDZg/XyIPhAUEByIP6AXRxZkEPbmoEZg9udgRmD25jBGYPb8VmD97l"
        . "Zg/exmYPdOVmD3TGZg/bxGYPdsNmD9fIg+EBQQHIg/oCdDZmD25mCGZBD25CCGYPbmsIZg9v9GY"
        . "P3uhmD97wZg90xWYPdOZmD9vEZg92w2YP18iD4QFBAchIweICSAHTSAHWSQHSRSnFRYXtD47s/f"
        . "//SQHqQSn+dAlFOfUPjsX+//9Ig8AESDkEJA+ClAAAAEWF/w+Ejf7//4t0JBBED7ZUJBdJicVIi"
        . "0wkGEiLFCRMi3QkIOnW/f//Zg8fRAAAifrp4f7//0WFwHRIZg9v8kqNHIAPH0AAZg9uAGYPb/lm"
        . "D2/mZg/e4GYP3vhmD3THZg905mYP28RmD3bDZkQP18BBg+ABD4X5/f//SIPABEg52HXESQHNTDn"
        . "qD4N0/f//6SP9//+LdCQQRA+2VCQXSItMJBhMi3QkIOkK/f//TIno6b79//9MiejpEP3//2YuDx"
        . "+EAAAAAAC4AgAAAMOQkJCQkJCQkJCQ"
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_flip_vert     : argb *imgutil_flip_vert(argb *p, u32 w, u32 h)
        . "" ; 0x000310: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x0003f0: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x000860: get_blob_psabi_level  : u32 get_blob_psabi_level()
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_flip_vert",         code + 0x0002a0
                    , "imgutil_make_sat_masks",    code + 0x000310
                    , "imgutil_imgsrch",           code + 0x0003f0
                    , "get_blob_psabi_level",      code + 0x000860
                    )
    }

    ; -march=x86-64-v3 optimized AVX2 machine code blob
    i_get_mcode_map_v3() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2480 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RB"
        . "FD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEPTNEpyInB99kPScE5wg"
        . "9M0DHAQTnQD53AW8MPHwBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYS"
        . "AHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABI"
        . "g8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcg"
        . "PTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASA"
        . "HyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPT"
        . "ME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHq"
        . "EEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+"
        . "2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwF"
        . "teww8fALgBAAAAW17DVlNBD6/QSInISI00lQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNB"
        . "jUD/SInORI0UlQAAAAAPr8JIjQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGY"
        . "PH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtl"
        . "QkKEFpwgABAQBECdANAAAA/8X5btDE4n1Y0oP6B35Pg+oIxf1vyjHAQYnTQcHrA0WNUwFJweIFD"
        . "x9EAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQBSIPAIEw50HXeQffbSAHBSQHBSQHAQo0U2sX5"
        . "b8KD+gN+J8X6byFJg8EQSIPBEEmDwBCD6gTF2djKxMF6f0jwxenczMTBen9J8IXSdFLF+W4JxfH"
        . "Y0MX53MnEwXl+EMTBeX4Jg/oBdDfF+W5JBMXx2NDF+dzJxMF5flAExMF5fkkEg/oCdBnF+W5RCM"
        . "Xp2MjF+dzCxMF5fkgIxMF5fkEIMcDF+HfDZpBBV0FWQVVBVFVXVlNIgeyoAAAAxfgRdCQwxfgRf"
        . "CRAxXgRRCRQxXgRTCRgxXgRVCRwxXgRnCSAAAAAxXgRpCSQAAAAi7wkGAEAAESLnCQoAQAAifhN"
        . "ic9Ei4wkIAEAAExj0kEPvtOJ1kSJw0EPr8EPr/BIY9aJdCQowf4fSGnSH4XrUUjB+iUp8kGA+2R"
        . "FD7ZfAUiLtCQQAQAAiVQkDLoBAAAAD0WUJDABAABBweMIidVBD7ZXAsHiEEQJ2kUPth9ECdpED7"
        . "ZeAcV5bsIPtlYCQcHjCMRCfVjAweIQRAnaRA+2HkQJ2oHKAAAA/8X5bvrE4n1Y/0Qpyw+IGAQAA"
        . "Ehj102J1It0JAyJXCQsSSnUxe120sXxdslBie5JweQCxXl/xcV5f8aFwEEPlcE58EqNFJUAAAAA"
        . "QQ+dwESJzkSNT/hEIcZFichBwegDRY1YAUH32EeNLMFFMcBJweMFRYnBSYnIifFMiePF+W/fxfl"
        . "v502JwkwBww+CiAMAAESJTCQkRIn26x1mLg8fhAAAAAAATYXSdX9MjVQVAEw50w+CWQMAAEyJ1Y"
        . "X2dOZIid1MKdVIwf0Cg8UBg/0HD46HAgAAxEF9b9jFfW/XTYnR6xJmkIPtCEmDwSCD/QcPjmoCA"
        . "ADEwX5vAcUt3sjFJd7gxZ10wMRBNXTKxbXbwMX9dsLFfdfwRYX2dMnzRQ+89kGD5jxPjRQxRItM"
        . "JCiEyQ+E9wEAAEiJVCQQQYn2iEwkI0yJRCQYSIkcJInDiVwkCIt0JAxMidJMiflMibwkCAEAAEy"
        . "LhCQQAQAAid0PH4QAAAAAADHAMdtBifmD/wd+Sw8fQADF/m8EAsRBfd4MAMV93hQBxEE1dAwASI"
        . "PAIMWtdMDFtdvAxf12wsV918jzRQ+4yUHB+QJEActMOdh1xUwB2U0B2EwB2kWJ6UGD+QMPjn8BA"
        . "ADF+m8CQYPpBEiDwRBJg8AQxEF53kjwxXneUfBIg8IQxEExdEjwxal0wMWx28DF+XbBxfnXwPMP"
        . "uMDB+AJFhckPhLcAAADFeW4SxEF5bhjFeW4JxEEp3snEwSnew8WhdMDEQTF0ysWx28DF+XbBxXn"
        . "X+EGD5wFEAfhBg/kBdHHFeW5SBMRBeW5YBMV5bkkExEEp3snEwSnew8WhdMDEQTF0ysWx28DF+X"
        . "bBxXnX+EGD5wFEAfhBg/kCdDXF+W5CCMRBeW5ICMV5blEIxTHe2MRBed7Sxal0wMRBMXTLxbHbw"
        . "MX5dsHFedf4QYPnAUQB+EnB4QJMAclNAchMAcoB2CnGhfYPjlABAABMAeIp/XQIOe4Pjoj+//+L"
        . "XCQITIu8JAgBAABJg8IETDkUJA+CcQEAAEWF9g+EPf7//4nYSItUJBBIixwkRIn2D7ZMJCNMi0Q"
        . "kGOmS/f//QYP5Yw+O9wAAAEmDwgRMOdMPgs0AAACF9g+Fc/3//+vfDx+AAAAAADHA6bb+//9Nid"
        . "GD/QN+LsTBem8BxWHeyMV53tXFqXTAxEFhdMnFsdvAxfl2wcV51/BFhfZ1VEmDwRCD7QSF7XRvT"
        . "Y00qesSZg8fhAAAAAAASYPBBE058XRJxMF5bgHFWd7IxUne0MWpdMDFMXTMxbHbwMX5dsHF+dfo"
        . "g+UBdNFMidVNicrpxvz//2bzRQ+81mZBweoCRQ+30k+NFJHpMv3//0UxyUyJ1U2Jyumg/P//SQH"
        . "STDnTD4Ou/P//RItMJCRBifZBg8EBSQHQRDlMJCwPjU/8//9FMdLF+HfF+BB0JDDF+BB8JEBMid"
        . "DFeBBEJFDFeBBMJGDFeBCcJIAAAADFeBBUJHDFeBCkJJAAAABIgcSoAAAAW15fXUFcQV1BXkFfw"
        . "0iLVCQQRItMJCSJ2EyLRCQYD7ZMJCNBg8EBSQHQRDlMJCwPjdr7///riQ8fALgDAAAAw5CQkJCQ"
        . "kJCQkJA="
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_flip_vert     : argb *imgutil_flip_vert(argb *p, u32 w, u32 h)
        . "" ; 0x000310: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x000410: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x0009a0: get_blob_psabi_level  : u32 get_blob_psabi_level()
        
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_flip_vert",         code + 0x0002a0
                    , "imgutil_make_sat_masks",    code + 0x000310
                    , "imgutil_imgsrch",           code + 0x000410
                    , "get_blob_psabi_level",      code + 0x0009a0 
                )
    } 

    ; -march=x86-64-v4 optimized AVX512 machine code blob
    i_get_mcode_map_v4() {
        static b64 := ""
        . "" ; imgutil_all.c
        . "" ; 2064 bytes
        . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
        . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
        . "" ; GNU assembler (GNU Binutils) 2.41
        . "" ; flags: -O2
        . "KdGJyPfYD0jBQTnAD53AD7bAw2ZmLg8fhAAAAAAAZpBTiciJ0cHqEEGJwQ+20g+23A+2wEHB6RB"
        . "FD7bJQSnRRInK99pBD0jRQYnZD7bdD7bJQSnZRYnKQffaRQ9JykQ5ykEPTNEpyInB99kPScE5wg"
        . "9M0DHAQTnQD53AW8MPHwBXVlNEi1QkSExjwotUJFhEichFictMY0wkQA+23EHB6xBBD6/QSGPST"
        . "AHKSI00kYtUJFBBD6/QSGPSTAHKSI0UkUg58nNqRQ+22w+220QPtshBg/gBdBLrZw8fgAAAAABI"
        . "g8IESDnyc0cPtkoBKdmJyPfYD0jBD7ZKAkQp2UGJyEH32EEPScg5yA9MwQ+2CkQpyUGJyEH32EE"
        . "PScg5yA9MwUE5wn26McBbXl/DDx9AALgBAAAAW15fww8fgAAAAABJweAC6xJmLg8fhAAAAAAATA"
        . "HCSDnyc9gPtkoCRCnZicj32A9IwQ+2SgEp2YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9Mw"
        . "UE5wn3BMcDrlWZmLg8fhAAAAAAAZpBWUw+vVCQ4TGNEJFBEi1QkQEhj0kkB0ESJyESJy0qNNIFM"
        . "Y0QkSA+2xMHrEEwBwkiNFJFIOfJzYA+220QPtthFD7bJ6wwPHwBIg8IESDnyc0cPtkoCKdmJyPf"
        . "YD0jBD7ZKAUQp2UGJyEH32EEPScg5yA9MwQ+2CkQpyUGJyEH32EEPScg5yA9MwUE5wn26McBbXs"
        . "MPH0QAALgBAAAAW17DVlNED6/CSInISo00hQAAAABMjRwxTDnZcz5FD7bJZpBED7ZRAUQPtkECx"
        . "kED/0UB0EQPthFFAdBFOcgPk8JIg8EE99oPttqIUf6I12aJWfxMOdlyy0gB8Fteww8fRAAAVlNB"
        . "jUD/SInORI0UlQAAAAAPr8JIjQyBSDnOc0eJ0kyNHJUAAAAASInyTInbSPfbRYXSdC8PHwAxwGY"
        . "PH0QAAESLBIJEiwyBRIkMgkSJBIFIg8ABRDnQcudMAdpIAdlIOcpy1EiJ8Ftew2YPH0QAAEQPtl"
        . "QkKEFpwgABAQBECdANAAAA/2LyfUh80IP6D35ag+oQYvH9SG/KMcBBidNBwesERY1TAUnB4gZmD"
        . "x9EAABi8X9IbxwBYvFlSNjBYtH+SH8EAGLxdUjcw2LR/kh/BAFIg8BATDnQddZBweMESAHBSQHB"
        . "SQHARCnahdJ0L7gBAAAAxOJp98CD6AHF+JLIYvF+yW8BYvF9SNjKYvF9SNzCYtF+SX8IYtF+SX8"
        . "BMcDF+HfDZmYuDx+EAAAAAABmkEFXQVZBVUFUVVdWU0iD7DhBvwEAAACLvCSoAAAARIuUJLAAAA"
        . "BEi5wkuAAAAEiJyEhjyon6TImMJJgAAABBD6/SRQ++y0iLtCSYAAAARYnGRA+vyokUJElj0USJy"
        . "0hp0h+F61HB+x9IwfolKdpBgPtkRA+2XgFED0W8JMAAAACJVCQESIuUJJgAAABBweMID7ZSAsHi"
        . "EEQJ2kQPth5Ii7QkoAAAAEQJ2kQPtl4BYvJ9SHzqSIuUJKAAAABBweMID7ZSAsHiEEQJ2kQPth5"
        . "ECdqBygAAAP9i8n1IfOJFKdYPiA8DAABIY9dIic2LdCQESMHhAkgp1YsUJESNZ/Bi83VIJcn/SM"
        . "HlAkWJ9TnyQQ+dwIXSRInGSYnARIngD5XCwegEIdYx202JwkSNWAHB4ARJichBKcSJ8EnB4waJ3"
        . "kSJy0GJwUiJ6kyJ0GLx/Uhv3UwB0g+CjAIAAEyJVCQQQYn2RYnKSInRTYnBRInu6xeQSYnFSIXA"
        . "dX9LjUQNAEg5wQ+CTgIAAEWF/3TlYvH9SG/USInKSYnASCnCSMH6AoPCAYP6D38a6cgBAAAPH0Q"
        . "AAIPqEEmDwECD+g8PjrMBAABi0X9IbwBi831IPssFYvN9ST7KAmLyfkgowWLzfUgfwQDF+JjAdM"
        . "nF+JPAZvMPvMAPt8BJjQSAugEAAABFhNIPhFIBAACJXCQgSIlMJAhEiXQkJESIVCQriXQkLEyJT"
        . "CQYRYn5iwwkTIusJKAAAABIicNIi7QkmAAAAESLdCQEQYnKZg8fRAAARTHAMclMY/+D/w9+SQ8f"
        . "AGKxf0hvFANis21IPgwGBWKTbUk+TAUAAkmDwEBi8n5IKMFi831IH9kAxXiT+/NFD7j/RAH5TTn"
        . "DdcZMAd5NAd1MAdtNY/xFhf90WsRiAffCQYPoAUnB5wLEwXuSyGLxfslvA0wB+2LhfslvDmLRfs"
        . "lvVQBMAf5NAf1is31IPtEFYvN9Sj7SAmLyfkgowmLzfUkf4QDFeJPEZvNFD7jARQ+3wEQBwUEpz"
        . "kWF9g+O7QAAAEgB60Ep+nQJRTnWD44u////SIPABEg5RCQID4LhAAAARYXJD4Ty/v//RYnPi1wk"
        . "IEiLTCQIRIt0JCRED7ZUJCuLdCQsTItMJBjpNP7//4P7Yw+OlgAAAEiDwARIOcFya0WF/3Tp6Rj"
        . "+//+F0nRRQb0BAAAAxMJp99WD6gHF+JLKYsF+yW8AYvN9QD7VBWLzfUI+xAJi4n5IKMBi831BH8"
        . "kAxfiYyXQYxfiT0WbzD7zSSYnFD7fSSY0EkOmr/f//TAHISDnBD4O9/f//TYnIRYnRTItUJBBBi"
        . "fVEifaDxgFNAcJEOe4PjlD9//8xwMX4d0iDxDhbXl9dQVxBXUFeQV/DRYnPi1wkIEyLVCQQTItE"
        . "JBiLdCQkRItsJCxED7ZMJCvruQ8fQAC4BAAAAMOQkJCQkJCQkJCQ"
        . "" ; 0x000000: imgutil_channel_match : i32 imgutil_channel_match(i32 a, i32 b, i32 t)
        . "" ; 0x000020: imgutil_pixels_match  : u32 imgutil_pixels_match(argb p1, argb p2, i32 t)
        . "" ; 0x000080: imgutil_column_uniform: u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
        . "" ; 0x0001a0: imgutil_row_uniform   : i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
        . "" ; 0x000240: imgutil_makebw        : argb *imgutil_makebw(argb *start, u32 w, u32 h, u8 threshold)
        . "" ; 0x0002a0: imgutil_flip_vert     : argb *imgutil_flip_vert(argb *p, u32 w, u32 h)
        . "" ; 0x000310: imgutil_make_sat_masks: u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
        . "" ; 0x0003d0: imgutil_imgsrch       : argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft)
        . "" ; 0x000800: get_blob_psabi_level  : u32 get_blob_psabi_level()
                        
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_channel_match",     code + 0x000000
                    , "imgutil_pixels_match",      code + 0x000020
                    , "imgutil_column_uniform",    code + 0x000080
                    , "imgutil_row_uniform",       code + 0x0001a0
                    , "imgutil_makebw",            code + 0x000240
                    , "imgutil_flip_vert",         code + 0x0002a0
                    , "imgutil_make_sat_masks",    code + 0x000310
                    , "imgutil_imgsrch",           code + 0x0003d0
                    , "get_blob_psabi_level",      code + 0x000800
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
