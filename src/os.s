// v4.s (was bios.s)		2021/04/23		Don Stoner
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

			// RAM assignments:
 .equ outvct,0		//	 200000000	sys-output  vector
 .equ inpvct,4		//		04	sys-input vector
 .equ bakfor,8		//		08	mshw.lshw
 .equ forgnd,8		//		08	lshw foreground color
 .equ bakgnd,0x0a	//		0a	mshw background color
 .equ xcursr,0x0c	//		0c	lshw X-Cursor
 .equ ycursr,0x0e	//		0e	mshw Y Cursor
 .equ scroff,0x10	//		10	Scroll offset flag
 .equ fontsz,0x11	//		11	Font v-h flag
 .equ shimsz,0x12	//		12	Shim v-h flag
 .equ stystt,0x13	//		13	Stylus status flag
 .equ evntid,0x14	//		14	Event Identification
 .equ psrnd, 0x18	//		18	pseudo-random number
 .equ keybdc,0x1c	//		1c	Keyboard Code image
 .equ dstckb,0x20	//		20	D-Stack bottom
			//	      1000	C-Stack top
//=======1=========2=========3=========4=========5=========6=========7==
//
	.thumb			// Generate STM32F Family Thumb2 code
	.syntax unified		// (Unified is an Easier Syntax)
	.org 0			// Start at zero

	// Startup Vectors:
	.word   0x20001000	// 1) set stack pointer
	.word   setup   +1	// 2) jump to code (+1 means "thumb")
	//
jtvect:	.word	jTable		// vector points to jTable (in bci)

	//==============================================================

	.include "ikeybd.s"	// Keyboard images
	.include "bci.s"	// Byte Code Interpreter
	.include "ifonts.s"	// Character fonts
	.include "icharo.s"	// Character output

	//==============================================================
	//
	// Configuration: M3 M4 Flash vectors and labels:
	//
M3vect:	.word 0x40013800	// M3 USART1 port base
	.word 2666		// M3 1ms wait-loop count (clock/3/1000 -1) just math
	.word 0x40010810	// M3 GPIO A base + bit set/reset offset (10h)
	.word 0x40010808	// M3 GPIO A base + bit IDR input offset (08h)
	.word 0x40010c10	// M3 GPIO B base + bit set/reset offset (18h)
	.word 0x00000400	// M3 D/C* (B10) high (D)
	.word 0x04000000	// M3 D/C* (B10) low (C*)
	.word 0x00000800	// M3 LCDdes (B11) high (deselect)
	.word 0x08000000	// M3 LCDsel (B11) low (select)

M4vect:	.word 0x40011000	// M4 USART1 port base
	.word 5325		// M4 1ms wait-loop count (clock/3/1000 -1) trimmed
	.word 0x40020018	// M4 GPIO A base + bit set/reset offset (18h)
	.word 0x40020010	// M4 GPIO A base + bit IDR input offset (10h)
	.word 0x40020418	// M4 GPIO B base + bit IDR output offset (1ch)
	.word 0x00000004	// M4 D/C* (B2) high (D)
	.word 0x00040000	// M4 D/C* (B2) low (C*)
	.word 0x00000400	// M4 LCDdes (B10) high (deselect)
	.word 0x04000000	// M4 LCDsel (B10) low (select)

	.equ usart1, 0		// USART1 port address label
	.equ mswait, usart1+4	// 1 ms. wait count-label
	.equ gpionf, mswait+4	// GPIO A on/off base
	.equ gpioin, gpionf+4	// GPIO A input base
	.equ gBionf, gpioin+4	// GPIO B on/off base
	.equ gpioDh, gBionf+4	// D/C* high (D)
	.equ gpioCl, gpioDh+4	// D/C* low (C*)
	.equ gpLCDh, gpioCl+4	// LCDdes high
	.equ gpLCDl, gpLCDh+4	// LCDsel low


//======================================================================
//
//  SPI routines (up here where external routines can reach them)
//
	// Send Command Byte:
SPIC08:	push {r0,r1,r2,r3,lr}
	bl SPIout		// setup registers 0-3 (trash 3) and output r0
	// LCD C*
	ldr r0,[r12,#gpioCl]	// B10/B2 (M3/M4) low (C*)
	ldr r1,[r12,#gBionf]	// cue to the GPIO's on/off register
	str r0,[r1]		// set or reset the correct bit
	pop {r0,r1,r2,r3,pc} // return to caller

	// Send Data Byte:
SPID08:	push {r0,r1,r2,r3,lr}
	bl SPIout		// setup registers 0-3 (trash 3) and output r0
	// LCD D
	ldr r0,[r12,#gpioDh]	// B10/B2 (M3/M4) high (D)
	ldr r1,[r12,#gBionf]	// cue to the GPIO's on/off register
	str r0,[r1]		// set or reset the correct bit
	pop {r0,r1,r2,r3,pc} // return to caller

	// 2-Byte Data output routine: (MSB First from r0)
SPID16:	push {r0,r1,r2,r3,r4,r5,r6,lr}	// Save registers 1-6
	mov r6,r0		// save data
	ror r0,r6,#8		// recover data (shifted for MSB: R-G out First)
	bl SPIout		// setup registers 0-4 5 and output MSB
	// LCD D
	ldr r4,[r12,#gpioDh]	// B10/B2 (M3/M4) high (D)
	ldr r3,[r12,#gBionf]	// cue to the GPIO's on/off register
	strh r4,[r3]		// [GPIO  + Bit-Set Reg:=0x10] (D/C* bit pattern in r4)
	//
	mov r0,r6		// recover data (unshifted for LSB)
	bl SPIou2		// LSB (G-B) out LSB
	pop {r0,r1,r2,r3,r4,r5,r6,pc}	// Restore registers

//======================================================================
// Output to both LCD Display and RS232 Terminal
//
SYSout:	push {r8,lr}	// save return address
	bl LCDout	// output to LCD
	bl TXout	// output to RS232
	pop {r8,pc}	// return to caller

//  Reconfigurble / Redirectable BIOS Subroutines:
//
biosin:	push {r1,lr}
	mov r1,0x20000000
	ldr r1,[r1,#inpvct]
	blx r1
	pop {r1,pc}

biouts:	push {r1,lr}
	mov r1,0x20000000
	ldr r1,[r1,#outvct]
	blx r1
	pop {r1,pc}

	//--------------------------------------------------------------
	// Events:	0:timer   1:RXin   2:Keyin   3:Penin

Event:	push {r1,r2,r3,r4,r8,r9,lr}
	mov r4,0x20000000	// Cue r4 to SRAM pointers
	// ***** Timer ticks go here *****

RXinLp:	// RX routine:
	//
	ldr r1,[r12,#usart1]	// get USATR1 address from config table
	ldr r0,[r1]		// status register (offset 0)
	ands r0,#0x20		// TXEmpty set? (0x20: RXNE)
	beq RXskip		// wait until "not empty" bit set
	//
	ldrb r0,[r1,#4]		// then, input from data register
	mov r1,#1		// event 1: RXin
	b evtend		// ... pop {r1,r2,r3,r4,r8,r9,pc}

RXskip:	// Stylus pressure routines;
	// First, old off until stylus pressure is removed
	//
	ldrb r0,[r4,#stystt]	// Get self-initiating stylus status flag
	cmp r0,#0	// (0 means no pressure yet, r4 is cued to SRAM)
	beq wait_p
	// do not proceed until there is no stylus pressure
	mov r0,#0xB3	// Z1 := 0xB3 (low end - wait for release)
	bl TouchI
	cmp r0,#0	// wait for pen release
	bne RXinLp		// loop until r0 is == 0
	strb r0,[r4,#stystt]	// clear the flag (no pressure)
	b RXinLp	// next time we will take the other branch

	// Then, wait for stylus pressure
	//
wait_p:	mov r0,#0xB3	// Z1 := 0xB3 (low end)
	bl TouchI
	cmp r0,#0	// avoid zero divide
	beq RXinLp	//loop and wait
	mov r1,r0	// save low end (r1:=Z1)
	//
	mov r0,#0xC3	// Z2 := 0xC3 (high end)
	bl TouchI
	subs r2,r0,r1	// subtract low from high (r2:=Z2-Z1)
	//
	mov r0,#0xD3	// X position := 0xD3
	bl TouchI
	mul r2,r2,r0	// multiply result by XPos (Z2-Z1)*XPos
	sdiv r0,r2,r1	// signed divide result by Z1 (Z2-Z1)*XPos/Z1
	//
	mov r3,#0xC600	// high number flakey, low number hard push
			// threshold C700 to high (dots) C600? too low
	cmp r0,r3	// maybe C600 for drawing? (slightly wrong both ways)
	bgt RXinLp	// (loop to wait for pressure) *****

	// text or drawing?
	bl GetXY	// get screen position
	cmp r9,#256	// keybd or not?
	bge tchkey
	// no scrolled drawing
	ldrb r2,[r4,#scroff]	// get scroll flag (r4 is cued to SRAM)
	cmp r2,#0
	bne RXinLp	// no drawing when scrolled
	// drawing  (only draw on unscrolled text area)
	bl PsetXY	// set a point
	b RXinLp

        // Text (keyboard) input
tchkey:	bl beep		// beep
	mov r0,0xff	// set the flag (wait for release)
	strb r0,[r4,#stystt]	// r4 is cued to SRAM
	//
	lsr r2,r9,#4	// character row
	subs r2,#16	// cue to keyboard pos. (was at 1 now at 20-4)
	mov r1,#30	// characters/row
	mul r2,r2,r1	// (multiply)
	add r8,#2	// skew 1/4 key right
	lsr r1,r8,#3	// character column
	add r2,r1	// add to row offset
	ldr r1,[r4,#keybdc]  // cue r1 to the operative keybd codes
	//	     // correct for blank spaces
	ldrb r0,[r1,r2]	// load keycode from text
	cmp r0,#32	// blank?
	bne xchok	// skip if not
	subs r2,#1	// cue to previous (left) key
	ldrb r0,[r1,r2]	// load adjacent keycode from text
xchok:	mov r1,#2	// Event 2: Keyin
evtend: strb r1,[r4,#evntid]	// save event code
	pop {r1,r2,r3,r4,r8,r9,pc}

	//-----------------------
	// Point-Set X,Y (r8,r9)
	//
PsetXY:	push {r0,lr}
	mov r0,#0x2A	// Column ()
	bl SPIC08	// Command
	mov r0,r8	// fetch Column data
	bl SPID16	// Start Data
	bl SPID16	// End Data
	//
	mov r0,#0x2B	// Row
	bl SPIC08	// Command
	mov r0,r9	// fetch Row data
	bl SPID16	// Start Data
	bl SPID16	// End Data
	//
	mov r0,#0x2C	// "home" command
	bl SPIC08	// (top-left pixel of character)
	//
	//		// Set the Point
	ldr r0,=0xFFFF	// New White
	bl SPID16	// Data16
	pop {r0,pc}

	//-----------------------
	// get x,y
				    // X := [7480h - x#] * 240 / 6E00h
GetXY:	push {r0,r1,r2,r3,lr}
	mov r3,#0	// 0 sum
	mov r2,#32	// 32 loops
xposlp:	mov r0,#0xD3	// X position := 0xD3
	bl TouchI				//	//
	add r3,r0	// add x
	subs r2,#1
	bne xposlp	// next loop?
	lsr r0,r3,#5	// /32
	//
	ldr r1,=30045	//(lower-left X)
//	ldr r1,=0x7400	// 7400h
	subs r0,r1,r0	// 7400h-x
	ldr r1,=240	// 240
	mul r0,r0,r1	// [7400h-x]*240 (multiply)
	ldr r1,=27700	// (llX-urX)
//	ldr r1,=0x6E00	// 6E00h
	sdiv r0,r0,r1	// [7400h-x]*240/6E00h (signed divide)
	mov r8,r0	// save x
				    // y := [y# - C30h] * 320 / 6CD0h
	mov r3,#0	// 0 sum
	mov r2,#16	// 16 loops
yposlp:	mov r0,#0x93	// Y position := 0x93
	bl TouchI				//	//
	add r3,r0	// add x
	subs r2,#1
	bne yposlp	// next loop?
	lsr r0,r3,#4	// /16
	//
	ldr r1,=3006	// (upper-right Y)
//	ldr r1,=0xC30	// 0C30h
	subs r0,r1	// y-C030h
	ldr r1,=320	// 320
	mul r0,r0,r1	// [y-0C30h]*320 (multiply)
	ldr r1,=28394	// (llY-urY)
//	ldr r1,=0x6CD0	// 1860h
	sdiv r0,r0,r1	// [y-0C30h]*320/6CD0h (signed divide)
	mov r9,r0	// save Y
	pop {r0,r1,r2,r3,pc}

	// Wait while pen is held on screen
	//
penWt:	push {r0,lr}
pnWtLp:	mov r0,#0xB3	// Z1 := 0xB3 (low end)
	bl TouchI
	cmp r0,#0	// wait for pen release
	bne pnWtLp
	pop {r0,pc}

	//==============================================================
	// RS-232

	// TX subroutine:
TXout:	push {r1,r4,lr}
	ldr r4,[r12,#usart1]	// get USATR1 address from config table
TXlp:	ldr r1,[r4]		// status register (offset 0)
	ands r1,#0x80		// TXEmpty set? (0x20: RXNE)
	beq TXlp		// wait until "empty" bit set
	//
	strb r0,[r4,#4]		// then, output to data register
	pop {r1,r4,pc}

	// RX subroutine:
RXin:	push {r4,lr}
	ldr r4,[r12,#usart1]	// get USATR1 address from config table
RXlp:	ldr r0,[r4]		// status register (offset 0)
	ands r0,#0x20		// TXEmpty set? (0x20: RXNE)
	beq RXlp		// wait until "not empty" bit set
	//
	ldrb r0,[r4,#4]		// then, input from data register
	pop {r4,pc}


	// RX input with 8-bit codes
RX2in:	push {r4,lr}
	ldr r4,[r12,#usart1]	// get USATR1 address from config table
RX2lp1:	ldr r0,[r4]		// status register (offset 0)
	ands r0,#0x20		// TXEmpty set? (0x20: RXNE)
	beq RX2lp1		// wait until "not empty" bit set
	//
	ldrb r0,[r4,#4]		// then, input from data register
	cmp r0,#0x1b	// escape?
	bne RX2nd	// done of not
	//
	ldr r4,[r12,#usart1]	// get USATR1 address from config table
RX2lp2:	ldr r0,[r4]		// status register (offset 0)
	ands r0,#0x20		// TXEmpty set? (0x20: RXNE)
	beq RX2lp2		// wait until "not empty" bit set
	//
	ldrb r0,[r4,#4]		// then, input from data register
	orrs r0,0x80	// turn on 0x80-weight bit
RX2nd:	pop {r4,pc}


	// TX output with 8-bit codes (won't work because of bug elsewhere)
TX2out:	push {r1,lr}
	cmp r0,#0x80	// extended code?
	bmi TX2nd	// done if not
	//
	subs r1,r0,#0x80 // save & make printable
	mov r0,#0xc0	// arbitrary special character
	bl TXout	// output
	mov r0,r1	// recover printable char
	//
TX2nd:	bl TXout	// output the character
	pop {r2,pc}


	//--------------------------------------------------------------
	// Misc. I/O routines: pinin pinhi pinlo wtroms beep

	// read pin input status
pinin:	mov r3,#1	// pull lsb high
	and r2,r0,#0xf	// which pin? (0-15)
	lsls r3,r2	// shift the "1" to the correct bit position
	and r2,r0,#0x70	// which port? (next 3 bits up)
	ldr r4,[r12,#gpioin]	// cue to the GPIO's input register
	add r4,r4,r2,lsl #6	// add the port's offset
	ldr r1,[r4]	// read the port
	mov r0,#0	// default low (false)
	ands r1,r3	// check the correct bit
	beq pinind
	mvns r0,r0	// change to true (if set)
pinind:	bx lr

	// pull a GPIO pin high (selected by r0)
pinhi:	mov r3,#1	// pull high (ls half-word)
	b pinmrg
	// pull a GPIO pin low (selected by r0)
pinlo:	mov r3,#0x10000	// pull low (ms half-word)
	//
pinmrg:	and r2,r0,#0xf	// which pin? (0-15)
	lsls r3,r2	// shift the "1" to the correct bit position
	and r2,r0,#0x70	// which port? (next 3 bits up)
	ldr r4,[r12,#gpionf]	// cue to the GPIO's on/off register
	add r4,r4,r2,lsl #6	// add the port's offset
	str r3,[r4]	// set or reset the correct bit
	bx lr

	// 1 ms. delay: delay in r0
wtr0ms:	push {r1,lr}
wtr0lp:	ldr r1,[r12,#mswait]
wt1mlp:	subs r1,#1
	bne wt1mlp	//16,000,000 clocks/sec * 1 sec/5,325,000 loop = 3 clocks/loop
	subs r0,#1
	bne wtr0lp
	pop {r1,pc}

	// beep the speaker
beep:	push {r1,r2,r3,lr}
	ldr r1,[r12,#mswait]	// get 1 ms. time
	ldr r2,[r12,#gpionf]	// cue to the GPIOA's on/off register
	//
	mov r3,#40		//~20ms.
ggloop:	asrs r0,r1,#2		// 1 ms./4 ~ 4Khz
ggw1:	subs r0,#1		// wait
	bne ggw1
	mov r0,#2		// A1 pin high (1 shifted left by 1)
	str r0,[r2]		// set A1
	//
	asrs r0,r1,#2		// 4 Khz
ggw2:	subs r0,#1		// wait
	bne ggw2
	mov r0,#0x20000		// A1 pin low (1 shifted left by 16+1)
	str r0,[r2]		// reset A1
	//
	subs r3,#1
	bne ggloop
	pop {r1,r2,r3,pc}

	//--------------------------------------------------------------
	//
	// Main Touch Innput Subroutine (Belongs here in Configuration Group)
	//
TouchI:	push {r1,r2,r3,lr}
	// Switch from LCD to Touch:
	bl Tchsel		// Select Touch-screen, Deselect LCD

	// Send command to Touch:
	ldr r1,=0x40013000	// r1 := SPI1:  4001.3000
	//
	strb r0,[r1,#0xC]	// output command/data r0 -> [SPI + Data Reg:=0xC]
	bl waitI0		// Wait & Input
	mov r0,#0		// 0's out for input
	strb r0,[r1,#0xC]	// output zero -> [SPI + Data Reg:=0xC]
	bl waitI5		// Wait & Input
	lsl r3,r2,#8		// get, *256, save (msb)
	strb r0,[r1,#0xC]	// output zero -> [SPI + Data Reg:=0xC]
	bl waitI5		// Wait & Input
	orr r3,r2		// or lsb with msb (return result in r8)
	// Switch back to LOCD again::
	bl LCDsel		// Disable Touch, Enable LCD
	// just output the result (and return)
	mov r0,r3		// return byte
	pop {r1,r2,r3,pc}

	// Wait and Input Subroutine
waitI0:	ldrb r2,[r1,#0xC]	// input data (to clear RXNE) <- [SPI + Data Reg:=0xC]
waitI5:	mov r2,#13		// 14 loops (@3cyc/8Mhz = ~5us)
Wtlp:	subs r2,#1
	bne Wtlp		// wait loop
	// Input
	ldrb r2,[r1,#0xC]	// input data (& clear RXNE) <- [SPI + Data Reg:=0xC]
	bx lr

	//--------------------------------------------------------------
	// LCD

// #2 SPI / LCD  Subroutines
// Due to some timing oddities between the STM32F103 and the ILI9341 SPI
// protocalls (E.g. Compare note on STM32F1 Ref: RM0008 p.711/1132 with the
// ILI9341 Ref: p.63/233), We will be following a somewhat off-beat system of
// handshaking with ing the D/C* control line to simplify the code and to improve
// it's reliability. The downside is that the D/C* timing will look unconventional
// (even a bit confusing) on an oscilloscope. (The D/C* Transitions will be
// delayed by a few bits from where they would normally be expected.) Basically,
// we will wait until the TXE (Transmitter buffer Empty) bit has been set BEFORE
// we set that byte's D/C* bit (ILI9341 Ref. p.63 says it only needs to be set
// before the final bint in each byte). This also means we do our wait-to-send-
// each-byte AFTER we have alredy sent it (but BEFORE we send the following one).
// This is somewhat unconvential, but, in the final analysis, it actually makes
// everything easier.
	// Output an LCD Command or Data byte (in r0) to the SPI -> LCD
	// r0 := data passed	// r5 := scratch
SPIout:	// Set up the necessary Registers:
	ldr r1,=0x40013000	// R1 := SPI1:  4001.3000
	mov r2,#0x02		// r2 := Reverse SPI TXE bit
	//  We don't need to wait for TXE to get set before sending the byte;
	//  it has already been set (either becaus we always wait for TXE after we
	//  send each previous byte, or because nothing has ever been sent yet).
	//  Either way:
SPIou2:	strb r0,[r1,#0xC]	// output command/data r0 -> [SPI + Data Reg:=0xC]
	//  But loading this new byte into the cue means we have now reset TXE back
	//  to zero again ... and so we now have to wait for any previous command
	//  (which was already in the process of being transmitted) to get fully
	//  transmitted (esp-ecially the final bit -- when it checks to see what
	//  that previous Data/Command* status was).
SPIwt:	ldrb r3,[r1,#0x08]	// Check Status Register [SPI + Status:=0x8]
	ands r3,r2		// Wait for TXE (empty) (bit pattern in r2)
	beq SPIwt		// loop until set
	//  So, by now the ILI9341 has been alowed to read D/C* from the previous
	//  byte in the cue and we can safely set it to reflect the type of byte we
	//  have just sent. We will set D/C* immediately after we return from this.
	bx lr

	// LCD select (B11 or B10): (data is transfeered elsewhere)
LCDsel: mov r0,0x0c		// A2 A3 high
	ldr r1,[r12,#gpionf]	// cue to GPIO A's on/off register
	str r0,[r1]		// set or reset the correct bit
	ldr r0,[r12,#gpLCDl]	// cue to LCD select bit (B11/B10)
	ldr r1,[r12,#gBionf]	// cue to GPIO B's on/off register
	str r0,[r1]		// set or reset the correct bit
	bx lr

	// Touch select (A3):	//(data is in r0)
Tchsel:	ldr r2,[r12,#gpLCDh]	// cue to LCD deselect bit (B11/B10)
	ldr r1,[r12,#gBionf]	// cue to GPIO B's on/off register
	str r2,[r1]		// set or reset the correct bit
	ldr r2,=0x00080004	// A3 low, A2 high
	ldr r1,[r12,#gpionf]	// cue to GPIO A's on/off register
	str r2,[r1]		// set or reset the correct bit
	bx lr

	// uSD select (A3):	//(data is in r0)
uSDsel:	ldr r2,[r12,#gpLCDh]	// cue to LCD deselect bit (B11/B10)
	ldr r1,[r12,#gBionf]	// cue to GPIO B's on/off register
	str r2,[r1]		// set or reset the correct bit
	ldr r2,=0x00040008	// A2 low, A3 high
	ldr r1,[r12,#gpionf]	// cue to the GPIO's on/off register
	str r2,[r1]		// set or reset the correct bit
	bx lr

	//--------------------------------------------------------------
	//  LCD-Setup Data Table:
	//
	//    Source: Ilitek ILI9341 Specification (a-Si TFT LCD Single Chip Driver)
	//
	// Command format: Count, LCD commmand, any number of data bytes (if present)
	//   Count 0:	 exit from this routine
	//   Counts 1-7: total byte count in sequence (including theLCD command)
	//   Count 0xFF: wait, followed by 1-byte of wait time (counts x .75ms.)
	//
lcdsud:	.byte 0xFF, 100			// Wait 100ms.
	.byte 2,  0xC0, 0x23		// Power Control 1		p.86
	.byte 2,  0xC1, 0x10		// Power Control 2		p.86
	.byte 3,  0xC5, 0x3E,0x28	// VCOM  Control 1		p,86
	.byte 2,  0xC7, 0x86		// VCOM  Control 2		p.86
	.byte 2,  0x37, 0x00		// ? Vertical Scrolling Start Addr
	.byte 2,  0x3A, 0x55		// Pixel Format Set (55=16-bit 66=18-bit)
	.byte 3,  0xB1, 0x00, 0x1B	// Normal-Mode Frame Control
	.byte 4,  0xB6, 0x0A,0x82,0x27	// Display Function Control 0x0A,0x82,0x27 p.86
	.byte 1,  0x11			// Exit Sleep Mode		p.83,
	.byte 0xFF, 100			// Wait 100ms.	(N*.75ms.)
	.byte 1,  0x29			// Display On			p.83
	.byte 0xFF, 100			// Wait 100ms.	(N*.75ms.)
	.byte 1,  0x13			// ? Normal Display Mode (Reset Default) p.83
	.byte 0xFF,200			// Wait 200ms.

	// drop thru to home & background-fill screen, or ...
	//--------------------------------------------------------------
	// Just do this part of the table to re-home
	// It sets up for: orientation and home/screen clear:
tbhome:	//
	// Flips: [F-Row F-Col R<>C Vref - F-RGB Href 0 0]:  (vert) 48->68->28 (horz)
	// 80: Row adr ordr   40: Col adr ordr	 20: R-C xchg	10: Vert. refresh order
	// 08: 0-RGB 1-BGR    04: Horz. refresh	 02,01: 0,0	ILI, 36h, pp.84,127
	.byte 2,  0x36, 0x98	// Vertical  rev.order,was 88,	Reset:00h, Setup: 1Bh
//	.byte 2,  0x36, 0x38		// Horizontal		(Pick one)
//	.byte 2,  0x36, 0x58		// opposite Vertical
//	.byte 2,  0x36, 0xF8		// opposite Horizontal
	//				// reverse either axis (0x80, 0x40) for mirror
	// Set row and Column Ranges:
	// Horizontal (normal video mode):	(chose H or V to match your pick above)
//	.byte 5,  0x2A, 0, 0, 1, 0x3F	// Set "Column" Range
//	.byte 5,  0x2B, 0, 0, 0, 0xEF	// Set "Row" Range
	// Vertical (phone mode):
	.byte 5,  0x2A, 0, 0, 0, 0xEF	// Set "Column" Range
	.byte 5,  0x2B, 0, 0, 1, 0x3F	// Set "Row" Range
	//
	// Scroll:	T: 0   S:256  B: 64	// (Top fixed, Scroll, Bottom fixed)
	.byte 7,  0x33, 0, 0,  1, 0,  0, 64	// Define the three areas
	.byte 3,  0x37,	0, 0	// Amount to Scroll the middle area (no scroll yet)
	//
	.byte 1,  0x2C		// data: Home & Write
	//
	.byte 0			// Exit
	.align 2

//===================================================================================
//  Table-Driven L.C.D. Setup Routine:
//
LCDsup:	push {lr}		// Remember return address (above)
	adr r8,lcdsud		// r8 := LCD Setup Data Table
	//			// r9 := Each Subsequence Code
	//			// r0 := Individual Commands and Data
	// LCD CS Select:
	bl LCDsel
	//
	// Execute Each Command in Table:
SSCdlp:	ldrb r9,[r8],#1	// Fetch Subsequence Code (and cue to next bytecode):
	//
	// 0 := end			  3 := Command + 2 Data Bytes ...
	// 1 := Command only		  N := Command + N-1 Data Btyes
	// 2 := Command + 1 Data byte	0xFF:= Wait 100ms.
	//
	ands r9,r9		// "End" Code, so
	beq LCDxit		// Exit (to blue-fill screen)
	//
	cmp r9,#0xff		// "Wait 100ms." Code
	bne skpwt		// else skip wait
	ldrb r0,[r8],#1	// Fetch Delay Count (~750us/count)
	bl wtr0ms
	b SSCdlp	// then loop back for next command
	//
skpwt:	ldrb r0,[r8],#1		// Fetch First Code and cue to next
	bl SPIC08		// execute the Command
	//
nxloop:	subs r9,#1		// All Bytes of Command Sent?
	beq SSCdlp		// Get Another SS Code if r6==0 now
	//			// Else Get a Data byte
	ldrb r0,[r8],#1		// Fetch Data (and cue to next)
	bl SPID08		// Send it
	b nxloop		// Check what's next
	//
	//--------------------------------------------------
	//
	// Clear Screen / Home:
	//
HomeSR:	push {lr}	// Remember return address (below)
	adr r8,tbhome	// r8 := LCD "Home" Data Table
	b SSCdlp	// loop back for next command
	// (drops thru from home, by way of setup routine)
LCDxit:	mov r1,#0x20000000	// cue to ram
	mov r0,#0
	str r0,[r1,#xcursr]	// home x and y cursors
	str r0,[r1,#scroff]	// clear scroll flag (etc.)
	//
	ldr r8,=76800	// Full Screen
	ldr r0,[r1,#bakgnd]	// get background color
LCDblp:	bl SPID16	// Send color to screen
	subs r8,#1	// Loop
	bne LCDblp
	pop {pc}	// (Use applicable return address)


//======================================================================
//
//  Configure:

setup:	// Determine Whether we're using a Cortex M3 (STM32F103) or M4 (STM32F4xx):
	//
	//				// presume Cortex M3 information
	adr r12,M3vect		// cue r12 to M3 vectors
	//
	ldr r0,=0x1ffff7e0	// load memory size (this address for stm32f103 only)
	ldrh r9,[r0]		// get size; (blank: ffff if not stm32f103)
	mov r0,#0xffff
	cmp r9,r0		// M4 if == (the only other supported option)
	bne CortexM3		// if non zero, then goto m3 routines
	//				// else  use Cortex M4 instead
	adr r12,M4vect		// cue r12 to M4 vectos

	//==============================================================
	//
	// M4 setup:
CortexM4:
	// Send clocks for LED (port c) also TX,RX & SPI (port a) and misc (port b)
	//
 	ldr r4,=0x40023800	// RCC Base (send clocks to devices)
	mov r5,#7		// RCC_AHB1ENR(0x30): Ports A, B, & C on
	str r5,[r4,#0x30]	// (store 4002.3830 msb)

	mov r5,#0x1010		// RCC_APB2(0x44): USART(4) & SPI(12) on
	str r5,[r4,#0x44]	// (store 4002.3844)
	//
//	mov r5,#0x1000		// RCC_APB2(0x24): SPI(12) on
//	strb r5,[r4,#0x24]	// (store 4002.3824)
//	strb r5,[r4,#0x44]	// (store 4002.3844)

	// Setup Port Outputs
	// A: ----------------------------------------------------------
	// Hardware:		Setup:
	// A15:	--		Normal input
	// A14:	--		Normal input
	// A13:	--		Normal input
	// A12:	--		Normal input
	// A11:	--		Normal input
	// A10	RX (RS232 in)	Input with Pull-Up (odr=1)
	// A9:	TX (RS232 out)	Alternate Function Output
	// A8:	--		Normal input
	// A7:	SPI_MOSI	Alternate Function Output
	// A6:	SPI_MISO	Input with Pull-Up (odr=1)
	// A5:	SPI_SCK		Alternate Function Output
	// A4:	LCD_LED		Normal Output (odr=1)
	// A3:	Touch_Select	Normal Output (odr=1)
	// A2:	uSD_Card_Select	Normal Output (odr=1)
	// A1:	Beeper		Normal Output
	// A0:	STM32F411 "Key"	input (pulled up)
	//
	// Make Port A: TX,RX, MISO,MOSI,SCK (a5,a6,a7,a9,a10) alt-function
	// Make A1-a4 outputs
	ldr r4,=0x40020000	// Port A: 13 12 11 10  9  8  7  6  5  4  3  2  1  0
	ldr r5,=0x0028a954	//   00 00.00 00|00 10.10 00|10 10.10 01|01 01.01 00
	str r5,[r4]		//	in: 00,  out: 01,  alt: 10,  analog: 11
	mov r5,#1		//   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01
	str r5,[r4,#0x0c]	//	none: 00,  pu: 01,  pd: 10,  reserved: 11
	mov r5,#0x10		//   a4 (LCD backlight) on
	str r5,[r4,#0x14]	//  SET OUTPUT DATA
	// Set AF7 on a9 & a10 to select USART1, AF5 on a5, a6, & a7 for SPI1
	ldr r5,=0x55500000	// mosi miso sck: AF5
	str r5,[r4,#0x20]	// GPIOA_AFRL
	mov r5,#0x0770		// RX TX: AF7
	str r5,[r4,#0x24]	// GPIOA_AFRH
	//
	// B: ----------------------------------------------------------
	// B15-B12		"Penguin" Outputs
	// B11: LCD_Select	Normal Output
	// [error: B10: LCD D/C	Normal Output] (input)
	// B9:   --		Normal Input
	// B5-B8:--		"Penguin" Outputs
	// B0-B4:--		Normal Inputs (except B2 is D/C*)
	//
	// Make Port B: outputs on 5-8, 10,11, 12-15
	ldr r4,=0x40020400	// Port B: 13 12 11 10  9  8  7  6  5  4  3  2  1  0
	ldr r5,=0x55515410	//   01 01.01 01|01 00.00 01|01 01.01 00|00 01.00 00
	str r5,[r4]		// output:  00: in, 01: out: 10: alt, 11: analog
	//
	// C: ----------------------------------------------------------
	// Make Port C: (LED output on c13)
	ldr r4,=0x40020800	// Port C: 13 12 11 10  9  8  7  6  5  4  3  2  1  0
	mov r5,#0x04		//   00 00.01 00|00 00.00 00|00 00.00 00|00 00.00 00
	strb r5,[r4,#3]		// output:  00: in, 01: out: 10: alt, 11: analog

	// USART1 Setup: -----------------------------------------------
	//
	ldr r4,=0x40011000	// USART1 p.91
	mov r5,#0x8b		// 115200 baud from 16Mhz system clock p.97
	str r5,[r4,#8]		// USART1_BRR p.91
	mov r5,#0x0c		// enable TX and RX (8 data bits) p.109
	str r5,[r4,#0xc]	// USART1_CR1 pp. 91,109
	mov r5,#0
	str r5,[r4,#0x10]	// USART1_CR2 1 stop bit
	str r5,[r4,#0x14]	// USART1_CR3 no flow control
	mov r5,#0x200c		// Enable USART1 (+ enable TX and RX, 8 data bits)
	str r5,[r4,#0xc]	// USART1_CR1

	// SPI1 --------------------------------------------------------
	// Serial Peripheral Interface Bus (pronounced "spy bus") Setup:
//same	ldr r1,=0x40013000	// SPI1
	// SPI1		4001.3000				Mazidi(F4)  p.238
	// SPI2		4000.3800
	// SPI3		4000.3C00
	//	CR1	(+0x0)	Control Register 1
	//	CR2	(+0x4)	Control Register 2
	//	SR	(+0x8)	Status Register
	//	Dr	(+0xC)	Data Register
	//
	//Control Register 1:					Mazidi(F4) p.240
	// bidim bidio crce crcn.dff rxo SSM SSI.lsb SPE baud baud.baud MSTR CPOL CPHA
	//   0    0     0    0  . 0   0   1   1 . 0   1   0    0  . 1    1    0    0
	//						3:/16 2:/8 1:/4 0:/2
//same	ldr r0,=#0x034C		// SSM, SSI, SPR, 001=PCLK/4, MSTR, CPOL, CPHA
//same	strh r0,[r1,#0]		// (CR1 = +0)
	//
	// Status Register:					Mazidi(F4)  p.244
	// fre bsy ovr modf crcerr . udr cnside TXE RXNE	(fre added, else same)
	b runcc		// done with M4 setup, so run common code

	//==============================================================
	//
	// M3 Setup:
CortexM3:
	// Turn on some different Clock sources (using an RCC register):

	ldr r1,=0x40021000	// Cue to RCC Base:

	// (This is the base-address for the Register-Clock-Control: RCC)
	// Here are the offsets:
	//	CFGR	(0x4)		Clock Configuration: see Mazidi p.221
	//	APB1ENR (0x14)	p.208, 224-5
	//	APB2ENR (0x18)	p.208, 224-5   <- we use this one (0x18 = 24)
	//	AHBENR  (0x1C)	p.208

	ldr r0,=0x8501C		//Send clocks to USART1, SPI1, & PORTS C,B,& A

	// Send clocks to (power up) the following peripheral units:
	//			Port A: 0x0004
	//			Port B: 0x0008
	//			Port C: 0x0010
	//			USART1: 0x4000
	//			SPI  1: 0x1000
	//			--------------
	// The Combined Bit Pattern is:	0x501C

	strh r0,[r1,#24]  // Send this bit pattern ro RCC (offset: 24=0x18)

	// The #24 offset is because there are different RCC registers.
	// We want the one which begins 24 bytes from the start of the
	// RCC part of memory address space which is dedicaated to this
	// particual function.

	// Base registers:
	//
	// port A	4001.0800
	// port B	4001.0C00
	// port C	4001.1000	// LED PC13
	// port D	4001.1400	D, E, etc. (not available on all STM32F103s)
	//	Individual regiter offsets:
	//	CRL	(+0x0)	Configuration Register Low	Mazidi pp.205-6
	//	CRH	(+0x4)	Configuration Register High	pp. 205-6
	//	IDR	(+0x8)	Input Data Register			pp. 205,7
	//	ODR	(+0xC)	Output Data Register (& Pull U or D) 205,7
	//	BSR	(+0x10)	Bit Set-Reset Register		pp. 205,213
	//	BRR	(+0x14)	Bit Reset Register (2nd half of RSR) 205,212
	//	LCKR	(+0x18)	Lock Register
	//		Contents:
	//		GPIO CRH/CRL setup:			Mazidi	p.206
	//		    Short version:	0: ADC input
	//		     (each nibble)	3: normal digital output
	//					4: normal digital input
	//					8: input with pull-up
	//					B: alternate function

	// GPIO A SETUP:

	//	Hardware:		Setup:
	//	A15: --			4: Normal input
	//	A14: --			4: Normal input
	//	A13: --			4: Normal input
	//	A12: --			4: Normal input
	//	A11: --			4: Normal input
	//	A10: RX (RS232 input)	8: Input with Pull-Up (odr=1)
	//	A9:  TX (RS232 output)	B: Alternate Function Output
	//	A8:  --			4: Normal input

	ldr r1,=0x40010800	// First, set GPIO_A port address:
	ldr r0,=0x444448B4 // A15:4 A14:4 A13:4 A12:4 A11:4 A10:8 A9:B A8:4
	str r0,[r1,#4]		// GPIO_A (CRH offset: 4)

	//	Hardware:		Setup:
	//	A7:  SPI_MOSI		B: Alternate Function Output
	//	A6:  SPI_MISO		8: Input with Pull-Up (odr=1)
	//	A5:  SPI_SCK		B: Alternate Function Output
	//	A4:  LCD_LED		3: Normal Output (odr=1)
	//	A3:  Touch_Select	3: Normal Output (odr=1)
	//	A2:  uSD_Card_Select	3: Normal Output (odr=1)
	//	A1:  Beeper		3: Normal Output
	//	A0:  --			4: Normal input

	ldr r0,=0xB8B33334	// A7:B A6:8 A5:B A4:3 A3:3 A2:3 A1:3 A0:4
	str r0,[r1]		// GPIO_A (CRL offset: 0)

	// 0000.0100 0101.1100	// Pull-high (odr=1) bit pattern
						// (collected from above information)
	ldr r0,=0X45C		// (Hex value for Output Data Register)
	strh r0,[r1,#12]	// GPIO_A (ODR offset: 12)

	// GPIO B SETUP:
	//
	//	B15-B12			4,4,4,4: Normal inputs
	//	B11: LCD_Select		3: Normal Output
	//	B10: LCD D/C		3: Normal Output
	//	B9:  --			4: Normal input
	//	B8:  --			4: Normal input

	ldr r1,=0x40010C00	// GPIO_B Base Register:
	ldr r0,=0x44443344	// I I I I.O O I I  3:out 4:in
	str r0,[r1,#4]		// CRH Control Reg. High (offset=4)


	// GPIO C SETUP:  (Same as before)
	//
	// Set pin C13 (The Green LED) of GPIO Port C to be an output:

	ldr r1,=0x40011000	// GPIO_C Base Register:

	// Here we really only need to set one byte:

	movs r0,#0x34		// part of ldr r0,=0x44344444
	strb r0,[r1,#6]		// part of CRH Control Reg. High (offset=4+2)



	// RS-232 USART1 setup:

	ldr r1,=0x40013800	// USART1 0x40013800
					//(USART2 0x40014400, USART3 0x40014800)
	// Set BAUD rate using baud-rate register:

	movs r0,#70			//   8Mhz/115200 ~= 69.4444
	strh r0,[r1,#8]		//   (baud index: 8)

	// Configure:		// Using configuration register "CR1"

	mov r0,0x200C		//  Set bits: UE--- ---- ---- TE.RE--
//	mov r0,0x800C		// ???
	strh r0,[r1,#12]		//  CR1 index: 12 (CR2 index: 16)

// Cut and paste everything above from previous setup
//---------------------------------------------------------------
// Then add this new setup procedure:
runcc:	// This code is common to both M3 and M4 processors
	//
	// SPI 1 setup:	Serial Peripheral Interface Bus (pronounced "spy bus")
	//
	ldr r1,=0x40013000	// SPI1				RM0008 p.22.5 (742-751)
	// SPI1		4001.3000				Mazidi	p.443-8
	// SPI2		4000.3800
	// SPI3		4000.3C00	(not on STM32F103)
	//	CR1	(+0x0)	Control Register 1
	//	CR2	(+0x4)	Control Register 2		???
	//	SR	(+0x8)	Status Register				p.446-7
	//	Dr	(+0xC)	Data Register				p.446
	//
	//Control Register 1:					Mazidi p.444-5
	// bidim bidio crce crcn.dff rxo SSM SSI.lsb SPE baud baud.baud MSTR CPOL CPHA
//	//   0    0     0    0  . 0   0   1   1 . 0   1   0    0  . 1    1    1    1
	//   0    0     0    0  . 0   0   1   1 . 0   1   0    0  . 1    1    0    0
	//					  	      2:/8 1:/4 0:/2
//	ldr r0,=#0x034F		// SSM, SSI, SPR, 001=PCLK/4, MSTR, CPOL, CPHA
	ldr r0,=#0x034C		// SSM, SSI, SPR, 001=PCLK/4, MSTR, CPOL, CPHA
	strh r0,[r1,#0]	//   (CR1 = +0)
	//
	// Status Register:					Mazidi	p.446-7
	// bsy ovr modf crcerr . udr cnside TXE RXNE


//---------------------------------------------------------
//
//  New Code:
//
//  Here we will write to the LCD display
//	Many steps are required:
//
//	1) Setting up the SPI interface (We just did that immediately above)
//	2) Using the SPI interface to send data the LCD Display (subroutines: middle)
//	3) Setting up the LCD Display (complex table-driven subroutine: end + table)
//	4) Setting pixels on the LCD Display (immediately below)
//	5) Displaying meaningful information on the LCD Display (future units)


//=====================================================================================
//
//  Set some Pixels (left to right, top to bottom)

	// Run the table-driven setup routine (#3 calls simpler routines from #2)
	mov r1,0x20000000	// cue to low RAM
	//
	ldr r0,= 0x10ffff	// select bckgrnd (blue:10) & forgrnd (white:ffff)
	str r0,[r1,#bakfor]	// set both background(msh) and foreground(lshw)
	bl LCDsup		// Configure the display (call #3)
	mov r0,#0x11		// small LCD font (must follow LCDsup{setup}previous)
	strh r0,[r1,#fontsz]	// set font size

	// I/O vector Setup:
///	ldr r0,=RXin+1		// RX input (Thumb-2) vector
//	ldr r0,=RX2in+1		// (or esc-enhanced version)
	ldr r0,=Event+1
	str r0,[r1,#inpvct]	// set up input vector
	//
	ldr r0,=SYSout+1	// both TX and LCD outputs
//	ldr r0,=TXout+1		// TX output (Thumb-2) Vector
///	ldr r0,=TX2out+1	// (or esc-enhanced version)
	str r0,[r1,#outvct]	// set up output vector

	// Eden ("Forth" OS Byte-Code) Interpreter Setup:
	add r7,r1,#dstckb	// set d-stack pointer to low in RAM
	str r7,[r1,#psrnd]	// (also use this for first pseudo-random number: rnd)
	ldr r0,=jtvect	// cue r0 to jTable address (out of " adr r0,jvect" range)
	ldr r10,[r0]	// then load r10 with that address

	// Launch "Ti":
	adr r11,banner	// cue to command string (ends with command-line)
	ldrb r0,[r11],#1	// load transfer code; Incriment for next in chain
	ldr r15,[r10,r0,lsl #2]	// Transfer  control to that bytecode routine
	// Sign-on Banner:
banner:	.ascii "$DNArgot Don Stoner 2021.05.15\0O"
	.byte 0x1B			// install keyboard
	// Run command line shell:
cline:	.ascii "[$\n>\0O I E_F]\0"	// requires reset to exit	unit 10

//
//===================================================================================

	.end
//
// usage:
//	nano os.s
//	as -o temp.o os.s
//	./stmld		// (hold and reset)
//	./stmid
//	./stmerase	// 103
//	./stme4		// 411
//	./stmid		// 411	// (hold and reset)
//	./stmburn
//	./term		// (reset alone)

