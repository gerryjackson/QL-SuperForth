--	FORTH 83  Cross compiler  -    QDOS definitions

--		Last modified:	21 October 1986

hex

x: mdv	5620 4D44
	set_drive	;

x: flp	5020 464c
	set_drive	;

decimal

: mdv1_	1 mdv		;

: mdv2_	2 mdv		;

: flp1_	1 flp		;
            
: flp2_	2 flp		;

: csize
	>r >r tib 45
	#out 2@ r> 0 r> trap3*
        dup ?error
	2drop		;

x: call3*
	pad swap rot #out 2@
	rot 0 0 trap3*
	dup ?error 2drop	;

x: call3*a
	rot rot >r >r
	0 swap #out 2@
	r> 0 r> trap3*
	dup ?error 2drop	;

: paper				( colour --- )
	39 call3*	;

: ink				( colour --- )
	41 call3*	;
 
: strip				( colour --- )
	40 call3*	;

x: flash
	42 call3*	;

: flash_on
	1 flash		;

: flash_off
	0 flash		;

x: under
	43 call3*	;

: under_on
	1 under		;

: under_off
	0 under		;

: set_mode			( like basic over ) ( n --- )
	44 call3*	;

x: paint
	53 call3*	;

: fill_on
	1 paint		;

: fill_off
	0 paint ;

: pan				( pixels --- )
	27 call3*	;

: pan_line			( pixels --- )
	30 call3*	;

: pan_rline			( pixels --- )
	31 call3*	;

: scroll			( pixels --- )
	24 call3*	;

: scroll_top			( pixels --- )
	25 call3*	;

: scroll_bottom			( pixels --- )
	26 call3*	;

: tab				( column --- )
	17 call3*	;

x: to_pad
	swap 2swap swap
	pad 2!
	pad 2+ 2+ 2!	;

: block_fill			( like basic block )
				( colour width height x y --- )
	to_pad 46 call3*	;

: recolour			( like basic recol )
				( c0 c1 c2 c3 c4 c5 c6 c7 --- )
	to_pad 0 38 call3*	;

: border			( colour width --- )
	12 call3*a	;

: cursor			( x y --- )
	23 call3*a	;

: at				( column row --- )
	16 call3*a	;


x: csor
	0 swap #in 2@ 0 trap3
	dup ?error 2drop	;

: cursor_on
	14 csor		;

: cursor_off
	15 csor		;

x: graphics
	#out 2@ 0 trap3
	dup ?error 2drop	;

x: fp_stack
	>r here 300 +
	r@ - swap over
	r> cmove	;

: point
	12 fp_stack 48 graphics		;

: line
	24 fp_stack 49 graphics		;

: arc
	30 fp_stack 50 graphics		;

: circle
	30 fp_stack 51 graphics		;

: scale
	18 fp_stack 52 graphics		;

: mode				( n --- )
	s->d 16 -1 trap1
	drop 2drop	;

x: ipc				( addr --- n )
	>r 2dup 17 r>
	trap1 2drop	;

: baud				( n --- )
	0 18 0 trap1
	drop 2drop	;

: time				( --- d )
	2dup 19 0 trap1
	drop		;

: set_time			( d --- )
	20 0 trap1
	drop 2drop	;

: adjust_time			( d --- )
	21 0 trap1
	drop 2drop	;

x: call_vu
	>r pad 22 + time
	2dup r> vec_ut
	drop 2drop
	pad 1+		;

: date$				( --- addr )
	236 call_vu	;

: day$				( --- addr )
	238 call_vu
	16 +		;


-- For sound generation

hex

xvariable bp -2 allot
	0A08 , 0 , AAAA , 0A00 , 0 ,
	20 , 0 , 0100 ,

x: sw			-- Swaps bytes in a word
	0 100 um/mod
	swap 100 * +		;

: beep				( pitch duration --- )
	sw bp 0a + !
	bp  6 + c! bp
	ipc drop		;

x: pk			-- Packs 2 bytes into 1
	0F and 10 *
	swap 0F and +		;

xvariable sl -2 allot
	0B00 , 0100 ,

: silence
	sl ipc drop	;

: sound               ( fz rn wr st dur int p1 p2 --- )
	create
	  0A08 , 0 , AAAA ,
	  c, c, sw , sw ,
	  pk c, pk c, 0100 ,
	does>
	  ipc drop	;

xvariable kr -2 allot
	0901 , 0 , 0 , 0 c, 2 c,

: keyrow
	kr 6 + c!
	kr ipc		;

decimal

: beeping
	163990. a@ 0<	;

-- For example,  0 0 15 1 1500 100 50 1 sound zap
-- To hear type		zap

x: v_ok
	#out 2@ #default #out 2!
	ok  #out 2!	;

2variable #print

: printer_is
	0 open #print 2!	;

: printer_on
	assign prompt x_to-do v_ok
	assign cls to-do null
	#print 2@ #out 2!	;

: printer_off
	assign prompt to-do ok
	assign cls to-do (cls)
	#default #out 2!	;

: printer_close
	#print 2@ close		;

