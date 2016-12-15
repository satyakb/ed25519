`define b 256
`define b2 512

module seq_mod_25519 (clk, start, x, mod, done);
  input clk, start;
  input [`b2-1:0] x;

  output wire done;
  output reg [`b-1:0] mod;

  reg [`b-1:0] r;
  reg [300:0] q;
  reg [`b2-1:0] intermediate;

  reg [1:0] count;
  assign done = !(| count);

  localparam INIT = 3'd0;
  localparam OP1 = 3'd1;
  localparam OP2 = 3'd2;
  localparam OP3 = 3'd3;
  localparam OP4 = 3'd4;
  localparam OP5 = 3'd5;
  localparam OP6 = 3'd6;

  reg [2:0] state = INIT;

  reg [`b2-1:0] add1, add2;
  wire [`b2-1:0] sum;

  seq_add_512bit seq_add(
    .a(add1),
    .b(add2),
    .sum(sum)
  );

  always @(posedge clk) begin
    case (state)
      INIT: begin
        if (start) begin
          intermediate <= x;
          count <= 2'b10;
          state = OP1;
        end
      end

      OP1: begin
        r = intermediate[254:0];  // r = x mod 2^255
        q = intermediate >> 255;  // q = floor(x / 2^255)
        state = OP2;
      end

      OP2: begin
        intermediate = q << 4;
        add1 = intermediate;
        add2 = q << 1;
        state = OP3;
      end

      OP3: begin
        intermediate = sum;
        add1 = intermediate;
        add2 = q;
        state = OP4;
      end

      OP4: begin
        intermediate = sum;
        add1 = intermediate;
        add2 = r;
        state = OP5;
      end

      OP5: begin
        if (count == 2'b10) begin
          intermediate = sum;
          state = OP1;
          count = count >> 1;
        end else begin
          mod = sum;
          state = OP6;
        end
      end
      
      // Need extra cycle to commit value to mod
      OP6: begin
        count = count >> 1;
        state = INIT;
      end
      
    endcase
  end
endmodule

module seq_add_512bit (a, b, sum);
  input [`b2-1:0] a;
  input [300:0] b;
  output wire [`b2-1:0] sum;

  assign sum = a + b;
endmodule