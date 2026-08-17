`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:19:33 05/12/2026 
// Design Name: 
// Module Name:    f 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module f(
	input w,
	input x,
	input y, 
	input z,
	output F
	);
	
assign F = w&x | y;

endmodule
