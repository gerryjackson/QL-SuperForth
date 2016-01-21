*	FORTH Cross Compiler
*
*	Addresses of various code words whose compilation addresses are needed
*	by the FORTH cross compiler
*
*	Last modified:	10 November 1986
*
		code_address	<'{branch}'>,branch_pf-2
		code_address	<'{?branch}'>,qbranch-2
		code_address	<'{do}'>,do,
		code_address	<'{loop}'>,loop
		code_address	<'{+loop}'>,ploop
		code_address	<'{leave}'>,leave
		code_address	<'{rp!}'>,rp_store
		code_address	<'{constant}'>,constant
		code_address	<'{word}'>,word
		code_address	<'{create}'>,variable
		code_address	<'{user}'>,user
		code_address	<'{digit}'>,digit
		code_address	<'{literal}'>,literal
		code_address	<'{compile}'>,compile
		code_address	<'{."}'>,print_string
		code_address	<'{;code}'>,semicolon_code
		code_address	<'{:}'>,colon
		code_address	<'{;}'>,exit-2
		code_address	<'{!}'>,store-2
*
		code_address	<'{does}'>,does
		code_address	<'{word_to_upper}'>,word_to_upper
		code_address	<'{read"}'>,read_quote
		code_address	<'{up_char}'>,up_char-2
		code_address	<'{loc_char}'>,loc_char-2
		code_address	<'{locate}'>,locate-2
		code_address	<'{seek}'>,seek
*
		code_offset	<'origin'>,dictionary
*
		dc.b	'load_target_start',10
*
		space_if_odd
		dc.b	'load_does_jump {jump_to_does} '	Note, must be an
		jmp	does-dictionary+nil(base)	even number of characters
		dc.b	10
*
		space_if_odd
		dc.b	'load_code',10		Loads the following code until
*						a zero marker is read, note the
*						even number of bytes here.
*
*
*	Next 2 words are read only
		dc.w	no_head_marker		Marks large block of code
		dc.w	no_head_end-zero	Size of code block
*
