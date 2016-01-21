--	 FORTH 83 Cross compiler -  Error handling

--	Last modified:	21 October 1986

forth_address {exvec:}			-- Load address into {exvec:}

] jump_to_does @ execute exit [		-- DOES> code for execution vectors

forth_address {xq_error}	-- Must be loaded with address of (ERROR)
				-- later, for now it allows ERROR to be created
				-- (ERROR) cannot be created yet, it uses QUIT

EXVEC: ERROR		-- Note ERROR has not been assigned to anything yet

: ?ERROR
	SWAP
	IF
	  ERROR EXIT
	THEN
	DROP		 ;
 
: ?EXEC
	STATE @ 2 ?ERROR	;

: ?FOUND
	DUP 0= eight ?ERROR		;

: ?COMP
	STATE @ 0= 1 ?ERROR	;

X: ?CSP
	SP@ CSP @ -
	four ?ERROR		;

: ?STACK
	DEPTH 0<
	IF
	  SP! 6 ERROR
	THEN
	DEPTH MAX_DEPTH @ >
	7 ?ERROR		;

X: ?PAIRS
	- 3 ?ERROR	;

X: ?LOADING
	BLK @ 0= five ?ERROR	;
 
