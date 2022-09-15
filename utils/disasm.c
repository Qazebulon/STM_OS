#include <stdio.h>		// include the console I/O function library

	FILE * fin;		// the Input file handle pointer is “fin”
	FILE * fout;		// the Output file handle pointer is “fout”
	int lsbyte=0;		// LSB is saved here (-1 means e.o.f.)
	int msbyte=0;		// MSB (-1 means e.o.f.)
	int byte3=0;		// for 32-bit unstructions
	int byte4=0;		// (same)	"
	int n=0;		// start the byte counter at zero
	int m=0;		// temporary switch variable

void wordx() {	// data processing (modified immediate)
	byte3=getc(fin);	// read a LSByte from the input file
	byte4=getc(fin);	// read a MSByte from the input file
	n++;n++;		// advance the byte counter
	printf("%x\t",256*byte4+byte3);
}

void wordf0() {
	switch (lsbyte & 0xF0) {
		case  (0x00) : printf("and r,r,#\n"); break;	// xF00x
		case  (0x10) : printf("ands r,r,#\n"); break;	// xF01x
		case  (0x20) : printf("bci r,r,#\n"); break;	// xF02x
		case  (0x30) : printf("bcis r,r,#\n"); break;	// xF03x
		case  (0x40) : printf("orr r,r,#\n"); break;	// xF04x
		case  (0x50) : printf("orrs r,r,#\n"); break;	// xF05x
		case  (0x60) : printf("orn r,r,#\n"); break;	// xF06x
		case  (0x70) : printf("orns r,r,#\n"); break;	// xF07x
		case  (0x80) : printf("eor r,r,#\n"); break;	// xF08x
		case  (0x90) : printf("eors r,r,#\n"); break;	// xF09x
		default   : printf("=== F0 not found ===\n"); break;
	}
}

void wordf1() {
	switch (lsbyte & 0xF0) {
		case  (0x00) : printf("add r,r,#\n"); break;	// xF00x
		case  (0x10) : printf("adds r,r,#\n"); break;	// xF01x
		case  (0x40) : printf("adc r,r,#\n"); break;	// xF02x
		case  (0x50) : printf("adcs r,r,#\n"); break;	// xF03x
		case  (0x60) : printf("sbc r,r,#\n"); break;	// xF04x
		case  (0x70) : printf("sbcs r,r,#\n"); break;	// xF05x
		case  (0xa0) : printf("sub r,r,#\n"); break;	// xF06x
		case  (0xb0) : printf("subs r,r,#\n"); break;	// xF07x
		case  (0xc0) : printf("rsb r,r,#\n"); break;	// xF08x
		case  (0xd0) : printf("rsbs r,r,#\n"); break;	// xF09x
		default   : printf("=== F1 not found ===\n"); break;
	}
}

void worde8() {
	switch (lsbyte & 0xF0) {
		case  (0xa0) : printf("!\n"); break;	// xE80x
		case  (0xb0) : printf("pop <rlist>\n"); break;	// xE80x
		default   : printf("=== push/pop not found===\n"); break;
	}
}

void worde9() {
	switch (lsbyte & 0xF0) {
		case  (0x20) : printf("push <rlist>\n"); break;	// xE80x
		case  (0x30) : printf("!\n"); break;	// xE80x
		default   : printf("=== push/pop not found ===\n"); break;
	}
}

void wordea() {
	switch (lsbyte & 0xF0) {
		case  (0x00) : printf("and r,r,r sshift\n"); break;	// xE80x
		case  (0x10) : printf("ands r,r,r shift@\n"); break;	// xE80x
		case  (0x20) : printf("bic r,r,r shift\n"); break;	// xE80x
		case  (0x30) : printf("bics r,r,r shift\n"); break;	// xE80x
		case  (0x40) : printf("orr r,r,r shift\n"); break;	// xE80x
		case  (0x50) : printf("orrs r,r,r shift\n"); break;	// xE80x
		case  (0x60) : printf("orn r,r,r shift\n"); break;	// xE80x
		case  (0x70) : printf("orns r,r,r shift@\n"); break;	// xE80x
		case  (0x80) : printf("eor r,r,r shift\n"); break;	// xE80x
		case  (0x90) : printf("eors r,r,r shift\n"); break;	// xE80x
		case  (0x7c) : printf("pkhbt/tb@\n"); break;	// xE80x
		case  (0x7d) : printf("pkhbt/tb@\n"); break;	// xE80x
		default   : printf("=== EA d.p.w/ missing ===\n"); break;
	}
}

void wordeb() {
	switch (lsbyte & 0xF0) {
		case  (0x00) : printf("add r,r,r shift\n"); break;	// xE80x
		case  (0x10) : printf("adds r,r,r shift@\n"); break;	// xE80x
		case  (0x40) : printf("adc r,r,r shift\n"); break;	// xE80x
		case  (0x50) : printf("adcs r,r,r shift\n"); break;	// xE80x
		case  (0x60) : printf("sbc r,r,r shift\n"); break;	// xE80x
		case  (0x70) : printf("sbcs r,r,r shift\n"); break;	// xE80x
		default   : printf("=== EB d.p.w/ missing ===\n"); break;
	}
}

void wordf8() {
	switch (lsbyte & 0xF0) {
		case  (0x00) : printf("strb r,[r,r,lsl #2]\n"); break;	// xF80x
		case  (0x10) : printf("pld [r,r,lsl #2]@\n"); break;	// xF81x
		case  (0x20) : printf("strh r,[r,r,lsl #2]\n"); break;	// xF82x
		case  (0x30) : printf("ldrb r,[r,#12]@\n"); break;	// xF83x
		case  (0x40) : printf("str r,[r,r,lsl #2]\n"); break;	// xF84x
		case  (0x50) : printf("ldr ??\n"); break;	// xF85x
		case  (0x60) : printf("ldr ??\n"); break;	// x86Xx
		case  (0x70) : printf("ldr ??\n"); break;	// xF87Xx
		case  (0x80) : printf("strb r,[r,#12]\n"); break;	// xF88Xx
		case  (0x90) : printf("pld @?\n"); break;	// xF89x
		case  (0xa0) : printf("strh r,[r,#12]\n"); break;	// xF8Ax
		case  (0xb0) : printf("ldrb r,[r,#12]@\n"); break;	// xF8Bx
		case  (0xc0) : printf("str r,[r,#12]\n"); break;	// xF8Cx
		case  (0xd0) : printf("ldr ??\n"); break;	// xF8Dx
		case  (0xe0) : printf("ldr ??\n"); break;	// xF8Ex
		case  (0xf0) : printf("\n"); break;	// xF8Fx
		default   : printf("=== ldr/str not found ===\n"); break;
	}
}

void wordf9() {
	switch (lsbyte & 0xF0) {
		case  (0x00) : printf("pli @?\n"); break;	// xF90x
		case  (0x10) : printf("ldr ??\n"); break;	// xF91x
		case  (0x20) : printf("ldr ??\n"); break;	// xF92x
		case  (0x30) : printf("ldrsb r[r,#12]@\n"); break;	// xF93x
		case  (0x40) : printf("ldr ??\n"); break;	// xF94x
		case  (0x50) : printf("ldr ??\n"); break;	// xF95x
		case  (0x60) : printf("ldr ??\n"); break;	// x89Xx
		case  (0x70) : printf("ldr ??\n"); break;	// xF97Xx
		case  (0x80) : printf("pli @?\n"); break;	// xF98Xx
		case  (0x90) : printf("pli @?\n"); break;	// xF99x
		case  (0xa0) : printf("ldr ??\n"); break;	// xF9Ax
		case  (0xb0) : printf("ldrsb r,[r#12]\n"); break;	// xF9Bx
		case  (0xc0) : printf("ldr ??\n"); break;	// xF9Cx
		case  (0xd0) : printf("ldr ??\n"); break;	// xF9Dx
		case  (0xe0) : printf("ldr ??\n"); break;	// xF9Ex
		case  (0xf0) : printf("\n"); break;	// xF9Fx
		default   : printf("=== ldr/str not found ===\n"); break;
	}
}

void main () {			// identify where execution should begin
	fin=fopen("temp","r");	// open the object file "fin" for read
	fout=fopen("temp.s","w");	// open the binary file "fout" for write

	while (lsbyte != -1) {	// loop until the end of the data
		lsbyte=getc(fin);	// read a LSByte from the input file
		msbyte=getc(fin);	// read a MSByte from the input file
		printf("L%d\t%x\t",n, 256*msbyte+lsbyte);
		// Yifeng Zhu,Embedded Systems with ARM Cortex-M (Assy. & C)
		// pp.617ff
		switch (msbyte) {
			case  (0) : printf("\tlsl\n"); break;	// x00
			case  (1) : printf("\tlsl\n"); break;
			case  (2) : printf("\tlsl\n"); break;
			case  (3) : printf("\tlsl\n"); break;
			case  (4) : printf("\tlsl\n"); break;
			case  (5) : printf("\tlsl\n"); break;
			case  (6) : printf("\tlsl\n"); break;
			case  (7) : printf("\tlsl\n"); break;
			case  (8) : printf("\tlsr\n"); break;
			case  (9) : printf("\tlsr\n"); break;
			case (10) : printf("\tlsr\n"); break;
			case (11) : printf("\tlsr\n"); break;
			case (12) : printf("\tlsr\n"); break;
			case (13) : printf("\tlsr\n"); break;
			case (14) : printf("\tlsr\n"); break;
			case (15) : printf("\tlsr\n"); break;
			case (16) : printf("\tasr\n"); break;	// x10
			case (17) : printf("\tasr\n"); break;
			case (18) : printf("\tasr\n"); break;
			case (19) : printf("\tasr\n"); break;
			case (20) : printf("\tasr\n"); break;
			case (21) : printf("\tasr\n"); break;
			case (22) : printf("\tasr\n"); break;
			case (23) : printf("\tasr\n"); break;
			case (24) : printf("\tadd\n"); break;
			case (25) : printf("\tadd\n"); break;
			case (26) : printf("\tsub\n"); break;
			case (27) : printf("\tsub\n"); break;
			case (28) : printf("\tadd\n"); break;
			case (29) : printf("\tadd\n"); break;
			case (30) : printf("\tsub\n"); break;
			case (31) : printf("\tsub\n"); break;
			case (32) : printf("\tmov\n"); break;	// x20
			case (33) : printf("\tmov\n"); break;
			case (34) : printf("\tmov\n"); break;
			case (35) : printf("\tmov\n"); break;
			case (36) : printf("\tmov\n"); break;
			case (37) : printf("\tmov\n"); break;
			case (38) : printf("\tmov\n"); break;
			case (39) : printf("\tmov\n"); break;
			case (40) : printf("\tcmp\n"); break;
			case (41) : printf("\tcmp\n"); break;
			case (42) : printf("\tcmp\n"); break;
			case (43) : printf("\tcmp\n"); break;
			case (44) : printf("\tcmp\n"); break;
			case (45) : printf("\tcmp\n"); break;
			case (46) : printf("\tcmp\n"); break;
			case (47) : printf("\tcmp\n"); break;
			case (48) : printf("\tadd\n"); break;	// x30
			case (49) : printf("\tadd\n"); break;
			case (50) : printf("\tadd\n"); break;
			case (51) : printf("\tadd\n"); break;
			case (52) : printf("\tadd\n"); break;
			case (53) : printf("\tadd\n"); break;
			case (54) : printf("\tadd\n"); break;
			case (55) : printf("\tadd\n"); break;
			case (56) : printf("\tsub\n"); break;
			case (57) : printf("\tsub\n"); break;
			case (58) : printf("\tsub\n"); break;
			case (59) : printf("\tsub\n"); break;
			case (60) : printf("\tsub\n"); break;
			case (61) : printf("\tsub\n"); break;
			case (62) : printf("\tsub\n"); break;
			case (63) : printf("\tsub\n"); break;
			case (64) : printf("\tand-eor-lsl-lsr\n"); break;	// x40
			case (65) : printf("\tasr-adc-sbc-ror\n"); break;
			case (66) : printf("\ttst-rsb-cmp-cmn\n"); break;
			case (67) : printf("\torr-mul-bic-mvn\n"); break;
			case (68) : printf("\tadd\n"); break;
			case (69) : printf("\tcmp-***\n"); break;
			case (70) : printf("\tmov\n"); break;
			case (71) : printf("\tbx-blx\n"); break;
			case (72) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (73) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (74) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (75) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (76) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (77) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (78) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (79) : printf("\tldr= r,[pc, imm8<<2]\n"); break;
			case (80) : printf("\tstr r,[r,r]\n"); break;	// x50
			case (81) : printf("\tstr r,[r,r]\n"); break;
			case (82) : printf("\tstrh r,[r,r]\n"); break;
			case (83) : printf("\tstrh r,[r,r]\n"); break;
			case (84) : printf("\tstrb r,[r,r]\n"); break;
			case (85) : printf("\tstrb r,[r,r]\n"); break;
			case (86) : printf("\tldrsb r,[r,r]\n"); break;
			case (87) : printf("\tldrsb r,[r,r]\n"); break;
			// two entries out of order in original table (144-159)
			case (88) : printf("\tstr r,[r,#<<2]\n"); break;
			case (89) : printf("\tstr r,[r,#<<2]\n"); break;
			case (90) : printf("\tstr r,[r,#<<2]\n"); break;
			case (91) : printf("\tstr r,[r,#<<2]\n"); break;
			case (92) : printf("\tstr r,[r,#<<2]\n"); break;
			case (93) : printf("\tstr r,[r,#<<2]\n"); break;
			case (94) : printf("\tstr r,[r,#<<2]\n"); break;
			case (95) : printf("\tstr r,[r,#<<2]\n"); break;
			case (96) : printf("\tldr r,[r,#<<2]\n"); break;	// x60
			case (97) : printf("\tldr r,[r,#<<2]\n"); break;
			case (98) : printf("\tldr r,[r,#<<2]\n"); break;
			case (99) : printf("\tldr r,[r,#<<2]\n"); break;
			case (100): printf("\tldr r,[r,#<<2]\n"); break;
			case (101): printf("\tldr r,[r,#<<2]\n"); break;
			case (102): printf("\tldr r,[r,#<<2]\n"); break;
			case (103): printf("\tldr r,[r,#<<2]\n"); break;
			case (104): printf("\tstrb r,[r,#]\n"); break;
			case (105): printf("\tstrb r,[r,#]\n"); break;
			case (106): printf("\tstrb r,[r,#]\n"); break;
			case (107): printf("\tstrb r,[r,#]\n"); break;
			case (108): printf("\tstrb r,[r,#]\n"); break;
			case (109): printf("\tstrb r,[r,#]\n"); break;
			case (110): printf("\tstrb r,[r,#]\n"); break;
			case (111): printf("\tstrb r,[r,#]\n"); break;
			case (112): printf("\tldrb r,[r,#]\n"); break;	// x70
			case (113): printf("\tldrb r,[r,#]\n"); break;
			case (114): printf("\tldrb r,[r,#]\n"); break;
			case (115): printf("\tldrb r,[r,#]\n"); break;
			case (116): printf("\tldrb r,[r,#]\n"); break;
			case (117): printf("\tldrb r,[r,#]\n"); break;
			case (118): printf("\tldrb r,[r,#]\n"); break;
			case (119): printf("\tldrb r,[r,#]\n"); break;
			case (120): printf("\tstrh r,[r,#<<1]\n"); break;
			case (121): printf("\tstrh r,[r,#<<1]\n"); break;
			case (122): printf("\tstrh r,[r,#<<1]\n"); break;
			case (123): printf("\tstrh r,[r,#<<1]\n"); break;
			case (124): printf("\tstrh r,[r,#<<1]\n"); break;
			case (125): printf("\tstrh r,[r,#<<1]\n"); break;
			case (126): printf("\tstrh r,[r,#<<1]\n"); break;
			case (127): printf("\tstrh r,[r,#<<1]\n"); break;
			case (128): printf("\tldrh r,[r,#<<1]\n"); break;	// x80
			case (129): printf("\tldrh r,[r,#<<1]\n"); break;
			case (130): printf("\tldrh r,[r,#<<1]\n"); break;
			case (131): printf("\tldrh r,[r,#<<1]\n"); break;
			case (132): printf("\tldrh r,[r,#<<1]\n"); break;
			case (133): printf("\tldrh r,[r,#<<1]\n"); break;
			case (134): printf("\tldrh r,[r,#<<1]\n"); break;
			case (135): printf("\tldrh r,[r,#<<1]\n"); break;
			case (136): printf("\tstrh r,[r,#<<2]\n"); break;
			case (137): printf("\tstrh r,[r,#<<2]\n"); break;
			case (138): printf("\tstrh r,[r,#<<2]\n"); break;
			case (139): printf("\tstrh r,[r,#<<2]\n"); break;
			case (140): printf("\tstrh r,[r,#<<2]\n"); break;
			case (141): printf("\tstrh r,[r,#<<2]\n"); break;
			case (142): printf("\tstrh r,[r,#<<2]\n"); break;
			case (143): printf("\tstrh r,[r,#<<2]\n"); break;
			case (144): printf("\tstr r,[sp,#<<2]\n"); break;	// x90
			case (145): printf("\tstr r,[sp,#<<2]\n"); break;
			case (146): printf("\tstr r,[sp,#<<2]\n"); break;
			case (147): printf("\tstr r,[sp,#<<2]\n"); break;
			case (148): printf("\tstr r,[sp,#<<2]\n"); break;
			case (149): printf("\tstr r,[sp,#<<2]\n"); break;
			case (150): printf("\tstr r,[sp,#<<2]\n"); break;
			case (151): printf("\tstr r,[sp,#<<2]\n"); break;
			case (152): printf("\tldr r,[sp,#<<2]\n"); break;
			case (153): printf("\tldr r,[sp,#<<2]\n"); break;
			case (154): printf("\tldr r,[sp,#<<2]\n"); break;
			case (155): printf("\tldr r,[sp,#<<2]\n"); break;
			case (156): printf("\tldr r,[sp,#<<2]\n"); break;
			case (157): printf("\tldr r,[sp,#<<2]\n"); break;
			case (158): printf("\tldr r,[sp,#<<2]\n"); break;
			case (159): printf("\tldr r,[sp,#<<2]\n"); break;	// x9F
			// cps iflags out of order
			// gap a000-afff
			case (176): printf("\tadd-sub sp,sp#<<2\n"); break;	// xB0
			case (177): printf("\tcbz rn,label\n"); break;
			case (178): printf("\tsxth-sxtb-uxth-uxtb r,r\n"); break;
			case (179): printf("\tcbz i:#imm5:0\n"); break;
			case (180): printf("\tpush registers\n"); break;
			case (181): printf("\tpush registers(M)\n"); break;
			case (182): printf("\tcps iflags\n"); break;		// xB6
			// gap b700-b9ff
			case (186): printf("\trev-rev16-revsh r,r\n"); break;	// xBA
			case (187): printf("\tcbnz i:imm5:0\n"); break;
			case (188): printf("\tpop registers\n"); break;
			case (189): printf("\tpop registers(P)\n"); break;
			case (190): printf("\tbkpt imm8\n"); break;		// xBE
			case (191): printf("\tnop-yield-wfe-sev-it{x{y{z}}} condition\n"); break;
			// gap c000-cfff
			case (208): printf("\tbeq #imm8<<1\n"); break;	// xD0
			case (209): printf("\tbne #imm8<<1\n"); break;
			case (210): printf("\tbcs #imm8<<1\n"); break;
			case (211): printf("\tbcc #imm8<<1\n"); break;
			case (212): printf("\tbmi #imm8<<1\n"); break;
			case (213): printf("\tbpl #imm8<<1\n"); break;
			case (214): printf("\tbvs #imm8<<1\n"); break;
			case (215): printf("\tbvc #imm8<<1\n"); break;
			case (216): printf("\tbhi #imm8<<1\n"); break;
			case (217): printf("\tbls #imm8<<1\n"); break;
			case (218): printf("\tbge #imm8<<1\n"); break;
			case (219): printf("\tblt #imm8<<1\n"); break;
			case (220): printf("\tbgt #imm8<<1\n"); break;
			case (221): printf("\tble #imm8<<1\n"); break;
			case (222): printf("\tbal #imm8<<1\n"); break;
			case (223): printf("\tsvc #imm8\n"); break;
			case (224): printf("\tb #imm11<<1\n"); break;	// xE0
			case (225): printf("\tb #imm11<<1\n"); break;
			case (226): printf("\tb #imm11<<1\n"); break;
			case (227): printf("\tb #imm11<<1\n"); break;
			case (228): printf("\tb #imm11<<1\n"); break;
			case (229): printf("\tb #imm11<<1\n"); break;
			case (230): printf("\tb #imm11<<1\n"); break;
			case (231): printf("\tb #imm11<<1\n"); break;	// xE7
			//
			case (232): wordx(); worde8(); break;		// E8 multiple
			case (233): wordx(); worde9(); break;		// E9 multiple
			case (234): wordx(); wordea(); break;		// EA
			case (235): wordx(); wordeb(); break;		// EB
			// gap ec00-efff
			case (240) : wordx(); wordf0(); break; 			// xF0
			case (241) : wordx(); wordf1(); break;			// xF1
			case (244) : wordx(); printf("=== r15 immediate? ===a\n"); break; //F4
			case (245) : wordx(); printf("=== r15 immediate? ===b\n"); break; //F5
			//
			case (247) : wordx(); printf("Proprietary Command\n"); break; // xF7
			case (248) : wordx(); wordf8(); break;		// xF8
			case (249) : wordx(); wordf9(); break;		// xF9

			default   : printf("\t====== not found ======1\n"); break;
		}
		n++;n++;		// advance the byte counter
	}
	fclose(fin);		// close both the input and output files
	fclose(fout);
}

// usage:
//
//	nano stmld.c
//	gcc -o stmld stmld.c
//	./stmld
