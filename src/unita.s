// unit3.s				// Rev. 11/02/2020
//
	.thumb			// Generate STM32F Family Thumb2 code
	.syntax unified		// (Unified is an Easier Syntax)
	.org 0			// Start at zero

	// Startup Vectors:
	.word   0x20001000	// 1) set stack pointer
	.word   setup   +1	// 2) jump to code (+1 means "thumb")

setup:	// We will begin with the same setup code we used in Unit2.s:

	// Turn on some different Clock sources (using an RCC register):
	// (This is the base-address for the Register-Clock-Control: RCC)
	// Here are the offsets:
	//	CFGR	(0x4)		Clock Configuration: see Mazidi p.221
	//	APB1ENR (0x14)	p.208, 224-5
	//	APB2ENR (0x18)	p.208, 224-5   <- we use this one (0x18 = 24)
	//	AHBENR  (0x1C)	p.208

	ldr r1,=0x40021000	// Cue to RCC Base:

	// Send clocks to (power up) the following peripheral units:
	//			Port A: 0x0004
	//			Port B: 0x0008
	//			Port C: 0x0010
	//			USART1: 0x4000
	//			SPI  1: 0x1000
	//			--------------
	// The Combined Bit Pattern is:	0x501C

	ldr r0,=0x501C		//Send clocks to USART1, SPI1, & PORTS C,B,& A
	strh r0,[r1,#24]  // Send this bit pattern ro RCC (offset: 24=0x18)

	// The #24 offset is because there are different RCC registers.
	// We want the one which begins 24 bytes (0x18) from the start
	// of the RCC part of memory address space which is dedicaated
	// to this particual function.

	// Base registers:
	//
	// port A	4001.0800
	// port B	4001.0c00
	// port C	4001.1000	// LED PC13
	// port D	4001.1400	(not on STM32F103)
	// port E	4001.1800		"
	// port F	4001.1c00		"
	// port G	4001.2000		"
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
	//	A0:  User Input		4: Normal input

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

	movs r0,#70		//   8Mhz/115200 ~= 69.4444
	strh r0,[r1,#8]	//   (baud index: 8)

	// Configure:		// Using configuration register "CR1"

	mov r0,0x200C		//  Set bits: --UE- ---- ---- TE.RE--
	strh r0,[r1,#12]	//  CR1 index: 12 (CR2 index: 16)


//---------------------------------------------------------
//
//  Here we will write a very simple "Operating System":
//
loop:
	// First, read a single-character "commnrd" and echo it:
	bl RXin			// Get one ASCII character (into r0)
	bl TXout		// Then ransmit it back to the Pi

	// Setup for controlling the LED on C13:
	movs r2,#1		// Set LSB (bit zero) to "1"	(setup)
	lsls r2,#13		// Then shift it left 13 times for Port C13
	ldr r1,=0x40011000	// Also Cue r1 to GPIO_C Base Register:

	// Setup for controlling the LED on A4 (the LCD screen):
//	movs r4,#1		// Set LSB (bit zero) to "1"	(setup)
//	lsls r4,#2		// Then shift it left 4 times for Port A4
	mov r4,#0x10		// (or just load the bit already shifted)
	ldr r3,=0x40010800	// Also Cue r3 to GPIO_A Base Register:

	// 0x40020010


	// Was the command a "1"
	cmp r0,#0x31	// Compare r0 to the ASCII code for "1"
	bne not1	// Skip this section if it didn't match
	// But do this if it was a "1":
	str r2,[r1,#0x14]	// Turn the LED ON (inverted logic)
	b loop		// Go back and get another command
not1:
	// Was the command a "2"
	cmp r0,#0x32	// Compare r0 to the ASCII code for "2"
	bne not2	// Skip this section if it didn't match
	// But do this if it was a "2":
	str r2,[r1,#0x10]	// Turn the LED OFF (inverted logic)
	b loop		// Go back and get another command
not2:
	// Was the command a "3"
	cmp r0,#0x33	// Compare r0 to the ASCII code for "3"
	bne not3	// Skip this section if it didn't match
	// But do this if it was a "3":
	str r4,[r3,#0x10]	// Turn the LCD's LED ON (not inverted)
	b loop		// Go back and get another command
not3:
	// Was the command a "4"
	cmp r0,#0x34	// Compare r0 to the ASCII code for "4"
	bne not4	// Skip this section if it didn't match
	// But do this if it was a "4":
	str r4,[r3,#0x14]	// Turn the LCD's LED OFF (not inverted)
	b loop		// Go back and get another command
not4:
	// Was the command a "5"
	cmp r0,#0x35	// Compare r0 to the ASCII code for "5"
	bne not5	// Skip this section if it didn't match
	// But do this if it was a "5":
	bl beep		// Beep; the speaker
	b loop		// Go back and get another command
not5:
	// If we didn't have a routine for the key, then do this:
	str r2,[r1,#0x14]	// LED ON
	bl beep		// (use the beep time for the wait)

	str r2,[r1,#0x10]	// LED OFF
			// (and just wait for next key)

	b loop	// One blink, then loop back for another command

//---------------------------------------------------------------
//
//  Subroutines:

// TX Send Routine:		Writes DATA from r0 to port A9 (TX1)
TXout:
	// setup:
	push {r1,r2,r3,lr}	// save r1, r2, r3 and lr (the return address)
	ldr r1,=0x40013800	// Usart1 (controls TX1, status index: 0)
	movs r2,#0x80		// Cue position for the “TX ready” test bit

	// Next, wait until the USART is redy:
TXwait:
	ldrh r3,[r1]	// Get status into r3 (index: 0, so we can omit it)
	ands r3,r2		// "AND" away everything except the "TX-ready" bit
	beq TXwait		// loop here until the TX-ready is non-zero

	// Finally, output the data (from r0)

	strb r0,[r1,#4]	// output the data to serial port (data index: 4)
	pop {r1,r2,r3,pc}  // restore registers & return (lr goes to pc)
				// This both restores the registers & returns

// RX Receive Routine:	Reads from port A10 (RX1) into register r0
RXin:
	// setup:
	push {r1,r2,r3,lr}	// save r1, r2, r3 and lr (the return address)
	ldr r1,=0x40013800	// Usart1 (status index:0)
	movs r2,#0x20		// Cue position for the “RX ready” test bit

	// Next, wait until the USART is redy:
RXwait:
	ldrh r3,[r1]		// Get the status data
	ands r3,r2			// “AND” away everything but the RX ready bit
	beq RXwait			// wait until ready

	// Get data and return
	ldrb r0,[r1,#4]		// (data offset: 4)
	pop {r1,r2,r3,pc}	// restore registers & return (lr goes to pc)
				// This both restores the registers & returns

// Beep Subroutine:
beep:	push {r1,r2,r3,r4,r5,lr}
	ldr r1,=0x40010800	// GPIO A
	mov r2,#0x02		// GPIO A, PA1: 0x02 Speaker (already shifted)
	mov r3,#30		//~10ms.
	ldr r4,=800		// 8000000/800=10000hz/3cyc~3300hz
	//
ggloop:	mov r5,r4
ggw1:	subs r5,#1
	bne ggw1
	strh r2,[r1,#0x10]	// Turn On
	//
	mov r5,r4
ggw2:	subs r5,#1
	bne ggw2
	strh r2,[r1,#0x14]	// Then Off
	//
	subs r3,#1
	bne ggloop
	pop {r1,r2,r3,r4,r5,pc}
//
// nano unita.s
// as -o temp.o unita.s
// ./stmld	// (temp.o -> temo) implied
// (reset device)
// ./stmid
// ./stmerase
// ./stmburn	// (temp imlied)
// ./term

