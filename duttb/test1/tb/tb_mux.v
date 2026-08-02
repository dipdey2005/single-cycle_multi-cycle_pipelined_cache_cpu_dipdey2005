module tb;
  reg a, b, sel;
  wire y;
  string vcd_file;

  mux2 dut(.a(a),.b(b),.sel(sel),.y(y));

  initial begin
    if ($value$plusargs("vcd=%s", vcd_file))
      $dumpfile(vcd_file);
    else
      $dumpfile("artefacts/default.vcd");

    $dumpvars(0, dut);

    a=0; b=0; sel=0; #10;
    a=1; b=0; sel=0; #10;
    a=0; b=1; sel=1; #10;
    a=1; b=1; sel=1; #10;

    $finish;
  end
endmodule
