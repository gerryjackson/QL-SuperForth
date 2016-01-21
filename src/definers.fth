-- FORTH 83 Cross compiler -  Defining words

-- Last modified:      21 October 1986

x: csp!   sp@ csp !   ;

: smudge
   latest 2+ c@ 32 xor
   latest 2+ c!      ;

: create
   dp_even bl word
   context_seek not_nil
   if
     cr ten message
     dup id.
   then
   2drop here latest ,
   current @ !
   here c@ 31 min dup 128 or
   here c! allot
   here c@ 128 or c, dp_even
   (variable) ,      ;

: does>
   compile (;code)
   (jump_to_does)
   literal , literal ,   ;   immediate

: [   0 state !   ;   immediate

: ]   -1 state !   ;

: :   ?exec csp!
   current @ context !
   create smudge
   compile_cfa (:)
   ]      ;
 
: ;   ?csp compile (;)
   smudge [compile] [   ;   immediate

: constant
   create compile_cfa (constant)
   ,      ;

: 2constant
   create
     , ,
   does>
     2@   ;

: variable
   create 0 ,   ;

: 2variable
   variable 0 ,   ;

x: link_in
   , dup @ here
   rot ! ,      ;

: vocabulary
   create
     nil ,
     voc_link
     [ hex 81a0 decimal ] literal
     link_in
   does>
     context ! ;

x: xq_error
   [ here 2- load_{xq_error} ]
   14 error   ;

: exvec:
   ?exec
   create
     xq_link [host'] xq_error
     link_in
   does>
     @ execute   ;

: assign
   ' ?found 2+   ;   immediate

: to-do
   ' ?found state @
        if
     [compile] literal
     [compile] literal
     compile !
        else
     swap !
   then      ;   immediate

: forth-83 [compile] forth   ;


