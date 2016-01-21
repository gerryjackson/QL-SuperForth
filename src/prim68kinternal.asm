*	FORTH Cross compiler -  Internal machine specific primitives
*
*	Last modified:	12 November 1986
*
*
trap1		code	'TRAP1',trap1_end		TRAP1
		bra	trap1_ext
trap1_end
*
trap2		code	'TRAP2',trap2_end		TRAP2
		bra	trap2_ext
trap2_end
*
trap3		code	'TRAP3',trap3_end		TRAP3
		bra	trap3_ext
trap3_end
*
trap3_star	code	'TRAP3*',trap3_star_end		TRAP3*
		move.l	(dsp)+,d1
		bra	trap3_ext
trap3_star_end
*
utility
		code	'VEC_UT',load_d0_end		VEC_UT
		bra	utility_ext
*
dot_message	no_head					.MESSAGE
		bra	dot_mess_ext
dot_mess_end
*
load_d0		no_head					LOAD_D0
		bra	load_d0_ext
load_d0_end
*
		code	'COMPARE',compare_end		COMPARE
compare		bra	compare_ext
compare_end
*
		code	'FS_LOAD',job_skel_end		FS_LOAD
fs_load		bra	fs_load_ext
*
call_mt		no_head					CALL_MAN_TRAP
		bra	call_mt_ext
*
load_job	no_head					LOAD_JOB
		bra	load_job_ext
*
job_skel	no_head					JOB_SKELETON
		move.w	tos,-(dsp)		Leaves the FORTH address of
		move.w	cp,tos			the tasks code on the stack
		addi.w	#jsc-job_skel,tos
		bra.s	nextz
*
* JOB_SKELETON	is the initial code for a new job, it is transferred into
*		the job's header by LOAD_JOB
*
jsc
job_skel_code	lea	js_end(pc),a0		a0--> start of job's registers
		movem.l	(a0),a2-a5		Load registers
nextz		move.w	(ip)+,cp		NEXT sequence, spelled out like
		movea.w	0(base,cp.w),a0		this to ensure debugging NEXT
		jmp	0(base,a0)		is not used inadvertently
js_end
*
job_skel_end
*
		code	'ALLOCATE',allocate_end	Allocate heap space
		bra	alloc_ext
allocate_end
*
		code	'DEALLOCATE',dealloc_end	Release common heap
		bra	dealloc_ext
dealloc_end
*

