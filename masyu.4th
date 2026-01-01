/* Constants direction values */
8 CONST>> DIRN
4 CONST>> DIRE
2 CONST>> DIRS
1 CONST>> DIRW

/* CIRCLE types */
0 CONST>> EMPTY
1 CONST>> WHITE
2 CONST>> BLACK

/* GLOBALS */
/* dimentions of the board */
VAR( BOARD-WIDTH BOARD-HEIGHT BOARD-DESC )

/* cursor position on the board */
VAR( BOARD-POS )
/* board is dynamically allocated at runtime so
different size puzzles can be supported */
ARRAY( INT: BOARD 0 )
ARRAY( BYTE: LINEBUF 80 )

5 CONST>> NUM-PUZZLES
ARRAY( INT: PUZZLE-DESC NUM-PUZZLES PUZZLE-DEF NUM-PUZZLES )

"6x6 Easy" >> PUZZLE-DESC [ 0 ]
"6x6:l0d0a1b1f0100c" >> PUZZLE-DEF [ 0 ]

"8x12 Hard" >> PUZZLE-DESC [ 1 ]
"8x12:b0f1d0f1g1a00a0h0f0a1f1n0c0a0c0f1c1" >> PUZZLE-DEF [ 1 ]

"10x10 Medium 1" >> PUZZLE-DESC [ 2 ]
"10x10:e0a0d0g0a0c11b0a0i0a0d1f1c0g0a0a1b000i0d0a0" >> PUZZLE-DEF [ 2 ]

"10x10 Medium 2" >> PUZZLE-DESC [ 3 ]
"10x10:b0b00l10b11a0c0b1b0e0b0c1e0c10a0b0e0a0f0d0a1d1d00" >> PUZZLE-DEF [ 3 ]

"12x12 Medium" >> PUZZLE-DESC [ 4 ]
"12x12:b1c1b00b0f0s1d0a0a0b0a1000c0b0j0a1a0g0f1a1e0a0d0b0a0a00a0n0a0c01b" >> PUZZLE-DEF [ 4 ]


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

: CVTCSTR PARAM( BUF )
/* convert from buffered line input to cstr */
/* buffered has two bytes at the start first
is length of butffer, second is actual len.
we will put \0 after str and return given address
plus 2 */
0 ( BUF 1 + C@ ) ( BUF 2 + ) + C!
BUF 2 +
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

: SET-WHITE PARAM( x y )
WHITE >> BOARD [ y BOARD-WIDTH * x + ]
;

: SET-BLACK PARAM( x y )
BLACK >> BOARD [ y BOARD-WIDTH * x + ]
;

: INIT-BOARD
VAR( I )
0 >> I
WHILE( I BOARD-WIDTH BOARD-HEIGHT * < ){
    EMPTY >> BOARD [ I ]
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
: OPPOSIT-DIR PARAM( DIR )
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
    DIR . SPACE "illegal direction in OPPOSIT-DIR" ERROR
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
  DIR . SPACE "illegal direction in GET-NEIGHBOR" ERROR
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
  DIR . SPACE "illegal direction in CAN-MOVE" ERROR
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
BOARD [ NEIGHBOR ] 256 DIR OPPOSIT-DIR * OR >> BOARD [ NEIGHBOR ]
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
BOARD [ NEIGHBOR ] DIR OPPOSIT-DIR UNSET >> BOARD [ NEIGHBOR ]
;

: IS-DIGIT PARAM( C )
/* assuming C is a char we return TRUE if it's code is between
$30 and $39 inclusive */
C $30 >=
C $39 <=
AND
;

: PARSE-2-DIGITS PARAM( P )
/* P is a pointer to a str. returns int on tos
then length under it.  If 1st char is not a digit
then return 0 for length. */
VAR( C RESULT )
P C@ >> C
C IS-DIGIT IF{
  C '0' - >> RESULT
  P 1 + >> P
  P C@ >> C
  C IS-DIGIT IF{
    RESULT 10 * >> RESULT
    RESULT C '0' - + >> RESULT
    2 RESULT
  }{
    1 RESULT
  }
}{
  0 0
}
;

: SET-BOARD-SIZE PARAM( DESC )
/* expecting a string that looks like 10x10:xxx first number
is width second is height.  At most two digits are allowed for
each value.  Updates globals BOARD-WIDTH and BOARD-HEIGHT and
returns a string OK or error description */
VAR( WIDTH HEIGHT LEN )
DESC PARSE-2-DIGITS >> WIDTH >> LEN
LEN 0= IF{
  "Board description must start with at most two digits"
}{
  DESC LEN + >> DESC
  DESC C@ 'x' <> IF{
    "Width must be at most two digits followed by x"
  }{
    DESC 1 + >> DESC
    DESC PARSE-2-DIGITS >> HEIGHT >> LEN
    LEN 0= IF{
      "Expected a digit for height but got something else"
    }{
      DESC LEN + >> DESC
      DESC C@ ':' <> IF{
        "Height must be at most two digits and followed by a :"
      }{
        WIDTH >> BOARD-WIDTH
        HEIGHT >> BOARD-HEIGHT
        "OK"
      }
    }
  }
}
;

: INTO-BOARD PARAM( BOARD-STR )
/* input like: 10x10:e0a0d0g0a0c11b0a0i0a0d1f1c0g0a0a1b000i0d0a0 
  we are also assumig this is going to be all lowercase atm
 BOARD-STR is a pointer to the string */
VAR( C P ) /* C = char we ar processing P = index into board array */
 0 >> P
 /* skip the 10x10: bit by scanning for : */
 BOARD-STR C@ >> C
 WHILE( C ':' <> ){
   BOARD-STR 1 + >> BOARD-STR
   BOARD-STR C@ >> C
 }
 /* then go one further */
 BOARD-STR 1 + >> BOARD-STR
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
    1 23 MOVE-CURSOR
    BOARD-STR STR. CRLF
    "ERROR parsing" ERROR
  }
  BOARD-STR 1 + >> BOARD-STR
  BOARD-STR C@ >> C
  C 0 <>  /* repeate until null */
 }WHILE
;

: GET-DIRS PARAM( CELL )
CELL 256 /
;

: CELL-TO-PARTS PARAM( CELL )
/* leaves DIR-PART on tos and below that CIRCLE-PART */
CELL $FF AND
CELL GET-DIRS
;

/* an array of number of bits for first 16 numbers
initialized at runtime */
ARRAY( BYTE: BIT-COUNT 0 )

: COUNT-CONNECTIONS PARAM( DIR-PART )
BIT-COUNT [ DIR-PART $F AND ]
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
VAR( IDX CIRCLE-PART DIR-PART WHITE-CNT BLACK-CNT CONN-CNT RESULT )
0 >> IDX
0 >> WHITE-CNT
0 >> BLACK-CNT
TRUE >> RESULT
WHILE( IDX BOARD-WIDTH BOARD-HEIGHT * < ){
  BOARD [ IDX ] CELL-TO-PARTS >> DIR-PART >> CIRCLE-PART
  DIR-PART COUNT-CONNECTIONS >> CONN-CNT
  CIRCLE-PART EMPTY = IF{
    CONN-CNT 0 =
    CONN-CNT 2 =
    OR  /* 0 or 2 is ok */
    IF{
      /* do nothing */
    }{
      FALSE >> RESULT
      BREAK
    }
  }{ /* circle so must have exactly two connections */
  CIRCLE-PART WHITE = IF{
    CONN-CNT 2 = IF{
      WHITE-CNT 1 + >> WHITE-CNT
    }{
      FALSE >> RESULT
      BREAK
    }
  }|
  CIRCLE-PART BLACK = IF{
    CONN-CNT 2 = IF{
      BLACK-CNT 1 + >> BLACK-CNT
    }{
      FALSE >> RESULT
      BREAK
    }
  }|
    "ERROR IN FIRST-CHECK CIRCLE-PART wrong" ERROR
  }
  IDX 1 + >> IDX
} /* end while */
RESULT BLACK-CNT WHITE-CNT
;

: PICK-LOWEST-DIR PARAM( DIR )
/* DIR can hold two directions so
pick the lowest bit value first */
DIR DIRW AND DIRW = IF{
    DIRW
}{
DIR DIRS AND DIRS = IF{
    DIRS
}|
DIR DIRE AND DIRE = IF{
    DIRE
}|
DIR DIRN AND DIRN = IF{
    DIRN
}|
  0
}
;

: FIND-FIRST-NONEMPTY
/* returns the index of the first cell with a line
as well as a direction to traverse next */
VAR( IDX MAX DIR VEC )
0 >> IDX
0 >> VEC
BOARD-WIDTH BOARD-HEIGHT * >> MAX
{
  BOARD [ IDX ] GET-DIRS >> DIR
  DIR 0 <> IF{
    DIR PICK-LOWEST-DIR OPPOSIT-DIR >> VEC
    BREAK
  }
  IDX 1 + >> IDX
  IDX MAX <
}WHILE
IDX MAX = IF{
  "FIND-FIRST-NONEMPTY coudn't find" ERROR
}{
  VEC IDX
}
;

: TRAVERSE PARAM( IDX VEC )
/* VEC is the direction we took to arrive at current
cell IDX.  Opposit of VEC is the way back to the
previous cell so we want to avoid that.  We assume
each cell we traverse has exactly two directions.
we return next VEC on tos and next IDX below that.
*/
VAR( NEW-VEC )
VEC OPPOSIT-DIR CPL $F AND /* complement bits of opposit */
BOARD [ IDX ] GET-DIRS /* extract dirs from current cell */
AND /* this is the direction to the next cell */
>> NEW-VEC
IDX NEW-VEC GET-NEIGHBOR /* leaves next idx on stack */
NEW-VEC
;

: IS-90 PARAM( DIR )
/* return true iff the two directions are 90 degrees
to each other */
VAR( LOWEST )
DIR PICK-LOWEST-DIR >> LOWEST
LOWEST DIRW = IF{
  DIR DIRS AND DIRS =
  DIR DIRN AND DIRN =
  OR
}{
LOWEST DIRS = IF{
  DIR DIRE AND DIRE =
}|
LOWEST DIRE = IF{
  DIR DIRN AND DIRN =
}|
LOWEST DIRN = IF{
  "IS-90 bad argument:" STR. DIR . EXIT
}|
  "IS-90 bad argument:" STR. DIR . EXIT
}
;

: IS-180 PARAM( DIR )
/* return true iff the two directions are 180 degrees
to each other.  We assume there are only two directions
in the given DIR */
VAR( LOWEST )
DIR PICK-LOWEST-DIR >> LOWEST
LOWEST DIRW = IF{
  DIR DIRE AND DIRE =
}{
  /* must be south-north */
  DIR DIRS AND DIRS =
  DIR DIRN AND DIRN =
  AND
}
;

: IS-2-STRAIGHT PARAM( DIR IDX )
/* DIR is the direction we took to get to IDX.
  IDX is the cell adjacent to the black circle.
  we want to make sure this cell is 180 line and
  the next cell has connection opposit of DIR.
  Return TRUE if so.
*/
VAR( NEXT OP BOTHDIR )
DIR OPPOSIT-DIR >> OP
DIR OP OR >> BOTHDIR
BOARD [ IDX ] GET-DIRS BOTHDIR = IF{
  IDX DIR GET-NEIGHBOR >> NEXT
  BOARD [ NEXT ] GET-DIRS OP AND OP =
}{
  FALSE
}
;

: VALID-BLACK PARAM( IDX )
/* returns TRUE iff black circle at IDX has
directions in 90 degrees and each leg is at least
two units without turning.  Assumes IDX has exactly
two connections */
VAR( DIR LOWEST )
BOARD [ IDX ] GET-DIRS >> DIR
DIR IS-90 IF{
  DIR PICK-LOWEST-DIR >> LOWEST
  LOWEST IDX LOWEST GET-NEIGHBOR IS-2-STRAIGHT IF{
    LOWEST CPL $F AND DIR AND /* the other direction */
    IDX OVER GET-NEIGHBOR
    IS-2-STRAIGHT /* return the result */
  }{
    FALSE /* lowest dir leg not 2 */
  }
}{
  FALSE /* not 90 */
}
;

: VALID-WHITE PARAM( IDX )
/* returns TRUE iff white circle has directions
in 180 degrees and a turn in the next square */
VAR( DIR LOWEST )
BOARD [ IDX ] GET-DIRS >> DIR
DIR IS-180 IF{
  DIR PICK-LOWEST-DIR >> LOWEST
  BOARD [ IDX LOWEST GET-NEIGHBOR ] GET-DIRS IS-90 
  BOARD [ IDX LOWEST CPL $F AND DIR AND GET-NEIGHBOR ] GET-DIRS IS-90
  OR
}{
  FALSE /* not 180 */
}
;

: SECOND-CHECK PARAM( NUM-WHITE NUM-BLACK )
/* start from zero and step through the board looking for a cell with
a line.  If/when found mark that as the starting point and then follow
the line.  Because of the first check we know we will return to this
point.  When we return compare the number of valid circles to expected
number of circles.  Return true if they match return false otherwise
*/
VAR( FIRST IVEC IDX BLACK-CNT WHITE-CNT CIRCLE-PART )
0 >> BLACK-CNT 0 >> WHITE-CNT
FIND-FIRST-NONEMPTY >> FIRST >> IVEC
FIRST >> IDX
/* IDX holds current cell index and IVEC holds direction we
took to arrive at current cell. */
{
  BOARD [ IDX ] $FF AND >> CIRCLE-PART
  CIRCLE-PART BLACK = IF{
    IDX VALID-BLACK IF{
      BLACK-CNT 1 + >> BLACK-CNT
    }
  }{
  CIRCLE-PART WHITE = IF{
    IDX VALID-WHITE IF{
      WHITE-CNT 1 + >> WHITE-CNT
    }
  }|
  }
  IDX IVEC TRAVERSE >> IVEC >> IDX
  IDX FIRST <> /* continue while it's not the start point */
}WHILE
NUM-WHITE WHITE-CNT =
NUM-BLACK BLACK-CNT =
AND
;

: END-CHECK
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
CELL CELL-TO-PARTS >> DIR-PART >> CIRCLE-PART
CIRCLE-PART EMPTY = IF{ $a8 }{
CIRCLE-PART WHITE = IF{ $88 }|
CIRCLE-PART BLACK = IF{ $98 }|
  "unexpected circle-part in DISP-CELL" ERROR
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
 17 2 "MASYU" STRXY
 17 10 "ARROW - MOVE" STRXY
 17 11 "SHIFT - DRAW" STRXY
 17 12 "CTRL - ERASE" STRXY
 17 14 "C - CHECK" STRXY
 17 15 "R - RESET" STRXY
 17 16 "Q - QUIT" STRXY
 17 18 "S - SELECT" STRXY
 17 19 "D - CUSTOM" STRXY
 17 21 "F1 - HELP" STRXY
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
VAR( NEXTKEY )
END-CHECK
IF{
  5 23 "Solved! -- hit any key to continue" STRXY
}{
  5 23 "Not solved yet. -- hit any key to continue" STRXY
}
{ /* loop to handle quit dialog */
  GET-INPUT >> NEXTKEY
  NEXTKEY 0= IF{
    0
  }{
    NEXTKEY 121 = IF{ /* y */
    1
  }|
    1
  }
  0=
}WHILE
1
;

: DO-HELP
1
;

: DO-SELECTION
/* allow user to type a puzzle definition. */
VAR( I NEXTKEY )
CLS
1 10 MOVE-CURSOR
0 >> I
WHILE( I NUM-PUZZLES < ){
  I 1 + . ") " STR.
  PUZZLE-DESC [ I ] STR. CRLF
  I 1 + >> I
}
CRLF "Enter 1-5" STR.
{ /* loop to handle quit dialog */
  GET-INPUT >> NEXTKEY
  NEXTKEY 0= IF{
    0
  }{
    NEXTKEY 49 >= 
    NEXTKEY 53 <=
    AND IF{
      NEXTKEY 49 - >> I
      PUZZLE-DEF [ I ] SET-BOARD-SIZE STR.
      _FREE BOARD-WIDTH BOARD-HEIGHT * 2 * ARRAY>> BOARD
      INIT-BOARD
      PUZZLE-DEF [ I ] INTO-BOARD
      1
  }|
    0
  }
  0=
}WHILE
1
;

: DO-DEFINITION
/* allow user to type a puzzle definition. */
VAR( BOARD-DEF )
5 22 "enter puzzle" STRXY CRLF
80 & LINEBUF C!
& LINEBUF >> _DE
$0a BDOS
& LINEBUF CVTCSTR >> BOARD-DEF
BOARD-DEF SET-BOARD-SIZE DROP
_FREE BOARD-WIDTH BOARD-HEIGHT * 2 * ARRAY>> BOARD
INIT-BOARD
BOARD-DEF INTO-BOARD
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
I 100 = IF{ /* d for definition */
  DO-DEFINITION
}|
I 115 = IF{ /* s for selection */
  DO-SELECTION
}|  0 /* didn't process and don't need refresh */
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
 DATA( BYTE: 0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4 ) ARRAY>> BIT-COUNT
 /* INIFNK */
 'h' $F87F C! /* set F1 to h */
 $FF $F880 C!
 SETUPCHARS
 "10x10:c0c0i1e00a0c0a0a0d1b0d0d00b0l10a000c0c0c1k0a" >> BOARD-DESC
 BOARD-DESC SET-BOARD-SIZE DROP
 _FREE BOARD-WIDTH BOARD-HEIGHT * 2 * ARRAY>> BOARD
 INIT-BOARD
 BOARD-DESC INTO-BOARD
 /* try next 8x12:a0d0b1a0j00a1a0p00a01c00h0a0a1d0a0a0l1b0b0a */
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