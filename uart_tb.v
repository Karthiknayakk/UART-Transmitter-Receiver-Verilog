`timescale 1ns/1ps

module uart_tb;

    reg        clk;
    reg        rst;
    reg        tx_start;
    reg [7:0]  tx_data;

    wire       tx;
    wire [7:0] rx_data;
    wire       rx_done;

    uart_top #(
        .CLK_FREQ(1_000_000),
        .BAUD_RATE(10_000)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 1 MHz clock
    initial begin
        clk = 1'b0;
        forever #500 clk = ~clk;
    end

    initial begin

        rst      = 1'b1;
        tx_start = 1'b0;
        tx_data  = 8'b00000000;

        #5000;

        rst = 1'b0;

        // Send byte
        tx_data  = 8'b10101010;
        tx_start = 1'b1;

        #1000;
        tx_start = 1'b0;

        // Wait until receiver completes
        @(posedge rx_done);

        // Check received byte
        if (rx_data == 8'b10101010) begin
            $display("--------------------------------");
            $display("TEST PASSED");
            $display("TX DATA = %b", tx_data);
            $display("RX DATA = %b", rx_data);
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("TEST FAILED");
            $display("TX DATA = %b", tx_data);
            $display("RX DATA = %b", rx_data);
            $display("--------------------------------");
        end

        #1000;
        $finish;
    end

    // Waveform generation
    initial begin
        $dumpfile("uart_waveform.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule
