this is a MSX game written in [H-Forth](https://github.com/MIN0/H-FORTH_MSX)( by A. Hiramatsu).  The source file masyu.4th generates masyu.com file which can be packaged into a DSK file and run in emulators.  This program is designed to run on MSX1 as well as any later MSX.

The program was written to submit to [MSXDEV25](https://www.msxdev.org/2026/01/07/msxdev25-24-masyu/)

### How to compile and run the game
In order to compile the source you'll need to setup a MSX-DOS disk and copy HFORTH.COM from H-FORTH site.  Then `HFORTH masyu.4th` will compile and produce a masyu.com file.  Running the game is just running MASYU.com from the MSX-DOS prompt, or if you have a .DSK file then boot with that disk.

### About the program
The fonts allow for the display of lines and circles.  I used a tool called Magellan to generate the fonts.  masyu.mag file is the map file for magellan.  It is not needed for building, but included for completeness.  
	![game fonts](font.png)


### About the puzzle format
I use the format from https://www.kakuro-online.com/masyu/  While the site does not define the format, it's pretty straight forward.  The first part is the width 'x' height followed by ':'.  For this program only one or two digits are supported for width and height.  Also for this program the total length of the string is 199 chars.  A white/clear circle is denoted with a zero and a black/solid circle is denoted with a 1.  letters a-z are used to skip 1~26 spaces.  Start from the top left, and place a 1 or 0 or skip spaces with a letter.  For example 6x6:l0d0a1b1f0100c is a 6x6 board; we first skip l=12 spaces and the first circle is clear and goes in left most column third row from the top, because the board wraps from right edge to the next row on the left edge.  A pattern like 0100 means clear, solid, clear, clear circles in a row.  For this program only lower case letters are allowed.

### How to play the game
Move around the board with arrow keys.  Hold shif to connect cells, hold ctl to disconnect while moving.  The objective of [Masyu](https://en.wikipedia.org/wiki/Masyu) is to find a loop that traverses all circles while satisfying the following.  When you have a solution use 'C' key to check.  If your solution is correct it will say solved.
- only one loop with no crosses
- lines must pass through while circles and turn in the next circle.
- lines must turn inside black circles and continue straight through the next square.  In other words two lines of at least two units long meet at 90 degrees inside a black circle.
- Hint: each puzzle has only one solution.

### Acknowledgements ###
* Thanks to my family for supporting my hobby
* Thank you to Paulo for listening to my thoughts about this, and for his code contributions.
* Thanks to Hiramatsu san for the H-FORTH compiler; it worked out nicely 25+ years later.
* Thanks to the folks at MSXDev.org for the oppourtunity to create something for MSX, and for the nice writeup.
* Thanks to the folks running msx.org and "MSX Assembly Page" for providing valuable resouces for the community.