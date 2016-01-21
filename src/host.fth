--	FORTH 83 Cross compiler - Cross compiler definitions

--	Copyright 1986  G.W.Jackson

--	Last modified:	11 November 1986


-32768 constant nil		-- Used to indicate a nil pointer

only definitions forth also forth

: previous		-- Removes top context vocabulary from search order
	context dup 2+ swap
	6 cmove          	-- Slide next 3 vocabularies up 2 bytes
	nil context 6 + !  ;	-- Ensure last is empty

vocabulary host			-- Vocabulary for cross compiler defining words
				-- and immediates
vocabulary target		-- For the cross compiled code

-- The idea is that when the cross compilation actually starts the FORTH and
-- ONLY vocaabularies will never be searched; any words to be executed will
-- be in the host vocabulary; words whose compilation address is compiled will
-- only be in the target vocabulary. This should prevent any references
-- to FORTH words being compiled or executed inadvertantly

only forth definitions

variable target_start		-- Start address (host) of target code
variable origin			-- Address (host) of origin of target dictionary
                                -- The origin is the lowest accessible Forth
				-- address in the target system

: address_var		-- Creates an object which, when executed, compiles the
			-- compilation of immediates and headerless code
	create nil , immediate
	does>
	  @ dup nil =
	  if 
	    only forth definitions
	    -1 abort" Address variable not initialised"
	  then
	  ,	;

-- Now for these address variables, these will be loaded by the assembled
-- machine code or by FORTH code, as appropriate

address_var {branch}
address_var {?branch}
address_var {do}
address_var {loop}
address_var {+loop}
address_var {leave}
address_var {literal}
address_var {."}			-- Run time machine code for ."
address_var {(.")}			-- Run time FORTH code for ."
address_var {;code}			-- Run time machine code for ;code
address_var {(;code)}			-- Run time FORTH code for ;code
address_var {create}
address_var {does}
address_var {:}				-- Must hold target address of {:}
address_var {;}
address_var {constant}
address_var {2constant}
address_var {user}
address_var {vocabulary}
address_var {exvec:}
address_var {xq_error}			-- Address of error routine
address_var {compile}			-- Run time code for COMPILE
address_var {cr}			-- Compilation address of CR
address_var {abort}			-- Compilation address of ABORT
address_var {rp!}
address_var {word}
address_var {digit}
address_var {word_to_upper}
address_var {read"}
address_var {compare}
address_var {up_char}
address_var {loc_char}
address_var {locate}
address_var {seek}
address_var {!}				-- Needed for host assign
address_var {.message}
address_var {load_d0}
address_var {call_man_trap}
address_var {load_job}
address_var {job_skeleton}

2variable {jump_to_does}		-- For DOES>, holds the machine code

variable h_csp				-- Used in host : and ; stack check
variable do_list nil do_list !		-- Used to link nested do loops
variable t_voc_link nil t_voc_link !	-- For target voc_link
variable t_xq_link  nil t_xq_link  !	-- For target xq_link
variable x:flag				-- True when headerless word is
0 x:flag !				-- being defined

-- Both these last two must have their linked list adjusted to target
-- addresses and be patched into the target user variable cold start values

: ?pairs
	?comp - 3 ?error	;

: target_address	( host_ad --- target_ad )
	origin @ - nil +	;

: host_address		( target_ad --- host_ad )
	nil + origin @ +	;

: h:    only host definitions		-- Special version of : to compile
					-- defining words and immediate words
	:				-- into host vocabulary
	forth		;		-- Search forth first in compilation of
					-- host definitions

: h;	[compile] ;			-- Corresponding version of ;
	only forth definitions ; immediate

: h_csp!
	depth h_csp !	;

: ?h_csp
	depth h_csp @ <>
	if
	  only forth definitions
	  -1 abort" Stack error in target colon definition "
	then	;

: host_immediate			-- Makes host definition immediate
	also host definitions
	immediate
	previous definitions	;

: create_with_name	-- Like create except that it announces the new word
	create latest id. space		;

: get_integer		-- Gets a 16 bit binary word from the input stream
	key 256 *			-- ms byte
	key +		;

: load_anonymous_code		-- Loads a block of unnamed code, this assumes
				-- that all unnamed words are together and that
				-- the assembler has inserted correct code
				-- pointers into the appropriate places
	get_integer 0			-- The size of the block in bytes
	do key c, loop	;		-- Compile the code. Cannot use EXPECT
					-- since a value of 10 will stop input

: load_header			-- Creates a code header, less code pointer
	key dup 127 >			-- Get the name length
	if
	  only forth definitions -1
	  abort" Invalid name length"	-- Remove this check eventually
	then
	tib over expect			-- Get the name itself
	span @ #tib !			-- Set span to number of characters
	1 and 0= if key drop then	-- Lose padding byte if length was even
	0 >in !				-- Reset input pointer
	create_with_name	;	-- Create new target entry

: load_shared_code		-- Loads a named primitive which has no code
				-- of it's own but shares some with others.
				-- The code pointer must follow the name.
	load_header			-- Create the header
	get_integer here 2- !	;	-- Compile the code pointer

: load_named_code			-- Loads a named machine code primitive
	load_header			-- Create the header
	here target_address here 2- !	-- Set code pointer
	get_integer 0			-- Get code length
	do key c, loop	;		-- Compile the machine code

: target_words			-- A safe way to list target vocabulary words
	also target
	cr words previous	;

: target_only                           -- Used in defining words
	only target definitions seal	;

: host_only				-- At end of variable etc
	only host definitions seal	;

variable anon_list		-- Points to last entry in anonymous header list
32766 1040 - anon_list !	-- Assumes  block buffer at top end of dictionary
				-- Can be moved to 32766 if block buffer moved

' {branch} @			-- Address of run time code of an address_var
constant anon_reference		-- Holds address of code to compile anonymous
				-- reference in target definition

: anon,	-2 anon_list +!		-- (n --- ) Compiles n into anonymous header
	anon_list @ !	;

: detach_header		-- Copies an anonymous header from target dictionary
			-- into anonymous list and saves compilation address
	latest dup target_address anon,	-- Store anonymous words compilation addr
	anon_reference anon,		-- Save code pointer
	dup 2+
	c@ 31 and 4 + -2 and		-- (--- ad1 l) l=header length
	dup >r
	negate anon_list +!		-- Make space for header
	anon_list @ here 100 + <	-- Check there is sufficient space
	abort" ERROR: Out of work space"
	dup anon_list @ r@ cmove	-- Copy header from target dictionary
	r@ over +			-- (--- ad1 ad2) ad2= code field address
	@ swap !			-- Move code pointer to new position
	r> negate allot			-- Reclaim target dictionary space
	anon_list @ context @ !	   ;	-- Update vocabulary pointer


-- Some variables in the host vocabulary which are used during compilation

only forth also host definitions

variable cold_users		-- Target address of user cold start values
variable number_users		-- Holds number of user variable bytes
variable tib_area		-- Target address of tib
variable tib_offset		-- User variable number
variable pad_area		-- Target address of pad
variable pad_offset		-- User variable number
variable buf_ad_offset		-- User variable number
variable user_area		-- Target address of run time user variables
variable (dp)			-- Target address of dp
variable (fence)		-- Target address of fence
variable (xq_link)		-- Target address of xq_link
variable (voc_link)		-- Target address of voc_link
variable (current)		-- Target address of CURRENT variable
variable (context)		-- Target address of CONTEXT variables
variable (timeout)		-- PFA of timeout
-- 29 constant number_messages	-- Number of error and other messages
variable message_vectors	-- Address of message vector array in target
88 constant tib_size		-- Size of TIB
84 constant pad_size		-- Size of PAD
1024 constant buf_size		-- Size of block buffer
variable (only)			-- Parameter field of target ONLY
variable (forth)		-- Parameter field of target FORTH
variable cold_forth		-- Holds patch address in target COLD
variable cold_only		-- Holds patch address in target COLD
variable default_id		-- Holds address of body of #DEFAULT
variable prim_error		-- Holds address of ERROR EXIT sequence for
				-- primitive detected errors


only forth definitions

h: escape				-- To return to forth
	only forth definitions
	quit h;

h: complete -1 finished !	h;

h: code_address		-- Loads the address variables with compilation
			-- addresses of immediate's run time code and of
			-- headerless words
	also forth
	' >body previous
	tib >in @ +			-- Address of ms byte of binary word
	dup c@ 256 *			-- Get and scale ms byte
	swap 1+ c@ +			-- Get and add in ls byte
	swap !				-- Save address
	2 >in +!	h;		-- Skip past binary word

h: load_target_start
	here target_start !
	here origin +!		h;

h: load_does_jump	-- Does the same as code_address for {jump_to_does}
	also forth
	' >body previous
	>r
	tib >in @ +
	dup c@ r@ c!			-- Save ms byte
	1+ dup c@ r@ 1+ c!
	1+ dup c@ r@ 2+ c!
	1+ c@ r> 3 + c!			-- Save ls byte
	4 >in +!	h;		-- Skip past data

h: load_{(;code)}
	target_address ['] {(;code)}
	>body !		h;

h: load_{xq_error}
	target_address ['] {xq_error}
	>body !		h;

h: load_{(.")}
	target_address ['] {(.")}
	>body !		h;

h: {;code},
	[compile] {;code}	h;	host_immediate

h: .message
	[compile] {.message}	h;	host_immediate

h: load_d0
	[compile] {load_d0}	h;	host_immediate

h: load_code			-- Compiles all machine code primitives which
				-- are assumed to be assembled into a single
				-- file by a conventional assembler.
	target_only
	begin
	  get_integer			-- Get a type of code marker
	  case
	    1 of load_named_code     0 endof
	    2 of load_shared_code    0 endof
	    3 of load_anonymous_code 0 endof
	    0 of ( End of code )    -1 endof
	    default only forth definitions
		-1 abort" Invalid code marker in primitives"
	  endcase
	until
	host_only	h;

h: (compile)
	[compile] {compile}	h;	host_immediate

h: word_to_upper
	[compile] {word_to_upper}
				h;	host_immediate

h: (seek)
	[compile] {seek}	h;	host_immediate

h: (.") [compile] {."}		h;	host_immediate

h: (literal)
	[compile] {literal}	h;	host_immediate

h: (xq_error)
	[compile] {literal}
	[compile] {xq_error}	h;	host_immediate

h: (variable)
	[compile] {literal}
	[compile] {create}	h;	host_immediate

h: (:)
	[compile] {:}		h;	host_immediate

h: (;)
	[compile] {;}		h;	host_immediate

h: (constant)
	[compile] {constant}	h;	host_immediate

h: (do)
	[compile] {do}		h;	host_immediate

h: (loop)
	[compile] {loop}	h;	host_immediate

h: (+loop)
	[compile] {+loop}	h;	host_immediate

h: (leave)
	[compile] {leave}	h;	host_immediate

h: (read")
	[compile] {read"}	h;	host_immediate

h: call_man_trap
	[compile] {call_man_trap}
				h;	host_immediate

h: load_job
	[compile] {load_job}	h;	host_immediate

h: job_skeleton
	[compile] {job_skeleton}
				h;	host_immediate

h: :	target_only			-- Create only in target vocabulary
	?exec				-- Check execution mode
	h_csp!				-- Save depth of stack
	create_with_name		-- Create dictionary entry
	smudge				-- Hide new word
	-2 allot [compile] {:}		-- Save address of {:}
	]		h;		-- Enter compilation mode

h: ;	?h_csp				-- Check stack depth
	[compile] {;}			-- Compile address of {;}
	[compile] [			-- Enter execution mode
	x:flag @
	if				-- If headerless code then switch to
	  host_only 0 x:flag !		-- host vocabulary before SMUDGEing
	then				-- and clear the flag
	smudge				-- Make new word visible
	host_only			-- Execute only host definitions
	h;	host_immediate

h: x:	host_only			-- Headerless, put into host vocabulary
	?exec h_csp!			-- since it has to be executed
	create_with_name
	smudge immediate		-- Hide and make it immediate
	-2 allot [compile] {:}
	detach_header			-- Copy header to anonymous list
	-1 x:flag !			-- Flag headerless code for later ;
	target_only  ]		h;	-- Compile body into target

h: variable
	target_only
	create_with_name
	-2 allot [compile] {create}
	0 ,
	host_only	h;

h: xvariable				-- Headerless variable
	host_only
	create_with_name immediate	-- Create and make it immediate
	-2 allot [compile] {create}
	detach_header
	0 ,		h;
	
h: 2variable
	[ also host ] variable
	[ previous  ]
	0 ,		h;

h: constant
	target_only
	create_with_name
	-2 allot [compile] {constant}
	,
	host_only	h;

h: xconstant				-- Headerless constant
	host_only
	create_with_name immediate
	-2 allot [compile] {constant}
	detach_header
	,		h;

h: 2constant
	target_only
	create_with_name
	-2 allot [compile] {2constant}
	, ,
	host_only	h;

h: user
	target_only
	create_with_name
	-2 allot [compile] {user}
	,
	host_only	h;

h: xuser				-- Headerless user variable
	host_only
	create_with_name immediate
	-2 allot [compile] {user}
	detach_header
	,		h;

h: vocabulary
	target_only
	create_with_name
	-2 allot [compile] {vocabulary}
	nil , 33184 ,			-- 33184 = $81A0, a dummy name
	t_voc_link dup @		-- Update target voc_link
	here rot ! ,
	host_only	h;

h: exvec:
	target_only
	?exec
	create_with_name
	-2 allot [compile] {exvec:}
	[compile] {xq_error}
	t_xq_link dup @
	here rot ! ,
	host_only	h;

h: assign
	target ' host ?found
	>body	h;	host_immediate

h: to-do
	target ' host ?found
	state @
	if
	  [compile] {literal} target_address ,
	  [compile] {literal} target_address ,
	  [compile] {!}
	else
	  swap !
	then	h;	host_immediate

h: x_to-do
	host ' target ?found
	>body @				-- Get compilation address
	state @
	if
	  [compile] {literal} ,		-- Is already a target address
	  [compile] {literal} target_address ,
	  [compile] {!}
	else
	  ." ERROR: Cannot execute a target word" abort
	then	h;	host_immediate

h: jump_to_does
	{jump_to_does} 2@ , ,	h;	host_immediate

h: (jump_to_does)
	{jump_to_does} 2@	h;	host_immediate

h: does>
	[compile] {(;code)}
	[ also host ]
	[compile] jump_to_does
	[ previous ]	h;	host_immediate

h: set_to_compile
	h_csp! smudge ]	h;	host_immediate

h: do	do_list @ nil do_list !		-- Remember start of do_list
	[compile] {do}
	<mark -1	h;	host_immediate

: resolve_loop
	-1 ?pairs			-- Check compilation constant
	<resolve			-- Insert offset back to do
	do_list @
	begin				-- Resolve possible list of leave offsets
	  dup nil <>
	while
	  dup @ swap >resolve
	repeat
	drop do_list !	;		-- Restore original do_list value

h: loop	[compile] {loop}
	resolve_loop	h;	host_immediate

h: +loop
	[compile] {+loop}
	resolve_loop	h;	host_immediate

h: leave
	[compile] {leave}
	do_list @ here do_list !	-- Insert here into do_list
	,	h;	host_immediate

h: begin
	<mark 2		h;	host_immediate

h: until
	2 ?pairs
	[compile] {?branch}
	<resolve	h;	host_immediate

h: again
	2 ?pairs
	[compile] {branch}
	<resolve	h;	host_immediate

h: while
	[compile] {?branch}
	>mark 3		h;	host_immediate

h: repeat
	>r >r 2 ?pairs
	[compile] {branch}
	<resolve
	r> r> 3 ?pairs
	>resolve	h;	host_immediate

h: if
	[compile] {?branch}
	>mark
	1	h;	host_immediate

h: else
	1 ?pairs
	[compile] {branch}
	>mark
	>r >resolve r>
	1	h;	host_immediate

h: then
	1 ?pairs
	>resolve	h;	host_immediate

h: compile
	?comp
	[compile] {compile}	h;	host_immediate

h: ."	?comp
	34 word
	[compile] {(.")}
	c@ 2+ -2 and allot
	h;	host_immediate

h: put_message"			-- Compiles error and other messages
				-- ( ad1 n1 --- ) n1 is message number
	swap target_address swap
	2* 
	[ also host ]
	message_vectors
	[ previous ] @ + !		-- Save message address
	34 word				-- Get the message
	dup 2- over c@ 1+		-- ( --- ad2 ad2-2 n2+1 )
	dup allot			-- Allocate space
	cmove		h;		-- Move message into place

h: make_even			-- Makes here an even address
	here 1 and
	if 1 allot then		h;

h: forth_address		-- Loads a target address into address variable
	here target_address
	also forth ' previous		-- Find address variable
	>body !			h;

h: abort"
	?comp
	[ also host ] [compile] if [ previous ]
	[compile] {cr}
	[ also host ] [compile] ." [ previous ]
	[compile] {abort}
	[ also host ] [compile] then [ previous ]
	h;	host_immediate

h: literal
	state @
	if
	  [compile] {literal} ,
	then	h;	host_immediate

h: '	target ' host	h;

h: [host']	-- For compilation of headerless word contents which are
		-- in the host vocabulary, like ['] below
	?comp
	host ' target
	[ also host ] [compile] literal [ previous ]
	h;	host_immediate

h: [']	?comp
	target ' host target_address
	[ also host ] [compile] literal [ previous ]
	h;	host_immediate

h: (	[compile] (	h;	host_immediate

h: .(	[compile] .(	h;	host_immediate

h: [	[compile] [
	host_only	h;	host_immediate

h: (rp!) [compile] {rp!}	 	h;	host_immediate

h: (word)
	[compile] {word}		h;	host_immediate

h: digit
	[compile] {digit}		h;	host_immediate

h: [compile]
	?comp
	target_only ' ?found
	target_address ,  h;	host_immediate

h: new_line
	10 c,	h;

h: here	here	h;
h: !	!	h;
h: @	@	h;
h: -	-	h;
h: dup	dup	h;
h: allot allot	h;
h: ,	,	h;
h: c,	c,	h;
h: --	[compile] --	h;	host_immediate
h: target_address target_address	h;
h: 2-	2-	h;
h: 2*	2*	h;
h: ]	] target_only	h;
h: hex	hex	h;
h: decimal	decimal	h;

h: immediate
	also target definitions
	immediate
	previous 	h;

h: bl	bl	h;
h: >body	>body	h;

: make_number			-- Converts and compiles, possibly, a number
	number				-- else try to convert it to a number
	dpl @ 1+			-- Is it a double number?
	if
	  state @			-- Compiling ?
	  if
	    swap			-- Yes, treat ls half first
	    [compile] {literal} ,
	    [compile] {literal} ,
	  then
	else                    	-- No
	  drop state @			-- Compiling?
	  if
	    [compile] {literal} ,
	  then
	then		;


: x_interpreter			-- The cross compiler interpreter
	0 finished !
	begin
	  >in @ #tib @ >= if query then
	  finished @ if exit then
	  bl word dup c@ 0=
	  if
	    drop
	  else
	    state @
	    if				-- If compiling
	      only target seal		-- Only search the target vocabulary
	      dup find 0<		-- Need dup because FIND will find
	      if			-- immediates
		target_address ,	-- If not immediate then compile it
		drop
	      else
		drop host find 0>	-- else search the host
	 	if
		  execute		-- If found then execute it
		else
		  make_number		-- else try as a literal
		then
	      then
	    else
	      only host seal find	-- If interpreting search only host
	      if
		execute			-- If found then execute it
	      else
		make_number
	      then
	    then
	  then
	  finished @
	until
	only forth definitions	;

: quit_to_forth
	only forth definitions
	quit	;

: only_word		-- Unlinks the following word from the target
			-- FORTH vocabulary and links it into the
			-- target ONLY vocabulary
	bl word target_only
	latest seek dup nil =		-- Error if word is not found
	if
	  drop cr ." ERROR: "
	  count type ."  not found" quit_to_forth
	then
	swap drop current		-- Now look for the previous entry
	begin
	  @ 2dup @ =			-- Until found
	  over @ nil = or		-- or at end of dictionary
	until
	dup @ nil = 			-- Error if at end of dictionary
	if
	  2drop ." ERROR: end of dictionary reached" quit_to_forth
	then
	over @ swap !			-- Unlink word from FORTH vocabulary
	[ also host (only) previous ]	-- Leaves cfa of variable holding
	literal				-- target ONLY vocabulary pointer
	@ host_address 2dup
	@ swap !			-- Link word to next ONLY word
	!				-- Make word top of ONLY vocabulary
	only forth definitions	;

: adjust_links		-- Adjusts a chain of linked addresses from
			-- host to target addresses, tos is start of chain
	begin
	  dup @ -32768 <>		-- Adjust all link addresses to
	while				-- target addresses
	  dup @ dup target_address
	  rot !
	repeat
	drop		;

: patch_target			-- Patches various target addresses prior to
				-- saving the executable Forth image
	[ also host also forth ]	-- To execute forth ]
	also target context @ @		-- Get address of top of target
	previous target_address		-- dictionary and store
	cold_forth @ 2+ !		-- in COLD location
	[ also host (only) previous ]
	literal @ host_address @	-- Leaves ONLY LATEST
	target_address cold_only @ 2+ !	-- Patch into COLD location
	here target_address dup
	(dp) @ !			-- Cold start DP value
	(fence) @ !			-- Cold start FENCE value
	t_xq_link @ target_address
		(xq_link) @ !		-- Cold start XQ_LINK value
	t_voc_link @ target_address
		(voc_link) @ !		-- Cold start VOC_LINK value
	(forth) @ (current)  @ !	-- COLD start current value
	(forth) @ (context)  @ !	-- COLD start context value
	(only)  @ (context)  @ 8 + !	-- ditto for ONLY
	user_area @ origin @ 8 + !	-- Address of user variable area
	cold_forth @ target_address
		origin @ 10 + !		-- Parameter field address of COLD
	default_id @ target_address
		origin @ 12 + !		-- Parameter field of #DEFAULT
	(timeout)  @ target_address
		origin @ 14 + !		-- Parameter field of TIMEOUT
	cold_users @ origin @ 16 + !	-- User cold start values
	prim_error @ target_address
		origin @ 18 + !		-- Error routine address for primitives
	only forth also target
	context @ previous		-- Get dictionary pointer of target
	adjust_links			-- Of target FORTH vocabulary
	[ also host (only) previous ]
	literal @ host_address		-- Leaves head of target ONLY chain
	adjust_links			-- and adjust them
	t_voc_link @ adjust_links	-- Adjust vocabulary words chain
	t_xq_link  @ adjust_links   ;	-- Adjust execution vectors chain


variable target_header			-- For setting target image header
0 ,					-- Rest of file length
0 c,					-- File access
1 c,					-- File type (executable)
0 , 0 ,					-- For dataspace
0 , 0 ,					-- Zero, not used

2variable #target -1 -1 #target 2!	-- For target channel ID

768. 2constant size_of_stacks		-- Combined size of data & return stacks

: sexec_target				-- To save target image
	0 here 2+ !			-- Ensure no spurious error message if
					-- a start up error
	target_name delete_file		-- Ensure deleted
	2 target_name open_device	-- Create a new image file
	#target 2!			-- and save channel ID
	here 4 + target_start @ - 0	-- The file length ...
	2dup target_header 2!		-- ... is saved
	65536. size_of_stacks d+
	origin @ target_start @ - 0 d+	-- Total image size
	2swap d-			-- Size of dataspace ...
	target_header 6 + 2!		-- ... is saved
	target_header 70		-- Now set the file header
	#target 2@ 0 trap3
	dup ?error 2drop
	target_start @			-- And save the file, the base address
	73 #target 2@ target_header 2+ @
	trap3 dup ?error 2drop
	#target 2@ close	;	-- Close the file

-- To re-order the dictionary to speed compilation

: re_order			-- Processes one line at a time
	target_only
	begin
	  bl word dup c@ 0= not		-- Loop until end of line
	while
	  current @ @ seek		-- Look for word
	  dup 32768 =			-- Fatal error if not found
	  abort" ERROR: Not found"
	  swap drop current
	  begin				-- Loop until find previous
	    @ 2dup @ =			-- entry in the dictionary
	    over @ 32768 = or
	  until
	  dup 32768 =			-- Fatal error if not found
	  abort" ERROR: End of dictionary reached"
	  over @ swap !			-- Unlink from old position
	  current @ @ over !		-- And re-link into top position
	  current @ !
	repeat drop
	only forth definitions		;

: target_include		-- To load into target vocabulary
	host_only include	;

: cross_compile
	host_only include
	x_interpreter		;

