( FORTH 83 Cross compiler -   String handling )

( Last modified:   21 October 1986 )

x: check_size
   dup 255 u>
   if 24 error then   ;

: string
   check_size
   create
     dup c, 0 c,
     allot dp_even
   does>
     1+      ;

: input
   dup 1+ dup 2-
   c@ expect span @
   swap c!      ;

x: move_it
   dup 1+ over c@ 1+
   dup 1+ allot
   cmove> dp_even   ;

: read"
   $" word state @
   if
     compile (read")
     move_it exit
   then
   2dup c@ swap 1- c@ >
   if 23 error then
   swap over c@ 1+ cmove   ;   immediate

: length c@   ;       -- put this into code file

: max_len
   1- c@   ;

: str_array
   check_size
   create
     swap dup , 0
     do
       dup c, 0 c,
       dup allot dp_even
     loop
     drop
   does>
     2dup @ u< 0=
     if 25 error then
     2+ swap over c@
     2+ 1+ -2 and
     * + 1+   ;

: clear
   0 swap c!   ;

: ins/del
   rot >r swap 1 max
   r@ 1- c@ min
   1- swap dup 0<
   if
     negate over 1+ r@ +
     2dup + swap over
     r@ - r@ c@ 1+
     swap - 0 max cmove
     r@ c@ swap - max
     r@ c@ min r> c!
     exit
   then
     2dup + over r@ c@ +
     r@ 1- c@ min
     dup r@ c! swap -
     r> swap >r
     rot 1+ + swap over +
     r> 0 max cmove>   ;

x: check_pars
   dup 0<
   >r over 0= >r
   over 3 pick c@ 1+ u>
   r> or r> or
   if 25 error then
    2 pick    ;

x: make_space
   check_pars 2dup
   c@ + swap 1- c@ >
   if 23 error then
   ins/del ;

x: check_pars2
   2dup + >r
   check_pars c@ 1+ r> <
   if 25 error then   ;

: lose
   check_pars2
   negate ins/del   ;

x: (insert)
   >r over max_len over - 1+
   r> min >r
   + swap 1+ swap r>
   cmove>   ;

: insert
   2dup four pick
   c@ dup >r make_space r>
        (insert)   ;
   
: ins_char
   2dup 1 make_space
   over max_len over <
   if 3drop exit then
   + c! ;

: app_char
   dup c@ 1+ ins_char   ;

: append
   dup c@ 1+ insert   ;

: slice
   2dup 1- c@ >
   if 23 error then
   >r check_pars2 >r + r>
   r@ 1- c@ min
   r> 2dup c!
   1+ swap cmove   ;

: take   >r
   2 pick 2 pick 2 pick
   r> slice lose   ;

x: check_pos
   over max_len over < >r
   over c@ over u<
   over 0= or r> or   ;

: char   check_pos
   if 25 error then
   + c@      ;

: take_char
   2dup char
   >r 1 lose r>   ;

: replace
   dup 0> 0= >r
   over c@ over - 1+
   3 pick c@ <
   r> or
   if 25 error then
   2 pick c@
   (insert)   ;

: repl_char
   check_pos
   if 25 error 3drop exit then
   + c!   ;

: unused
   dup max_len
   swap c@ -
   0 max   ;

: $=   2 compare 0=   ;

: $==   3 compare 0=   ;

: $<   2 compare 0<   ;

: $>   2 compare 0>   ;

: c==   up_char swap
   up_char =   ;

: str_const
   create
     -1 >in +!
     $" word drop
     -2 allot $" word
     2 allot move_it
   does>
     1+      ;

