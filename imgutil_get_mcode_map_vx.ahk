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
    . "" ; 7040 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=core2 -D MARCH_x86_64_v0 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VlNEi0FASItBCEhjcSBBD6/QRIuQyAAAAEGJ0YnQMdJB9/Ix0kGJw0ONBAhEi0E0QffySGNROExjSTBMY1EYRQHYRA+vwk1jwE0ByEyLSShPjQSBRItJHEUB2UQPr85NY8lN"
    . "AdFMi1EQT40MikE5w31GRItRPEiNHJUAAAAASMHmAkWF0nQxZg8fhAAAAAAAMdJmDx9EAABBiwyQQYkMkUiDwgFMOdJ170GDwwFJAdhJAfFEOdh12Fteww8fRAAAV1ZTi1wk"
    . "SESJyEhj8kiJz0hjTCRAD7bERYnIQYnCi0QkWEHB6BAPr8ZImEgByEyNHIeLRCRQD6/GSJhIAchIjQyHTDnZc2mD/gFFD7bARQ+20kUPtsl0EetmZg8fRAAASIPBBEw52XNH"
    . "D7ZBAUQp0Jkx0CnQD7ZRAkQpwonWwf4fMfIp8jnQD0zCD7YRRCnKidbB/h8x8inyOdAPTMI5w32+McBbXl/DDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusSZi4PH4QA"
    . "AAAAAEgB8Uw52XPYD7ZBAkQpwJkx0CnQD7ZRAUQp0onXwf8fMfop+jnQD0zCD7YRRCnKidfB/x8x+in6OdAPTMI5w32/McDrj2ZmLg8fhAAAAAAAVlMPr1QkOItcJEBIY9JI"
    . "ic5IY0wkUEWJykSJyEHB6hAPtsRIAdFMjRyOSGNMJEhIAcpIjQyWTDnZc2VFD7bSRA+2wEUPtsnrEA8fgAAAAABIg8EETDnZc0cPtkECRCnQmTHQKdAPtlEBRCnCidbB/h8x"
    . "8inyOdAPTMIPthFEKcqJ1sH+HzHyKfI50A9MwjnDfb4xwFtew2YPH4QAAAAAALgBAAAAW17DDx+EAAAAAABBV0FWQVVBVFVXVlNIgey4AgAADxG0JBACAAAPEbwkIAIAAEQP"
    . "EYQkMAIAAEQPEYwkQAIAAEQPEZQkUAIAAEQPEZwkYAIAAEQPEaQkcAIAAEQPEawkgAIAAEQPEbQkkAIAAEQPEbwkoAIAAE2FwEmJyonXi5QkIAMAAA+UwE2FyQ+UwQjID4VN"
    . "CAAATYXSD4RECAAAD7bSRGniAAEBAEEJ1EGBzAAAAP9EieBFieZEieZBwe4QD7bEhf9BicNEifMPjhIIAACD/xAPjnQHAABFD7bkRQ+29kUPtuvzRA9vPUwXAABMieBMifFM"
    . "ierzRA9vNUoXAACNb/9IweAIZg/v/2ZFD3bbSMHhCEwJ8EjB4gjzRA9vLTYXAABMCelIweAITAni80QPbyVjFwAASMHhCEwJ6EjB4ghMCeFIweAITAnySMHhCEwJ4EwJ8UjB"
    . "4AhIweEITAnwTAnpSMHgCEjB4QhMCehMCeFIweAISMHhCEwJ4EwJ8UjB4AhIweEITAnwTAnpSMHiCEiJBCRMCepIiUwkCEjB4ghIiUwkEEyJ0UwJ4kiJRCQoTInISMHiCEwJ"
    . "8kjB4ghMCepIweIITAniQYnsQcHsBEiJVCQYScHkBkiJVCQgTInCTQHUDx9EAADzD28xSIPBQEiDwkBIg8BA8w9vUdBmDzgANcIVAADzD29p4GYPb8LzD29kJCBmDzgAFcoV"
    . "AABmDzgABbEVAABmD+vwZg9vxWYPOAAt0BUAAGYP/ObzD29cJBBmRA9v1mYPOAAFqBUAAGYP69DzD29B8GZED/hUJCBmRA9vymYP/NrzD28MJGZED/hMJBBmDzgABZoVAABm"
    . "D+voZg9vxmZED2/FZg/YxGYP/M1mD3THZkQP+AQkZg/b4GZBD9/DZg/rxGYPb+JmD9jjZg9052YP29xmQQ/f42YP6+NmD2/dZg/Y2WYPdN9mD9vLZkEP39tmD+vZZkEPb8pm"
    . "D9jOZkEPb/FmD3TPZg/Y8mZBD2/QZg/Y1WYPdPdmD3TXZkEP28pmRA/F6QBmRIlqwGYPb+kPEYwkAAIAAGZBD9vxRA+2rCQCAgAAZg84AC3yFAAAZkEP29BEiGrCZkQPxe0A"
    . "Zg9v6WZEiWrEZkEPOADvDxGMJPABAABED7asJPUBAABEiGrGZkQPxekDZkSJasgPEYwk4AEAAEQPtqwk6AEAAESIaspmRA/F7QBmD2/uZkSJasxmQQ84AO0PEYwk0AEAAEQP"
    . "tqwk2wEAAESIas5mRA/F6QZmRIlq0A8RjCTAAQAAZkEPOADORA+2rCTOAQAAZg/rzUSIatJmRA/F6QBmD2/OZg84AA14FAAAZkSJatQPEbQksAEAAEQPtqwksQEAAESIatZm"
    . "RA/F7gFmRIlq2A8RtCSgAQAARA+2rCSkAQAARIhq2mZED8XpAGYPb85mDzgADTsUAABmRIlq3A8RtCSQAQAARA+2rCSXAQAARIhq3mZED8XuBGZEiWrgDxG0JIABAABED7as"
    . "JIoBAABEiGriZkQPxekAZg9vymYPOAAN/hMAAGZEiWrkDxG0JHABAABED7asJH0BAABEiGrmZkQPxe4HZkSJauhmQQ9+1USIaupmRA/F6QBmD2/KZkSJauxmQQ84AMwPEZQk"
    . "YAEAAEQPtqwkYwEAAESIau5mRA/F6gJmRIlq8A8RlCRQAQAARA+2rCRWAQAARIhq8mZED8XpAGYPb8pmDzgADZMTAABmRIlq9A8RlCRAAQAARA+2rCRJAQAARIhq9mZED8Xq"
    . "BWZEiWr4DxGUJDABAABED7asJDwBAABEiGr6ZkQPxekAZg9vyGZEiWr8DxGUJCABAABED7asJC8BAADGQsMAxkLHAMZCywBEiGr+ZkQPxegAxkLPAMZC0wDGQtcAxkLbAMZC"
    . "3wDGQuMAxkLnAMZC6wDGQu8AxkLzAMZC9wDGQvsAxkL/AGYPOAANZhIAAGZEiWjADxGEJBABAABED7asJBIBAABEiGjCZkQPxekAZg9vyGZEiWjEZkEPOADPDxGEJAABAABE"
    . "D7asJAUBAABEiGjGZkQPxegDZkSJaMgPEYQk8AAAAEQPtqwk+AAAAESIaMpmRA/F6QBmD2/MZkSJaMxmQQ84AM0PEYQk4AAAAEQPtqwk6wAAAESIaM5mRA/F6AZmRIlo0A8R"
    . "hCTQAAAAZkEPOADGRA+2rCTeAAAAZg/rwUSIaNJmRA/F6ABmD2/EZg84AAXbEQAAZkSJaNQPEaQkwAAAAEQPtqwkwQAAAESIaNZmRA/F7AFmRIlo2A8RpCSwAAAARA+2rCS0"
    . "AAAARIho2mZED8XoAGYPb8RmRIlo3A8RpCSgAAAARA+2rCSnAAAAZg84AAWIEQAARIho3mZED8XsBGZEiWjgDxGkJJAAAABED7asJJoAAABEiGjiZkQPxegAZg9vw2YPOAAF"
    . "YREAAGZEiWjkDxGkJIAAAABED7asJI0AAABEiGjmZkQPxewHZkSJaOhmQQ9+3USIaOpmRA/F6ABmD2/DZkSJaOxmQQ84AMQPEVwkcEQPtmwkc0SIaO5mRA/F6wJmRIlo8A8R"
    . "XCRgRA+2bCRmRIho8mZED8XoAGYPb8NmDzgABQIRAABmRIlo9A8RXCRQRA+2bCRZRIho9mZED8XrBWZEiWj4DxFcJEBED7ZsJExEiGj6ZkQPxegAZkSJaPwPEVwkMEQPtmwk"
    . "P8ZAw//GQMf/xkDL/0SIaP7GQM//xkDT/8ZA1//GQNv/xkDf/8ZA4//GQOf/xkDr/8ZA7//GQPP/xkD3/8ZA+//GQP//TDnhD4Wx+f//g+Xwiegp70jB4AJJAcJJAcBJAcGN"
    . "R/8x/0mNbIEEDx8AQQ+2CkHGQQP/RQ+2egFBxkADAEUPtmoCQYnMQSj0RIn6RA9C50Qo2kEPtsRBidRED0LnRIniRYnsQSjciNREifpED0LnQADxZkGJAESJ6EUY9kQJ8UQA"
    . "2kWIYAJFGPZBiAlECfIA2EGIUQEY0kmDwQRJg8IECdBJg8AEQYhB/kw5zQ+FeP///w8QtCQQAgAAMcAPELwkIAIAAEQPEIQkMAIAAEQPEIwkQAIAAEQPEJQkUAIAAEQPEJwk"
    . "YAIAAEQPEKQkcAIAAEQPEKwkgAIAAEQPELQkkAIAAEQPELwkoAIAAEiBxLgCAABbXl9dQVxBXUFeQV/DZi4PH4QAAAAAAEFXQVZBVUFUVVdWU0iB7BgBAAAPEXQkcA8RvCSA"
    . "AAAARA8RhCSQAAAARA8RjCSgAAAARA8RlCSwAAAARA8RnCTAAAAARA8RpCTQAAAARA8RrCTgAAAARA8RtCTwAAAARA8RvCQAAQAARIusJIgBAACLnCSQAQAAi7QkmAEAAESL"
    . "nCSgAQAATYXJSInISGPKD5TCRYnCTIuEJKgBAABIg7wkgAEAAABBD5TBRAjKD4UNCQAASIXAD4QECQAARYnuQA++1kQPr/NBD6/WRIl0JEhMY8rB+h9NackfhetRScH5JUWJ"
    . "z0Ep10CA/mRIi7QkgAEAALoBAAAARA9E2kSJfCQ8D7ZWAkQPtk4BweIQQcHhCEQJykQPtg5ECcqBygAAAP9BKdqJ10SJVCRkD4iPCAAASInKTWPNSIlEJEBmD+/ATCnKRTn+"
    . "TImEJKgBAABmD2/wSI00jQAAAAAPncFFhfbzRA9vPfcNAABIjRyVAAAAAA+Vwol8JExmDzgANQ8OAABMjSQYIdFIiVwkWESJ602J4EGJykyLpCSoAQAAMclBjVX/SIn3Zg/W"
    . "dCQIidBEiZwkoAEAAMHoBEjB4AZIiUQkGInQg+DwTI08hQAAAAApw4lEJDiJ0EyNNIUEAAAAiVwkFEyJ/kyJdCRoQYnWSItEJEBJOcBIicIPgqoHAABEi4wkoAEAAEWFyQ+E"
    . "HggAAItEJEwPtuyJw8HoEIlsJCBBicFEifVMicBEi3QkIEgp0EjB+AKD+P8PjFwHAACDwAFIiVQkKEyNfIIESInQ6w1Ig8AETDn4D4Q4BwAARDpIAkEPk8NEOnABD5PCQYTT"
    . "dN86GHLbQYnuSInDSItUJFhIiXwkUEiJ90iLRCRoiUwkYESJ9kiJ2USIVCQoSYn+TIlEJDBMiaQkqAEAAIB8JCgAi2wkPA+EbQYAAEiLvCSAAQAASInLSIlMJCBEi2QkSIts"
    . "JDzzRA9+NYMMAAAPHwBFhe0PjikGAACD/g8PhosGAABMi3wkGEiJ+UmJ2GZFD+/tZkUP7+RNjQw/Dx9EAADzQQ9vEGZBD2/PZkEPb8dmQQ9v//NFD29QEGZBD2/3ZkUPb99I"
    . "g8FA80EPb2ggZg/bymYPcdIISYPAQPNFD29I8GZBD9vCZg9nyGZBD2/H80QPb0HQZg/b/WZBD3HSCGZBD9vB8w9vWcBmQQ9x0QhmD2f4Zg9x1QjzD29h4GZBD2fSZkEP29fz"
    . "D29B8GZBD2fpZkQPb8pmQQ/b8PMPb1HAZkEP299mD2feZkEPb/dmD9v0ZkQP29hmQQ9x0AhmQQ9n82YPcdAIZkEP2+9mRA9nzUk5yWYPcdIIZg9v7mZBD9v3Zg9x1AhmQQ9n"
    . "0GZBD9vXZg9n4GYPb8FmQQ/b52YPZ9RmD2/nZg9x0AhmQQ/b/2ZBD9rRZg9x1AhmQQ/bz2YPZ89mD+//Zg9nxGYPb+NmD3HVCGZBD9vfZg9x1AhmD2feZg/a2WYPZ+VmD9rg"
    . "Zg90y2YPdMRmQQ900WYP29BmD9vRZg/bFfUKAABmD2/CZg9gx2YPb8hmD2jXZkEPacRmQQ9hzGYP/sFmD2/KZkEPadRmQQ9hzGYP/tFmD/7CZkQP/ugPhVb+//9Ei0QkOE6N"
    . "FDdmQQ9vxWYPc9gIRIt8JBROjQwzZkEP/sVmD2/IZg9z2QRmD/7BZg9+wUEPEsVmRA/+6EGJ80Upw0GD+wcPhioCAABJweACZkEPb85mQQ9vxkqNDANmQQ9v/kkB+PMPfhFm"
    . "QQ9v3mZBD2/2ZkUPb9bzRA9+YQhBg+P48w9+aRBmD9vKZg9x0ghFKd/zRA9+WRhmQQ/bxGYPZ8hmQQ9vxvNFD35ICGYP2/1mQQ9x1AhmD3DJCGZBD9vDZg9n+PNBD34AZg9x"
    . "1QjzQQ9+YBBmQQ/b8WZBD2fUZkEPcdMI80UPfkAYZg/b2GYPZ95mQQ9v9mYP2/RmD3HQCGYPcNIIZkEPZ+tmRQ/b0GZBD3HRCGYPcO0IZkEP29ZmD3HUCGZBD9vuZkEPZ8Fm"
    . "D2fVZkEPcdAIZg9w0ghmD3DACGZBD9vGZkEPZ+BmD3DkCGZBD9vmZg9nxGYPcMAIZg/awmYPcP8IZg9v52YPdMJmD2/RZg9w2whmQQ9n8mYPcdQIZg9w9ghmD2/uZkEP2/5m"
    . "D3HSCGZBD9v2ZkEP285mD2fPZg9n1GYPb+NJweMCZg9x1QhmD3HUCGYPcNIITQHaZg9wyQhmD2flZkEP295mD3DkCE0B2WYPZ95mD9riZg9w2whmD9rZZg901GYP7+3zD358"
    . "JAjzD341tggAAGYPdMtmD+/bZg/bwmYP28hmD9vOZg9v0WYPYMtmD2DTZg9wyU5mD2/ZZg9vwWYPb8pmD2HdZg9hxWYPYdVmD2HNZg9wwE5mD3DSTmYP/sNmD/7RZg/+wmZB"
    . "D/7FZg9vyGYPOAANXQgAAGYP689mD/7BZg9+wUUPtlkCRThaAkUPtlkBQQ+TwEU4WgFBD5PDRSHDRQ+2AUU4AkEPk8BFD7bARSHYRAHBQYP/AQ+EnwEAAEUPtlkFRThaBUUP"
    . "tlkGQQ+TwEU4WgZBD5PDRSHDRQ+2QQRFOEIEQQ+TwEUPtsBFIdhEAcFBg/8CD4RhAQAARQ+2WQpFOFoKRQ+2WQlBD5PARThaCUEPk8NFIcNFD7ZBCEU4QghBD5PARQ+2wEUh"
    . "2EQBwUGD/wMPhCMBAABFD7ZZDkU4Wg5FD7ZZDUEPk8BFOFoNQQ+Tw0Uhw0UPtkEMRThCDEEPk8BFD7bARSHYRAHBQYP/BA+E5QAAAEUPtlkSRThaEkUPtlkRQQ+TwEU4WhFB"
    . "D5PDRSHDRQ+2QRBFOEIQQQ+TwEUPtsBFIdhEAcFBg/8FD4SnAAAARQ+2WRZFOFoWRQ+2WRVBD5PARThaFUEPk8NFIcNFD7ZBFEU4QhRBD5PARQ+2wEUh2EQBwUGD/wZ0bUUP"
    . "tlkaRThaGkUPtlkZQQ+TwEU4WhlBD5PDRSHDRQ+2QRhFOEIYQQ+TwEUPtsBFIdhEAcFBg/8HdDNFD7Z5HkU4eh5FD7Z5HUEPk8BFOHodRQ+2eRxBD5PDRTHJRSHYRTh6HEEP"
    . "k8FFIcFEAclIAcNIAccpzUgB00Up7HQJQTnsD429+f//SItMJCCF7Q+OSAEAAEiDwQRIOUwkMA+CDwEAAESLhCSgAQAARYXAD4Rc+f//TInwSInKQYn2SIt8JFBED7ZUJChI"
    . "icZMi0QkMItMJGBMi6QkqAEAAOmT+P//SYnZSYn6RYnvZkUP7+1FMcAxyelg+///SItUJChIAfpJOdAPg4D4//9Bie6LRCRkg8EBSQH4SAF8JEA5wQ+OLvj//zHJDxB0JHBI"
    . "icgPELwkgAAAAEQPEIQkkAAAAEQPEIwkoAAAAEQPEJQksAAAAEQPEJwkwAAAAEQPEKQk0AAAAEQPEKwk4AAAAEQPELQk8AAAAEQPELwkAAEAAEiBxBgBAABbXl9dQVxBXUFe"
    . "QV/DSYnB6wgPH0QAAEyJyE2FyXVXTI0MOE05yHPv6Vv///9MifBIi3wkUEGJ9otMJGBIicZED7ZUJChMi0QkMEyLpCSoAQAA6TH///9Mi4QkqAEAAE2FwA+EOf///4tEJDwp"
    . "6EGJAOkr////TInI6dn3//+QVlNIg+xox0QkXAAAAABIjXQkXEiJy+tPDx+EAAAAAACLUyhIi0sgSIl0JEgPr8JImEiNDIGLQ0yJRCRAD75DSESJRCQwiUQkOItDQIlEJChI"
    . "i0M4SIlEJCBMi0sw6P70//9IhcB1IbgBAAAA8A/BA0SLQ0SLUyxEKcI5wn2iSIPEaFteww8fAEiNUxRBuAEAAABmDx9EAABEicGGCoTJdfdEi0QkXEQ5QxB9CESJQxBIiUMI"
    . "hgqLQ0APr0NEO0QkXH+ki0MshwPrnWYPH0QAAFNIg+xwZg9uhCS4AAAAZg9ujCSwAAAARIuUJMAAAABmD2LISIucJNAAAABIichmQQ9u6WZID27iSIuMJKAAAABmSA9u2GZB"
    . "D27AZg9s3GYPYsVIhclmSA9u0Q+UwQ8WlCSoAAAASIO8JKgAAAAAQQ+UwUQIyXV5SIXSdHSLlCTIAAAADxFcJDhMjUQkIEiJwcdEJCAAAAAASMdEJCgAAAAASMdEJDAAAAAA"
    . "iVQkbEiNFXv+//9mD9ZEJEgPEVQkUGYP1kwkYESIVCRo/5DQAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbw2YPH4QAAAAAADHASIPEcFvDDx+EAAAAAABWU0yLVCQ4i3QkYEiF"
    . "yQ+EtAAAAE2F0g+EqwAAAItEJEhFMdtECcALRCRACdAPiIoAAACLRCRYhcAPjokAAACF9g+OgQAAAEUPr8FIY9JNY8lKjRyNAAAAAEljwEgB0EhjVCRATI0EgYtEJEgPr0Qk"
    . "UEiYSAHQSY0MgkhjRCRQRItUJFhMjQyFAAAAAA8fQAAxwGYPH0QAAIsUgUGJFIBIg8ABSTnCdfBBg8MBSQHYTAHJRDnef9lBuwEAAABEidhbXsMPH0QAAEUx20SJ2Ftew2Zm"
    . "Lg8fhAAAAAAADx9AAEiD7HhMi5wkqAAAAEiF0kiJyA+E6AAAAE2F2w+E3wAAAIuMJLgAAABFMdJECckLjCSwAAAARAnBD4i6AAAARIuUJMgAAABFhdIPjrEAAACLjCTQAAAA"
    . "hckPjqIAAABmSA9u0ouUJKAAAABmSA9uwGZBD27ZZg9swg8RRCQoSInBZkEPbsBmD2LDZg/WRCQ4Zg9ujCTAAAAATI1EJCBmD26kJMgAAADHRCQgAAAAAGYPboQksAAAAIlU"
    . "JECLlCTQAAAAZg9izEyJXCRIZg9urCS4AAAAZg9ixWYPbMEPEUQkUIlUJGBIjRXk5f///5DQAAAAQboBAAAARInQSIPEeMNFMdJEidBIg8R4ww8fRAAAMcDDZmYuDx+EAAAA"
    . "AABmkAABAgQFBggJCgwNDoCAgICAgICAgICAgICAgIAAAQIEBQYICQoMDQ6AgICAgICAgICAgICAgICAAAECBAUGCAkKDA0OgICAgICAgICAgICAgICAgAABAgQFBggJCgwN"
    . "DgMEAgMEBQYHCAkKCwwNDg8JCgIDBAUGBwgJCgsMDQ4PD4CAgICAgICAgICAgICAgIAAAgMEBQYHCAkKCwwNDg8FBgIDBAUGBwgJCgsMDQ4PCwwCAwQFBgcICQoLDA0ODwEC"
    . "AgMEBQYHCAkKCwwNDg8HCAIDBAUGBwgJCgsMDQ4PDQ4CAwQFBgcICQoLDA0OD/8A/wD/AP8A/wD/AP8A/wABAQEBAQEBAQEBAQEBAQEBBAUGB4CAgICAgICAgICAgICAgIAA"
    . "AQIDgICAgICAgIA="
    mcode_imgutil_column_uniform := 0x0000c0 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x0001e0 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000290 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000be0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x001750 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x001850 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x001930 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x001a40 ; u32 get_blob_psabi_level()
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
    . "" ; 3360 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64 -D MARCH_x86_64_v1 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIyAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
    . "Y9JIAcpJi0sQTI0MkUE5wg+N1QAAAA8fgAAAAABBi1s8g/sDD47LAAAAjWv8MdKJ7sHuAo1OAUjB4QRmkPNBD28EEEEPEQQRSIPCEEg50XXs995JjTwJTAHBjVS1AEGLazhB"
    . "i3MghdJ0HkSLMUSJN4P6AXQTRItxBESJdwSD+gJ0BotRCIlXCEhj1UhjzkGDwgFIweICSMHhAkkB0EkByUQ50HRGg/sDD49v////RYtbPA8fAEWF23QiQYsYQYkZQYP7AXQW"
    . "QYtYBEGJWQRBg/sCdAhBi1gIQYlZCEGDwgFJAdBJAclEOdB/ylteX11BXsMPHwCJ2kyJz0yJwelk////ZmYuDx+EAAAAAABXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQ"
    . "QYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJ"
    . "zvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj3"
    . "2A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB"
    . "0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45"
    . "yA9MwTnDfcAxwFteww8fALgBAAAAW17DRItUJChNhcCJ0A+Uwk2FyUEPlMNECNoPheEAAABIhckPhNgAAABFD7bSQWnSAAEBAEQJ0oHKAAAA/2YPbuJmD3DcAIP4A35URI1Y"
    . "/GYPb8sxwEWJ2kHB6gJBjVIBSMHiBA8fgAAAAADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnCddxB99pIAdFJAdFJAdBDjQSThcB0XmYPbgFmD2/IZg/cw2YP"
    . "2MtmQQ9+AWZBD34Ig/gBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35BBGZBD35IBIP4AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+QAhmQQ9+WQgxwMNmZi4PH4QAAAAAAA8fQABB"
    . "V0FWQVVBVFVXVlNIg+xoDxF0JEAPEXwkUIu8JNgAAABEi5wk6AAAAESLvCTwAAAASIuEJPgAAABNic5JicpIY8pEi4wk4AAAAE2F9g+UwkiDvCTQAAAAAA+UwwjaD4VDAQAA"
    . "TYXSD4Q6AQAAif5BD77TQQ+v8Q+v1ol0JDRIY9rB+h9IadsfhetRSMH7JSnTQYD7ZLoBAAAARQ+2XgFED0T6QQ+2VgKJXCQsQcHjCMHiEEQJ2kUPth5ECdpMi5wk0AAAAGYP"
    . "bspIi5Qk0AAAAEUPtlsBZg9wyQAPtlICQcHjCMHiEEQJ2kyLnCTQAAAARQ+2G0QJ2oHKAAAA/0UpyGYPbtJEiUQkPGYPcNIAD4iSAAAASGPXSInNSMHhAsdEJDgAAAAASCnV"
    . "SImEJPgAAABmD3bbSMHlAoX2QQ+VwDneD53CQSHQRIhEJDNEjUf8RInCweoCRI1aAffaRY0kkEnB4wRJichIielMidJMAdFyIkyJ0EWF/3QI6XsCAABIidBIhdIPhY0AAABK"
    . "jRQASDnRc+uDRCQ4AU0BwotEJDg5RCQ8fcEx0g8QdCRADxB8JFBIidBIg8RoW15fXUFcQV1BXkFfw4XAD4SxAgAAZg9v8kyNDILrFA8fgAAAAABIg8IETDnKD4STAgAAZg9u"
    . "AmYPb/lmD2/mZg/e4GYP3vhmD3THZg905mYP28RmD3bDZg/XwKgBdMdIiWwkCEyJRCQgTYnQgHwkMwCLdCQsD4SbAQAASIlMJBBEi2wkNEmJ0U2J8kiJVCQYSIucJNAAAACL"
    . "dCQsZi4PH4QAAAAAADHSMcmJ+IP/Aw+OgQAAAJDzQQ9vBBHzQQ9vPBLzD280E/MPbywTSIPCEGYP3vhmD97wZg90x2YPdO5mD9vFZg92w2YP1+iJ6GbR6GYlVVUpxYnoZsHt"
    . "AmYlMzNmgeUzMwHFiehmwegEAehmJQ8PicVmwe0IAehmwegCg+AHAcFMOdp1jE0B2kwB200B2USJ4IXAD4S2AAAAZkEPbilmD24zZkEPbiJmD2/FZg/e5WYP3sZmD3TlZg90"
    . "xmYP28RmD3bDZg/X0IPiAQHRg/gBdHFmQQ9uaQRmD25zBGZBD25iBGYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBAdGD+AJ0NmYPbmMIZkEPbkEIZkEPbmoI"
    . "Zg9v9GYP3uhmD97wZg90xWYPdOZmD9vEZg92w2YP19CD4gEB0UjB4AJJAcJIAcNJAcFIi0QkCCnOSQHBQSn9dAlEOe4Pjpr+//9Ii0wkEEiLVCQYhfYPjrkAAABIg8IESDnR"
    . "D4LKAAAARYX/D4Q4/v//TYnCSItsJAhMi0QkIEiJ02YPb+pIichIidpIKdhIwfgCg8ABg/gDfxnpq/3//w8fQACD6ARIg8IQg/gDD46X/f//8w9vAmYPb/FmD2/lZg/e4GYP"
    . "3vBmD3TGZg905WYP28RmD3bDZkQP18hFhcl0wvNFD7zJTIlEJCBNidBBwfkCSIlsJAhJY8FIjRSC6ab9//9MAcNIOdkPg3b////pBP3//0iLhCT4AAAASIXAD4QH/f//i0wk"
    . "LCnxiQjp+vz//02JwkiLbCQITItEJCDp1Pz//2ZmLg8fhAAAAAAADx9AAFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NM"
    . "iUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOjO+v//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInB"
    . "hgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABXVlNIg+xwTIucJLAAAABMi5QkuAAAAIu8JNAAAABIi5wk4AAAAE2F20iJyA+U"
    . "wU2F0kAPlMZACPEPhZkAAABIhdIPhJAAAABIiVQkQIuUJMAAAABIicFEiUQkSEyNRCQgiVQkYIuUJMgAAADHRCQgAAAAAIlUJGSLlCTYAAAASMdEJCgAAAAAiVQkbEiNFZ3+"
    . "//9Ix0QkMAAAAABIiUQkOESJTCRMTIlcJFBMiVQkWECIfCRo/5DQAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbXl/DDx9EAAAxwEiDxHBbXl/DZmYuDx+EAAAAAAAPHwBBVkFU"
    . "VVdWU0yLVCRYi1wkeIu0JIAAAABIhckPhP8AAABNhdIPhPYAAACLRCRoRTHbRAnAC0QkYAnQD4jQAAAAhdsPjtgAAACF9g+O0AAAAEUPr8FIY9JNY8lIY3wkcEqNLI0AAAAA"
    . "RI1L/EjB5wJJY8BIAdBIY1QkYEiNDIGLRCRoD69EJHBImEgB0EmNFIJEicjB6AJEjUAB99hJweAERY0kgQ8fQAAxwIP7Aw+OfQAAAA8fRAAA8w9vBAIPEQQBSIPAEEw5wHXu"
    . "So0EAk6NFAFFheR0JEWJ4USLMEWJMkGD+QF0FUSLcARFiXIEQYP5AnQHi0AIQYlCCEGDwwFIAelIAfpEOd5/nkG7AQAAAESJ2FteX11BXEFeww8fQABFMdtEidhbXl9dQVxB"
    . "XsOQQYnZSYnKSInQ658PH0QAAEiD7HhMi5wkqAAAAEiJyEiF0g+E2AAAAE2F2w+EzwAAAIuMJLgAAABFMdJECckLjCSwAAAARAnBD4inAAAARIuUJMgAAABFhdIPjqEAAACL"
    . "jCTQAAAAhckPjpIAAABIiVQkMIuUJKAAAABIicFmD26MJMAAAABEiUQkOEyNRCQgZg9ulCTIAAAAiVQkQGYPboQksAAAAIuUJNAAAADHRCQgAAAAAGYPbpwkuAAAAGYPYspI"
    . "iUQkKIlUJGBIjRUu8///Zg9iw0SJTCQ8Zg9swUyJXCRIDxFEJFD/kNAAAABBugEAAABEidBIg8R4ww8fAEUx0kSJ0EiDxHjDDx9EAAC4AQAAAMOQkJCQkJCQkJCQ"
    mcode_imgutil_column_uniform := 0x000170 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000290 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000330 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000440 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0009e0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000ad0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000c10 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000d10 ; u32 get_blob_psabi_level()
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
    . "" ; 3360 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v2 -D MARCH_x86_64_v2 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIyAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
    . "Y9JIAcpJi0sQTI0MkUE5wg+N1QAAAA8fgAAAAABBi1s8g/sDD47LAAAAjWv8MdKJ7sHuAo1OAUjB4QRmkPNBD28EEEEPEQQRSIPCEEg50XXs995JjTwJTAHBjVS1AEGLazhB"
    . "i3MghdJ0HkSLMUSJN4P6AXQTRItxBESJdwSD+gJ0BotRCIlXCEhj1UhjzkGDwgFIweICSMHhAkkB0EkByUQ50HRGg/sDD49v////RYtbPA8fAEWF23QiQYsYQYkZQYP7AXQW"
    . "QYtYBEGJWQRBg/sCdAhBi1gIQYlZCEGDwgFJAdBJAclEOdB/ylteX11BXsMPHwCJ2kyJz0yJwelk////ZmYuDx+EAAAAAABXVlOLXCRIRInISGPySGNUJEBFicgPtsRBwegQ"
    . "QYnCi0QkWA+vxkiYSAHQTI0cgYtEJFAPr8ZImEgB0EiNFIFMOdpzbEUPtsBFD7bSRQ+2yYP+AXQU62lmDx+EAAAAAABIg8IETDnac0cPtkoBRCnRicj32A9IwQ+2SgJEKcGJ"
    . "zvfeD0nOOcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXl/DZi4PH4QAAAAAALgBAAAAW15fww8fgAAAAABIweYC6xJmLg8fhAAAAAAASAHyTDnac9gPtkoCRCnBicj3"
    . "2A9IwQ+2SgFEKdGJz/ffD0nPOcgPTMEPtgpEKcmJz/ffD0nPOcgPTME5w33BMcDrj2ZmLg8fhAAAAAAAZpBWUw+vVCQ4i1wkQEhj0kiJzkhjTCRQRInIRYnKD7bEQcHqEEgB"
    . "0UyNHI5IY0wkSEgBykiNFJZMOdpzXUUPttJED7bARQ+2yesQDx+AAAAAAEiDwgRMOdpzPw+2SgJEKdGJyPfYD0jBD7ZKAUQpwYnO994PSc45yA9MwQ+2CkQpyYnO994PSc45"
    . "yA9MwTnDfcAxwFteww8fALgBAAAAW17DRItUJChNhcCJ0A+Uwk2FyUEPlMNECNoPheEAAABIhckPhNgAAABFD7bSQWnSAAEBAEQJ0oHKAAAA/2YPbuJmD3DcAIP4A35URI1Y"
    . "/GYPb8sxwEWJ2kHB6gJBjVIBSMHiBA8fgAAAAADzD28EAWYPb9BmD9zBZg/Y0UEPEQQBQQ8RFABIg8AQSDnCddxB99pIAdFJAdFJAdBDjQSThcB0XmYPbgFmD2/IZg/cw2YP"
    . "2MtmQQ9+AWZBD34Ig/gBdD9mD25BBGYPb8hmD9zDZg/Yy2ZBD35BBGZBD35IBIP4AnQdZg9uSQhmD2/BZg/Yw2YP3NlmQQ9+QAhmQQ9+WQgxwMNmZi4PH4QAAAAAAA8fQABB"
    . "V0FWQVVBVFVXVlNIg+xoDxF0JEAPEXwkUIu8JNgAAABEi5wk6AAAAESLvCTwAAAASIuEJPgAAABNic5JicpIY8pEi4wk4AAAAE2F9g+UwkiDvCTQAAAAAA+UwwjaD4VDAQAA"
    . "TYXSD4Q6AQAAif5BD77TQQ+v8Q+v1ol0JDRIY9rB+h9IadsfhetRSMH7JSnTQYD7ZLoBAAAARQ+2XgFED0T6QQ+2VgKJXCQsQcHjCMHiEEQJ2kUPth5ECdpMi5wk0AAAAGYP"
    . "bspIi5Qk0AAAAEUPtlsBZg9wyQAPtlICQcHjCMHiEEQJ2kyLnCTQAAAARQ+2G0QJ2oHKAAAA/0UpyGYPbtJEiUQkPGYPcNIAD4iSAAAASGPXSInNSMHhAsdEJDgAAAAASCnV"
    . "SImEJPgAAABmD3bbSMHlAoX2QQ+VwDneD53CQSHQRIhEJDNEjUf8RInCweoCRI1aAffaRY0kkEnB4wRJichIielMidJMAdFyIkyJ0EWF/3QI6XsCAABIidBIhdIPhY0AAABK"
    . "jRQASDnRc+uDRCQ4AU0BwotEJDg5RCQ8fcEx0g8QdCRADxB8JFBIidBIg8RoW15fXUFcQV1BXkFfw4XAD4SxAgAAZg9v8kyNDILrFA8fgAAAAABIg8IETDnKD4STAgAAZg9u"
    . "AmYPb/lmD2/mZg/e4GYP3vhmD3THZg905mYP28RmD3bDZg/XwKgBdMdIiWwkCEyJRCQgTYnQgHwkMwCLdCQsD4SbAQAASIlMJBBEi2wkNEmJ0U2J8kiJVCQYSIucJNAAAACL"
    . "dCQsZi4PH4QAAAAAADHSMcmJ+IP/Aw+OgQAAAJDzQQ9vBBHzQQ9vPBLzD280E/MPbywTSIPCEGYP3vhmD97wZg90x2YPdO5mD9vFZg92w2YP1+iJ6GbR6GYlVVUpxYnoZsHt"
    . "AmYlMzNmgeUzMwHFiehmwegEAehmJQ8PicVmwe0IAehmwegCg+AHAcFMOdp1jE0B2kwB200B2USJ4IXAD4S2AAAAZkEPbilmD24zZkEPbiJmD2/FZg/e5WYP3sZmD3TlZg90"
    . "xmYP28RmD3bDZg/X0IPiAQHRg/gBdHFmQQ9uaQRmD25zBGZBD25iBGYPb8VmD97lZg/exmYPdOVmD3TGZg/bxGYPdsNmD9fQg+IBAdGD+AJ0NmYPbmMIZkEPbkEIZkEPbmoI"
    . "Zg9v9GYP3uhmD97wZg90xWYPdOZmD9vEZg92w2YP19CD4gEB0UjB4AJJAcJIAcNJAcFIi0QkCCnOSQHBQSn9dAlEOe4Pjpr+//9Ii0wkEEiLVCQYhfYPjrkAAABIg8IESDnR"
    . "D4LKAAAARYX/D4Q4/v//TYnCSItsJAhMi0QkIEiJ02YPb+pIichIidpIKdhIwfgCg8ABg/gDfxnpq/3//w8fQACD6ARIg8IQg/gDD46X/f//8w9vAmYPb/FmD2/lZg/e4GYP"
    . "3vBmD3TGZg905WYP28RmD3bDZkQP18hFhcl0wvNFD7zJTIlEJCBNidBBwfkCSIlsJAhJY8FIjRSC6ab9//9MAcNIOdkPg3b////pBP3//0iLhCT4AAAASIXAD4QH/f//i0wk"
    . "LCnxiQjp+vz//02JwkiLbCQITItEJCDp1Pz//2ZmLg8fhAAAAAAADx9AAFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NM"
    . "iUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOjO+v//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInB"
    . "hgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABXVlNIg+xwTIucJLAAAABMi5QkuAAAAIu8JNAAAABIi5wk4AAAAE2F20iJyA+U"
    . "wU2F0kAPlMZACPEPhZkAAABIhdIPhJAAAABIiVQkQIuUJMAAAABIicFEiUQkSEyNRCQgiVQkYIuUJMgAAADHRCQgAAAAAIlUJGSLlCTYAAAASMdEJCgAAAAAiVQkbEiNFZ3+"
    . "//9Ix0QkMAAAAABIiUQkOESJTCRMTIlcJFBMiVQkWECIfCRo/5DQAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbXl/DDx9EAAAxwEiDxHBbXl/DZmYuDx+EAAAAAAAPHwBBVkFU"
    . "VVdWU0yLVCRYi1wkeIu0JIAAAABIhckPhP8AAABNhdIPhPYAAACLRCRoRTHbRAnAC0QkYAnQD4jQAAAAhdsPjtgAAACF9g+O0AAAAEUPr8FIY9JNY8lIY3wkcEqNLI0AAAAA"
    . "RI1L/EjB5wJJY8BIAdBIY1QkYEiNDIGLRCRoD69EJHBImEgB0EmNFIJEicjB6AJEjUAB99hJweAERY0kgQ8fQAAxwIP7Aw+OfQAAAA8fRAAA8w9vBAIPEQQBSIPAEEw5wHXu"
    . "So0EAk6NFAFFheR0JEWJ4USLMEWJMkGD+QF0FUSLcARFiXIEQYP5AnQHi0AIQYlCCEGDwwFIAelIAfpEOd5/nkG7AQAAAESJ2FteX11BXEFeww8fQABFMdtEidhbXl9dQVxB"
    . "XsOQQYnZSYnKSInQ658PH0QAAEiD7HhMi5wkqAAAAEiJyEiF0g+E2AAAAE2F2w+EzwAAAIuMJLgAAABFMdJECckLjCSwAAAARAnBD4ijAAAARIuUJMgAAABFhdIPjqEAAACL"
    . "jCTQAAAAhckPjpIAAABIiVQkMIuUJKAAAABIicFmD26MJMAAAABEiUQkOEyNRCQgZg86IowkyAAAAAGJVCRAZg9uhCSwAAAAi5Qk0AAAAEiJRCQoZg86IoQkuAAAAAHHRCQg"
    . "AAAAAIlUJGBIjRUu8///Zg9swUSJTCQ8TIlcJEgPEUQkUP+Q0AAAAEG6AQAAAESJ0EiDxHjDDx+AAAAAAEUx0kSJ0EiDxHjDDx9EAAC4AgAAAMOQkJCQkJCQkJCQ"
    mcode_imgutil_column_uniform := 0x000170 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000290 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x000330 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000440 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x0009e0 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000ad0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000c10 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000d10 ; u32 get_blob_psabi_level()
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
    . "" ; 3712 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v3 -D MARCH_x86_64_v3 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "V1ZTSInLi0lASItDCA+v0USLiMgAAABBidCJ0DHSQffxMdKJx0KNBAFIY0swQffxi1M0AfoPr1M4SGPSSAHKSItLKEyNFJGLUxxIY0sYAfoPr1MgSGPSSAHKSItLEEyNDJE5"
    . "xw+NowAAAGYPH0QAAItTPIP6Bw+OnAAAAESNQvgx0kSJxsHuA41OAUjB4QWQxMF+bwQSxMF+fwQRSIPCIEg50XXr995NjRwKTAHJQY0U8IP6A34VxMF6bwtIg8EQSYPDEIPq"
    . "BMX6f0nwhdJ0H0WLA0SJAYP6AXQURYtDBESJQQSD+gJ0B0GLUwiJUQhIY1M4g8cBTY0UkkhjUyBNjQyROfgPhWb////F+HdbXl/DDx+AAAAAAEyJyU2J0+uSV1ZTi1wkSESJ"
    . "yEhj8khjVCRARYnID7bEQcHoEEGJwotEJFgPr8ZImEgB0EyNHIGLRCRQD6/GSJhIAdBIjRSBTDnac2xFD7bARQ+20kUPtsmD/gF0FOtpZg8fhAAAAAAASIPCBEw52nNHD7ZK"
    . "AUQp0YnI99gPSMEPtkoCRCnBic733g9JzjnID0zBD7YKRCnJic733g9JzjnID0zBOcN9wDHAW15fw2YuDx+EAAAAAAC4AQAAAFteX8MPH4AAAAAASMHmAusSZi4PH4QAAAAA"
    . "AEgB8kw52nPYD7ZKAkQpwYnI99gPSMEPtkoBRCnRic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBOcN9wTHA649mZi4PH4QAAAAAAGaQVlMPr1QkOItcJEBIY9JIic5I"
    . "Y0wkUESJyEWJyg+2xEHB6hBIAdFMjRyOSGNMJEhIAcpIjRSWTDnac11FD7bSRA+2wEUPtsnrEA8fgAAAAABIg8IETDnacz8PtkoCRCnRicj32A9IwQ+2SgFEKcGJzvfeD0nO"
    . "OcgPTMEPtgpEKcmJzvfeD0nOOcgPTME5w33AMcBbXsMPHwC4AQAAAFtew0SLVCQoTYXAidAPlMJNhclBD5TDRAjaD4UGAQAASIXJD4T9AAAARQ+20kFp0gABAQBECdKBygAA"
    . "AP/F+W7SxOJ9WNKD+Ad+UkSNWPjF/W/KMcBFidpBweoDQY1SAUjB4gUPH4AAAAAAxf5vHAHF5djBxMF+fwQAxfXcw8TBfn8EAUiDwCBIOcJ13kH32kgB0UkB0UkB0EONBNPF"
    . "+W/Cg/gDfifF+m8hSYPBEEiDwRBJg8AQg+gExdnYysTBen9I8MXp3MzEwXp/SfCFwHRixfluCcXx2NDF+dzJxMF5fhDEwXl+CYP4AXRHxfluSQTF8djQxfncycTBeX5QBMTB"
    . "eX5JBIP4AnQpxfluUQjF6djIxfncwsTBeX5ICMTBeX5BCMX4dzHAw2YuDx+EAAAAAADF+HcxwMNmLg8fhAAAAAAAQVdBVkFVQVRVV1ZTSIHsuAAAAMX4EXQkQMX4EXwkUMV4"
    . "EUQkYMV4EUwkcMV4EZQkgAAAAMV4EZwkkAAAAMV4EaQkoAAAAIu8JCgBAABEi5wkMAEAAIucJDgBAABEi7QkQAEAAE2Jz0xj0kyLjCRIAQAATYX/D5TASIO8JCABAAAAD5TC"
    . "CNAPheUEAABIhckPhNwEAACJ+A++00EPr8MPr9BIY/LB+h9IafYfhetRSMH+JSnWgPtkugEAAABBD7ZfAUQPRPJBD7ZXAol0JCjB4wjB4hAJ2kEPth8J2kiLnCQgAQAAxXlu"
    . "wkiLlCQgAQAAD7ZbAcRCfVjAD7ZSAsHjCMHiEAnaSIucJCABAAAPthsJ2kSJw4HKAAAA/8X5bvrE4n1Y/0Qp2w+IQQQAAEhj10yJ1YlcJDzF7XbSSCnVxfF2ycV5f8VNic1I"
    . "weUChcBKjRSVAAAAAEEPlcI58MV5f8ZBD53ARSHCRIhUJC9EjVf4RYnQQcHoA0WNWAFB99hHjSTCScHjBUUxwEiJ68X5b9/F+W/nSYnKSAHLD4K7AwAASIlMJDBMielFifVE"
    . "iUQkOOsWTYXSD4U7AwAATY0UEUw50w+CgwMAAE2J0UWF7XTiSYnZTSnRScH5AkGDwQFBg/kHD46GAgAAxEF9b9jFfW/XTYnQ6xtmDx+EAAAAAABBg+kISYPAIEGD+QcPjmAC"
    . "AADEwX5vAMUt3sjFJd7gxZ10wMRBNXTKxbXbwMX9dsLF/dfwhfZ0yPMPvPZIiVQkIEiJjCRIAQAAg+Y8TY0UMIB8JC8Ai3QkKA+E1AEAAIlEJAyLdCQoTInSTIn5SIlcJBBM"
    . "i4QkIAEAAEGJxkyJVCQYZg8fRAAAMcBFMdJBifmD/wd+Sg8fAMX+bwQCxEF93gwAxX3eFAHEQTV0DABIg8Agxa10wMW128DF/XbCxX3XyPNFD7jJQcH5AkUBykw52HXFTAHZ"
    . "TQHYTAHaRYnhQYP5Aw+OfwEAAMX6bwJBg+kESIPBEEmDwBDEQXneSPDFed5R8EiDwhDEQTF0SPDFqXTAxbHbwMX5dsHF+dfYidhm0ehmJVVVKcOJ2GbB6wJmJTMzZoHjMzMB"
    . "w4nYZsHoBAHYZiUPD4nDZsHrCAHYZsHoAoPgB0WFyQ+EsQAAAMV5bhLEQXluGMV5bgnEQSneycTBKd7DxaF0wMRBMXTKxbHbwMX5dsHF+dfYg+MBAdhBg/kBdG3FeW5SBMRB"
    . "eW5YBMV5bkkExEEp3snEwSnew8WhdMDEQTF0ysWx28DF+XbBxfnX2IPjAQHYQYP5AnQzxfluQgjEQXluSAjFeW5RCMUx3tjEQXne0sWpdMDEQTF0y8Wx28DF+XbBxfnX2IPj"
    . "AQHYScHhAkwByU0ByEwBykQB0EgB6inGQSn+dAlEOfYPjmP+//+LRCQMSItcJBBMi1QkGIX2D45tAQAASYPCBEw50w+CLgEAAEWF7Q+E//3//0iLVCQgSIuMJEgBAADpbv3/"
    . "/w8fRAAAMcDp5v7//02J0EGD+QN+LsTBem8AxWHeyMV53tXFqXTAxEFhdMnFsdvAxfl2wcX51/CF9nVySYPAEEGD6QRFhckPhJEAAABLjTSI6wwPHwBJg8AESTnwdHTEwXlu"
    . "AMVZ3sjFSd7Qxal0wMUxdMzFsdvAxfl2wcV518hBg+EBdNBNidFNicJNhdIPhMX8//9IiVQkIEiJjCRIAQAA6Uf9//8PH4AAAAAAZvNED7zOSIlUJCBmQcHpAkiJjCRIAQAA"
    . "RQ+3yU+NFIjpG/3//0UxwE2J0U2JwuuuSQHSTDnTD4OF/P//RYnuRItEJDhJic1Ii0wkMEGDwAFIAdFEOUQkPA+NHPz//8X4d0Ux0utLSItUJCBEi0QkOEWJ7kiLTCQwTIus"
    . "JEgBAABBg8ABSAHRRDlEJDwPjej7///ryg8fQABMi4wkSAEAAE2FyXRWi0QkKCnwQYkBxfh3xfgQdCRAxfgQfCRQTInQxXgQRCRgxXgQTCRwxXgQlCSAAAAAxXgQnCSQAAAA"
    . "xXgQpCSgAAAASIHEuAAAAFteX11BXEFdQV5BX8PF+HfrsVZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhIjQyBi0NMiUQkQA++Q0hE"
    . "iUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOiO+f//SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8fRAAARInBhgqEyXX3RItE"
    . "JFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABXVlNIg+xwTIucJLAAAABMi5QkuAAAAIu8JNAAAABIi5wk4AAAAE2F20iJyA+UwU2F0kAPlMZA"
    . "CPEPhZkAAABIhdIPhJAAAABIiVQkQIuUJMAAAABIicFEiUQkSEyNRCQgiVQkYIuUJMgAAADHRCQgAAAAAIlUJGSLlCTYAAAASMdEJCgAAAAAiVQkbEiNFZ3+//9Ix0QkMAAA"
    . "AABIiUQkOESJTCRMTIlcJFBMiVQkWECIfCRo/5DQAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbXl/DDx9EAAAxwEiDxHBbXl/DZmYuDx+EAAAAAAAPHwBBVkFUVVdWU0yLVCRY"
    . "i1wkeIu0JIAAAABIhckPhCcBAABNhdIPhB4BAACLRCRoRTHbRAnAC0QkYAnQD4j5AAAAhdsPjgABAACF9g+O+AAAAEUPr8FIY9JNY8lIY3wkcEqNLI0AAAAARI1L+EjB5wJJ"
    . "Y8BIAdBIY1QkYEiNDIGLRCRoD69EJHBImEgB0EmNFIJEicjB6ANEjUAB99hFjSTBScHgBUUxyWYPH4QAAAAAADHAg/sHD46lAAAADx9EAADF/m8EAsX+fwQBSIPAIEk5wHXt"
    . "To0UAkqNBAFFieNBg/wDfhbEwXpvCkiDwBBJg8IQQYPrBMX6f0jwRYXbdCJFizJEiTBBg/sBdBZFi3IERIlwBEGD+wJ0CEWLUghEiVAIQYPBAUgB6UgB+kQ5zn+AQbsBAAAA"
    . "xfh3RInYW15fXUFcQV7DDx8ARTHbRInYW15fXUFcQV7DZg8fhAAAAAAAQYnbSInISYnSg/sDD49y////64tmZi4PH4QAAAAAAJBIg+x4TIucJKgAAABIichIhdIPhNgAAABN"
    . "hdsPhM8AAACLjCS4AAAARTHSRAnJC4wksAAAAEQJwQ+IpAAAAESLlCTIAAAARYXSD46hAAAAi4wk0AAAAIXJD46SAAAASIlUJDCLlCSgAAAASInBxflulCTAAAAARIlEJDhM"
    . "jUQkIMTjaSKMJMgAAAABiVQkQMX5bpwksAAAAIuUJNAAAABIiUQkKMTjYSKEJLgAAAABx0QkIAAAAACJVCRgSI0VzvH//8X5bMFEiUwkPEyJXCRIxfp/RCRQ/5DQAAAAQboB"
    . "AAAARInQSIPEeMNmDx9EAABFMdJEidBIg8R4ww8fRAAAuAMAAADDkJCQkJCQkJCQkA=="
    mcode_imgutil_column_uniform := 0x000120 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000240 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x0002e0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x000420 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x000b00 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000bf0 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000d70 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000e70 ; u32 get_blob_psabi_level()
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
    . "" ; 3168 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -march=x86-64-v4 -D MARCH_x86_64_v4 -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VVdWU0SLQUBIi0EIRIuQyAAAAEEPr9BBidGJ0DHSQffyMdKJw0ONBAhMY0EwQffyi1E0AdoPr1E4SGPSTAHCTItBKE2NDJCLURxMY0EYAdoPr1EgSGPSTAHCTItBEE2NFJA5"
    . "ww+NgwAAAL4BAAAAkItRPIP6Dw+OnwAAAESNWvAx0kSJ38HvBESNRwFJweAGYtH+SG8MEWLR/kh/DBJIg8JASTnQdenB5wREidpLjSwBTQHQKfqF0nQ+xOJp99aNev+DwwHF"
    . "+JLPYvF+yW9FAGLRfkl/AEhjUThNjQyRSGNRIE2NFJI5w3WGxfh3W15fXcNmDx9EAABIY1E4g8MBTY0MkUhjUSBNjRSSOdh024tRPIP6Dw+PYf///02J0EyJzeuTZmYuDx+E"
    . "AAAAAABmkFdWU0SLVCRITGPCi1QkWESJyEWJy0xjTCRAD7bcQcHrEEEPr9BIY9JMAcpIjTSRi1QkUEEPr9BIY9JMAcpIjRSRSDnyc2pFD7bbD7bbRA+2yEGD+AF0EutnDx+A"
    . "AAAAAEiDwgRIOfJzRw+2SgEp2YnI99gPSMEPtkoCRCnZQYnIQffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteX8MPH0AAuAEAAABbXl/DDx+AAAAA"
    . "AEnB4ALrEmYuDx+EAAAAAABMAcJIOfJz2A+2SgJEKdmJyPfYD0jBD7ZKASnZic/33w9JzznID0zBD7YKRCnJic/33w9JzznID0zBQTnCfcExwOuVZmYuDx+EAAAAAABmkFZT"
    . "D69UJDhMY0QkUESLVCRASGPSSQHQRInIRInLSo00gUxjRCRID7bEwesQTAHCSI0UkUg58nNgD7bbRA+22EUPtsnrDA8fAEiDwgRIOfJzRw+2SgIp2YnI99gPSMEPtkoBRCnZ"
    . "QYnIQffYQQ9JyDnID0zBD7YKRCnJQYnIQffYQQ9JyDnID0zBQTnCfboxwFteww8fRAAAuAEAAABbXsNEi1QkKE2FwInQD5TCTYXJQQ+Uw0QI2g+FtgAAAEiFyQ+ErQAAAEUP"
    . "ttJBadIAAQEARAnSgcoAAAD/YvJ9SHzSg/gPflhEjVjwYvH9SG/KMcBFidpBweoEQY1SAUjB4gZi8X9IbxwBYvFlSNjBYtH+SH8EAGLxdUjcw2LR/kh/BAFIg8BASDnQddZI"
    . "AcFJAcFJAcBBweIERInYRCnQhcB0P7oBAAAAxOJ598KD6AHF+JLIYvF+yW8BYvF9SNjKYvF9SNzCYtF+SX8IYtF+SX8Bxfh3McDDZi4PH4QAAAAAAMX4dzHAw2YuDx+EAAAA"
    . "AABBV0FWQVVBVFVXVlNIg+w4i7wkqAAAAESLnCSwAAAAi5wkuAAAAEyJjCSYAAAATGPSSIO8JJgAAAAASInID5TCi4wkwAAAAEiDvCSgAAAAAEAPlMZMi4wkyAAAAEAI8g+F"
    . "0wMAAEiFwA+EygMAAEGJ/g++00WJx0UPr/NBD6/WRIl0JBRIY/LB+h9IafYfhetRSMH+JSnWgPtkugEAAABIi5wkmAAAAA9EykiLlCSYAAAAiXQkDA+2WwEPtlICweMIweIQ"
    . "CdpIi5wkmAAAAA+2GwnaSIucJKAAAABi8n1IfOpIi5QkoAAAAA+2WwEPtlICweMIweIQCdpIi5wkoAAAAA+2GwnagcoAAAD/YvJ9SHziRSnfD4gaAwAASGPXTInVRI1n8EG9"
    . "AQAAAEgp1U6NBJUAAAAAYvN1SCXJ/0jB5QJFhfZBD5XCQTn2TYnOTYnBD53CQYnIMdtBIdJEiFQkE0mJwkSJ4MHoBESNWAHB4ARJweMGQSnESInqTInQYvH9SG/dTAHSD4KZ"
    . "AgAAiVwkKEyJ002JykWJwUSJfCQs6xwPH4AAAAAASInGSIXAdX9KjQQWSDnCD4JXAgAARYXJdOZi8f1Ib9RIidFJicBIKcFIwfkCg8EBg/kPfxvp1wEAAGYPH0QAAIPpEEmD"
    . "wECD+Q8PjsEBAABi0X9IbwBi831IPssFYvN9ST7KAmLyfkgowWLzfUgfwQDF+JjAdMnF+JPAZvMPvMAPt8BJjQSATIlUJBhEiWQkCEiJXCQgSIkUJEyJ8oB8JBMAi3QkDA+E"
    . "5wAAAEyLtCSgAAAASIucJJgAAABJicJEi3wkFIt0JAwxyUUx5Exjx4P/D35KDx8AYtF/SG8UCmLzbUg+DAsFYtNtST4MDgJIg8FAYvJ+SCjBYvN9SB/ZAMV4k8PzRQ+4wEUB"
    . "xEk5y3XHTGNEJAhMAdtNAd5NAdpFhcAPhKgAAADEwjn3zYPpAUnB4AJBKf/F+5LJYtF+yW8CYuF+yW8DTAHDYtF+yW8WTQHGSQHoYrN9SD7QBU0BwmLzfUo+0gJi8n5IKMJi"
    . "831JH+EAxfiTzGbzD7jJD7fJRAHhKc5BOfd8CUWF/w+FNf///4X2flFIg8AESDkEJA+C8gAAAEWFyQ+E7/7//0mJ1kyLVCQYRItkJAhIi1wkIEiLFCTpUf7//w8fgAAAAABE"
    . "KeZJAepBKf90uEQ5/g+O5P7//4X2f69JidFIhdIPhMMAAACLVCQMKfJBiRHF+HdIg8Q4W15fXUFcQV1BXkFfw4XJdEvEwnH3zY1x/8X4ks5i0X7JbwBi831IPtUFYvN9Sj7E"
    . "AmLyfkgowGLzfUkfyQDF+JjJdBjF+JPxZvMPvM5IicYPt8lJjQSI6aP9//9MAdBIOcIPg7T9//9FichEi3wkLE2J0UmJ2otcJCiDwwFNAcpEOfsPjkP9///F+HcxwOlp////"
    . "RYnIi1wkKESLfCQsSYnWRItkJAhMi1QkIEyLTCQY68fF+HfpQf///2YPH4QAAAAAAFZTSIPsaMdEJFwAAAAASInLSI10JFzrTw8fhAAAAAAAi1MoSItLIEiJdCRID6/CSJhI"
    . "jQyBi0NMiUQkQA++Q0hEiUQkMIlEJDiLQ0CJRCQoSItDOEiJRCQgTItLMOgu+///SIXAdSG4AQAAAPAPwQNEi0NEi1MsRCnCOcJ9okiDxGhbXsMPHwBIjVMUQbgBAAAAZg8f"
    . "RAAARInBhgqEyXX3RItEJFxEOUMQfQhEiUMQSIlDCIYKi0NAD69DRDtEJFx/pItDLIcD651mDx9EAABXVlNIg+xwTIucJLAAAABMi5QkuAAAAIu8JNAAAABIi5wk4AAAAE2F"
    . "2w+UwE2F0kAPlMZACPAPhZQAAABIhdIPhIsAAACLhCTAAAAASIlUJEBIjRXY/v//RIlEJEhMjUQkIIlEJGCLhCTIAAAAx0QkIAAAAACJRCRki4Qk2AAAAEjHRCQoAAAAAEjH"
    . "RCQwAAAAAEiJTCQ4RIlMJExMiVwkUEyJVCRYQIh8JGiJRCRs/5HQAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbXl/DDx8AMcBIg8RwW15fw2YPH0QAAEFVQVRVV1ZTSItcJFhE"
    . "i1QkeESLnCSAAAAASIXJD4QFAQAASIXbD4T8AAAAi0QkaDH2RAnAC0QkYAnQD4ixAAAARYXSD47eAAAARYXbD47VAAAARQ+vwUhj0kGNcvBNY8lKjSyNAAAAAEG8AQAAAEUx"
    . "yUljwEgB0EhjVCRgSI0MgYtEJGgPr0QkcEiYSAHQSI0Ug4nwSGNcJHDB6AREjUABweAESMHjAknB4AYpxmaQMcBBg/oPD458AAAADx9AAGLx/khvDAJi8f5IfwwBSIPAQEk5"
    . "wHXphfZ1JUGDwQFIAelIAdpFOct/xr4BAAAAxfh3ifBbXl9dQVxBXcMPHwBOjSwCSo08AYnwxMJ598SD6AHF+JLIYtF+yW9FAGLxfkl/B+u2Dx8AMfaJ8FteX11BXEFdww8f"
    . "AESJ0EiJz0mJ1evHZmYuDx+EAAAAAABmkEiD7HhMi5wkqAAAAEiF0g+E0wAAAE2F2w+EygAAAIuEJLgAAABFMdJECcgLhCSwAAAARAnAD4ihAAAARIuUJMgAAABFhdIPjpwA"
    . "AACLhCTQAAAAhcAPjo0AAACLhCSgAAAASIlUJDBIjRVC9P//xflulCTAAAAARIlEJDhMjUQkIMTjaSKMJMgAAAABiUQkQMX5bpwksAAAAIuEJNAAAABIiUwkKMTjYSKEJLgA"
    . "AAABx0QkIAAAAABEiUwkPMX5bMFMiVwkSIlEJGDF+n9EJFD/kdAAAABBugEAAABEidBIg8R4ww8fQABFMdJEidBIg8R4w2ZmLg8fhAAAAAAAZpC4BAAAAMOQkJCQkJCQkJCQ"
    mcode_imgutil_column_uniform := 0x000130 ; u32 imgutil_column_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 x, i32 tolerance, i32 ymin, i32 ymax)
    mcode_imgutil_row_uniform    := 0x000250 ; i32 imgutil_row_uniform(argb *ptr, i32 width, i32 height, argb refc, i32 y, i32 tolerance, i32 xmin, i32 xmax)
    mcode_imgutil_make_sat_masks := 0x0002f0 ; u32 imgutil_make_sat_masks(u32 *__restrict needle, i32 pixelcount, u32 *__restrict needle_lo, u32 *__restrict needle_hi, u8 t)
    mcode_imgutil_imgsrch        := 0x0003e0 ; argb *imgutil_imgsrch(argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_imgsrch_multi  := 0x000920 ; argb *imgutil_imgsrch_multi(mt_ctx *ctx, argb *haystack, i32 haystack_w, i32 haystack_h, argb *needle_lo, argb *needle_hi, i32 needle_w, i32 needle_h, i8 pctmatchreq, i32 force_topleft, i32 *ppixels_matched)
    mcode_imgutil_blit           := 0x000a00 ; i32 imgutil_blit(argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_imgutil_blit_multi     := 0x000b50 ; i32 imgutil_blit_multi(mt_ctx *ctx, argb *dst, i32 dx, i32 dy, i32 dstride, argb *src, i32 sx, i32 sy, i32 sstride, i32 w, i32 h)
    mcode_get_blob_psabi_level   := 0x000c50 ; u32 get_blob_psabi_level()
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
    . "" ; 2944 bytes
    . "" ; gcc.exe (Rev2, Built by MSYS2 project) 13.2.0
    . "" ; flags: -mabi=ms -m64 -D __HEADLESS__ -O3
    . "" ; GNU assembler (GNU Binutils) 2.41
    . "" ; flags: -O2
    . "VVdWU0iD7Di/AQAAAEiJy/APwbnMAAAASIuRkAAAAEhjx0iNdCQg8w9+BMJIjSzFAAAAAA8WgZgAAAAPEUQkIOsjZg8fRAAASIuLwAAAAIn6/5O4AAAASIuDoAAAAEiLDCj/"
    . "U3BFMcBBuf////9IifK5AgAAAP+TiAAAAIXAdMgxwEiDxDhbXl9dww8fRAAAVlNIg+woMcBIictIhcl1EEiDxChbXsNmDx+EAAAAAABIh5G4AAAATIeBwAAAAIuJyAAAAIXJ"
    . "dCQx9mYPH0QAAEiLg5AAAABIiwzwSIPGAf9TcIuLyAAAADnOcuRIi5OgAAAAQbn/////QbgBAAAA/5OIAAAAuAEAAABIg8QoW17DZmYuDx+EAAAAAAAPH0AAQVVBVFVXVlNI"
    . "g+wYRTHJnJxngTQkAAAgAJ2cWGczBCSdJQAAIACFwA+EgQAAAEyNFUsIAABEichEickx/w+iSY2q0AEAAEGJxESJybgAAACAD6JBicVBi0IMRYsCQTnBRA9CyEGB+AAAAIB2"
    . "U0U5xXJYRDsF1wkAAEWLWghJY3IEdB1EicCJ+USJBcEJAAAPookEJIlcJASJTCQIiVQkDEQjHLR0JEmDwhBJOep1p0SJyEiDxBhbXl9dQVxBXcOQRTnEc61FhcB4qEGD6QFE"
    . "ichIg8QYW15fXUFcQV3DZpBlSIsEJWAAAABIi0AYSItAIEiLAEiLAEiLQCDDR2V0UHJvY0FkZHJlc3MADx9EAABWU0mJy0yJ2YtBPEgByEiNQBhIjUBwSIvAixBIjQQRi1gY"
    . "i1Aghdt0U0Ux0kmNNBNCixSWQbhHAAAATI0Nq////0wB2g+2CoTJdR7rJg8fAEQ4wXUeD7ZKAUiDwgFJg8EBRQ+2AYTJdAVFhMB14kQ4wXQOSYPCAUk52nW0McBbXsOLUCRL"
    . "jQxTi0AcD7cUEUmNFJOLBAJMAdhbXsMPH0AAVlNIg+woSInLSIXJD4S2AAAASIuJmAAAAP9TcEiLk6gAAACLi8gAAABBuf////9BuAEAAAD/k4gAAABIi4uYAAAA/5OAAAAA"
    . "i4PIAAAAhcB0RTH2Dx9AAEiLg6gAAABIiwzw/5OAAAAASIuDoAAAAEiLDPD/k4AAAABIi4OQAAAASIsM8EiDxgH/k4AAAAA7s8gAAABywUiLi6AAAAD/UyhIi4uQAAAA/1Mo"
    . "SIuLqAAAAP9TKEiLQyhIidlIg8QoW15I/+APHwBIg8QoW17DkFVXVlNIg+xISItBUMdEJDgAAAAASInOSIXAD4QAAQAASI18JDxFMckx0jHJSYn4x0QkPAAAAABIx0QkIAAA"
    . "AAD/0ItUJDy5QAAAAP9WIEiJw0iFwA+EtgAAAEUxyYtUJDxJifhIicFIx0QkIAAAAAD/VlCFwA+ElQAAAESLRCQ8RYXAD4QvAQAASInaMclBuv////9FMdsx7UUxyeseZpCD"
    . "xQFBicJmLg8fhAAAAAAAiwIBwUgBwkQ5wXM0i0IEhcB17Q+2Qg9EOdB05EGDwQGAehIAdMpBicKLAkGDwwEBwUgBwkQ5wXLTDx+AAAAAAESJzynvRYXbQQ9E+UiJ2f9WKIn4"
    . "SIPESFteX13DDx8AMf+J+EiDxEhbXl9dww8fADHbSI18JDjrLg8fgAAAAAD/VjCD+Hp12EiF23QGSInZ/1Yoi1QkOLlAAAAA/1YgSInDSIXAdLlIifpIidn/VkiFwHTMi0Qk"
    . "OIP4H3ZLjUjgMf9IidhBichBwegFQY1QAUjB4gVIAdpmDx+EAAAAAACDeAgBg9cASIPAIEg5wnXwQcHgBYnIRCnAiUQkOOlK////Zg8fRAAAMf/pPf///0dsb2JhbEZyZWUA"
    . "R2xvYmFsQWxsb2MATG9hZExpYnJhcnlBAEZyZWVMaWJyYXJ5AJBHZXRMb2dpY2FsUHJvY2Vzc29ySW5mb3JtYXRpb24AR2V0U3lzdGVtQ3B1U2V0SW5mb3JtYXRpb24AR2V0"
    . "TGFzdEVycm9yAFF1ZXJ5UGVyZm9ybWFuY2VDb3VudGVyAFF1ZXJ5UGVyZm9ybWFuY2VGcmVxdWVuY3kAQ3JlYXRlVGhyZWFkAFdhaXRGb3JTaW5nbGVPYmplY3QAQ3JlYXRl"
    . "RXZlbnRBAFNldEV2ZW50AFJlc2V0RXZlbnQAQ2xvc2VIYW5kbGUAV2FpdEZvck11bHRpcGxlT2JqZWN0cwBmkEFVQVRVV1ZTSIPsOGVIiwQlYAAAAEiLQBhIi0AgSIsASIsA"
    . "SItAIEiJxonNSIXAD4TlAgAASInB6IP7//9IjRWr/v//SInxSInH/9BIjRWn/v//SInxSYnF/9e62AAAALlAAAAASYnE/9BIicNIhcAPhKQCAABIjQWj+f//SI0Vgv7//0iJ"
    . "8UiJM0iJg9AAAABMiWMgSIl7CEyJayj/10iNFW3+//9IifFIiUMQ/9dIjRVq/v//SInxSIlDGP/XSI0Vef7//0iJ8UiJQ0j/10iNFYT+//9IifFIiUNQ/9dIjRWB/v//SInx"
    . "SIlDMP/XSI0Vif7//0iJ8UiJQzj/10iNFZP+//9IifFIiUNA/9dIjRWQ/v//SInxSIlDWP/XSI0VlP7//0iJ8UiJQ2D/10iNFZH+//9IifFIiUNo/9dIjRWK/v//SInxSIlD"
    . "cP/XSI0Vhf7//0iJ8UiJQ3j/10iNFYH+//9IifFIiYOAAAAA/9dIiYOIAAAAhe0PhFcBAACNFO0AAAAAuUAAAACJq8gAAABB/9S5QAAAAEiJg6gAAACLg8gAAACNFMUAAAAA"
    . "Qf/UuUAAAABIiYOQAAAAi4PIAAAAjRTFAAAAAEH/1DHJRTHJRTHASImDoAAAALoBAAAA/1NoSIO7qAAAAABIx4O4AAAAAAAAAEiJg5gAAABIi4uQAAAASMeDwAAAAAAAAADH"
    . "g8wAAAAAAAAAD4TPAAAASIXJD4TGAAAASIuDoAAAAEiFwA+EtgAAAIuTyAAAAIXSdH0x7UyNJUP3///rCJBIi4OgAAAASI007QAAAABFMclFMcAx0kiNPDAxyUiDxQH/U2hF"
    . "MclFMcAx0kiJB0iLu5AAAAAxyf9TaEmJ2U2J4DHSSAH3MclIiQdIA7OoAAAASMdEJCgAAAAAx0QkIAAAAAD/U1hIiQY7q8gAAAByj0iJ2EiDxDhbXl9dQVxBXcMPH4AAAAAA"
    . "SInZ6FD6//+Jxema/v//Zg8fhAAAAAAA/5OAAAAASIuLoAAAAP9TKEiLi6gAAAD/UyhIi4uwAAAA/1MoSInZQf/VMdtIidhIg8Q4W15fXUFcQV3DDx9AAAEAAAADAAAAAQAA"
    . "AAEAAAABAAAAAwAAAAABAAABAAAAAQAAAAMAAAAACAAAAQAAAAEAAAADAAAAAIAAAAEAAAABAAAAAwAAAAAAAAEBAAAAAQAAAAMAAAAAAIAAAQAAAAEAAAADAAAAAAAAAQEA"
    . "AAABAAAAAwAAAAAAAAIBAAAAAQAAAAMAAAAAAAAEAQAAAAEAAAACAAAAAQAAAAIAAAABAAAAAgAAAAAgAAACAAAAAQAAAAIAAAAAAAgAAgAAAAEAAAACAAAAAAAQAAIAAAAB"
    . "AAAAAgAAAAAAgAACAAAAAQAAgAIAAAABAAAAAgAAAAEAAAACAAAAABAAAAMAAAABAAAAAgAAAAAAQAADAAAAAQAAAAIAAAAAAAAIAwAAAAEAAAACAAAAAAAAEAMAAAABAAAA"
    . "AgAAAAAAACADAAAAAQAAgAIAAAAgAAAAAwAAAAcAAAABAAAACAAAAAMAAAAHAAAAAQAAACAAAAADAAAABwAAAAEAAAAAAQAAAwAAAAcAAAABAAAAAAABAAQAAAAHAAAAAQAA"
    . "AAAAAgAEAAAABwAAAAEAAAAAAAAQBAAAAAcAAAABAAAAAAAAQAQAAAAHAAAAAQAAAAAAAIAEAAAA/////5CQkJCQkJCQkJCQkA=="
    mcode_mt_threadproc         := 0x000000 ; 
    mcode_mt_run                := 0x000090 ; 
    mcode_get_cpu_psabi_level   := 0x000120 ; int get_cpu_psabi_level()
    mcode_gpa_getkernel32       := 0x000200 ; 
    mcode_gpa_getgetprocaddress := 0x000230 ; 
    mcode_mt_deinit             := 0x0002d0 ; 
    mcode_mt_get_cputhreads     := 0x0003a0 ; int mt_get_cputhreads(mt_ctx *ctx)
    mcode_mt_init               := 0x000670 ; 
    ;----------------- end of ahkmcodegen auto-generated section ------------------
            
        static code := this.i_b64decode(b64)
        codemap := Map( "get_cpu_psabi_level",       code + mcode_get_cpu_psabi_level
                      , "mt_get_cputhreads",         code + mcode_mt_get_cputhreads
                      , "mt_init",                   code + mcode_mt_init
                      , "mt_deinit",                 code + mcode_mt_deinit
                      )
        return codemap
    }












