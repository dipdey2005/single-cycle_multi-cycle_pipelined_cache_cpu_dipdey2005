module tb;
  reg [3:0]a; 
  reg [3:0]b;
  reg cin;
  wire [3:0]sum;
  wire cout;
  string vcd_file;

  dut DUT(.a(a),.b(b),.cin(cin),.sum(sum),.cout(cout));

  initial begin
    if ($value$plusargs("vcd=%s", vcd_file))
      $dumpfile(vcd_file);
    else
      $dumpfile("artefacts/default.vcd");

    $dumpvars(0, DUT);

    a=4'H0; b=4'H0; cin=0; #10;
    a=4'H6; b=4'HB; cin=1; #10;
    a=4'HF; b=4'HF; cin=1; #10;
    a=4'H0; b=4'H1; cin=0; #10;
    a=4'HA; b=4'H9; cin=0; #10;
    a=4'H4; b=4'H3; cin=1; #10;

    $finish;
  end
endmodule

