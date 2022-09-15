// file: /stm32/burn/stmwren.c		11/18/2020	Don Stoner
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
	serialPutchar (fd, 0x73); delay(1); // write-enable command
	serialPutchar (fd, 0x8c); delay(1); // (compliment)
	ch=serialGetchar(fd);		// get response (times out after 10 seconds)
	if (ch != 0x79) {
		printf(", NACK1");
	} else {
		ch=serialGetchar(fd);	// get response (times out after 10 seconds)
		if (ch != 0x79) {
			printf(", NACK2");	// receive ACK
		} else {
			printf("Write Enabled\n");
		}
	}

	//	Shutdown Serial
	//
	serialClose (fd);	// close serial connection
}

//---------------------------------------------------------------------------------------------
// usage:
//	nano stmwren.c
//	gcc -o stmewren stmewren.c -l wiringPi
//	./stmewren

