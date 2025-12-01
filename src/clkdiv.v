module clkdiv #(
    parameter DIVISOR = 2
) (
    input wire rst_n,
    input wire clk_in,
    output reg clk_out
);

// Calculate minimum counter width based on DIVISOR
localparam CNT_WIDTH = $clog2(DIVISOR);
reg [CNT_WIDTH-1:0] counter;

// Precompute half divisor value
localparam HALF_DIV = DIVISOR >> 1;

always @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
        counter <= {CNT_WIDTH{1'b0}};
        clk_out <= 1'b0;
    end else begin
        if (counter >= DIVISOR - 1) begin
            counter <= {CNT_WIDTH{1'b0}};
        end else begin
            counter <= counter + 1'b1;
        end
        
        // Toggle output at half point
        clk_out <= (counter < HALF_DIV);
    end
end

endmodule
