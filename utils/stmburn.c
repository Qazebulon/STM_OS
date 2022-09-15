// file: /stm32/burn/stmburn.c		12/05/2020	Don Stoner
//
#include <stdio.h>		// we need this for console I/O
#include <wiringPi.h>		// we only need this for the delays
#include <wiringSerial.h>	// we need this for the serial stuff

int ch, fd, cmmnd, code, device, adr2, adr3, chks, lsb, msb;

// Main Routine:
//
void main( int argc, char *argv[] )  {		// argc is the number of arguments passed
						// argv is a "character" (string) array
	//	Evaluate command-line options
	//
	adr2=0;		// default start at address 0(*256)	//if argc==1
	adr3=0xffff;	// default block count = "unlimited"
	if( argc > 1 ) {					//if argc==2 or 3
		sscanf( argv[1], "%d", &adr2);	// convert starting address to number
	}
	else if( argc > 2 ) {					//if argc==3
		sscanf( argv[2], "%d", &adr3);	// convert block size to a number too
	}
	else {
	}

	//	Set-up to read file "temp"
	//
	FILE * fin;		// the Input file handle pointer is “fin”
	int byte;		// each byte read will be saved here (-1 means e.o.f.)
	int n=0;		// start the byte counter at zero
	fin=fopen("temp","r");	// open the object file "fin" for read

	//	Set-up Pi serial port
	//
	fd=serialOpen ("/dev/serial0", 115200);	// open serial port

	//	Send Data
	//
	byte=0;				// don't exit before first loop
	while (adr3>0 && byte>=0) {	// count pages as long as input file not empty
		printf(".");	// mark progress
		//
		//	Write One 256-Byte Block
		//
		serialPutchar (fd, 0x31); delay(1); // write command
		serialPutchar (fd, 0xce); delay(1); // (compliment)
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) { printf(", NACK1"); }	// receive ACK
		//
		chks=0x08 ^ adr2;	// calculate page-address check"sum" (xor)
		serialPutchar (fd, 0x08); delay(1); // address0 08 (0800xx00)
		serialPutchar (fd, 0x00); delay(1); // address1 00
		serialPutchar (fd, adr2); delay(1); // address2 adr2
		serialPutchar (fd, 0x00); delay(1); // address3 00
		serialPutchar (fd, chks); delay(1); // check"sum"
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) { printf(", NACK2"); }	// receive ACK
		//
		serialPutchar (fd, 0xff); delay(1); // length-1
		code=0; chks=0xff;	// zero codecount, include length-1 in checksum
		while (code<256) {		// print 256 bytes of data
			byte=getc(fin);		// read a byte from the input file
			chks=chks^byte;		// "add" to check"sum"
			serialPutchar(fd,byte); delay(1);
			code++;
		}
		serialPutchar (fd, chks); delay(1); // (send check"sum")
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) { printf(", NACK3"); }	// receive ACK
		//
		adr2=adr2+1;		// advance to next page and
		adr3=adr3-1;		// decriment page counter
	}
	printf("Done\n");	// mark end
	//	Shutdown
	//
	serialClose (fd);	// close serial connection
	fclose(fin);		// close the input file
}

//---------------------------------------------------------------------------------------------
// usage:
//	nano stmburn.c
//	gcc -o stmburn stmburn.c -l wiringPi
//	./stmburn
