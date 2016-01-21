( FORTH 83 Cross compiler -  Control structure definitions )

( Last modified      21 October 1986 )

: >mark   ?comp here 0 ,   ;

: >resolve
   ?comp here over -
   swap !   ;

: <mark   ?comp here   ;

: <resolve
   ?comp here - ,   ;

: if   compile ?branch >mark 1   ;   immediate

: else   1 ?pairs compile branch
   >mark
   >r >resolve r> 1   ;   immediate

: then   1 ?pairs >resolve   ;   immediate

: abort"
   ?comp
   [compile] if
   compile cr
   [compile] ."
   compile abort
   [compile] then   ;   immediate

: begin   <mark 2      ;   immediate

: until   2 ?pairs
   compile ?branch
   <resolve   ;   immediate

: while   [compile] if 2+   ;   immediate

: repeat
   >r >r 2 ?pairs
   compile branch
   <resolve
   r> r> 2- [compile] then   ;   immediate

: do   do_list @ nil do_list !
   compile (do) <mark -1   ;   immediate

x: resolve_leaves
   -1 ?pairs <resolve
   do_list @
   begin
     dup nil <>
   while
     dup @ swap
     >resolve
   repeat
   drop do_list !   ;

: loop   compile (loop)
   resolve_leaves   ;   immediate

: +loop   compile (+loop)
   resolve_leaves   ;   immediate

: leave
   compile (leave)
   do_list @
   here do_list ! ,   ;   immediate

: case   ?comp
   csp @ csp! four   ;  immediate

x: test_equal
   over = dup
   if swap drop then ;

: of   four ?pairs
   compile test_equal
   compile ?branch
   >mark five      ;  immediate

: endof
   five ?pairs
   compile branch >mark
   swap 1
   [compile] then four   ;  immediate

: default
   ?comp compile drop ;   immediate

: endcase
   four ?pairs
   begin
     sp@ csp @ -
   while
     1 [compile] then
   repeat
   csp !      ;  immediate

