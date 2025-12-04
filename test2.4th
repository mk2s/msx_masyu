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

: INIT-BOARD
VAR( I )
0 >> I
WHILE( I 100 < ){
    0 >> BOARD [ I ]
    I 1 + >> I
}
/* manually enter 10x10:e0a0d0g0a0c11b0a0i0a0d1f1c0g0a0a1b000i0d0a0 */
/* white circle at 5,0 */
5 0 SET-WHITE
/* white circle at 7,0 */
7 0 SET-WHITE
/* white circle at 2,1 */
2 1 SET-WHITE
/* white at 2,2 */
2 2 SET-WHITE
/* black at 6&7, 2 */
6 2 SET-BLACK
7 2 SET-BLACK
/* white at 0&2, 3 */
0 3 SET-WHITE
2 3 SET-WHITE
/* white at 2&4, 4 */
2 4 SET-WHITE
4 4 SET-WHITE
/* black at 9, 4 */
9 4 SET-BLACK
/* black at 6, 5 */
6 5 SET-BLACK
0 6 SET-WHITE
8 6 SET-WHITE
0 7 SET-WHITE
2 7 SET-BLACK
5 7 SET-WHITE
6 7 SET-WHITE
7 7 SET-WHITE
7 8 SET-WHITE
2 9 SET-WHITE
4 9 SET-WHITE
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
 DISP-BOARD
 ;

END MAIN


