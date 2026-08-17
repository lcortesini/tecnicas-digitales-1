// -----------------------------------------------------------------------
// half_adder.v
// Ejemplo de circuito COMBINACIONAL: multiplexor 4 a 1, datos de 4 bits.
// Reemplaza este contenido por tu propio diseño; mantene el nombre del
// modulo igual al nombre del archivo para que el Makefile funcione sin
// tocar nada mas.
// -----------------------------------------------------------------------
//

module adder_subtractor_4bit (
  input [3:0] A,
  input [3:0] B,
  input M,
  output [3:0] S,
  output C,
  output V
);

reg [3:0] P;

wire C1;
wire C2;
wire C3;

always @(*) begin
  if (M == 1) P = ~B ; else P = B;
end

full_adder fa1 (A[0],P[0],M,S[0],C1);
full_adder fa2 (A[1],P[1],C1,S[1],C2);
full_adder fa3 (A[2],P[2],C2,S[2],C3);
full_adder fa4 (A[3],P[3],C3,S[3],C);

assign V = \C3 ^ C;

endmodule
