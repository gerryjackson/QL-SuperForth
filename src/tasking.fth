--	FORTH 83 Cross compiler -  Multi-tasking definitions

--		Last modified:	21 October 1986


: man_trap
	call_man_trap
	dup ?error
	2drop 2drop	;

: freeze			( d n --- )
	s->d 2swap 2dup
	eight man_trap	;

: suspend_me			( n ---   )
	-1 -1 rot freeze	;

: suspend			( n ---   )
	' >body 2@ rot freeze	;

: unfreeze			( d ---   )
	2dup 2dup 9 man_trap	;

: release			(   ---   )
	' >body 2@ unfreeze	;

: priority			( d n --- )
	127 min 0 2over
	11 man_trap	;

: priority_of			( n   --- )
	' >body 2@ rot
	priority	;

: activate			( d1 d2 n  --- )
	127 min 0 2swap
	ten man_trap	;

: start				( d n --- )
	' >body 2@ rot
	activate	;

: sleep
	2dup 0 0 -1 -1
	11 man_trap	;


-- These next must be used before job if any of the areas are needed,
-- any of the last three also need user variables

: own_users			(    --- ad )
	here [ cold_users   @ ] literal
	here [ number_users @ ] literal
	dup allot cmove		;

: own_pad			( ad --- ad )
	here 84 allot over
	[ pad_offset @ ] literal + !	;

: own_tib			( ad --- ad )
	here 88 allot over
	[ tib_offset @ ] literal + !	;

: own_buf			( ad --- ad )
	here 2+ 1030 allot over
	[ buf_ad_offset @ ] literal + !	;

x: create_job
	over 2* 2*
	over 2* +
	100 +
	0 38 0 -1 -1 1 call_man_trap
        dup ?error	;

: job
	create >r create_job
	  , , 2dup , ,
	  r> 127 min ,
	  here 2+ job_skeleton
	  load_job ,
	does>
	  >r 0 0 r@
	  eight + @ r> 2@ rot
	  activate	;

: runs
	' , ['] sleep ,		;

-- for example,  n1 n2 n3 job fred runs mary
--		n1 = return stack size
--		n2 = data stack size
--		n3 = priority
-- will create and load a job in the transient area
-- To activate the job, type fred

-- To exec an existing job from microdrive

2variable #mdv
2variable job_id

: exec
	0 open #mdv 2!
	pad 71 #mdv 2@ 16 trap3
	dup ?error 2drop
	pad 6 + 2@ pad 2@ -1 -1
	1 call_man_trap
	dup ?error
	job_id 2!
	#mdv 2@
	pad 2@ 72 fs_load
	dup ?error
	0 0 1 0 job_id 2@
	ten call_man_trap
	dup ?error
	2drop 2drop #mdv 2@ close	;

: remove			( d ---   )
	2dup 2dup  five man_trap	;

: bye				(   ---   )
	-1 -1 remove	;

: kill				(   ---   )
	' >body 2@ remove	;

: ?job_id			                (   --- d )
	' >body 2@	;

