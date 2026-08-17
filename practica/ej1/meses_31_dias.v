`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:04:38 06/14/2026 
// Design Name: 
// Module Name:    meses_31_dias
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
module meses_31_dias(
		input [3:0] A,
		output F
    );

assign F = ~A[3] & A[0] | A[3] & ~A[0];

endmodule
