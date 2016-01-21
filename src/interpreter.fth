-- FORTH 83 Cross compiler -  Interpreter words

-- Modification record:

-- 13/11/86   RENAME definition added

x: cdot   
   [ here 2- load_{(.")} ]   
   (.") type   ;

: ."   ?comp $" word
   compile cdot
   c@ 1+ allot
   dp_even   ;   immediate
 
: .(   41 word
   count type   ;   immediate
 
: .s   cr ." ( ==>  "
   depth 0>
   if
     0 depth 2-
     do i pick . -1 +loop
   then
   ."  ) top" cr   ;

: interpret
   begin
     bl word dup c@ 0=
     if 
       blk  @ if ?exec then
       drop exit
     then
     context_seek not_nil
     if
       2+ c@ 64 and state @ 0= or
       if execute else , then
     else
       drop number dpl @ 1+
       if
         state @
         if swap [compile] literal then
       else
         drop
       then
       [compile] literal
     then
     ?stack
   0 until      ;  -2 allot

: load
   blk @ >r blk !
   >in @ >r 0 >in !
   interpret
   r> >in !
   r> blk !   ;

x: set_#0
   #default #in  2!
   #default #out 2!   ;

: ok   state @ 0=
   if
     ."  ok"
   then
   cr   ;

exvec: prompt  assign prompt to-do ok

: quit   set_#0
   [compile] [ cr
   begin
   (rp!) query
   interpret prompt
   0 until      ;  -2 allot

: (error)
   set_#0
   here 2+ count type
   ."  ? " cr
   dup 0<
   if
     load_d0 #out 2@ 2dup
     [ hex cc decimal ] literal
     vec_ut 3drop quit
   then
   message quit   ;   -2 allot

assign error to-do (error)

x: p_error         -- for primitive detected errors
   [ here prim_error ! ]
   error ;

: (abort)
   sp! quit  ;  -2 allot
  
exvec: abort   assign abort to-do (abort)

: cold
   [ here cold_forth ! ]         -- save address for patching
   -32768                        -- to be patched with forth latest
   [ (forth) @ ] literal !       -- patch vocabulary pointer
   [ here cold_only  ! ]         -- save address for patching
   -32768                        -- to be patched with only latest
   [ (only)  @ ] literal !       -- patch vocabulary pointer
   [ cold_users @ ] literal      -- from
   [ user_area @  ] literal      -- to
   [ number_users @ ] literal    -- number
   cmove                         -- load cold start user values
   -1 [ ' timeout >body ] literal ! -- ensure trap3 timeout is -1
   sp! (rp!)
   0 here 2+ !                   -- to avoid a mess if an error
   assign prompt to-do ok
   assign error  to-do (error)
   assign abort  to-do (abort)
   assign cls    to-do (cls)
   set_#0 cls empty-buffers
   1 load
   cls cr   12 message
   quit   ;   -2 allot

x: forth_message
   cls 15 message
   quit   ;   -2 allot

: forget
   bl word latest seek
   not_nil ?found drop
   swap fence @ < 9 ?error
   context @ over >
   over current @ < or
   if
     only forth definitions
     cr 22 message
   then
   >r xq_link snip
   begin
     dup 2- dup @
     r@ >
     if
       (xq_error) swap ! 0
     then
     drop @ dup nil = 
   until
   drop
   voc_link snip
   begin
     dup four -
     begin
       @ dup r@ <
     until
     over four - !
     @ dup nil =
   until
   drop r> dp !   ;

: (
   41 word drop   ;   immediate

: -->
   blk @
   if
     0 >in !
     1 blk +!
   then      ;   immediate

: thru
   1+ swap
   do i load loop   ;

x: save_name
   bl word
   move_here+64   ;

: open
   save_name (open)
   call_?error   ;

: delete
   save_name (delete) ;

: null      ;

: end_file
   assign error to-do (error)
   #default #in 2!
   -1 key_input !
   assign prompt to-do ok
   #file 2@ close      ;

x: load_error
   end_file error   ;

: load_file
   0 open 2dup
   #file 2!
   #in 2!
   0 key_input !
   assign error x_to-do load_error  -- load_error is headerless
   assign prompt to-do null   ;

: open_device
   move_here+64
   (open) call_?error ;

: rename             -- eg  rename file1 file2 ; file2 is the new name
   0 open 2dup       -- (--- id id )
   1 allot           -- to get word aligned string length
   bl word
   0 here ! -1 allot -- ensure ms byte of length is zero
   dup c@ 0=
   if 8 error then   -- ( --- id id ad1 )
   1- 74 2swap 0     -- ( --- id ad1-1 n1 id 0 )
   trap3 dup ?error  -- ( --- id n3 n4 )
   2drop close   ;

: delete_file
   move_here+64
   (delete)   ;

x: (status)
   (open) >r (close)
   3drop r> dup 0=
   if (del) 3drop then   ;

: status
   2 save_name (status)   ;

: device_status
   2 swap move_here+64 (status)   ;


