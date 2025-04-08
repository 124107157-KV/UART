`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 16:17:00
// Design Name: 
// Module Name: uart_baud_gen
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


// Baud Rate Generator: produces baud_tick pulses at desired baud rate.
module uart_baud_gen #(
    parameter CLK_FREQ = 32000000,       // system clock (Hz)
    parameter BAUD_RATE = 115200         // target baud rate (bps)
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);
    // Compute divisor: number of clocks per baud tick (integer approximation).
    localparam integer BAUD_DIV = (CLK_FREQ + BAUD_RATE/2) / BAUD_RATE;
    // Counter registers
    reg [31:0] count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (count >= BAUD_DIV-1) begin
                count <= 0;
                baud_tick <= 1'b1;   // assert tick on last count
            end else begin
                count <= count + 1;
                baud_tick <= 1'b0;
            end
        end
    end
endmodule

