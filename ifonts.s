//=======1=========2========3=========4=========5=========6=========7==
//
// Table file: itable.s
//
// because of where the GNU assembler has chosen to store the data from
// ldr rn,=0x12345678 instructions, (at the very end of memory), we will
// encounter less trouble if we put our large data tables right at the
// front (So the assembler won't have as far to reach to get past them).
//
	// ASCII character font table:
	//
fonts:	.word	0x0,	    0x0,	0x0,	    0x0 	@ 20
	.word	0x10,	    0x10101010,	0x10001010, 0x0 	@ 21
	.word	0x28,	    0x28282800,	0x0,	    0x0 	@ 22
	.word	0x2424,	    0x24ff2424,	0xff242424, 0x0 	@ 23
	.word	0x10107c,   0x9290701c,	0x12927c10, 0x10000000 	@ 24
	.word	0x60,	    0x90916618,	0x66890906, 0x0 	@ 25
	.word	0x38,	    0x44281028,	0x45464639, 0x0 	@ 26
	.word	0x10,	    0x10101000,	0x0,	    0x0 	@ 27
	.word	0x40808,    0x10101010,	0x10100808, 0x4000000 	@ 28
	.word	0x201010,   0x8080808,	0x8081010,  0x20000000 	@ 29
	.word	0x0,	    0x8493e1c,	0x3e490800, 0x0 	@ 2A
	.word	0x0,	    0x808087f,	0x8080800,  0x0 	@ 2B
	.word	0x0,	    0x0,	0x1818,	    0x10200000 	@ 2C
	.word	0x0,	    0x0,	0x3e000000, 0x0 	@ 2D
	.word	0x0,	    0x0,	0x1818,	    0x0 	@ 2E
	.word	0x202,	    0x4040808,	0x10102020, 0x40400000 	@ 2F
	.word	0x1c,	    0x22414949,	0x4941221c, 0x0 	@ 30
	.word	0x18,	    0x38080808,	0x808083e,  0x0 	@ 31
	.word	0x3e,	    0x41010102,	0xc30407f,  0x0 	@ 32
	.word	0x7f,	    0x4102041c,	0x301433e,  0x0 	@ 33
	.word	0x2,	    0x60a1222,	0x427f0202, 0x0 	@ 34
	.word	0x7f,	    0x40407c03,	0x101433c,  0x0 	@ 35
	.word	0x1e,	    0x21405e63,	0x4141231e, 0x0 	@ 36
	.word	0x7f,	    0x1010204,	0x8081010,  0x0 	@ 37
	.word	0x3e,	    0x4141413e,	0x4141613e, 0x0 	@ 38
	.word	0x3c,	    0x62414163,	0x3d01423c, 0x0 	@ 39
	.word	0x0,	    0x181800,	0x1818,	    0x0 	@ 3A
	.word	0x0,	    0x181800,	0x1818,	    0x10200000 	@ 3B
	.word	0x0,	    0x31c60,	0x601c0300, 0x0 	@ 3C
	.word	0x0,	    0x7f00,	0x7f0000,   0x0 	@ 3D
	.word	0x0,	    0x601c03,	0x31c6000,  0x0 	@ 3E
	.word	0x38,	    0x44040810,	0x10001010, 0x0 	@ 3F
	.word	0x1e,	    0x21414d53,	0x51514f40, 0x201f0000 	@ 40
	.word	0x8,	    0x14222241,	0x417f4141, 0x0 	@ 41
	.word	0x7e,	    0x4141417e,	0x4141417e, 0x0 	@ 42
	.word	0x1e,	    0x21404040,	0x4040211e, 0x0 	@ 43
	.word	0x7c,	    0x42414141,	0x4141427c, 0x0 	@ 44
	.word	0x7f,	    0x4040407e,	0x4040407f, 0x0 	@ 45
	.word	0x7f,	    0x4040407e,	0x40404040, 0x0 	@ 46
	.word	0x1e,	    0x21404040,	0x4341211e, 0x0 	@ 47
	.word	0x41,	    0x4141417f,	0x41414141, 0x0 	@ 48
	.word	0x3e,	    0x8080808,	0x808083e,  0x0 	@ 49
	.word	0x1c,	    0x4040404,	0x4044438,  0x0 	@ 4A
	.word	0x42,	    0x44485070,	0x48444442, 0x0 	@ 4B
	.word	0x40,	    0x40404040,	0x4040407f, 0x0 	@ 4C
	.word	0x41,	    0x63555555,	0x49494141, 0x0 	@ 4D
	.word	0x41,	    0x61515149,	0x45454341, 0x0 	@ 4E
	.word	0x1c,	    0x22414141,	0x4141221c, 0x0 	@ 4F
	.word	0x7e,	    0x41414143,	0x7e404040, 0x0 	@ 50
	.word	0x1c,	    0x22414141,	0x41414121, 0x1e030000 	@ 51
	.word	0x7e,	    0x4141417e,	0x42414141, 0x0 	@ 52
	.word	0x3e,	    0x6140603e,	0x301433c,  0x0 	@ 53
	.word	0x7f,	    0x8080808,	0x8080808,  0x0 	@ 54
	.word	0x41,	    0x41414141,	0x4141413e, 0x0 	@ 55
	.word	0x41,	    0x41414122,	0x22221408, 0x0 	@ 56
	.word	0x81,	    0x81819999,	0x99a5a542, 0x0 	@ 57
	.word	0x63,	    0x22141408,	0x14142263, 0x0 	@ 58
	.word	0xc6,	    0x44442810,	0x10101010, 0x0 	@ 59
	.word	0x7f,	    0x3020408,	0x1020607f, 0x0 	@ 5A
	.word	0x1c1010,   0x10101010,	0x10101010, 0x1c000000 	@ 5B
	.word	0x4040,	    0x20201010,	0x8080404,  0x2020000 	@ 5C
	.word	0x380808,   0x8080808,	0x8080808,  0x38000000 	@ 5D
	.word	0x10,	    0x2844c600,	0x0,	    0x0 	@ 5E
	.word	0x0,	    0x0,	0x0,	    0xfe00 	@ 5F
	.word	0x1008,	    0x0,	0x0,	    0x0 	@ 60
	.word	0x0,	    0x1c2202,	0x3e42463a, 0x0 	@ 61
	.word	0x40,	    0x40407c42,	0x4242427c, 0x0 	@ 62
	.word	0x0,	    0x1c2240,	0x4040221c, 0x0 	@ 63
	.word	0x202,	    0x2023e42,	0x4242423e, 0x0 	@ 64
	.word	0x0,	    0x3c4242,	0x7e40623c, 0x0 	@ 65
	.word	0xc10,	    0x10107c10,	0x10101010, 0x0 	@ 66
	.word	0x0,	    0x3c4242,	0x42463a02, 0x2423c00 	@ 67
	.word	0x4040,	    0x40405c62,	0x42424242, 0x0 	@ 68
	.word	0x10,	    0x701010,	0x1010107c, 0x0 	@ 69
	.word	0x8,	    0x380808,	0x8080808,  0x8087000 	@ 6A
	.word	0x4040,	    0x40424448,	0x50684442, 0x0 	@ 6B
	.word	0x1010,	    0x10101010,	0x10101010, 0x0 	@ 6C
	.word	0x0,	    0x764949,	0x49494949, 0x0 	@ 6D
	.word	0x0,	    0x5c6242,	0x42424242, 0x0 	@ 6E
	.word	0x0,	    0x3c4242,	0x4242423c, 0x0 	@ 6F
	.word	0x0,	    0x7c4242,	0x42427c40, 0x40404000 	@ 70
	.word	0x0,	    0x3e4242,	0x42423e02, 0x2020200 	@ 71
	.word	0x0,	    0x2c3220,	0x20202020, 0x0 	@ 72
	.word	0x0,	    0x3c4240,	0x3c02423c, 0x0 	@ 73
	.word	0x10,	    0x107e1010,	0x1010100c, 0x0 	@ 74
	.word	0x0,	    0x424242,	0x4242463a, 0x0 	@ 75
	.word	0x0,	    0x424224,	0x24241818, 0x0 	@ 76
	.word	0x0,	    0x818199,	0x9999a542, 0x0 	@ 77
	.word	0x0,	    0x632214,	0x8142263,  0x0 	@ 78
	.word	0x0,	    0x424242,	0x42423e02, 0x2047800 	@ 79
	.word	0x0,	    0x7e0204,	0x1820407e, 0x0 	@ 7A
	.word	0xc1010,    0x10106010,	0x10101010, 0xc000000 	@ 7B
	.word	0x101010,   0x10101010,	0x10101010, 0x10000000 	@ 7C
	.word	0x601010,   0x10100c10,	0x10101010, 0x60000000 	@ 7D
	.word	0x0,	    0x62,	0x8c000000, 0x0 	@ 7E
	.word	0xffffffff, 0xffffffff,	0xffffffff, 0xffffffff 	@ 7F
