-- FORTH Cross compiler -  User variables, TIB, PAD and constants

-- Last modified:   9 November 1986


--   Input/output buffers

here target_address tib_area !         -- TIB space
tib_size allot

here target_address pad_area !         -- PAD space
pad_size allot


--   User variables

0  xuser   s0           -- Base of data stack (long address )
4  xuser   r0           -- Base of return stack
8  xuser   max_depth    -- Size of data stack (leave here for tasking)
10 xuser   dp           -- Dictionary pointer (gives HERE)
12 user      fence      -- Marks protected dictionary
14 user      >in        -- Offset into input buffer
16 dup tib_offset !     -- Needed for multi-tasking
   xuser   (tib)        -- Address of TIB
18 user      state      -- Interpret/compile flag
20 user      blk        -- Block number being interpreted/compiled
22 user      base       -- Numeric base for input/output
24 xuser   xq_link      -- Links execution vectors
26 xuser   do_list      -- For compilation of nested DO ...  LOOPs
28 xuser   voc_link     -- Links vocabulary words
30 dup pad_offset !     -- For multi-tasking
   xuser   (pad)        -- Address of PAD
32 user      scr        -- Screen being edited
34 user      dpl        -- Position of decimal point in input number
36 xuser   csp          -- Holds stack depth during compilation
38 xuser   hld          -- Latest character during output conversion
40 user      #tib       -- Number of bytes in TIB
42 user      span       -- Number of characters received by EXPECT
44 dup buf_ad_offset !  -- For multi-tasking
   xuser   buf_ad       -- Block buffer address
46 user      #in        -- Input channel ID (long word)
50 user      #out       -- Output channel ID (long word)
54 xuser   emit_var     -- Character being EMITted
56 user      current    -- Current vocabulary
58 user      context    -- List of CONTEXT vocabularies

here target_address cold_users !      -- COLD start user values

0 0 , ,                    -- s0   loaded by entry routine
0 0 , ,                    -- r0   loaded by entry routine
128 ,                      -- max_depth
here (dp) !
0 ,                        -- dp   must be patched before saving image
here (fence) !   
0 ,                        -- fence   must be patched before saving
0 ,                        -- >in
tib_area @ ,               -- (tib)
0 ,                        -- state
0 ,                        -- blk
10 ,                       -- base
here (xq_link) !
-32768 ,                   -- xq_link   must be patched before saving
-32768 ,                   -- do_list
here (voc_link) !
-32768 ,                   -- voc_link   must be patched before saving
pad_area @ ,               -- (pad)
0 ,                        -- scr
-1 ,                       -- dpl
0 ,                        -- csp
0 ,                        -- hld
0 ,                        -- #tib
0 ,                        -- span
32764 1024 - ,             -- buf_address
-1 -1 , ,                  -- #in
-1 -1 , ,                  -- #out
0 ,                        -- emit_var
here (current) !           -- Remember address
-32768 ,                   -- current
here (context) !           -- Remember address
-32768 , -32768 , -32768 ,
-32768 , -32768 ,          -- context


here target_address user_area !  -- Run time user variable area

user_area @ cold_users @ - number_users ! -- Save number of USER bytes

number_users @ allot            -- Run time user area


--   Constants

-1    constant   -1
-1    constant   timeout         -- Timeout period for QDOS calls
here 2- (timeout) !              -- Save for later patching
-2    constant   -2
0    constant   0
1    constant   1
2    constant   2
3    constant   3
4    xconstant   four
5    xconstant   five
8    xconstant   eight
10    xconstant   ten
32    constant   bl              -- Ascii code for SPACE
34    xconstant   $"             -- Ascii code for "
-32768    constant   nil         -- Nil pointer, at end of lists
tib_size xconstant   tib_length  -- Size, in bytes, of tib

