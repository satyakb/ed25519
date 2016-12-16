`default_nettype none
`timescale 1 ns / 100 ps

`define b 257
`define q 255'd57896044618658097711785492504343953926634992332820282019728792003956564819949
`define l 253'd7237005577332262213973186563042994240857116359379907606001950938285454250989

module ed25519_tb();

reg clk = 0;
always #100 clk = ~clk;


//inputs to test are reg type;
reg start;
reg [`b-1:0] n, x, y, z, t;

// outputs
wire done;
wire signed [`b-1:0] x3, y3, z3, t3;

ed25519 ed (
  .clk(clk),
  .start(start),
  .n(n),
  .x(x), .y(y), .z(z), .t(t),
  .done(done),
  .x3(x3), .y3(y3), .z3(z3), .t3(t3)
);

initial begin
  $display("<< Starting Simulation >>\n");
  clk = 1'b0;

  @(negedge clk);
  n = `b'd25;
  x = `b'd15112221349535400772501151409588531511454012693041857206046113283949847762202;
  y = `b'd46316835694926478169428394003475163141307993866256225615783033603165251855960;
  z = `b'd1;
  t = `b'd46827403850823179245072216630277197565144205554125654976674165829533817101731;
  start = 1;

  @(negedge clk);
  start = 0;

  @(posedge done);
  $display("x3: %0d", x3);
  $display("y3: %0d", y3);
  $display("z3: %0d", z3);
  $display("t3: %0d", t3);
  $display("done: %d", done);
  
  @(posedge clk);
  $display("x3: %0d", x3);
  $display("y3: %0d", y3);
  $display("z3: %0d", z3);
  $display("t3: %0d", t3);

  $display("\n<< End of simulation >>");
  $finish;
end
endmodule
