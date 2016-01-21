* Contains the disassembled floating point code words from Superforth
*
*               Last modified:  10 November 1986
*
ri.exec         equ     $11C            Executes a floating point operation
*
*
f_to_r          code    'F>R',f_to_r_end                F>R
                move.l  (dsp)+,-(rsp)
                move.w  tos,-(rsp)
                move.w  (dsp)+,tos
                bra.s   next_fp2
f_to_r_end
*
f_r_from        code    'FR>',float_conv_end            FR>
                move.w  tos,-(dsp)
                move.w  (rsp)+,tos
                move.l  (rsp)+,-(dsp)
                bra.s   next_fp2
*
float_op        no_head                 (n1 --- n2)
                move.w  tos,d0          n1 is operation code
                movea.l dsp,a1          a1 is arithmetic stack pointer
                suba.l  a6,a6
                moveq   #0,d7
                movea.w ri.exec,a0
                jsr     (a0)
                move.w  d0,tos          tos := error code
                movea.l a1,dsp          Update data stack pointer
next_fp2        next
*
float_convert   no_head                     (fp ad1 n1 --- ad2 n2)
                movem.l a2/a3,-(rsp)    or  (ad1 n1 --- fp ad2 n2)
                movea.w tos,a2          n1 is vector number ($F0 or $100)
                movea.w (a2),a2
                movea.w (dsp)+,a0       a0 --> buffer
                adda.l  base,a0
                movea.l dsp,a1          a1 is arithmetic stack pointer
                suba.l  a6,a6
                jsr     (a2)
                movea.l a1,dsp          Update data stack pointer
                suba.l  base,a0
                move.w  a0,-(dsp)       Push updated buffer pointer
                move.w  d0,tos          Push error code
                movem.l (rsp)+,a2/a3
                bra.s   next_fp2
float_conv_end
*
fdrop           code    'FDROP',fdrop_end               FDROP
                addq.l  #4,dsp
                move.w  (dsp)+,tos
                bra.s   next_fp1
fdrop_end
*
fswap           code    'FSWAP',fswap_end               FSWAP
                move.l  (dsp)+,d0
                move.w  (dsp)+,d1
                move.l  (dsp)+,d2
                move.l  d0,-(dsp)
                move.w  tos,-(dsp)
                move.l  d2,-(dsp)
                move.w  d1,tos
                bra.s   next_fp1
fswap_end
*
fover           code    'FOVER',fover_end               FOVER
                move.w  tos,-(dsp)
                move.l  8(dsp),-(dsp)
                move.w  10(dsp),tos
                bra.s   next_fp1
fover_end
*
fdup            code    'FDUP',fdup_end                 FDUP
                move.w  tos,-(dsp)
                move.l  $0002(dsp),-(dsp)
next_fp1                next
fdup_end
*
f_at            code    'F@',f_at_end                   F@
                move.l  2(base,tos.w),-(dsp)
                move.w  0(base,tos.w),tos
                bra.s   next_fp1
f_at_end
*
f_store         code    'F!',f_store_end                F!
                move.l  (dsp)+,0(base,tos.w)
                move.w  (dsp)+,4(base,tos.w)
                move.w  (dsp)+,tos
                bra.s   next_fp1
f_store_end
*

