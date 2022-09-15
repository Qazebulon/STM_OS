// file: /stm32/burn/term.c	11/11/2020	Don Stoner
//
#include <ncurses.h>	// To get this code: sudo apt-get install libncurses5-dev
#include <wiringSerial.h>	// This is included in wiringPi.h

//-------------------------------------------------------------------------------------
//
// Main Routine:
//
void main() {
	//	Setup for ncurses (captures  single keystrokes)
	//
	initscr();	// initiate the curses code
	//raw();	// get just one character at a time (option)
	cbreak();	// 	or:	same as "raw" but allow ^c and etc. to work
	noecho();	//		supress automatic character echoing (option)
	keypad(stdscr, TRUE); //	also capture special keys: (option)
	// KEY_DOWN  KEY_UP  KEY_LEFT  KEY_RIGHT  KEY_F(n)  KEY_ENTER
	// KEY_HOME  KEY_BACKSPACE  KEY_DC (delete)  KEY_IC (insert)
	nodelay(stdscr, TRUE);// returns ERR (-1) if no key is ready (option)

	//	Main Code Loop	(with Sign-on Banner)
	//
	printw("Terminal Program:  /dev/serial0 115200 baud  (^C to exit)\n");
	int fd=serialOpen ("/dev/serial0", 115200);	// open serial port

	//	Loop reading one key per loop
	//	exit following control-C
	//
	int ch = -1; 	//	First loop != 3 (exit)
	for (; ch != 3 ; ch == KEY_ENTER) {
		ch = getch();		// get a key (or immediate -1)
		if(ch != -1) {
			//	OUTPUT
			serialPutchar (fd, ch);		// serial output keycode
			if (ch==13) { addch(65); }	// add a LF to a CR
		} else {
			//	INPUT
			if (serialDataAvail(fd) > 0) {	// # of characters available > 0?
				// read (and echo) serial inputs (only when present)
				ch=serialGetchar(fd);	// (else times out after 10 seconds)
				echochar(ch);
			}
		}
	}

	//	Shutdown
	//
	serialClose (fd);	// close serial connection
	endwin();	// restore normal terminal settings
}

//-------------------------------------------------------------------------------------
// To make this code work:
//		nano term.c					  (copy and paste this code into term.c)
//		gcc -o term term.c -l ncurses -l wiringPi		(compile it)
//		./term							  (then use the terminal)
