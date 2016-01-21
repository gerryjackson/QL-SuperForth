-- FORTH 83 Cross compiler -  Error handling

-- Last modified:   21 October 1986

forth_address {exvec:}           -- load address into {exvec:}

] jump_to_does @ execute exit [  -- does> code for execution vectors

forth_address {xq_error}         -- must be loaded with address of (error)
                                 -- later, for now it allows error to be created
                                 -- (error) cannot be created yet, it uses quit

exvec: error      -- note error has not been assigned to anything yet

: ?error
   swap
   if
     error exit
   then
   drop       ;
 
: ?exec
   state @ 2 ?error   ;

: ?found
   dup 0= eight ?error      ;

: ?comp
   state @ 0= 1 ?error   ;

x: ?csp
   sp@ csp @ -
   four ?error      ;

: ?stack
   depth 0<
   if
     sp! 6 error
   then
   depth max_depth @ >
   7 ?error      ;

x: ?pairs
   - 3 ?error   ;

x: ?loading
   blk @ 0= five ?error   ;
 
