// This directive specifies the simulation time unit and precision.
// 1ns is the time unit, 1ps is the precision.
`timescale 1ns/1ps

// A testbench is a Verilog module used ONLY for simulation.
// It does NOT represent real hardware and has no ports.
module tb;

  // ---------------------------------------------------------
  // Declare signals that will drive the DUT inputs
  // ---------------------------------------------------------
  // reg is used because these signals are assigned values
  // procedurally inside an initial block.
  reg a;
  reg b;
  reg cin;

  // ---------------------------------------------------------
  // Declare wires to observe DUT outputs
  // ---------------------------------------------------------
  // wire is used because outputs are driven by the DUT.
  wire sum;
  wire cout;

  // ---------------------------------------------------------
  // Instantiate the Design Under Test (DUT)
  // ---------------------------------------------------------
  // 'dut' is the module name of the design being tested.
  // 'DUT' is the instance name (Unit Under Test).
  dut DUT (
    .a(a),       // Connect testbench signal 'a' to DUT port 'a'
    .b(b),       // Connect testbench signal 'b' to DUT port 'b'
    .cin(cin),   // Connect testbench signal 'cin' to DUT port 'cin'
    .sum(sum),   // Observe DUT output 'sum'
    .cout(cout)  // Observe DUT output 'cout'
  );

  // ---------------------------------------------------------
  // Waveform dump configuration
  // ---------------------------------------------------------
  // This string will store the VCD file name passed from the command line.
  string vcd_file;

  // This initial block runs once at the start of simulation.
  initial begin
    // Check if a VCD file name was passed using +vcd=<filename>
    if ($value$plusargs("vcd=%s", vcd_file))
      // If provided, dump waveforms to that file
      $dumpfile(vcd_file);
    else
      // Otherwise, use a default file name
      $dumpfile("fa.vcd");

    // Dump all signals inside the DUT hierarchy
    $dumpvars(0, DUT);
  end

  // ---------------------------------------------------------
  // Test logic
  // ---------------------------------------------------------

  // Integer variable used for looping through test cases
  integer i;

  // Registers to store expected (correct) outputs
  reg exp_sum;
  reg exp_cout;

  // This initial block applies test vectors and checks outputs
  initial begin
    // Print header information to the console
    $display("Starting Full Adder Testbench");
    $display(" a b cin | sum cout ");

    // Loop through all 8 possible input combinations
    // {a, b, cin} is a 3-bit vector
    for (i = 0; i < 8; i = i + 1) begin
      // Assign bits of 'i' to inputs a, b, cin
      {a, b, cin} = i[2:0];

      // Wait for 10 time units to allow outputs to settle
      #10;

      // -----------------------------------------------------
      // Compute expected outputs using Boolean expressions
      // -----------------------------------------------------
      exp_sum  = a ^ b ^ cin;
      exp_cout = (a & b) | (a & cin) | (b & cin);

      // Display the current inputs and outputs
      $display(" %b %b  %b  |  %b    %b",
                a, b, cin, sum, cout);

      // -----------------------------------------------------
      // Check if DUT output matches expected output
      // -----------------------------------------------------
      if (sum !== exp_sum || cout !== exp_cout) begin
        // Print an error message if there is a mismatch
        $display("ERROR: Output mismatch detected!");
        $display("Expected: sum=%b cout=%b",
                 exp_sum, exp_cout);
        // Stop simulation immediately
        $finish;
      end
    end

    // If all test cases pass, print success message
    $display("All test cases PASSED.");

    // End the simulation
    $finish;
  end

endmodule
