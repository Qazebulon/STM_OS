
// file: /stm32/burn/term.c	11/11/2020	Don Stoner
//
#include <stdio.h>	// stdio.h is unnecessary because ncurses already uses it
#include <wiringPi.h>	// this is also unnecessary (we only need serial stuff):
#include <wiringSerial.h>

int ch, fd;

//---------------------------------------------------------------------------------------------
//
//  Subroutines:

//	STM ID Routine:
//
void stmid () {
}

//---------------------------------------------------------------------------------------------
//
// Main Routine:
//
void main() {
	//	Set-up Pi serial port
	//
	fd=serialOpen ("/dev/serial0", 115200);	// open serial port

	//	Set Device baud rate
	//
	int cmmnd = 0x7f; serialPutchar (fd, cmmnd); delay(20);	// synch devices
	ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
	if (ch == 0x79) {
		//	ID Device
		//
		cmmnd = 0x02; serialPutchar (fd, cmmnd); delay(20);	// request device ID
		cmmnd = 0xfd; serialPutchar (fd, cmmnd); delay(20);	// (send compliment)
		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
		if (ch != 0x79) { printf("NACK2\n"); }		// receive ACK
		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
		if (ch != 0x01) { printf("NACK3\n"); }		// receive ACK
		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
		if (ch != 0x04) { printf("NACK4\n"); }		// receive ACK
		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
		//
		printf("STM32");
		if (ch==0x10) { printf ("F103/F102R8"); }	// ID the device
		if (ch==0x12) { printf ("F103-L"); }
		if (ch==0x13) { printf ("F405/F407"); }
		if (ch==0x14) { printf ("F103-H"); }
		if (ch==0x16) { printf ("L15xxB"); }
		if (ch==0x18) { printf ("F103-cnct"); }
		if (ch==0x19) { printf ("F42xxx/F43xxx"); }
		if (ch==0x20) { printf ("F100xx"); }
		if (ch==0x23) { printf ("F401-B/C"); }
		if (ch==0x27) { printf ("L15-C"); }
		if (ch==0x29) { printf ("L15xxB-A"); }
		if (ch==0x30) { printf ("F103-X"); }
		if (ch==0x31) { printf ("F411"); }
		if (ch==0x32) { printf ("F437xx"); }
		if (ch==0x33) { printf ("F401-D/E"); }
		if (ch==0x35) { printf ("L44xx"); }
		if (ch==0x40) { printf ("F05x"); }
		if (ch==0x41) { printf ("F412"); }
		if (ch==0x42) { printf ("F09x"); }
		if (ch==0x44) { printf ("F03x"); }
		if (ch==0x48) { printf ("F07xB"); }
		if (ch==0x50) { printf ("F74x"); }
		if (ch==0x51) { printf ("F76x"); }
		if (ch==0x60) { printf ("G71xx"); }
		printf(" (4%x)\n", ch);
		//
		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
		if (ch != 0x79) { printf("NACK5\n"); }		// receive ACK
	} else {
		printf ("*** timeout error ****: check connections, boot0 to 1, reset device, and rerun\n");
	}
	//	Shutdown
	//
	serialClose (fd);	// close serial connection
}

//---------------------------------------------------------------------------------------------
// usage:
//	nano stmid.c
//	gcc -o stmid stmid.c -l wiringPi
//	./stmid
