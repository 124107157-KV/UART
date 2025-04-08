`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 16:20:32
// Design Name: 
// Module Name: uart_full_duplex_32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_full_duplex_32bit #(
    parameter CLK_FREQ = 32000000,
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire        rst_n,
    // TX interface
    input  wire        tx_start,
    input  wire [31:0] tx_data,
    output wire        tx_busy,
    // RX interface
    output wire [31:0] rx_data,
    output wire        rx_ready,
    input  wire        rx_clear,
    // Configuration
    input  wire        parity_even_n,   // 0 = even parity, 1 = odd parity
    // Serial lines
    output wire        uart_tx,   // UART transmit line to external device
    input  wire        uart_rx    // UART receive line from external device
);
    // Instantiate baud rate generator
    wire baud_tick;
    uart_baud_gen #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) BAUDGEN (
        .clk(clk), .rst_n(rst_n), .baud_tick(baud_tick)
    );

    // Instantiate Transmitter
    uart_tx #(.WIDTH(32)) TX (
        .clk(clk), .rst_n(rst_n),
        .tx_start(tx_start), .tx_data(tx_data),
        .parity_even_n(parity_even_n),
        .baud_tick(baud_tick),
        .tx_line(uart_tx),
        .tx_busy(tx_busy)
    );

    // Instantiate Receiver
    uart_rx #(.WIDTH(32)) RX (
        .clk(clk), .rst_n(rst_n),
        .rx_line(uart_rx),
        .parity_even_n(parity_even_n),
        .rx_clear(rx_clear),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .parity_error(parity_error),
        .framing_error(framing_error)
    );
endmodule

