//STM computer //home/pi/stm32/v4/jubes/bci.s (~bci.j01) 2021.10.31
//----------------------------------------------------------------------
// ToDo:
// *** Can't return to the command-line with blx calls
// (bx is OK) to RXin or TXout ***
// [add esc I/O] & Re-assign key-codes (for keyboard)
// insert lines	delete lines	test byte-code subroutine call (code?)
// wait counter	ap,aq (P,Q) (or other) combinations?
// I/O hi lo in	display-touch	use cbpeek (& apply), chpeek, chpoke
// simple 0-9		use cno_op	read left byte from string
// ***	Fast Clock	Compiler	Teaching machine
// Terminator??	a-f trouble
//
//	 Byte-Code Jump Table: (jump-table base pointer saved in r10)
	// Use Red
jTable:	.word bcExit+1	// 00	byte-code Exit (return to any caller)
	.word bcExec+1	// 01	byte-code Execute
	.word echo00+1	// 02			//
	.word case00+1	// 03 ^c 		// ^c
	.word cpinlo+1	// 04			// ^d #-pull down
	.word cpinhi+1	// 05			// ^e #-pull high
	.word cpinin+1	// 06			// ^f #-pin high?
	.word echo00+1	// 07 bell		// ^g
	.word echo00+1	// 08 BS		// ^h
	.word echo00+1	// 09 TAB		// ^i
	.word cacrlf+1	// 0A LF (crlf)		// ^j
	.word case00+1	// 0B UP 		// ^k
	.word echo00+1	// 0C CLR EOL, Page 	// ^l
	.word caslin+1	// 0D CR (L.F.)		// ^m
	.word cLCD16+1	// 0E			// ^n LCD data 16
	.word cLCDd8+1	// 0F			// ^o LCD data 8
	.word cpause+1	// 10			// ^p #-pause
	.word caini1+1	// 11			// ^q LCD init 1
	.word caini2+1	// 12			// ^r LCD init 2
	.word calsel+1	// 13			// ^s LCDsel
	.word catsel+1	// 14			// ^t Tchsel
	.word causel+1	// 15			// ^u uSDsel (up?)
	.word cLCDc8+1	// 16			// ^v LCD control
	.word catest+1	// 17			// ^w 11-29-13 test
	.word echo00+1	// 18 Exit		// ^x
	.word echo00+1	// 19			// ^y
	.word echo00+1	// 1A EOF		// ^z
	.word dspkyb+1	// 1B			// ^[ L.C. Keyboard
	.word ctrkyb+1	// 1C			// ^\ Ctrl Keyboard
	.word shfkyb+1	// 1D			// ^] U.C. Keyboard
	.word echo00+1	// 1E			// ^^
	.word echo00+1	// 1F			// ^_
	// use white
	.word casspa+1	// 20 space
	.word casnot+1	// 21 ! (not)
	.word casdup+1	// 22 " (dupe)
	.word cimwrd+1	// 23 #	immediate (soon to be "word" hex number)
	.word casimm+1	// 24 $ immediate string
	.word casmod+1	// 25 % (mod)
	.word casand+1	// 26 & (and)
	.word cimmnm+1	// 27 ' Immediate number
	.word casalt+1	// 28 ( Invoke alternate function of next character
	.word casebs+1	// 29 ) backspace
	.word casmul+1	// 2A * (mul)
	.word casadd+1	// 2B + (add)
	.word casnop+1	// 2C , nop
	.word cassub+1	// 2D - (sub)
	.word cchain+1	// 2E . (byte-code-string return)
	.word casdiv+1	// 2F / (div)
	.word casnum+1	// 30 0 (digit)
	.word casnum+1	// 31 1	 "
	.word casnum+1	// 32 2	 "
	.word casnum+1	// 33 3	 "
	.word casnum+1	// 34 4	 "
	.word casnum+1	// 35 5	 "
	.word casnum+1	// 36 6	 "
	.word casnum+1	// 37 7	 "
	.word casnum+1	// 38 8	 "
	.word casnum+1	// 39 9	 "
	.word cassto+1	// 3A : (:= store)
	.word casrst+1	// 3B ;	(=: reverse store)
	.word caslth+1	// 3C < (<)
	.word casequ+1	// 3D = (==)
	.word casgth+1	// 3E > (>)
	.word caspri+1	// 3F ? (print)
	//
	.word casloa+1	// 40 @ (fetch)
	.word casabs+1	// 41 A (abs)
	.word casbyt+1	// 42 B (output hex Byte)
	.word caschr+1	// 43 C (output one Character)
	.word cdecin+1	// 44 D	decimal in + terminator
	.word bcExec+1	// 45 E Execute$ (byte-code)
	.word casfal+1	// 46 F (false)
	.word casgeq+1	// 47 G (>=)
	.word cashwo+1	// 48 H (output hex Halfword)
	.word cassin+1	// 49 I input$
	.word cajoin+1	// 4A J	Join$
	.word cakomp+1	// 4B K	Kompare$
	.word casleq+1	// 4C L (<=)
	.word caslen+1	// 4D M Length($) (measure length)
	.word casneq+1	// 4E N (!=)
	.word cassot+1	// 4F O output$
	.word caleft+1	// 50 P Left$
	.word casget+1	// 51 Q Get$
	.word cright+1	// 52 R	Right$
	.word castor+1	// 53 S	Store$
	.word castru+1	// 54 T (true)
	.word casupr+1	// 55 U (unsigned print)
	.word cVtest+1	// 56 V (test Y)
	.word caswor+1	// 57 W (output hex word)
	.word cassqr+1	// 58 X (square?)
	.word cYtest+1	// 59 Y (if then goto)
	.word chexin+1	// 5A Z hex in + terminator
	.word casedo+1	// 5B [ do
	.word caswap+1	// 5C \ swap top two entries
	.word cuntil+1	// 5D ] until
	.word casxor+1	// 5E ^ xor
	.word csdrop+1	// 5F _ (string drop)
	//
	.word casdro+1	// 60 ` (number drop)
	.word cainc2+1	// 61 a incriment (advance) [need decriment too]
	.word casbak+1	// 62 b Background Color
	.word cascol+1	// 63 c Column
	.word casfnt+1	// 64 d Font Size
	.word casexd+1	// 65 e execute from dstack
	.word casfor+1	// 66 f f.g.
	.word cas0go+1	// 67 g goto if==0 (stay and do if "true")
	.word chedit+1	// 68 h hex edit (change RAM)
	.word cindex+1	// 69 i {loop index}
	.word 0x20001101 //6A j jump to default RAM location (20001100)
	.word caskey+1	// 6B k input single key-code
	.word cuelin+1	// 6C l cue to line number		EDIT
	.word c0test+1	// 6D m 
	.word casnib+1	// 6E n output hex nibble
	.word casrow+1	// 6F o Set Display Row
	.word cbpeek+1	// 70 p byte "peek"
	.word cbpoke+1	// 71 q byte "poke" (poQue)
	.word caspsr+1	// 72 r pseudo-random number ***
	.word cassqr+1	// 73 s square root
	.word casxfr+1	// 74 t block xfer
	.word casvar+1	// 75 u --- variable ---
	.word cverif+1	// 76 v verify (type) number of lines	EDIT
	.word cwrite+1	// 77 w write text (insert)
	.word casimh+1	// 78 x immediate hex number
	.word ciltst+1	// 79 y dump a block of RAM
	.word casezz+1	// 7A z	cue up RAM
	.word cloops+1	// 7B { loops
	.word casorr+1	// 7C | (or)
	.word caloop+1	// 7D } loop
	.word caschs+1	// 7E ~ (chs)
	.word case00+1	// 7F (delta)
	//  Green			CONTROL-ALT:	// Use Green
	.word casvar+1	// 80 @		+------------------------------+
	.word casvar+1	// 81 A		| These are all Variable Names |
	.word casvar+1	// 82 B		+------------------------------+
	.word casvar+1	// 83 C
	.word casvar+1	// 84 D		*** EXIT WINDOW ***
	.word casvar+1	// 85 E
	.word casvar+1	// 86 F
	.word casvar+1	// 87 G
	.word casvar+1	// 88 H
	.word casvar+1	// 89 I
	.word casvar+1	// 8A J
	.word casvar+1	// 8B K
	.word casvar+1	// 8C L
	.word casvar+1	// 8D M		*** SHUT DOWN ***
	.word casvar+1	// 8E N
	.word casvar+1	// 8F O
	.word casvar+1	// 90 P
	.word casvar+1	// 91 Q
	.word casvar+1	// 92 R
	.word casvar+1	// 93 S		???
	.word casvar+1	// 94 T		*** NEW WINDOW ***
	.word casvar+1	// 95 U
	.word casvar+1	// 96 V
	.word casvar+1	// 97 W
	.word casvar+1	// 98 X		???
	.word casvar+1	// 99 Y
	.word casvar+1	// 9A Z
	.word casvar+1	// 9B [		???
	.word casvar+1	// 9C \
	.word casvar+1	// 9D ]
	.word casvar+1	// 9E ^		???
	.word casvar+1	// 9F _
	// Green			ALT:	// Use Green
	.word case00+1	// A0 space	???
	.word case00+1	// A1 !
	.word case00+1	// A2 "
	.word case00+1	// A3 #
	.word case00+1	// A4 $
	.word case00+1	// A5 %
	.word case00+1	// A6 &
	.word case00+1	// A7 '
	.word case00+1	// A8 (
	.word case00+1	// A9 )
	.word case00+1	// AA *
	.word case00+1	// AB +
	.word case00+1	// AC ,
	.word case00+1	// AD -
	.word case00+1	// AE .
	.word case00+1	// AF /
	.word case00+1	// B0 0
	.word case00+1	// B1 1
	.word case00+1	// B2 2
	.word case00+1	// B3 3
	.word case00+1	// B4 4
	.word case00+1	// B5 5
	.word case00+1	// B6 6
	.word case00+1	// B7 7
	.word case00+1	// B8 8
	.word case00+1	// B9 9
	.word case00+1	// BA :
	.word case00+1	// BB ;
	.word case00+1	// BC <
	.word case00+1	// BD =
	.word case00+1	// BE >
	.word case00+1	// BF ?
	// Blue				ALT-SHIFT:	// Use Blue
	.word case00+1	// C0 @	
	.word case00+1	// C1 A			ACK "." ==0x79 "x" !=0x79
	.word cerase+1	// C2 B erase device (Blank)
	.word cacopy+1	// C3 C copy device
	.word cpause+1	// C4 D	delay (pause)
	.word crx2lc+1	// C5 E Echo RX to LCD (works)
	.word casfp5+1	// C6 F flash pointer set r5 to base pointer
	.word case00+1	// C7 G
	.word cpinhi+1	// C8 H pin high (oin?)
	.word cpinin+1	// C9 I pin in
	.word case00+1	// CA J
	.word case00+1	// CB K
	.word cpinlo+1	// CC L pin low
	.word case00+1	// CD M
	.word case00+1	// CE N
	.word clouto+1	// CF O	lOcal Output Only
	.word csetxy+1	// D0 P pset (point set)
	.word cgetxy+1	// D1 Q query pen position
	.word caRXin+1	// D2 R RX-in Read
	.word clcdou+1	// D3 S screen LCDout
	.word cpento+1	// D4 T pen touch (and pressure)
	.word cpenre+1	// D5 U pen Up (release)
	.word cexera+1	// D6 V extended-erase device
	.word cprgrm+1	// D7 W Device Programmer
	.word cTXout+1	// D8 X TX-out
	.word FDterm+1	// D5 Y Full Duplex Treminal
	.word HDterm+1	// D6 Z Hald Duplex Terminal
	.word case00+1	// DB [	Flsh Program Key
	.word case00+1	// DC \`Flash Program Write
	.word case00+1	// DD ] Flash Program Terminate
	.word case00+1	// DE ^
	.word case00+1	// DF _
	// Blue				ALT:	// Use Blue
	.word case00+1	// E0 `
	.word case00+1	// E1 a			ACK "." ==0x79 "x" !=0x79
	.word cerase+1	// E2 b Erase device (Blank, low density)
	.word cacopy+1	// E3 c Copy device
	.word cpause+1	// E4 d	delay (pause)
	.word crx2lc+1	// E5 e Echo RX to LCD (works)
	.word casfp5+1	// E6 f flash program set r5 to base pointer
	.word case00+1	// E7 g
	.word cpinhi+1	// E8 h pin high (oin?)
	.word cpinin+1	// E9 i pin in
	.word case00+1	// EA j
	.word case00+1	// EB k
	.word cpinlo+1	// EC l pin low
	.word case00+1	// ED m
	.word case00+1	// EE n
	.word clouto+1	// EF o	lOcal Output Only
	.word csetxy+1	// F0 p pset (point set)
	.word cgetxy+1	// F1 q query pen position
	.word caRXin+1	// F2 r RX-in Read
	.word clcdou+1	// F3 s screen LCDout
	.word cpento+1	// F4 t pen touch (and pressure)
	.word cpenre+1	// F5 u pen Up (release)
	.word cexera+1	// F6 v erase device (high density)
	.word cprgrm+1	// F7 w Device Programmer
	.word cTXout+1	// F8 x TX-out
	.word FDterm+1	// F5 y Full Duplex Treminal
	.word HDterm+1	// F6 z Hald Duplex Terminal
	.word casfpk+1	// FB {	Flath Program Key
	.word casfpw+1	// FC | Flash Program Write
	.word casfpt+1	// FD } Flash Program Terminate
	.word cassys+1	// FE ~ fetch system registsers 7,10-13
	.word case00+1	// FF xxx
//
//	.word case00+1	// E5 e		*** MENU
//	.word case00+1	// E6 f		*** MENU
//	.word case00+1	// E8 h		*** MENU
//	.word case00+1	// F3 t		*** MENU

//======================================================================
//
// Register assignments:
//
//	r15	Program counter
//	r14	Link register
//	r13	C-Stack pointer
//	r12	Configutration base (M3,M4)
//	r11	Byte-code pointer
//	r10	Jump-table base
//	r8-9	Spare
//	r7	D-Stack pointer
//	r6	Top of D-Stack
//	r1-5	Spare
//	r0	Pass parameters

//======================================================================
//
//  Logic Routines

	// Logic
casand:	ldr r0,[r7,#-4]! // pop data
	ands r6,r0	// and
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

casorr:	ldr r0,[r7,#-4]! // pop data
	orrs r6,r0	// or
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

casxor:	ldr r0,[r7,#-4]! // pop data
	eors r6,r0	// eor, xor
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

casnot:	mvns r6,r6	// not: compliment all bits
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// Comparison
	// <
caslth:	ldr r0,[r7,#-4]! // pop data
	cmp r0,r6	// compare
	mov r6,#0	// (0) default false (don't mess up flags)
	.hword 0xBFB8	// it: if lt, then ...
	.hword 0x43F6	//mvn r6,r6 // (-1) true if condition met
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// ==
casequ:	ldr r0,[r7,#-4]! // pop data	(good trick)
	sub r6,r0	// 0 only if same
	subs r6,#1	//-1 borrow only if same
	sbc r6,r6	// 0 (F) unless borrow -1 (T)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// >
casgth:	ldr r0,[r7,#-4]! // pop data
	cmp r0,r6	// compare
	mov r6,#0	// (0) default false (don't mess up flags)
	.hword 0xBFC8	// it: if gt, then ...
	.hword 0x43F6	//mvn r6,r6 // (-1) true if condition met
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// <=
casleq:	ldr r0,[r7,#-4]! // pop data
	cmp r0,r6	// compare
	mov r6,#0	// (0) default false (don't mess up flags)
	.hword 0xBFD8	// it: if le, then ...
	.hword 0x43F6	//mvn r6,r6 // (-1) true if condition met
//	it le
//	mvn r6,r6
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// !=
casneq:	ldr r0,[r7,#-4]! // pop data
	cmp r0,r6	// 0 only if same
	mov r6,#0	// (0) default false (don't mess up flags)
	.hword 0xBF18	// it: if ne, then ...
	.hword 0x43F6	//mvn r6,r6 // (-1) true if condition met
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// >=
casgeq:	ldr r0,[r7,#-4]! // pop data
	cmp r0,r6	// compare
	mov r6,#0	// (0) default false (don't mess up flags)
	.hword 0xBFA8	// it: if ge then ... (0xBFA8)
	.hword 0x43F6	//mvn r6,r6 // (-1) true if condition met
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// True
castru:	str r6,[r7],#4	// push old top
true:	mvn r6,#0	// put T on top of dstakk
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// False
casfal:	str r6,[r7],#4	// push old top
false:	movs r6,#0	// put F on top of dstakk (don't save flags)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//----------------------------------------------------------------------
//
//  Number Routines

	// system snoop: fetch r7,r10-r13
cassys:	str r6,[r7],#4	// push old top
	mov r6,r13	// get r13	c-stack pointer
	str r6,[r7],#4	// push old top
	mov r6,r12	// get r12	configuration base
	str r6,[r7],#4	// push old top
	mov r6,r11	// get r11	byte code pointer
	str r6,[r7],#4	// push old top
	mov r6,r10	// get r10	jump table base
	str r6,[r7],#4	// push old top
	mov r6,r7	// get r7	d-stack pointer
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

casimd:	// for new "#" (presently "m" cimwrd)

	// Number (0-9)
casnum:	str r6,[r7],#4	// push old top
	and r0,#0x0f	// just lsn
	mov r6,r0	// put on top of dstakk
	//
	mov r2,#10	// use base 10
idinlp:	ldrb r0,[r11],#1 // fetch 'char and cue to next command
	cmp r0,#0x30
	blt idxit	// check for <"0"
	cmp r0,#0x39
	bgt idxit	// check for >"9"
	and r0,#0x0f	// just lsn
	//		//mul r6,r2 (error or returns 32-bit version)
	.hword 0x4356	// short multiply: 0100 0011 01nn nddd n->d (r6=r6*r2)
	and r0,#0x0f	// just lsn of r0
	adds r6,r0	// add new nibble (from r0)
	b idinlp	// loop until non-hex char
	//
idxit:	// then, simply execute the terminator as the next command:
ihxit:	ldr r15,[r10,r0,lsl #2]	 // same exit label as for below

	// immediate hexadecimal number
casimh:	str r6,[r7],#4	// push old top
	mov r6,#0	// zero target (r6)
	//
ihinlp:	ldrb r0,[r11],#1 // fetch 'char and cue to next command
	mov r1,r0	// make working copy (r1) to mess up
	cmp r0,#0x30
	blt ihxit	// check for <"0" (above)
	cmp r0,#0x39
	ble ihxok	// check for >"9"
	//
	ands r1,#0xDf	// make all uppercase
	cmp r1,#0x41
	blt ihxit	// check for <"A" (above)
	cmp r1,#0x46
	bgt ihxit	// check for <="F" (above)
	subs r1,#0x07	// turn A,B,C,D,E,F -> :,;,<,=,>,?
	//
ihxok:	and r1,#0x0f	// just lsn
	lsls r6,#4	// shift r2 4-bits
	adds r6,r1	// add new nibble
	//
	b ihinlp	// loop until non-hex char

	// ' Immediate character (number)
cimmnm:	str r6,[r7],#4	// push old top
	ldrb r6,[r11],#1 // fetch 'char and cue to next command
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// ' Immediate word (number)
cimwrd:	str r6,[r7],#4	// push old top
	ldr r6,[r11],#4 // fetch word and cue to next command
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// Memory:
// @
casloa: ldr r6,[r6]	// replace address with data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// @ :=
casfco:	ldr r6,[r6]	// replace address with data (copy)
// :=
cassto:	ldr r0,[r7,#-4]! // pop target address
	str r6,[r0]	 // store data at that address
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// @ =:
casfrc:	ldr r6,[r6]	// reverses order of address and data
// =: (as, or reverse store)
casrst: ldr r0,[r7,#-4]! // pop data (previous)
	str r0,[r6]	 // store it at (current) target address
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// p poke (store) byte
cbpoke:	ldr r0,[r7,#-4]! // pop data to store
	strb r0,[r6]	 // store data at the poke address
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// peek (load) byte *****
cbpeek:	ldrb r6,[r6]	// load data byte from address
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// poke (store) halfword *****
chpoke:	ldr r0,[r7,#-4]! // pop target address
	strh r6,[r0]	 // store data at that address
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// peek (load) halfword *****
chpeek:
	ldrh r6,[r6]	 // load data from address
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//----------------------------------------------------------------------
//
//  Math Routines

// @ add
casfad:	ldr r6,[r6]	// replace address with data
// add
casadd:	ldr r0,[r7,#-4]! // pop data
	//add r6,r0	// add
	.hword 0x1836
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ sub
casfsu:	ldr r6,[r6]	// replace address with data
// sub
cassub:	ldr r0,[r7,#-4]! // pop data
	//sub r6,r0,r6	// subtract new from old
	.hword 0x1b86
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ mul
casfmu:	ldr r6,[r6]	// replace address with data
// mul
casmul:	ldr r0,[r7,#-4]! // pop data
	//mul r6,r0	// (error or returns 32-bit version)
	.hword 0x4346	// short multiply: 0100 0011 01nn nddd n->d
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ div
casfdv:	ldr r6,[r6]	// replace address with data
// div
casdiv:	ldr r0,[r7,#-4]! // pop data
	sdiv r6,r0,r6	// signed divide old by new
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// modulo division
casmod:	ldr r0,[r7,#-4]! // pop old (r0) data
	sdiv r1,r0,r6	// signed divide old (r0) by new (r6)
	mul r2,r1,r6	// multiply result (r1) by new (r6)
	sub r6,r0,r2	// subtract product (r2) from old (r0)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//incriment
casinc:	ldr r1,[r6]	// fetch variable
	adds r1,#1	// incriment it
	str r1,[r6]	// and save it
	ldr r6,[r7,#-4]! //pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// "a" (@++) incriment after fetch
cainc2:	mov r0,r6	// copy (save) original u.ptr(r0)
	ldr r6,[r0]	// fetch memptr(new r6) using u.ptr(r0)
	adds r1,r6,#1	// incriment memptr (to r1) (return original)
	str r1,[r0]	// and save incrimented copy to saved u.ptr
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//decriment
casdec:	ldr r1,[r6]	// fetch variable
	subs r1,#1	// decriment it
	str r1,[r6]	// and save it
	ldr r6,[r7,#-4]! //pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ abs
casfab:	ldr r6,[r6]	// replace address with data
// abs
casabs: ands r6,r6	// check sign
	it mi
	negmi r6,r6	// make positive if minus
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ chs
casfch:	ldr r6,[r6]	// replace address with data
// chs
caschs:	neg r6,r6	// make negative
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ square
casfsq:	ldr r6,[r6]	// replace address with data
// square
cassqu:	//mul r6,r6,r6	// multiply by self
	//mul r6,r06	// (error or returns 32-bit version)
	.hword 0x4376	// short multiply: 0100 0011 01nn nddd n->d
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// @ sqrt
casfsr:	ldr r6,[r6]	// replace address with data
// sqrt
cassqr:			// square root
	clz r0,r6	// count leading zeros
	mov r1,#0xd743	// first guess (was: e000)
	mvn r2,#0	// no n-1 guess
	//
	lsrs r0,r0,#1	// half, and test for lsb
	bcc sqrl1
	mov r1,#0x9838	// adjusted first guess (was: a000)
	//
sqrl1:	cbz r0,aprxlp	// goto approximation loop when r0==0
	lsrs r1,r1,#1	// half of guess
	subs r0,#1	// for each count
	b sqrl1
	//
aprxlp:	mov r3,r2	// uddate history (n-2)
	mov r2,r1	// (n-1)
	//
	udiv r1,r6,r2	// unsigned divide #/guess
	add r1,r1,r2	// #/guess + guess
	lsrs r1,r1,#1	// /2 for average
	//
	cmp r1,r2	// check for exact match
	beq sqrxit	//	(exit if found)
	cmp r1,r3	// check for repeating pattern
	bne aprxlp	//	(keep going if neither)
	cmp r1,r2	// which is smaller?
	bmi sqrxit	//	(use the smaller)
	mov r1,r2	//	(whichever it was)
sqrxit:	mov r6,r1	// return first (2nd) guess
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// forth
// dupe
casdup:	str r6,[r7],#4	// push old top
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// swap (switch top two entries)
caswap:	mov r0,r6	// hold old top of stack
	ldr r6,[r7,#-4]! // pop new top of stack
	str r0,[r7],#4	// push old top of stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// drop	supported: casdro: (end-part of drop-string routine)

// get next pseudo-random number
//	x ^= x << 13;	x ^= x >> 17;	x ^= x << 5;
caspsr:
	mov r1,#0x20000000	// cue to ram
	ldr r0,[r1,#psrnd]	// fetch old rnd number
	eor r0,r0,r0,lsl #13			// ^ <<13
	eor r0,r0,r0,lsr #17	// randomize	// ^ >>17
	eor r0,r0,r0,lsl #5			// ^ <<5
	str r0,[r1,#psrnd]	// save new rnd number
	str r6,[r7],#4  	// push old top
	mov r6,r0       	// put rnd number on top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//======================================================================
//
//  String Routines:

// String Output
cassot:		// String Output:
	mov r0,r6	// cue to beginning of string
					// (pointer from top of D-Stack)
	mov r1,#0	// terminate  string with zero
	strb r1,[r7],#1 // (push zero onto D-Stack)
	mov r7,r6	// and drop the string from the D-Stack
	bl string	// output the string (to the terminating zero)
	ldr r6,[r7,#-4]! // finally, cue up (pop) the next number
					// from the D-Stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// String Input
cassin:		// String Input (until C.R.)
	str r6,[r7],#4	// push old top-of-D-stack data
	mov r5,r7	// save new (beginning of string)
					// D-stack pointer in r5
	mov r4,#0	// set character counter to zero
strilp:	bl RXbios		// read a key
	//
	cmp r0,#10	// is it a L.F.?	// (touch)
	beq strind	// then exit
	cmp r0,#8	// is it a backspace?
	beq stribs	// then remove character
	cmp r0,#7	// alternate Linux backspace?
	beq stribs	// still remove character
	//
	add r4,#1	// else incriment character counter
	strb r0,[r7],#1 // and push Byte on D-Stack
	bl TXbios	// output it
	b strilp	// and go get another character
stribs:		// backspace
	cmp r4,#0
	beq strilp	// skip if string is zero length
	//
	bl bckspc	// remove character from screen
	ldrb r1,[r7,#-1]! // discard last character from Dstack
	sub r4,#1	// decriment character counter
	b strilp
strind:		// C.R.
	mov r0,#0
	strb r0,[r7],#1	// terminate string with zero
						// (needed for execute)
	mov r6,r5	// put pointer to string beginning on
						// top-of-D-Stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// String "Immediate" (from code)
casimm:		// Immediate $
	str r6,[r7],#4	// push old top of D-stack
	mov r6,r7	// cue r6 to beginning of new string
simmlp:
	ldrb r0,[r11],#1 //get next byte for the string (from code)
	strb r0,[r7],#1	// push it onto the D-stack
	ands r0,r0	// check for end-of-string (asciiz 0)
	bne simmlp	// loop until done
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// String Load
casget:		// Load$ - from address (in r6) on top of d-stack
	mov r5,r7	// save D-stack pointer (pointer to string start)
sgetlp:	ldrb r0,[r6],#1	// read a byte from memory
	strb r0,[r7],#1	// push it onto the d-stack
	ands r0,r0	// watch for terminating "0"
	bne sgetlp	// loop until done
	//
	mov r6,r5	// update top of stack (pointer to string start)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// String Store
castor:		// Store$
	mov r7,r6	// drop string from d-stack
					// (next d-stack to $-start)
	ldr r5,[r7,#-4]! //pop memory target from dstack
storlp:
	ldrb r0,[r6],#1	// get byte (dropped from old d-stack position)
	strb r0,[r5],#1	// store it in memory target
	ands r0,r0	// watch for terminating "0"
	bne storlp	// loop until done (includes the "0")
	//
	ldr r6,[r7,#-4]! // finally, cue up (pop) the next number
						// from the D-Stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// String Join (+$)
cajoin:		// Join$
	mov r5,r6	// cue r5 to start of 2nd string
	mov r7,r6	// drop 2nd string from dstack
	ldr r6,[r7,#-4]! //pop 1st string's start from dstack
	subs r7,#1	// then cue back 1 byte
joinlp:				// (to drop its terminating "0")
	ldrb r0,[r5],#1	// get byte (dropped from dstack)
	strb r0,[r7],#1	// store it in memory target
	ands r0,r0	// watch for terminating "0"
	bne joinlp	// loop until done (includes the "0")
	//
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// String Compare (=$)
cakomp:		// Compare$
	mov r5,r6	// cue r5 to start of 2nd string
	mov r7,r6	// also adjust dstack pointer
	ldr r4,[r7,#-4]! //pop start of 1st string from dstack
	mov r7,r4	// and adjust dstack pointer again
	mov r6,#0	// put "false" on new top of dstack
komplp:
	ldrb r0,[r5,#1]! // get byte from 2nd string
	ldrb r1,[r4,#1]! // get matching byte from 1st string
	cmp r0,r1	// compare bytes
	bne kompF	// false if different
	ands r0,r0	// check for end
	bne komplp	// loop until done
	//		// if we get to here, then
kompT:	mvn r6,r6	// Change "False" in r6 to "True"
kompF:	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// Right$
cright:		// Right$
	mov r3,r6	// r3 = save length
	ldr r6,[r7,#-4]! // r6 = begin (also beginning of destination)
						//  r7 => now end
	sub r1,r7,r3	// r1 is cued to beginning of source fraction

	cmp r1,r7	// r1 must be <= r7 (end)
	it gt
	movgt r1,r7
	mov r7,r6	// cue d-stack to bottom of destination

	cmp r1,r6	// r1 must be >= r6 (begin)
	ble rgstnd

rgstlp:	ldr r0,[r1],#1	// move from source
	str r0,[r7],#1	// to destination (beginning at start of string)
	subs r3,#1	// for rach byte of length
	bne rgstlp	// until done
rgstnd:			// leave same old start pointer
						// on top of stack r6
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// Left$
caleft:		// Left$	// [r7] = begin  r6= new length
	ldr r0,[r7,#-4]!	// r0 = begin  r7 = end
	add r1,r0,r6		// r1 = new end = begin + new length

	cmp r1,r0	// r1 must be >= r0 (begin)
	it lt
	movlt r1,r0
	cmp r1,r7	// r1 must be <= r7 (end)
	it gt
	movgt r1,r7

	mov r7,r1	// cue D-stack pointer to new end of string
	mov r6,r0	// put same old start pointer on top of stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// Length
caslen:		// Length$	r6= start pointer r7= end pointer end
	mov r1,r7	// save end pointer
	mov r7,r6	// cue dstack to r6 (now points to string start)
	sub r6,r1,r6	// r6= return length (end pointer-start pointer)
	subs r6,#1
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// Drop both r6 (string pointer) and string from dstack
					// (or just the pointer r6)
csdrop:	mov r7,r6	// cue D-stack to beginning of string
					// (drop the string)
casdro:	ldr r6,[r7,#-4]! // pop the next number from the D-Stack
					// (drop the string pointer)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//----------------------------------------------------------------------
//
// Control Routines:

casedo:		// [ do
	push {r11}	// push byte-code pointer onto c-stack
						// (loop start)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

cuntil:		// ] until
	pop {r0}	// remove loop-start from c-stack
	ands r6,r6	// test condition for true (if!=0)
	bne untmet	// exit if true
//keep looping:
	push {r0}	// else, restore loop-start pointer
	mov r11,r0	// and cue the byte-code pointer back to it
untmet:
	ldr r6,[r7,#-4]! // remove condition from d-stack top
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

cloops:		// { set number of loops, and maek start of loop
	push {r6,r11}	// push loops and byte-code pointer
					// (loop start) onto c-stack
	ldr r6,[r7,#-4]! // drop loop-counts from top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

caloop:		// } loop
	pop {r0,r1}	// pop loops and loop start off of c-stack
	subs r0,#1	// decriment loop counter
	beq loopmt	// exit loop if done
// keep looping
	push {r0,r1}	// else keep looping: put info back on c-stack
	mov r11,r1	// and cue byte-code pointer back to loop start
loopmt:	// (merge here to exit loop)
	ldrb r0,[r11],#1
	ldr r15,[r10,r0,lsl #2]

// {i is loop index}
cindex:	str r6,[r7],#4	// push old to to make room
	ldr r6,[r13]	// grab loop counter from c-stack
	ldrb r0,[r11],#1
	ldr r15,[r10,r0,lsl #2]

// "m" if then (else if false "0")
c0test:	ldrh r0,[r11],#2 // fetch else address-offset
				// *** (needs sign extension?) ***
	ands r6,r6	// test zero condition (else)?
	bne nogoto	// just skip branch and execute if true (!=)
	adds r11,r0	// else add offset to r11 pointer if false
nogoto:	ldr r6,[r7,#-4]! // remove condition from d-stack top
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//======================================================================
//
// Simple I/O routines

case00: // echo offending character
	bl TXbios	// output it
	mov r0,#0x3F	// "?" flag error
	b echo00
// space (or other echo)
casspa:	mov r0,#0x20	// space out
echo00:	// simply echo character (in r0) from lookup index
	bl TXbios	// output it
	// just chain (used as a no-op instruction)
casnop:	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// new line
caslin:	mov r0,#13	// c.r. out
	bl TXbios	// output it
	mov r0,#10	// l.f. out
	bl TXbios	// output it
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// print
caspri:	mov r0,r6	// get data	// fix
	bl decwrd	// output it (decimal)
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// unsigned print
casupr:	mov r0,r6	// get data	// fix
	bl udecwd	// output it (decimal)
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// word
caswor:	mov r0,r6	// get data	// fix
	bl hexwrd	// output it
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// half word
cashwo:	mov r0,r6	// get data
	bl hexhwd	// output it
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// byte
casbyt:	mov r0,r6	// get data
	bl hexbyt	// output it
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// nibble
casnib:	mov r0,r6	// get data
	bl hexlsn	// output it
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// character
caschr:	mov r0,r6	// get data
	bl TXbios	// output it
	ldr r6,[r7,#-4]! // pop next data
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// CR-LF
cacrlf:	bl crlf
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// input a single key code
caskey:	str r6,[r7],#4	// push old top
	bl RXbios		// read a key
	mov r6,r0
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// hex input with exit character
chexin:	str r6,[r7],#4	// push old top
	bl hexin
	str r2,[r7],#4
	mov r6,r0
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// decimal input with exit character
cdecin:	str r6,[r7],#4	// push old top
	bl decin
	str r2,[r7],#4
	mov r6,r0
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//======================================================================
//
// Outputs:
//
// space:
space:	push {r0,lr}
	mov r0,#0x20	//space out
	bl TXbios	// output it
	pop {r0,pc}

// CR LF
crlf:	push {r0,lr}
	mov r0,#10	// l.f. out
	bl TXbios	// output it
	pop {r0,pc}

// backspace
bckspc:
	push {r0,lr}
	mov r0,#8	// B.S. space
	bl TXbios	// output it
	mov r0,#0x20	// blank old character
	bl TXbios	// output it
	mov r0,#8	// (so we B.S. again)
	bl TXbios	// output it
	pop {r0,pc}

// r1: TXbios String Output:
string:
	push {r1,lr}	// save reg. and return
	mov r1,r0     // cue index to r1 (variables always passed in r0)
	b strobg	// merge after the output

strolp:	bl TXbios	// output it
strobg:	ldrb r0,[r1],#+1	// fetch char. & cue to next
	cmp r0,#0
	bne strolp		// not final 0? (then loop)
	pop {r1,pc}		// (else exit)

// r0 Unsigned Decimal Output
udecwd:
	push {r1,r2,r3,r4,lr}
	mov r0,#' '	// leading space
	b udecmg	// merge below

// r0 Signed Decimal output:
decwrd:
	push {r1,r2,r3,r4,lr}
		// setup
	mov r4,r0	// copy number to r4
	mov r3,#10	// base 10
	mov r2,#0	// digit counter
		// evaluate sign
	mov r0,#' '
	tst r4,r4	// test for minus
	itt mi		// if,then,then (no else specified)
	negmi r4,r4	// else, make it positive
	movmi r0,#'-'	// 0x2D
udecmg:	bl TXbios	// output it
decxlp:		// modulo division digit extraction(s)
	mov r0,r4	// copy number back to r0		OK (64)
	udiv r4,r4,r3	// divide number (r4) by base_10 (r3)	OK (6)
	mul r1,r4,r3	// multiply result (r1) by base_10 (r3) OK (60)
	sub r0,r0,r1	// subtract product (r1) from number (r0)
		// count and save each digit
	str r0,[r7],#4	// push digit onto data stack
		// loop until end (number == 0)
	add r2,#1	// count the digit
	tst r4,r4	// test for "equal" (zero_flag=1)
	bne decxlp	// loop until zero
decolp:		// digit output loop
	ldr r0,[r7,#-4]! // pop digit from data stack
	bl declsn	// output the digit (r0)
	subs r2,#1	// tally the digit
	bne decolp	// loop until zero
		// exit
	pop {r1,r2,r3,r4,pc}

// r0: Hex Word Input ftom RX (echoed to TX)

hexin:	push {lr}	// save return address
	mov r2,#0	// zero target
	//
hxinlp:	bl RXbios		// read a key
	bl TXbios	// output it
	mov r1,r0	// make copy of exit chracter
	//
	cmp r1,#0x30
	blt hexit	// check for <"0"
	cmp r1,#0x39
	ble hexiok	// check for <="9"
	//
	ands r1,#0xdf	// turn a-f -> A-F
	cmp r1,#0x41
	blt hexit	// check for <"A"
	cmp r1,#0x46
	bgt hexit	// check for <="F"
	//
hexaok:	subs r1,#0x07	// turn A-F -> :-?
hexiok:	and r1,#0x0f	// just lsn
	lsls r2,#4	// shift r2 4-bits
	adds r2,r1	// add new nibble
	b hxinlp	// loop until non-hex char
	//
hexit:	pop {pc}	// return: r0=exit character, r2=hex number

// r0: Dec Word Input ftom RX (echoed to TX)

decin:	push {lr}	// save return address
	mov r2,#0	// zero target
	mov r3,#10	// base 10
	//
dcinlp:	bl RXbios		// read a key
	bl TXbios	// output it
	//
	cmp r0,#0x30
	blt dcxit	// check for <"0"
	cmp r0,#0x39
	bgt dcxit	// check for >"9"
	//
	and r0,#0x0f	// just lsn
//	mul r2,r3	// times 10 (error or returns 32-bit version)
	.hword 0x435A	// short multiply: 0100 0011 01nn nddd d*n->d
	adds r2,r0	// add new nibble
	b dcinlp	// loop until non-hex char
	//
dcxit:	pop {pc}     // return: r0=exit character, r1=lun, r2=hex number


// r0: Hex Word  Out to TX
hexwrd:	push {r1,lr}
	mov r1,r0	// save r0
	lsr r0,#16
	bl hexhwd	// msb
	//
	mov r0,r1
	bl hexhwd	// lsb
	pop {r1,pc}

// r0: Hex HalfWord  Out to TX
hexhwd:	push {r1,lr}
	mov r1,r0	// save r0
	lsr r0,#8
	bl hexbyt	// msb
	//
	mov r0,r1
	bl hexbyt	// lsb
	pop {r1,pc}

// r0 Hex Byte Out to TX
hexbyt:	push {r1,lr}
	mov r1,r0	// save r0
	lsr r0,#4
	bl hexlsn	// msn
	//
	mov r0,r1
	bl hexlsn	// lsn
	pop {r1,pc}

// r0: Just Hex Nibble  Out to TX
hexlsn:	ands r0,#0x0F
declsn:	orrs r0,#0x30
	//
	push {lr}
	cmp r0,#0x39
	ble hexook
	adds r0,#0x27	// 10-15 => a-f
hexook:	bl TXbios
	pop {pc}

//======================================================================
//
// Misc. Byte-Code Execution Routines:

// "e" execute an immediate code number
casexd:
	mov r0,r6	// get code to execute from top of dstack
	ldr r6,[r7,#-4]!	// pop next number off of dstack
	ldr r15,[r10,r0,lsl #2]	// set program counter directrly to the
		// address: (and don't mess with the code pointer)

// Start automatic execution of a string stored in memory
bcExec: //					// (pointed to by r6:)
//	mov r0,lr		// (save link register)
	push {r0,r6,r7,r10,r11}	// push everything that
	//			// needs to be saved
	mov r11,r6  //cue r11 (byte-code pointer) to executable bytecode
	ldrb r0,[r11],#1    //fetch bytecode (then cue to next bytecode)
	ldr r15,[r10,r0,lsl #2]	// execute table routine indexed by r0
							   // (times 4)
// Return to byte-code routine from  byte-code subroutine
bcRet:	pop {r0,r6,r7,r10,r11}	// restore everything
				//  (including unused lr in r0)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// Terminate automatic execution of a string
bcExit:	pop {r0,r6,r7,r10,r11}	// just restore everything
				//  (including return address in r0)
//	bx r0	// (return to old lr)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//-----------------------------------------------------
// Indirect: Byte-code subroutine (called from within another byte-code
//  string)
	// push {r11}	// save byte-code pointer
	// ldr r11,[r11],#4	// cue to specified routine
	// ldrb r0,[r11],#1	// chain (continue from new string)
	// ldr r15,[r10,r0,lsl #2] ("." or "g" returns to the calling
							// chain)
// Immediate: Machine-code Subroutine to initiate in-line byte-code
//							 execution:
inLine:	push {r11}	// save higher-level byte-code pointer
	mov r0,lr	// get Thumb-2 formatted "return address (+1)"
						// (string addr.)
	subs r11,r0,#1	// cue lower-level byte-code-pointer to start
						// (-1) of string
	ldrb r0,[r11],#1	// chain (and cue to next)
	ldr r15,[r10,r0,lsl #2]	// execute table routine indexed by r0
						// (times 4)

// "g" if top-of-d-stack == 0 (but don't push or pop anything at all)
// then exit bytecode-string to next bytecode
cas0go:	ands r6,r6	// is top of d-stack == 0?
	// if == 0 then just drop thru and run exit routine below
	bne cno_op	// (else go run just the no-op routine)

// ("." exit) chain from bytecode-string to next bytecode:
cchain:	pop {r11}	// restore higher-level byte-code pointer
cno_op:	ldrb r0,[r11],#1	// chain to it
	ldr r15,[r10,r0,lsl #2]



casebs:	//*************************************************
cVtest:
cYtest:
//	bl inline
//	.ascii "255B."
//	.align 2

// Hex data dump
ciltst:	bl inLine	// invoke inline execution ("y")
	.ascii "8{10C u@W 16{uapB }}."	//incriment "a" used
	.align 2
// Cue up SRAM 	to 0x20001100
casezz:	bl inLine	// cue up RAM ("z")
//	.ascii "ux20001100:."	// just past the variables
	.ascii "u#"
	.word 0x20001100	// cue just past the variables
	.ascii ":."
	.align 2
// cue to line number
cuelin:	bl inLine	// invoke inline execution ("y")
	.ascii "zg1-g{[uapxa=]}."  // until peek-byte == 0x0a
	.align 2
// verify (type) number of lines
cverif:	bl inLine	// invoke inline execution ("y")
	.ascii "\ng{[uap\"Cxa=]}."  // until peek-byte == 0x0a
	.align 2
// write text (insert)
cwrite:	bl inLine	// invoke inline execution ("y")
	.ascii " \n[k\"\"Cuaqxa=]."
	.align 2

// Terminal:
FDterm:
	bl inLine	// invoke inline execution ("y")
	.ascii "[(E(X0]" // show (exho) RXin, send keys
	.align 2
HDterm:	bl inLine	// invoke inline execution ("y")
	.ascii "[(EC0]"	 // show (exho) RXin, send (and echo) keys
	.align 2


// Equates
//	.word case00+1	// C0 @		
//	.word case00+1	// C1 A			ACK "." ==0x79 "x" !=0x79
//	.word cerase+1	// C2 B erase device (Blank)
//	.word cacopy+1	// C3 C (Copy)
//	.word cpause+1	// C4 D	delay (pause)
//	.word crx2lc+1	// C5 E Echo RX to LCD (works)
//	.word case00+1	// C6 F
//	.word case00+1	// C7 G
//	.word cpinhi+1	// C8 H pin high (oin?)
//	.word cpinin+1	// C9 I pin in
//	.word case00+1	// CA J
//	.word case00+1	// CB K
//	.word cpinlo+1	// CC L pin low
//	.word case00+1	// CD M
//	.word case00+1	// CE N
//	.word clouto+1	// CF O	lOcal Output Only
//	.word csetxy+1	// D0 P pset (point set)
//	.word cgetxy+1	// D1 Q query pen position
//	.word caRXin+1	// D2 R RX-in Read
//	.word clcdou+1	// D3 S screen LCDout
//	.word cpento+1	// D4 T pen touch (and pressure)
//	.word cpenre+1	// D5 U pen Up (release)
//	.word cerase+1	// D6 V erase device (same as B)
//	.word cprgrm+1	// D7 W Device Programmer
//	.word cTXout+1	// D8 X TX-out
//	.word FDterm+1	// D5 Y Full Duplex Treminal
//	.word HDterm+1	// D6 Z Hald Duplex Terminal
//	.word case00+1	// DB [		???
//	.word case00+1	// DC \
//	.word case00+1	// DD ]
//	.word case00+1	// DE ^
//	.word case00+1	// DF _
//	// Blue				ALT:	// Use Blue
//	.word case00+1	// E0 `
//	.word case00+1	// E1 a			ACK "." ==0x79 "x" !=0x79
//	.word cerase+1	// E2 b erase device (Blank)
//	.word cacopy+1	// E3 c (Copy)
//	.word cpause+1	// E4 d	delay (pause)
//	.word crx2lc+1	// E5 e Echo RX to LCD (works)
//	.word case00+1	// E6 f
//	.word case00+1	// E7 g
//	.word cpinhi+1	// E8 h pin high (oin?)
//	.word cpinin+1	// E9 i pin in
//	.word case00+1	// EA j
//	.word case00+1	// EB k
//	.word cpinlo+1	// EC l pin low
//	.word case00+1	// ED m
//	.word case00+1	// EE n
//	.word clouto+1	// EF o	lOcal Output Only
//	.word csetxy+1	// F0 p pset (point set)
//	.word cgetxy+1	// F1 q query pen position
//	.word caRXin+1	// F2 r RX-in Read
//	.word clcdou+1	// F3 s screen LCDout
//	.word cpento+1	// F4 t pen touch (and pressure)
//	.word cpenre+1	// F5 u pen Up (release)
//	.word cerase+1	// F6 v erase device (same as B)
//	.word cprgrm+1	// F7 w Device Programmer
//	.word cTXout+1	// F8 x TX-out
//	.word FDterm+1	// F5 y Full Duplex Treminal
//	.word HDterm+1	// F6 z Hald Duplex Terminal
//	.word case00+1	// FB {		???
//	.word case00+1	// FC |
//	.word case00+1	// FD }
//	.word case00+1	// FE ~
//	.word case00+1	// FF xxx

// byte-code equates:
	.equ b_dupe,0x22	// 22 -"-
	.equ b_ic, 0x27		// 27 "'" immediate number (character)
	.equ b_add,0x2b		// 2b "+" add
	.equ b_0,0x30		// 30 "0"
	.equ b_1,0x31		// 31 "1"
	.equ b_8,0x38		// 38 "8"
	.equ b_store,0x3a	// 3a ":" store
	.equ b_rstor,0x3b	// 3b ";" reverse store
	.equ b_load,0x40	// 40 "@" fetch
	.equ b_xor, 0x5e	// 5e "^" xor
	.equ b_drop,0x60	// 60 ` number drop
	.equ b_inc, 0x61	// 61 a (fetch & incriment)
	.equ b_peek,0x70	// 70 p (1-byte peek)
	.equ b_varA,0x81
	.equ b_varB,0x82	// variables
	.equ b_varC,0x83
	.equ b_varD,0x84
	.equ b_varE,0x85
	.equ b_wait,0xc4	// C4 (D delay
	.equ b_localout,0xcf	// CF (O lOcal TX Output Only
	.equ b_RX, 0xd2		// D2 (R RX-in		*** (f2(r) -> d2(R))
	.equ b_lcd,0xd3		// D3 (S screen LCDout
	.equ b_TX, 0xd8		// D8 (X TX-out

// Programmer: Device ID:
cprgrm:	bl inLine	// invoke inline execution ("y")
	// ST Application note: AN3155 pp.5-6/38 Set Baudrate
	.byte b_localout,b_ic,0x3a,b_lcd	//local output prompt ":" (0x3a)
	.ascii "[k10=]"	// wait for linefeed key (10=0x0a) after reseting UUT
	.byte b_ic,0x7f,b_TX	//,b_RX	//,b_drop	// x7f TX RX drop
	.ascii "["
	.byte b_RX,b_ic,0x79	// read until ack (sometimes gets 0xff first)
	.ascii "=]"

	// ST Application note: AN3155 p.12/38 Get I.D. command
//	.byte b_ic,0x2e,b_lcd	// prompt "." for delay
	.byte b_1,b_wait
	.byte b_ic,0x02,b_TX	// 0x02 ("10" works (above) "2" doesn't)
//	.byte b_ic,0x2e,b_lcd	// prompt "." for delay
	.byte b_1,b_wait
	.byte b_ic,0xfd,b_TX	// 0xfd request id (+ checksum)

	// Report device code:	(410:STM32F103	431:STM32F411)
	.byte b_RX	// read ack
	.byte b_RX	// read "01" (length-1)
	.byte b_RX	// read "04" (leading byte)
	.byte b_RX	// read code
	.ascii "\\BB``"	// just output 04+code
	.byte b_RX,b_drop // read final ack ("y" in next line)
	.ascii "."	// and discard it ?????????
	.align 2

// Programmer: Erase, (short STM32F103 version):
cerase:	bl inLine	// invoke inline execution ("y")
	.ascii "'E(s"
	// ST Application note: AN3155 pp.21-22/38 Erase Memory command
	.byte b_ic,0x43,b_TX	// 0x43 stm32f103 erase command
	.byte b_1,b_wait
	.byte b_ic,0xbc,b_TX	// 0xbc (checksum)

	.byte b_RX,b_lcd	// get ack, echo ("y") for delay
	.byte b_ic,0xff,b_TX	// 0xff entire device
	.byte b_1,b_wait
	.byte b_ic,0x00,b_TX	// 0x00 (checksum)

	.byte b_RX,b_lcd	// get final ack and echo ("y")
	.ascii "."		// end
	.align 2

// Programmer: Extended Erase, (long STM32F411 version):
cexera:	bl inLine	// invoke inline execution ("y")
	.ascii "'X"
	.byte b_lcd
	// ST Application note: AN3155 pp.24-25/38 Extended-Erase Memory command
	.byte b_ic,0x44,b_TX	// 0x43 stm32f103 erase command
	.byte b_1,b_wait
	.byte b_ic,0xbb,b_TX	// 0xbc (checksum)

	.byte b_RX,b_lcd	// get ack, echo ("y") for delay
	.byte b_ic,0xff,b_TX	// 0xffff,0x00  erase entire device	OK
	.byte b_1,b_wait	// 0xfffe,0x01  erase bank 1 (MSB 1st) 	??
	.byte b_ic,0xff,b_TX	// 0xfffd,0x02  erase bank 2		??
	.byte b_1,b_wait
	.byte b_ic,0x00,b_TX	// 0x00 (checksum)

	.byte b_RX,b_lcd	// get final ack and echo ("y")
	.ascii "."		// end
	.align 2

// Programmer: "Copy", (short STM32F103 version):
cacopy:	bl inLine
	.ascii "'C(s"
	.byte b_varA,b_0,b_store	// set address to 0
	.byte b_varC,b_0,b_store	// start page count at 0
	// ST Application note: AN3155 p.18-19/38 Write Memory command
	.ascii "["  // send command
		.byte b_ic,0x31,b_TX,b_1,b_wait	// 0x31 (program)
		.byte b_ic,0xce,b_TX		// 0x31 (checksum)
		.byte b_RX,b_lcd	// get ack, echo ("y") for delay
		// send address:
		.byte b_varB,b_8,b_store	// set checksum byte to 0
		.byte b_8,b_TX,b_1,b_wait	// 0x8 (address)
		.byte b_0,b_TX,b_1,b_wait	// 0x0 (address)
		.byte b_varC,b_load,b_TX,b_1,b_wait // (active address)
		.byte b_0,b_TX,b_1,b_wait	// 0x0 (address)
		.byte b_8, b_varC,b_inc,b_xor,b_TX  // checksum
		.byte b_RX,b_lcd	// get ack, echo ("y") for delay
		// send length:
		.byte b_ic,0xff,b_dupe,b_TX,b_1,b_wait	// (length-1)
		.byte b_varB,b_rstor		// initiate checksum
		// semd data (loop):
		.ascii "256{"
			.byte b_varA,b_inc,b_peek,b_dupe,b_TX,b_1,b_wait // data
			.byte b_varB,b_load,b_xor,b_varB,b_rstor // checksum update
		.ascii "}"
		// semd checksum:
		.byte b_varB,b_load,b_TX,b_RX,b_lcd  // get ack, echo ("y") for delay
	.byte b_varC
	.ascii "@34=]."		// end at 0x22 = 34d
	.align 2

// init LCD
caini1:	bl inLine
	.ascii "xc0"
	.byte 0x16	//^V	power #1
	.ascii "x23"
	.byte 0x0f	//^O

	.ascii "xc1"
	.byte 0x16	//^V	power #2
	.ascii "x10"
	.byte 0x0f	//^O

	.ascii "xc5"
	.byte 0x16	//^V	VCOM #1
	.ascii "x3e"
	.byte 0x0f	//^O
	.ascii "x28"
	.byte 0x0f	//^O

	.ascii "xc7"
	.byte 0x16	//^V	VCOM #2
	.ascii "x86"
	.byte 0x0f	//^O

	.ascii "x3a"
	.byte 0x16	//^V	16-bit data
	.ascii "x55"
	.byte 0x0f	//^O

	.ascii "xb1"
	.byte 0x16	//^V	normol mode frame ctrl.
	.ascii "x00"
	.byte 0x0f	//^O
	.ascii "x1b"
	.byte 0x0f	//^O

	.ascii "xb6"
	.byte 0x16	//^V	display function control
	.ascii "x0a"
	.byte 0x0f	//^O
	.ascii "x82"
	.byte 0x0f	//^O
	.ascii "x27"
	.byte 0x0f	//^O

	.ascii "."	//end
	.align 2

catest:	bl inLine
	.ascii "x11"	//Wake up ^V
	.byte 0x16
	.ascii "x29"	//Display on ^V
	.byte 0x16
	.ascii "x13"	//Normal mode ^V
	.byte 0x16

	.ascii "."	//end
	.align 2

caini2:	bl inLine
	.ascii "x36"
	.byte 0x16	//^V	vertical (phone)
	.ascii "x98"
	.byte 0x0f	//^O

	.ascii "x2a"
	.byte 0x16	//^V	column range
	.ascii "x000"
	.byte 0x0e	//^N
	.ascii "x0ef"
	.byte 0x0e	//^N

	.ascii "x2b"
	.byte 0x16	//^V	row range
	.ascii "x000"
	.byte 0x0e	//^N
	.ascii "x13f"
	.byte 0x0e	//^N

	.ascii "x2c"
	.byte 0x16	//^V	write
	.ascii "xffff"
	.byte 0x0e	//^N	white
	.ascii "x0"
	.byte 0x0e	//^N	black
	.ascii "xffff"
	.byte 0x0e	//^N	white
	.ascii "x0"
	.byte 0x0e	//^N	black
	.ascii "xffff"
	.byte 0x0e	//^N	white
	.ascii "x0"
	.byte 0x0e	//^N	black

	.ascii "."	//end
	.align 2

//-----------------------------------------------------
// block transfer src. dest. len. (in d-stack & r6)
casxfr:	ldr r2,[r7,#-4]!	// pop dest. off d-stack
	ldr r1,[r7,#-4]!	// pop src. off d-stack
	cmp r1,r2
	bmi xfrdn		// move up or down?
	// "upward-safe" xfer
xfrulp:	ldrb r0,[r1],#1		// get src. byte
	strb r0,[r2],#1		// put dest. byte
	subs r6,#1		// count length down
	bne xfrulp
	b xfrnd
	// "downward-safe" xfer
xfrdn:	adds r1,r6		// (start at bottom
	adds r2,r6		//  of both blocks)
xfrdlp:	ldrb r0,[r1,#-1]!	// get src. byte
	strb r0,[r2,#-1]!	// put dest. byte
	subs r6,#1		// count length down
	bne xfrdlp
	//
xfrnd:	ldr r6,[r7,#-4]!	// new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

// display dstack pointer
	//mov r0,r7			/// DEBUG ONLY
	//bl hexwrd
	//ldrb r0,[r11],#1	// chain
	//ldr r15,[r10,r0,lsl #2]

// all the way down here because of "ldr rn,=" short range problems
// "j" jumps straight to "z" address: (u:=0x20001100)

// change some hex bytes of memory (h)
chedit:	ldr r4,=0x20001054	// cue r4 to variable "u" b10101 * b100
	ldr r3,[r4]		// fetch it
	//
hedtlp:	bl hexin	// read new data in r2, (lun in r1)
	strb r2,[r3],#1	// store each data byte (index)
	cmp r0,0x0a	// and use exit character
	bne hedtlp	// to exit (lf) or loop (all else)
	//
	str r3,[r4]		// update "u" variable
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// Examples:
	//   (r7 is the d-stack pointer; r6 is the top of the d-stack)
	// 47 F8 04 6B 	str r6,[r7],#4		// push r6
	// 57 F8 04 6D	ldr r6,[r7,#-4]!	// pop r6
	// 00 26     	movs r6,#0		// clear r6
	//				// chain:
	// 1B F8 01 0B	ldrb r0,[r11],#1	// fetch next bytecode
	// 5A F8 20 F0	ldr r15,[r10,r0,lsl #2]	// jump to that routine

//======================================================================
// Invoke alternate function of next character
casalt:	ldrb r0,[r11],#1	// chain to next character (again)
	adds r0,#128		// and use alternate offsets
	ldr r15,[r10,r0,lsl #2]	// go do it

// graphics functions: (Alternate functions)
// Read pen (alt.Q)
cgetxy:	str r6,[r7],#4	// push r6 onto d-stack
	bl GetXY	// Get the Point
	mov r6,r9	// put Y into r6 (top of d-stack)
	mov r5,r8	// get X, and
	str r5,[r7],#4	// push it onto d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// Set Point (alt.P)
csetxy:	mov r9,r6	 // put Y into r9
	ldr r6,[r7,#-4]! // get X from d-stack
	mov r8,r6	 // put it into r8
	bl PsetXY	 // Set the Point
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// straight TXout (alt.X)
cTXout:	mov r0,r6	 // get character
	bl TXout	 // rs-232 TX output it
	ldr r6,[r7,#-4]! // new top of d-stack
	//
	mov r0,#0xE0	//
vswlp:	subs r0,#1	// very short wait
	bne vswlp	//
	//
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// straight LCDout (alt.S)
clcdou:	mov r0,r6	 // get character
	bl LCDout	 // output to LCD screen
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// Echo RX in (if any) to LCDout (alt.E)
crx2lp:	bl LCDout	// Echo RXin to LCDout
crx2lc:	bl Event	// Get next event
	mov r2,#0x20000000	// cue to SRAM
	ldrb r1,[r2,#evntid]	//0:clock, 1:RXin, 2:Key, 3:Pen
	cmp r1,#1	// test for RXin event
	beq crx2lp	// loop while RXin
	b crx2mg	// return non-RXin event
// straight RX in
caRXin:	bl RXin		// Get the character
crx2mg:	str r6,[r7],#4	// push r6 onto d-stack
	mov r6,r0	// put character/number into r6
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// lOcal Output Only (alt. O)
clouto:	mov r1,0x20000000	// cue pointer to RAM
	mov r0,LCDout+1		// cue vector to local output
	str r0,[r1,#outvct]	// redirect output vector
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// Pen Release (0 means released) (alt.R)
cpenre:	bl penRel	// Get the number
	b crx2mg	// push it onto the D-stack
// Pen touching (measures pressure) (alt.T)
cpento:	bl penTch	// Get the number
	b crx2mg	// push it onto d-stack

// Hardware control routines: (Alternate functions)
// r0 miliseconds pause (alt.D delay)
cpause:	mov r0,r6
	bl wtr0ms	 // wait r0 ms.
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// r0 pin# input test (alt.I input) (swaps r6 for status)
cpinin:	mov r0,r6
	bl pinin	// pull pin# r0 high
	mov r6,r0	// get new value
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// r0 pin# high (alt.H high)
cpinhi:	mov r0,r6
	bl pinhi	 // pull pin# r0 high
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
// r0 pin# low: (alt.L low)
cpinlo:	mov r0,r6
	bl pinlo	 // pull pin# r0 low
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//cacsel:	bl Csel			// LCD command select (^q)
//	ldrb r0,[r11],#1	// chain
//	ldr r15,[r10,r0,lsl #2]

//cadsel:	bl Dsel			// LCD data select (^r)
//	ldrb r0,[r11],#1	// chain
//	ldr r15,[r10,r0,lsl #2]

cLCDc8:	mov r0,r6	// data in r0	// LCD control out (^v)
	bl SPIC08	// output control
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

cLCDd8:	mov r0,r6	// data in r0	// LCD 8-bit data out (^o)
	bl SPID08	// output data
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

cLCD16:	mov r0,r6	// data iin r0	// LCD 16-bit data out (^n)
	bl SPID16	// output data
	ldr r6,[r7,#-4]! // new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

calsel:	bl LCDsel		// LCD select (^s)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

catsel:	bl Tchsel		// Touch select (^t)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

causel:	bl uSDsel		// uSD select (^u)
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//======================================================================
// LCD Display Settings:

	// ^F (Foreground Color)
casfor:	mov r1,0x20000000	// Cue to RAM
	strh r6,[r1,#forgnd]	// store from r6
	ldr r6,[r7,#-4]! 	// new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// ^B (Background Color)
casbak:	mov r1,0x20000000	// Cue to RAM
	strh r6,[r1,#bakgnd]	// store from r6
	ldr r6,[r7,#-4]! 	// new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// ^C (H-Tab)
cascol:	mov r1,0x20000000	// Cue to RAM
	strh r6,[r1,#xcursr]	// store from r6
	ldr r6,[r7,#-4]! 	// new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// "o" (V-ab)
casrow:	mov r1,0x20000000	// Cue to RAM
	strh r6,[r1,#ycursr]	// store from r6
	ldr r6,[r7,#-4]! 	// new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

	// (Font Size)
casfnt:	mov r1,0x20000000	// Cue to RAM
	strb r6,[r1,#fontsz]	// store from r6
	ldr r6,[r7,#-4]! 	// new top of d-stack
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]

//======================================================================
// Links to Redirectable BIOS RX and TX routines
//  (for logical unit reassignment and ctrl-esc-sequence stuff)
//
RXbios:	push {r1,lr}
	mov r1,0x20000000
	ldr r1,[r1,#inpvct]
	blx r1
	pop {r1,pc}

TXbios:	push {r1,lr}
	mov r1,0x20000000
	ldr r1,[r1,#outvct]
	blx r1
	pop {r1,pc}

//======================================================================
// Anything below this line requires a short-range "LDR" ****
// variables a-z

// Internal Flash Programming Routines:
// Flash Program r5 base pointer:			F[\] or f{|}
casfp5:	ldr r5,=0x40022000	// get flash register base here
	b fpkxit		// short (slow) chain
// Flash Program Enable:				[ or }
casfpk:	// ldr r5,=0x40022000	// don't get flash register base here
	ldr r0,=0x32107654	// Key1	  (requires an additional step)
	str r0,[r5,#4]		// to Key Register
	ldr r0,=0xba98fedc	// Key2
	str r0,[r5,#4]		// to Key Register
	b fpkxit		// short (slow) chain
// Flash Program Write:	(addr & dat16 off d-stack)	| or \
casfpw:	ldr r5,=0x40022000	// get flash register base
	movs r0,#1		// set program bit
	str r0,[r5,#16]		// write to control register
	ldr r0,[r7,#-4]!	// fetch address32, (data16 is in r6)
	strh r6,[r0]		// transfer data16 to address
	ldr r6,[r7,#-4]!	// pop next data from dstack
	// drop thru:		// then busy wait
// Flash program Busy Wait & Chain:		(busy-wait & terminate)
fpbwtx:	ldr r0,[r5,#12]		// get status register
	ands r0,#1		// busy bit still set?
	bne fpbwtx		// loop while busy
fpkxit:	ldrb r0,[r11],#1	// then chain
	ldr r15,[r10,r0,lsl #2]
// Flash Program Terminate:				] or }
casfpt:	ldr r5,=0x40022000	// get flash register base
	movs r0,#0x80		// set lock bit
	str r0,[r5,#16]		// write to control register
	b fpbwtx		// busy wait & chain

// Variables:
casvar:	str r6,[r7],#4	// push old top
	ldr r6,=0x20001000	//cue to data RAM ***
	and r0,#0x1f	// just 32 locations
	lsl r0,#2	// times 4
	add r6,r0	// add offset
	ldrb r0,[r11],#1	// chain
	ldr r15,[r10,r0,lsl #2]
