-- 	FORTH 83 Cross compiler -  Interpreter words

--	 Modification record:

--	13/11/86	RENAME definition added

X: CDOT	
	[ here 2- load_{(.")} ]	
	(.") TYPE	;

: ."	?COMP $" WORD
	COMPILE CDOT
	C@ 1+ ALLOT
	DP_EVEN	;	immediate
 
: .(	41 WORD
	COUNT TYPE	;	immediate
 
: .s	cr ." ( ==>  "
	depth 0>
	if
	  0 depth 2-
	  do i pick . -1 +loop
	then
	."  ) top" cr	;

: INTERPRET
	BEGIN
	  BL WORD DUP C@ 0=
	  IF 
	    BLK  @ IF ?EXEC THEN
	    DROP EXIT
	  THEN
	  CONTEXT_SEEK NOT_NIL
	  IF
	    2+ C@ 64 AND STATE @ 0= OR
	    IF EXECUTE ELSE , THEN
	  ELSE
	    DROP NUMBER DPL @ 1+
	    IF
	      STATE @
	      IF SWAP [COMPILE] LITERAL THEN
	    ELSE
	      DROP
	    THEN
	    [COMPILE] LITERAL
	  THEN
	  ?STACK
	0 until		;  -2 ALLOT

: LOAD
	BLK @ >R BLK !
	>IN @ >R 0 >IN !
	INTERPRET
	R> >IN !
	R> BLK !	;

X: SET_#0
	#DEFAULT #IN  2!
	#DEFAULT #OUT 2!	;

: OK	STATE @ 0=
	IF
	  ."  ok"
	THEN
	CR	;

EXVEC: PROMPT  ASSIGN PROMPT TO-DO OK

: QUIT	SET_#0
	[COMPILE] [ CR
	BEGIN
	(rp!) QUERY
	INTERPRET PROMPT
	0 until		;  -2 ALLOT

: (ERROR)
	SET_#0
	HERE 2+ COUNT TYPE
	."  ? " CR
	DUP 0<
	IF
	  LOAD_D0 #OUT 2@ 2DUP
	  [ HEX CC DECIMAL ] LITERAL
	  VEC_UT 3DROP QUIT
	THEN
	MESSAGE QUIT	;   -2 ALLOT

ASSIGN ERROR TO-DO (ERROR)

x: p_error			-- For primitive detected errors
	[ here prim_error ! ]
	error ;

: (ABORT)
	SP! QUIT  ;  -2 ALLOT
  
EXVEC: ABORT	ASSIGN ABORT TO-DO (ABORT)

: COLD
	[ here cold_forth ! ]			-- Save address for patching
	-32768					-- To be patched with FORTH LATEST
	[ (forth) @ ] literal !			-- Patch vocabulary pointer
	[ here cold_only  ! ]			-- Save address for patching
	-32768					-- To be patched with ONLY LATEST
	[ (only)  @ ] literal !			-- Patch vocabulary pointer
	[ COLD_USERS @ ] literal		-- From
	[ user_area @  ] literal		-- To
	[ NUMBER_USERS @ ] literal		-- Number
	CMOVE					-- Load cold start user values
	-1 [ ' timeout >body ] literal !	-- Ensure Trap3 timeout is -1
	SP! (rp!)
	0 here 2+ !				-- To avoid a mess if an error
	ASSIGN PROMPT TO-DO OK
	ASSIGN ERROR  TO-DO (ERROR)
	ASSIGN ABORT  TO-DO (ABORT)
	ASSIGN CLS    TO-DO (CLS)
	SET_#0 CLS EMPTY-BUFFERS
	1 LOAD
	CLS CR	12 MESSAGE
	QUIT	;	-2 ALLOT

X: SECRET_MESSAGE
	CLS 15 MESSAGE
	QUIT	;	-2 ALLOT

: FORGET
	BL WORD LATEST SEEK
	NOT_NIL ?FOUND DROP
	SWAP FENCE @ < 9 ?ERROR
	CONTEXT @ OVER >
	OVER CURRENT @ < OR
	IF
	  ONLY FORTH DEFINITIONS
	  CR 22 MESSAGE
	THEN
	>R XQ_LINK SNIP
	BEGIN
	  DUP 2- DUP @
	  R@ >
	  IF
	    (XQ_ERROR) SWAP ! 0
	  THEN
	  DROP @ DUP NIL = 
	UNTIL
	DROP
	VOC_LINK SNIP
	BEGIN
	  DUP four -
	  BEGIN
	    @ DUP R@ <
	  UNTIL
	  OVER four - !
	  @ DUP NIL =
	UNTIL
	DROP R> DP !	;

: (
	41 word drop	;	immediate

: -->
	blk @
	if
	  0 >in !
	  1 blk +!
	then		;	immediate

: thru
	1+ swap
	do i load loop	;

X: SAVE_NAME
	BL WORD
	MOVE_HERE+64	;

: OPEN
	SAVE_NAME (OPEN)
	CALL_?ERROR	;

: DELETE
	SAVE_NAME (DELETE) ;

: NULL		;

: END_FILE
	ASSIGN ERROR TO-DO (ERROR)
	#DEFAULT #IN 2!
	-1 KEY_INPUT !
	ASSIGN PROMPT TO-DO OK
	#FILE 2@ CLOSE		;

X: LOAD_ERROR
	END_FILE ERROR	;

: LOAD_FILE
	0 OPEN 2DUP
	#FILE 2!
	#IN 2!
	0 KEY_INPUT !
	ASSIGN ERROR x_to-do LOAD_ERROR		-- load_error is headerless
	ASSIGN PROMPT TO-DO NULL	;

: OPEN_DEVICE
	MOVE_HERE+64
	(OPEN) CALL_?ERROR ;

: rename		-- eg  RENAME file1 file2 ; file2 is the new name
	0 open 2dup			-- (--- ID ID )
	1 allot				-- To get word aligned string length
	bl word
	0 here ! -1 allot		-- Ensure ms byte of length is zero
	dup c@ 0=
	if 8 error then			-- ( --- ID ID ad1 )
	1- 74 2swap 0			-- ( --- ID ad1-1 n1 ID 0 )
	trap3 dup ?error		-- ( --- ID n3 n4 )
	2drop close	;

: DELETE_FILE
	MOVE_HERE+64
	(DELETE)	;

X: (STATUS)
	(OPEN) >R (CLOSE)
	3DROP R> DUP 0=
	IF (DEL) 3DROP THEN	;

: STATUS
	2 SAVE_NAME (STATUS)	;

: DEVICE_STATUS
	2 SWAP MOVE_HERE+64 (STATUS)	;


