`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:06:08 06/23/2026 
// Design Name: 
// Module Name:    ej6 
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
module ej6(
    input T,
    input C,
    input S,
    output A
    );

assign A = (T & C) | S;	 

endmodule
