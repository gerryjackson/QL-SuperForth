-- FORTH 83 Cross compiler -  Floating Point Maths

-- Last modified:   10 November 1986

: frot
   f>r fswap fr> fswap ;

: fconstant
   2constant , does> f@ ;

: fvariable
   2variable 0 , ;

: f0=   or or 0= ;

: f0<   drop swap drop 0< ;

: f0>   drop swap drop 0> ;

x: fpr   3 * 2 + 3 0 ;

: fpick
   fpr
   do
     >r r@ pick r>
   loop
   drop   ;

: froll
   fpr
   do
     >r r@ roll r>
   loop
   drop   ;

forth_address {flop}
] jump_to_does @ float_op dup ?error exit [   -- Run time code for FLOP


 2 flop f->s     4 flop int    6 flop f->d
 8 flop s->f    10 flop f+   12 flop f-
14 flop f*      16 flop f/   18 flop fabs
20 flop fnegate 24 flop cos   26 flop sin
28 flop tan     30 flop cot   32 flop arcsin
34 flop arccos  36 flop arctan   38 flop arccot
40 flop sqrt    42 flop ln   44 flop log10
46 flop exp     48 flop ^

: f<   f- f0<   ;    -- These could be made quicker
                     -- by not using F-
: f>   f- f0>   ;

: f=   f- f0=   ;

: f.
   pad 240 float_convert
   drop pad swap pad -
   type space   ;

: f$   bl word 1+ 256 float_convert
   dup ?error drop      ;

x: f65536
   0 16384 2065   ;  -- Leaves floating 65536 on the stack
                     -- Redefine later as a floating constant

: d->f
   >r s->f fdup f0<
   if f65536 f+ then
   r> s->f f65536 f* f+ ;
