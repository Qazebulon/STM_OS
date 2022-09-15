// fix argument passing
//
// file: /stm32/burn/stmerase.c		11/16/2020	Don Stoner
//
#include <stdio.h>	// stdio.h is unnecessary because ncurses already uses it
#include <wiringPi.h>	// this is also unnecessary (we only need serial stuff):
#include <wiringSerial.h>

int ch, fd, cmmnd, code, device, adr2, adr3, chks, lsb, msb;

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
void main( int argc, char *argv[] ) {	// argc=# of arguments passed
					//
	//	Get page count (or just assume 2)
	//
//	if ( argc==1 ) {
//		adr3=2;
//	} else {
//		adr3= *argv[2] * 4;		//each count = 1K (4*256)
//	}
	//	Set-up Pi serial port
	//
	fd=serialOpen ("/dev/serial0", 115200);	// open serial port

	//	Set Device baud rate
	//
////	serialPutchar (fd, 0x7f); delay(1);	// synch devices
////	ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
////	adr2=0;
////	if (ch == 0x79) {	// baud rate is correctly set

		//	ID Device
		//
//		cmmnd = 0x02; serialPutchar (fd, cmmnd); delay(20);	// request device ID
//		cmmnd = 0xfd; serialPutchar (fd, cmmnd); delay(20);	// (send compliment)
//		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
//		if (ch != 0x79) { printf("NACK2\n"); }		// receive ACK
//		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
//		if (ch != 0x01) { printf("NACK3\n"); }		// receive ACK
//		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
//		if (ch != 0x04) { printf("NACK4\n"); }		// receive ACK
//		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
//		//
//		printf("STM32F");
//		if (ch==0x10) { printf ("103"); }	// ID the device
//		if (ch==0x12) { printf ("103-L"); }
//		if (ch==0x13) { printf ("405/407"); }
//		if (ch==0x14) { printf ("103-H"); }
//		if (ch==0x18) { printf ("103-cnct"); }
//		if (ch==0x19) { printf ("42xxx/43xxx"); }
//		if (ch==0x23) { printf ("401-B/C"); }
//		if (ch==0x30) { printf ("103-X"); }
//		if (ch==0x31) { printf ("411"); }
//		if (ch==0x33) { printf ("401-D/E"); }
//		if (ch==0x44) { printf ("030"); }
//		printf(" (%x)\n", ch);
//		//
//		ch=serialGetchar(fd);	// get response (else times out after 10 seconds)
//		if (ch != 0x79) { printf("NACK5\n"); }		// receive ACK

		//	Erase Entire Device
		//
		serialPutchar (fd, 0x43); delay(1); // read command
		serialPutchar (fd, 0xbc); delay(1); // (compliment)
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) { printf(", NACK1"); }	// receive ACK
		//
		serialPutchar (fd, 0xff); delay(1); // clear all
		serialPutchar (fd, 0x00); delay(1); // (compliment)
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) {
			printf(", NACK2");	// receive ACK
		} else {
			printf("Device Erased\n");
		}
////	} else {
////		printf ("** timeout: check connections, boot0 to 1, reset device, rerun ***\n");
////	}
	//	Shutdown
	//
	serialClose (fd);	// close serial connection
}

//---------------------------------------------------------------------------------------------
// usage:
//	nano stmdump.c
//	gcc -o stmerase stmerase.c -l wiringPi
//	./stmerase

