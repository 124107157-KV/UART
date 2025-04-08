`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 16:17:48
// Design Name: 
// Module Name: uart_parity_gen
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


// Parity Generator: computes even or odd parity bit for given data
module uart_parity_gen #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] data,
    input  wire parity_even_n,  // 0 for even parity, 1 for odd parity
    output wire parity_bit
);
    // XOR reduction of data gives even parity bit (1 if an odd number of ones in data)
    wire even_parity = ^data; 
    assign parity_bit = (parity_even_n) ? ~even_parity : even_parity;
endmodule

