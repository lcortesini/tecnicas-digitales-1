`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:06:51 06/23/2026 
// Design Name: 
// Module Name:    ej7 
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
module ej7(
    input I1,
    input I2,
    input SEL,
    output Y
    );

assign Y = (~SEL & I0) | (SEL & I1);

endmodule
