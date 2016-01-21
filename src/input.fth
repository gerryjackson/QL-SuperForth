-- FORTH 83 Cross compiler -  Input words

-- Last modified:   19 October 1986 )

xvariable key_input  -- true for keyboard input
-1 here 2- !         -- preset to true

: tib   (tib) @      ;

x: move_cursor
   nil swap #in 2@ 0 trap3    -- nil is convenient and irrelevant
   3drop      ;
 
: expect
   dup 0>
   if
     >r 2 #in 2@ r> trap3
     dup -5 <>
     if
       dup ?error 1- 0
     then
     drop
   else
     drop 0
   then
   span ! drop
   key_input @
   if
     19 move_cursor
     20 move_cursor space
   then      ;
 
: query
   tib tib_length expect
   0 >in !
   0 blk !
   span @ #tib !   ;
 
: convert
   begin
     1+ dup >r c@ base @ digit
   while
     swap base @ um* drop
     rot base @ um* d+ dpl @ 1+
     if 1 dpl +! then
     r>
   repeat
   r>      ;

: number
   0 0 rot
   dup 1+ c@ 45 =
   dup >r - -1
   begin
     dpl ! convert dup c@ bl >
   while
     1 dpl @ 0<
     if drop dup c@ 46 - then
     if 3drop 0 error then
     0
   repeat
   drop r>
   if dnegate then      ;

: key
   tib 1 #in 2@ 1 trap3
   dup ?error swap drop
   255 and      ;

