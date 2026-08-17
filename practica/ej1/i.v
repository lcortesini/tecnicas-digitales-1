`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:39:05 05/13/2026 
// Design Name: 
// Module Name:    i 
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
module i(
	input A,
	input B,
	input C,
	input D,
	output F
    );
assign F = ~B&C | ~A&B&~C&D | A&B&~D;

endmodule
