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
    . "" ; 4688 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -D MARCH_x86_64_v0 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVVBVFVXVlNIic6F0g+OlQAAAEiLCUmLGEGJ1DHATYsRMe0PH0QAAEQPtmyBAkQ6bIMCD5PCRThsggJED7ZcgQFBD5PFD7Y8gUQh6kU4XIIBQQ+TxUQh6kQ6XIMBQQ+Tw0Qh"
    . "2kE4PIJBD5PDRITadAdAOjyDg93/SIPAAUk5xHWnScHkAonoTQHiTAHjTAHhTYkRSYkYSIkOW15fXUFcQV3DZg8fRAAAMe2J6FteX11BXEFdw2ZmLg8fhAAAAAAAVlNEi0FA"
    . "SItBCEhjcSBEi5DIAAAAQQ+v0EGJ0YnQMdJB9/Ix0kGJw0ONBAhEi0E0TGNJMEH38khjUThMY1EYRQHYRA+vwk1jwE0ByEyLSShPjQSBRItJHEUB2UQPr85NY8lNAdFMi1EQ"
    . "T40MikE5w31GRItRPEiNHJUAAAAASMHmAkWF0nQxZg8fhAAAAAAAMdJmDx9EAABBiwyQQYkMkUiDwgFMOdJ170GDwwFJAdhJAfFEOdh12Fteww8fRAAAQVRVV1ZTi0QkaA+2"
    . "XCRQD7Z0JFgPtmwkYInXhcB+UEyNJIEPH0QAAEQPtlECD7ZRAUQPthlFOMoPk8BEONVBD5PCRCHQQDjWQQ+TwkQh0EQ4wg+TwiHQRDjbD5PChNB0BUE4+3MSSIPBBEw54XW5"
    . "McBbXl9dQVzDSInI6/QPHwBBV0FWQVVBVFVXVlNED7ZcJGgPtlwkcA+2dCR4SYnKhdIPjnwAAACJ0kUx5EyNLJFBD7YKQQ+2UgFBxkADAEEPtkICQcZBA/9Bic6J1UUo3onH"
    . "RQ9C9EAo3UEPQuxAKPdBD0L8RADZRYgwRRj/QYhoAUQJ+QDaQYh4AkUY/0GICUQJ+kAA8EGIUQEY0kmDwgRJg8EECdBJg8AEQYhB/k056nWNMcBbXl9dQVxBXUFeQV/DZmYu"
    . "Dx+EAAAAAAAPHwBBV0FWQVVBVFVXVlNIgeyoAAAAx0QkfAAAAABMjaQkkAAAAEmJyU2J50iNrCSIAAAATInOSIlsJGgPH4AAAAAAuAEAAADwD8EGi1YsK1ZEOcIPjMkCAABI"
    . "Y1YoSItOIA+vwkiYTI00gUhjRkBIKcJIicOLRkxIjSyVAAAAAE2NBC6FwA+ENwEAAE058HKyD7ZGWEyJRCRITInxSI28JJgAAABMi2QkaIhEJFAPtkZZiEQkWA+2RlqIRCRk"
    . "D7ZGXIhEJHkPtkZdiEQkeg+2Rl6IRCR7Dx9EAABIi0QkSEQPtkwkZEQPtkQkWA+2VCRQSCnISMH4AoPAAYlEJDgPtkQke4hEJDAPtkQkeohEJCgPtkQkeYhEJCDopP3//0iJ"
    . "wUiFwA+EGP///0iLRjCLVlRIiYwkmAAAAESLblBIiYQkiAAAAEiLRjhBidZIiYQkkAAAAEQ56n9GRYXtdEFNiflNieBJic9JifSJ1mYPH0QAAInaSIn56Mb7//9IAawkmAAA"
    . "AEEpxkEp3XQFRTnufuFMifmJ8k2Jz0yJ5k2JxEWF9g+OHAEAAEiDwQRIOUwkSA+DI////+mG/v//Zg8fRAAATTnwD4K/AAAARItWUItWVEyJRCRYTYn5TItEJGhIibQk8AAA"
    . "AEyNpCSYAAAARDnSRIlUJGRBiddBD57FRYXSD5XAQSHFSItGMEiJRCRISItGOIneTInzSIlEJFAPH0AASItEJEhIiZwkmAAAAEiJhCSIAAAASItEJFBIiYQkkAAAAEWE7XRZ"
    . "RIt0JGREif+QifJMieHo5vr//0gBrCSYAAAAKcdBKfZ0BUQ5937ihf9+NUiDwwRIOVwkWHOjSIu0JPAAAABNic9Ig3wkcAAPhKz9//9Mi2QkcEmJ8esxZpBEif+F/3/LRIn6"
    . "SIlcJHBIi7Qk8AAAAE2Jzyn6iVQkfOvGRCnySYnMSYnxiVQkfEmNURRBugEAAAAPH4AAAAAARYnQRIYCRYTAdfWLRCR8QTlBEH0/QYlBEE2JYQhEhgJBOUFQD48f/f//QYtR"
    . "LEGHEekT/f//Zi4PH4QAAAAAAEiBxKgAAABbXl9dQVxBXUFeQV/DRIYCi0QkfEE5QVAPj+T8///rw2YPH4QAAAAAAFdWU4tcJEhEichIY/JIY1QkQEWJyA+2xEHB6BBBicKL"
    . "RCRYD6/GSJhIAdBMjRyBi0QkUA+vxkiYSAHQSI0UgUw52nNsRQ+2wEUPttJFD7bJg/4BdBTraWYPH4QAAAAAAEiDwgRMOdpzRw+2SgFEKdGJyPfYD0jBD7ZKAkQpwYnO994P"
    . "Sc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteX8NmLg8fhAAAAAAAuAEAAABbXl/DDx+AAAAAAEjB5gLrEmYuDx+EAAAAAABIAfJMOdpz2A+2SgJEKcGJyPfYD0jB"
    . "D7ZKAUQp0YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9MwTnDfcExwOuPZmYuDx+EAAAAAABmkFZTD69UJDiLXCRASGPSSInOSGNMJFBEichFicoPtsRBweoQSAHRTI0c"
    . "jkhjTCRISAHKSI0Ulkw52nNdRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPCBEw52nM/D7ZKAkQp0YnI99gPSMEPtkoBRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zB"
    . "OcN9wDHAW17DDx8AuAEAAABbXsNBV0FWQVVBVFVXVlNIg+wYi6wkiAAAAIu0JJAAAABFD6/BSInLi4wkgAAAAEljwEyNNINMOfMPg7oAAABMY+pBKdFBicsPtv1JweUCTWPh"
    . "QcHrEEQPttFMiWwkCEUPtttJweQCRTHJTYnvZg8fRAAASItEJAhMjQQDTDnDc1xIidoPH4AAAAAAD7ZCAg+2SgFEKdhBicVB991ED0joKfmJyPfYD0jBD7YKQTnFQQ9NxUQp"
    . "0UGJzUH33UQPSOlEOehBD0zFOcZ8BokqQYPBAUiDwgRMOcJysUwB+0wB40w583KORInISIPEGFteX11BXEFdQV5BX8NFMcnr5w8fRAAAVlOLRCRIi1QkWEhjXCRARItEJFAB"
    . "wkmJ20EPr9FJicqLTCQ4QQ+vwUhj0kQB2EgB2kiYSY0ckkmNFIJIOdpzaU1j2EUpwUnB4wJNY9FJweICTIneDx9AAE6NBBpMOcJzQEiJ0IkKSPfQTAHASMHoAoPgAUmJwUiN"
    . "QgRMOcBzH02FyXQMiQhIjUIITDnAcw+QiQhIg8AIiUj8TDnAcvJIAfJMAdJIOdpyr1teww8fQABXVlNFD6/BSYnKSWPASI00gUg58XNiQSnRSGPaTWPZSMHjAkG5q6qqqknB"
    . "4wJIid9NjQQaTTnCczdMidIPH0AAD7ZKAQ+2QgJIg8IEAcgPtkr8AchJD6/BSMHoIQ+2yIhC/ojFZolK/Ew5wnLTSQH6TQHaSTnycrhbXl/DDx9AAFNIg+xARItUJHBNhcAP"
    . "lMBNhclBD5TDRAjYdTxIhcl0N0UPttJBacIAAQEARAnQDQAAAP9BicKIZCQoQcHqEIhEJCBEiFQkMOiz9///SIPEQFvDDx9EAAAxwEiDxEBbw0FXQVZBVUFUVVdWU0iB7LgA"
    . "AABEi7QkKAEAAIu0JDABAABEi5wkOAEAAEiLnCRIAQAATYXJSInITGPSTInKD5TBSIO8JCABAAAAQQ+UwUQIyQ+FeAEAAEiFwA+EbwEAAESJ90UPvstBKfAPr/5EiUQkbESJ"
    . "xkSLhCRAAQAARA+vz4l8JExJY/lBwfkfSGn/H4XrUUjB/yVEKc+JfCRIRYXAD4VCAQAAQYD7ZA+EOAEAAIX2D4gWAQAAi3QkTIn5TWPGTInXTCnHSImcJEgBAABMjYwkoAAA"
    . "AEmJ1EjB5wKF9kAPlcU5zkyNLDhIicFBD53AMcBJweICTInuRCHFicNMjYQkmAAAAEiJyECIbCRATInRDx9EAABIjawkqAAAAEg5xg+CkQAAAEiJRCRQSIlMJFiJXCRgRInz"
    . "SYnGDx8ASIuEJCABAACAfCRAAEyJpCSYAAAATIm0JKgAAABIiYQkoAAAAA+ExQIAAESLbCRMRIt8JEgPHwCJ2kiJ6ege9P//SAG8JKgAAABBKcdBKd10BUU5737hRYX/D46e"
    . "AgAASYPGBEw59nOXQYneSItEJFBIi0wkWItcJGCLVCRsg8MBSAHISAHOOdMPjkn///9FMf9MifhIgcS4AAAAW15fXUFcQV1BXkFfw0QPtkICRA+2SgFIi7wkIAEAAItMJGxB"
    . "weEIQcHgEEUJyEQPtgpFCchED7ZPAUSJhCSIAAAARInGRA+2RwJBweEIQcHgEEUJyEQPtg9FCchBgcgAAAD/RYnFhcl4iYt8JExNY86LTCRITYnQTSnISImcJEgBAACF/0qN"
    . "LIUAAAAASImUJBgBAABBD5XBOc9BD53ARTHbRSHBRInaTo0ElQAAAABEiEwka0mJwUiNBChIiUQkQInwwegQiEQkaonwD7bEiYQkjAAAAESJ6A8fAEyJyUw5TCRAD4JNAQAA"
    . "i7QkjAAAAEGJxYhEJGBIjbwkoAAAAEHB7RCJRCRwSI2cJKgAAACJdCRkD7a0JIgAAABEiGwkWIlUJHRMiUQkeEyJjCSAAAAAQIh0JGkPtvSJdCRQSI20JJgAAABmDx9EAABI"
    . "i0QkQEQPtkwkakQPtkQkZA+2VCRpSCnISMH4AoPAAYlEJDgPtkQkWIhEJDAPtkQkUIhEJCgPtkQkYIhEJCDotPP//0mJxUiFwA+EhgAAAEiLhCQYAQAAgHwkawBMiawkqAAA"
    . "AEiJhCSYAAAASIuEJCABAABIiYQkoAAAAA+EvQAAAESLfCRMRItkJEhJiflJifAPH0QAAESJ8kiJ2ejV8f//SAGsJKgAAABBKcRFKfd0BUU5/H7gTInPTInGRYXkD46HAAAA"
    . "SY1NBEg5TCRAD4Mq////i0QkcItUJHRMi0QkeEyLjCSAAAAAi3QkbIPCAUwBRCRATQHBOfIPjo7+///poP3//5BEi3wkSEWF/w+PYv3//0iLnCRIAQAARIn+TYn3SIXbD4R9"
    . "/f//i1QkSCnyiRPpcP3//2YPH0QAAESLZCRIRYXkD495////SIucJEgBAABNie9IhdsPhEj9//+LVCRIRCniiRPpOv3//w8fhAAAAAAAQVRVV1ZTSIPEgEyLnCTQAAAATIuU"
    . "JNgAAACLrCToAAAAi4Qk8AAAAE2F20iLnCQAAQAAQA+Ux02F0kEPlMRIidaLlCTgAAAARAjnD4X/AAAASIX2D4T2AAAARIlEJEhEi4Qk+AAAAGYP78APEUQkXEWFwESJTCRM"
    . "QQ+VwDxkiVQkYEEPlMEPr9WIRCRoD77ARQnIDxFEJDBFD7bASIlMJDgPr8KJVCRwRIlEJGxMjUQkIEiJdCRASGPQwfgfTIlcJFBIadIfhetRTIlUJFiJbCRkDxFEJCBIwfol"
    . "KcJBD7ZDAolUJHRBD7ZTAcHgEMHiCAnQQQ+2EwnQQQ+2UgGJRCR4QQ+2QgLB4gjB4BAJ0EEPthIJ0EiNFaTy//8NAAAA/4lEJHz/kdAAAABIhdt0BotEJDCJA0iLRCQoSIPs"
    . "gFteX11BXMNmLg8fhAAAAAAAMcBIg+yAW15fXUFcww8fAFZTTItUJDiLdCRgSIXJD4S0AAAATYXSD4SrAAAAi0QkSEUx20QJwAtEJEAJ0A+IigAAAItEJFiFwA+OiQAAAIX2"
    . "D46BAAAARQ+vwUhj0k1jyUqNHI0AAAAASWPASAHQSGNUJEBMjQSBi0QkSA+vRCRQSJhIAdBJjQyCSGNEJFBEi1QkWEyNDIUAAAAADx9AADHAZg8fRAAAixSBQYkUgEiDwAFJ"
    . "OcJ18EGDwwFJAdhMAclEOd5/2UG7AQAAAESJ2Fteww8fRAAARTHbRInYW17DZmYuDx+EAAAAAAAPH0AASIPseEyLnCSoAAAASInISIXSD4TYAAAATYXbD4TPAAAAi4wkuAAA"
    . "AEUx0kQJyQuMJLAAAABECcEPiKcAAABEi5QkyAAAAEWF0g+OoQAAAIuMJNAAAACFyQ+OkgAAAEiJVCQwi5QkoAAAAEiJwWYPbowkwAAAAESJRCQ4TI1EJCBmD26UJMgAAACJ"
    . "VCRAZg9uhCSwAAAAi5Qk0AAAAMdEJCAAAAAAZg9unCS4AAAAZg9iykiJRCQoiVQkYEiNFb7u//9mD2LDRIlMJDxmD2zBTIlcJEgPEUQkUP+Q0AAAAEG6AQAAAESJ0EiDxHjD"
    . "Dx8ARTHSRInQSIPEeMMPH0QAADHAw5CQkJCQkJCQkJCQkJA="
    mcode_i_imgutil_pixelmatchcount_v0 := 0x000000 ; define i_imgutil_pixelmatchcount i_imgutil_pixelmatc(a)_mm_popcnt_u32(a)
    mcode_imgutil_column_uniform       := 0x000610 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform          := 0x000730 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_replace_color        := 0x0007d0 ; i32 imgutil_replace_color(argb *ptr, i32 width, i32 height, i32 stride, argb cold, argb cnew, i32 tolerance)
    mcode_imgutil_fill                 := 0x0008d0 ; void imgutil_fill(argb *ptr, i32 width, i32 height, i32 stride, argb c, i32 x, i32 y, i32 w, i32 h)
    mcode_imgutil_grayscale            := 0x000980 ; void imgutil_grayscale(argb *ptr, i32 width, i32 height, i32 stride)
    mcode_imgutil_make_sat_masks       := 0x000a00 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch              := 0x000a60 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi        := 0x000f00 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit                 := 0x001060 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi           := 0x001140 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level         := 0x001240 ; u32 get_blob_psabi_level()
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_replace_color",     code + mcode_imgutil_replace_color
                    , "imgutil_fill",              code + mcode_imgutil_fill
                    , "imgutil_grayscale",         code + mcode_imgutil_grayscale
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
    . "" ; 6128 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIyAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
    . "Y9JIAcpJi0sQTI0MkUE5wg+N1QAAAA8fgAAAAABBi1s8g/sDD47LAAAAjWv8MdKJ7sHuAo1OAUjB4QRmkPNBD28EEEEPEQQRSIPCEEg50XXs995JjTwJTAHBjVS1AEGLazhB"
    . "i3MghdJ0HkSLMUSJN4P6AXQTRItxBESJdwSD+gJ0BotRCIlXCEhj1UhjzkGDwgFIweICSMHhAkkB0EkByUQ50HRGg/sDD49v////RYtbPA8fAEWF23QiQYsYQYkZQYP7AXQW"
    . "QYtYBEGJWQRBg/sCdAhBi1gIQYlZCEGDwgFJAdBJAclEOdB/ylteX11BXsMPHwCJ2kyJz0yJwelk////ZmYuDx+EAAAAAABBV0FWQVVBVFVXVlNIg+xIDxF0JDAxwGYPdsm6"
    . "AQAAAPAPwRFEi0EsRCtBREE50A+MwAUAAExjaShMi0kgQQ+v1Uhj0kmNFJFEi0lATWPBTSnFRItBTEnB5QJOjTwqRYXAD4QJAwAASTnXcq9FjVH88w9vYWDzD29ZcEWJ0EHB"
    . "6AJFjWABQffYR400gknB5ARBicAPH0QAAEyJ+Egp0EjB+AKDwAGD+AN/FukhAgAAkIPoBEiDwhCD+AMPjhACAADzD28CZg9v7GYPb9NmD97QZg/e6GYPdMVmD3TTZg/bwmYP"
    . "dsFmRA/X0EWF0nTC80UPvNJBwfoCSWPCSI0Ugot5VItxUEiLWTBMi1k4OfcPjw0CAABIidCJ/YX2D4QAAgAAiXwkCEiJVCQQZg8fRAAARTHSMdJBg/kDD46JAQAAiWwkKA8f"
    . "RAAA80IPbwQQ80IPbxQT80MPbywTZg/e0GYP3uhmD3TC80MPbxQTSYPCEGYPdNVmD9vCZg92wWYP1+iJ72bR72aB51VVKf2J72bB7QJmgeczM2aB5TMzAf2J72bB7wQB72aB"
    . "5w8Pif1mwe0IAe9mwe8Cg+cHAfpNOdR1h4tsJChMAeNNAeNMAeBFifJFhdIPhLUAAABmD24oZkEPbjNmD24TZg9vxWYP3tVmD97GZg901WYPdMZmD9vCZg92wWYP1/iD5wEB"
    . "+kGD+gF0cGYPbmgEZkEPbnMEZg9uUwRmD2/FZg/e1WYP3sZmD3TVZg90xmYP28JmD3bBZg/X+IPnAQH6QYP6AnQ1ZkEPblMIZg9uQAhmD25rCGYPb/JmD97oZg/e8GYPdMVm"
    . "D3TWZg/bwmYPdsFmD9f4g+cBAfpJweICTAHTTQHTTAHQKdVMAehEKc50CDn1D46P/v//i3wkCEiLVCQQhe1+eUiDwgRJOdcPg939//9EicDpWP3//w8fRAAARYnK6QH///+F"
    . "wHTnTI0Ugg8fhAAAAAAAZg9uAmYPb+xmD2/TZg/e0GYP3uhmD3TFZg9002YP28JmD3bBZg/XwKgBD4Xu/f//SIPCBEw50nXHRInA6fr8//+J/YXtf4eJ+CnoTI1BFEG6AQAA"
    . "AEWJ0UWGCEWEyXX1OUEQD43CAgAAiUEQSIlRCEWGCDtBUA+Mv/z//4tRLIcR6bX8//9mLg8fhAAAAAAASTnXD4IyAgAASItxMIt5UESLUVRMi2E4SIl0JBhBjXH8QTn6QYn2"
    . "D57Dhf9BD5XDQcHuAkWJ8EGNbgFB99hIweUERo00hkSE2w+EEgIAAESJVCQQTYngiUQkLEiJjCSQAAAADx9EAABIiVQkCEyLVCQYSInQTYnDRItkJBCJ+0yJxmYPH0QAAEUx"
    . "wDHJRInKQYP5Aw+OoAAAAESJZCQokPNCD28EAPNDD28UAvNDD28cA2YP3tBmD97YZg90wvNDD28UA0mDwBBmD3TTZg/bwmYPdsFmRA/X4ESJ4mbR6maB4lVVQSnURIniZkHB"
    . "7AJmgeIzM2ZBgeQzM0EB1ESJ4mbB6gREAeJmgeIPD0GJ1GZBwewIRAHiZsHqAoPiBwHRTDnFD4V3////RItkJChJAepJAetIAehEifKF0g+EvwAAAGYPbhhmQQ9uI2ZBD24S"
    . "Zg9vw2YP3tNmD97EZg9002YPdMRmD9vCZg92wWZED9fAQYPgAUQBwYP6AXR3Zg9uWARmQQ9uYwRmQQ9uUgRmD2/DZg/e02YP3sRmD3TTZg90xGYP28JmD3bBZkQP18BBg+AB"
    . "RAHBg/oCdDlmQQ9uUwhmD25ACGZBD25aCGYPb+JmD97YZg/e4GYPdMNmD3TUZg/bwmYPdsFmRA/XwEGD4AFEAcFIweICSQHSSQHTSAHQQSnMTAHoRCnLdAlBOdwPjnP+//9I"
    . "i1QkCEmJ8EWF5H5JSIPCBEk51w+DOf7//4tEJCxIi4wkkAAAAEiDfCQgAA+EZPr//0iLVCQg6Wr9//8PH4AAAAAASIPCBEk513LaRYXSf/JFidTrDUSLVCQQSIuMJJAAAABE"
    . "idBIiVQkIEQp4Ou2DxB0JDBIg8RIW15fXUFcQV1BXkFfw0WGCDlBUA+PBPr//+lA/f//Dx9AAFdWU4tcJEhEichIY/JIY1QkQEWJyA+2xEHB6BBBicKLRCRYD6/GSJhIAdBM"
    . "jRyBi0QkUA+vxkiYSAHQSI0UgUw52nNsRQ+2wEUPttJFD7bJg/4BdBTraWYPH4QAAAAAAEiDwgRMOdpzRw+2SgFEKdGJyPfYD0jBD7ZKAkQpwYnO994PSc45yA9MwQ+2CkQp"
    . "yYnO994PSc45yA9MwTnDfcAxwFteX8NmLg8fhAAAAAAAuAEAAABbXl/DDx+AAAAAAEjB5gLrEmYuDx+EAAAAAABIAfJMOdpz2A+2SgJEKcGJyPfYD0jBD7ZKAUQp0YnP998P"
    . "Sc85yA9MwQ+2CkQpyYnP998PSc85yA9MwTnDfcExwOuPZmYuDx+EAAAAAABmkFZTD69UJDiLXCRASGPSSInOSGNMJFBEichFicoPtsRBweoQSAHRTI0cjkhjTCRISAHKSI0U"
    . "lkw52nNdRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPCBEw52nM/D7ZKAkQp0YnI99gPSMEPtkoBRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW17DDx8A"
    . "uAEAAABbXsNBV0FWQVVBVFVXVlNIg+wYi6wkiAAAAIu0JJAAAABFD6/BSInLi4wkgAAAAEljwEyNNINMOfMPg7oAAABMY+pBKdFBicsPtv1JweUCTWPhQcHrEEQPttFMiWwk"
    . "CEUPtttJweQCRTHJTYnvZg8fRAAASItEJAhMjQQDTDnDc1xIidoPH4AAAAAAD7ZCAg+2SgFEKdhBicVB991ED0joKfmJyPfYD0jBD7YKQTnFQQ9NxUQp0UGJzUH33UQPSOlE"
    . "OehBD0zFOcZ8BokqQYPBAUiDwgRMOcJysUwB+0wB40w583KORInISIPEGFteX11BXEFdQV5BX8NFMcnr5w8fRAAAVlOLRCRIi1QkWEhjXCRARItEJFABwkmJ20EPr9FJicqL"
    . "TCQ4QQ+vwUhj0kQB2EgB2kiYSY0ckkmNFIJIOdpzaU1j2EUpwUnB4wJNY9FJweICTIneDx9AAE6NBBpMOcJzQEiJ0IkKSPfQTAHASMHoAoPgAUmJwUiNQgRMOcBzH02FyXQM"
    . "iQhIjUIITDnAcw+QiQhIg8AIiUj8TDnAcvJIAfJMAdJIOdpyr1teww8fQABXVlNFD6/BSYnKSWPASI00gUg58XNiQSnRSGPaTWPZSMHjAkG5q6qqqknB4wJIid9NjQQaTTnC"
    . "czdMidIPH0AAD7ZKAQ+2QgJIg8IEAcgPtkr8AchJD6/BSMHoIQ+2yIhC/ojFZolK/Ew5wnLTSQH6TQHaSTnycrhbXl/DDx9AAESLVCQoTYXAidAPlMJNhclBD5TDRAjaD4Xh"
    . "AAAASIXJD4TYAAAARQ+20kFp0gABAQBECdKBygAAAP9mD27iZg9w3ACD+AN+VESNWPxmD2/LMcBFidpBweoCQY1SAUjB4gQPH4AAAAAA8w9vBAFmD2/QZg/cwWYP2NFBDxEE"
    . "AUEPERQASIPAEEg5wnXcQffaSAHRSQHRSQHQQ40Ek4XAdF5mD24BZg9vyGYP3MNmD9jLZkEPfgFmQQ9+CIP4AXQ/Zg9uQQRmD2/IZg/cw2YP2MtmQQ9+QQRmQQ9+SASD+AJ0"
    . "HWYPbkkIZg9vwWYP2MNmD9zZZkEPfkAIZkEPflkIMcDDZmYuDx+EAAAAAAAPH0AAQVdBVkFVQVRVV1ZTSIPsaA8RdCRADxF8JFCLtCTgAAAAi5wk6AAAAE2FyUWJwk2Jy0iJ"
    . "yEEPlMCLjCTYAAAASIO8JNAAAAAAQQ+UwUUIyA+FEQMAAEiFwA+ECAMAAEGJz0QPvsNED6/+RQ+vx01jyESJx01pyR+F61HB/x9JwfklQSn5RYnORYnRRIuUJPAAAABBKfFF"
    . "hdIPhf4CAACA+2QPhPUCAABFhckPiLYCAABIY9JMY9FMiZwkyAAAAEWJ80mJ1EiNPJUAAAAASInCTSnUSIl8JBhmD3bkScHkAkWF/w+Vw0U590qNNCBMi7QkyAAAAEEPncJE"
    . "IdNEjVH8RInQwegCjXgB99hFjSyCidhIwecERInDRTHSQYnASInQSDnWD4IlAgAARYTAD4RaAgAARIl8JAyJXCQ4RIlcJAhEiVQkIESIRCQoSIl0JBBIiVQkMESJTCQ8Dx+A"
    . "AAAAAItcJAyLbCQISInCTYnxTIuUJNAAAABmLg8fhAAAAAAAMfZFMdtBiciD+QMPjqMAAAAPH4AAAAAA8w9vBDLzQQ9vDDHzQQ9vFDJmD97IZg/e0GYPdMHzQQ9vDDJIg8YQ"
    . "Zg90ymYP28FmD3bEZkQP1/hFifhmQdHoZkGB4FVVRSnHRYn4ZkHB7wJmQYHgMzNmQYHnMzNFAcdFifhmQcHoBEUB+GZBgeAPD0WJx2ZBwe8IRQH4ZkHB6AJBg+AHRQHDSDn+"
    . "D4Vw////SQH5SQH6SAH6RYnoRYXAD4TAAAAAZg9uEmZBD24aZkEPbglmD2/CZg/eymYP3sNmD3TKZg90w2YP28FmD3bEZg/X8IPmAUEB80GD+AF0eWYPblIEZkEPbloEZkEP"
    . "bkkEZg9vwmYP3spmD97DZg90ymYPdMNmD9vBZg92xGYP1/CD5gFBAfNBg/gCdDxmQQ9uSghmD25CCGZBD25RCGYPb9lmD97QZg/e2GYPdMJmD3TLZg/bwWYPdsRmD9fwg+YB"
    . "QQHzDx9EAABJweACTQHBTQHCTAHCRCndTAHiKct0CDndD45x/v//he0PjiUEAABIg8AESDlEJBAPgzr+//9Ei3wkDItcJDhEi1wkCESLVCQgRA+2RCQoSIt0JBBIi1QkMESL"
    . "TCQ8SItEJBhBg8IBSAHCSAHGRTnKD463/f//McAPEHQkQA8QfCRQSIPEaFteX11BXEFdQV5BX8NIg8AESDnGcsKD+2N/8kWJ3kSJ3emlAwAARQ+2QwJFD7ZTAUiLnCTQAAAA"
    . "QcHiCEHB4BBFCdBFD7YTRQnQRA+2UwFmQQ9u2EQPtkMCQcHiCGYPcNsAQcHgEEUJ0EQPthNFCdBBgcgAAAD/ZkEPbuBmD3DkAEWFyQ+IZv///0hj0kxjwWYPdtJJidRNKcRJ"
    . "weQCRYX/QQ+VwkU590qNNCBBD53ARSHCSYnARIhUJBhMjRSVAAAAAI1R/InQwegCjWgB99hEjSyCSMHlBDHSTInAZg9vzEw5xg+CfQIAAIlUJDhMiUQkIEyJVCQoRIlMJDAP"
    . "H0QAAEiJ8kgpwkjB+gKDwgGD+gN/FullAgAAkIPqBEiDwBCD+gMPjlQCAADzD28AZg9v82YPb+lmD97oZg/e8GYPdMZmD3TpZg/bxWYPdsJmRA/XwEWFwHTC80UPvMBBwfgC"
    . "SWPQSI0EkIB8JBgARIn3D4TJAQAARIl8JAhIicJNidlEiftEiXQkDEyLlCTQAAAASIl0JBAPH0AARTH2MfZBiciD+QMPjqQAAAAPH4AAAAAA80IPbwQy80MPbywx80MPbzQy"
    . "Zg/e6GYP3vBmD3TF80MPbywySYPGEGYPdO5mD9vFZg92wmZED9f4RYn4ZkHR6GZBgeBVVUUpx0WJ+GZBwe8CZkGB4DMzZkGB5zMzRQHHRYn4ZkHB6ARFAfhmQYHgDw9Ficdm"
    . "QcHvCEUB+GZBwegCQYPgB0QBxkk57g+Fb////0kB6UkB6kgB6kWJ6EWFwA+ExwAAAGYPbjJmQQ9uOmZBD24pZg9vxmYP3u5mD97HZg907mYPdMdmD9vFZg92wmZED9fwQYPm"
    . "AUQB9kGD+AF0fmYPbnIEZkEPbnoEZkEPbmkEZg9vxmYP3u5mD97HZg907mYPdMdmD9vFZg92wmZED9fwQYPmAUQB9kGD+AJ0P2ZBD25qCGYPbkIIZkEPbnEIZg9v/WYP3vBm"
    . "D974Zg90xmYPdO9mD9vFZg92wmZED9fwQYPmAUQB9mYPH0QAAEnB4AJMAcJNAcFNAcIp90wB4inLdAg53w+Oav7//0SLfCQIRIt0JAxIi3QkEIX/D46mAAAASIPABEg5xg+D"
    . "rv3//4tUJDhMi0QkIEyLVCQoRItMJDCDwgFNAdBMAdZEOcoPjmH9///pcvz//4XSdNJMjQSQDx9AAGYPbgBmD2/zZg9v6WYP3uhmD97wZg90xmYPdOlmD9vFZg92wmYP19CD"
    . "4gEPha39//9Ig8AETDnAdcbrjkSLdCQISIO8JPgAAAAAD4QY/P//SIucJPgAAABBKe5EiTPpBfz//0iDvCT4AAAAAA+E9vv//0iLnCT4AAAARInyKfqJE+ni+///Zi4PH4QA"
    . "AAAAAEFVQVRVV1ZTSIHsqAAAAEiLtCQAAQAATIucJAgBAACLrCQQAQAARIusJBgBAABIhfZIi5wkMAEAAA+UwE2F20mJyg+UwUmJ1IuUJCABAAAIyA+FEQEAAE2F5A+ECAEA"
    . "ADHASI18JCC5DAAAAPNIq4uEJCgBAACJbCRgiFQkaIXARIlEJEhMjUQkIA+VwID6ZA++0kyJVCQ4D5TBQQ+v7UyJZCRACchEiUwkTEyJ0Q+2wEiJdCRQD6/ViUQkbEyJXCRY"
    . "RIlsJGRIY8LB+h+JbCRwSGnAH4XrUUjB+CUp0A+2VgGJRCR0D7ZGAsHiCMHgEAnQD7YWCdBBD7ZTAWYPbshBD7ZDAsHiCGYPcMEAweAQDxGEJIAAAAAJ0EEPthMJ0EiNFSns"
    . "//8NAAAA/2YPbtBmD3DCAA8RhCSQAAAAQf+S0AAAAEiF23QGi0QkMIkDSItEJChIgcSoAAAAW15fXUFcQV3DDx9AADHASIHEqAAAAFteX11BXEFdw2YPH0QAAEFWQVRVV1ZT"
    . "TItUJFiLXCR4i7QkgAAAAEiFyQ+E/wAAAE2F0g+E9gAAAItEJGhFMdtECcALRCRgCdAPiNAAAACF2w+O2AAAAIX2D47QAAAARQ+vwUhj0k1jyUhjfCRwSo0sjQAAAABEjUv8"
    . "SMHnAkljwEgB0EhjVCRgSI0MgYtEJGgPr0QkcEiYSAHQSY0UgkSJyMHoAkSNQAH32EnB4ARFjSSBDx9AADHAg/sDD459AAAADx9EAADzD28EAg8RBAFIg8AQTDnAde5KjQQC"
    . "To0UAUWF5HQkRYnhRIswRYkyQYP5AXQVRItwBEWJcgRBg/kCdAeLQAhBiUIIQYPDAUgB6UgB+kQ53n+eQbsBAAAARInYW15fXUFcQV7DDx9AAEUx20SJ2FteX11BXEFew5BB"
    . "idlJicpIidDrnw8fRAAASIPseEyLnCSoAAAASInISIXSD4TYAAAATYXbD4TPAAAAi4wkuAAAAEUx0kQJyQuMJLAAAABECcEPiKcAAABEi5QkyAAAAEWF0g+OoQAAAIuMJNAA"
    . "AACFyQ+OkgAAAEiJVCQwi5QkoAAAAEiJwWYPbowkwAAAAESJRCQ4TI1EJCBmD26UJMgAAACJVCRAZg9uhCSwAAAAi5Qk0AAAAMdEJCAAAAAAZg9unCS4AAAAZg9iykiJRCQo"
    . "iVQkYEiNFV7o//9mD2LDRIlMJDxmD2zBTIlcJEgPEUQkUP+Q0AAAAEG6AQAAAESJ0EiDxHjDDx8ARTHSRInQSIPEeMMPH0QAALgBAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000790 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0008b0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_replace_color  := 0x000950 ; i32 imgutil_replace_color(argb *ptr, i32 width, i32 height, i32 stride, argb cold, argb cnew, i32 tolerance)
    mcode_imgutil_fill           := 0x000a50 ; void imgutil_fill(argb *ptr, i32 width, i32 height, i32 stride, argb c, i32 x, i32 y, i32 w, i32 h)
    mcode_imgutil_grayscale      := 0x000b00 ; void imgutil_grayscale(argb *ptr, i32 width, i32 height, i32 stride)
    mcode_imgutil_make_sat_masks := 0x000b80 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000c90 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x001420 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x0015a0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x0016e0 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x0017e0 ; u32 get_blob_psabi_level()
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                   
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_replace_color",     code + mcode_imgutil_replace_color
                    , "imgutil_fill",              code + mcode_imgutil_fill
                    , "imgutil_grayscale",         code + mcode_imgutil_grayscale
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
    . "" ; 5840 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIyAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
    . "Y9JIAcpJi0sQTI0MkUE5wg+N1QAAAA8fgAAAAABBi1s8g/sDD47LAAAAjWv8MdKJ7sHuAo1OAUjB4QRmkPNBD28EEEEPEQQRSIPCEEg50XXs995JjTwJTAHBjVS1AEGLazhB"
    . "i3MghdJ0HkSLMUSJN4P6AXQTRItxBESJdwSD+gJ0BotRCIlXCEhj1UhjzkGDwgFIweICSMHhAkkB0EkByUQ50HRGg/sDD49v////RYtbPA8fAEWF23QiQYsYQYkZQYP7AXQW"
    . "QYtYBEGJWQRBg/sCdAhBi1gIQYlZCEGDwgFJAdBJAclEOdB/ylteX11BXsMPHwCJ2kyJz0yJwelk////ZmYuDx+EAAAAAABBV0FWQVVBVFVXVlNIg+xIDxF0JDAx0mYPdslI"
    . "iciJ0UG4AQAAAPBED8EAi1AsK1BERDnCD4wyBQAATGNgKESLUEBMi0ggRQ+vxElj0kkp1ItQTEnB5AJNY8BPjQSBT400IIXSD4TWAgAATTnGcrFFjUr88w9vYGBBic9NifNE"
    . "icrzD29YcMHqAo1qAffaSMHlBEWNLJFmLg8fhAAAAAAATInaTCnCSMH6AoPCAYP6A38e6fEBAABmDx+EAAAAAACD6gRJg8AQg/oDD47YAQAA80EPbwBmD2/sZg9v02YP3tBm"
    . "D97oZg90xWYPdNNmD9vCZg92wWYP18iFyXTD8w+8ycH5Akhj0U2NBJBEi0hURItwUEiLcDBIi1g4RTnxD4/PAQAATInBRInPRYX2D4TAAQAARIlMJAhMiUQkEA8fADHSRTHA"
    . "QYP6Aw+OUQEAAJDzD28EEfMPbxQW8w9vLBNmD97QZg/e6GYPdMLzD28UE0iDwhBmD3TVZg/bwmYPdsFmRA/XyPNFD7jJQcH5AkUByEg51XW6SAHuSAHrSAHpRInqhdIPhLkA"
    . "AABmD24pZg9uM2YPbhZmD2/FZg/e1WYP3sZmD3TVZg90xmYP28JmD3bBZkQP18hBg+EBRQHIg/oBdHNmD25pBGYPbnMEZg9uVgRmD2/FZg/e1WYP3sZmD3TVZg90xmYP28Jm"
    . "D3bBZkQP18hBg+EBRQHIg/oCdDdmD25TCGYPbkEIZg9ubghmD2/yZg/e6GYP3vBmD3TFZg901mYP28JmD3bBZkQP18hBg+EBRQHISMHiAkgB1kgB00gB0UQpx0wB4UUp1nQJ"
    . "RDn3D47J/v//RItMJAhMi0QkEIX/fnVJg8AETTnDD4MO/v//RIn56Yb9//9mDx9EAABEidLp+v7//4XSdOZJjQyQZkEPbgBmD2/sZg9v02YP3tBmD97oZg90xWYPdNNmD9vC"
    . "Zg92wWYP19CD4gEPhSn+//9Jg8AESTnIdcVEifnpLf3//0SJz4X/f4tEickp+UiNUBRBugEAAABFidFEhgpFhMl19TlIEA+NZQIAAIlIEEyJQAhEhgo7SFAPjPD8//+LUCyH"
    . "EOnm/P//Zg8fRAAATTnGD4LSAQAARIt4UESLSFRBjXL8SIt4MInyRTn5SIl8JBAPnsNIi3g4RYX/QQ+Vw8HqAkiJfCQYjXoB99pIwecERI0slkSE2w+EsgEAAIlMJCxIiYQk"
    . "kAAAAA8fRAAATIlEJAhIi1wkGEyJwkSJ/kyLXCQQRInNDx+EAAAAAAAxwDHJQYP6Aw+OggEAAGaQ8w9vBALzQQ9vFAPzD28cA2YP3tBmD97YZg90wvMPbxQDSIPAEGYPdNNm"
    . "D9vCZg92wWZED9fA80UPuMBBwfgCRAHBSDnHdblJAftIAftIAfpEieiFwA+EvAAAAGYPbhpmD24jZkEPbhNmD2/DZg/e02YP3sRmD3TTZg90xGYP28JmD3bBZkQP18BBg+AB"
    . "RAHBg/gBdHVmD25aBGYPbmMEZkEPblMEZg9vw2YP3tNmD97EZg9002YPdMRmD9vCZg92wWZED9fAQYPgAUQBwYP4AnQ4Zg9uUwhmD25CCGZBD25bCGYPb+JmD97YZg/e4GYP"
    . "dMNmD3TUZg/bwmYPdsFmRA/XwEGD4AFEAcFIweACSQHDSAHDSAHCKc1MAeJEKdZ0CDn1D47H/v//TItEJAiF7X5WSYPABE05xg+Dkf7//4tMJCxIi4QkkAAAAEiDfCQgAA+E"
    . "+fr//0yLRCQg6c79//8PH4AAAAAASYPABE05xnLaRYXJf/JEic3rFQ8fRAAARInQ6cv+//9Ii4QkkAAAAESJyUyJRCQgKenrrw8QdCQwSIPESFteX11BXEFdQV5BX8NEhgo5"
    . "SFAPj5L6///pnf3//2ZmLg8fhAAAAAAAZpBXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQQYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBF"
    . "D7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJzvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4PH4QA"
    . "AAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj32A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5w33B"
    . "McDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiD"
    . "wgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteww8fALgBAAAAW17DQVdBVkFVQVRVV1ZTSIPsGIusJIgA"
    . "AACLtCSQAAAARQ+vwUiJy4uMJIAAAABJY8BMjTSDTDnzD4O6AAAATGPqQSnRQYnLD7b9ScHlAk1j4UHB6xBED7bRTIlsJAhFD7bbScHkAkUxyU2J72YPH0QAAEiLRCQITI0E"
    . "A0w5w3NcSInaDx+AAAAAAA+2QgIPtkoBRCnYQYnFQffdRA9I6Cn5icj32A9IwQ+2CkE5xUEPTcVEKdFBic1B991ED0jpRDnoQQ9MxTnGfAaJKkGDwQFIg8IETDnCcrFMAftM"
    . "AeNMOfNyjkSJyEiDxBhbXl9dQVxBXUFeQV/DRTHJ6+cPH0QAAFZTi0QkSItUJFhIY1wkQESLRCRQAcJJidtBD6/RSYnKi0wkOEEPr8FIY9JEAdhIAdpImEmNHJJJjRSCSDna"
    . "c2lNY9hFKcFJweMCTWPRScHiAkyJ3g8fQABOjQQaTDnCc0BIidCJCkj30EwBwEjB6AKD4AFJicFIjUIETDnAcx9Nhcl0DIkISI1CCEw5wHMPkIkISIPACIlI/Ew5wHLySAHy"
    . "TAHSSDnacq9bXsMPH0AAV1ZTRQ+vwUmJykljwEiNNIFIOfFzYkEp0Uhj2k1j2UjB4wJBuauqqqpJweMCSInfTY0EGk05wnM3TInSDx9AAA+2SgEPtkICSIPCBAHID7ZK/AHI"
    . "SQ+vwUjB6CEPtsiIQv6IxWaJSvxMOcJy00kB+k0B2kk58nK4W15fww8fQABEi1QkKE2FwInQD5TCTYXJQQ+Uw0QI2g+F4QAAAEiFyQ+E2AAAAEUPttJBadIAAQEARAnSgcoA"
    . "AAD/Zg9u4mYPcNwAg/gDflREjVj8Zg9vyzHARYnaQcHqAkGNUgFIweIEDx+AAAAAAPMPbwQBZg9v0GYP3MFmD9jRQQ8RBAFBDxEUAEiDwBBIOcJ13EH32kgB0UkB0UkB0EON"
    . "BJOFwHReZg9uAWYPb8hmD9zDZg/Yy2ZBD34BZkEPfgiD+AF0P2YPbkEEZg9vyGYP3MNmD9jLZkEPfkEEZkEPfkgEg/gCdB1mD25JCGYPb8FmD9jDZg/c2WZBD35ACGZBD35Z"
    . "CDHAw2ZmLg8fhAAAAAAADx9AAEFXQVZBVUFUVVdWU0iD7FgPEXQkMA8RfCRAi7Qk0AAAAIucJNgAAABNhclNic9IY8JEicJBD5TBRIuEJMgAAABIg7wkwAAAAABBD5TCRQjR"
    . "D4WXAgAASIXJD4SOAgAARYnGRA++yynyRA+v9kWJykUPr9ZNY9pFidFNadsfhetRQcH5H0nB+yVFKctBidGLlCTgAAAAhdIPhYYCAACA+2QPhH0CAABFhckPiD4CAABJY9BJ"
    . "icRmD3bkSSnUScHkAkWF9g+Vw0U53g+dwkjB4AIh00iJRCQISInIid5KjRwhQY1I/InKweoCjXoB99pEjSyRRInKSMHnBEGJ8THJRInWQYnSSInCSDnDD4LGAQAARYTJD4T9"
    . "AQAARIl0JBCJdCQURIkcJIlMJChEiEwkGEiJRCQgRIlUJCwPH4AAAAAAi3QkEIssJEiJ0U2J+UyLlCTAAAAADx8AMcBFMdtBg/gDD47JBAAAZg8fhAAAAAAA8w9vBAHzQQ9v"
    . "DAHzQQ9vFAJmD97IZg/e0GYPdMHzQQ9vDAJIg8AQZg90ymYP28FmD3bEZkQP1/DzRQ+49kHB/gJFAfNIOfh1t0kB+UkB+kgB+USJ6IXAD4TAAAAAZg9uEWZBD24aZkEPbglm"
    . "D2/CZg/eymYP3sNmD3TKZg90w2YP28FmD3bEZkQP1/BBg+YBRQHzg/gBdHhmD25RBGZBD25aBGZBD25JBGYPb8JmD97KZg/ew2YPdMpmD3TDZg/bwWYPdsRmRA/X8EGD5gFF"
    . "AfOD+AJ0OmZBD25KCGYPbkEIZkEPblEIZg9v2WYP3tBmD97YZg90wmYPdMtmD9vBZg92xGZED9fwQYPmAUUB85BIweACSQHBSQHCSAHBRCndTAHhRCnGdAg59Q+OuP7//4Xt"
    . "D475AwAASIPCBEg50w+Di/7//0SLdCQQi3QkFESLHCSLTCQoRA+2TCQYSItEJCBEi1QkLEiLVCQIg8EBSAHQSAHTRDnRD44X/v//MdIPEHQkMA8QfCRASInQSIPEWFteX11B"
    . "XEFdQV5BX8NIg8IESDnTcsCD/mN/8kSJ3emCAwAAQQ+2VwJFD7ZXAUiLnCTAAAAAQcHiCMHiEEQJ0kUPthdECdJED7ZTAWYPbtpIi5QkwAAAAEHB4ghmD3DbAA+2UgLB4hBE"
    . "CdJED7YTRAnSgcoAAAD/Zg9u4mYPcOQARYXJD4hk////SWPQSInFRIl0JBRmD3bSSCnVRInbSMHlAkWF9kEPlcJFOd5MjSwpD53CQSHSQY1Q/ESIVCQsTI0UhQAAAACJ0MHo"
    . "Ao14AffYRI0kgkjB5wQxwGYPb8xJOc0Pgi4CAACJRCQoRA+2XCQsRInKSIlMJBhMiVQkIEiJDCQPH0QAAEyLDCRMiehMKchIwfgCg8ABg/gDfxrpKQIAAA8fRAAAg+gESYPB"
    . "EIP4Aw+OEAIAAPNBD28BZg9v82YPb+lmD97oZg/e8GYPdMZmD3TpZg/bxWYPdsJmD9fIhcl0w/MPvMnB+QJIY8FJjQSBSIkEJIneRYTbD4RpAQAASIsMJESLdCQUiVwkEE2J"
    . "+USIXCQITIuUJMAAAACQMcBFMdtBg/gDD46RAQAAkPMPbwQB80EPbywB80EPbzQCZg/e6GYP3vBmD3TF80EPbywCSIPAEGYPdO5mD9vFZg92wmYP19jzD7jbwfsCQQHbSDn4"
    . "dbpJAflJAfpIAflEieCFwA+EwwAAAGYPbjFmQQ9uOmZBD24pZg9vxmYP3u5mD97HZg907mYPdMdmD9vFZg92wmYP19iD4wFBAduD+AF0fWYPbnEEZkEPbnoEZkEPbmkEZg9v"
    . "xmYP3u5mD97HZg907mYPdMdmD9vFZg92wmYP19iD4wFBAduD+AJ0QWZBD25qCGYPbkEIZkEPbnEIZg9v/WYP3vBmD974Zg90xmYPdO9mD9vFZg92wmYP19iD4wFBAdtmLg8f"
    . "hAAAAAAASMHgAkgBwUkBwUkBwkQp3kgB6UUpxnQJRDn2D46//v//i1wkEEQPtlwkCIX2D47UAAAASIMEJARIiwQkSTnFD4MD/v//i0QkKEiLTCQYQYnRTItUJCCDwAFMAdFN"
    . "AdVEOcgPjrP9///pwPz//w8fAESJwOmN+///Dx+EAAAAAABEicDpuv7//0yJDCSFwHS1SIs0JEiNDIZIifDrDA8fAEiDwARIOch0nGYPbgBmD2/zZg9v6WYP3uhmD97wZg90"
    . "xmYPdOlmD9vFZg92wmZED9fIQYPhAXTISIkEJOnW/f//RIscJEiDvCToAAAAAA+EO/z//0iLhCToAAAAQSnrRIkY6Sj8//9Ig7wk6AAAAABIixQkQYnbD4QS/P//SIuEJOgA"
    . "AABBKfNEiRjp//v//0FVQVRVV1ZTSIHsqAAAAEiLtCQAAQAATIucJAgBAACLrCQQAQAARIusJBgBAABIhfZIi5wkMAEAAA+UwE2F20mJyg+UwUmJ1IuUJCABAAAIyA+FEQEA"
    . "AE2F5A+ECAEAADHASI18JCC5DAAAAPNIq4uEJCgBAACJbCRgiFQkaIXARIlEJEhMjUQkIA+VwID6ZA++0kyJVCQ4D5TBQQ+v7UyJZCRACchEiUwkTEyJ0Q+2wEiJdCRQD6/V"
    . "iUQkbEyJXCRYRIlsJGRIY8LB+h+JbCRwSGnAH4XrUUjB+CUp0A+2VgGJRCR0D7ZGAsHiCMHgEAnQD7YWCdBBD7ZTAWYPbshBD7ZDAsHiCGYPcMEAweAQDxGEJIAAAAAJ0EEP"
    . "thMJ0EiNFUnt//8NAAAA/2YPbtBmD3DCAA8RhCSQAAAAQf+S0AAAAEiF23QGi0QkMIkDSItEJChIgcSoAAAAW15fXUFcQV3DDx9AADHASIHEqAAAAFteX11BXEFdw2YPH0QA"
    . "AEFWQVRVV1ZTTItUJFiLXCR4i7QkgAAAAEiFyQ+E/wAAAE2F0g+E9gAAAItEJGhFMdtECcALRCRgCdAPiNAAAACF2w+O2AAAAIX2D47QAAAARQ+vwUhj0k1jyUhjfCRwSo0s"
    . "jQAAAABEjUv8SMHnAkljwEgB0EhjVCRgSI0MgYtEJGgPr0QkcEiYSAHQSY0UgkSJyMHoAkSNQAH32EnB4ARFjSSBDx9AADHAg/sDD459AAAADx9EAADzD28EAg8RBAFIg8AQ"
    . "TDnAde5KjQQCTo0UAUWF5HQkRYnhRIswRYkyQYP5AXQVRItwBEWJcgRBg/kCdAeLQAhBiUIIQYPDAUgB6UgB+kQ53n+eQbsBAAAARInYW15fXUFcQV7DDx9AAEUx20SJ2Fte"
    . "X11BXEFew5BBidlJicpIidDrnw8fRAAASIPseEyLnCSoAAAASInISIXSD4TYAAAATYXbD4TPAAAAi4wkuAAAAEUx0kQJyQuMJLAAAABECcEPiKMAAABEi5QkyAAAAEWF0g+O"
    . "oQAAAIuMJNAAAACFyQ+OkgAAAEiJVCQwi5QkoAAAAEiJwWYPbowkwAAAAESJRCQ4TI1EJCBmDzoijCTIAAAAAYlUJEBmD26EJLAAAACLlCTQAAAASIlEJChmDzoihCS4AAAA"
    . "AcdEJCAAAAAAiVQkYEiNFX7p//9mD2zBRIlMJDxMiVwkSA8RRCRQ/5DQAAAAQboBAAAARInQSIPEeMMPH4AAAAAARTHSRInQSIPEeMMPH0QAALgCAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x000710 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000830 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_replace_color  := 0x0008d0 ; i32 imgutil_replace_color(argb *ptr, i32 width, i32 height, i32 stride, argb cold, argb cnew, i32 tolerance)
    mcode_imgutil_fill           := 0x0009d0 ; void imgutil_fill(argb *ptr, i32 width, i32 height, i32 stride, argb c, i32 x, i32 y, i32 w, i32 h)
    mcode_imgutil_grayscale      := 0x000a80 ; void imgutil_grayscale(argb *ptr, i32 width, i32 height, i32 stride)
    mcode_imgutil_make_sat_masks := 0x000b00 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000c10 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x001300 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001480 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x0015c0 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x0016c0 ; u32 get_blob_psabi_level()
    ;----------------- end of ahkmcodegen auto-generated section ------------------
    
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_replace_color",     code + mcode_imgutil_replace_color
                    , "imgutil_fill",              code + mcode_imgutil_fill
                    , "imgutil_grayscale",         code + mcode_imgutil_grayscale
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
    . "" ; 6576 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTSInLi0lASItDCA+v0USLiMgAAABBidCJ0DHSQffxMdKJx0KNBAFIY0swQffxi1M0AfoPr1M4SGPSSAHKSItLKEyNFJGLUxxIY0sYAfoPr1MgSGPSSAHKSItLEEyNDJE5"
    . "xw+NowAAAGYPH0QAAItTPIP6Bw+OnAAAAESNQvgx0kSJxsHuA41OAUjB4QWQxMF+bwQSxMF+fwQRSIPCIEg50XXr995NjRwKTAHJQY0U8IP6A34VxMF6bwtIg8EQSYPDEIPq"
    . "BMX6f0nwhdJ0H0WLA0SJAYP6AXQURYtDBESJQQSD+gJ0B0GLUwiJUQhIY1M4g8cBTY0UkkhjUyBNjQyROfgPhWb////F+HdbXl/DDx+AAAAAAEyJyU2J0+uSQVdBVkFVQVRV"
    . "V1ZTSIHs6AAAAMX4EbQkkAAAAMX4EbwkoAAAAMV4EYQksAAAAMV4EYwkwAAAAMV4EZQk0AAAAMXldtvF8XbJSI1UJF/HRCQsAAAAAEiJyEiD4uBIiVQkOLkBAAAA8A/BCItQ"
    . "LCtQRDnKD4wmBgAASGN4KItYQEyLQCAPr89IY9NIKdeLUExIwecCSGPJTY0MiEmNNDlIiXQkEIXSD4SdAwAATDnOcrGNS/jF+m9wYMX6b2BwicrF+m+QgAAAAEyLdCQ4weoD"
    . "xXpvgJAAAABEjWoB99pEjTzRScHlBUiJ8UiJxg8fRAAASInIxMF6fxZMKcjEQXp/RhDEwX5vLkjB+ALEwXp/diCDwAHEwXp/ZjCD+AcPjjUCAADEwX5vfiDrFmYPH0QAAIPo"
    . "CEmDwSCD+AcPjhcCAADEwX5vAcVV3sjFRd7Qxa10wMU1dM3FtdvAxf12w8X919CF0nTL8w+80oPiPEkB0USLXlBMi1YwTItGOItuVEWF2w+EaAIAAEyJykGJ7EQ53Q+PWQIA"
    . "AIlsJAhMiUwkEEiJTCQYDx9AADHAMe2D+wcPjpsBAAAPHwDF/m8EAsTBfd4sAMTBfd48AsTBVXQsAEiDwCDF/XTHxf3bxcX9dsPF/dfI8w+4ycH5AgHNSTnFdcdNAepNAehM"
    . "AepEifiD+AMPjjoBAADF+m8CxMF53ihJg8IQg+gExMF53nrwSYPAEEiDwhDEwVF0aPDF+XTHxfnbxcX5dsHF+dfI8w+4ycH5AoXAD4SwAAAAxfluOsRBeW4IxMF5birFwd7t"
    . "xbHex8WxdMDF0XTvxfnbxcX5dsHFedfIQYPhAUQByYP4AXRtxfluegTEQXluSATEwXluagTFwd7txbHex8WxdMDF0XTvxfnbxcX5dsHFedfIQYPhAUQByYP4AnQ0xfluQgjE"
    . "wXluaAjEwXluegjFUd7Ixfne/8X5dMfFsXTtxfnbxcX5dsHFedfIQYPhAUQByUjB4AJJAcJJAcBIAcIB6UgB+kEpzEEp23QJRTncD46Z/v//i2wkCEyLTCQQSItMJBhFheQP"
    . "jtUAAABJg8EETDnJD4O9/f//SInw6Sb9//8PH0QAADHJ6fr+//9mDx+EAAAAAACJ2Omm/v//xMF6b34gxMF6by6D+AN+LcTBem8BxVHeyMV53tfFqXTAxEFRdMnFsdvAxfl2"
    . "wcX519CF0nVNSYPBEIPoBIXAdJtJjRSBDx9AAMTBeW4BxVHeyMVB3tDFqXTAxTF0zcWx28DF+XbBxfnXwKgBD4Wm/f//SYPBBEk50XXOSInw6Yf8//9m8w+8wmbB6AIPt8BN"
    . "jQyB6YD9//9BiexFheQPjyv///9BietIifBFKeNEiVwkLEiNUBRBuAEAAABEicGGCoTJdfeLfCQsOXgQD425AgAAiXgQTIlICIYKO3hQD4wm/P//i1AshxDpHPz//w8fAEw5"
    . "TCQQD4L2AQAARItAUESLaFREjVv4SItwMESJ2kU5xUEPnsJFhcBIiXQkGEiLcDgPlcHB6gONagH32kiJdCQgSMHlBUWNPNNBhMoPhNEBAABIiYQkMAEAAGYPH0QAAEyJTCQI"
    . "TItcJCBMicpEicZMi1QkGEWJ7DHARTHJg/sHD46yAQAAZpDF/m8EAsTBfd4UA8TBfd4kAsTBbXQUA0iDwCDF/XTExf3bwsX9dsPF/dfI8w+4ycH5AkEByUg5xXXGSQHqSQHr"
    . "SAHqRIn4g/gDD45ZAQAAxfpvAsTBed4TSYPCEIPoBMTBed5i8EmDwxBIg8IQxMFpdFPwxfl0xMX528LF+XbBxfnXyPMPuMnB+QKFwA+EsAAAAMX5biLEwXluK8TBeW4Sxdne"
    . "0sXZ3sXF+XTFxel01MX528LF+XbBxXnX8EGD5gFEAfGD+AF0bcX5bmIExMF5bmsExMF5blIExdne0sXZ3sXF+XTFxel01MX528LF+XbBxXnX8EGD5gFEAfGD+AJ0NMX5bkII"
    . "xMF5blMIxMF5bmIIxene6MX53uTF+XTExel01cX528LF+XbBxXnX8EGD5gFEAfFIweACSQHDSQHCSAHCRAHJSAH6QSnMKd50CUE59A+OmP7//0yLTCQIRYXkflVJg8EETDlM"
    . "JBAPg2f+//9Ii4QkMAEAAEiDfCQwAA+EDPr//0yLTCQw6ar9//+QSYPBBEw5TCQQct5Fhe1/8EWJ7OsaDx8AMcnp2/7//5CJ2OmP/v//SIuEJDABAABFKeVMiUwkMESJbCQs"
    . "66vF+HfF+BC0JJAAAADF+BC8JKAAAADFeBCEJLAAAADFeBCMJMAAAADFeBCUJNAAAABIgcToAAAAW15fXUFcQV1BXkFfw4YKi3wkLDl4UA+PcPn//+lF/f//Zi4PH4QAAAAA"
    . "AFdWU4tcJEhEichIY/JIY1QkQEWJyA+2xEHB6BBBicKLRCRYD6/GSJhIAdBMjRyBi0QkUA+vxkiYSAHQSI0UgUw52nNsRQ+2wEUPttJFD7bJg/4BdBTraWYPH4QAAAAAAEiD"
    . "wgRMOdpzRw+2SgFEKdGJyPfYD0jBD7ZKAkQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45yA9MwTnDfcAxwFteX8NmLg8fhAAAAAAAuAEAAABbXl/DDx+AAAAAAEjB5gLr"
    . "EmYuDx+EAAAAAABIAfJMOdpz2A+2SgJEKcGJyPfYD0jBD7ZKAUQp0YnP998PSc85yA9MwQ+2CkQpyYnP998PSc85yA9MwTnDfcExwOuPZmYuDx+EAAAAAABmkFZTD69UJDiL"
    . "XCRASGPSSInOSGNMJFBEichFicoPtsRBweoQSAHRTI0cjkhjTCRISAHKSI0Ulkw52nNdRQ+20kQPtsBFD7bJ6xAPH4AAAAAASIPCBEw52nM/D7ZKAkQp0YnI99gPSMEPtkoB"
    . "RCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW17DDx8AuAEAAABbXsNBV0FWQVVBVFVXVlNIg+wYi6wkiAAAAIu0JJAAAABFD6/BSInLi4wkgAAAAElj"
    . "wEyNNINMOfMPg7oAAABMY+pBKdFBicsPtv1JweUCTWPhQcHrEEQPttFMiWwkCEUPtttJweQCRTHJTYnvZg8fRAAASItEJAhMjQQDTDnDc1xIidoPH4AAAAAAD7ZCAg+2SgFE"
    . "KdhBicVB991ED0joKfmJyPfYD0jBD7YKQTnFQQ9NxUQp0UGJzUH33UQPSOlEOehBD0zFOcZ8BokqQYPBAUiDwgRMOcJysUwB+0wB40w583KORInISIPEGFteX11BXEFdQV5B"
    . "X8NFMcnr5w8fRAAAVlOLRCRIi1QkWEhjXCRARItEJFABwkmJ20EPr9FJicqLTCQ4QQ+vwUhj0kQB2EgB2kiYSY0ckkmNFIJIOdpzaU1j2EUpwUnB4wJNY9FJweICTIneDx9A"
    . "AE6NBBpMOcJzQEiJ0IkKSPfQTAHASMHoAoPgAUmJwUiNQgRMOcBzH02FyXQMiQhIjUIITDnAcw+QiQhIg8AIiUj8TDnAcvJIAfJMAdJIOdpyr1teww8fQABXVlNFD6/BSYnK"
    . "SWPASI00gUg58XNiQSnRSGPaTWPZSMHjAkG5q6qqqknB4wJIid9NjQQaTTnCczdMidIPH0AAD7ZKAQ+2QgJIg8IEAcgPtkr8AchJD6/BSMHoIQ+2yIhC/ojFZolK/Ew5wnLT"
    . "SQH6TQHaSTnycrhbXl/DDx9AAESLVCQoTYXAidAPlMJNhclBD5TDRAjaD4UGAQAASIXJD4T9AAAARQ+20kFp0gABAQBECdKBygAAAP/F+W7SxOJ9WNKD+Ad+UkSNWPjF/W/K"
    . "McBFidpBweoDQY1SAUjB4gUPH4AAAAAAxf5vHAHF5djBxMF+fwQAxfXcw8TBfn8EAUiDwCBIOcJ13kH32kgB0UkB0UkB0EONBNPF+W/Cg/gDfifF+m8hSYPBEEiDwRBJg8AQ"
    . "g+gExdnYysTBen9I8MXp3MzEwXp/SfCFwHRixfluCcXx2NDF+dzJxMF5fhDEwXl+CYP4AXRHxfluSQTF8djQxfncycTBeX5QBMTBeX5JBIP4AnQpxfluUQjF6djIxfncwsTB"
    . "eX5ICMTBeX5BCMX4dzHAw2YuDx+EAAAAAADF+HcxwMNmLg8fhAAAAAAAQVdBVkFVQVRVV1ZTSIHsyAAAAMX4EXQkQMX4EXwkUMV4EUQkYMV4EUwkcMV4EZQkgAAAAMV4EZwk"
    . "kAAAAMV4EaQkoAAAAMV4EawksAAAAIucJEABAABEi5wkSAEAAEyJjCQoAQAASInISIO8JCgBAAAASGPKQQ+UwkSLjCQ4AQAARInCSIO8JDABAAAAQA+UxkEI8g+F1gIAAEiF"
    . "wA+EzQIAAEWJyEUPvtMp2kQPr8OLnCRQAQAARQ+v0E1j4kSJ1k1p5B+F61HB/h9JwfwlQSn0hdsPhRIDAABBgPtkD4QIAwAAhdIPiIQCAABNY9lJic5EiVQkOMXldttNKd7F"
    . "6XbSScHmAkWFwA+Vw0U54EqNLDBBD53DRCHbRY1Z+EGJ3UiNHI0AAAAARInZwekDRYnqRYnFTIuEJDABAACNcQH32UWNPMuJ0UjB5gVIidpFMduJy0iJwUg5xQ+C+gEAAEWE"
    . "0g+EZQIAAESIVCQYRIlsJAxEiWQkCESJXCQgSIlEJChIiVQkMEiJbCQQiVwkPItsJAyLfCQISInKTInDTIucJCgBAABmLg8fhAAAAAAAMcBFMeRBg/kHD46RBQAAkMX+bwQC"
    . "xf3eDAPEwX3eJAPF9XQMA0iDwCDF/XTExf3bwcX9dsPFfdfQ80UPuNJBwfoCRQHUSDnGdcZJAfNIAfNIAfJEifiD+AMPjjEFAADF+m8CxfneC4PoBEmDwxDEwXneY/BIg8MQ"
    . "SIPCEMXxdEvwxfl0xMX528HF+XbCxXnX0PNFD7jSQcH6AoXAD4SzAAAAxfluIsX5bivEwXluC8XZ3snF2d7Fxfl0xcXxdMzF+dvBxfl2wsV51+hBg+UBRQHqg/gBdHHF+W5i"
    . "BMX5bmsExMF5bksExdneycXZ3sXF+XTFxfF0zMX528HF6XbAxXnX6EGD5QFFAeqD+AJ0OcX5bkIIxfluSwjEwXluYwjF8d7oxfne5MX5dMTF8XTNxfnbwcXpdsDFedfoQYPl"
    . "AUUB6mYPH0QAAEjB4AJJAcNIAcNIAcJFAeJMAfJEKddEKc10CDnvD46V/v//hf8PjuAEAABIg8EESDlMJBAPg17+//9ED7ZUJBhEi2wkDESLZCQIRItcJCBIi0QkKEiLVCQw"
    . "SItsJBCLXCQ8QYPDAUgB0EgB1UE52w+O5/3//8X4dzHJxfgQdCRAxfgQfCRQSInIxXgQRCRgxXgQTCRwxXgQlCSAAAAAxXgQnCSQAAAAxXgQpCSgAAAAxXgQrCSwAAAASIHE"
    . "yAAAAFteX11BXEFdQV5BX8NIg8EESDnNcoyDfCQ4Y3/wSIO8JFgBAAAARInnD4UwBAAAxfh364ZIi7QkKAEAAEQPtlYCRA+2XgFBweIQQcHjCEUJ2kQPth5Ii7QkMAEAAEUJ"
    . "2kQPtl4BxEF5btJED7ZWAkHB4wjEQn1Y0kHB4hBFCdpED7YeRQnaQYHKAAAA/8RBeW7KxEJ9WMmF0g+IFv///01j0cV5f9bFeX/MSYnNxEF5b8LF6XbSxeV2200p1UnB5QJF"
    . "hcBBD5XDRTngSo0sKEEPncJFid9FjVn4RSHXTI0UjQAAAABEidnB6QONeQH32UWNNMtIwecFRTHbxflv/MV9f9XFfX/JSInBSDnFD4JYAgAARIlcJDhIiUQkGEyJVCQgiVQk"
    . "KGaQSInoSCnISMH4AoPAAYP4B38e6YECAABmDx+EAAAAAACD6AhIg8Egg/gHD45oAgAAxf5vAcV13tjFVd7gxZ10wMUldNnFpdvAxf12w8X919CF0nTM8w+80oPiPEgB0USJ"
    . "5kWE/w+EsQEAAESJRCQISInKRInDTIucJDABAABEiWQkDEyLlCQoAQAARIh8JBCQMcBFMf9Bg/kHD47xAQAAkMX+bwQCxEF93hwDxEF93iQCxEEldBwDSIPAIMWddMDFpdvA"
    . "xf12w8V918DzRQ+4wEHB+AJFAcdIOfh1xEkB+kkB+0gB+kSJ8IP4Aw+OjwEAAMX6bwLEQXneG4PoBEmDwhDEQXneYvBJg8MQSIPCEMRBIXRb8MWZdMDFodvAxfl2wsV518Dz"
    . "RQ+4wEHB+AKFwA+EvwAAAMV5biLEQXluK8RBeW4axEEZ3tvEwRnexcWRdMDEQSF03MWh28DF+XbCxXnX4EGD5AFFAeCD+AF0ecV5bmIExEF5bmsExEF5bloExEEZ3tvEwRne"
    . "xcWRdMDEQSF03MWh28DF6XbAxXnX4EGD5AFFAeCD+AJ0PcX5bkIIxEF5blsIxEF5bmIIxSHe6MRBed7kxZl0wMRBIXTdxaHbwMXpdsDFedfgQYPkAUUB4A8fgAAAAABIweAC"
    . "SQHCSQHDSAHCRQH4TAHqRCnGRCnLdAg53g+Ohf7//0SLRCQIRItkJAxED7Z8JBCF9g+OKgEAAEiDwQRIOc0Pg9D9//9Ei1wkOEiLRCQYTItUJCCLVCQoQYPDAUwB0EwB1UE5"
    . "0w+Off3//8X4d+ky/P//ZpBFMdLpAvv//w8fhAAAAAAARInI6a76//8PH4QAAAAAAEUxwOmm/v//Dx+EAAAAAABEicjpUP7//4P4A34sxfpvAcVZ3tjFed7mxZl0wMRBWXTb"
    . "xaHbwMX5dsLF+dfQhdJ1TEiDwRCD6ASFwA+EX////0iNFIEPHwDF+W4BxUHe2MU53uDFmXTAxSF038Wh28DF+XbCxfnXwKgBD4Ve/f//SIPBBEg50XXP6SL///9m8w+8wmbB"
    . "6AIPt8BIjQyB6Tv9//9Ig7wkWAEAAABEi2QkCA+E0Pv//0iLhCRYAQAAQSn8RIkgxfh36UX7//9Ig7wkWAEAAAAPhKv7//9Ii4QkWAEAAEEp9ESJIMX4d+kg+///ZmYuDx+E"
    . "AAAAAAAPHwBBVkFVQVRVV1ZTSIHs0AAAAEiLrCQwAQAATIucJDgBAABEi6QkQAEAAESLtCRIAQAASIu0JGABAABIjVwkP0mJykmJ1YuUJFABAABIg+PgSIXtD5TATYXbD5TB"
    . "CMgPhQUBAABNhe0PhPwAAAAxwLkMAAAASInf80iri4QkWAEAAESJY0CIU0iFwEyJUxgPlcCA+mQPvtJEiUMoD5TBRQ+v5kSJSyxJidgJyEyJWzhMidEPtsBMiWsgQQ+v1IlD"
    . "TEiJazBEiXNESGPCwfofRIljUEhpwB+F61FIwfglKdAPtlUBiUNUD7ZFAsHiCMHgEAnQD7ZVAAnQQQ+2UwHF+W7AQQ+2QwLB4gjE4n1YwMHgEMX+f0NgCdBBD7YTCdBIjRVM"
    . "6v//DQAAAP/F+W7AxOJ9WMDF/n+DgAAAAMX4d0H/ktAAAABIhfZ0BYtDEIkGSItDCEiBxNAAAABbXl9dQVxBXUFeww8fQAAxwOvmDx9AAEFWQVRVV1ZTTItUJFiLXCR4i7Qk"
    . "gAAAAEiFyQ+EJwEAAE2F0g+EHgEAAItEJGhFMdtECcALRCRgCdAPiPkAAACF2w+OAAEAAIX2D474AAAARQ+vwUhj0k1jyUhjfCRwSo0sjQAAAABEjUv4SMHnAkljwEgB0Ehj"
    . "VCRgSI0MgYtEJGgPr0QkcEiYSAHQSY0UgkSJyMHoA0SNQAH32EWNJMFJweAFRTHJZg8fhAAAAAAAMcCD+wcPjqUAAAAPH0QAAMX+bwQCxf5/BAFIg8AgSTnAde1OjRQCSo0E"
    . "AUWJ40GD/AN+FsTBem8KSIPAEEmDwhBBg+sExfp/SPBFhdt0IkWLMkSJMEGD+wF0FkWLcgREiXAEQYP7AnQIRYtSCESJUAhBg8EBSAHpSAH6RDnOf4BBuwEAAADF+HdEidhb"
    . "Xl9dQVxBXsMPHwBFMdtEidhbXl9dQVxBXsNmDx+EAAAAAABBidtIichJidKD+wMPj3L////ri2ZmLg8fhAAAAAAAkEiD7HhMi5wkqAAAAEiJyEiF0g+E2AAAAE2F2w+EzwAA"
    . "AIuMJLgAAABFMdJECckLjCSwAAAARAnBD4ikAAAARIuUJMgAAABFhdIPjqEAAACLjCTQAAAAhckPjpIAAABIiVQkMIuUJKAAAABIicHF+W6UJMAAAABEiUQkOEyNRCQgxONp"
    . "IowkyAAAAAGJVCRAxflunCSwAAAAi5Qk0AAAAEiJRCQoxONhIoQkuAAAAAHHRCQgAAAAAIlUJGBIjRWe5v//xflswUSJTCQ8TIlcJEjF+n9EJFD/kNAAAABBugEAAABEidBI"
    . "g8R4w2YPH0QAAEUx0kSJ0EiDxHjDDx9EAAC4AwAAAMOQkJCQkJCQkJCQ"
    mcode_imgutil_column_uniform := 0x000820 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000940 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_replace_color  := 0x0009e0 ; i32 imgutil_replace_color(argb *ptr, i32 width, i32 height, i32 stride, argb cold, argb cnew, i32 tolerance)
    mcode_imgutil_fill           := 0x000ae0 ; void imgutil_fill(argb *ptr, i32 width, i32 height, i32 stride, argb c, i32 x, i32 y, i32 w, i32 h)
    mcode_imgutil_grayscale      := 0x000b90 ; void imgutil_grayscale(argb *ptr, i32 width, i32 height, i32 stride)
    mcode_imgutil_make_sat_masks := 0x000c10 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000d50 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0015b0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001720 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x0018a0 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x0019a0 ; u32 get_blob_psabi_level()
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform  
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_replace_color",     code + mcode_imgutil_replace_color
                    , "imgutil_fill",              code + mcode_imgutil_fill
                    , "imgutil_grayscale",         code + mcode_imgutil_grayscale
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
    . "" ; 5888 bytes
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
    . "QffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteww8fRAAAuAEAAABbXsNBV0FWQVVBVFVXVlOLRCRoRItcJHhJicpEicmJ00SLTCRwRA+vwU1jwEuN"
    . "FIJJOdIPg8EAAABIY/NBicUp2Q+2/EjB5gJBwe0QSGPZQYn+RQ+27UQPtuBIweMCRTHASIn3xOH5bsJmLg8fhAAAAAAASY0UMkk50nNhTInVSInRkA+2RQJEKehBicdB999B"
    . "D0nHRA+2fQFFKfeJwkSJ+PfYQQ9Ix0QPtn0AOcIPTcJFKedEifr32kQPSfpEOfhBD0zHQTnDfAhEiU0AQYPAAUiDxQRIOc1yqUkB+kkB2sTh+X7ASTnCcolEicBbXl9dQVxB"
    . "XUFeQV/DRTHARInAW15fXUFcQV1BXkFfw2YPH0QAAFZTi0QkSItUJFhIY1wkQESLRCQ4AcJEi1QkUEmJ20EPr9FBD6/BSGPSRAHYSAHaSJhIjRyRSI0UgUg52nN1TWPaRSnR"
    . "ScHjAk1j0UnB4gJMid5mDx9EAABKjQwaSDnKc0pIidBEiQJI99BIAchIwegCg+ABSYnBSI1CBEg5yHMoTYXJdBNEiQBIjUIISDnIcxcPH4AAAAAARIkASIPACESJQPxIOchy"
    . "8EgB8kwB0kg52nKlW17DZi4PH4QAAAAAAFdWU0UPr8FJicpNY8BKjTSBSDnxc2JBKdFIY9pNY9lIweMCQbmrqqqqScHjAkiJ302NBBpNOcJzN0yJ0g8fQAAPtkoBD7ZCAkiD"
    . "wgQByA+2SvwByEkPr8FIweghD7bIiEL+iMVmiUr8TDnCctNJAfpNAdpJOfJyuFteX8MPH0AARItUJChNhcCJ0A+Uwk2FyUEPlMNECNoPhbYAAABIhckPhK0AAABFD7bSQWnS"
    . "AAEBAEQJ0oHKAAAA/2LyfUh80oP4D35YRI1Y8GLx/UhvyjHARYnaQcHqBEGNUgFIweIGYvF/SG8cAWLxZUjYwWLR/kh/BABi8XVI3MNi0f5IfwQBSIPAQEg50HXWSAHBSQHB"
    . "SQHAQcHiBESJ2EQp0IXAdD+6AQAAAMTieffCg+gBxfiSyGLxfslvAWLxfUjYymLxfUjcwmLRfkl/CGLRfkl/AcX4dzHAw2YuDx+EAAAAAADF+HcxwMNmLg8fhAAAAAAAQVdB"
    . "VkFVQVRVV1ZTSIPsOIu0JLAAAABMi5QkyAAAAEyJjCSYAAAASInIRInDTGPaSIO8JJgAAAAAi5QkqAAAAA+UwUSLjCS4AAAASIO8JKAAAAAAQQ+UwEQIwQ+FgQEAAEiFwA+E"
    . "eAEAAInRRQ++wSnzD6/ORA+vwYlMJAhJY8hEicdIackfhetRwf8fSMH5JSn5QYnPi4wkwAAAAIXJD4VUAQAAQYD5ZA+ESgEAAIXbD4grAQAASGPKTYncRI1q8ESJRCQoSSnM"
    . "i0wkCEiJRCQYYvN1SCXJ/0nB5AKJXCQsQb4BAAAARDn5TImUJMgAAABKjSwgQQ+dwYXJD5XBQSHJSo0MnQAAAABFMdtIiUwkIESJ6cHpBESITCQQjXkBweEERIlcJAxBKc1I"
    . "wecGRIlsJARIi0QkGEmJwUg5xQ+CfAQAAIB8JBAAdBLpZQMAAEmDwQRMOc0PgmMEAACDfCQoY3/sTIuUJMgAAABEif5NhdIPha4EAADF+HfrZ4XAdDfEwnn3xoPoAcX4kshi"
    . "0X7JbwFi831IPtUFYvN9Sj7EAmLyfkgowGLzfUkfwQDF+JjAD4WuAQAASItEJBBMi1wkGESLRCQgi1wkKEGDwAFMAdhMAd1BOdgPjvgAAADF+HdFMclMichIg8Q4W15fXUFc"
    . "QV1BXkFfw0iLtCSYAAAASIuMJJgAAABED7ZGAQ+2SQJBweAIweEQRAnBRA+2BkiLtCSgAAAARAnBRA+2RgFi8n1IfOlIi4wkoAAAAEHB4AgPtkkCweEQRAnBRA+2BkQJwYHJ"
    . "AAAA/2LyfUh84YXbD4h4////SGPKTYncRI1q8ESJfCQMSSnMi0wkCEyJlCTIAAAAQb4BAAAAScHkAmLzdUglyf+FyUqNLCBBD5XARDn5D53BScHjAkEhyESIRCQsSYnARIno"
    . "wegEjXgBweAEQSnFMcBIwecGRIlsJASJwUyJwEGJyEmJwWLx/Uhv3WLx/Uhv1Eg5xQ+C3f7//0iJRCQQD7ZMJCxMiVwkGESJRCQgiVwkKGYPH4QAAAAAAEiJ6EwpyEjB+AKD"
    . "wAGD+A9/HulX/v//Zg8fhAAAAAAAg+gQSYPBQIP4Dw+OPv7//2LRf0hvAWLzfUg+ywVi831JPsoCYvJ+SCjBYvN9SB/BAMX4mMB0ycX4k8Bm8w+8wIt0JAwPt8BNjQyBhMkP"
    . "hPAAAABIi5wkoAAAAEyLnCSYAAAATYnIRItUJAiLdCQMkDHARTH/g/oPD44AAQAAZpBi0X9IbwQAYtN9SD4MAwVi831JPgwDAkiDwEBi8n5IKMFi831IH/EAxXiT7vNFD7jt"
    . "RQHvSDn4dcdIY0QkBEkB+0kB+EgB+4XAD4SRAAAAxEJ59+5Bg+0BSMHgAkEp0sTBe5LNYtF+yW8AYsF+yW8DSQHDYuF+yW8LSAHDTAHgYrN9SD7QBUkBwGKzfUo+0QJi8n5I"
    . "KMJi831IH8EAxfxB6cV4k+1m80UPuO1FD7ftRQH9RCnuQTnyfAlFhdIPhS3///+F9g+OugEAAEmDwQRMOc0Pg4j+///pLP3//w8fAEQp/k0B4EEp0nTYRDnWf9MxwEUx/4P6"
    . "Dw+PAv///0hjwulB////SInpDx+AAAAAAEiLnCSgAAAARItUJAhNichEif5Mi5wkmAAAAA8fRAAAMcBFMe2D+g8PjiABAABmkGLRf0hvJABi011IPgwDBWLzXUk+DAMCSIPA"
    . "QGLyfkgowWLzfUgf2QDF+JPr8w+47UEB7Ug5+HXISGNEJARJAftJAfhIAfuFwA+EsgAAAMTCeffug+0BSMHgAkEp0sX7ks1i0X7JbwBi0X7JbxtJAcNi8X7JbxNIAcNMAeBi"
    . "831IPtMFSQHAYvN9Sj7SAmLyfkgowmLzfUgfwQDF/EHhxfiT7GbzD7jtD7ftRAHtKe5EOdZ/CUWF0g+FM////4X2fmVJg8EETDnJD4MC////SInNSIt0JCCDRCQMAYtMJCyL"
    . "RCQMSAF0JBhIAfU5yA+OUfv//8X4d+n3+///Dx9EAABEKe5NAeBBKdJ0skQ51n+tMcBFMe2D+g8Pj+L+//9IY8LpIP///0yLlCTIAAAATYXSD4RS+///QSn3RYk6xfh36bD7"
    . "//9Mi5QkyAAAAESLfCQMTYXSD4Qu+///RIn4KfBBiQLF+Hfpivv//w8fRAAAQVVBVFVXVlNIgexYAQAATIucJLABAABMi5QkuAEAAIu8JMABAABEi6QkyAEAAIuEJNABAABI"
    . "i7Qk4AEAAEiNXCRfSIPjwE2F20APlMVNhdJBD5TFRAjtD4UDAQAASIXSD4T6AAAAxfnvwGLxf0h/QwFIiVNAi5Qk2AEAAESJQ0iF0ol7YA+VwjxkiENoD77AQQ+UwEEPr/xi"
    . "8X9IfwNECcJIiUsYSYnYD7bSRIlLTA+vx4lTbEyJW1BMiVNYSGPQwfgfRIljZEhp0h+F61GJe3BIwfolKcJBD7ZDAolTdEEPtlMBweAQweIICdBBD7YTCdBBD7ZSAWLyfUh8"
    . "wEEPtkICYvF+SH9DAsHiCMHgEAnQQQ+2EgnQSI0V8uz//w0AAAD/YvJ9SHzAYvF+SH9DA8X4d/+R0AAAAEiF9nQFi0MQiQZIi0MISIHEWAEAAFteX11BXEFdw2YPH4QAAAAA"
    . "ADHASIHEWAEAAFteX11BXEFdw2ZmLg8fhAAAAAAADx8AQVVBVFVXVlNIi1wkWESLVCR4RIucJIAAAABIhckPhAUBAABIhdsPhPwAAACLRCRoMfZECcALRCRgCdAPiLEAAABF"
    . "hdIPjt4AAABFhdsPjtUAAABFD6/BSGPSQY1y8E1jyUqNLI0AAAAAQbwBAAAARTHJSWPASAHQSGNUJGBIjQyBi0QkaA+vRCRwSJhIAdBIjRSDifBIY1wkcMHoBESNQAHB4ARI"
    . "weMCScHgBinGZpAxwEGD+g8PjnwAAAAPH0AAYvH+SG8MAmLx/kh/DAFIg8BASTnAdemF9nUlQYPBAUgB6UgB2kU5y3/GvgEAAADF+HeJ8FteX11BXEFdww8fAE6NLAJKjTwB"
    . "ifDEwnn3xIPoAcX4kshi0X7Jb0UAYvF+SX8H67YPHwAx9onwW15fXUFcQV3DDx8ARInQSInPSYnV68dmZi4PH4QAAAAAAGaQSIPseEyLnCSoAAAASIXSD4TTAAAATYXbD4TK"
    . "AAAAi4QkuAAAAEUx0kQJyAuEJLAAAABECcAPiKEAAABEi5QkyAAAAEWF0g+OnAAAAIuEJNAAAACFwA+OjQAAAIuEJKAAAABIiVQkMEiNFaLp///F+W6UJMAAAABEiUQkOEyN"
    . "RCQgxONpIowkyAAAAAGJRCRAxflunCSwAAAAi4Qk0AAAAEiJTCQoxONhIoQkuAAAAAHHRCQgAAAAAESJTCQ8xflswUyJXCRIiUQkYMX6f0QkUP+R0AAAAEG6AQAAAESJ0EiD"
    . "xHjDDx9AAEUx0kSJ0EiDxHjDZmYuDx+EAAAAAABmkLgEAAAAw5CQkJCQkJCQkJA="
    mcode_imgutil_column_uniform := 0x0007c0 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0008e0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_replace_color  := 0x000980 ; i32 imgutil_replace_color(argb *ptr, i32 width, i32 height, i32 stride, argb cold, argb cnew, i32 tolerance)
    mcode_imgutil_fill           := 0x000a90 ; void imgutil_fill(argb *ptr, i32 width, i32 height, i32 stride, argb c, i32 x, i32 y, i32 w, i32 h)
    mcode_imgutil_grayscale      := 0x000b50 ; void imgutil_grayscale(argb *ptr, i32 width, i32 height, i32 stride)
    mcode_imgutil_make_sat_masks := 0x000bd0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000cc0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x001320 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x0014a0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x0015f0 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x0016f0 ; u32 get_blob_psabi_level()
    ;----------------- end of ahkmcodegen auto-generated section ------------------
                                                
        static code := this.i_b64decode(b64)
        return Map(   "imgutil_column_uniform",    code + mcode_imgutil_column_uniform
                    , "imgutil_row_uniform",       code + mcode_imgutil_row_uniform
                    , "imgutil_replace_color",     code + mcode_imgutil_replace_color
                    , "imgutil_fill",              code + mcode_imgutil_fill
                    , "imgutil_grayscale",         code + mcode_imgutil_grayscale
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
