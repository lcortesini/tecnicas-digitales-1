
module full_adder (
  input x,
  input y,
  input Ci,
  output S,
  output C
);

wire P;
wire G;
wire O;

half_adder ha1 (x,y,P,G);
half_adder ha2 (P,Ci,S,O);

assign C = O | G;

endmodule
