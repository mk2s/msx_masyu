/* dimentions of the board */
10 CONST>> BOARD-WIDTH
10 CONST>> BOARD-HEIGHT

/* direction values */
8 CONST>> DIRN
4 CONST>> DIRE
2 CONST>> DIRS
1 CONST>> DIRW

/* cursor position on the board */
VAR( BOARD-POS )

: cls 
/* MSX BIOS CALL to initialize screen */
$c3 BIOS
;

: POSIT
/* MSX BIOS call POSIT for positioning cursor takes _HL */
$c6 BIOS
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

: MOVE-CURSOR PARAM( x y )
/* x y are screen coordinates */
256 x * y + >> _HL POSIT
;

: STRXY PARAM( x y s )
/* move cursor to screen coordinates and print string */
x y MOVE-CURSOR
s STR.
;

: WAIT PARAM( COUNT )
VAR( I )
0 >> I
WHILE( I COUNT < ){ I 1 + >> I }
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
ARRAY( INT: BOARD 100 )

: SET-WHITE PARAM( x y )
1 >> BOARD [ y BOARD-WIDTH * x + ]
;

: SET-BLACK PARAM( x y )
2 >> BOARD [ y BOARD-WIDTH * x + ]
;

: TO-XY PARAM( IDX )
/* given index into board we return
  x and y as needed by set-black/white */
VAR( X Y )
IDX BOARD-WIDTH / >> Y
IDX Y BOARD-WIDTH * - /* this leaves X on tos */
Y
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
/* if you need to know if that's safe, call CAN-CONNECT */
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

: INTO-BOARD PARAM( BOARD-STR )
/* input like: 10x10:e0a0d0g0a0c11b0a0i0a0d1f1c0g0a0a1b000i0d0a0 
  we are also assumig this is going to be all lowercase atm
 BOARD-STR is a pointer to the string */
VAR( C P ) /* C = char we ar processing P = index into board array */
 0 >> P
 BOARD-STR 6 + >> BOARD-STR /* skip the 10x10: bit */
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
WHILE( I 10 < ){
    2 5 I + MOVE-CURSOR
    I DISP-ROW
    I 1 + >> I
}
;

: TOPOFBOX
1 4 "\$80\$81\$81\$81\$81\$81\$81\$81\$81\$81\$81\$82" STRXY
;

: BOTTOMOFBOX
1 15 "\$84\$85\$85\$85\$85\$85\$85\$85\$85\$85\$85\$86" STRXY
;

: SIDESOFBOX
VAR( I )
1 >> I
WHILE( I 10 <= ){
    1 4 I + "\$83\$20\$20\$20\$20\$20\$20\$20\$20\$20\$20\$87" STRXY
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

: MOVE-BOARD PARAM( IDX )
/* given a board position move cursor to that position and update BOARD-POS */
VAR( X Y )
IDX >> BOARD-POS
IDX TO-XY >> Y >> X
X 2 + Y 5 + MOVE-CURSOR
;

: PROCESS-INPUT PARAM( I )
VAR( DIR )
I 0 <> IF{
  I STICK-TO-DIR >> DIR
  DIR 0 <> IF{
    BOARD-POS DIR CAN-MOVE IF{ BOARD-POS DIR GET-NEIGHBOR MOVE-BOARD }
    { /* continue reading until zero to clear key down */
        0 GTSTCK
        0 <>
    }WHILE
  }
}
;

: MAIN
 1 >> _A  $5F BIOS /* switch to screen 1 */
 cls
 1 VSYNC
 SETUPCHARS PAINT-SCRN
 INIT-BOARD
 "10x10:b0b00l10b11a0c0b1b0e0b0c1e0c10a0b0e0a0f0d0a1d1d00" INTO-BOARD
 DISP-BOARD
 0 MOVE-BOARD
 { 
0 GTSTCK PROCESS-INPUT
 }
;

END MAIN


