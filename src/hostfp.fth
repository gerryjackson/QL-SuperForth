-- FORTH 83 Cross Compiler - Floating Point extensions

-- Contains extra host definitions

--	Last modified:	11 November 1986

address_var {float_op}
address_var {float_convert}
address_var {flop}			-- Run time code for FLOP

h: float_op
	[compile] {float_op}	h;	host_immediate

h: float_convert
	[compile] {float_convert}
				h;	host_immediate

h: flop					-- For floating point maths
	target_only
	create_with_name
	-2 allot [compile] {flop}
	,
	host_only	h;

