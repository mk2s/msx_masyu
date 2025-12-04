: cls 
$c3 BIOS
;

: SETUPCHARS
/* copy bitmap to pattern map */
DATA( BYTE:  
$00 $00 $00 $00 $0f $08 $08 $08 
$00 $00 $00 $00 $ff $00 $00 $00
$00 $00 $00 $00 $f0 $10 $10 $10
$08 $08 $08 $08 $08 $08 $08 $08
$08 $08 $08 $0f $00 $00 $00 $00
$00 $00 $00 $ff $00 $00 $00 $00
$10 $10 $10 $f0 $00 $00 $00 $00
$10 $10 $10 $10 $10 $10 $10 $10
$00 $3C $42 $42 $42 $42 $3C $00  /* white circle $88 */
$00 $3C $7E $7E $7E $7E $3C $00  /* black circle $89 */
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
1 >> BOARD [ y 10 * x + ]
;

: SET-BLACK PARAM( x y )
2 >> BOARD [ y 10 * x + ]
;

: TO-XY PARAM( I )
/* given index into board we return
  x and y as needed by set-black/white */
VAR( X Y )
I 10 / >> Y
I Y 10 * - /* this leaves X on tos */
Y
;

: INIT-BOARD
VAR( I )
0 >> I
WHILE( I 100 < ){
    0 >> BOARD [ I ]
    I 1 + >> I
}
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
VAR( C D )
CELL $FF AND >> C
C 0 = IF{ $20 >> D }{
C 1 = IF{ $88 >> D }|
C 2 = IF{ $89 >> D }|
  "ERROR" STR. EXIT
}
D CHPUT
;

: DISP-ROW PARAM( ROW )
VAR( I )
0 >> I
WHILE( I 10 < ){
    BOARD [ ROW 10 * I + ] DISP-CELL
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
 "10x10:e0a0d0g0a0c11b0a0i0a0d1f1c0g0a0a1b000i0d0a0" INTO-BOARD
 DISP-BOARD
 ;

END MAIN


