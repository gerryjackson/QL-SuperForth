( Forth 83 Cross Compiler -  dictionary handling words )

( Last modified:   21 October 1986 )

xvariable u/lcase  bl here 2- !

: upper     0 u/lcase ! ;         ( upper case only )

: lower    bl u/lcase ! ;         ( lower case also )

: word
   dup bl = dup
   if 
     drop bl
   then
   tib #tib @ blk @
   if 
     2drop blk @ block b/buf
   then
   over >r over + swap
   >in @ +
   (word)
   r> - >in !
   here 2+ 2dup c!
   1+ 2dup + bl swap c!
   swap cmove
   here 2+         ;

: allot dp +!   ;
 
x: dp_even
   0 here c!
   here 1 and allot   ;

: ,   here 2 allot !   ;

: compile
   ?comp
   (compile) ,   ;
 
: rp!   compile (rp!)   ;

x: compile_cfa
   -2 allot (compile) ,   ;

: latest
   current @ @ ;

: id.   2+
   begin
     1+ dup c@ 127
     2dup and emit >
   until
   drop   ;

x: not_nil
   dup nil <> ;

: seek
   u/lcase @
   if word_to_upper then
   not_nil
   if (seek) then      ;
   
 
x: context_seek         ( searches all context vocabularies )
   dup u/lcase @
   if word_to_upper then
   ten 0 do
      drop context i + @
      not_nil
      if
        @ (seek) not_nil
        if leave then
      then
      2 +loop   ;

: literal
   state @
   if
     (literal) (literal) , ,
   then      ;   immediate

: c,   here 1 allot c!   ;

: '   bl word context_seek
   nil =
   if drop eight error then   ;

x: snip
   dup
   begin
     @ r> r> r@
     rot rot >r >r over >
   until
   over ! @   ;

forth_address {vocabulary}

] jump_to_does context ! exit [     -- run time code for vocabulary

vocabulary forth
   [ here 6 - target_address        -- save parameter field address
     (forth) !                      -- of forth

: recurse
   ?comp latest link> ,   ;

: find   context_seek not_nil
   if
     2+ c@ 64 and
     0= 2* 1+ exit
   then
   drop 0      ;


: >link   >name 2-   ;

: >body           -- compilation address to parameter field
   2+   ;

: body>           -- parameter field to compilation address
   2-   ;

: name>           -- name field to compilation address
   2- link> ;

: n>link          -- name field to link field
   2-   ;

: l>name          -- link field to name field )
   2+   ;

x: (;code)
   [ here 2- load_{(;code)} ]
   {;code},  latest link> !   ;


vocabulary only
   here 6 - target_address          -- save parameter field address
   (only) !                         -- of only
   here target_address here 8 - !   -- point only code pointer here
   ] jump_to_does                   -- the does> code for only
   eight 0 do
         nil i context + !          -- clears top 8 words of context
     2 +loop
   dup context !
   context eight + !
   exit   [

: definitions
   context @ current !   ;

: also   context dup 2+
   6 cmove>   ;

: previous                 -- removes top context vocabulary from search order
   context dup 2+ swap
   6 cmove                 -- slide next 3 vocabularies up 2 bytes
   nil context 6 + !  ;    -- ensure last is empty

: order   cr 26 message
   context ten over + swap
   do
     i @ not_nil
     if
       dup 2- >link id. space
     then
     drop 2
   +loop
   cr 27 message
   current @ 2-
   >link id.   ;

: seal   [ (only) @ ] literal
   ten 0
   do
     context i + @ over =
     if
       nil context i + !
     then
     2
   +loop
   drop      ;

: words
   cr context @ @
   begin
     eight 0
     do
       not_nil 0=
       if leave then
        dup id. 2 spaces @
     loop
     cr not_nil 0=
   until
   drop    ;

: immediate 
   latest 2+ dup c@
   64 or swap c!   ;

: [compile]
   ?comp '
   ?found ,   ;   immediate

: [']
   ?comp '
   [compile] literal  ;   immediate

: blank
   bl fill      ;

: erase
   0 fill      ;


