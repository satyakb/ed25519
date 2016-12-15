`default_nettype none
`timescale 1 ns / 100 ps

`define b 256
`define q 255'd57896044618658097711785492504343953926634992332820282019728792003956564819949
`define l 253'd7237005577332262213973186563042994240857116359379907606001950938285454250989

module point_add_tb();

reg clk = 0;
always #100 clk = ~clk;


//inputs to test are reg type;
reg enable, start;
reg [`b-1:0] x1, y1, z1, t1;
reg [`b-1:0] x2, y2, z2, t2;

// outputs
wire done;
wire signed [`b-1:0] x3, y3, z3, t3;

point_add pa (
  .clk(clk),
  .start(start),
  .x1(x1), .y1(y1), .z1(z1), .t1(t1),
  .x2(x2), .y2(y2), .z2(z2), .t2(t2),
  .done(done),
  .x3(x3), .y3(y3), .z3(z3), .t3(t3)
);

initial begin
  $display("<< Starting Simulation >>\n");
  clk = 1'b0;

  @(negedge clk);
  x1 = `b'd3;
  x2 = `b'd4;
  y1 = `b'd5;
  y2 = `b'd6;
  z1 = `b'd7;
  z2 = `b'd8;
  t1 = `b'd9;
  t2 = `b'd10;
  start = 1;

  @(negedge clk);
  start = 0;

  @(posedge done);
  $display("x3: %0d", x3);
  $display("y3: %0d", y3);
  $display("z3: %0d", z3);
  $display("t3: %0d", t3);
  $display("done: %d", done);

  $display("\n<< End of simulation >>");
  $finish;
end
endmodule
