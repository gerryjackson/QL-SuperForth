( Forth Cross compiler - Master calling file )

( Last modified:   11 November 1986 )

LOWER

cls 3 1 csize cr .(       Cross Compiling) cr cr 0 0 csize

only forth definitions

: xc ;            ( For FORGETting )

: --   #tib @ >in !     ( Rest of input line is a comment )
   ;   immediate        -- For example, this is a comment

2variable #inc   -1 -1 #inc 2!      -- Holds included file channel ID
variable finished 0 finished !      -- Boolean, indicates cross
                                    -- compilation is complete

: x_error
   only forth definitions
   >r                            -- Save error number
   assign error to-do drop
   end_file #inc 2@ close        -- Close open files
   assign error to-do (error)
   sp! r>                        -- Restore error number
   (error)      ;

assign error to-do x_error


-- Some definitions to include other files

: inc_error                      -- To detect end of included file
   only forth definitions        -- Back to forth vocabulary
   dup -10 =
   if
     drop #file 2@ #in 2!        -- Restore input stream to this file
     #inc 2@ close               -- Close included file
     assign error to-do X_error
     -1 finished !               -- To leave X_interpreter
   else
     assign error to-do (error)  -- Other error, so report it and stop
     error
   then      ;

: include
   0 open 2dup #in 2!            -- Open included file and switch input
   #inc 2!                       -- Remember for later closure
   assign error to-do inc_error  -- To detect end of included file
   ;

: close_files                    -- Development aid when errors occur
   assign error to-do drop
   #inc 2@ close
   end_file
   assign error to-do (error)   ;

20 string target_name            -- For output file name
target_name read" forth_image"
0 target_name 1- c!              -- For QDOS


cr cr .( Loading host.fth)     include host.fth
cr cr .( Loading primitives)   target_include primitives.obj
cr cr .( Loading decl.fth)     cross_compile  declarations.fth
cr cr .( Loading errors.fth)   cross_compile  errors.fth
cr cr .( Loading maths.fth)    cross_compile  arithmetic.fth
cr cr .( Loading output.fth)   cross_compile  output.fth
cr cr .( Loading input.fth)    cross_compile  input.fth
cr cr .( Loading files.fth)    cross_compile  files.fth
cr cr .( Loading dict.fth)     cross_compile  dictionary.fth
cr cr .( Loading definers.fth) cross_compile  definers.fth
cr cr .( Loading inter.fth)    cross_compile  interpreter.fth
cr cr .( Loading control.fth)  cross_compile  control.fth
cr cr .( Loading strings.fth)  cross_compile  strings.fth
cr cr .( Loading qdos.fth)     cross_compile  qdos.fth
cr cr .( Loading tasking.fth)  cross_compile  tasking.fth

include finish.fth

end_file
