( FORTH 83 Cross compiler -  Dictionary handling words )

( Last modified:	21 October 1986 )

XVARIABLE U/LCASE  bl here 2- !

: UPPER	  0 U/LCASE ! ;			( Upper case only )

: LOWER	 BL U/LCASE ! ;			( Lower case also )

: WORD
	DUP BL = DUP
	IF 
	  DROP BL
	THEN
	TIB #TIB @ BLK @
	IF 
	  2DROP BLK @ BLOCK B/BUF
	THEN
	OVER >R OVER + SWAP
	>IN @ +
	(WORD)
	R> - >IN !
	HERE 2+ 2DUP C!
	1+ 2DUP + BL SWAP C!
	SWAP CMOVE
	HERE 2+			;

: ALLOT DP +!	;
 
X: DP_EVEN
	0 HERE C!
	HERE 1 AND ALLOT	;

: ,	HERE 2 ALLOT !	;

: COMPILE
	?COMP
	(COMPILE) ,	;
 
: RP!	COMPILE (RP!)	;

X: COMPILE_CFA
	-2 ALLOT (COMPILE) ,	;

: LATEST
	CURRENT @ @ ;

: ID.	2+
	BEGIN
	  1+ DUP C@ 127
	  2DUP AND EMIT >
	UNTIL
	DROP	;

X: NOT_NIL
	DUP NIL <> ;

: seek
	u/lcase @
	if word_to_upper then
	not_nil
	if (seek) then		;
	
 
X: CONTEXT_SEEK			( Searches all context vocabularies )
	DUP U/LCASE @
	IF WORD_TO_UPPER THEN
	ten 0 DO
		DROP CONTEXT I + @
		NOT_NIL
		IF
		  @ (SEEK) NOT_NIL
		  IF LEAVE THEN
		THEN
	   2 +LOOP	;

: LITERAL
	STATE @
	IF
	  (LITERAL) (LITERAL) , ,
	THEN		;	IMMEDIATE

: C,	HERE 1 ALLOT C!	;

: '	BL WORD CONTEXT_SEEK
	NIL =
	IF DROP eight ERROR THEN	;

X: SNIP
	DUP
	BEGIN
	  @ R> R> R@
	  ROT ROT >R >R OVER >
	UNTIL
	OVER ! @	;

forth_address {vocabulary}

] jump_to_does context ! exit [		-- Run time code for vocabulary

VOCABULARY FORTH
	[ here 6 - target_address       -- Save parameter field address
	  (forth) !			-- of FORTH

: RECURSE
	?COMP LATEST LINK> ,	;

: FIND	CONTEXT_SEEK NOT_NIL
	IF
	  2+ C@ 64 AND
	  0= 2* 1+ EXIT
	THEN
	DROP 0		;


: >LINK	>NAME 2-	;

: >body			-- Compilation address to parameter field
	2+	;

: body>			-- Parameter field to compilation address
	2-	;

: name>			-- Name field to compilation address
	2- link> ;

: n>link		-- Name field to link field
	2-	;

: l>name		-- Link field to name field )
	2+	;

x: (;code)
	[ here 2- load_{(;code)} ]
	{;CODE},  LATEST LINK> !	;


VOCABULARY ONLY
	here 6 - target_address		-- Save parameter field address
	(only) !			-- of ONLY
	here target_address here 8 - !	-- Point ONLY code pointer HERE
	] jump_to_does			-- the DOES> code for ONLY
	eight 0 DO
	      NIL I CONTEXT + !		-- Clears top 8 words of context
	  2 +LOOP
	dup context !
	CONTEXT eight + !
	exit   [

: DEFINITIONS
	CONTEXT @ CURRENT !	;

: ALSO	CONTEXT DUP 2+
	6 CMOVE>	;

: previous		-- Removes top context vocabulary from search order
	context dup 2+ swap
	6 cmove          	-- Slide next 3 vocabularies up 2 bytes
	nil context 6 + !  ;	-- Ensure last is empty

: ORDER	CR 26 MESSAGE
	CONTEXT ten OVER + SWAP
	DO
	  I @ NOT_NIL
	  IF
	    DUP 2- >LINK ID. SPACE
	  then
	  DROP 2
	+LOOP
	CR 27 MESSAGE
	CURRENT @ 2-
	>LINK ID.	;

: SEAL	[ (only) @ ] LITERAL
	ten 0
	DO
	  CONTEXT I + @ OVER =
	  IF
	    NIL CONTEXT I + !
	  THEN
	  2
	+LOOP
	DROP		;

: WORDS
	CR CONTEXT @ @
	BEGIN
	  eight 0
	  DO
	    NOT_NIL 0=
	    IF LEAVE THEN
 	    DUP ID. 2 SPACES @
	  LOOP
	  CR NOT_NIL 0=
	UNTIL
	DROP	 ;

: immediate 
	latest 2+ dup c@
	64 or swap c!	;

: [compile]
	?comp '
	?found ,	;	immediate

: [']
	?comp '
	[compile] literal  ;	immediate

: blank
	bl fill		;

: erase
	0 fill		;


