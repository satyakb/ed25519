`default_nettype none

`define b 256
`define b2 512
`define q 255'd57896044618658097711785492504343953926634992332820282019728792003956564819949
`define l 253'd7237005577332262213973186563042994240857116359379907606001950938285454250989

module ed25519(clk, start, n, x, y, z, t, x3, y3, z3, t3, done);

  input wire clk, start;
  input [`b-1:0] n, x, y, z, t;
  output reg signed [`b-1:0] x3, y3, z3, t3;
  output wire done;

  reg [7:0] count = 8'd2;
  assign done = !(| count);

  localparam INIT = 4'd0;
  localparam DOUBLE = 4'd1;
  localparam ADD = 4'd2;
  localparam GAP = 4'd3;
  reg [3:0] state = INIT;

  reg pa_start = 0;
  reg [`b-1:0] x1, y1, z1, t1, x2, y2, z2, t2;
  wire pa_done;
  wire [`b-1:0] x_tmp, y_tmp, z_tmp, t_tmp;
  point_add pa (
    .clk(clk),
    .start(pa_start),
    .x1(x1), .y1(y1), .z1(z1), .t1(t1),
    .x2(x2), .y2(y2), .z2(z2), .t2(t2),
    .done(pa_done),
    .x3(x_tmp), .y3(y_tmp), .z3(z_tmp), .t3(t_tmp)
  );

  always @(posedge clk) begin
    case (state)
      INIT: begin
        count = 8'd2;
        if (start) begin
          x1 <= `b'd0;
          y1 <= `b'd1;
          z1 <= `b'd1;
          t1 <= `b'd0;

          x2 <= `b'd0;
          y2 <= `b'd1;
          z2 <= `b'd1;
          t2 <= `b'd0;
          
          x3 <= `b'd0;
          y3 <= `b'd0;
          z3 <= `b'd0;
          t3 <= `b'd0;
          
          pa_start = 1'b1;
          state = DOUBLE;
        end
      end

      DOUBLE: begin
        pa_start = 1'b0;
        if (pa_done) begin
          x3 <= x_tmp;
          y3 <= y_tmp;
          z3 <= z_tmp;
          t3 <= t_tmp;

          x1 <= x_tmp;
          y1 <= y_tmp;
          z1 <= z_tmp;
          t1 <= t_tmp;
          if (n[count-1]) begin
            x2 <= x;
            y2 <= y;
            z2 <= z;
            t2 <= t;
            state = ADD;
          end else begin
            x2 <= x_tmp;
            y2 <= y_tmp;
            z2 <= z_tmp;
            t2 <= t_tmp;
            state = (count == 1) ? INIT : DOUBLE;
            count = count - 1;
          end
          pa_start = 1'b1;
        end
      end
      
      GAP: begin
        $display("1: %0d, %0d, %0d, %0d", x1, y1, z1, t1);
        $display("2: %0d, %0d, %0d, %0d", x2, y2, z2, t2); 
        pa_start = 1'b1;
        state = ADD;
      end

      ADD: begin
        pa_start = 1'b0;
        if (pa_done) begin
          x3 <= x_tmp;
          y3 <= y_tmp;
          z3 <= z_tmp;
          t3 <= t_tmp;

          x1 <= x_tmp;
          y1 <= y_tmp;
          z1 <= z_tmp;
          t1 <= t_tmp;

          x2 <= x_tmp;
          y2 <= y_tmp;
          z2 <= z_tmp;
          t2 <= t_tmp;
          state = (count == 1) ? INIT : DOUBLE;
          pa_start = 1'b1;
          count = count - 1;
        end
      end
    endcase

  end

endmodule



