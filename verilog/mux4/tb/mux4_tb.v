`timescale 1ns/1ps
// -----------------------------------------------------------------------
// mux4_tb.v
// Testbench basico: aplica estimulos, imprime resultados por consola y
// vuelca las senales a un .vcd para poder verlas en gtkwave.
// -----------------------------------------------------------------------
module mux4_tb;

    reg  [3:0] in0, in1, in2, in3;
    reg  [1:0] sel;
    wire [3:0] out;

    integer errores = 0;

    // Instancia del DUT (Device Under Test)
    mux4 dut (
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .sel(sel),
        .out(out)
    );

    // Volcado de ondas para gtkwave
    initial begin
        $dumpfile("build/waves/mux4.vcd");
        $dumpvars(0, mux4_tb);
    end

    task check(input [3:0] esperado);
        begin
            if (out !== esperado) begin
                $display("FALLO  sel=%b out=%b esperado=%b (t=%0t)", sel, out, esperado, $time);
                errores = errores + 1;
            end else begin
                $display("OK     sel=%b out=%b (t=%0t)", sel, out, $time);
            end
        end
    endtask

    initial begin
        in0 = 4'h1; in1 = 4'h2; in2 = 4'h3; in3 = 4'h4;

        sel = 2'b00; #10; check(in0);
        sel = 2'b01; #10; check(in1);
        sel = 2'b10; #10; check(in2);
        sel = 2'b11; #10; check(in3);

        if (errores == 0)
            $display("\n*** TODOS LOS CASOS PASARON ***");
        else
            $display("\n*** %0d CASO(S) FALLARON ***", errores);

        $finish;
    end

endmodule
