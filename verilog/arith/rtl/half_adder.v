// -----------------------------------------------------------------------
// half_adder.v
// Ejemplo de circuito COMBINACIONAL: multiplexor 4 a 1, datos de 4 bits.
// Reemplaza este contenido por tu propio diseño; mantene el nombre del
// modulo igual al nombre del archivo para que el Makefile funcione sin
// tocar nada mas.
// -----------------------------------------------------------------------
//
module half_adder (
  input x,
  input y,
  output S,
  output C
);

assign S = x ^ y;
assign C = x & y;

endmodule
