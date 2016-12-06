`define b 256
`define b2 512

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