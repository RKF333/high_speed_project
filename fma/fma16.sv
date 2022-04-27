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
	input logic mul, add, negr, negz;
	input logic [1:0]  roundmode;
	
	output logic [15:0] result;
	//output logic [19:0] debug;
	
	logic [21:0] Mantissa_multi, buffer_1;
	logic [21:0] Mantissa_add, buffer_2;
	logic [4:0]  add_exp;
	
	logic x_sign, y_sign, z_sign, product_sign;
	logic [4:0] x_exp, y_exp, z_exp, product_exp;
	logic [20:0] x_frac, y_frac, z_frac, product_frac;
	
	logic [20:0] x_frac_buffer, y_frac_buffer, z_frac_buffer;
	
	// assigning the MSB or the 16th bit to the sign bit
	assign x_sign = x[15]; 
	assign y_sign = y[15];
	assign z_sign = z[15];
	
	// assigning bits 14 thur 10 to the exponet array
	assign x_exp = x[14:10]; 
	assign y_exp = y[14:10];
	assign z_exp = z[14:10];
   
	assign x_frac = {1'b1, x[9:0]}; // adds a 1 in the front
	assign y_frac = {1'b1, y[9:0]}; // adds a 1 in the front
	assign z_frac = {1'b1, z[9:0]}; // adds a 1 in the front 
	
	/*
	//multiplication section start
	assign Mantissa_multi = x_frac * y_frac; // Mantissa calculation
	assign product_sign = x_sign ^ y_sign; // xor to handle the sign bit
	assign product_exp = $signed(x_exp + y_exp + 5'b10001) + Mantissa_multi[21];
	assign buffer_1 = (Mantissa_multi[20:0] >> Mantissa_multi[21]); // shifting 
	assign product_frac = buffer_1[19:10];
	
	assign result[15] = product_sign;
	assign result[14:10] = product_exp;
	assign result[9:0] = product_frac;
	// multiplication section end
	*/

	assign z_frac_buffer = z_frac * 2 ** (z_exp - x_exp);
	assign Mantissa_add = x_frac + z_frac_buffer;
	assign add_exp = x_exp + Mantissa_add[11];
	//assign Mantissa_add = (buffer_2[10:0] >> buffer_2[11]);
	
	//assign result = $unsigned(z_exp - x_exp);
	
	assign result[15] = x_sign | z_sign;
	assign result[14:10] = add_exp;
	assign result[9:0] = Mantissa_add[9:0];
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	assign x_frac = x_frac_buffer << $signed(x_exp - 5'b10001);
	assign z_frac = z_frac_buffer << $signed(z_exp - 5'b10001);
	
	assign Mantissa_add = x_frac + z_frac;
	
	assign add_exp = (x_exp & z_exp) + Mantissa_add[19:16];
	
	assign buffer_1 = Mantissa_add >> $signed(add_exp + 5'b10001);
	
	
	assign debug = $signed(5'b10001);
	
	
	//assign debug[19:16] = 0;
	//assign debug[15] = x_sign | z_sign;
	//assign debug[14:10] = add_exp;
	//assign debug[9:0] = buffer_1[9:0];
*/
	
   // 00: rz, 01: rne, 10: rp, 11: rn   3000
 
endmodule
