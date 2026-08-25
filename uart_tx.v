module uart_tx #(
    parameter CLK_FREQ  = 1_000_000,
    parameter BAUD_RATE = 10_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        tx_busy
);

    localparam integer BAUD_COUNT = CLK_FREQ / BAUD_RATE;

    reg [31:0] baud_counter;
    reg [3:0]  bit_index;
    reg [9:0]  tx_shift;

    always @(posedge clk) begin

        if (rst) begin
            tx           <= 1'b1;
            tx_busy      <= 1'b0;
            baud_counter <= 0;
            bit_index    <= 0;
            tx_shift     <= 0;
        end

        else begin

            // Start a new UART transmission
            if (tx_start && !tx_busy) begin

                // UART frame:
                // START + 8 DATA BITS + STOP
                // START = 0, STOP = 1
                tx_shift <= {1'b1, tx_data, 1'b0};

                tx_busy      <= 1'b1;
                baud_counter <= 0;
                bit_index    <= 0;

                // Send start bit immediately
                tx <= 1'b0;
            end

            // Transmission in progress
            else if (tx_busy) begin

                if (baud_counter == BAUD_COUNT - 1) begin

                    baud_counter <= 0;

                    if (bit_index == 9) begin

                        // Transmission complete
                        tx      <= 1'b1;
                        tx_busy <= 1'b0;
                        bit_index <= 0;

                    end

                    else begin

                        bit_index <= bit_index + 1'b1;

                        // Send next bit
                        tx <= tx_shift[bit_index + 1'b1];

                    end
                end

                else begin
                    baud_counter <= baud_counter + 1'b1;
                end
            end
        end
    end

endmodule
