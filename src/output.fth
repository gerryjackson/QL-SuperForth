( FORTH 83 Cross compiler -  Output words )

( Last modified:   9 November 1986 )

: pad   (pad) @      ;

: here   dp @   ;
 
: count
   dup 1+ swap c@   ;
 
: type
   dup 0>
   if
     >r
     7 #out 2@ r> trap3
     dup ?error
   then
   2drop      ;

: message            -- version with messages outside dictionary
   #out 2@ rot       -- ( n1 --- id n1 )
   .message          -- (   --- n2 )
   dup ?error   ;
   

-- : message               -- version with internal messages
--   2* message_vecs + @   -- read address of desired message
--   count type   ;

: emit   emit_var c! emit_var 1 type ;

: cr   ten emit   ;

: space   bl emit      ;
 
: spaces
   begin
     dup 0>
   while
     space 1-
   repeat
   drop   ;

: hold   -1 hld +! hld @ c!   ;

x: print_num
   over - spaces
   type      ; 

x: hold_ascii
   dup 9 >
   if 7 + then
   48 + hold   ;
 
x: pad_top
   pad 84 +   ;

: <#   pad_top hld !   ;

: #>   2drop hld @
   pad_top over -   ;

: sign   0<
   if 45 hold then   ;

: #   base @ m/mod
   rot hold_ascii   ;

: #s   begin
     # 2dup d0=
   until      ;

: d.r   >r swap over dabs
   <# #s rot sign
   #> r> print_num   ;

: d.   0 d.r space   ;
 
: u.   0 d.   ;

: .r   >r dup abs 0 <#
   begin
     base @ um/mod
     swap hold_ascii 0
     over 0=
   until
   rot sign
   #> r> print_num   ;

: .   0 .r space   ;
 
: ?   @ .   ;

: u.r
   0 swap d.r   ;

: decimal
   ten base ! ;

: hex   16 base ! ;

: h.   base @ swap
   hex u.
   base !      ;
 
x: dec.
   base @ decimal
   swap u.
   base !      ;

: -trailing
   dup 0>
   if
     begin
       1- 2dup + c@ bl -
       over 0< or
     until
     1+
   then   ;

: (cls)
   1 bl #out 2@ 1 trap3
   dup ?error 2drop   ;

exvec: cls   assign cls to-do (cls)

