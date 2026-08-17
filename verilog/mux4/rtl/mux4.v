// -----------------------------------------------------------------------
// mux4.v
// Ejemplo de circuito COMBINACIONAL: multiplexor 4 a 1, datos de 4 bits.
// Reemplaza este contenido por tu propio diseño; mantene el nombre del
// modulo igual al nombre del archivo para que el Makefile funcione sin
// tocar nada mas.
// -----------------------------------------------------------------------
module mux4 (
    input  wire [3:0] in0,
    input  wire [3:0] in1,
    input  wire [3:0] in2,
    input  wire [3:0] in3,
    input  wire [1:0] sel,
    output reg  [3:0] out
);

    // Logica puramente combinacional -> siempre bloque "always @(*)"
    always @(*) begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 4'bxxxx;
        endcase
    end

endmodule
