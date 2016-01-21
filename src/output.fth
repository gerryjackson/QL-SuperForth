( FORTH 83 Cross compiler -  Output words )

( Last modified:	9 November 1986 )

: pad	(pad) @		;

: HERE	DP @	;
 
: COUNT
	DUP 1+ SWAP C@	;
 
: TYPE
	DUP 0>
	IF
	  >R
	  7 #OUT 2@ R> TRAP3
	  DUP ?ERROR
	THEN
	2DROP		;

: message			-- Version with messages outside dictionary
	#out 2@ rot             -- ( n1 --- ID n1 )
	.message		-- (   --- n2 )
	dup ?error	;
	

-- : message			-- Version with internal messages
--	2* message_vecs + @	-- Read address of desired message
--	count type	;

: EMIT	EMIT_VAR C! EMIT_VAR 1 TYPE ;

: CR	ten EMIT	;

: SPACE	BL EMIT		;
 
: SPACES
	BEGIN
	  DUP 0>
	WHILE
	  SPACE 1-
	REPEAT
	DROP	;

: HOLD	-1 HLD +! HLD @ C!	;

X: PRINT_NUM
	OVER - SPACES
	TYPE		; 

X: HOLD_ASCII
	DUP 9 >
	IF 7 + THEN
	48 + HOLD	;
 
X: PAD_TOP
	PAD 84 +	;

: <#	PAD_TOP HLD !	;

: #>	2DROP HLD @
	PAD_TOP OVER -	;

: SIGN	0<
	IF 45 HOLD then	;

: #	BASE @ M/MOD
	ROT HOLD_ASCII	;

: #S	BEGIN
	  # 2DUP D0=
	UNTIL		;

: D.R	>R SWAP OVER DABS
	<# #S ROT SIGN
	#> R> PRINT_NUM	;

: D.	0 D.R SPACE	;
 
: U.	0 D.	;

: .R	>R DUP ABS 0 <#
	BEGIN
	  BASE @ UM/MOD
	  SWAP HOLD_ASCII 0
	  OVER 0=
	UNTIL
	ROT SIGN
	#> R> PRINT_NUM	;

: .	0 .R SPACE	;
 
: ?	@ .	;

: u.r
	0 swap d.r	;

: DECIMAL
	ten BASE ! ;

: HEX	16 BASE ! ;

: H.	BASE @ SWAP
	HEX U.
	BASE !		;
 
X: DEC.
	BASE @ DECIMAL
	SWAP U.
	BASE !		;

: -TRAILING
	DUP 0>
	IF
	  BEGIN
	    1- 2DUP + C@ BL -
	    OVER 0< OR
	  UNTIL
	  1+
	THEN	;

: (CLS)
	1 BL #OUT 2@ 1 TRAP3
	DUP ?ERROR 2DROP	;

EXVEC: CLS   ASSIGN CLS TO-DO (CLS)

