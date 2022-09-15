#include <stdio.h>		// include the console I/O function library
void main () {			// identify where execution should begin
	FILE * fin;		// the Input file handle pointer is “fin”
	FILE * fout;		// the Output file handle pointer is “fout”
	int byte;		// each byte read is saved here (-1 means e.o.f.)
	int n=0;			// start the byte counter at zero
	int start=52;		// the code starts at 52 (34h) 
	int end=16384+52;		// the code ends at 4148 (= 52 + 4096)
	fin=fopen("temp.o","r");	// open the object file "fin" for read
	fout=fopen("temp","w");	// open the binary file "fout" for write

//	while (byte != -1 && n < end) {	// loop until the end of the data
//		byte=getc(fin);			// read a byte from the input file
//		if (n >= start) {		// if past start, then
//			putc(byte,fout);		// write it to the output file
//		}
//		n++;			// advance the byte counter
//	}

	int cue=0;
	while (byte != -1 && n < end && cue < 11) {
		byte=getc(fin);			// read a byte from the input file
		if (n >= start) {		// if past start, then
			putc(byte,fout);		// write it to the output file
		}
		n++;			// advance the byte counter

		if      (cue == 0 && byte == 0x41) {cue = 1;}	// watch for pseudo vendor
		else if (cue == 1 && byte == 0x15) {cue = 2;}	// (indicating end)
		else if (cue == 2 && byte == 0x0)  {cue = 3;}
		else if (cue == 3 && byte == 0x0)  {cue = 4;}
		else if (cue == 4 && byte == 0x0)  {cue = 5;}
		else if (cue == 5 && byte == 0x61) {cue = 6;}
		else if (cue == 6 && byte == 0x65) {cue = 7;}
		else if (cue == 7 && byte == 0x61) {cue = 8;}
		else if (cue == 8 && byte == 0x62) {cue = 9;}
		else if (cue == 9 && byte == 0x69) {cue = 10;}
		else if (cue == 10 && byte == 0x0) {cue = 11;}
		else    {cue = 0;}
	}

	fclose(fin);		// close both the input and output files
	fclose(fout);
}
//
// gcc -o stmld stmld.c
//
// as -o temp.o blink.s
// ./stmld
//
