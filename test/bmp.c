#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma pack(push, 1)
typedef struct tagBITMAPFILEHEADER
{
    u16     bfType;         //specifies the file type
    u32     bfSize;         //specifies the size in bytes of the bitmap file
    u16     bfReserved1;    //reserved; must be 0
    u16     bfReserved2;    //reserved; must be 0
    u32     bfOffBits;      //specifies the offset in bytes from the bitmapfileheader to the bitmap bits
} BITMAPFILEHEADER;
typedef struct tagBITMAPINFOHEADER
{
    u32 biSize;            //specifies the number of bytes required by the struct
    i32 biWidth;           //specifies width in pixels
    i32 biHeight;          //specifies height in pixels
    u16 biPlanes;          //specifies the number of color planes, must be 1
    u16 biBitCount;        //specifies the number of bits per pixel
    u32 biCompression;     //specifies the type of compression
    u32 biSizeImage;       //size of image in bytes
    i32 biXPelsPerMeter;   //number of pixels per meter in x axis
    i32 biYPelsPerMeter;   //number of pixels per meter in y axis
    u32 biClrUsed;         //number of colors used by the bitmap
    u32 biClrImportant;    //number of colors that are important
} BITMAPINFOHEADER;
#pragma pack(pop)

#define BI_RGB 0
#define BI_BITFIELDS 3

argb* loadbmp(char *fname, BITMAPINFOHEADER *pbih)
{
    FILE *fp = NULL;
    BITMAPFILEHEADER bfh;
    argb* bitmap = NULL;

    if (fp = fopen(fname, "rb")) {
        if (fread(&bfh, sizeof(BITMAPFILEHEADER), 1, fp)) {
            if (bfh.bfType ==0x4D42) {
                if (fread(pbih, sizeof(BITMAPINFOHEADER), 1, fp)) {
                    if (pbih->biBitCount == 32 && (pbih->biCompression == BI_RGB || pbih->biCompression == BI_BITFIELDS)) {
                        if (!fseek(fp, bfh.bfOffBits, SEEK_SET)) {
                            u32 topdown = pbih->biHeight < 0;
                            if (topdown) pbih->biHeight = -pbih->biHeight;
                            u32 imgsize = pbih->biWidth * pbih->biHeight * 4;
                            bitmap = (argb*)malloc(imgsize);
                            u32 rowbytes = pbih->biWidth * 4;
                            if (bitmap) {
                                for (i32 y = 0; y < pbih->biHeight; y++) {
                                    argb* ptr = bitmap;
                                    u32 offset = topdown ? (y * pbih->biWidth) : ((pbih->biHeight - 1 - y) * pbih->biWidth);
                                    ptr += offset;
                                    if (!fread(ptr, rowbytes, 1, fp)) {
                                        free(bitmap);
                                        bitmap = NULL;
                                        break;
                                    }
                                }
                                fclose(fp);
                                return bitmap;
                            }
                        }
                    }
                }
            }
        }
        fclose(fp);
    }
    return NULL;
}