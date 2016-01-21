--	FORTH 83 Cross Compiler -  Re-order dictionary and save compiled code

--	Last modified:	11 November 1986

cr cr .( Re-ordering words in dictionary ... )

re_order immediate not .r allot word s->d --> j
re_order m/mod abs um/mod */ */mod
re_order 2constant 2variable 2over 2rot 2swap d+ d- d. d.r d0= d< dabs
re_order d= dmax dmin dnegate du< roll find fill or and xor pick pad c,
re_order forth [compile] [ ] literal negate ? 2* 2/ does> um* u.
re_order u> constant variable / mod +loop /mod 1- 2- cmove 2@ 2!
re_order <> >= <= create -2 -1 3 2 1 0
re_order hex decimal spaces space count type max min 2drop 2dup
re_order r@ * ( ." , here i cr c! c@ u< until repeat while begin
re_order ?dup 2+ 1+ +! . 0< 0= 0> < > = rot loop do else then if r> >r @
re_order ! - + over swap drop dup ; : forth-83


-- Now link ONLY vocabulary words into their own vocabulary

only_word seal
only_word words
only_word order
only_word vocabulary
only_word forget
only_word definitions
only_word also
only_word forth
only_word only

patch_target			-- Patch various target addresses

cr cr .( Saving image file ...  )
sexec_target			-- and save target image
