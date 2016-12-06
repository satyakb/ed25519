`default_nettype none

`define b 256
`define b2 512
`define q 255'd57896044618658097711785492504343953926634992332820282019728792003956564819949
`define l 253'd7237005577332262213973186563042994240857116359379907606001950938285454250989

module point_add (
  clk,
  enable,
  rst,
  x1, y1, z1, t1,
  x2, y2, z2, t2,
  done,
  x3, y3, z3, t3,
  );

  // Inputs
  input clk, enable, rst;
  input [`b-1:0] x1, y1, z1, t1;
  input [`b-1:0] x2, y2, z2, t2;

  // Outputs
  output reg done;
  output reg signed [`b-1:0] x3, y3, z3, t3;

  // State
  reg [3:0] state;
  localparam OPA = 4'd0;
  localparam OPB = 4'd1;
  localparam OPC = 4'd2;
  localparam OPD = 4'd3;
  localparam OPEH = 4'd4;
  localparam OPFG = 4'd5;
  localparam OPX3 = 4'd6;
  localparam OPY3 = 4'd7;
  localparam OPZ3 = 4'd8;
  localparam OPT3 = 4'd9;

  reg need_mult;

  // Multiplier module
  reg mult_start;
  initial mult_start = 1;
  reg [`b-1:0] mult1, mult2;
  wire mult_done;
  wire [`b2-1:0] product;
  seq_mult_256bit mult (
    .product(product),
    .done(mult_done),
    .a(mult1),
    .b(mult2),
    .clk(clk),
    .start(mult_start)
  );

  // Adder module
  reg [`b2-1:0] add1, add2;
  wire [`b2-1:0] sum;
  seq_add_256bit add (
    .a(add1),
    .b(add2),
    .sum(sum)
  );

  // Subtraction module
  wire [`b2-1:0] diff;
  seq_sub_256bit sub (
    .a(add1),
    .b(add2),
    .diff(diff)
  );

  reg [3:0] need_add;

  // Intermediate values
  reg signed [`b2-1:0] A, B, C, D, E, F, G, H;

  always @(posedge clk) begin

    if (rst) begin
      x3 <= `b'd0;
      y3 <= `b'd0;
      z3 <= `b'd0;
      t3 <= `b'd0;
      done <= 0;
      need_add <= 4'b1000;
      need_mult <= 0;
      state = OPA;
    end else if (enable) begin
      if (need_mult) begin
        mult_start = 1;
        need_mult = 0;
      end else begin
        mult_start = 0;
      end

      case (state)
        OPA: begin
          if (need_add == 8) begin
            add1 <= y1;
            add2 <= x1;
            need_add <= {1'b0, need_add[3:1]};
          end else if (need_add == 4) begin
            mult1 = diff;
            add1 <= y2;
            add2 <= x2;
            need_add <= {1'b0, need_add[3:1]};
          end else if (need_add == 2) begin
            mult2 = diff;
            need_add <= {1'b0, need_add[3:1]};
          end else if (need_add == 1) begin
            need_mult <= 1;
            need_add <= {1'b0, need_add[3:1]};
          end

          if (mult_done) begin
            $display("mult1: %0d", mult1);
            $display("mult2: %0d", mult2);
            A = product;
            $display("A: %0d", A);
            need_add <= 4'b1000;
            state = OPB;
          end else begin
            state = OPA;
          end
        end

        OPB: begin
          if (need_add == 8) begin
            add1 <= y1;
            add2 <= x1;
            need_add <= {1'b0, need_add[3:1]};
          end else if (need_add == 4) begin
            mult1 = sum;
            add1 <= y2;
            add2 <= x2;
            need_add <= {1'b0, need_add[3:1]};
          end else if (need_add == 2) begin
            mult2 = sum;
            need_add <= {1'b0, need_add[3:1]};
          end else if (need_add == 1) begin
            need_mult <= 1;
            need_add <= {1'b0, need_add[3:1]};
          end

          if (mult_done) begin
            $display("mult1: %0d", mult1);
            $display("mult2: %0d", mult2);
            B = product;
            $display("B: %0d", B);
            mult1 <= t1;
            mult2 <= t2;
            need_mult <= 1;
            state = OPC;
          end else begin
            state = OPB;
          end
        end

        OPC: begin
          if (mult_done) begin
            C = product;
            $display("C: %0d", C);
            mult1 <= z1;
            mult2 <= z2;
            need_mult <= 1;
            state = OPD;
          end else begin
            state = OPC;
          end
        end

        OPD: begin
          if (mult_done) begin
            D = product;
            $display("D: %0d", D);
            need_add <= 4'b1000;
            state = OPEH;
          end else begin
            state = OPD;
          end
        end

        OPEH: begin
          if (need_add == 8) begin
            add1 <= B;
            add2 <= A;
            need_add <= {1'b0, need_add[3:1]};
            state = OPEH;
          end else if (need_add == 4) begin
            E = diff;
            H = sum;
            $display("E: %0d", E);
            $display("H: %0d", H);
            need_add <= 4'b1000;
            state = OPFG;
          end
        end

        OPFG: begin
          if (need_add == 8) begin
            add1 <= D;
            add2 <= C;
            need_add <= {1'b0, need_add[3:1]};
            state = OPFG;
          end else if (need_add == 4) begin
            F = diff;
            G = sum;
            $display("F: %0d", F);
            $display("G: %0d", G);
            mult1 <= E;
            mult2 <= F;
            need_mult <= 1;
            state <= OPX3;
          end
        end

        OPX3: begin
          if (mult_done) begin
            x3 = product;
            mult1 <= G;
            mult2 <= H;
            need_mult <= 1;
            state = OPY3;
          end else begin
            state = OPX3;
          end
        end

        OPY3: begin
          if (mult_done) begin
            y3 = product;
            mult1 <= E;
            mult2 <= H;
            need_mult <= 1;
            state = OPT3;
          end else begin
            state = OPY3;
          end
        end

        OPT3: begin
          if (mult_done) begin
            t3 = product;
            mult1 <= F;
            mult2 <= G;
            need_mult <= 1;
            state = OPZ3;
          end else begin
            state = OPT3;
          end
        end

        OPZ3: begin
          if (mult_done) begin
            z3 = product;
            done = 1;
          end else begin
            state = OPZ3;
          end
        end

      endcase

    end
  end

endmodule

module seq_add_256bit (a, b, sum);
  input [`b2-1:0] a, b;
  output wire [`b2-1:0] sum;

  assign sum = a + b;
endmodule

module seq_sub_256bit (a, b, diff);
  input [`b2-1:0] a, b;
  output wire [`b2-1:0] diff;

  assign diff = a - b;
endmodule

module seq_mult_256bit (
  output  [`b2-1:0] product,
  output        done,
  input   [`b-1:0] a,
  input   [`b-1:0] b,
  input         clk,
  input         start
);

  reg     [`b2-1:0] product;
  reg     [`b-1:0] multiplicand;
  reg     [`b-1:0] delay;

  wire    [`b:0] sum = {1'b0, product[`b2-1:`b]} + {1'b0, multiplicand};

  assign done = delay[0];

  always @(posedge clk) begin
    if (start) begin
      delay = `b'd0;
      delay[`b-1] = 1'b1;
      multiplicand = a;
      if (b[0]) begin
        product <= {1'b0, a, b[`b-1:1]};
      end else begin
        product <= {1'b0, `b'b0, b[`b-1:1]};
      end
    end else begin
      delay = {1'b0, delay[`b-1:1]};
      if (product[0]) begin
        product <= {sum, product[`b-1:1]};
      end else begin
        product <= {1'b0, product[`b2-1:1]};
      end
    end
  end

endmodule
