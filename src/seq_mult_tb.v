`default_nettype none
`timescale 1 ns / 100 ps

`define b 257
`define b2 514
`define q 255'd57896044618658097711785492504343953926634992332820282019728792003956564819949
`define l 253'd7237005577332262213973186563042994240857116359379907606001950938285454250989

module seq_mult_tb();

reg clk = 0;
always #100 clk = ~clk;


// Outputs
wire  [`b2-1:0] product;
wire        done;

// Inputs
reg   [`b-1:0] a, b;
reg         start;

seq_mult_256bit seq (
  .product(product),
  .done2(done),
  .a(a),
  .b(b),
  .start(start),
  .clk(clk)
);

initial begin
  $display("<< Starting Simulation >>\n");
  clk = 1'b0;

  @(negedge clk);
  a = `b'd52424661395467705593862908645031544692223933496118405275236336510276532625785;
//  a[`b-1] = 1'b1;
  b = `b'd52424661395467705593862908645031544692223933496118405275236336510276532625785;
  start = 1;
  $display("a: %0d", a);
  $display("b: %0d", b);

  @(negedge clk);
  start = 0;

  @(posedge done);
  $display("x3: %0d", product);
  $display("done: %d", done);

  $display("\n<< End of simulation >>");
  $finish;
end
endmodule
