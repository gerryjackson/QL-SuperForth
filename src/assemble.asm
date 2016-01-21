*       FORTH Cross Compiler -  Assembler calling file
*
*       For the standard system
*
*       Last modified:  10 November 1986
*
*
                include prim68ka.asm            Declarations
start
                include QLentry.asm             QL specific addresses
                include prim68kb.asm            Code addresses
zero
                include primqlexternal.asm      External QL code
                include prim68kc.asm_c          The standard code primitives
                include primqlinternal.asm      Internal QL code
code_size
*
                end_code
*
                end

