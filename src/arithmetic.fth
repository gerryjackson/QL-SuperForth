( FORTH 83 Cross compiler -  Arithmetic definitions )

( Last modified:  19 October 1986 )

: mod /mod drop   ;

: /   /mod swap drop ;
 
: */  */mod swap drop   ;

: dabs   dup 0<
   if dnegate then   ;

: 2rot
   >r >r 2swap
   r> r> 2swap ;

: d=
   d- d0=      ;

x: 2discard
   if 2swap then
   2drop    ;

: dmin
   2over 2over d< not
   2discard ;

: dmax
   2over 2over d<
   2discard ;


