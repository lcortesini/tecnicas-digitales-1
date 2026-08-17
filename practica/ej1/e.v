`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:16:26 05/12/2026 
// Design Name: 
// Module Name:    e 
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

module e(
	input A,
	input B, 
	input C,
	input D,
	output F
	);
assign F = B&C | C&D | A&B&D;

endmodule
