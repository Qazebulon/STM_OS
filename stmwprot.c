// file: /stm32/burn/stmwprot.c		11/18/2020	Don Stoner
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
	serialPutchar (fd, 0x63); delay(1); // write-protect command
	serialPutchar (fd, 0x9c); delay(1); // (compliment)
	ch=serialGetchar(fd);		// get response (times out after 10 seconds)
	if (ch != 0x79) {
		printf(", NACK1");
	} else {
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) {
			printf(", NACK2");	// receive ACK
		} else {
			printf("Write Protected\n");
		}
	}

	//	Shutdown Serial
	//
	serialClose (fd);	// close serial connection
}

//---------------------------------------------------------------------------------------------
// usage:
//	nano stmwprot.c
//	gcc -o stmewprot stmewprot.c -l wiringPi
//	./stmewprot

