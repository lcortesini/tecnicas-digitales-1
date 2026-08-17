`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:48:20 05/15/2026
// Design Name:   ej1
// Module Name:   /home/corte/Documents/utn/tecnicas-digitales-1/practica/ej1/xyz.v
// Project Name:  ej1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ej1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module xyz;

	// Inputs
	reg x;
	reg y;

	// Outputs
	wire F;

	// Instantiate the Unit Under Test (UUT)
	ej1 uut (
		.x(x), 
		.y(y), 
		.F(F)
	);

	initial begin
		// Initialize Inputs
		x = 0;
		y = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

