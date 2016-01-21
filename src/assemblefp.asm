*       FORTH Cross Compiler -  Assembler calling file
*
*       For the standard system with floating point extensions
*
*       Last modified:  10 November 1986
*
*
                include prim68ka.asm            Declarations
start
                include QLentries.asm           QL specific addresses
                include QLfpentry.asm           QL floating addresses
                include prim68kb.asm            Code addresses
zero
                include primqlexternal.asm      External QL code
                include prim68kc.asm            The standard code primitives
                include primqlinternal.asm      Internal QL code
                include primqlfp.asm            Internal QL floating code
code_size
*
                end_code
*
                end

