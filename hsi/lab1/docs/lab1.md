-   x - 1: x + ~0
-   -x   : ~x + 1
-   0xffff0000:  0x1 << 31 >> n
-   0x0000ffff:  ~0xffff0000
-   sign: x>31 & 0x1
-   0 0x80000000: 正负数的符号位相同,但符号位不同