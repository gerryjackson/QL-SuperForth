*	FORTH Cross Compiler -  Assembler calling file
*
*	For the standard system
*
*	Last modified:	10 November 1986
*
*
		include	flp1_prim68k_asm_a	Declarations
start
		include flp1_QLentries_asm	QL specific addresses
		include flp1_prim68k_asm_b	Code addresses
zero
		include flp1_primQLext_asm	External QL code
		include	flp1_prim68k_asm_c	The standard code primitives
		include	flp1_primQLint_asm	Internal QL code
code_size
*
		end_code
*
		end

