`define b 256
`define b2 512

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

  reg [`b-1:0] r, q;

  wire [`b:0] sum = {1'b0, product[`b2-1:`b]} + {1'b0, multiplicand};

  // reg [1:0] lala;
  // assign done2 = !(| lala);

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
  localparam OP4 = 3'd4;

  reg [2:0] state = INIT;

  always @(posedge clk) begin
    case (state)
      INIT: begin
        done2 = 0;
        if (start) begin
          delay = `b'b0;
          delay[`b-1] = 1'b1;
          multiplicand = a;
          mod_start = 0;

          if (b[0]) begin
            product <= {1'b0, a, b[`b-1:1]};
          end else begin
            product <= {1'b0, `b'b0, b[`b-1:1]};
          end

          state = OP1;
        end
      end

      OP1: begin
        if (!done) begin
          delay = {1'b0, delay[`b-1:1]};
          if (product[0]) begin
            product <= {sum, product[`b-1:1]};
          end else begin
            product <= {1'b0, product[`b2-1:1]};
          end
        end else begin
          mod_start = 1;
          state = OP2;
        end
      end

      // WHY DO WE NEED THIS DELAY FOR mod_start
      OP2: begin
        state = OP3;
      end

      OP3: begin
        mod_start = 0;
        if (mod_done) begin
          product = mod;
//          done2 = 1;
          state = OP4;
        end
      end
      
      OP4: begin
        done2 = 1;
        state = INIT;
      end

    endcase
  end

endmodule