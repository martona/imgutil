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
    . "" ; 6752 bytes
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
    . "AGYPYsNmD9ZEJEjzD36EJKAAAABMjUQkIMdEJCAAAAAASI0VxP7//w8WhCSoAAAASMdEJCgAAAAADxFEJFBmD26EJLAAAABIx0QkMAAAAABmD2LBiUQkbGYP1kQkYP+R0AAA"
    . "AEiF23QGi0QkMIkDSItEJChIg8RwW8NmkFZTMfZEi1QkSExjXCRAi1wkYESJwEQJ0EQJ2AnQD4iBAAAAi0QkWIXAD46BAAAAhdt+fUUPr8FIY9JNY8lED69UJFBKjTSNAAAA"
    . "AExjTCRQSWPASAHQSItUJDhMjQSBSWPCRItUJFhMAdhJweECRTHbSI0Mgg8fADHAZg8fRAAAixSBQYkUgEiDwAFJOcJ18EGDwwFJAfBMAclEOdt/2b4BAAAAifBbXsMPH4AA"
    . "AAAAMfaJ8Ftew2YPH4QAAAAAAEiD7HiLhCSgAAAAZg9ujCTAAAAAZg9ulCS4AAAAiUQkQGZID27aZkgPbsFIi4QkqAAAAGYPbMNmQQ9u4Q8RRCQoZkEPbsBmD2LEZg/WRCQ4"
    . "Zg9uhCTIAAAATI1EJCDHRCQgAAAAAEiNFSPn//9IiUQkSIuEJNAAAABmD2LIZg9uhCSwAAAAZg9iwmYPbMEPEUQkUIlEJGD/kdAAAAC4AQAAAEiDxHjDZg8fhAAAAAAAMcDD"
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
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIyAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
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
    . "uAAAAMdEJCAAAAAAiUQkZIuEJMAAAABIx0QkKAAAAACIRCRoi4QkyAAAAEjHRCQwAAAAAEiJTCQ4RIlMJEyJRCRs/5HQAAAASIXbdAaLRCQwiQNIi0QkKEiDxHBbww8fgAAA"
    . "AABBVkFUVVdWUzH/RItUJGhMY1wkYItcJHiLtCSAAAAARInARAnQRAnYCdAPiMcAAACF2w+O0AAAAIX2D47IAAAARQ+vwUhj0k1jyUhjfCRwRA+vVCRwSo0sjQAAAABEjUv8"
    . "SMHnAkljwEgB0EiLVCRYSI0MgUljwkwB2EUx20iNFIJEicjB6AJEjUAB99hJweAERY0kgQ8fADHAg/sDfnmQ8w9vBAIPEQQBSIPAEEw5wHXuSo0EAk6NFAFFheR0JEWJ4USL"
    . "MEWJMkGD+QF0FUSLcARFiXIEQYP5AnQHi0AIQYlCCEGDwwFIAelIAfpEOd5/pr8BAAAAifhbXl9dQVxBXsNmDx9EAAAx/4n4W15fXUFcQV7DDx8AQYnZSYnKSInQ659mZi4P"
    . "H4QAAAAAAGaQSIPseGYPbowkwAAAAIuEJKAAAABmD26UJMgAAABmD26EJLAAAABmD26cJLgAAABmD2LKiUQkQEiLhCSoAAAAZg9iw2YPbMFIiVQkMEiNFW30//9IiUQkSIuE"
    . "JNAAAABEiUQkOEyNRCQgx0QkIAAAAABIiUwkKESJTCQ8iUQkYA8RRCRQ/5HQAAAAuAEAAABIg8R4w2ZmLg8fhAAAAAAAkLgBAAAAw5CQkJCQkJCQkJA="
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
    . "QVZVV1ZTSYnLi0lASYtDCEGLazgPr9FBi3MgRIuIyAAAAEGJ0InQMdJB9/Ex0kGJwkKNBAFJY0swQffxQYtTNEQB0g+v1Uhj0kgBykmLSyhMjQSRQYtTHEljSxhEAdIPr9ZI"
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
    . "iEQkaIuEJMgAAABIx0QkMAAAAABIiUwkOESJTCRMiUQkbP+R0AAAAEiF23QGi0QkMIkDSItEJChIg8RwW8MPH4AAAAAAQVZBVFVXVlMx/0SLVCRoTGNcJGCLXCR4i7QkgAAA"
    . "AESJwEQJ0EQJ2AnQD4jHAAAAhdsPjtAAAACF9g+OyAAAAEUPr8FIY9JNY8lIY3wkcEQPr1QkcEqNLI0AAAAARI1L/EjB5wJJY8BIAdBIi1QkWEiNDIFJY8JMAdhFMdtIjRSC"
    . "RInIwegCRI1AAffYScHgBEWNJIEPHwAxwIP7A355kPMPbwQCDxEEAUiDwBBMOcB17kqNBAJOjRQBRYXkdCRFieFEizBFiTJBg/kBdBVEi3AERYlyBEGD+QJ0B4tACEGJQghB"
    . "g8MBSAHpSAH6RDnef6a/AQAAAIn4W15fXUFcQV7DZg8fRAAAMf+J+FteX11BXEFeww8fAEGJ2UmJykiJ0OufZmYuDx+EAAAAAABmkEiD7HhmD26MJMAAAACLhCSgAAAAZg86"
    . "IowkyAAAAAFmD26EJLAAAABmDzoihCS4AAAAAYlEJEBIi4QkqAAAAGYPbMFIiVQkMEiNFZH0//9IiUQkSIuEJNAAAABEiUQkOEyNRCQgx0QkIAAAAABIiUwkKESJTCQ8iUQk"
    . "YA8RRCRQ/5HQAAAAuAEAAABIg8R4w7gCAAAAw5CQkJCQkJCQkJA="
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
    . "V1ZTSInLi0lASItDCA+v0USLiMgAAABBidCJ0DHSQffxMdKJx0KNBAFIY0swQffxi1M0AfoPr1M4SGPSSAHKSItLKEyNFJGLUxxIY0sYAfoPr1MgSGPSSAHKSItLEEyNDJE5"
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
    . "RCQoAAAAAIhEJGiLhCTIAAAASMdEJDAAAAAASIlMJDhEiUwkTIlEJGz/kdAAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAAEFWQVRVV1ZTMf9Ei1QkaExjXCRgi1wk"
    . "eIu0JIAAAABEicBECdBECdgJ0A+I8AAAAIXbD474AAAAhfYPjvAAAABFD6/BSGPSTWPJSGN8JHBED69UJHBKjSyNAAAAAESNS/hIwecCSWPASAHQSItUJFhIjQyBSWPCTAHY"
    . "SI0UgkSJyMHoA0SNQAH32EWNJMFJweAFRTHJDx8AMcCD+wcPjp0AAAAPH0QAAMX+bwQCxf5/BAFIg8AgSTnAde1OjRQCSo0EAUWJ40GD/AN+FsTBem8KSIPAEEmDwhBBg+sE"
    . "xfp/SPBFhdt0IkWLMkSJMEGD+wF0FkWLcgREiXAEQYP7AnQIRYtSCESJUAhBg8EBSAHpSAH6RDnOf4C/AQAAAMX4d4n4W15fXUFcQV7DDx9EAAAx/4n4W15fXUFcQV7DDx8A"
    . "QYnbSInISYnSg/sDD496////65NmZi4PH4QAAAAAAJBIg+x4xflulCTAAAAAi4QkoAAAAMTjaSKMJMgAAAABxflunCSwAAAAxONhIoQkuAAAAAGJRCRASIuEJKgAAADF+WzB"
    . "SIlUJDBIjRUx8///SIlEJEiLhCTQAAAARIlEJDhMjUQkIMdEJCAAAAAASIlMJChEiUwkPIlEJGDF+n9EJFD/kdAAAAC4AQAAAEiDxHjDZmYuDx+EAAAAAAAPH0AAuAMAAADD"
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
    . "VVdWU0SLQUBIi0EIRIuQyAAAAEEPr9BBidGJ0DHSQffyMdKJw0ONBAhMY0EwQffyi1E0AdoPr1E4SGPSTAHCTItBKE2NDJCLURxMY0EYAdoPr1EgSGPSTAHCTItBEE2NFJA5"
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
    . "JGz/kdAAAABIhdt0BotEJDCJA0iLRCQoSIPEcFvDDx+AAAAAAEFVQVRVV1ZTMf9Ei1QkaEhjdCRgRItcJHiLnCSAAAAARInARAnQCfAJ0A+IsgAAAEWF2w+OtwAAAIXbD46v"
    . "AAAARQ+vwUhj0kGNe/BNY8lED69UJHBBvAEAAABJY8BIAdBIi1QkWEiNDIFJY8JFMdJIAfBKjTSNAAAAAExjTCRwSI0Ugon4wegEScHhAkSNQAHB4ARJweAGKcdmDx9EAAAx"
    . "wEGD+w8PjoQAAAAPH0AAYvH+SG8MAmLx/kh/DAFIg8BASTnAdemF/3U1QYPCAUgB8UwBykQ503/GvwEAAADF+HeJ+FteX11BXEFdww8fADH/ifhbXl9dQVxBXcMPHwBOjSwC"
    . "So0sAYn4xMJ598SD6AHF+JLIYtF+yW9FAGLxfkl/RQDrpWYuDx+EAAAAAABEidhIic1JidXrzw8fRAAASIPseIuEJKAAAADF+W6UJMAAAADF+W6cJLAAAADE42kijCTIAAAA"
    . "AcTjYSKEJLgAAAABiUQkQEiLhCSoAAAAxflswUiJVCQwSI0VofT//0iJRCRIi4Qk0AAAAESJRCQ4TI1EJCDHRCQgAAAAAEiJTCQoRIlMJDyJRCRgxfp/RCRQ/5HQAAAAuAEA"
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
