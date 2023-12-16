# imgutil
A pixel-crunching library for AutoHotkey v2

For imagesearch, look in i_imgutil_imgsrch.c 

The imgutil_imgsrch_v1.c (2, 3, 4) files just define MARCH_x86_64_v1 (2, 3, 4) and #include this file. (Messy, it will get fixed.)

You will need to specify -march=x86-64-v4 (3, 2..) to GCC for the stuff to compile.

If you want to make blobs, use https://github.com/martona/ahkmcodegen