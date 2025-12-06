/* dimentions of the board */
10 CONST>> BOARD-WIDTH
10 CONST>> BOARD-HEIGHT

/* direction values */
8 CONST>> DIRN
4 CONST>> DIRE
2 CONST>> DIRS
1 CONST>> DIRW

: cls 
$c3 BIOS
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

: TO-XY PARAM( I )
/* given index into board we return
  x and y as needed by set-black/white */
VAR( X Y )
I BOARD-WIDTH / >> Y
I Y BOARD-WIDTH * - /* this leaves X on tos */
Y
;

: INIT-BOARD
VAR( I )
0 >> I
WHILE( I BOARD-WIDTH BOARD-HEIGHT * < ){
    0 >> BOARD [ I ]
    I 1 + >> I
}
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
"\$80\$81\$81\$81\$81\$81\$81\$81\$81\$81\$81\$82" STR. CRLF
VAR( I )
0 >> I
WHILE( I 10 < ){
    $83 CHPUT /* left border */
    I DISP-ROW
    $87 CHPUT CRLF
    I 1 + >> I
}
"\$84\$85\$85\$85\$85\$85\$85\$85\$85\$85\$85\$86" STR. CRLF
;

: MAIN
 1 >> _A  $5F BIOS /* switch to screen 1 */
 cls
 1 VSYNC
 SETUPCHARS
 INIT-BOARD
 "10x10:b0b00l10b11a0c0b1b0e0b0c1e0c10a0b0e0a0f0d0a1d1d00" INTO-BOARD
 /* hand built test data */
 1 DIRE CONNECT
 2 DIRE CONNECT
 3 DIRS CONNECT
 13 DIRS CONNECT
 23 DIRW CONNECT
 22 DIRW CONNECT
 21 DIRS CONNECT
 31 DIRE CONNECT
 32 DIRS CONNECT
 42 DIRS CONNECT
 52 DIRE CONNECT
 53 DIRN CONNECT
 43 DIRN CONNECT
 33 DIRE CONNECT
 34 DIRE CONNECT
 35 DIRE CONNECT
 36 DIRE CONNECT
 37 DIRN CONNECT
 27 DIRW CONNECT
 26 DIRW CONNECT
 25 DIRW CONNECT
 24 DIRN CONNECT
 14 DIRN CONNECT
 4  DIRE CONNECT
 5 DIRE CONNECT
 6 DIRE CONNECT
 7 DIRS CONNECT
 17 DIRE CONNECT
 18 DIRE CONNECT
 19 DIRS CONNECT
 29 DIRS CONNECT
 39 DIRS CONNECT
 49 DIRW CONNECT
 48 DIRW CONNECT
 47 DIRW CONNECT
 46 DIRW CONNECT
 45 DIRW CONNECT
 44 DIRS CONNECT
 54 DIRE CONNECT
 55 DIRE CONNECT
 56 DIRE CONNECT
 57 DIRE CONNECT
 58 DIRE CONNECT
 59 DIRS CONNECT
 69 DIRS CONNECT
 79 DIRW CONNECT
 78 DIRN CONNECT
 68 DIRW CONNECT
 67 DIRS CONNECT
 77 DIRS CONNECT
 87 DIRE CONNECT
 88 DIRE CONNECT
 89 DIRS CONNECT
 99 DIRW CONNECT
 98 DIRW CONNECT
 97 DIRW CONNECT
 96 DIRN CONNECT
 86 DIRW CONNECT
 85 DIRW CONNECT
 84 DIRS CONNECT
 94 DIRW CONNECT
 93 DIRW CONNECT
 92 DIRN CONNECT
 82 DIRN CONNECT
 72 DIRE CONNECT
 73 DIRE CONNECT
 74 DIRE CONNECT
 75 DIRE CONNECT
 76 DIRN CONNECT
 66 DIRW CONNECT
 65 DIRW CONNECT
 64 DIRW CONNECT
 63 DIRW CONNECT
 62 DIRW CONNECT
 61 DIRS CONNECT
 71 DIRS CONNECT
 81 DIRS CONNECT
 91 DIRW CONNECT
 90 DIRN CONNECT
 80 DIRN CONNECT
 70 DIRN CONNECT
 60 DIRN CONNECT
 50 DIRE CONNECT
 51 DIRN CONNECT
 41 DIRW CONNECT
 40 DIRN CONNECT
 30 DIRN CONNECT
 20 DIRN CONNECT
 10 DIRE CONNECT
 11 DIRN CONNECT
 DISP-BOARD
 /* BOARD [ 3 ] . CRLF */
 ;
END MAIN


