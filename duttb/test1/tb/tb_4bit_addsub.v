module tb;
  reg [3:0]a;
  reg [3:0]b;
  reg m;
  wire [3:0]sum;
  wire cout;
  string vcd_file;

  dut DUT(.a(a),.b(b),.sum(sum),.cout(cout),.m(m));

  initial begin
    if ($value$plusargs("vcd=%s", vcd_file))
      $dumpfile(vcd_file);
    else
      $dumpfile("artefacts/default.vcd");

    $dumpvars(0, DUT);

    a=4'H4; b=4'H0; m=0;#10;
    a=4'H8; b=4'HB; m=0;#10;
    a=4'HD; b=4'HF; m=0;#10;
    a=4'H3; b=4'H1; m=0;#10;
    a=4'H0; b=4'H9; m=0;#10;
    a=4'HF; b=4'H0; m=0;#10;

    a=4'H4; b=4'H0; m=1;#10;
    a=4'H8; b=4'HB; m=1;#10;
    a=4'HD; b=4'HF; m=1;#10;
    a=4'H3; b=4'H1; m=1;#10;
    a=4'H0; b=4'H9; m=1;#10;
    a=4'HF; b=4'H0; m=1;#10;

    $finish;
  end
endmodule
