-- FORTH 83 Cross compiler -   File and block handling

-- Last modified:   21 October 1986

forth_address {2constant}
] jump_to_does 2@ exit [      -- run time code for 2constants

-1 -1 2constant #default
here 4 - default_id !      -- save address for patching at end

buf_size constant b/buf

64 constant c/l

16 constant l/b

xvariable mess_flag   -1 here 2- !

variable drive   1 here 2- !

variable #file            -- really a 2variable
-1 here 2- ! -1 ,

x: bkbuf
   buf_ad @   ;

x: mark_block_valid
   1 bkbuf c!
   bkbuf 2+   ;

xvariable device
   8 here 2- !                   -- the string length
   102 c, 108 c, 112 c, 49 c,    -- flp1
    95 c,  66 c,  76 c, 75 c,    -- _blk

x: set_drive
   device 2+  2! drive !   ;

x: here+64
   here 64 +
   1+ -2 and   ;

x: save_drive
   48 +
   here+64
   five + c!      ;

x: generate_name
   device            ( device is a string 'flp1_blk' )
   here+64 ten cmove
   drive @ save_drive
   base @ decimal
   bkbuf 2- @ 0
   <# #s #>
   dup here+64 +!
   here+64 ten +
   swap cmove
   base !      ;

x: absolute_pad
   nil 2@ here+64
   nil - 0 d+   ;

x: call_?error
   dup ?error   ;
 
x: (del)
   absolute_pad 0 four trap2   ;

x: (delete)
   (del) dup -7 <>
   if call_?error 0 then
   3drop      ;

x: (open)
   absolute_pad
   rot 1 trap2   ;

x: (close)
   0 2 trap2   ;

: close
   (close) call_?error 2drop   ;

x: read_write
   bkbuf 2+ swap
   2over b/buf
   trap3 >r 2drop
   close r> call_?error   ;

x: write_block
   generate_name
   (delete)
   2 (open) call_?error
   73 read_write   ;

x: read_block
   generate_name
   0 (open) dup -7 =
   if
     device 2+ @
     [ hex 4d44 decimal ] literal
     =
     if
       3drop 3
       drive @ - save_drive
       0 (open)
     then
   then
   call_?error
   72 read_write   ;

: empty-buffers
   0 bkbuf c!   ;

: save-buffers
   bkbuf c@ 2 =
   if write_block then
   1 bkbuf c!   ;

x: buf   save-buffers
   empty-buffers
   bkbuf 2- !
   bkbuf 2+   ;

: buffer
   buf b/buf bl fill 
   mark_block_valid
   0 over b/buf + !   ;

x: mess13
   -1 mess_flag !   ;

x: message13
   mess_flag @ mess13
   if
     cr 13 message dup dec.
   then      ;

: block
   bkbuf c@
   if
     bkbuf 2- @ over =
     if drop bkbuf 2+ exit then
   then
   message13
   buf drop read_block
   mark_block_valid   ;

: update
   2 bkbuf c!   ;

: list
   0 mess_flag !
   dup block mess13 swap
   dup scr !
   cr cls 11 message
   . cr l/b 0
   do
     dup c/l
     -trailing cr type
     c/l +
   loop
   cr drop      ;

x: move_here+64
   0 here+64 !
   here+64 1+ over
   c@ 1+ cmove>   ;
 
: flush
   save-buffers empty-buffers   ;

-- more file handling at end of interpreter.fth

