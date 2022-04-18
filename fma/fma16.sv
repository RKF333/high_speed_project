// fma16.sv
// David_Harris@hmc.edu 26 February 2022
// 16-bit floating-point multiply-accumulate

// Operation: general purpose multiply, add, fma, with optional negation
//   If mul=1, p = x * y.  Else p = x.
//   If add=1, result = p + z.  Else result = p.
//   If negr or negz = 1, negate result or z to handle negations and subtractions
//   fadd: mul = 0, add = 1, negr = negz = 0
//   fsub: mul = 0, add = 1, negr = 0, negz = 1
//   fmul: mul = 1, add = 0, negr = 0, negz = 0
//   fmadd:  mul = 1, add = 1, negr = 0, negz = 0
//   fmsub:  mul = 1, add = 1, negr = 0, negz = 1
//   fnmadd: mul = 1, add = 1, negr = 1, negz = 0
//   fnmsub: mul = 1, add = 1, negr = 1, negz = 1

module fma16 (x, y, z, mul, add, negr, negz, roundmode, result);
   
	input logic [15:0] x, y, z;   
	input logic 	    mul, add, negr, negz;
	input logic [1:0]  roundmode;
	
	output logic [15:0] result;
	
	logic [21:0] Mantissa;
	
	logic x_sign;
	logic [4:0] x_exp;
	logic [10:0] x_frac;
	
	logic y_sign;
	logic [4:0] y_exp;
	logic [10:0] y_frac;
	logic [21:0] buffer;
	
	assign x_sign = x[15];
	assign y_sign = y[15];
	
	assign x_exp[4:0] = x[14:10];
	assign y_exp[4:0] = y[14:10];
   
	assign x_frac[10:0] = {1'b1, x[9:0]};
	assign y_frac[10:0] = {1'b1, y[9:0]};
	
	
	assign Mantissa = x_frac * y_frac;
	assign result[15] = x_sign ^ y_sign; // xor to handle the sign bit
	assign result[14:10] = $signed(x_exp + y_exp + 5'b10001) + Mantissa[21];
	assign buffer = (Mantissa[20:0] >> Mantissa[21]);
	assign result[9:0] = buffer[19:10];
	
   // 00: rz, 01: rne, 10: rp, 11: rn   3000
 
endmodule
