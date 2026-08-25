module uart_top #(
    parameter CLK_FREQ  = 1_000_000,
    parameter BAUD_RATE = 10_000
)(
    input wire       clk,
    input wire       rst,
    input wire       tx_start,
    input wire [7:0] tx_data,

    output wire      tx,
    output wire [7:0] rx_data,
    output wire      rx_done
);

    wire tx_busy;

    // UART Transmitter
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // UART Receiver
    // TX output is directly connected to RX input
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule
