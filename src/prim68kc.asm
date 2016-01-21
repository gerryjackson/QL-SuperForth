*       FORTH Cross Compiler -  Main primitive file
*
*       Last modified:  12 November 1986
*
*       Table of offsets to messages
*
message_addresses
mess_bot        mess_ad 0
                mess_ad 1
                mess_ad 2
                mess_ad 3
                mess_ad 4
                mess_ad 5
                mess_ad 6
                mess_ad 7
                mess_ad 8
                mess_ad 9
                mess_ad 10
                mess_ad 11
                mess_ad 12
                mess_ad 13
                mess_ad 14
                mess_ad 15
                mess_ad 16
                mess_ad 17
                mess_ad 18
                mess_ad 19
                mess_ad 20
                mess_ad 21
                mess_ad 22
                mess_ad 23
                mess_ad 24
                mess_ad 25
                mess_ad 26
                mess_ad 27
                mess_ad 28
                mess_ad 29
mess_top
*
max_mess        equ     mess_top-mess_bot-2
*
*       Error and other messages
*
message0        string_b        <'Name not found'>
message1        string_b        <'Compilation mode only'>
message2        string_b        <'Execution mode only'>
message3        string_b        <'Control structure error'>
message4        string_b        <'Stack mis-match in definition'>
message5        string_b        <'Use only when LOADing'>
message6        string_b        <'Stack empty'>
message7        string_b        <'Stack full'>
message8        string_b        <'Not found'>
message9        string_b        <'In protected dictionary'>
message10       string_b        <'     Redefining: '>
message11       string_b        <'  Block '>
message12       str_b_nl        <'     FORTH 83  version 1.0 '>
message13       string_b        <'  Reading block '>
message14       string_b        <'Unassigned execution vector'>
message15       string_b        <'FORTH 83 Copyright 1986 G.W.Jackson'>
message16       string_b        <'Division by 0'>
message17       string_b        <'Division overflow'>
message18       string_b        <'ROLL parameter negative'>
message19       string_b        <'ROLL beyond stack'>
message20       string_b        <'PICK parameter negative'>
message21       string_b        <'PICK beyond stack'>
message22       string_b        <'Now in FORTH vocabulary'>
message23       string_b        <'String too long'>
message24       string_b        <'String size too big'>
message25       string_b        <'String index out of range'>
message26       string_b        <'Search:   '>
message27       string_b        <'Compile:  '>
message28       str_b_nl        <' ?'>
message29       string_b        <'Message number out of range'>
*
* Note that the last message MUST be 'Message number out of range'
*
*
debug_next
                ifeq    debug                   Common next routine for
                move.w  (ip)+,cp                debugging purposes
                movea.w 0(base,cp.w),a0
                jmp     0(base,a0.w)
                endc              
*
pick_ext        tst.w   tos                     PICK
                blt.s   pick1
                lsl.w   #1,tos
                andi.l  #$FFFF,tos
                lea     2(dsp,tos.l),a0
                cmpa.l  0(base,up.w),a0
                bge.s   pick2
                move.w  -2(a0),tos
                bra.s   next8
pick1           moveq   #20,tos
                bra.s   roll_error
pick2           moveq   #21,tos
                bra.s   roll_error
*
roll_ext        tst.w   tos                     ROLL
                blt.s   roll1
                addq.w  #1,tos
                lsl.w   #1,tos
                andi.l  #$7FFF,tos
                movea.l dsp,a0
                adda.l  tos,a0
                cmpa.l  0(base,up.w),a0
                bge.s   roll5
                move.w  -2(a0),-(dsp)
                bra.s   roll3
roll2           move.w  -4(a0),-(a0)
roll3           subq.w  #2,tos
                bgt.s   roll2
                move.w  (dsp)+,tos
                addq.l  #2,dsp
                bra.s   next8
roll1           move.w  #18,tos
roll_error      movea.w error,ip        Point IP to FORTH code which
                adda.l  base,ip         calls ERROR
                bra.s   next8
roll5           move.w  #19,tos
                bra.s   roll_error
*
cmove_ext       move.w  (dsp)+,a0               CMOVE
                adda.l  base,a0
                move.w  (dsp)+,a1
                adda.l  base,a1
                andi.l  #$FFFF,tos
                bra.s   cmove1
cmove2          move.b  (a1)+,(a0)+             Consider 2 alternatives
cmove1          subq.l  #1,tos                  (a) use dbra
                bge.s   cmove2                  (b) testing for even addresses
cmove3          move.w  (dsp)+,tos                  and using move.l
next8
                next
*
cmove_up_ext    move.w  (dsp)+,a0               CMOVE>
                adda.l  base,a0
                move.w  (dsp)+,a1
                adda.l  base,a1
                andi.l  #$FFFF,tos
                adda.l  tos,a0
                adda.l  tos,a1
                bra.s   cmove_up1
cmove_up2       move.b  -(a1),-(a0)
cmove_up1       subq.l  #1,tos
                bge.s   cmove_up2
                bra.s   cmove3
*
fill_ext        moveq   #0,d0                   FILL
                move.w  (dsp)+,d0
                move.w  (dsp)+,a0
                adda.l  base,a0
                bra.s   fill1
fill2           move.b  tos,(a0)+               Consider using dbra
fill1           subq.l  #1,d0
                bge.s   fill2
                bra.s   cmove3
*
seek_ext        cmpi.w  #$8000,tos              SEEK
                beq.s   next8           Exit early if at end of vocabulary
                movea.w (dsp),a0
                adda.l  base,a0
                move.l  a0,d1
                movea.w tos,a1
seek1           adda.l  base,a1
                movea.l d1,a0
                move.l  a1,d0
                addq.l  #2,a1
                move.b  (a1)+,tos
                andi.b  #$3F,tos
                cmpi.b  #$1F,tos
                bgt.s   seek4
                cmp.b   (a0)+,tos
                bne.s   seek4
seek2           move.b  (a1)+,tos
                bpl.s   seek3
                andi.b  #$7F,tos
                cmp.b   (a0)+,tos
                beq.s   seek5
                bra.s   seek4
seek3           cmp.b   (a0)+,tos
                beq.s   seek2
seek4           movea.l d0,a1
                move.w  (a1),d0
                movea.w d0,a1
                cmpi.w  #$8000,d0
                bne.s   seek1
                move.w  d0,tos          Set tos to nil, indicates not found
                bra.s   next8
seek5           sub.l   base,d0
                suba.l  base,a1
                move.w  a1,tos
                addq.w  #1,tos          Ensure tos is even
                bclr    #0,tos
                move.w  tos,(dsp)
                move.w  d0,tos
                bra.s   next9
*
cfa_ext         lea     3(base,tos.w),a0        LINK>
cfa1            tst.b   (a0)+
                bge.s   cfa1
                suba.l  base,a0
                move.w  a0,tos
                addq.w  #1,tos          Ensure tos is even
                bclr    #0,tos
                bra.s   next9
*
word_ext        move.w  tos,a0                  (WORD)
                adda.l  base,a0
                move.w  (dsp)+,a1
                adda.l  base,a1
                movem.w (dsp)+,d0/d1
                moveq   #0,d3
word1           cmpa.l  a0,a1
                ble.s   word9
                move.b  (a0)+,tos
                beq.s   word4
                cmp.b   tos,d1
                beq.s   word1
                cmp.b   #191,tos
                bhi.s   word1
                cmp.b   d0,tos
                bcs.s   word1
                subq.l  #1,a0
                suba.l  base,a0
                move.w  a0,-(dsp)
                adda.l  base,a0
                bra.s   word8
word2           addq.b  #1,d3
word8           cmpa.l  a0,a1
                ble.s   word5
                move.b  (a0)+,tos
                beq.s   word3
                cmpi.b  #192,tos
                bcc.s   word5                   bcc = bhs
                cmp.b   d0,tos
                bcs.s   word5
word7           cmp.b   tos,d1
                bne.s   word2
word5           andi.b  #$FF,d3
                suba.l  base,a0
word6           move.w  d3,-(dsp)
                move.w  a0,tos
next9
                next
word3           subq.l  #1,a0
                bra.s   word5
word4           subq.l  #1,a0
word9           suba.l  base,a0
                move.w  a0,-(dsp)
                bra.s   word6
*
digit_ext       move.w  tos,d0                  (DIGIT)
                move.w  (dsp)+,d1
                moveq   #0,tos
                subi.b  #$30,d1
                bmi.s   next9
                cmpi.b  #$0A,d1
                bmi.s   digit0
                cmpi.b  #$11,d1
                bmi.s   next9
                cmpi.b  #$4D,d1
                bpl.s   next9
                subi.b  #7,d1
digit0          cmp.b   d0,d1
                bge.s   next9
                move.w  d1,-(dsp)
                subq.w  #1,tos
                bra.s   next9
*
print_str_ext   move.w  tos,-(dsp)              Used by (.")
                moveq   #0,tos
                movea.l (rsp),a0
                move.b  (a0)+,tos
                suba.l  base,a0
                move.w  a0,-(dsp)
                move.l  tos,d0
                addq.w  #2,d0
                bclr    #0,d0
                add.l   d0,(rsp)
                bra.s   next9
*
up_char_ext     cmpi.w  #96,tos                 UP_CHAR
                ble.s   next12
                cmpi.w  #122,tos
                bgt.s   next12
                subi.w  #32,tos
                bra.s   next12
*
loc_char_ext    move.w  tos,d0                  LOC_CHAR
                beq.s   case_dep1
                move.w  #32,d0
case_dep1       movem.w (dsp)+,a0/a1/d7
                lea     -2(dsp),a1
                moveq   #1,d1
                bra.s   loc1
* 
locate_ext      move.w  tos,d0                  LOCATE
                beq.s   case_dep
                move.w  #32,d0
case_dep        movem.w (dsp)+,a0/a1/d7
                adda.l  base,a1
                moveq   #0,d1
                move.b  (a1),d1
                beq.s   not_found
loc1            tst.w   tos
                ble.s   not_found
                adda.l  base,a0
                moveq   #1,d2
                moveq   #0,d3
                moveq   #0,d4
                move.b  (a0),d3
                cmp.w   tos,d3
                blt.s   not_found
* 
try_again       move.b  0(a0,tos.w),d4
                move.w  d4,d5
                sub.b   0(a1,d2.w),d4
                beq.s   are_equal
                tst.w   d0
                bne.s   test_case
not_equal       sub.w   d2,tos
                addq.w  #2,tos
                moveq   #1,d2
* 
test_done       cmp.w   tos,d3
                blt.s   is_done
                cmp.w   d2,d1
                bge.s   try_again
* 
found           sub.w   d1,tos
                bra.s   next12
are_equal       addq.w  #1,d2
                addq.w  #1,tos
                bra.s   test_done
* 
is_done         cmp.w   d2,d1
                blt.s   found
not_found       moveq   #0,tos
next12
                next
 
test_case       cmp.b   d0,d4
                beq.s   test_low
                cmpi.b  #-32,d4
                bne.s   not_equal
                cmpi.b  #65,d5
                blt.s   not_equal
                cmpi.b  #90,d5
                bgt.s   not_equal
                bra.s   are_equal
* 
test_low        cmpi.b  #97,d5
                blt.s   not_equal
                cmpi.b  #122,d5
                bgt.s   not_equal
                bra.s   are_equal
* 
read_quote_ext  move.w  tos,-(dsp)       Run time code for READ"
                move.l  ip,tos
                sub.l   base,tos
                addq.w  #1,tos
                moveq   #0,d3
                move.b  (ip),d3
                addq.w  #3,d3
                andi.b  #$FE,d3
                adda.l  d3,ip
                bra.s   next13
* 
word_to_upper_ext
                move.w  (dsp),a0        Converts word to upper case
                adda.l  base,a0
                moveq   #0,d0
                move.b  (a0)+,d0
                move.b  #32,d3
                bra.s   test_end
next_char       move.b  (a0)+,d1
                cmp.b   #97,d1
                blt.s   test_end
                cmp.b   #122,d1
                bgt.s   test_end
                sub.b   d3,-1(a0)
test_end        dbra    d0,next_char
next13
                next
* 
to_name_ext     lea     -1(base,tos.w),a0       >name
                tst.b   (a0)
                blt.s   at_name_end
                subq.l  #1,a0
at_name_end     tst.b   -(a0)
                bge.s   at_name_end
                suba.l  base,a0
                move.w  a0,tos
                bra.s   next13
*
acmove_ext      move.w  tos,-(dsp)              ACMOVE  n is double number
                movem.l (dsp)+,d0/a0/a1         a0 := destination
                bra.s   acmove2                 a6 := source
acmove1         move.b  (a1)+,(a0)+
acmove2         subq.l  #1,d0
                bge.s   acmove1
acmove3         move.w  (dsp)+,tos
                next
*
acmoveup_ext    move.w  tos,-(dsp)              ACMOVE>
                movem.l (dsp)+,d0/a0/a1
                adda.l  d0,a0
                adda.l  d0,a1
                bra.s   acmoveup2
acmoveup1       move.b  -(a1),-(a0)
acmoveup2       subq.l  #1,d0
                bge.s   acmoveup1
                bra.s   acmove3
*
**********************************************************
*
*       True FORTH dictionary starts here
*
*
dictionary      dc.l    0       Absolute start address of FORTH dictionary
task_start      dc.l    0       Absolute start address of FORTH task
user_vars       dc.w    -32768  FORTH address of user variables (for up)
cold_pfa        dc.w    -32768  FORTH address of COLD parameter field
default_id      dc.w    -32768  FORTH address of #DEFAULT
timeout         dc.w    -1      Time out value for QDOS calls
user_cold       dc.w    0       FORTH address of cold start values
error           dc.w    -32768  FORTH address of FORTH code 'ERROR EXIT' for
*                               machine code detected errors eg divide by zero
*
*
seek            no_head                         {SEEK}
                bra     seek_ext
seek_end
*
word            no_head                         (WORD)
                bra     word_ext
word_end
*
constant        move.w  tos,-(dsp)              (CONSTANT)
                move.w  2(base,cp.w),tos
                next
const_end
*
variable        move.w  tos,-(dsp)              (VARIABLE)
                move.w  cp,tos
                addq.w  #2,tos
                next
var_end
*
user            move.w  tos,-(dsp)              (USER)
                move.w  up,tos
                add.w   2(base,cp.w),tos
                next
user_end
*
does            move.w  tos,-(dsp)              (DOES)
                move.w  cp,tos
                addq.w  #2,tos
                addq.w  #2,a0                   a0 used in 'next'
                move.w  a0,cp
colon           move.l  ip,-(rsp)               (:)
                lea     2(base,cp.w),ip
next6
                next
does_end
*
digit           no_head                         (DIGIT)
                bra     digit_ext
digit_end
*
literal         no_head                         (LITERAL)
                move.w  tos,-(dsp)
                move.w  (ip)+,tos
                next
lit_end
*
compile         no_head                         (COMPILE)
                move.w  tos,-(dsp)
                move.l  (rsp),a0
                move.w  (a0),tos
                addq.l  #2,(rsp)
                bra.s   next6
comp_end
*
print_string    no_head                         ((.")) used by (.")
                bra     print_str_ext
prstr_end
*
semicolon_code  no_head                         ((;CODE)) used by (;CODE)
                move.w  tos,-(dsp)
                movea.l (rsp)+,a0
                suba.l  base,a0
                move.w  a0,tos
                bra.s   next6
semi_end
*
word_to_upper   no_head                         {word_to_upper} converts a
                bra     word_to_upper_ext       word to upper case
word_to_up_end
*
read_quote      no_head                         {read"} run time code
                bra     read_quote_ext
read_quote_end
*
rp_store        no_head                         (RP!)
                movea.l 4(base,up.w),rsp
                bra.s   next14
rpst_end
*
do              no_head                         (DO)
                move.w  #$8000,d0
                sub.w   (dsp)+,d0
                add.w   d0,tos
                move.w  d0,-(rsp)
                move.w  tos,-(rsp)
                move.w  (dsp)+,tos
                bra.s   next14
do_end
*
loop            no_head                         (LOOP)
                addq.w  #1,(rsp)
                bvc.s   branch
lp1             addq.l  #2,ip
                addq.l  #4,rsp
next14
                next
loop_end
*
ploop           no_head                         (+LOOP)
                add.w   tos,(rsp)
                bvc.s   br2
                move.w  (dsp)+,tos
                bra.s   lp1
ploop_end
*
leave           no_head                         (LEAVE)
                addq.l  #4,rsp
                bra.s   branch
leave_end
*
no_head_end
*
                no_code 'BRANCH',branch         BRANCH
branch_pf
*
                code    '?BRANCH',qbra_end      ?BRANCH
qbranch         tst.w   tos
                bne.s   br1
br2             move.w  (dsp)+,tos
branch          adda.w  (ip),ip
                next
br1             move.w  (dsp)+,tos
                addq.l  #2,ip
                bra.s   next14
qbra_end
*
                code    '0>',gt0_end            0>
gt0             tst.w   tos
                bgt.s   true
                bra.s   false
gt0_end
*
                code    '0=',eq0_end            0=
eq0             tst.w   tos
                beq.s   true
                bra.s   false
eq0_end
*
                code    <'0<'>,lt0_end          0<
lt0             tst.w   tos
                blt.s   true
                bra.s   false
lt0_end
*
                code    '>=',ge_end             >=
ge              cmp.w   (dsp)+,tos
                ble.s   true
                bra.s   false
ge_end
*
                code    <'<='>,le_end           <=
le              cmp.w   (dsp)+,tos
                bge.s   true
                bra.s   false
le_end
*
                code    '>',gt_end              >
gt              cmp.w   (dsp)+,tos
                blt.s   true
false           moveq   #0,tos
                next
gt_end
                code    <'<'>,lt_end            <
lt              cmp.w   (dsp)+,tos
                bgt.s   true
                bra.s   false
lt_end
*
                code    '=',eq_end              =
eq              cmp.w   (dsp)+,tos
deq0_cont       bne.s   false
true            moveq   #-1,tos
                next
eq_end
*
                code    'D0=',deq0_end          D0=
deq0            or.w    (dsp)+,tos
                bra.s   deq0_cont
deq0_end
*
                code    '<<>>',ne_end           <>      A bodge to get
ne              cmp.w   (dsp)+,tos                      asm to accept <>
                beq.s   false
                bra.s   true
ne_end
*
                code    <'U<'>,ult_end          U<
ult             cmp.w   (dsp)+,tos
                bhi.s   true
                bra.s   false
ult_end
*
                code    'U>',ugt_end            U>
ugt             cmp.w   (dsp)+,tos
                bcs.s   true
                bra.s   false
ugt_end
*
                code    <'DU<'>,dult_end        DU<
dult            bsr.s   dsub
                bhi.s   false
                bra.s   true
dult_end
*
                code    <'D<'>,dlt_end          D<
dlt             bsr.s   dsub
                blt.s   true
                bra.s   false
dlt_end
*
                code    'D-',dminus_end         D-
dminus          bsr.s   dsub
                bra.s   dpush
*
dsub            swap    tos                     Double length subtract s/r
                move.w  (dsp)+,tos
                sub.l   (dsp)+,tos
                neg.l   tos
                rts
dminus_end
*
                code    'D+',dplus_end          D+
dplus           swap    tos
                move.w  (dsp)+,tos
                add.l   (dsp)+,tos
dpush           move.w  tos,-(dsp)
                swap    tos
                bra.s   next1
dplus_end
*
                no_code '+',addition            +
*
                code    '-',sub_end
subtract        neg.w   tos                     -
addition        add.w   (dsp)+,tos
                next
sub_end
*
                code    'MAX',max_end           MAX
max             sub.w   (dsp),tos
                bge.s   addition
                bra.s   drop
max_end
*
                code    'MIN',min_end           MIN
min             sub.w   (dsp),tos
                blt.s   addition
                bra.s   drop
min_end
*
                code    'DROP',drop_end         DROP
drop            move.w  (dsp)+,tos
                next
drop_end
*
                code    '1+',plus1_end          1+
plus1           addq.w  #1,tos
next1
                next
plus1_end
*
                code    '2+',plus2_end          2+
plus2           addq.w  #2,tos
                bra.s   next1
plus2_end
*
                code    '1-',sub1_end           1-
sub1            subq.w  #1,tos
                bra.s   next1
sub1_end
*
                code    '2-',sub2_end           2-
sub2            subq.w  #2,tos
                bra.s   next1
sub2_end
*
                code    '+!',plst_end           +!
plus_store      btst    #0,tos
                bne.s   ps1
                move.w  (dsp)+,d0
                add.w   d0,0(base,tos.w)
                move.w  (dsp)+,tos
                bra.s   next2
ps1             lea     2(base,tos.w),a0
                move.b  (dsp)+,d0               d0 := ms byte
                move.b  (dsp),d1                d1 := ls byte
                add.b   d1,-(a0)
                addx.b  -(dsp),-(a0)
                move.l  (dsp)+,tos
                bra.s   next2
plst_end
*
                no_code 'NEGATE',negate         NEGATE
*
                code    'ABS',abs_end           ABS
abs             tst.w   tos
                bgt.s   next2
negate          neg.w   tos
                bra.s   next2
abs_end
*
                code    'DNEGATE',dneg_end      DNEGATE
dnegate         neg.w   (dsp)
                negx.w  tos
                bra.s   next2
dneg_end
*
                no_code 'DUP',dup               DUP
*
                code    '?DUP',qdup_end         ?DUP
qdup            tst.w   tos
                beq.s   next2
dup             move.w  tos,-(dsp)
next2
                next
qdup_end
*
                code    'AND',and_end           AND
and_x           and.w   (dsp)+,tos
                bra.s   next2
and_end
*
                code    'OR',or_end             OR
or_x            or.w    (dsp)+,tos
                bra.s   next2
or_end
*
                code    'XOR',xor_end           XOR
xor             eor.w   tos,(dsp)
                move.w  (dsp)+,tos
                bra.s   next2
xor_end
*
                code    'NOT',not_end           NOT
not_x           not.w   tos
                bra.s   next2
not_end
*
                code    'PICK',pick_end         PICK
pick            bra     pick_ext
pick_end
*
                code    'ROLL',roll_end         ROLL
roll            bra     roll_ext
roll_end
*
                code    'C@',cat_end            C@
cat             move.b  0(base,tos.w),tos
                andi.w  #$FF,tos
                next
cat_end
*
                code    '@',at_end              @
at              btst    #0,tos
                bne.s   at1
                move.w  0(base,tos.w),tos
                next
at1             lea     2(base,tos.w),a0
at2             move.b  -(a0),-(dsp)
                move.b  -(a0),-(dsp)
                bra.s   pop
at_end
*
                code    '2@',tat_end            2@
tat             btst    #0,tos
                bne.s   tat1
                move.w  2(base,tos.w),-(dsp)
                move.w  0(base,tos.w),tos
                bra.s   next3
tat1            lea     4(base,tos.w),a0
tat2            move.b  -(a0),-(dsp)
                move.b  -(a0),-(dsp)
                bra.s   at2
tat_end
*
                code    'AC@',ac_at_end         AC@
ac_at           move.w  tos,-(dsp)
                movea.l (dsp)+,a0
                moveq   #0,tos
                move.b  (a0),tos
                bra.s   next3
ac_at_end
*
                code    'A@',a_at_end           A@
a_at            move.w  tos,-(dsp)
                movea.l (dsp)+,a0
                addq.l  #2,a0
                bra.s   at2
a_at_end
*
                code    'A2@',a2_at_end         A2@
a2_at           move.w  tos,-(dsp)
                movea.l (dsp)+,a0
                addq.l  #4,a0
                bra.s   tat2
a2_at_end
*
                code    'C!',cst_end            C!
cstore          move.w  (dsp)+,d0
                move.b  d0,0(base,tos.w)
                move.w  (dsp)+,tos
next3
                next
cst_end
*
                code    '!',st_end              !
store           move.b  (dsp)+,0(base,tos.w)
                move.b  (dsp)+,1(base,tos.w)
pop             move.w  (dsp)+,tos
                next
st_end
*
                code    '2!',tst_end            2!
tstore          lea     0(base,tos.w),a0
a2_st_cont      move.b  (dsp)+,(a0)+
                move.b  (dsp)+,(a0)+
a_st_cont       move.b  (dsp)+,(a0)+
ac_st_cont      move.b  (dsp)+,(a0)
                bra.s   pop
tst_end
*
                code    'A!',a_store_end        A!
a_store         move.w  tos,-(dsp)
                movea.l (dsp)+,a0
                bra.s   a_st_cont
a_store_end
*
                code    'AC!',ac_store_end      AC!
ac_store        move.w  tos,-(dsp)
                movea.l (dsp)+,a0
                addq.l  #1,dsp
                bra.s   ac_st_cont
ac_store_end
*
                code    'A2!',a2_store_end      A2!
a2_store        move.w  tos,-(dsp)
                movea.l (dsp)+,a0
                bra.s   a2_st_cont
a2_store_end
*
                code    '2DUP',tdup_end         2DUP
two_dup         move.w  tos,-(dsp)
                move.w  2(dsp),-(dsp)
                bra.s   next10
tdup_end
*
                code    '2DROP',tdrop_end       2DROP
two_drop        addq.l  #2,dsp
tdrop1          move.w  (dsp)+,tos
                bra.s   next10
tdrop_end
*
                code    '3DROP',drop3_end       3DROP
drop3           addq.l  #4,dsp
                bra.s   tdrop1
drop3_end
*
                code    '2OVER',tover_end       2OVER
two_over        move.w  tos,-(dsp)
                move.l  4(dsp),-(dsp)
                move.w  (dsp)+,tos
                bra.s   next10
tover_end
*
                code    '2SWAP',tswap_end       2SWAP
two_swap        move.w  tos,-(dsp)
                move.l  4(dsp),d0
                move.l  (dsp),4(dsp)
                move.l  d0,(dsp)
                move.w  (dsp)+,tos
                bra.s   next10
tswap_end
*
                code    '>R',tor_end            >R
to_r            move.w  tos,-(rsp)
                move.w  (dsp)+,tos
next10
                next
tor_end
*
                code    'R@',rat_end            R@
r_at            move.w  tos,-(dsp)
                move.w  (rsp),tos
                next
rat_end
*
                code    'R>',rfrom_end          R>
r_from          move.w  tos,-(dsp)
                move.w  (rsp)+,tos
                next
rfrom_end
*
                code    'I',i_end               I
i               move.w  tos,-(dsp)
                move.w  (rsp),tos
                sub.w   2(rsp),tos
next4
                next
i_end
*
                code    'J',j_end               J
j               move.w  tos,-(dsp)
                move.w  4(rsp),tos
                sub.w   6(rsp),tos
                bra.s   next4
j_end
*
                code    'K',k_end               K
k               move.w  tos,-(dsp)
                move.w  8(rsp),tos
                sub.w   10(rsp),tos
                bra.s   next4
k_end
*
                code    'SWAP',swap_end         SWAP
swap_x          move.w  (dsp),d0
                move.w  tos,(dsp)
                move.w  d0,tos
                next
swap_end
*
                code    'ROT',rot_end           ROT
rot             move.w  (dsp),d0
                move.w  tos,(dsp)
                move.w  2(dsp),tos
                move.w  d0,2(dsp)
next11
                next
rot_end
*
                code    'CMOVE',cmv_end         CMOVE
cmove           bra     cmove_ext
cmv_end
*
                code    'CMOVE>',cmvup_end      CMOVE>
cmove_up        bra     cmove_up_ext
cmvup_end
*
                code    'FILL',fill_end         FILL
fill            bra     fill_ext
fill_end
*
                code    'S->D',std_end          S->D
s_to_d          move.w  tos,-(dsp)
                ext.l   tos
                swap    tos
                bra.s   next11
std_end
*
                code    'M/MOD',mdmod_end       M/MOD
m_div_mod       tst.w   tos
                beq.s   div_by_0
                moveq   #0,d0
                move.w  (dsp)+,d0
                divu    tos,d0
                bvs.s   div_overflow
                move.w  d0,d1
                move.w  (dsp)+,d0
                divu    tos,d0
                swap    d0
                move.l  d0,-(dsp)
                move.w  d1,tos
                bra.s   next5
*
div_by_0        moveq   #16,tos
div_error       bra     roll_error
*
div_overflow    moveq   #17,tos
                bra.s   div_error
mdmod_end
*
                code    '*/MOD',mltdiv_end      */MOD
mult_div_mod    move.w  (dsp)+,d0
                move.w  (dsp)+,d1
                muls    d0,d1
                tst.w   tos
                beq.s   div_by_0
                bra.s   div_mod1
mltdiv_end
*
                code    '/MOD',divmod_end       /MOD
div_mod         tst.w   tos
                beq.s   div_by_0
                move.w  (dsp)+,d0
                ext.l   d0
div_mod1        divs    tos,d0
                bvs.s   div_overflow
                bgt.s   u_div
                move.l  d0,d1
                swap    d1
                tst.w   d1
                beq.s   result_ok
                eor.w   d1,tos
                bge.s   result_ok
                eor.w   d1,tos
                add.w   tos,d1
                subq.w  #1,d0
result_ok       move.w  d0,tos
                move.w  d1,-(dsp)
                bra.s   next5
divmod_end
*
                code    'OVER',over_end         OVER
over            move.w  tos,-(dsp)
                move.w  2(dsp),tos
next5
                next
over_end
*
                code    'UM/MOD',ummod_end      UM/MOD
um_div_mod      tst.w   tos
                beq.s   div_by_0
                move.l  (dsp)+,d0
                divu    tos,d0
                bvs.s   div_overflow
u_div           move.w  d0,tos
                swap    d0
                move.w  d0,-(dsp)
                bra.s   next5
ummod_end
*
                code    '*',mlt_end             *
mult            muls    (dsp)+,tos
                bra.s   next5
mlt_end
*
                code    'UM*',umlt_end          UM*
um_mult         mulu    (dsp),tos
                move.w  tos,(dsp)
                swap    tos
                bra.s   next5
umlt_end
*
                code    '2*',times2_end         2*
two_times       lsl.w   #1,tos
                bra.s   next5
times2_end
*
                code    '2/',div2_end           2/
two_div         asr.w   #1,tos
                bra.s   next5
div2_end
*
                code    'D2*',dtimes2_end       D2*
d_two_times     asl.w   (dsp)
                roxl.w  #1,tos
                bra.s   next5
dtimes2_end
*
                code    'D2/',ddiv2_end         D2/
d_two_div       asr.w   #1,tos
                roxr.w  (dsp)
                bra.s   next5
ddiv2_end
*
                code    'SP!',spst_end          SP!
sp_store        movea.l 0(base,up.w),dsp
                moveq   #0,tos
                bra.s   next7
spst_end
*
                code    'SP@',spat_end          SP@
sp_at           move.w  tos,-(dsp)
                move.l  dsp,tos
                sub.l   base,tos
                bra.s   next7
spat_end
*
                code    'DEPTH',depth_end       DEPTH
depth           movea.l 0(base,up.w),a0
                suba.l  dsp,a0
                move.w  tos,-(dsp)
                move.w  a0,tos
                asr.w   #1,tos
                bra.s   next7
depth_end
*
                code    'EXECUTE',xq_end        EXECUTE
execute         move.w  tos,cp
                move.w  (dsp)+,tos
                ifne    debug
                  bra.s next7+2
                endc
                ifeq    debug
                  bra   debug_next+2
                endc
xq_end
*
                code    'LINK>',lkfrom_end      LINK>
link_from       bra     cfa_ext
lkfrom_end
*
                code    'EXIT',exit_end         EXIT and (;)
exit            movea.l (rsp)+,ip
next7
                next
exit_end
*
to_name         code    '>NAME',to_name_end     >NAME
                bra     to_name_ext
to_name_end
*
                code    'LOCATE',locate_end     LOCATE
locate          bra     locate_ext
locate_end
*
                code    'LOC_CHAR',loc_char_end         LOC_CHAR
loc_char        bra     loc_char_ext
loc_char_end
*
                code    'UP_CHAR',up_char_end   UP_CHAR
up_char         bra     up_char_ext
up_char_end
*
                code    'ACMOVE',acmove_end     Absolute CMOVE
                bra     acmove_ext
acmove_end
*
                code    'ACMOVE>',acmoveup_end  Absolute CMOVE>
                bra     acmoveup_ext
acmoveup_end
*
