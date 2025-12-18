/* dimentions of the board */
8 CONST>> BOARD-WIDTH
12 CONST>> BOARD-HEIGHT

/* direction values */
8 CONST>> DIRN
4 CONST>> DIRE
2 CONST>> DIRS
1 CONST>> DIRW

/* GLOBALS */
/* cursor position on the board */
VAR( BOARD-POS )

/* END GLOBALS */


/* utility words */
: CLS
/* MSX BIOS CALL to initialize screen */
$c3 BIOS
;

: POSIT
/* MSX BIOS call POSIT for positioning cursor takes _HL */
$c6 BIOS
;

: CHSNS
/* MSX BIOS call to check for key status. Z flag set if buffer empty
we return true if there's a key that needs to be read
note that shift and ctl do not seem to register as needing to
be read by CHSNS but arrow keys do */
$9c BIOS
_F $40 AND $40 <>
;

: DRAIN-KEYBUFFER
WHILE( CHSNS ){
  /* throw away the rest of the chars this
    is necessary for the case where a function key
    stuffs more than one char in the buffer */
  CHGET DROP
}
;

: INIFNK
/* initialize function keys */
$3e BIOS
;

: GTSTCK PARAM( N )
/* get stick value 
up down left right => 1 5 7 3
N selects between arrow keys, stick1 and stick2
*/
N >> _A
$d5 BIOS
_A
;

: WAIT PARAM( COUNT )
VAR( I )
0 >> I
WHILE( I COUNT < ){ I 1 + >> I }
;

: GET-MODIFIERS
/* returns 0 for neither 1=SHIFT only, 2=CTL only
3= both pressed */
6 >> _A
$141 BIOS
/* shift is bit0 ctl is bit1; bits are inverted */
_A CPL 3 AND
;

/* Board related words */

: TO-XY PARAM( IDX )
/* given index into board we return
  x and y as needed by set-black/white */
VAR( Y )
IDX BOARD-WIDTH / >> Y
IDX Y BOARD-WIDTH * - /* this leaves X on tos */
Y
;

: MOVE-CURSOR PARAM( x y )
/* x y are screen coordinates */
256 x * y + >> _HL POSIT
;

: MOVE-SCREEN PARAM( IDX )
/* given a board index position move
screen cursor to the right place */
VAR( X Y )
IDX TO-XY >> Y >> X
X 2 + Y 5 + MOVE-CURSOR
;

: STRXY PARAM( x y s )
/* move cursor to screen coordinates and print string */
x y MOVE-CURSOR
s STR.
;

: SETUPCHARS
/* copy bitmap to pattern map */
DATA( BYTE:  
$00 $00 $00 $00 $0f $08 $08 $08  /* top left corner  */
$00 $00 $00 $00 $ff $00 $00 $00  /* top edge         */
$00 $00 $00 $00 $f0 $10 $10 $10  /* top right corner */
$08 $08 $08 $08 $08 $08 $08 $08  /* left edge        */
$08 $08 $08 $0f $00 $00 $00 $00  /* bottom left      */
$00 $00 $00 $ff $00 $00 $00 $00  /* bottom edge      */
$10 $10 $10 $f0 $00 $00 $00 $00  /* bottom right     */
$10 $10 $10 $10 $10 $10 $10 $10  /* right edge       */
$00 $3C $42 $42 $42 $42 $3C $00  /* white circle $88 */
$00 $3C $42 $C2 $42 $42 $3C $00  /* white W          */
$00 $3C $42 $42 $42 $42 $3C $10  /* white S          */
$00 $3C $42 $C2 $42 $42 $3C $10  /* white SW         */
$00 $3C $42 $42 $43 $42 $3C $00  /* white E          */
$00 $3C $42 $C3 $42 $42 $3C $00  /* white EW         */
$00 $3C $42 $43 $42 $42 $3C $10  /* white ES         */
$00 $3C $42 $C3 $42 $42 $3C $10  /* white EWS        */
$10 $3C $42 $42 $42 $42 $3C $00  /* white N          */
$10 $3C $42 $C2 $42 $42 $3C $00  /* white NW         */
$10 $3C $42 $42 $42 $42 $3C $10  /* white NS         */
$10 $3C $42 $C2 $42 $42 $3C $10  /* white NWS        */
$10 $3C $42 $43 $42 $42 $3C $00  /* white NE         */
$10 $3C $42 $C3 $42 $42 $3C $00  /* white NEW        */
$10 $3C $42 $43 $42 $42 $3C $10  /* white NES        */
$10 $3C $42 $C3 $42 $42 $3C $10  /* white NESW       */
$00 $3C $7E $7E $7E $7E $3C $00  /* black circle $98 */
$00 $3C $7E $FE $7E $7E $3C $00  /* black W          */
$00 $3C $7E $7E $7E $7E $3C $10  /* black S          */
$00 $3C $7E $FE $7E $7E $3C $10  /* black WS         */
$00 $3C $7E $7F $7E $7E $3C $00  /* black E          */
$00 $3C $7E $FF $7E $7E $3C $00  /* black EW         */
$00 $3C $7E $7F $7E $7E $3C $10  /* black ES         */
$00 $3C $7E $FF $7E $7E $3C $10  /* black EWS        */
$10 $3C $7E $7E $7E $7E $3C $00  /* black N          */
$10 $3C $7E $FE $7E $7E $3C $00  /* black NW         */
$10 $3C $7E $7E $7E $7E $3C $10  /* black NS         */
$10 $3C $7E $FE $7E $7E $3C $10  /* black NWS        */
$10 $3C $7E $7F $7E $7E $3C $00  /* black NE         */
$10 $3C $7E $FF $7E $7E $3C $00  /* black NEW        */
$10 $3C $7E $7F $7E $7E $3C $10  /* black NES        */
$10 $3C $7E $FF $7E $7E $3C $10  /* black NESW       */
$00 $00 $00 $00 $00 $00 $00 $00  /* blank            */
$00 $00 $00 $F0 $00 $00 $00 $00  /* empty W          */
$00 $00 $00 $00 $10 $10 $10 $10  /* empty S          */
$00 $00 $00 $F0 $10 $10 $10 $10  /* empty WS         */
$00 $00 $00 $0F $00 $00 $00 $00  /* empty E          */
$00 $00 $00 $FF $00 $00 $00 $00  /* empty EW         */
$00 $00 $00 $1F $10 $10 $10 $10  /* empty ES         */
$00 $00 $00 $FF $10 $10 $10 $10  /* empty EWS        */
$10 $10 $10 $10 $00 $00 $00 $00  /* empty N          */
$10 $10 $10 $F0 $00 $00 $00 $00  /* empty NW         */
$10 $10 $10 $10 $10 $10 $10 $10  /* empty NS         */
$10 $10 $10 $F0 $10 $10 $10 $10  /* empty NSW        */
$10 $10 $10 $1F $00 $00 $00 $00  /* empty NE         */
$10 $10 $10 $FF $00 $00 $00 $00  /* empty NEW        */
$10 $10 $10 $1F $10 $10 $10 $10  /* empty NSE        */
$10 $10 $10 $FF $10 $10 $10 $10  /* empty NSEW       */
) $0400 LDIRVM
;

/* board state */
/* each square will be represented with a 16bit integer word
  The hi will hold wether there is an edge to adjacent square
  if there's a link upwards/N then 8, if to the right/E then 4
  if downwards/S then 2 and left/W then 1.
  the lo bite will hold 0=no circle, 1=white circle, 2=black
*/

/* board is 10x10 row at a time */
ARRAY( INT: BOARD 96 )

: SET-WHITE PARAM( x y )
1 >> BOARD [ y BOARD-WIDTH * x + ]
;

: SET-BLACK PARAM( x y )
2 >> BOARD [ y BOARD-WIDTH * x + ]
;

: INIT-BOARD
VAR( I )
0 >> I
WHILE( I BOARD-WIDTH BOARD-HEIGHT * < ){
    0 >> BOARD [ I ]
    I 1 + >> I
}
0 >> BOARD-POS
;

: RESET-BOARD
/* keep circles, but earase the lines */
VAR( I MAXI )
0 >> I
BOARD-WIDTH BOARD-HEIGHT * >> MAXI
WHILE( I MAXI < ){
  BOARD [ I ] $FF AND >> BOARD [ I ]
  I 1 + >> I
}
0 >> BOARD-POS
;

/* N->S S->N E->W W->E */
: OPPOSITDIR PARAM( DIR )
DIR DIRN = IF{
    DIRS
}{
DIR DIRS = IF{
    DIRN
}|
DIR DIRE = IF{
    DIRW
}|
DIR DIRW = IF{
    DIRE
}|
    DIR . SPACE "illegal direction in OPPOSITDIR" STR. EXIT
}
;

: GET-NEIGHBOR PARAM( IDX DIR )
/* given a board index and a direction return the index of the board
after moving in the direction */
DIR DIRN = IF{
    IDX BOARD-WIDTH -
}{
DIR DIRS = IF{
    IDX BOARD-WIDTH +
}|
DIR DIRE = IF{
    IDX 1 +
}|
DIR DIRW = IF{
    IDX 1 -
}|
  DIR . SPACE "illegal direction in GET-NEIGHBOR" STR. EXIT
}
;

: CAN-MOVE PARAM( IDX DIR )
/* given an index into the board and a direction, return a bool indicating
whether we can move from IDX to that cell. */
VAR( X Y )
IDX TO-XY >> Y >> X
DIR DIRN = IF{
    0 Y <  /* can move N if Y is greater than 0 */
}{
DIR DIRS = IF{
    BOARD-HEIGHT 1 - Y > /* can move S if Y is less than board height minus 1 */ 
}|
DIR DIRE = IF{
    BOARD-WIDTH 1 - X > /* can move E if X is less that board width minus 1 */
}|
DIR DIRW = IF{
    0 X < /* can move W if X is greater than 1 */
}|
  DIR . SPACE "illegal direction in CAN-MOVE" STR. EXIT
}
;

/* assuming it is ok, connect cell IDX with its neighbor DIR */
/* if you need to know if that's safe, call CAN-MOVE */
/* when connecting a cell we will set the cell's bit conrresponding to */
/* the edge it's connecting as well as the neighbor's matching edge */
/* so if this cell's N is connecting then the cell above this will have */
/* it's S connecting to this cell */
/* for display these two parts are separate, but operationally half a */
/* connection is not possible to create */
: CONNECT PARAM( IDX DIR )
VAR( NEIGHBOR )
BOARD [ IDX ] 256 DIR * OR >> BOARD [ IDX ]
IDX DIR GET-NEIGHBOR >> NEIGHBOR
BOARD [ NEIGHBOR ] 256 DIR OPPOSITDIR * OR >> BOARD [ NEIGHBOR ]
;

: UNSET PARAM( BITS DIR )
/* given contents of board a 16bit int and a direction
remove the direction bit from the upper 8bits 
CPL flips all 16 bits */
BITS DIR CPL 256 * 255 + AND
;

: DISCONNECT PARAM( IDX DIR )
VAR( NEIGHBOR )
BOARD [ IDX ] DIR UNSET >> BOARD [ IDX ]
IDX DIR GET-NEIGHBOR >> NEIGHBOR
BOARD [ NEIGHBOR ] DIR OPPOSITDIR UNSET >> BOARD [ NEIGHBOR ]
;

: INTO-BOARD PARAM( BOARD-STR )
/* input like: 10x10:e0a0d0g0a0c11b0a0i0a0d1f1c0g0a0a1b000i0d0a0 
  we are also assumig this is going to be all lowercase atm
 BOARD-STR is a pointer to the string */
VAR( C P ) /* C = char we ar processing P = index into board array */
 0 >> P
 BOARD-STR 5 + >> BOARD-STR /* skip the 10x10: bit */
 BOARD-STR C@ >> C
 {
  '0' C = IF{
  P TO-XY SET-WHITE
  P 1 + >> P
  }{
  '1' C = IF{
  P TO-XY SET-BLACK
  P 1 + >> P
  }|
  'a' C <=
  'z' C >=
  AND IF{
  /* 96 is the char before lower a */
  C 96 - P + >> P /* move forward P by letter amount */
  }|
    "ERROR parsing" STR. EXIT
  }
  BOARD-STR 1 + >> BOARD-STR
  BOARD-STR C@ >> C
  C 0 <>  /* repeate until null */
 }WHILE
;

: FIRST-CHECK 
/* this word will leave number of white circles found on tos
number of black circles below that, and below that a boolean
indicating whether the word was successful.  False means
something went wrong and the number of circles returned
is invalid.

Should I put the check for white needs straight through and
turns on next square, black needs to turn inside and have
two unit straight legs?
*/
TRUE 10 10
;

: SECOND-CHECK PARAM( NUM-WHITE NUM-BLACK )
/* start from zero and step through the board looking for a cell with
a line.  If/when found mark that as the starting point and then follow
the line.  Because of the first check we know we will return to this
point.  When we return compare the number of circles to expected
number of circles.  Return true if they match return false otherwise
*/
TRUE
;

: END-check
/* First check to see for each cell that if it's empty then 0 or two connections
and if cell has circle then must have two connections.  Then check that we can
traverse all circles by following the line. */
VAR( NUM-WHITE NUM-BLACK )
  FIRST-CHECK >> NUM-WHITE >> NUM-BLACK
  IF{
    NUM-WHITE NUM-BLACK SECOND-CHECK
  }{
    FALSE
  }
;

: DISP-CELL PARAM( CELL )
/* the direction part 0~15 becomes offset into font table */
VAR( CIRCLE-PART DIR-PART )
CELL $FF AND >> CIRCLE-PART
CELL 256 / >> DIR-PART
CIRCLE-PART 0 = IF{ $a8 }{
CIRCLE-PART 1 = IF{ $88 }|
CIRCLE-PART 2 = IF{ $98 }|
  "unexpected circle-part in DISP-CELL" STR. EXIT
}
DIR-PART + CHPUT
;

: DISP-ROW PARAM( ROW )
VAR( I )
0 >> I
WHILE( I BOARD-WIDTH < ){
    BOARD [ ROW BOARD-WIDTH * I + ] DISP-CELL
    I 1 + >> I
}
;

: DISP-BOARD
/* display the inside of the board ie no boarders */
VAR( I )
0 >> I
WHILE( I BOARD-HEIGHT < ){
    2 5 I + MOVE-CURSOR
    I DISP-ROW
    I 1 + >> I
}
BOARD-POS MOVE-SCREEN
;

: TOP-OR-BOTTOM PARAM( Y L M R )
VAR( I )
1 Y MOVE-CURSOR
L CHPUT
0 >> I
WHILE( I BOARD-WIDTH < ){
  M CHPUT
  I 1 + >> I
}
R CHPUT
;


: TOPOFBOX
/* $80-82 are char code for left middle right of the top edge */
4 $80 $81 $82 TOP-OR-BOTTOM
;

: BOTTOMOFBOX
5 BOARD-HEIGHT + $84 $85 $86 TOP-OR-BOTTOM
;

: SIDESOFBOX
VAR( I )
1 >> I
WHILE( I BOARD-HEIGHT <= ){
    4 I + $83 $20 $87 TOP-OR-BOTTOM
    I 1 + >> I
}
;

: PAINT-SCRN
 15 2 "MASYU" STRXY
 17 15 "USE ARRORW TO" STRXY
 17 16 "MOVE.  HOLD" STRXY
 17 17 "SHIFT TO DRAW" STRXY
 17 18 "HOLD CTL TO" STRXY
 17 19 "ERASE." STRXY
 17 21 "F1 FOR HELP" STRXY
 TOPOFBOX SIDESOFBOX BOTTOMOFBOX
;

: STICK-TO-DIR PARAM( I )
/* zero means error */
I 1 = IF{ /* up */
    DIRN
}{
I 5 = IF{ /* down */
    DIRS
}|
I 7 = IF{ /* left */
    DIRW
}|
I 3 = IF{
    DIRE
}|
  0
}
;

: PAINT-CELL PARAM( IDX )
/* given a IDX update screen for that cell
based on the board */
IDX MOVE-SCREEN
BOARD [ IDX ] DISP-CELL
;

: MOVE-BOARD PARAM( IDX )
/* given a board position move cursor to that position and update BOARD-POS */
VAR( X Y )
IDX >> BOARD-POS
IDX MOVE-SCREEN
;

: MOVE-CONNECT-CLEAR PARAM( IDX DIR )
VAR( MOD )
GET-MODIFIERS >> MOD
MOD 1 = IF{
  IDX DIR CONNECT
}{
MOD 2 = IF{
  IDX DIR DISCONNECT
} /* if both are pressed we ignore both */
}
IDX DIR GET-NEIGHBOR MOVE-BOARD
;

: GET-INPUT
/* to make things compatible with 0 GTSTCK 
I'm remapping right arrow -> 3 left arrow -> 7 etc. */
VAR( CHAR )
CHSNS IF{
  CHGET >> CHAR
  CHAR 28 = IF{ /* right arrow */
    3
  }{
  CHAR 29 = IF{ /* left arrow */
    7
  }|
  CHAR 30 = IF{ /* up arrow */
    1
  }|
  CHAR 31 = IF{ /* down arrow */
    5
  }|
  DRAIN-KEYBUFFER
  CHAR
  }
}{
  0
}
;

: DO-RESET-BOARD
/* DO-* words are like dialogs we
wait for certain keys to proceed
In this case we prompt to reset board
if y then reset board and n will
return to main screen without resetting
*/
VAR( NEXTKEY )
5 23 "Reset board? (y/n)" STRXY
{ /* loop to handle dialog */
  GET-INPUT >> NEXTKEY
  NEXTKEY 0= IF{
    0
  }{
  NEXTKEY 121 = IF{ /* y */
    RESET-BOARD
    1
  }|
    1
  }
  0=
}WHILE
1 /* we processed and need a screen refresh */
;

: DO-CHECK-QUIT
/* prompt for quit and do so if y */
VAR( NEXTKEY )
5 23 "QUIT ?(y/n)" STRXY
{ /* loop to handle quit dialog */
  GET-INPUT >> NEXTKEY
  NEXTKEY 0= IF{
    0
  }{
    NEXTKEY 121 = IF{ /* y */
    EXIT
  }|
    1
  }
  0=
}WHILE
1 /* we processed and need a screen refresh */
;

: DO-CHECK-BOARD
1
;

: DO-HELP
1
;

: MAIN-PROCESS-KEY PARAM( I )
/* I is key code
returns 0 if didn't process
1 if processed and need refresh
2 if processed and don't need refresh
*/
I 113 = IF{ /* q */
  DO-CHECK-QUIT
}{
I 99 = IF{ /* c */
  DO-CHECK-BOARD
}|
I 114 = IF{ /* r */
  DO-RESET-BOARD
}|
I 104 = IF{ /* h for help */
  DO-HELP
}|
  0 /* didn't process and don't need refresh */
}
;

: PROCESS-INPUT PARAM( I )
/* I is the key code.  Zero if no key pressed
  This word returns a bool indicating whether
  the screen needs to be redrawn.
*/
VAR( DIR OLD-POS RESULT )
I 0 <> IF{
  I MAIN-PROCESS-KEY >> RESULT
  RESULT 0 <> IF{
    RESULT 1 = IF{
      TRUE
    }{
      FALSE
    }
  }{
    I STICK-TO-DIR >> DIR
    DIR 0 <> IF{
      BOARD-POS DIR CAN-MOVE IF{ 
        BOARD-POS >> OLD-POS
        BOARD-POS DIR MOVE-CONNECT-CLEAR /* this will update BOARD-POS */
        OLD-POS PAINT-CELL
        BOARD-POS PAINT-CELL
        BOARD-POS MOVE-SCREEN /* after we paint a cell we're one to the right so nudge back */
      }
    }
    FALSE /* no need to redraw */
  }
}{
  FALSE
}
;

: MAIN
 1 >> _A  $5F BIOS /* switch to screen 1 */
 INIFNK
 'h' $F87F C! /* set F1 to h */
 $FF $F880 C!
 SETUPCHARS
 INIT-BOARD
 "8x12:b0f1d0f1g1a00a0h0f0a1f1n0c0a0c0f1c1" INTO-BOARD
 0 MOVE-BOARD
 TRUE /* start by redrawing screen */
 { /* main loop */
   IF{
     CLS
     PAINT-SCRN
     DISP-BOARD
   }
   GET-INPUT /* leaves key code on tos */
   PROCESS-INPUT /* puts redraw on tos */
 }
;

END MAIN


