( Forth Cross compiler - Floating point extensions -  Master calling file )

( Last modified:	11 November 1986 )

LOWER

cls 3 1 csize cr .(       CROSS COMPILING) cr cr 0 0 csize

only forth definitions

: xc ;				( For FORGETting )

: --	#tib @ >in !		( Rest of input line is a comment )
	;	immediate	-- For example, this is a comment

2variable #inc   -1 -1 #inc 2!		-- Holds included file channel ID
variable finished 0 finished !		-- Boolean, indicates cross
					-- compilation is complete

: X_error
	only forth definitions
	>r				-- Save error number
	assign error to-do drop
	end_file #inc 2@ close		-- Close open files
	assign error to-do (error)
	sp! r>				-- Restore error number
	(error)		;

assign error to-do X_error


-- Some definitions to include other files

: inc_error				-- To detect end of included file
	only forth definitions		-- Back to forth vocabulary
	dup -10 =
	if
	  drop #file 2@ #in 2!		-- Restore input stream to this file
	  #inc 2@ close			-- Close included file
	  assign error to-do X_error
	  -1 finished !			-- To leave X_interpreter
	else
	  assign error to-do (error)	-- Other error, so report it and stop
	  error
	then		;

: include
	0 open 2dup #in 2!		-- Open included file and switch input
	#inc 2!				-- Remember for later closure
	assign error to-do inc_error	-- To detect end of included file
	;

: close_files			-- Development aid when errors occur
	assign error to-do drop
	#inc 2@ close
	end_file
	assign error to-do (error)	;

20 string target_name			-- For output file name
target_name read" flp1_forth_fp_image"
0 target_name 1- c!			-- For QDOS


cr cr .( Loading X_host_fth )		include flp1_X_host_fth
cr cr .( Loading X_hostfp_fth )		include flp1_X_hostfp_fth
cr cr .( Loading primitives:  )		target_include flp1_prim_fp_obj
cr cr .( Loading X_decl_fth:  )		cross_compile  flp1_X_decl_fth
cr cr .( Loading X_errors_fth:  )	cross_compile  flp1_X_errors_fth
cr cr .( Loading X_maths_fth:  )	cross_compile  flp1_X_maths_fth
cr cr .( Loading X_output_fth:  )	cross_compile  flp1_X_output_fth
cr cr .( Loading X_input_fth:  )	cross_compile  flp1_X_input_fth
cr cr .( Loading X_files_fth:  )	cross_compile  flp1_X_files_fth
cr cr .( Loading X_dict_fth:  )		cross_compile  flp1_X_dict_fth
cr cr .( Loading X_definers_fth:  )	cross_compile  flp1_X_definers_fth
cr cr .( Loading X_inter_fth:  )	cross_compile  flp1_X_inter_fth
cr cr .( Loading X_control_fth:  )	cross_compile  flp1_X_control_fth
cr cr .( Loading X_strings_fth:  )	cross_compile  flp1_X_strings_fth
cr cr .( Loading X_QDOS_fth:  )		cross_compile  flp1_X_QDOS_fth
cr cr .( Loading X_tasking_fth:  )	cross_compile  flp1_X_tasking_fth
cr cr .( Loading X_fpmaths_fth:  )	cross_compile  flp1_X_fpmaths_fth

include flp1_X_finish_fth

end_file

