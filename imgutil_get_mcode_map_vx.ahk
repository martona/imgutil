#Requires AutoHotkey v2.0

; imgutil class member functions

    ;########################################################################################################
    ; scalar only, this is just for benchmarking comparison and not meant to be used. v0 is below the psabi 
    ; baseline, there's no equivalent psabi level and get_cpu_psabi_level should never return it.
    ; (theoretically it might, if e.g. SSE has been masked off from CPUID in a VM, so... eh?)
    ;########################################################################################################
    i_get_mcode_map_v0() {
        static b64 := ""
    . "" ; imgutil_all.c
    . "" ; 3936 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVVBVFVXVlOJ00iJzYXbfn9MiyGNS/9FMdtJizlNiyhMieJIjXSPBEiJ+A8fRAAAD7ZKAjhIAg+2SgFBD5PCOEgBD5PBQSHKD7YKOAgPk8FIg8AESIPCBA+2yUQh0UEBy0g5"
    . "8HXKSMHjAkSJ2EkB3EkB3UgB30yJZQBNiShJiTlbXl9dQVxBXcMPH4AAAAAARTHbRInYW15fXUFcQV3DkEWFwHQcRYnAMcBmDx9EAABEiwyCRIkMgUiDwAFMOcB178NmZi4P"
    . "H4QAAAAAAA8fAFdWU0iD7CBEi1lASYnIQQ+v00mLQAhJY3A4idFJY1ggQQHLSWNIGESLiMgAAACJ0DHSQffxMdJBicJEidhB9/FJY1AwQYnDQYtANEQB0A+vxkiYSAHQSYtQ"
    . "KEiNFIJBi0AcRAHQD6/DSJhIAchJi0gQRTnaSI0MgX0tQYt4PEjB5gJIweMCZi4PH4QAAAAAAEGJ+EGDwgHoNP///0gB8kgB2UU503XpSIPEIFteX8OQSInISGNMJCiFyXg0"
    . "TI1ciATrDg8fRAAASIPABEw52HQfRDpIAkEPk8JEOkABD5PBQYTKdOM6EHLfw2YPH0QAADHAw2ZmLg8fhAAAAAAAZpBBV0FWQVVBVFVXVlNED7ZcJGgPtlwkcA+2dCR4hdJJ"
    . "icoPjnwAAACJ0kUx5EyNLJFBD7YKQcZAAwBBD7ZSAUHGQQP/QQ+2QgJBic5FKN6J1UUPQvSJx0Ao3UEPQuxAKPdBD0L8RADZRYgwRRj/QYhoAUQJ+QDaQYh4AkUY/0GICUQJ"
    . "+kAA8EGIUQEY0kmDwgRJg8EECdBJg8AEQYhB/k056nWNMcBbXl9dQVxBXUFeQV/DZmYuDx+EAAAAAAAPHwBBV0FWQVVBVFVXVlNIgeyIAAAATI1MJHDHRCRcAAAAAEmJz0yJ"
    . "zUyNRCRoTYnFZpC4AQAAAPBBD8EHQYtXLEErV0Q5wg+MjgIAAEljVyhJi08gD6/CSJhIjQyBSWNHQEgpwkiJw0GLR0xIjTyVAAAAAEyNFDmFwA+E+wAAAEk5ynKuQQ+2R1xI"
    . "jXQkeEyJVCQ4TYn8iEQkQEEPtkddiEQkSEEPtkdeiEQkWGYPH0QAAEiLRCQ4RA+2TCRYRA+2RCRID7ZUJEBIKchIwfgCg8ABiUQkIOgX/v//SIXASInBD4SGAAAASYtEJDBI"
    . "iUwkeEGLVCRURYt0JFBIiUQkaEmLRCQ4QYnXRDnySIlEJHB/Q0WF9nQ+SYnpTYnoSInNTYnlQYnUDx9AAInaSInx6D78//9IAXwkeEEpx0Ep3nQFRTn3fuRIielEieJMic1N"
    . "iexNicVFhf8PjiIBAABIg8EESDlMJDgPg0X///9Niefpvf7//w8fRAAASTnKD4K5AAAASYtHMEyNZCR4TIlUJEhFi0dUTIm8JNAAAABBi1dQSIlEJDhJi0c4QTnQiVQkWEEP"
    . "nsaF0kEPlcFEifZIiUQkQEmJzkQhzkmJ6USJxU2J6EiLRCQ4QIT2TIl0JHhIiUQkaEiLRCRASIlEJHB0YkSLbCRYQYnvZi4PH4QAAAAAAInaTInh6Gb7//9IAXwkeEEpx0Ep"
    . "3XQFRTnvfuRFhf9+N0mDxgRMOXQkSHOkTIu8JNAAAABMic1NicVIg3wkUAAPhOr9//9Mi2QkUOtBDx8AQYnvRYX/f8lMifFNicVFif5Mi7wk0AAAAEGJ6EiJTCRQTInNRSnw"
    . "RIlEJFzrvEWJ/k2J50mJzEQp8olUJFxJjUcUQbgBAAAADx+EAAAAAABEicKGEITSdfeLdCRcQTl3EH05QYl3EE2JZwiGEEE5d1APj1/9//9Bi0csQYcH6VP9//8PH0QAAEiB"
    . "xIgAAABbXl9dQVxBXUFeQV/DhhCLRCRcQTlHUA+PKv3//+vJZpBXVlOLXCRIRInISGPySInPSGNMJEAPtsRFichBicKLRCRYQcHoEA+vxkiYSAHITI0ch4tEJFAPr8ZImEgB"
    . "yEiNDIdMOdlzaYP+AUUPtsBFD7bSRQ+2yXQR62ZmDx9EAABIg8EETDnZc0cPtkEBRCnQmTHQKdAPtlECRCnCidbB/h8x8inyOdAPTMIPthFEKcqJ1sH+HzHyKfI50A9MwjnD"
    . "fb4xwFteX8MPH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHxTDnZc9gPtkECRCnAmTHQKdAPtlEBRCnSidfB/x8x+in6OdAPTMIPthFEKcqJ18H/"
    . "HzH6Kfo50A9MwjnDfb8xwOuPZmYuDx+EAAAAAABWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRYnKRInIQcHqEA+2xEgB0UyNHI5IY0wkSEgBykiNDJZMOdlzZUUPttJED7bARQ+2"
    . "yesQDx+AAAAAAEiDwQRMOdlzRw+2QQJEKdCZMdAp0A+2UQFEKcKJ1sH+HzHyKfI50A9Mwg+2EUQpyonWwf4fMfIp8jnQD0zCOcN9vjHAW17DZg8fhAAAAAAAuAEAAABbXsMP"
    . "H4QAAAAAAFNIg+xARItUJHBNhcAPlMBNhclBD5TDRAjYdTxIhcl0N0UPttJBacIAAQEARAnQDQAAAP9BicKIZCQoQcHqEIhEJCBEiFQkMOgj+v//SIPEQFvDDx9EAAAxwEiD"
    . "xEBbw0FXQVZBVUFUVVdWU0iB7KgAAACLnCQYAQAAi7wkIAEAAESLnCQoAQAASIu0JDgBAABNhclIichMY9IPlMFMicpIg7wkEAEAAABBD5TBRAjJD4WAAQAASIXAD4R3AQAA"
    . "idlFD77LQSn4D6/PRIlEJGREicdEi4QkMAEAAEQPr8mJTCRISWPpQcH5H0hp7R+F61FIwf0lRCnNRYXAiWwkRA+FSwEAAEGA+2QPhEEBAACF/w+IHwEAAExjw0yJ1YnPSIm0"
    . "JDgBAABOjRyVAAAAAEwpxUiJ1kyNjCSQAAAASMHlAoXJi0wkREyNNChBD5XETInaOc9MifFBD53ARTHSRSHERYnXTI2EJIgAAAAPH0AASI28JJgAAABIOcEPgp4AAABEiXwk"
    . "TEmJx0iJRCRQSIlUJFhIiUwkOA8fhAAAAAAASIuEJBABAABFhORIibQkiAAAAEyJvCSYAAAASImEJJAAAAAPhFcCAABEi2wkSESLdCREDx9EAACJ2kiJ+ei+9v//SAGsJJgA"
    . "AABBKcZBKd10BUU57n7hRYX2D44uAgAASYPHBEw5fCQ4c5VEi3wkTEiLRCRQSItUJFhIi0wkOIt8JGRBg8cBSAHQSAHRQTn/D446////RTH/TIn4SIHEqAAAAFteX11BXEFd"
    . "QV5BX8NIi7wkEAEAAItMJGRED7ZHAkQPtk8BQcHgEEHB4QhFCchED7YPRQnIRInHgc8AAAD/hcmJfCR0eK2LTCRITGPDTYnUQIh8JFBEi1wkRE0pxEmJwUiJlCQIAQAAScHk"
    . "AkiJtCQ4AQAAhclBD5XHRDnZSo0MlQAAAABBD53ARTHbRSHHwe8QSIlMJHhOjQQgRIh8JGNEidhAiHwkWA8fRAAATTnITInJD4L/AAAAi1QkdEiNrCSQAAAAiUQkcEiNtCSY"
    . "AAAATIlMJGhMiUQkOA+2/ol8JExIjbwkiAAAAA8fAEiLRCQ4RA+2TCRYRA+2RCRMD7ZUJFBIKchIwfgCg8ABiUQkIOjH9v//SIXASYnHD4SIAAAASIuEJAgBAABMibwkmAAA"
    . "AIB8JGMASImEJIgAAABIi4QkEAEAAEiJhCSQAAAAD4S4AAAARIt0JEhJielJifhEi2wkRA8fhAAAAAAAidpIifHo5vT//0wBpCSYAAAAQSnFQSnedAVFOfV+4UWF7UyJzUyJ"
    . "xw+OfAAAAEmNTwRIOUwkOA+DQ////4tEJHBMi0wkaEyLRCQ4SIt8JHiDwAFJAflJAfiLfCRkOfgPjtv+///pHP7//2YPH0QAAESLdCRERYX2D4/S/f//SIu0JDgBAABIhfYP"
    . "hPr9//+LVCRERCnyiRbp7P3//w8fAESLbCRERYXtf4RIi7QkOAEAAEiF9g+Ezv3//4tUJEREKeqJFunA/f//Dx+AAAAAAFVXVlNIgeyIAAAASIusJNAAAABIi7Qk2AAAAGYP"
    . "boQk4AAAAESLlCTwAAAASIXtZkgPbs1mSA9u0UiLnCQAAQAAZkgPbuYPlMBIhfZmSA9u6kmJy2YPbMwPlMFmD26kJOgAAABmQQ9u2GYPbNUIyGZBD27pZg9ixGYPYt0PhQ4B"
    . "AABIhdIPhAUBAAAxwLkJAAAAi5Qk4AAAAA+vlCToAAAASI18JCDzSKuLhCT4AAAAZg/WRCRgTI1EJCAPEVQkOGYPbuJmD9ZcJEgPEUwkUIXAD5XAQYD6ZMcHAAAAAA+UwUSI"
    . "VCRoRQ++0gnID7ZOAUQPr9IPtsAPtlUBZg9uwGYPYsRmD9ZEJGxJY8JBwfofSGnAH4XrUcHiCMHhCEjB+CVEKdCJRCR0D7ZFAsHgEAnQD7ZVAAnQD7ZWAmYPbsDB4hAJyg+2"
    . "DgnKTInZgcoAAAD/Zg9u6mYPYsVIjRVP9f//Zg/WRCR4Qf+T0AAAAEiF23QGi0QkMIkDSItEJChIgcSIAAAAW15fXcNmDx9EAAAxwEiBxIgAAABbXl9dw2aQV1ZTSIPsIEyL"
    . "VCRgRIucJIAAAACLnCSIAAAASIXJSGPCD4SJAAAATYXSD4SAAAAAi1QkcDH2RAnCC1QkaAnCeGNFhdt+aoXbfmZFD6/BSGNUJGhJY/lIY3QkeEjB5wJNY8BJAcCLRCRwD69E"
    . "JHhKjQyBSMHmAkiYSAHQSY0UgkUx0mYPH0QAAEWJ2EGDwgHojPL//0gB+UgB8kQ503/pvgEAAACJ8EiDxCBbXl/DZpAx9onwSIPEIFteX8MPH0AASIPseEyLnCSoAAAASIXS"
    . "SInID4ToAAAATYXbD4TfAAAAi4wkuAAAAEUx0kQJyQuMJLAAAABECcEPiLoAAABEi5QkyAAAAEWF0g+OsQAAAIuMJNAAAACFyQ+OogAAAGZID27Si5QkoAAAAGZID27AZkEP"
    . "btlmD2zCDxFEJChIicFmQQ9uwGYPYsNmD9ZEJDhmD26MJMAAAABMjUQkIGYPbqQkyAAAAMdEJCAAAAAAZg9uhCSwAAAAiVQkQIuUJNAAAABmD2LMTIlcJEhmD26sJLgAAABm"
    . "D2LFZg9swQ8RRCRQiVQkYEiNFaTx////kNAAAABBugEAAABEidBIg8R4w0Ux0kSJ0EiDxHjDDx9EAAAxwMOQkJCQkJCQkJCQkJCQ"
    mcode_i_imgutil_pixelmatchcount_v0 := 0x000000 ; define i_imgutil_pixelmatchcount i_imgutil_pixelmatc(a)_mm_popcnt_u32(a)
    mcode_imgutil_column_uniform       := 0x000590 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform          := 0x0006b0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks       := 0x000760 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch              := 0x0007c0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi        := 0x000be0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit                 := 0x000d80 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi           := 0x000e40 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level         := 0x000f50 ; u32 get_blob_psabi_level()
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
    . "" ; 5552 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "RYXAdByLAokBQYP4AXQSi0IEiUEEQYP4AnQGi0IIiUEIw2ZmLg8fhAAAAAAADx8AVVdWU0iD7ChJicuLSUBJi0MID6/RRIuIyAAAAEGJ0InQMdJB9/Ex0onGQo0EAUH38Ulj"
    . "UzCJw0GLQzQB8EEPr0M4SJhIAdBJi1MoTI0UgkGLQxxJY1MYAfBBD69DIEiYSAHQSYtTEEyNDII53n1ekEWLQzxBg/gDflxBg+gEMdJEicDB6AKNSAFIweEEDx8A80EPbwQS"
    . "QQ8RBBFIg8IQSDnRdez32EmNFApMAcmDxgFFjQSA6Bf///9JY0M4TY0UgkljQyBNjQyBOfN1o0iDxChbXl9dw0yJ0kyJyYPGAejs/v//SWNrOEljeyBIweUCSMHnAkkB6kkB"
    . "+TnzdM9mkEWLQzxMidJMicmDxgFJAepJAfnouP7//znzf+RIg8QoW15fXcNmZi4PH4QAAAAAAEFXQVZBVUFUVVdWU0iD7EgPEXQkMDHAZg92yboBAAAA8A/BEUSLQSxEK0FE"
    . "QTnQD4zABQAATGNpKEyLSSBBD6/VSGPSSY0UkUSLSUBNY8FNKcVEi0FMScHlAk6NPCpFhcAPhAkDAABJOddyr0WNUfzzD29hYPMPb1lwRYnQQcHoAkWNYAFB99hHjTSCScHk"
    . "BEGJwA8fRAAATIn4SCnQSMH4AoPAAYP4A38W6SECAACQg+gESIPCEIP4Aw+OEAIAAPMPbwJmD2/sZg9v02YP3tBmD97oZg90xWYPdNNmD9vCZg92wWZED9fQRYXSdMLzRQ+8"
    . "0kHB+gJJY8JIjRSCi3lUi3FQSItZMEyLWTg59w+PDQIAAEiJ0In9hfYPhAACAACJfCQISIlUJBBmDx9EAABFMdIx0kGD+QMPjokBAACJbCQoDx9EAADzQg9vBBDzQg9vFBPz"
    . "Qw9vLBNmD97QZg/e6GYPdMLzQw9vFBNJg8IQZg901WYP28JmD3bBZg/X6InvZtHvZoHnVVUp/YnvZsHtAmaB5zMzZoHlMzMB/YnvZsHvBAHvZoHnDw+J/WbB7QgB72bB7wKD"
    . "5wcB+k051HWHi2wkKEwB400B40wB4EWJ8kWF0g+EtQAAAGYPbihmQQ9uM2YPbhNmD2/FZg/e1WYP3sZmD3TVZg90xmYP28JmD3bBZg/X+IPnAQH6QYP6AXRwZg9uaARmQQ9u"
    . "cwRmD25TBGYPb8VmD97VZg/exmYPdNVmD3TGZg/bwmYPdsFmD9f4g+cBAfpBg/oCdDVmQQ9uUwhmD25ACGYPbmsIZg9v8mYP3uhmD97wZg90xWYPdNZmD9vCZg92wWYP1/iD"
    . "5wEB+knB4gJMAdNNAdNMAdAp1UwB6EQpznQIOfUPjo/+//+LfCQISItUJBCF7X55SIPCBEk51w+D3f3//0SJwOlY/f//Dx9EAABFicrpAf///4XAdOdMjRSCDx+EAAAAAABm"
    . "D24CZg9v7GYPb9NmD97QZg/e6GYPdMVmD3TTZg/bwmYPdsFmD9fAqAEPhe79//9Ig8IETDnSdcdEicDp+vz//4n9he1/h4n4KehMjUEUQboBAAAARYnRRYYIRYTJdfU5QRAP"
    . "jcICAACJQRBIiVEIRYYIO0FQD4y//P//i1EshxHptfz//2YuDx+EAAAAAABJOdcPgjICAABIi3Ewi3lQRItRVEyLYThIiXQkGEGNcfxBOfpBifYPnsOF/0EPlcNBwe4CRYnw"
    . "QY1uAUH32EjB5QRGjTSGRITbD4QSAgAARIlUJBBNieCJRCQsSImMJJAAAAAPH0QAAEiJVCQITItUJBhIidBNicNEi2QkEIn7TInGZg8fRAAARTHAMclEicpBg/kDD46gAAAA"
    . "RIlkJCiQ80IPbwQA80MPbxQC80MPbxwDZg/e0GYP3thmD3TC80MPbxQDSYPAEGYPdNNmD9vCZg92wWZED9fgRIniZtHqZoHiVVVBKdREieJmQcHsAmaB4jMzZkGB5DMzQQHU"
    . "RIniZsHqBEQB4maB4g8PQYnUZkHB7AhEAeJmweoCg+IHAdFMOcUPhXf///9Ei2QkKEkB6kkB60gB6ESJ8oXSD4S/AAAAZg9uGGZBD24jZkEPbhJmD2/DZg/e02YP3sRmD3TT"
    . "Zg90xGYP28JmD3bBZkQP18BBg+ABRAHBg/oBdHdmD25YBGZBD25jBGZBD25SBGYPb8NmD97TZg/exGYPdNNmD3TEZg/bwmYPdsFmRA/XwEGD4AFEAcGD+gJ0OWZBD25TCGYP"
    . "bkAIZkEPbloIZg9v4mYP3thmD97gZg90w2YPdNRmD9vCZg92wWZED9fAQYPgAUQBwUjB4gJJAdJJAdNIAdBBKcxMAehEKct0CUE53A+Oc/7//0iLVCQISYnwRYXkfklIg8IE"
    . "STnXD4M5/v//i0QkLEiLjCSQAAAASIN8JCAAD4Rk+v//SItUJCDpav3//w8fgAAAAABIg8IESTnXctpFhdJ/8kWJ1OsNRItUJBBIi4wkkAAAAESJ0EiJVCQgRCng67YPEHQk"
    . "MEiDxEhbXl9dQVxBXUFeQV/DRYYIOUFQD48E+v//6UD9//8PH0AAV1ZTi1wkSESJyEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhIAdBI"
    . "jRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPCBEw52nNHD7ZKAUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9"
    . "wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusSZi4PH4QAAAAAAEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJic/3"
    . "3w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItcJEBIY9JIic5IY0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2wEUP"
    . "tsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0SLVCQoTYXA"
    . "idAPlMJNhclBD5TDRAjaD4XhAAAASIXJD4TYAAAARQ+20kFp0gABAQBECdKBygAAAP9mD27iZg9w3ACD+AN+VESNWPxmD2/LMcBFidpBweoCQY1SAUjB4gQPH4AAAAAA8w9v"
    . "BAFmD2/QZg/cwWYP2NFBDxEEAUEPERQASIPAEEg5wnXcQffaSAHRSQHRSQHQQ40Ek4XAdF5mD24BZg9vyGYP3MNmD9jLZkEPfgFmQQ9+CIP4AXQ/Zg9uQQRmD2/IZg/cw2YP"
    . "2MtmQQ9+QQRmQQ9+SASD+AJ0HWYPbkkIZg9vwWYP2MNmD9zZZkEPfkAIZkEPflkIMcDDZmYuDx+EAAAAAAAPH0AAQVdBVkFVQVRVV1ZTSIPsaA8RdCRADxF8JFCLtCTgAAAA"
    . "i5wk6AAAAE2FyUWJwk2Jy0iJyEEPlMCLjCTYAAAASIO8JNAAAAAAQQ+UwUUIyA+FEQMAAEiFwA+ECAMAAEGJz0QPvsNED6/+RQ+vx01jyESJx01pyR+F61HB/x9JwfklQSn5"
    . "RYnORYnRRIuUJPAAAABBKfFFhdIPhf4CAACA+2QPhPUCAABFhckPiLYCAABIY9JMY9FMiZwkyAAAAEWJ80mJ1EiNPJUAAAAASInCTSnUSIl8JBhmD3bkScHkAkWF/w+Vw0U5"
    . "90qNNCBMi7QkyAAAAEEPncJEIdNEjVH8RInQwegCjXgB99hFjSyCidhIwecERInDRTHSQYnASInQSDnWD4IlAgAARYTAD4RaAgAARIl8JAyJXCQ4RIlcJAhEiVQkIESIRCQo"
    . "SIl0JBBIiVQkMESJTCQ8Dx+AAAAAAItcJAyLbCQISInCTYnxTIuUJNAAAABmLg8fhAAAAAAAMfZFMdtBiciD+QMPjqMAAAAPH4AAAAAA8w9vBDLzQQ9vDDHzQQ9vFDJmD97I"
    . "Zg/e0GYPdMHzQQ9vDDJIg8YQZg90ymYP28FmD3bEZkQP1/hFifhmQdHoZkGB4FVVRSnHRYn4ZkHB7wJmQYHgMzNmQYHnMzNFAcdFifhmQcHoBEUB+GZBgeAPD0WJx2ZBwe8I"
    . "RQH4ZkHB6AJBg+AHRQHDSDn+D4Vw////SQH5SQH6SAH6RYnoRYXAD4TAAAAAZg9uEmZBD24aZkEPbglmD2/CZg/eymYP3sNmD3TKZg90w2YP28FmD3bEZg/X8IPmAUEB80GD"
    . "+AF0eWYPblIEZkEPbloEZkEPbkkEZg9vwmYP3spmD97DZg90ymYPdMNmD9vBZg92xGYP1/CD5gFBAfNBg/gCdDxmQQ9uSghmD25CCGZBD25RCGYPb9lmD97QZg/e2GYPdMJm"
    . "D3TLZg/bwWYPdsRmD9fwg+YBQQHzDx9EAABJweACTQHBTQHCTAHCRCndTAHiKct0CDndD45x/v//he0PjiUEAABIg8AESDlEJBAPgzr+//9Ei3wkDItcJDhEi1wkCESLVCQg"
    . "RA+2RCQoSIt0JBBIi1QkMESLTCQ8SItEJBhBg8IBSAHCSAHGRTnKD463/f//McAPEHQkQA8QfCRQSIPEaFteX11BXEFdQV5BX8NIg8AESDnGcsKD+2N/8kWJ3kSJ3emlAwAA"
    . "RQ+2QwJFD7ZTAUiLnCTQAAAAQcHiCEHB4BBFCdBFD7YTRQnQRA+2UwFmQQ9u2EQPtkMCQcHiCGYPcNsAQcHgEEUJ0EQPthNFCdBBgcgAAAD/ZkEPbuBmD3DkAEWFyQ+IZv//"
    . "/0hj0kxjwWYPdtJJidRNKcRJweQCRYX/QQ+VwkU590qNNCBBD53ARSHCSYnARIhUJBhMjRSVAAAAAI1R/InQwegCjWgB99hEjSyCSMHlBDHSTInAZg9vzEw5xg+CfQIAAIlU"
    . "JDhMiUQkIEyJVCQoRIlMJDAPH0QAAEiJ8kgpwkjB+gKDwgGD+gN/FullAgAAkIPqBEiDwBCD+gMPjlQCAADzD28AZg9v82YPb+lmD97oZg/e8GYPdMZmD3TpZg/bxWYPdsJm"
    . "RA/XwEWFwHTC80UPvMBBwfgCSWPQSI0EkIB8JBgARIn3D4TJAQAARIl8JAhIicJNidlEiftEiXQkDEyLlCTQAAAASIl0JBAPH0AARTH2MfZBiciD+QMPjqQAAAAPH4AAAAAA"
    . "80IPbwQy80MPbywx80MPbzQyZg/e6GYP3vBmD3TF80MPbywySYPGEGYPdO5mD9vFZg92wmZED9f4RYn4ZkHR6GZBgeBVVUUpx0WJ+GZBwe8CZkGB4DMzZkGB5zMzRQHHRYn4"
    . "ZkHB6ARFAfhmQYHgDw9FicdmQcHvCEUB+GZBwegCQYPgB0QBxkk57g+Fb////0kB6UkB6kgB6kWJ6EWFwA+ExwAAAGYPbjJmQQ9uOmZBD24pZg9vxmYP3u5mD97HZg907mYP"
    . "dMdmD9vFZg92wmZED9fwQYPmAUQB9kGD+AF0fmYPbnIEZkEPbnoEZkEPbmkEZg9vxmYP3u5mD97HZg907mYPdMdmD9vFZg92wmZED9fwQYPmAUQB9kGD+AJ0P2ZBD25qCGYP"
    . "bkIIZkEPbnEIZg9v/WYP3vBmD974Zg90xmYPdO9mD9vFZg92wmZED9fwQYPmAUQB9mYPH0QAAEnB4AJMAcJNAcFNAcIp90wB4inLdAg53w+Oav7//0SLfCQIRIt0JAxIi3Qk"
    . "EIX/D46mAAAASIPABEg5xg+Drv3//4tUJDhMi0QkIEyLVCQoRItMJDCDwgFNAdBMAdZEOcoPjmH9///pcvz//4XSdNJMjQSQDx9AAGYPbgBmD2/zZg9v6WYP3uhmD97wZg90"
    . "xmYPdOlmD9vFZg92wmYP19CD4gEPha39//9Ig8AETDnAdcbrjkSLdCQISIO8JPgAAAAAD4QY/P//SIucJPgAAABBKe5EiTPpBfz//0iDvCT4AAAAAA+E9vv//0iLnCT4AAAA"
    . "RInyKfqJE+ni+///Zi4PH4QAAAAAAEFVQVRVV1ZTSIHsqAAAAEiLtCQAAQAATIucJAgBAACLrCQQAQAARIusJBgBAABIhfZIi5wkMAEAAA+UwE2F20mJyg+UwUmJ1IuUJCAB"
    . "AAAIyA+FEQEAAE2F5A+ECAEAADHASI18JCC5DAAAAPNIq4uEJCgBAACJbCRgiFQkaIXARIlEJEhMjUQkIA+VwID6ZA++0kyJVCQ4D5TBQQ+v7UyJZCRACchEiUwkTEyJ0Q+2"
    . "wEiJdCRQD6/ViUQkbEyJXCRYRIlsJGRIY8LB+h+JbCRwSGnAH4XrUUjB+CUp0A+2VgGJRCR0D7ZGAsHiCMHgEAnQD7YWCdBBD7ZTAWYPbshBD7ZDAsHiCGYPcMEAweAQDxGE"
    . "JIAAAAAJ0EEPthMJ0EiNFVnu//8NAAAA/2YPbtBmD3DCAA8RhCSQAAAAQf+S0AAAAEiF23QGi0QkMIkDSItEJChIgcSoAAAAW15fXUFcQV3DDx9AADHASIHEqAAAAFteX11B"
    . "XEFdw2YPH0QAAEFVQVRVV1ZTSIPsKEyLlCSAAAAAi7QkoAAAAIu8JKgAAABIhckPhPUAAABNhdIPhOwAAACLhCSQAAAARTHbRAnAC4QkiAAAAAnQD4i3AAAAhfYPjsgAAACF"
    . "/w+OwAAAAEUPr8FIY9JNY8lMY6QkmAAAAEqNHI0AAAAAMe1JweQCSWPASAHQSGOUJIgAAABMjRyBi4QkkAAAAA+vhCSYAAAASJhIAdCNVvxNjRSCidDB6AJEjUgB99hJweEE"
    . "RI0sgjHAQYnwTInZTInSg/4Dfh/zQQ9vBAJBDxEEA0iDwBBJOcF17EuNFApLjQwLRYno6Kzr//+DxQFJAdtNAeI573+/QbsBAAAARInYSIPEKFteX11BXEFdw2YPH4QAAAAA"
    . "AEUx20SJ2EiDxChbXl9dQVxBXcNmZi4PH4QAAAAAAGaQSIPseEyLnCSoAAAASInISIXSD4TYAAAATYXbD4TPAAAAi4wkuAAAAEUx0kQJyQuMJLAAAABECcEPiKcAAABEi5Qk"
    . "yAAAAEWF0g+OoQAAAIuMJNAAAACFyQ+OkgAAAEiJVCQwi5QkoAAAAEiJwWYPbowkwAAAAESJRCQ4TI1EJCBmD26UJMgAAACJVCRAZg9uhCSwAAAAi5Qk0AAAAMdEJCAAAAAA"
    . "Zg9unCS4AAAAZg9iykiJRCQoiVQkYEiNFc7q//9mD2LDRIlMJDxmD2zBTIlcJEgPEUQkUP+Q0AAAAEG6AQAAAESJ0EiDxHjDDx8ARTHSRInQSIPEeMMPH0QAALgBAAAAw5CQ"
    . "kJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000780 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0008a0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000940 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000a50 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0011e0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001360 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x0014a0 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x0015a0 ; u32 get_blob_psabi_level()
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
    . "" ; 5264 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "RYXAdByLAokBQYP4AXQSi0IEiUEEQYP4AnQGi0IIiUEIw2ZmLg8fhAAAAAAADx8AVVdWU0iD7ChJicuLSUBJi0MID6/RRIuIyAAAAEGJ0InQMdJB9/Ex0onGQo0EAUH38Ulj"
    . "UzCJw0GLQzQB8EEPr0M4SJhIAdBJi1MoTI0UgkGLQxxJY1MYAfBBD69DIEiYSAHQSYtTEEyNDII53n1ekEWLQzxBg/gDflxBg+gEMdJEicDB6AKNSAFIweEEDx8A80EPbwQS"
    . "QQ8RBBFIg8IQSDnRdez32EmNFApMAcmDxgFFjQSA6Bf///9JY0M4TY0UgkljQyBNjQyBOfN1o0iDxChbXl9dw0yJ0kyJyYPGAejs/v//SWNrOEljeyBIweUCSMHnAkkB6kkB"
    . "+TnzdM9mkEWLQzxMidJMicmDxgFJAepJAfnouP7//znzf+RIg8QoW15fXcNmZi4PH4QAAAAAAEFXQVZBVUFUVVdWU0iD7EgPEXQkMDHSZg92yUiJyInRQbgBAAAA8EQPwQCL"
    . "UCwrUEREOcIPjDIFAABMY2AoRItQQEyLSCBFD6/ESWPSSSnUi1BMScHkAk1jwE+NBIFPjTQghdIPhNYCAABNOcZysUWNSvzzD29gYEGJz02J80SJyvMPb1hwweoCjWoB99pI"
    . "weUERY0skWYuDx+EAAAAAABMidpMKcJIwfoCg8IBg/oDfx7p8QEAAGYPH4QAAAAAAIPqBEmDwBCD+gMPjtgBAADzQQ9vAGYPb+xmD2/TZg/e0GYP3uhmD3TFZg9002YP28Jm"
    . "D3bBZg/XyIXJdMPzD7zJwfkCSGPRTY0EkESLSFREi3BQSItwMEiLWDhFOfEPj88BAABMicFEic9FhfYPhMABAABEiUwkCEyJRCQQDx8AMdJFMcBBg/oDD45RAQAAkPMPbwQR"
    . "8w9vFBbzD28sE2YP3tBmD97oZg90wvMPbxQTSIPCEGYPdNVmD9vCZg92wWZED9fI80UPuMlBwfkCRQHISDnVdbpIAe5IAetIAelEieqF0g+EuQAAAGYPbilmD24zZg9uFmYP"
    . "b8VmD97VZg/exmYPdNVmD3TGZg/bwmYPdsFmRA/XyEGD4QFFAciD+gF0c2YPbmkEZg9ucwRmD25WBGYPb8VmD97VZg/exmYPdNVmD3TGZg/bwmYPdsFmRA/XyEGD4QFFAciD"
    . "+gJ0N2YPblMIZg9uQQhmD25uCGYPb/JmD97oZg/e8GYPdMVmD3TWZg/bwmYPdsFmRA/XyEGD4QFFAchIweICSAHWSAHTSAHRRCnHTAHhRSnWdAlEOfcPjsn+//9Ei0wkCEyL"
    . "RCQQhf9+dUmDwARNOcMPgw7+//9Eifnphv3//2YPH0QAAESJ0un6/v//hdJ05kmNDJBmQQ9uAGYPb+xmD2/TZg/e0GYP3uhmD3TFZg9002YP28JmD3bBZg/X0IPiAQ+FKf7/"
    . "/0mDwARJOch1xUSJ+ekt/f//RInPhf9/i0SJySn5SI1QFEG6AQAAAEWJ0USGCkWEyXX1OUgQD41lAgAAiUgQTIlACESGCjtIUA+M8Pz//4tQLIcQ6eb8//9mDx9EAABNOcYP"
    . "gtIBAABEi3hQRItIVEGNcvxIi3gwifJFOflIiXwkEA+ew0iLeDhFhf9BD5XDweoCSIl8JBiNegH32kjB5wREjSyWRITbD4SyAQAAiUwkLEiJhCSQAAAADx9EAABMiUQkCEiL"
    . "XCQYTInCRIn+TItcJBBEic0PH4QAAAAAADHAMclBg/oDD46CAQAAZpDzD28EAvNBD28UA/MPbxwDZg/e0GYP3thmD3TC8w9vFANIg8AQZg9002YP28JmD3bBZkQP18DzRQ+4"
    . "wEHB+AJEAcFIOcd1uUkB+0gB+0gB+kSJ6IXAD4S8AAAAZg9uGmYPbiNmQQ9uE2YPb8NmD97TZg/exGYPdNNmD3TEZg/bwmYPdsFmRA/XwEGD4AFEAcGD+AF0dWYPbloEZg9u"
    . "YwRmQQ9uUwRmD2/DZg/e02YP3sRmD3TTZg90xGYP28JmD3bBZkQP18BBg+ABRAHBg/gCdDhmD25TCGYPbkIIZkEPblsIZg9v4mYP3thmD97gZg90w2YPdNRmD9vCZg92wWZE"
    . "D9fAQYPgAUQBwUjB4AJJAcNIAcNIAcIpzUwB4kQp1nQIOfUPjsf+//9Mi0QkCIXtflZJg8AETTnGD4OR/v//i0wkLEiLhCSQAAAASIN8JCAAD4T5+v//TItEJCDpzv3//w8f"
    . "gAAAAABJg8AETTnGctpFhcl/8kSJzesVDx9EAABEidDpy/7//0iLhCSQAAAARInJTIlEJCAp6euvDxB0JDBIg8RIW15fXUFcQV1BXkFfw0SGCjlIUA+Pkvr//+md/f//ZmYu"
    . "Dx+EAAAAAABmkFdWU4tcJEhEichIY/JIY1QkQEWJyA+2xEHB6BBBicKLRCRYD6/GSJhIAdBMjRyBi0QkUA+vxkiYSAHQSI0UgUw52nNsRQ+2wEUPttJFD7bJg/4BdBTraWYP"
    . "H4QAAAAAAEiDwgRMOdpzRw+2SgFEKdGJyPfYD0jBD7ZKAkQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteX8NmLg8fhAAAAAAAuAEAAABbXl/DDx+A"
    . "AAAAAEjB5gLrEmYuDx+EAAAAAABIAfJMOdpz2A+2SgJEKcGJyPfYD0jBD7ZKAUQp0YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9MwTnDfcExwOuPZmYuDx+EAAAAAABm"
    . "kFZTD69UJDiLXCRASGPSSInOSGNMJFBEichFicoPtsRBweoQSAHRTI0cjkhjTCRISAHKSI0Ulkw52nNdRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPCBEw52nM/D7ZKAkQp0YnI"
    . "99gPSMEPtkoBRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW17DDx8AuAEAAABbXsNEi1QkKE2FwInQD5TCTYXJQQ+Uw0QI2g+F4QAAAEiFyQ+E2AAA"
    . "AEUPttJBadIAAQEARAnSgcoAAAD/Zg9u4mYPcNwAg/gDflREjVj8Zg9vyzHARYnaQcHqAkGNUgFIweIEDx+AAAAAAPMPbwQBZg9v0GYP3MFmD9jRQQ8RBAFBDxEUAEiDwBBI"
    . "OcJ13EH32kgB0UkB0UkB0EONBJOFwHReZg9uAWYPb8hmD9zDZg/Yy2ZBD34BZkEPfgiD+AF0P2YPbkEEZg9vyGYP3MNmD9jLZkEPfkEEZkEPfkgEg/gCdB1mD25JCGYPb8Fm"
    . "D9jDZg/c2WZBD35ACGZBD35ZCDHAw2ZmLg8fhAAAAAAADx9AAEFXQVZBVUFUVVdWU0iD7FgPEXQkMA8RfCRAi7Qk0AAAAIucJNgAAABNhclNic9IY8JEicJBD5TBRIuEJMgA"
    . "AABIg7wkwAAAAABBD5TCRQjRD4WXAgAASIXJD4SOAgAARYnGRA++yynyRA+v9kWJykUPr9ZNY9pFidFNadsfhetRQcH5H0nB+yVFKctBidGLlCTgAAAAhdIPhYYCAACA+2QP"
    . "hH0CAABFhckPiD4CAABJY9BJicRmD3bkSSnUScHkAkWF9g+Vw0U53g+dwkjB4AIh00iJRCQISInIid5KjRwhQY1I/InKweoCjXoB99pEjSyRRInKSMHnBEGJ8THJRInWQYnS"
    . "SInCSDnDD4LGAQAARYTJD4T9AQAARIl0JBCJdCQURIkcJIlMJChEiEwkGEiJRCQgRIlUJCwPH4AAAAAAi3QkEIssJEiJ0U2J+UyLlCTAAAAADx8AMcBFMdtBg/gDD47JBAAA"
    . "Zg8fhAAAAAAA8w9vBAHzQQ9vDAHzQQ9vFAJmD97IZg/e0GYPdMHzQQ9vDAJIg8AQZg90ymYP28FmD3bEZkQP1/DzRQ+49kHB/gJFAfNIOfh1t0kB+UkB+kgB+USJ6IXAD4TA"
    . "AAAAZg9uEWZBD24aZkEPbglmD2/CZg/eymYP3sNmD3TKZg90w2YP28FmD3bEZkQP1/BBg+YBRQHzg/gBdHhmD25RBGZBD25aBGZBD25JBGYPb8JmD97KZg/ew2YPdMpmD3TD"
    . "Zg/bwWYPdsRmRA/X8EGD5gFFAfOD+AJ0OmZBD25KCGYPbkEIZkEPblEIZg9v2WYP3tBmD97YZg90wmYPdMtmD9vBZg92xGZED9fwQYPmAUUB85BIweACSQHBSQHCSAHBRCnd"
    . "TAHhRCnGdAg59Q+OuP7//4XtD475AwAASIPCBEg50w+Di/7//0SLdCQQi3QkFESLHCSLTCQoRA+2TCQYSItEJCBEi1QkLEiLVCQIg8EBSAHQSAHTRDnRD44X/v//MdIPEHQk"
    . "MA8QfCRASInQSIPEWFteX11BXEFdQV5BX8NIg8IESDnTcsCD/mN/8kSJ3emCAwAAQQ+2VwJFD7ZXAUiLnCTAAAAAQcHiCMHiEEQJ0kUPthdECdJED7ZTAWYPbtpIi5QkwAAA"
    . "AEHB4ghmD3DbAA+2UgLB4hBECdJED7YTRAnSgcoAAAD/Zg9u4mYPcOQARYXJD4hk////SWPQSInFRIl0JBRmD3bSSCnVRInbSMHlAkWF9kEPlcJFOd5MjSwpD53CQSHSQY1Q"
    . "/ESIVCQsTI0UhQAAAACJ0MHoAo14AffYRI0kgkjB5wQxwGYPb8xJOc0Pgi4CAACJRCQoRA+2XCQsRInKSIlMJBhMiVQkIEiJDCQPH0QAAEyLDCRMiehMKchIwfgCg8ABg/gD"
    . "fxrpKQIAAA8fRAAAg+gESYPBEIP4Aw+OEAIAAPNBD28BZg9v82YPb+lmD97oZg/e8GYPdMZmD3TpZg/bxWYPdsJmD9fIhcl0w/MPvMnB+QJIY8FJjQSBSIkEJIneRYTbD4Rp"
    . "AQAASIsMJESLdCQUiVwkEE2J+USIXCQITIuUJMAAAACQMcBFMdtBg/gDD46RAQAAkPMPbwQB80EPbywB80EPbzQCZg/e6GYP3vBmD3TF80EPbywCSIPAEGYPdO5mD9vFZg92"
    . "wmYP19jzD7jbwfsCQQHbSDn4dbpJAflJAfpIAflEieCFwA+EwwAAAGYPbjFmQQ9uOmZBD24pZg9vxmYP3u5mD97HZg907mYPdMdmD9vFZg92wmYP19iD4wFBAduD+AF0fWYP"
    . "bnEEZkEPbnoEZkEPbmkEZg9vxmYP3u5mD97HZg907mYPdMdmD9vFZg92wmYP19iD4wFBAduD+AJ0QWZBD25qCGYPbkEIZkEPbnEIZg9v/WYP3vBmD974Zg90xmYPdO9mD9vF"
    . "Zg92wmYP19iD4wFBAdtmLg8fhAAAAAAASMHgAkgBwUkBwUkBwkQp3kgB6UUpxnQJRDn2D46//v//i1wkEEQPtlwkCIX2D47UAAAASIMEJARIiwQkSTnFD4MD/v//i0QkKEiL"
    . "TCQYQYnRTItUJCCDwAFMAdFNAdVEOcgPjrP9///pwPz//w8fAESJwOmN+///Dx+EAAAAAABEicDpuv7//0yJDCSFwHS1SIs0JEiNDIZIifDrDA8fAEiDwARIOch0nGYPbgBm"
    . "D2/zZg9v6WYP3uhmD97wZg90xmYPdOlmD9vFZg92wmZED9fIQYPhAXTISIkEJOnW/f//RIscJEiDvCToAAAAAA+EO/z//0iLhCToAAAAQSnrRIkY6Sj8//9Ig7wk6AAAAABI"
    . "ixQkQYnbD4QS/P//SIuEJOgAAABBKfNEiRjp//v//0FVQVRVV1ZTSIHsqAAAAEiLtCQAAQAATIucJAgBAACLrCQQAQAARIusJBgBAABIhfZIi5wkMAEAAA+UwE2F20mJyg+U"
    . "wUmJ1IuUJCABAAAIyA+FEQEAAE2F5A+ECAEAADHASI18JCC5DAAAAPNIq4uEJCgBAACJbCRgiFQkaIXARIlEJEhMjUQkIA+VwID6ZA++0kyJVCQ4D5TBQQ+v7UyJZCRACchE"
    . "iUwkTEyJ0Q+2wEiJdCRQD6/ViUQkbEyJXCRYRIlsJGRIY8LB+h+JbCRwSGnAH4XrUUjB+CUp0A+2VgGJRCR0D7ZGAsHiCMHgEAnQD7YWCdBBD7ZTAWYPbshBD7ZDAsHiCGYP"
    . "cMEAweAQDxGEJIAAAAAJ0EEPthMJ0EiNFXnv//8NAAAA/2YPbtBmD3DCAA8RhCSQAAAAQf+S0AAAAEiF23QGi0QkMIkDSItEJChIgcSoAAAAW15fXUFcQV3DDx9AADHASIHE"
    . "qAAAAFteX11BXEFdw2YPH0QAAEFVQVRVV1ZTSIPsKEyLlCSAAAAAi7QkoAAAAIu8JKgAAABIhckPhPUAAABNhdIPhOwAAACLhCSQAAAARTHbRAnAC4QkiAAAAAnQD4i3AAAA"
    . "hfYPjsgAAACF/w+OwAAAAEUPr8FIY9JNY8lMY6QkmAAAAEqNHI0AAAAAMe1JweQCSWPASAHQSGOUJIgAAABMjRyBi4QkkAAAAA+vhCSYAAAASJhIAdCNVvxNjRSCidDB6AJE"
    . "jUgB99hJweEERI0sgjHAQYnwTInZTInSg/4Dfh/zQQ9vBAJBDxEEA0iDwBBJOcF17EuNFApLjQwLRYno6Mzs//+DxQFJAdtNAeI573+/QbsBAAAARInYSIPEKFteX11BXEFd"
    . "w2YPH4QAAAAAAEUx20SJ2EiDxChbXl9dQVxBXcNmZi4PH4QAAAAAAGaQSIPseEyLnCSoAAAASInISIXSD4TYAAAATYXbD4TPAAAAi4wkuAAAAEUx0kQJyQuMJLAAAABECcEP"
    . "iKMAAABEi5QkyAAAAEWF0g+OoQAAAIuMJNAAAACFyQ+OkgAAAEiJVCQwi5QkoAAAAEiJwWYPbowkwAAAAESJRCQ4TI1EJCBmDzoijCTIAAAAAYlUJEBmD26EJLAAAACLlCTQ"
    . "AAAASIlEJChmDzoihCS4AAAAAcdEJCAAAAAAiVQkYEiNFe7r//9mD2zBRIlMJDxMiVwkSA8RRCRQ/5DQAAAAQboBAAAARInQSIPEeMMPH4AAAAAARTHSRInQSIPEeMMPH0QA"
    . "ALgCAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000700 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000820 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x0008c0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x0009d0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0010c0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001240 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x001380 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x001480 ; u32 get_blob_psabi_level()
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
    . "" ; 6000 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "RYXAdByLAokBQYP4AXQSi0IEiUEEQYP4AnQGi0IIiUEIw2ZmLg8fhAAAAAAADx8AVlNIg+woSYnLi0lASYtDCA+v0USLiMgAAABBidCJ0DHSQffxMdKJw0KNBAFB9/FJY1Mw"
    . "icZBi0M0AdhBD69DOEiYSAHQSYtTKEyNFIJBi0McSWNTGAHYQQ+vQyBImEgB0EmLUxBMjQyCOfN9fA8fAEWLQzxBg/gHfnZBg+gIMdJEicDB6AONSAFIweEFDx8AxMF+bwQS"
    . "xMF+fwQRSIPCIEg50XXr99hJjRQKTAHJRY0EwEGD+AN+FcX6bwpIg8EQSIPCEEGD6ATF+n9J8Oj+/v//SWNDOIPDAU2NFIJJY0MgTY0MgTnedYdIg8QoW17DTInJTInS67oP"
    . "H4QAAAAAAEFXQVZBVUFUVVdWU0iB7OgAAADF+BG0JJAAAADF+BG8JKAAAADFeBGEJLAAAADFeBGMJMAAAADFeBGUJNAAAADF5XbbxfF2yUiNVCRfx0QkLAAAAABIichIg+Lg"
    . "SIlUJDi5AQAAAPAPwQiLUCwrUEQ5yg+MJgYAAEhjeCiLWEBMi0AgD6/PSGPTSCnXi1BMSMHnAkhjyU2NDIhJjTQ5SIl0JBCF0g+EnQMAAEw5znKxjUv4xfpvcGDF+m9gcInK"
    . "xfpvkIAAAABMi3QkOMHqA8V6b4CQAAAARI1qAffaRI080UnB5QVIifFIicYPH0QAAEiJyMTBen8WTCnIxEF6f0YQxMF+by5IwfgCxMF6f3Ygg8ABxMF6f2Ywg/gHD441AgAA"
    . "xMF+b34g6xZmDx9EAACD6AhJg8Egg/gHD44XAgAAxMF+bwHFVd7IxUXe0MWtdMDFNXTNxbXbwMX9dsPF/dfQhdJ0y/MPvNKD4jxJAdFEi15QTItWMEyLRjiLblRFhdsPhGgC"
    . "AABMicpBiexEOd0Pj1kCAACJbCQITIlMJBBIiUwkGA8fQAAxwDHtg/sHD46bAQAADx8Axf5vBALEwX3eLADEwX3ePALEwVV0LABIg8Agxf10x8X928XF/XbDxf3XyPMPuMnB"
    . "+QIBzUk5xXXHTQHqTQHoTAHqRIn4g/gDD446AQAAxfpvAsTBed4oSYPCEIPoBMTBed568EmDwBBIg8IQxMFRdGjwxfl0x8X528XF+XbBxfnXyPMPuMnB+QKFwA+EsAAAAMX5"
    . "bjrEQXluCMTBeW4qxcHe7cWx3sfFsXTAxdF078X528XF+XbBxXnXyEGD4QFEAcmD+AF0bcX5bnoExEF5bkgExMF5bmoExcHe7cWx3sfFsXTAxdF078X528XF+XbBxXnXyEGD"
    . "4QFEAcmD+AJ0NMX5bkIIxMF5bmgIxMF5bnoIxVHeyMX53v/F+XTHxbF07cX528XF+XbBxXnXyEGD4QFEAclIweACSQHCSQHASAHCAelIAfpBKcxBKdt0CUU53A+Omf7//4ts"
    . "JAhMi0wkEEiLTCQYRYXkD47VAAAASYPBBEw5yQ+Dvf3//0iJ8Okm/f//Dx9EAAAxyen6/v//Zg8fhAAAAAAAidjppv7//8TBem9+IMTBem8ug/gDfi3EwXpvAcVR3sjFed7X"
    . "xal0wMRBUXTJxbHbwMX5dsHF+dfQhdJ1TUmDwRCD6ASFwHSbSY0UgQ8fQADEwXluAcVR3sjFQd7Qxal0wMUxdM3FsdvAxfl2wcX518CoAQ+Fpv3//0mDwQRJOdF1zkiJ8OmH"
    . "/P//ZvMPvMJmwegCD7fATY0MgemA/f//QYnsRYXkD48r////QYnrSInwRSnjRIlcJCxIjVAUQbgBAAAARInBhgqEyXX3i3wkLDl4EA+NuQIAAIl4EEyJSAiGCjt4UA+MJvz/"
    . "/4tQLIcQ6Rz8//8PHwBMOUwkEA+C9gEAAESLQFBEi2hURI1b+EiLcDBEidpFOcVBD57CRYXASIl0JBhIi3A4D5XBweoDjWoB99pIiXQkIEjB5QVFjTzTQYTKD4TRAQAASImE"
    . "JDABAABmDx9EAABMiUwkCEyLXCQgTInKRInGTItUJBhFiewxwEUxyYP7Bw+OsgEAAGaQxf5vBALEwX3eFAPEwX3eJALEwW10FANIg8Agxf10xMX928LF/XbDxf3XyPMPuMnB"
    . "+QJBAclIOcV1xkkB6kkB60gB6kSJ+IP4Aw+OWQEAAMX6bwLEwXneE0mDwhCD6ATEwXneYvBJg8MQSIPCEMTBaXRT8MX5dMTF+dvCxfl2wcX518jzD7jJwfkChcAPhLAAAADF"
    . "+W4ixMF5bivEwXluEsXZ3tLF2d7Fxfl0xcXpdNTF+dvCxfl2wcV51/BBg+YBRAHxg/gBdG3F+W5iBMTBeW5rBMTBeW5SBMXZ3tLF2d7Fxfl0xcXpdNTF+dvCxfl2wcV51/BB"
    . "g+YBRAHxg/gCdDTF+W5CCMTBeW5TCMTBeW5iCMXp3ujF+d7kxfl0xMXpdNXF+dvCxfl2wcV51/BBg+YBRAHxSMHgAkkBw0kBwkgBwkQByUgB+kEpzCnedAlBOfQPjpj+//9M"
    . "i0wkCEWF5H5VSYPBBEw5TCQQD4Nn/v//SIuEJDABAABIg3wkMAAPhAz6//9Mi0wkMOmq/f//kEmDwQRMOUwkEHLeRYXtf/BFiezrGg8fADHJ6dv+//+Qidjpj/7//0iLhCQw"
    . "AQAARSnlTIlMJDBEiWwkLOurxfh3xfgQtCSQAAAAxfgQvCSgAAAAxXgQhCSwAAAAxXgQjCTAAAAAxXgQlCTQAAAASIHE6AAAAFteX11BXEFdQV5BX8OGCot8JCw5eFAPj3D5"
    . "///pRf3//2YuDx+EAAAAAABXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+"
    . "AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAA"
    . "W15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5w33BMcDrj2ZmLg8f"
    . "hAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+2"
    . "SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteww8fALgBAAAAW17DRItUJChNhcCJ0A+Uwk2FyUEPlMNECNoPhQYBAABI"
    . "hckPhP0AAABFD7bSQWnSAAEBAEQJ0oHKAAAA/8X5btLE4n1Y0oP4B35SRI1Y+MX9b8oxwEWJ2kHB6gNBjVIBSMHiBQ8fgAAAAADF/m8cAcXl2MHEwX5/BADF9dzDxMF+fwQB"
    . "SIPAIEg5wnXeQffaSAHRSQHRSQHQQ40E08X5b8KD+AN+J8X6byFJg8EQSIPBEEmDwBCD6ATF2djKxMF6f0jwxenczMTBen9J8IXAdGLF+W4JxfHY0MX53MnEwXl+EMTBeX4J"
    . "g/gBdEfF+W5JBMXx2NDF+dzJxMF5flAExMF5fkkEg/gCdCnF+W5RCMXp2MjF+dzCxMF5fkgIxMF5fkEIxfh3McDDZi4PH4QAAAAAAMX4dzHAw2YuDx+EAAAAAABBV0FWQVVB"
    . "VFVXVlNIgezIAAAAxfgRdCRAxfgRfCRQxXgRRCRgxXgRTCRwxXgRlCSAAAAAxXgRnCSQAAAAxXgRpCSgAAAAxXgRrCSwAAAAi5wkQAEAAESLnCRIAQAATImMJCgBAABIichI"
    . "g7wkKAEAAABIY8pBD5TCRIuMJDgBAABEicJIg7wkMAEAAABAD5TGQQjyD4XWAgAASIXAD4TNAgAARYnIRQ++0ynaRA+vw4ucJFABAABFD6/QTWPiRInWTWnkH4XrUcH+H0nB"
    . "/CVBKfSF2w+FEgMAAEGA+2QPhAgDAACF0g+IhAIAAE1j2UmJzkSJVCQ4xeV2200p3sXpdtJJweYCRYXAD5XDRTngSo0sMEEPncNEIdtFjVn4QYndSI0cjQAAAABEidnB6QNF"
    . "iepFicVMi4QkMAEAAI1xAffZRY08y4nRSMHmBUiJ2kUx24nLSInBSDnFD4L6AQAARYTSD4RlAgAARIhUJBhEiWwkDESJZCQIRIlcJCBIiUQkKEiJVCQwSIlsJBCJXCQ8i2wk"
    . "DIt8JAhIicpMicNMi5wkKAEAAGYuDx+EAAAAAAAxwEUx5EGD+QcPjpEFAACQxf5vBALF/d4MA8TBfd4kA8X1dAwDSIPAIMX9dMTF/dvBxf12w8V919DzRQ+40kHB+gJFAdRI"
    . "OcZ1xkkB80gB80gB8kSJ+IP4Aw+OMQUAAMX6bwLF+d4Lg+gESYPDEMTBed5j8EiDwxBIg8IQxfF0S/DF+XTExfnbwcX5dsLFedfQ80UPuNJBwfoChcAPhLMAAADF+W4ixflu"
    . "K8TBeW4LxdneycXZ3sXF+XTFxfF0zMX528HF+XbCxXnX6EGD5QFFAeqD+AF0ccX5bmIExfluawTEwXluSwTF2d7JxdnexcX5dMXF8XTMxfnbwcXpdsDFedfoQYPlAUUB6oP4"
    . "AnQ5xfluQgjF+W5LCMTBeW5jCMXx3ujF+d7kxfl0xMXxdM3F+dvBxel2wMV51+hBg+UBRQHqZg8fRAAASMHgAkkBw0gBw0gBwkUB4kwB8kQp10QpzXQIOe8PjpX+//+F/w+O"
    . "4AQAAEiDwQRIOUwkEA+DXv7//0QPtlQkGESLbCQMRItkJAhEi1wkIEiLRCQoSItUJDBIi2wkEItcJDxBg8MBSAHQSAHVQTnbD47n/f//xfh3McnF+BB0JEDF+BB8JFBIicjF"
    . "eBBEJGDFeBBMJHDFeBCUJIAAAADFeBCcJJAAAADFeBCkJKAAAADFeBCsJLAAAABIgcTIAAAAW15fXUFcQV1BXkFfw0iDwQRIOc1yjIN8JDhjf/BIg7wkWAEAAABEiecPhTAE"
    . "AADF+HfrhkiLtCQoAQAARA+2VgJED7ZeAUHB4hBBweMIRQnaRA+2HkiLtCQwAQAARQnaRA+2XgHEQXlu0kQPtlYCQcHjCMRCfVjSQcHiEEUJ2kQPth5FCdpBgcoAAAD/xEF5"
    . "bsrEQn1YyYXSD4gW////TWPRxXl/1sV5f8xJic3EQXlvwsXpdtLF5XbbTSnVScHlAkWFwEEPlcNFOeBKjSwoQQ+dwkWJ30WNWfhFIddMjRSNAAAAAESJ2cHpA415AffZRY00"
    . "y0jB5wVFMdvF+W/8xX1/1cV9f8lIicFIOcUPglgCAABEiVwkOEiJRCQYTIlUJCCJVCQoZpBIiehIKchIwfgCg8ABg/gHfx7pgQIAAGYPH4QAAAAAAIPoCEiDwSCD+AcPjmgC"
    . "AADF/m8BxXXe2MVV3uDFnXTAxSV02cWl28DF/XbDxf3X0IXSdMzzD7zSg+I8SAHRRInmRYT/D4SxAQAARIlEJAhIicpEicNMi5wkMAEAAESJZCQMTIuUJCgBAABEiHwkEJAx"
    . "wEUx/0GD+QcPjvEBAACQxf5vBALEQX3eHAPEQX3eJALEQSV0HANIg8AgxZ10wMWl28DF/XbDxX3XwPNFD7jAQcH4AkUBx0g5+HXESQH6SQH7SAH6RInwg/gDD46PAQAAxfpv"
    . "AsRBed4bg+gESYPCEMRBed5i8EmDwxBIg8IQxEEhdFvwxZl0wMWh28DF+XbCxXnXwPNFD7jAQcH4AoXAD4S/AAAAxXluIsRBeW4rxEF5bhrEQRne28TBGd7FxZF0wMRBIXTc"
    . "xaHbwMX5dsLFedfgQYPkAUUB4IP4AXR5xXluYgTEQXluawTEQXluWgTEQRne28TBGd7FxZF0wMRBIXTcxaHbwMXpdsDFedfgQYPkAUUB4IP4AnQ9xfluQgjEQXluWwjEQXlu"
    . "YgjFId7oxEF53uTFmXTAxEEhdN3FodvAxel2wMV51+BBg+QBRQHgDx+AAAAAAEjB4AJJAcJJAcNIAcJFAfhMAepEKcZEKct0CDneD46F/v//RItEJAhEi2QkDEQPtnwkEIX2"
    . "D44qAQAASIPBBEg5zQ+D0P3//0SLXCQ4SItEJBhMi1QkIItUJChBg8MBTAHQTAHVQTnTD459/f//xfh36TL8//9mkEUx0ukC+///Dx+EAAAAAABEicjprvr//w8fhAAAAAAA"
    . "RTHA6ab+//8PH4QAAAAAAESJyOlQ/v//g/gDfizF+m8BxVne2MV53ubFmXTAxEFZdNvFodvAxfl2wsX519CF0nVMSIPBEIPoBIXAD4Rf////SI0UgQ8fAMX5bgHFQd7YxTne"
    . "4MWZdMDFIXTfxaHbwMX5dsLF+dfAqAEPhV79//9Ig8EESDnRdc/pIv///2bzD7zCZsHoAg+3wEiNDIHpO/3//0iDvCRYAQAAAESLZCQID4TQ+///SIuEJFgBAABBKfxEiSDF"
    . "+HfpRfv//0iDvCRYAQAAAA+Eq/v//0iLhCRYAQAAQSn0RIkgxfh36SD7//9mZi4PH4QAAAAAAA8fAEFWQVVBVFVXVlNIgezQAAAASIusJDABAABMi5wkOAEAAESLpCRAAQAA"
    . "RIu0JEgBAABIi7QkYAEAAEiNXCQ/SYnKSYnVi5QkUAEAAEiD4+BIhe0PlMBNhdsPlMEIyA+FBQEAAE2F7Q+E/AAAADHAuQwAAABIid/zSKuLhCRYAQAARIljQIhTSIXATIlT"
    . "GA+VwID6ZA++0kSJQygPlMFFD6/mRIlLLEmJ2AnITIlbOEyJ0Q+2wEyJayBBD6/UiUNMSIlrMESJc0RIY8LB+h9EiWNQSGnAH4XrUUjB+CUp0A+2VQGJQ1QPtkUCweIIweAQ"
    . "CdAPtlUACdBBD7ZTAcX5bsBBD7ZDAsHiCMTifVjAweAQxf5/Q2AJ0EEPthMJ0EiNFXzs//8NAAAA/8X5bsDE4n1YwMX+f4OAAAAAxfh3Qf+S0AAAAEiF9nQFi0MQiQZIi0MI"
    . "SIHE0AAAAFteX11BXEFdQV7DDx9AADHA6+YPH0AAQVVBVFVXVlNIg+woTIuUJIAAAACLvCSgAAAAi6wkqAAAAEiFyQ+EHQEAAE2F0g+EFAEAAIuEJJAAAABFMdtECcALhCSI"
    . "AAAACdAPiOUAAACF/w+O8AAAAIXtD47oAAAARQ+vwUhj0k1jyUUx7UhjtCSYAAAASo0cjQAAAABJY8BIweYCSAHQSGOUJIgAAABMjRyBi4QkkAAAAA+vhCSYAAAASJhIAdCN"
    . "V/hNjRSCidDB6ANEjUgB99hJweEFRI0kwg8fgAAAAAAxwEGJ+EyJ2UyJ0oP/B34oDx+EAAAAAADEwX5vBALEwX5/BANIg8AgSTnBdetLjRQKS40MC0WJ4EGD+AN+FcX6bwpI"
    . "g8EQSIPCEEGD6ATF+n9J8Ojg6f//QYPFAUkB20kB8kQ57X+ZQbsBAAAARInYSIPEKFteX11BXEFdww8fAEUx20SJ2EiDxChbXl9dQVxBXcMPH0QAAEiD7HhMi5wkqAAAAEiJ"
    . "yEiF0g+E2AAAAE2F2w+EzwAAAIuMJLgAAABFMdJECckLjCSwAAAARAnBD4ikAAAARIuUJMgAAABFhdIPjqEAAACLjCTQAAAAhckPjpIAAABIiVQkMIuUJKAAAABIicHF+W6U"
    . "JMAAAABEiUQkOEyNRCQgxONpIowkyAAAAAGJVCRAxflunCSwAAAAi5Qk0AAAAEiJRCQoxONhIoQkuAAAAAHHRCQgAAAAAIlUJGBIjRUO6f//xflswUSJTCQ8TIlcJEjF+n9E"
    . "JFD/kNAAAABBugEAAABEidBIg8R4w2YPH0QAAEUx0kSJ0EiDxHjDDx9EAAC4AwAAAMOQkJCQkJCQkJCQ"
    mcode_imgutil_column_uniform := 0x000830 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000950 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x0009f0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000b30 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x001390 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001500 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x001660 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x001760 ; u32 get_blob_psabi_level()
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
    . "" ; 5296 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VVdWU0SLQUBIi0EIRIuQyAAAAEEPr9BBidGJ0DHSQffyMdKJw0ONBAhMY0EwQffyi1E0AdoPr1E4SGPSTAHCTItBKE2NDJCLURxMY0EYAdoPr1EgSGPSTAHCTItBEE2NFJA5"
    . "ww+NgwAAAL4BAAAAkItRPIP6Dw+OnwAAAESNWvAx0kSJ38HvBESNRwFJweAGYtH+SG8MEWLR/kh/DBJIg8JASTnQdenB5wREidpLjSwBTQHQKfqF0nQ+xOJp99aNev+DwwHF"
    . "+JLPYvF+yW9FAGLRfkl/AEhjUThNjQyRSGNRIE2NFJI5w3WGxfh3W15fXcNmDx9EAABIY1E4g8MBTY0MkUhjUSBNjRSSOdh024tRPIP6Dw+PYf///02J0EyJzeuTZmYuDx+E"
    . "AAAAAABmkEFXQVZBVUFUVVdWU0iD7EhFMcli831IJcD/Qb8BAAAASYnNuAEAAADwQQ/BRQBBi1VMQStVZDnCD4wcBgAAQYt9SEmLVUBJY01gD6/HiXwkPEiYTI0cgkhjx0iJ"
    . "ykgpyEGLTWxJjQSDSIlEJBCFyQ+EdQMAAEw52HKpRI1i8CnXSIlcJChi0f5Ib20CRIngRIlMJDBIY+9i0f5Ib2UDwegEQYPkD0jB5QKJRCQ4Dx8ASItEJBBMKdhIwfgCg8AB"
    . "g/gPD462AgAAYvH9SG/dYvH9SG/U6xpmLg8fhAAAAAAAg+gQSYPDQIP4Dw+OjgIAAGLRf0hvC2LzdUg+ywVi83VJPsoCYvJ+SCjJYvN1SB/AAMX4mMB0ycX4k8Bm8w+8wA+3"
    . "wEmNNINBi0V0RYtNcE2LVVBJi11YiUQkHEGJw0WFyQ+EEAIAAEQ5yA+PBwIAAItEJDhIifFIifdEjXABTIl0JAiD+g8PjnQCAABIi3QkCEUxwDHASMHmBmYPH0QAAGKxf0hv"
    . "FAFik21IPgwCBWKzbUk+DAMCSYPAQGLyfkgoyWLzdUgf+ADFeJP380UPuPZEAfBJOfB1x00BwkwBw0wBwU1jxEWFwA+FGgEAAESLdCQ8QSnDRInISIn+KdBBKdZNY/ZJweYC"
    . "TAHxRDnYD4xjAQAAhcAPhFsBAACLfCQ4SIl0JAhIiWwkIESNTwFJweEGZg8fRAAAg/oPD45fBAAAMfZFMcBmLg8fhAAAAAAAYvF/SG8UMWLTbUg+DDIFYvNtST4MMwJIg8ZA"
    . "YvJ+SCjJYvN1SB/4AMX4k//zD7j/QQH4TDnOdchNAcpMActMAclFKcMp0EwB8UQ52HwEhcB1lkiLdCQISItsJCBFhdsPj8sAAACLfCQcSItcJChIifFEKd9BiflJjUUUQbgB"
    . "AAAARInChhCE0nX3RTlNEA+NqgMAAEWJTRBJiU0IhhBFO01wD4xL/f//QYtFTEGHRQDpPv3//w8fAMTCOff3g+4BScHgAsX7ks5i8X7Jbwli0X7JbxpNAcJi8X7JbxNMAcNJ"
    . "Aehi83VIPtMFTAHBYvN1Sj7SAmLyfkgoymLzdUgfwADF/EHhxfiT9GbzD7j2D7f2AcZBKfNBKdF0CUU5yw+OD/7//0iJ/kWF2w+ONf///0yNXgRMOVwkEA+DQf3//0iLXCQo"
    . "RItMJDDppfz//4XAdO3Ewnn3x4PoAcX4kshi0X7Jbwti83VIPtUFYvN1Sj7EAmLyfkgoyGLzdUkfyADF+JjJdLrF+JPBZvMPvMAPt8BJjTSDSIX2D4VZ/f//SItcJChEi0wk"
    . "MOlG/P//Dx8ATGPCMcDp2/3//0w5XCQQD4KjAQAASYtFUIn9jUrwQYt9dEWLdXAp1UiJXCQwxMH5buVIiUQkIEmLRVhIY+1EiUwkPEjB5QJFifVIiUQkKInIg+EPwegEiXwk"
    . "OIlEJByJyEyJ2UGJw2YPH4QAAAAAAIt8JDhIi1wkIESJ6EiLdCQoQYn6RYXtD4QEAQAARDnvD4/7AAAAi3wkHEmJyUSNdwFMiXQkCIP6Dw+OoQEAAJBMi3QkCDH/RTHAScHm"
    . "BmaQYtF/SG8sOWLzVUg+DDsFYvNVST4MPgJIg8dAYvJ+SCjJYvN1SB/oAMV4k+XzRQ+45EUB4Ew593XHSAH7SQH5SAH+SWP7hf8PhcMAAABFKcIp0EQ50Hx6hcB0dot8JBxJ"
    . "AelEjWcBScHkBmYPH0QAAIP6Dw+OIgEAADH/RTHAZpBi0X9Ibyw5YvNVSD4MOwVi81VJPgw+AkiDx0Bi8n5IKMli83VIH/AAxXiT9vNFD7j2RQHwTDnndcdMAeNNAeFMAeZF"
    . "KcJJAekp0HQFQTnCfp9FhdIPjskAAABIg8EESDlMJBAPg8f+//9Ii1wkMESLTCQ8xMH5fuVIhdsPhIL6//9Iidnp/vz//w8fgAAAAADEQkH350WNdCT/SMHnAinQxMF7ks5i"
    . "0X7Jbwli8X7JbxtIAfti8X7JbxZIAf5IAe9i83VIPtMFSQH5YvN1Sj7SAmLyfkgoymLzdUgfwADF/EHZxXiT42bzRQ+45EUPt+RFAcRFKeJEOdAPjFL///+FwA+ESv///4P6"
    . "Dw+PYP7//0hj+kUxwOmq/v//RTHA6R////+LfCQ4xMH5fuVIictEKddBifnpPv///8X4d0iDxEhbXl9dQVxBXUFeQV/DhhBFOU1wD4+p+f//6Vn8//+QRTHA6en7//8PH4QA"
    . "AAAAAFdWU0SLVCRITGPCi1QkWESJyEWJy0xjTCRAD7bcQcHrEEEPr9BIY9JMAcpIjTSRi1QkUEEPr9BIY9JMAcpIjRSRSDnyc2pFD7bbD7bbRA+2yEGD+AF0EutnDx+AAAAA"
    . "AEiDwgRIOfJzRw+2SgEp2YnI99gPSMEPtkoCRCnZQYnIQffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteX8MPH0AAuAEAAABbXl/DDx+AAAAAAEnB"
    . "4ALrEmYuDx+EAAAAAABMAcJIOfJz2A+2SgJEKdmJyPfYD0jBD7ZKASnZic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBQTnCfcExwOuVZmYuDx+EAAAAAABmkFZTD69U"
    . "JDhMY0QkUESLVCRASGPSSQHQRInIRInLSo00gUxjRCRID7bEwesQTAHCSI0UkUg58nNgD7bbRA+22EUPtsnrDA8fAEiDwgRIOfJzRw+2SgIp2YnI99gPSMEPtkoBRCnZQYnI"
    . "QffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteww8fRAAAuAEAAABbXsNEi1QkKE2FwInQD5TCTYXJQQ+Uw0QI2g+FtgAAAEiFyQ+ErQAAAEUPttJB"
    . "adIAAQEARAnSgcoAAAD/YvJ9SHzSg/gPflhEjVjwYvH9SG/KMcBFidpBweoEQY1SAUjB4gZi8X9IbxwBYvFlSNjBYtH+SH8EAGLxdUjcw2LR/kh/BAFIg8BASDnQddZIAcFJ"
    . "AcFJAcBBweIERInYRCnQhcB0P7oBAAAAxOJ598KD6AHF+JLIYvF+yW8BYvF9SNjKYvF9SNzCYtF+SX8IYtF+SX8Bxfh3McDDZi4PH4QAAAAAAMX4dzHAw2YuDx+EAAAAAABB"
    . "V0FWQVVBVFVXVlNIg+w4i7QksAAAAEyLlCTIAAAATImMJJgAAABIichEicNMY9pIg7wkmAAAAACLlCSoAAAAD5TBRIuMJLgAAABIg7wkoAAAAABBD5TARAjBD4WBAQAASIXA"
    . "D4R4AQAAidFFD77BKfMPr85ED6/BiUwkCEljyESJx0hpyR+F61HB/x9IwfklKflBic+LjCTAAAAAhckPhVQBAABBgPlkD4RKAQAAhdsPiCsBAABIY8pNidxEjWrwRIlEJChJ"
    . "KcyLTCQISIlEJBhi83VIJcn/ScHkAolcJCxBvgEAAABEOflMiZQkyAAAAEqNLCBBD53BhckPlcFBIclKjQydAAAAAEUx20iJTCQgRInpwekERIhMJBCNeQHB4QREiVwkDEEp"
    . "zUjB5wZEiWwkBEiLRCQYSYnBSDnFD4J8BAAAgHwkEAB0EullAwAASYPBBEw5zQ+CYwQAAIN8JChjf+xMi5QkyAAAAESJ/k2F0g+FrgQAAMX4d+tnhcB0N8TCeffGg+gBxfiS"
    . "yGLRfslvAWLzfUg+1QVi831KPsQCYvJ+SCjAYvN9SR/BAMX4mMAPha4BAABIi0QkEEyLXCQYRItEJCCLXCQoQYPAAUwB2EwB3UE52A+O+AAAAMX4d0UxyUyJyEiDxDhbXl9d"
    . "QVxBXUFeQV/DSIu0JJgAAABIi4wkmAAAAEQPtkYBD7ZJAkHB4AjB4RBECcFED7YGSIu0JKAAAABECcFED7ZGAWLyfUh86UiLjCSgAAAAQcHgCA+2SQLB4RBECcFED7YGRAnB"
    . "gckAAAD/YvJ9SHzhhdsPiHj///9IY8pNidxEjWrwRIl8JAxJKcyLTCQITImUJMgAAABBvgEAAABJweQCYvN1SCXJ/4XJSo0sIEEPlcBEOfkPncFJweMCQSHIRIhEJCxJicBE"
    . "iejB6ASNeAHB4ARBKcUxwEjB5wZEiWwkBInBTInAQYnISYnBYvH9SG/dYvH9SG/USDnFD4Ld/v//SIlEJBAPtkwkLEyJXCQYRIlEJCCJXCQoZg8fhAAAAAAASInoTCnISMH4"
    . "AoPAAYP4D38e6Vf+//9mDx+EAAAAAACD6BBJg8FAg/gPD44+/v//YtF/SG8BYvN9SD7LBWLzfUk+ygJi8n5IKMFi831IH8EAxfiYwHTJxfiTwGbzD7zAi3QkDA+3wE2NDIGE"
    . "yQ+E8AAAAEiLnCSgAAAATIucJJgAAABNichEi1QkCIt0JAyQMcBFMf+D+g8PjgABAABmkGLRf0hvBABi031IPgwDBWLzfUk+DAMCSIPAQGLyfkgowWLzfUgf8QDFeJPu80UP"
    . "uO1FAe9IOfh1x0hjRCQESQH7SQH4SAH7hcAPhJEAAADEQnn37kGD7QFIweACQSnSxMF7ks1i0X7JbwBiwX7JbwNJAcNi4X7JbwtIAcNMAeBis31IPtAFSQHAYrN9Sj7RAmLy"
    . "fkgowmLzfUgfwQDF/EHpxXiT7WbzRQ+47UUPt+1FAf1EKe5BOfJ8CUWF0g+FLf///4X2D466AQAASYPBBEw5zQ+DiP7//+ks/f//Dx8ARCn+TQHgQSnSdNhEOdZ/0zHARTH/"
    . "g/oPD48C////SGPC6UH///9IiekPH4AAAAAASIucJKAAAABEi1QkCE2JyESJ/kyLnCSYAAAADx9EAAAxwEUx7YP6Dw+OIAEAAGaQYtF/SG8kAGLTXUg+DAMFYvNdST4MAwJI"
    . "g8BAYvJ+SCjBYvN9SB/ZAMX4k+vzD7jtQQHtSDn4dchIY0QkBEkB+0kB+EgB+4XAD4SyAAAAxMJ59+6D7QFIweACQSnSxfuSzWLRfslvAGLRfslvG0kBw2LxfslvE0gBw0wB"
    . "4GLzfUg+0wVJAcBi831KPtICYvJ+SCjCYvN9SB/BAMX8QeHF+JPsZvMPuO0Pt+1EAe0p7kQ51n8JRYXSD4Uz////hfZ+ZUmDwQRMOckPgwL///9Iic1Ii3QkIINEJAwBi0wk"
    . "LItEJAxIAXQkGEgB9TnID45R+///xfh36ff7//8PH0QAAEQp7k0B4EEp0nSyRDnWf60xwEUx7YP6Dw+P4v7//0hjwukg////TIuUJMgAAABNhdIPhFL7//9BKfdFiTrF+Hfp"
    . "sPv//0yLlCTIAAAARIt8JAxNhdIPhC77//9Eifgp8EGJAsX4d+mK+///Dx9EAABBVUFUVVdWU0iB7FgBAABMi5wksAEAAEyLlCS4AQAAi7wkwAEAAESLpCTIAQAAi4Qk0AEA"
    . "AEiLtCTgAQAASI1cJF9Ig+PATYXbQA+UxU2F0kEPlMVECO0PhQMBAABIhdIPhPoAAADF+e/AYvF/SH9DAUiJU0CLlCTYAQAARIlDSIXSiXtgD5XCPGSIQ2gPvsBBD5TAQQ+v"
    . "/GLxf0h/A0QJwkiJSxhJidgPttJEiUtMD6/HiVNsTIlbUEyJU1hIY9DB+B9EiWNkSGnSH4XrUYl7cEjB+iUpwkEPtkMCiVN0QQ+2UwHB4BDB4ggJ0EEPthMJ0EEPtlIBYvJ9"
    . "SHzAQQ+2QgJi8X5If0MCweIIweAQCdBBD7YSCdBIjRVC7///DQAAAP9i8n1IfMBi8X5If0MDxfh3/5HQAAAASIX2dAWLQxCJBkiLQwhIgcRYAQAAW15fXUFcQV3DZg8fhAAA"
    . "AAAAMcBIgcRYAQAAW15fXUFcQV3DZmYuDx+EAAAAAAAPHwBBVUFUVVdWU0iLXCRYRItUJHhEi5wkgAAAAEiFyQ+EBQEAAEiF2w+E/AAAAItEJGgx9kQJwAtEJGAJ0A+IsQAA"
    . "AEWF0g+O3gAAAEWF2w+O1QAAAEUPr8FIY9JBjXLwTWPJSo0sjQAAAABBvAEAAABFMclJY8BIAdBIY1QkYEiNDIGLRCRoD69EJHBImEgB0EiNFIOJ8EhjXCRwwegERI1AAcHg"
    . "BEjB4wJJweAGKcZmkDHAQYP6Dw+OfAAAAA8fQABi8f5IbwwCYvH+SH8MAUiDwEBJOcB16YX2dSVBg8EBSAHpSAHaRTnLf8a+AQAAAMX4d4nwW15fXUFcQV3DDx8ATo0sAkqN"
    . "PAGJ8MTCeffEg+gBxfiSyGLRfslvRQBi8X5Jfwfrtg8fADH2ifBbXl9dQVxBXcMPHwBEidBIic9JidXrx2ZmLg8fhAAAAAAAZpBIg+x4TIucJKgAAABIhdIPhNMAAABNhdsP"
    . "hMoAAACLhCS4AAAARTHSRAnIC4QksAAAAEQJwA+IoQAAAESLlCTIAAAARYXSD46cAAAAi4Qk0AAAAIXAD46NAAAAi4QkoAAAAEiJVCQwSI0V8uv//8X5bpQkwAAAAESJRCQ4"
    . "TI1EJCDE42kijCTIAAAAAYlEJEDF+W6cJLAAAACLhCTQAAAASIlMJCjE42EihCS4AAAAAcdEJCAAAAAARIlMJDzF+WzBTIlcJEiJRCRgxfp/RCRQ/5HQAAAAQboBAAAARInQ"
    . "SIPEeMMPH0AARTHSRInQSIPEeMNmZi4PH4QAAAAAAGaQuAQAAADDkJCQkJCQkJCQkA=="
    mcode_imgutil_column_uniform := 0x0007c0 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0008e0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000980 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000a70 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0010d0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001250 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x0013a0 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x0014a0 ; u32 get_blob_psabi_level()
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
    . "" ; 2880 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VVdWU0iD7Di/AQAAAEiJy/APwbnMAAAASIuRkAAAAEhjx0iNdCQg8w9+BMJIjSzFAAAAAA8WgZgAAAAPEUQkIOsjZg8fRAAASIuLwAAAAIn6/5O4AAAASIuDoAAAAEiLDCj/"
    . "U3BFMcBBuf////9IifK5AgAAAP+TiAAAAIXAdMgxwEiDxDhbXl9dww8fRAAAVlNIg+woMcBIictIhcl1EEiDxChbXsNmDx+EAAAAAABIh5G4AAAATIeBwAAAAIuJyAAAAIXJ"
    . "dCQx9mYPH0QAAEiLg5AAAABIiwzwSIPGAf9TcIuLyAAAADnOcuRIi5OgAAAAQbn/////QbgBAAAA/5OIAAAAuAEAAABIg8QoW17DZmYuDx+EAAAAAAAPH0AAVVdWU0iD7BhF"
    . "McBFMdtFMclEicBEicEPokSJwUyNBR0IAACJxrgAAACASY2o0AEAAA+iicdBi1AMQYsAQTnTRA9C2j0AAACAdj45x3JCRInJRYtQCA+iiQQkSWNABIlcJASJTCQIiVQkDEQj"
    . "FIR0IEmDwBBJOeh1vESJ2EiDxBhbXl9dww8fADnGc8KFwHi+QYPrAUSJ2EiDxBhbXl9dw2VIiwQlYAAAAEiLQBhIi0AgSIsASIsASItAIMNHZXRQcm9jQWRkcmVzcwAPH0QA"
    . "AFZTSYnLTInZi0E8SAHISI1AGEiNQHBIi8CLEEiNBBGLWBiLUCCF23RTRTHSSY00E0KLFJZBuEcAAABMjQ2r////TAHaD7YKhMl1HusmDx8ARDjBdR4PtkoBSIPCAUmDwQFF"
    . "D7YBhMl0BUWEwHXiRDjBdA5Jg8IBSTnadbQxwFtew4tQJEuNDFOLQBwPtxQRSY0Uk4sEAkwB2Fteww8fQABWU0iD7ChIictIhckPhLYAAABIi4mYAAAA/1NwSIuTqAAAAIuL"
    . "yAAAAEG5/////0G4AQAAAP+TiAAAAEiLi5gAAAD/k4AAAACLg8gAAACFwHRFMfYPH0AASIuDqAAAAEiLDPD/k4AAAABIi4OgAAAASIsM8P+TgAAAAEiLg5AAAABIiwzwSIPG"
    . "Af+TgAAAADuzyAAAAHLBSIuLoAAAAP9TKEiLi5AAAAD/UyhIi4uoAAAA/1MoSItDKEiJ2UiDxChbXkj/4A8fAEiDxChbXsOQVVdWU0iD7EhIi0FQx0QkOAAAAABIic5IhcAP"
    . "hAABAABIjXwkPEUxyTHSMclJifjHRCQ8AAAAAEjHRCQgAAAAAP/Qi1QkPLlAAAAA/1YgSInDSIXAD4S2AAAARTHJi1QkPEmJ+EiJwUjHRCQgAAAAAP9WUIXAD4SVAAAARItE"
    . "JDxFhcAPhC8BAABIidoxyUG6/////0Ux2zHtRTHJ6x5mkIPFAUGJwmYuDx+EAAAAAACLAgHBSAHCRDnBczSLQgSFwHXtD7ZCD0Q50HTkQYPBAYB6EgB0ykGJwosCQYPDAQHB"
    . "SAHCRDnBctMPH4AAAAAARInPKe9FhdtBD0T5SInZ/1YoifhIg8RIW15fXcMPHwAx/4n4SIPESFteX13DDx8AMdtIjXwkOOsuDx+AAAAAAP9WMIP4enXYSIXbdAZIidn/ViiL"
    . "VCQ4uUAAAAD/ViBIicNIhcB0uUiJ+kiJ2f9WSIXAdMyLRCQ4g/gfdkuNSOAx/0iJ2EGJyEHB6AVBjVABSMHiBUgB2mYPH4QAAAAAAIN4CAGD1wBIg8AgSDnCdfBBweAFichE"
    . "KcCJRCQ46Ur///9mDx9EAAAx/+k9////R2xvYmFsRnJlZQBHbG9iYWxBbGxvYwBMb2FkTGlicmFyeUEARnJlZUxpYnJhcnkAkEdldExvZ2ljYWxQcm9jZXNzb3JJbmZvcm1h"
    . "dGlvbgBHZXRTeXN0ZW1DcHVTZXRJbmZvcm1hdGlvbgBHZXRMYXN0RXJyb3IAUXVlcnlQZXJmb3JtYW5jZUNvdW50ZXIAUXVlcnlQZXJmb3JtYW5jZUZyZXF1ZW5jeQBDcmVh"
    . "dGVUaHJlYWQAV2FpdEZvclNpbmdsZU9iamVjdABDcmVhdGVFdmVudEEAU2V0RXZlbnQAUmVzZXRFdmVudABDbG9zZUhhbmRsZQBXYWl0Rm9yTXVsdGlwbGVPYmplY3RzAGaQ"
    . "QVVBVFVXVlNIg+w4ZUiLBCVgAAAASItAGEiLQCBIiwBIiwBIi0AgSInGic1IhcAPhOUCAABIicHog/v//0iNFav+//9IifFIicf/0EiNFaf+//9IifFJicX/17rYAAAAuUAA"
    . "AABJicT/0EiJw0iFwA+EpAIAAEiNBeP5//9IjRWC/v//SInxSIkzSImD0AAAAEyJYyBIiXsITIlrKP/XSI0Vbf7//0iJ8UiJQxD/10iNFWr+//9IifFIiUMY/9dIjRV5/v//"
    . "SInxSIlDSP/XSI0VhP7//0iJ8UiJQ1D/10iNFYH+//9IifFIiUMw/9dIjRWJ/v//SInxSIlDOP/XSI0Vk/7//0iJ8UiJQ0D/10iNFZD+//9IifFIiUNY/9dIjRWU/v//SInx"
    . "SIlDYP/XSI0Vkf7//0iJ8UiJQ2j/10iNFYr+//9IifFIiUNw/9dIjRWF/v//SInxSIlDeP/XSI0Vgf7//0iJ8UiJg4AAAAD/10iJg4gAAACF7Q+EVwEAAI0U7QAAAAC5QAAA"
    . "AImryAAAAEH/1LlAAAAASImDqAAAAIuDyAAAAI0UxQAAAABB/9S5QAAAAEiJg5AAAACLg8gAAACNFMUAAAAAQf/UMclFMclFMcBIiYOgAAAAugEAAAD/U2hIg7uoAAAAAEjH"
    . "g7gAAAAAAAAASImDmAAAAEiLi5AAAABIx4PAAAAAAAAAAMeDzAAAAAAAAAAPhM8AAABIhckPhMYAAABIi4OgAAAASIXAD4S2AAAAi5PIAAAAhdJ0fTHtTI0lg/f//+sIkEiL"
    . "g6AAAABIjTTtAAAAAEUxyUUxwDHSSI08MDHJSIPFAf9TaEUxyUUxwDHSSIkHSIu7kAAAADHJ/1NoSYnZTYngMdJIAfcxyUiJB0gDs6gAAABIx0QkKAAAAADHRCQgAAAAAP9T"
    . "WEiJBjuryAAAAHKPSInYSIPEOFteX11BXEFdww8fgAAAAABIidnoUPr//4nF6Zr+//9mDx+EAAAAAAD/k4AAAABIi4ugAAAA/1MoSIuLqAAAAP9TKEiLi7AAAAD/UyhIidlB"
    . "/9Ux20iJ2EiDxDhbXl9dQVxBXcMPH0AAAQAAAAMAAAABAAAAAQAAAAEAAAADAAAAAAEAAAEAAAABAAAAAwAAAAAIAAABAAAAAQAAAAMAAAAAgAAAAQAAAAEAAAADAAAAAAAA"
    . "AQEAAAABAAAAAwAAAAAAgAABAAAAAQAAAAMAAAAAAAABAQAAAAEAAAADAAAAAAAAAgEAAAABAAAAAwAAAAAAAAQBAAAAAQAAAAIAAAABAAAAAgAAAAEAAAACAAAAACAAAAIA"
    . "AAABAAAAAgAAAAAACAACAAAAAQAAAAIAAAAAABAAAgAAAAEAAAACAAAAAACAAAIAAAABAACAAgAAAAEAAAACAAAAAQAAAAIAAAAAEAAAAwAAAAEAAAACAAAAAABAAAMAAAAB"
    . "AAAAAgAAAAAAAAgDAAAAAQAAAAIAAAAAAAAQAwAAAAEAAAACAAAAAAAAIAMAAAABAACAAgAAACAAAAADAAAABwAAAAEAAAAIAAAAAwAAAAcAAAABAAAAIAAAAAMAAAAHAAAA"
    . "AQAAAAABAAADAAAABwAAAAEAAAAAAAEABAAAAAcAAAABAAAAAAACAAQAAAAHAAAAAQAAAAAAABAEAAAABwAAAAEAAAAAAABABAAAAAcAAAABAAAAAAAAgAQAAACQkJCQkJCQ"
    . "kJCQkJCQkJCQ"
    mcode_mt_threadproc         := 0x000000 ; 
    mcode_mt_run                := 0x000090 ; 
    mcode_get_cpu_psabi_level   := 0x000120 ; int get_cpu_psabi_level()
    mcode_gpa_getkernel32       := 0x0001c0 ; 
    mcode_gpa_getgetprocaddress := 0x0001f0 ; 
    mcode_mt_deinit             := 0x000290 ; 
    mcode_mt_get_cputhreads     := 0x000360 ; int mt_get_cputhreads(mt_ctx *ctx)
    mcode_mt_init               := 0x000630 ; 
    ;----------------- end of ahkmcodegen auto-generated section ------------------
            
        static code := this.i_b64decode(b64)
        codemap := Map( "get_cpu_psabi_level",       code + mcode_get_cpu_psabi_level
                      , "mt_get_cputhreads",         code + mcode_mt_get_cputhreads
                      , "mt_init",                   code + mcode_mt_init
                      , "mt_deinit",                 code + mcode_mt_deinit
                      )
        return codemap
    }






















































































