`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:33:00 05/13/2026 
// Design Name: 
// Module Name:    h 
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


module h(
	input A,
	input B,
	input C,
	input D,
	output F
	);
assign F = A&~B | ~D;

endmodule
