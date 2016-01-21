--		FORTH 83 Cross compiler -   File and block handling

--		Last modified:	21 October 1986

forth_address {2constant}
] jump_to_does 2@ exit [		-- Run time code for 2CONSTANTs

-1 -1 2CONSTANT #DEFAULT
here 4 - default_id !		-- Save address for patching at end

BUF_SIZE CONSTANT B/BUF

64 CONSTANT C/L

16 CONSTANT L/B

XVARIABLE MESS_FLAG	-1 here 2- !

VARIABLE DRIVE	1 here 2- !

VARIABLE #FILE				-- Really a 2VARIABLE
-1 here 2- ! -1 ,

X: bkbuf
	buf_ad @	;

X: MARK_BLOCK_VALID
	1 BKBUF C!
	BKBUF 2+	;

xvariable device
	8 here 2- !			-- The string length
	102 c, 108 c, 112 c, 49 c,	-- flp1
	 95 c,  66 c,  76 c, 75 c,	-- _BLK

X: SET_DRIVE
	device 2+  2! DRIVE !	;

X: HERE+64
	HERE 64 +
	1+ -2 AND	;

X: SAVE_DRIVE
	48 +
	HERE+64
	five + C!		;

X: GENERATE_NAME
	DEVICE				( DEVICE is a string 'flp1_BLK' )
	HERE+64 ten CMOVE
	DRIVE @ SAVE_DRIVE
	BASE @ DECIMAL
	BKBUF 2- @ 0
	<# #S #>
	DUP HERE+64 +!
	HERE+64 ten +
	SWAP CMOVE
	BASE !		;

X: ABSOLUTE_PAD
	nil 2@ HERE+64
	nil - 0 D+	;

X: CALL_?ERROR
	DUP ?ERROR	;
 
X: (DEL)
	ABSOLUTE_PAD 0 four TRAP2	;

X: (DELETE)
	(DEL) DUP -7 <>
	IF CALL_?ERROR 0 THEN
	3DROP		;

X: (OPEN)
	ABSOLUTE_PAD
	ROT 1 TRAP2	;

X: (CLOSE)
	0 2 TRAP2	;

: CLOSE
	(CLOSE) CALL_?ERROR 2DROP	;

X: READ_WRITE
	BKBUF 2+ SWAP
	2OVER B/BUF
	TRAP3 >R 2DROP
	CLOSE R> CALL_?ERROR	;

X: WRITE_BLOCK
	GENERATE_NAME
	(DELETE)
	2 (OPEN) CALL_?ERROR
	73 READ_WRITE	;

X: READ_BLOCK
	GENERATE_NAME
	0 (OPEN) DUP -7 =
	IF
	  DEVICE 2+ @
	  [ HEX 4D44 DECIMAL ] LITERAL
	  =
	  IF
	    3DROP 3
	    DRIVE @ - SAVE_DRIVE
	    0 (OPEN)
	  THEN
	THEN
	CALL_?ERROR
	72 READ_WRITE	;

: EMPTY-BUFFERS
	0 BKBUF C!	;

: SAVE-BUFFERS
	BKBUF C@ 2 =
	IF WRITE_BLOCK THEN
	1 BKBUF C!	;

X: BUF	SAVE-BUFFERS
	EMPTY-BUFFERS
	BKBUF 2- !
	BKBUF 2+	;

: BUFFER
	BUF B/BUF BL FILL 
	MARK_BLOCK_VALID
	0 OVER B/BUF + !	;

X: MESS13
	-1 MESS_FLAG !	;

X: MESSAGE13
	MESS_FLAG @ MESS13
	IF
	  CR 13 MESSAGE DUP DEC.
	THEN		;

: BLOCK
	BKBUF C@
	IF
	  BKBUF 2- @ OVER =
	  IF DROP BKBUF 2+ EXIT THEN
	THEN
	MESSAGE13
	BUF DROP READ_BLOCK
	MARK_BLOCK_VALID	;

: UPDATE
	2 BKBUF C!	;

: LIST
	0 MESS_FLAG !
	DUP BLOCK MESS13 SWAP
	DUP SCR !
	CR CLS 11 MESSAGE
	. CR L/B 0
	DO
	  DUP C/L
	  -TRAILING CR TYPE
	  C/L +
	LOOP
	CR DROP		;

X: MOVE_HERE+64
	0 HERE+64 !
	HERE+64 1+ OVER
	C@ 1+ CMOVE>	;
 
: flush
	save-buffers empty-buffers	;

-- More file handling at end of X_inter_fth

