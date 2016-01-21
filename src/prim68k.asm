*	FORTH 83 Source code
*	====================
*
*	Copyright G.W.Jackson 1986
*
*	Last modified:	10 November 1986
*
* This file contains the code primitives for a 68000 family based FORTH 83
* system, which is to  be used by a FORTH cross compiler, although it may
* be used for an assembled version. The intention is to put all the
* machine independent primitives in this file and to put machine specific
* primitives for I/O etc into another file.
*
*	Assembly flag
debug		equ	1		Clear when debugging
*
* Register names
*
tos		equr	d7		The top of stack
tos.w		equr	d7
tos.l		equr	d7
cp		equr	d6		Code pointer after next
cp.w		equr	d6
up		equr	a2		User pointer
up.w		equr	a2
ip		equr	a3		Interpretive pointer
base		equr	a4		Mid dictionary pointer
dsp		equr	a5		Data stack pointer
rsp		equr	a7		Return stack pointer
*
*
* d0 to d5, a0, a1 & a6 are available for general use, keep a6=0 if possible
* d6 is usually only used in VARIABLE etc.
*
*
* constants
*
code_marker	equ	1		Marks start of a code header
no_code_marker	equ	2		Start of a no code header
no_head_marker	equ	3		Start of a no header section of code
nil		equ	-32768
*
*
* macros
*
next		macro			Fetches and executes the next
		ifne	debug           Forth word
		move.w	(ip)+,cp
		movea.w	0(base,cp.w),a0
		jmp	0(base,a0.w)
		endc
		ifeq	debug		Debug version jumps to common routine
		bra	debug_next
		endc
		endm
*
*
code		macro			Creates a header
		dc.w	code_marker	Marks the start of a word
		dc.b	se\@-*-1	Gives the string length
		dc.b	\1		The primitive's name
se\@
		even			Pads to an even address
		dc.w	\2-*-2		Gives the code length
		endm
*
no_code		macro			For words sharing code with others
		dc.w	no_code_marker
		dc.b	ncse\@-*-1	String length
		dc.b	\1		The name
ncse\@
		even
		dc.w	\2-dictionary+nil	The code pointer (rel to base)
		endm
*
no_head		macro				For headerless code words
		dc.w	*+2-dictionary+nil      Points to next address
		endm
*
odd		set 0			A bodge to get this stupid assembler
*					to accept the conditional in the
* 					next macro
*
space_if_odd	macro			Conditionally inserts a space if the
odd		set	(*-start)&1	pc is an odd address
		ifne	odd		If address is odd ...
		  dc.b	' '		... insert a space to make it even
		endc
		endm
*
place_word	macro			DC.B's a word as 2 bytes, address odd
		dc.b	(\1)>>8&255		ms byte
		dc.b	(\1)&255		ls byte
		endm
*
code_address	macro			Generates data about headerless words
		dc.b	'code_address '
		dc.b	\1,' '				The word name
		place_word \2-dictionary+nil		The code position
		dc.b	10				New line
		endm
*
code_offset	macro			For origin and target start
		dc.b	'code_address '
		dc.b	\1,' '
		place_word \2-zero
		dc.b	10
		endm
*
mess_ad		macro			Deposits the offset to a message
		dc.w	message\1-*	in the message vector table
		endm
*
string_b	macro			Deposits a string with
		dc.b	sb\@-*-1	length in a byte
		dc.b	\1
sb\@
		endm
*
str_b_nl	macro			Like string_b plus a new line
		dc.b	sbnl\@-*-1
		dc.b	\1
		dc.b	10
sbnl\@
		endm
*
end_code	macro
		dc.w	0		Must be placed at end of the code
		endm
*
