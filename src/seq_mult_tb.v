`default_nettype none
`timescale 1 ns / 100 ps

`define b 256
`define b2 512
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

//inputs to test are reg type;
// reg enable, rst;
// reg [`b-1:0] x1, y1, z1, t1;
// reg [`b-1:0] x2, y2, z2, t2;

// // outputs
// wire done;
// wire [2*`b-1:0] x3, y3, z3, t3;


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
  a = `b'd47040;
//  a[`b-1] = 1'b1;
  b = `b'd115792089237316195423570985008687907853269984665640564039457584007913129584737;
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
