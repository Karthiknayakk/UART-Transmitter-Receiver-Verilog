module uart_rx #(
    parameter CLK_FREQ  = 1_000_000,
    parameter BAUD_RATE = 10_000
)(
    input wire       clk,
    input wire       rst,
    input wire       rx,

    output reg [7:0] rx_data,
    output reg       rx_done
);

    localparam integer BAUD_COUNT = CLK_FREQ / BAUD_RATE;

    reg [31:0] baud_counter;
    reg [3:0]  bit_index;
    reg [7:0]  rx_shift;
    reg        receiving;

    always @(posedge clk) begin

        if (rst) begin
            baud_counter <= 0;
            bit_index    <= 0;
            rx_shift     <= 0;
            rx_data      <= 0;
            rx_done      <= 0;
            receiving    <= 0;
        end

        else begin

            // rx_done is a one-clock pulse
            rx_done <= 1'b0;

            // Wait for start bit
            if (!receiving) begin

                if (rx == 1'b0) begin
                    receiving    <= 1'b1;
                    baud_counter <= 0;
                    bit_index    <= 0;
                    rx_shift     <= 0;
                end
            end

            else begin

                // Check the center of the start bit
                if (bit_index == 0 &&
                    baud_counter == (BAUD_COUNT/2 - 1)) begin

                    baud_counter <= 0;

                    // Invalid start bit
                    if (rx != 1'b0)
                        receiving <= 1'b0;
                end

                // Receive 8 data bits
                else if (bit_index < 8 &&
                         baud_counter == BAUD_COUNT - 1) begin

                    baud_counter <= 0;

                    // UART receives LSB first
                    rx_shift[bit_index] <= rx;

                    bit_index <= bit_index + 1'b1;
                end

                // Check stop bit
                else if (bit_index == 8 &&
                         baud_counter == BAUD_COUNT - 1) begin

                    baud_counter <= 0;

                    // Stop bit must be HIGH
                    if (rx == 1'b1) begin
                        rx_data <= rx_shift;
                        rx_done <= 1'b1;
                    end

                    receiving <= 1'b0;
                    bit_index <= 0;
                end

                else begin
                    baud_counter <= baud_counter + 1'b1;
                end
            end
        end
    end

endmodule
