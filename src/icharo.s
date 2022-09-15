//==============================================================================
//  Character Output Routines:	File: icharo.s
//
//	r0  --	scratch
//	r1  fs	Font Size xHW
//	r2  pw	Pixel-Width Counter
//	r3  cw	Character-Width Counter
//	r4  ph	Pixel-Height Counter
//	r5  ch	Character-Height Counter
//	r6  fp	character or Font-Table Pointer to it
//	r7  rp	Ram pointer (0x20000000)
//	r8  fg	ForeGround  (move only)
//	r9  bg	BackGround  (move only)
//	r10 dw	Data Word (move or add to self)
//	r11 db	Data Backup (move only)
//
//------------------------------------------------------------------------------
//  LCDout Subroutine:	(Set all Pexels for one complete character)
//
LCDou2:	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,lr}	// Save 12 registers
	mov r6,r0	// Move the r0-passed character to a less-needed register
	//
	mov r7,#0x20000000	// Cue r11 to SRAM
	ldrb r1,[r7,#fontsz]	// Font Size
	ldrh r8,[r7,#forgnd]	// Foreground Color (nominally lighter)
	ldrh r9,[r7,#bakgnd]	// Background Color (nominally darker)
	// Test for special control characters:
	cmp r6,#0x0a	// LINUX l.f.?
	beq rowadv	// next row
	cmp r6,#0x0d	// DOS c.r.?
	beq DOScr	// start of same line

	// Back Space
	cmp r6,#0x07	// LINUX "07" Backspace
	beq BSpace	// column-1
	cmp r6,#0x08	// DOS "08" Backspace
	bne BkSpSk	// column-1
	// Backspace Exit
BSpace:	ldrh r0,[r7,#xcursr]	// fetch column
	ands r0,r0	// already at left?
	beq bsprev	// then goto previous line
mergbs:	mov r2,r1	// else b.s. (*** font size ***)
	ands r2,#0x0f	// (*** lsn only ***)
	lsls r2,#3	// (*** tines 8 ***)
	subs r0,r2
	strh r0,[r7,#xcursr]	// update column
	b advxit	// exit
	// row beginning:
bsprev:	ldrh r0,[r7,#ycursr]	// fetch row
	ands r0,r0	// already at top?
	beq advxit	// then just exit (no action)
	mov r3,r1	// (*** font size ***)
	ands r3,#0xf0	// (*** msn only "times 16" ***)
	subs r0,r3	// (*** row=start-size ***)
	strh r0,[r7,#ycursr]	// update row
//	movs r0,#0xe8
	movs r0,#0xf0	// cue to the end of that row (vertical screen)
	b mergbs	// update the column and exit
BkSpSk:
	// Test for geeral control characters:
	cmp r6,#0x20
	bge ngctrl
	add r6,#0x40	// x00 -> "@" x01 ->"A" etc
	mov r8,#0xFFE0	// Foreground YELLOW
	movs r9,#0	// Background Black
	b colrnd

	// Test for alternate characters:
ngctrl:	cmp r6,0x80
	blt colrnd
	and r6,#0x7f	// strip 0x80 bit
	mov r8,#0x7FF	// Foreground CYAN
	movs r9,#0	// Background Black
	// Test for alternate geeral control characters:
	cmp r6,#0x20
	bge colrnd
	add r6,#0x40	// x00 -> "@" x01 ->"A" etc
	mov r8,#0xF81F	// Foreground MAGENTA
colrnd:
	//-------------------------------------------
	// Locate the Character in the table
	ands r6,#0x7F	// trim Character in r10 to 7-bits
	subs r6,#0x20	// table begins at 0x20 (space)
	lsls r6,#4	// multiply entry number by 16 bytes per entry
	adr r0,fonts	// get the table base
	adds r6,r0	// add the correct offset (now a pointer)

	//-------------------------------------------
	// Set Up & Home Character Window:
	movs r0,#0x2A	// Column
	bl SPIC08	// Command
	ldrh r0,[r7,#xcursr]	// column: (240)
	bl SPID16	// Start Data
	mov r5,r1	// font size
	ands r5,#0x0f	// lsn only
	lsls r5,#3	// tines 8
	subs r5,#1	// minus 1
	adds r0,r5	// End = start + size - 1 ***)
	bl SPID16	// End Data
	//
	movs r0,#0x2B	// Row
	bl SPIC08	// Command
	ldrh r0,[r7,#ycursr]	// Row: (320)
	bl SPID16	// Start Data
	mov r5,r1	// font size
	ands r5,#0xf0	// msn only "times 16"
	subs r5,#1	// minus 1
	adds r0,r5	// End = start + size - 1
	bl SPID16	// End Data
	//
	movs r0,#0x2C	// "home" command
	bl SPIC08	// (top-left pixel of character)

	//-------------------------------------------
	// Draw the Character
	movs r5,#16	// {ch}=16 lines in normal character
chrlp5:	ldr r10,[r6],#4	// fecth row of 32 pixels and cue to next 32
	mov r11,r10	// save data (from new word)
	asrs r4,r1,#4	// {ph}:= set line multiplier (tall char's)
chrlp4:	mov r10,r11	// restore data (to its proper position)
chrlp3:	movs r3,#8	// {cw}=8 pixels across in normal character
chrlp2:	mov r0,r8	// fg foreground color
	adds r10,r10	// shift msbit data bit out (must be "adds" ...
	bcs chrskp			// because status is used here)
	mov r0,r9	// bg background
chrskp:	mov r2,r1	// {pw} font size
	ands r2,#0x0f	// lsn only (and orands work equally well)
chrlp1:	bl SPID16	// r0 color to SPI (Data16)
	//
	subs r2,#1	// {pw} minus 1
	bne chrlp1	// until done
	subs r3,#1	// {cw} next normal pixel on line
	bne chrlp2	// loop until last one
	subs r4,#1	// {ph} final repeated line?
	bne chrlp4	// and restore the same pattern
	mov r11,r10	// save data (in its new shifted position)
	asrs r4,r1,#4	// {ph}:= set line multiplier but not status
	subs r5,#1	// {ch} final normal line?
	beq chrend	// exit if yes
	ands r0,r5,#3	// ch test for reload (must be "ands" because of bne,beq)
	bne chrlp3	// if not, continue to next pattern
	beq chrlp5	// if so, load next data word
chrend:
	//-------------------------------------------
	// Advance the Column
	ldrh r0,[r7,#xcursr]	// fetch column position
	mov r2,r1	// (*** font size ***)
	ands r2,#0x0f	// (*** lsn only ***)
	lsls r2,#3	// (*** tines 8 ***)
	adds r0,r2	// (*** advance by char width ***)
	movs r2,#0xEF	// limit is 240-1	// vertical
//	mov r2,#0x13F	// limit is 320-1	// horizontal
	subs r2,r0	// Negative if limit exceeded
	bmi rowadv	// ... so next row (blanking?)
	strh r0,[r7,#xcursr]	// update column position
	b advxit	// and exit

	//-------------------------------------------
	// Advance Row:
rowadv:	ldrh r0,[r7,#ycursr]	// fetch row
	mov r2,r1	// (*** font size ***)
	ands r2,#0xf0	// (*** msn only "times 16" ***)
	adds r0,r2	// (*** end=start+size ***)
	strh r0,[r7,#ycursr]	// update row
//
//	 -------------1		 ------------4
//	< End of Page? >--N->---< Scroll On?  >--N->--------+
//	 --------------		 -------------		   |
//		Yv			Yv		   |
//	+-------------2		+------------3		   |
//	|  Row := 0   |		| Clear Row  |		 ------
//	|  Scroll On  |--->---->| Do Scroll  |--->----->( Exit )
//	+-------------+		+------------+		 ------
//
// (1):
scrl1: // mov r1,#319	// limit is 320-1 (no keyboard)
	movs r2,#255	// limit is 256-1 (keyboard present)
//	subs r1,r0	// compare, (negative if limit exceeded)
//	bpl scrl4	// ... so next screen? (scroll? blanking?)
	ands r2,r0	// (zero can be ignored)
	bne scrl4	// scroll at exactly 256
// (2):
scrl2:	movs r0,#0	// Row := 0
	strh r0,[r7,#ycursr]	// update row position
	subs r0,#1	// change r0 to "true"
	strb r0,[r7,#scroff]	// scroll flag true
// (3):	// Set Up Character Window to blank out "top" row
scrl3:	movs r0,#0x2A	//// Column ////
	bl SPIC08	// Command
	movs r0,#0
	bl SPID16	// Start Data
	movs r0,#239			//********************************
	bl SPID16	// End Data
	movs r0,#0x2B	//// Row ////
	bl SPIC08	// Command
	ldrh r0,[r7,#ycursr]	// fetch Row data
	bl SPID16	// Start Data

	mov r3,r1	// font size
	ands r3,#0xf0	// msn only "times 16"
	adds r0,r3	// End = start + size ...
	subs r0,#1	// minus 1 (leave the full count in r3 for below)
///	adds r0,#15	// end = start+15 *********************************

	bl SPID16	// End Data
	movs r0,#0x2C	//// "home" command ////
	bl SPIC08	// (top-left pixel of character)
	// Clear the Row

	movs r0,#240	// one line of pixels
	mul  r3,r0	// times lines/row
///	mov r3,#3840	// := line of text **************************************

blnklp:	ldrh r0,[r7,#bakgnd]	// use pointer to fetch BG color
	bl SPID16	// Send Data
	subs r3,#1	// Loop
	bne blnklp
	// Do the scroll
	movs r0,#0x37	// Scroll command
	bl SPIC08	// Send command
	ldrh r0,[r7,#ycursr]	// Scroll to active row at top ****************

	mov r3,r1	// font size
	ands r3,#0xf0	// msn only "times 16"
	adds r0,r3	// End = start + size ...
///	adds r0,#16	// then up one row (back to bottom) *******************

	ands r0,#0xFF	// (with a 0-255 limit)
	bl SPID16	// Send Scroll Data
	b DOScr		// exit
// (4):
scrl4:	ldrb r0,[r7,#scroff]	// get scroll flag
	ands r0,r0
	bne scrl3	// scroll (above) if True

	// Zero-Column Exit (use when the column must also be set to 0)
DOScr:	movs r0,#0	// zero column	(for DOS c.r.)
	strh r0,[r7,#xcursr]	// update column position (must be down here to allow skip)
	// Normal Exit:
advxit:	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,pc}  // pop 12 registers (including pc)

LCDout:	b LCDou2	// relay to 'out-of-reach' start poiny
