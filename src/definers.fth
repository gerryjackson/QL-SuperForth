-- 	FORTH 83 Cross compiler -  Defining words

--	Last modified:		21 October 1986

X: CSP!	SP@ CSP !	;

: SMUDGE
	LATEST 2+ C@ 32 XOR
	LATEST 2+ C!		;

: CREATE
	DP_EVEN bl word
	CONTEXT_SEEK NOT_NIL
	IF
	  CR ten MESSAGE
	  DUP ID.
	THEN
	2DROP HERE LATEST ,
	CURRENT @ !
	HERE C@ 31 MIN DUP 128 OR
	HERE C! ALLOT
	HERE C@ 128 OR C, DP_EVEN
	(VARIABLE) ,		;

: DOES>
	COMPILE (;CODE)
	(jump_to_does)
	literal , literal ,	;	immediate

: [	0 STATE !	;	IMMEDIATE

: ]	-1 STATE !	;

: :	?EXEC CSP!
	CURRENT @ CONTEXT !
	CREATE SMUDGE
	COMPILE_CFA (:)
	]		;
 
: ;	?CSP COMPILE (;)
	SMUDGE [compile] [	;	immediate

: CONSTANT
	CREATE COMPILE_CFA (CONSTANT)
	,		;

: 2CONSTANT
	CREATE
	  , ,
	DOES>
	  2@	;

: VARIABLE
	CREATE 0 ,	;

: 2variable
	variable 0 ,	;

X: LINK_IN
	, DUP @ HERE
	ROT ! ,		;

: VOCABULARY
	CREATE
	  NIL ,
	  VOC_LINK
	  [ HEX 81A0 DECIMAL ] LITERAL
	  LINK_IN
	DOES>
	  CONTEXT ! ;

X: XQ_ERROR
	[ here 2- load_{xq_error} ]
	14 ERROR	;

: EXVEC:
	?EXEC
	CREATE
	  XQ_LINK [host'] xq_error
	  LINK_IN
	DOES>
	  @ EXECUTE	;

: assign
	' ?found 2+	;	immediate

: to-do
	' ?found state @
        if
	  [compile] literal
	  [compile] literal
	  compile !
        else
	  swap !
	then		;	immediate

: forth-83 [compile] forth	;


