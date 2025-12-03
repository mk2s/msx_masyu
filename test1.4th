
: cls 
$c3 BIOS
;

: POSIT
$c6 BIOS
;

: STRXY PARAM( x y s )
256 x * y + >> _HL POSIT
s STR.
/* 65 >> _A $a2 BIOS */
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
) $0400 LDIRVM
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

: MAIN
 1 >> _A  $5F BIOS /* switch to screen 1 */
 cls
 1 VSYNC
 SETUPCHARS PAINT-SCRN
 1 24 " " STRXY
 { }
;

END MAIN


