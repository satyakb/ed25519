`define b 257
`define b2 514

module seq_mult_256bit (
  output reg [`b2-1:0] product,
  output   reg     done2,
  input   [`b-1:0] a,
  input   [`b-1:0] b,
  input         clk,
  input         start
);

//  reg [`b2-1:0] product;
  reg [`b-1:0] multiplicand;
  reg [`b-1:0] delay;
  
  reg [`b-1:0] a_, b_;

  reg [`b-1:0] r, q;

  wire [`b:0] sum = {1'b0, product[`b2-1:`b]} + {1'b0, multiplicand};

  wire done;
  assign done = delay[0];

  reg mod_start;
  reg need_mod;
  wire [`b-1:0] mod;
  wire mod_done;
  seq_mod_25519 seq (
    .clk(clk),
    .start(mod_start),
    .x(product),
    .mod(mod),
    .done(mod_done)
  );

  localparam INIT = 3'd0;
  localparam OP1 = 3'd1;
  localparam OP2 = 3'd2;
  localparam OP3 = 3'd3;
  localparam OP0 = 3'd4;
  reg [2:0] state = INIT;

  always @(posedge clk) begin
    case (state)
      INIT: begin
        done2 = 0;
        if (start) begin
          a_ = a[`b-1] ? -a : a;
          b_ = b[`b-1] ? -b : b;
          delay = `b'b0;
          delay[`b-1] = 1'b1;
          mod_start = 0;
          state = OP0;
        end
      end
      
      OP0: begin
        multiplicand = a_;
        if (b_[0]) begin
          product <= {1'b0, a_, b_[`b-1:1]};
        end else begin
          product <= {1'b0, `b'b0, b_[`b-1:1]};
        end
        state = OP1;
      end

      OP1: begin
        if (!done) begin
          delay = {1'b0, delay[`b-1:1]};
           if (product[0]) begin
             product <= {sum, product[`b-1:1]};
           end else begin
             product <= {1'b0, product[`b2-1:1]};
           end
//          product = a * b;
        end else begin
           product = (a[`b-1] ^ b[`b-1]) ? -product : product;
          $display("a: %0d", a);
          $display("b: %0d", b);
          $display("product: %0d, %0d", product, -product);
          mod_start = 1;
          state = OP2;
        end
      end

      OP2: begin
        mod_start = 0;
        if (mod_done) begin
           product = mod;
//         product = (a[`b-1] ^ b[`b-1]) ? -mod : mod;
//          done2 = 1;
          state = OP3;
        end
      end
      
      OP3: begin
        done2 = 1;
        state = INIT;
      end

    endcase
  end

endmodule