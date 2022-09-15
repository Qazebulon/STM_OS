// file: /stm32/burn/stmerprot.c		11/18/2020	Don Stoner
//
#include <stdio.h>
#include <wiringPi.h>
#include <wiringSerial.h>

int ch, fd;

//
// Main Routine:
//
void main() {
	//	Setup Serial
	//
	fd=serialOpen ("/dev/serial0", 115200);	// open serial port

	//	Read Enable and Erase Entire Device
	//
	serialPutchar (fd, 0x82); delay(1); // read-protect command
	serialPutchar (fd, 0x7d); delay(1); // (compliment)
	ch=serialGetchar(fd);		// get response (times out after 10 seconds)
	if (ch != 0x79) {
		printf(", NACK1");
	} else {
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) {
			printf(", NACK2");	// receive ACK
		} else {
			printf("Read Protected\n");
		}
	}

	//	Shutdown Serial
	//
	serialClose (fd);	// close serial connection
}

//---------------------------------------------------------------------------------------------
// usage:
//	nano stmrprot.c
//	gcc -o stmerprot stmerprot.c -l wiringPi
//	./stmerprot

