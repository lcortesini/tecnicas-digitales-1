`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:02:11 06/23/2026 
// Design Name: 
// Module Name:    ej3 
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
module ej3(
    input A,
    input B,
    input C,
    output Y
    );
	
assign Y = (A & B) | (A & C) | (B & C);

endmodule
