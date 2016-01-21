*               FORTH 83  Machine dependent code (QL)
*               =====================================
*
*       Last modified:  15 November 1986
*
* Contains all the machine dependent primitives, initialisation etc for the
* FORTH cross compiler
*
return_stack_size       equ     512
data_stack_size         equ     256
*
io.sstrg        equ     $07
ut.con          equ     $C6
mt.alchp        equ     $18
mt.rechp        equ     $19
*
* Entry point and initialisation
*
                bra.s   entry
                dc.b    '01.0'
                dc.w    $4AFB,12
                dc.b    'FORTH 83 1.0'
*
*
entry           lea     window,a1       a1 --> window parameter list
                move.w  ut.con\w,a0
                jsr     (a0)            Open a console window
*
                lea     -return_stack_size(a7),dsp
*                                       Load data stack pointer
*                                       a7 is return stack pointer
                lea     dictionary,a1   a1 --> start of FORTH dictionary
                move.l  a1,(a1)+        Save absolute dictionary address
                lea     32764(a1),base  base --> mid dictionary
                move.l  a6,(a1)+        Save task start address
                movea.w (a1)+,up        up --> user variables (FORTH address)
                movea.w (a1)+,ip        ip --> cold start (Forth address)
                adda.l  base,ip         Make ip absolute
                move.w  (a1)+,d0        d0 --> #DEFAULT
                move.l  a0,0(base,d0.w) Save channel ID
                addq.l  #2,a1           Skip over timeout address
*
                movea.w (a1)+,a0        a0 --> Cold start user values
                adda.l  base,a0
                move.l  dsp,(a0)+       Save data stack pointer
                move.l  rsp,(a0)        Save return stack pointer
*
                moveq   #0,tos          Make top of stack := 0
                next                    Start executing COLD
*
window          dc.b    0,0,0,4         Window parameters
                dc.w    512,256,0,0     The whole screen
*
*
trap1_ext       move.w  (dsp)+,d0               TRAP1
                ext.l   d0
                move.l  (dsp)+,d1
                movem.l a2-a4,-(a7)
                lea     0(base,tos.w),a3
                trap    #1
                movem.l (a7)+,a2/a3/a4
                move.l  d1,-(dsp)
                move.w  d2,tos
                andi.w  #$FF,tos
nexta           
                next
*
trap2_ext       movem.l a2/a3,-(a7)             TRAP2
                moveq   #-1,d1
                move.w  tos,d0
                ext.l   d0
                move.w  (dsp)+,d3
                ext.l   d3
                movea.l (dsp)+,a0
                trap    #2
                move.w  d0,tos
                move.l  a0,-(dsp)
                movem.l (a7)+,a2/a3
                bra.s   nexta
*
trap3_ext       moveq   #0,d0                   TRAP3
                movea.l (dsp)+,a0
                movem.w (dsp)+,d0/a1
                move.w  timeout,d3              d3 --> timeout pfa
                move.w  0(base,d3.w),d3         d3 :=  timeout value
                moveq   #0,d2
                move.w  tos,d2
                adda.l  base,a1
                trap    #3
                suba.l  base,a1
                move.w  a1,-(dsp)
                move.w  d1,-(dsp)
                move.w  d0,tos
                bra.s   nexta
*
utility_ext     movem.l a2/a3,-(a7)             VEC_UT
                move.l  (dsp)+,d1
                move.l  (dsp)+,a0
                move.w  (dsp)+,a1
                adda.l  base,a1
                suba.l  a6,a6
                move.w  tos,a2
                move.w  (a2),a2
                moveq   #0,d7
                jsr     (a2)
                move.l  a0,-(dsp)
                move.w  d0,tos
                movem.l (a7)+,a2/a3
                bra.s   nextb
*
dot_mess_ext    lea     message_addresses,a1    .MESSAGE   (ID n1 --- n2)
                move.w  tos,d0                  n2 is error code
                lsl.w   #1,d0                   d0 := message_num * 2
                cmpi.w  #max_mess,d0            In range?
                bls.s   num_in_range
                moveq   #max_mess,d0            No, print top message
num_in_range    adda.w  d0,a1                   a1 --> message offset
                adda.w  (a1),a1                 a1 --> message
                moveq   #0,d2
                move.b  (a1)+,d2                d2 := message length
                moveq   #-1,d3
                movea.l (dsp)+,a0               a0 := channel ID
                moveq   #io.sstrg,d0
                trap    #3
                move.w  d0,tos                  Error code
                bra.s   nextb
*
load_d0_ext     move.w  tos,d0                  LOAD_D0
                ext.l   d0
                bra.s   nextb           
*               
compare_ext     move.l  a3,-(rsp)               COMPARE
                moveq   #0,d0
                move.w  (dsp)+,a1
                move.w  (dsp)+,a0
                subq.w  #1,a0
                subq.w  #1,a1
                move.l  base,a6
                move.b  0(base,a0.w),d1
                move.b  0(base,a1.w),d3
                move.b  d0,0(base,a0.w)
                move.b  d0,0(base,a1.w)
                move.w  tos,d0
                move.w  $E6,a3
                jsr     (a3)
                move.w  d0,tos
                move.b  d1,0(base,a0.w)
                move.b  d3,0(base,a1.w)
                movea.l (rsp)+,a3
nextb
                next
*
*       Multi-tasking primitives
*       ========================
*
call_mt_ext     moveq   #0,d0                   * CALL_MAN_TRAP external  code
                move.w  tos,d0
                movem.l (dsp)+,d1/d2/d3
                movem.l a2/a3,-(rsp)
                suba.l  a1,a1
                trap    #$01
                movem.l (rsp)+,a2/a3
                movem.l d1/a0,-(dsp)
                move.w  d0,tos
                bra.s   nextb
*
* LOAD_JOB      ( ad1 rs ds job_ad ad2 ad3 --- ad1 )
*                       ad1 = FORTH address of User area, 0 if none
*                       rs  = return stack size in long words (includes a7 stack)
*                       ds  = data stack size in words
*                    job_ad = absolute job address
*                       ad2 = FORTH address of job's FORTH code
*                       ad3 = Job skeleton FORTH address 
*
load_job_ext    lea     0(base,tos.w),a0        a0 --> Job skeleton
                move.w  (dsp)+,d3               (COULD DO THIS DIRECTLY!!)
                ext.l   d3
                add.l   base,d3                 d3 --> job's FORTH code
                movea.l (dsp)+,a1               a1 --> job header
                moveq   #8,d2
ld_job1         move.w  (a0)+,(a1)+             Transfer 9 words of code from
                dbf     d2,ld_job1              job skeleton to job header
                move.w  4(dsp),d2               d2 --> Own Users or none
                beq.s   no_users                Branch if none
                ext.l   d2
                move.l  d2,(a1)+                Save User address for job's up
                bra.s   ld_job2
no_users        move.l  up,(a1)+                Save current up for job's up
ld_job2         move.l  d3,(a1)+                Save for job's ip
                move.l  base,(a1)+              Save for job's base
                moveq   #4,d3                   d3 := size rest of register area
                moveq   #0,d1
                move.w  (dsp)+,d1               d1 := data stack size (.w)
                moveq   #0,d0
                move.w  (dsp)+,d0               d0 := return stack size (.l)
                add.w   d1,d3
                add.w   d1,d3                   Add data stack bytes to d3
                add.l   a1,d3                   d3 := data stack base
                lsl.w   #2,d0                   d0 := return stack size in bytes
                add.l   d3,d0                   d0 := return stack base
                move.l  d3,(a1)+                Save d3 for job's dsp
*               move.l  d0,(a1)+                Not needed, rsp(=a7) is ok
                tst.w   d2                      Any User's ?
                beq.s   ld_job3                 Exit if not
                lea     0(base,d2.w),a0         a0 --> User area absolute
                move.l  d3,(a0)+                Load job's S0
                move.l  d0,(a0)+                Load job's R0
                move.w  d1,(a0)+                Load job's max_depth
ld_job3         move.w  (dsp)+,tos              Pop tos
                bra.s   nextc
*
*
* FS_LOAD       Used, in particular, to load a job into RAM. Calls TRAP 3
*               with d0 = $48.
*               ( ad1 ID n1 --- n2 )
*                       ad1 = absolute address for loading
*                       ID  = channel ID
*                       n1  = file length
*                       n2  = trap number
*                       n3  = error code
*               
fs_load_ext     moveq   #0,d0
                move.w  tos,d0                  d0 := trap number
                movem.l a2/a3,-(rsp)            For safety!
                movem.l (a3)+,d2/a0/a1          Load registers
                moveq   #-1,d3                  Timeout
                trap    #3
                move.w  d0,tos                  Error code
                movem.l (rsp)+,a2/a3
nextc
                next
*
alloc_ext       move.w  tos,-(dsp)              ALLOCATE (da db --- dad n1)
                movem.l (dsp)+,d1/d2            da = Job ID
                movem.l a2/a3,-(rsp)            db = no. bytes needed
                moveq   #mt.alchp,d0            dad = base address
                trap    #1                      n1 = error code
                movem.l (rsp)+,a2/a3
                move.l  a0,-(dsp)
                move.w  d0,tos
                bra.s   nextc
*
dealloc_ext     move.w  tos,-(dsp)              DEALLOCATE (dad --- )
                movea.l (dsp)+,a0               dad = base address of area
                movem.l a2/a3,-(rsp)
                moveq   #mt.rechp,d0
                trap    #1
                movem.l (rsp)+,a2/a3
                move.w  (dsp)+,tos              No error return
                bra.s   nextc     
*

