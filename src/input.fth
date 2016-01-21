--		FORTH 83 Cross compiler -  Input words

--		Last modified:	19 October 1986 )

XVARIABLE KEY_INPUT		-- True for keyboard input
-1 here 2- !			-- Preset to true

: tib	(tib) @		;

X: MOVE_CURSOR
	nil SWAP #IN 2@ 0 TRAP3		-- nil is convenient and irrelevant
	3DROP		;
 
: EXPECT
	DUP 0>
	IF
	  >R 2 #IN 2@ R> TRAP3
	  DUP -5 <>
	  IF
	    DUP ?ERROR 1- 0
	  THEN
	  DROP
	ELSE
	  DROP 0
	THEN
	SPAN ! DROP
	KEY_INPUT @
	IF
	  19 MOVE_CURSOR
	  20 MOVE_CURSOR SPACE
	THEN		;
 
: QUERY
	TIB TIB_LENGTH EXPECT
	0 >IN !
	0 BLK !
	SPAN @ #TIB !	;
 
: CONVERT
	BEGIN
	  1+ DUP >R C@ BASE @ DIGIT
	WHILE
	  SWAP BASE @ UM* DROP
	  ROT BASE @ UM* D+ DPL @ 1+
	  IF 1 DPL +! THEN
	  R>
	REPEAT
	R>		;

: NUMBER
	0 0 ROT
	DUP 1+ C@ 45 =
	DUP >R - -1
	BEGIN
	  DPL ! CONVERT DUP C@ BL >
	WHILE
	  1 DPL @ 0<
	  IF DROP DUP C@ 46 - THEN
	  IF 3DROP 0 ERROR THEN
	  0
	REPEAT
	DROP R>
	IF DNEGATE THEN		;

: key
	tib 1 #in 2@ 1 trap3
	dup ?error swap drop
	255 and		;


