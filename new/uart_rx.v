`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 16:18:23
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 32-bit UART Receiver with Parity and Framing Error Detection
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter WIDTH = 32
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_line,        // serial RX input line
    input  wire       parity_even_n,  // parity mode (0=even, 1=odd) - must match transmitter
    input  wire       rx_clear,       // clear signal for rx_ready flag (acknowledge data read)
    output reg  [WIDTH-1:0] rx_data,  // received parallel data
    output reg        rx_ready,       // indicates a received word is ready
    output reg        parity_error,   // parity check failure flag
    output reg        framing_error   // stop-bit (framing) error flag
);
    // States for RX FSM
    localparam [2:0] RX_IDLE   = 3'd0,
                     RX_START  = 3'd1,
                     RX_DATA   = 3'd2,
                     RX_PARITY = 3'd3,
                     RX_STOP   = 3'd4;
                     
    reg [2:0] state;
    reg [5:0] rx_bit_count;
    reg [15:0] baud_count;  // counter for baud timing (size enough for clock divisor)
    
    // Parameter: number of system clocks per bit (same BAUD_DIV as in a baud_gen module)
    localparam integer CLK_FREQ = 32000000;
    localparam integer BAUD_RATE = 115200;
    localparam integer BAUD_DIV = (CLK_FREQ + BAUD_RATE/2) / BAUD_RATE;  // rounding to nearest int

    // Compute expected parity as a combinational signal (must be computed once rx_data is settled)
    // XOR reduction of rx_data yields 1 if an odd number of bits are '1'
    wire expected_parity;
    assign expected_parity = (^rx_data) ^ parity_even_n;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= RX_IDLE;
            rx_bit_count <= 0;
            baud_count <= 0;
            rx_data <= {WIDTH{1'b0}};
            rx_ready <= 1'b0;
            parity_error <= 1'b0;
            framing_error <= 1'b0;
        end else begin
            case (state)
            RX_IDLE: begin
                rx_ready <= 1'b0;
                parity_error <= 1'b0;
                framing_error <= 1'b0;
                rx_bit_count <= 0;
                if (rx_line == 1'b0) begin  // detect start bit (falling edge)
                    // Initialize counter to half-bit delay to sample middle of start bit
                    baud_count <= (BAUD_DIV >> 1);  // half of baud interval
                    state <= RX_START;
                end
                // If rx_clear asserted (data was read), clear the ready flag (if still set)
                if (rx_clear)
                    rx_ready <= 1'b0;
            end

            RX_START: begin
                if (baud_count > 0)
                    baud_count <= baud_count - 1;
                else begin
                    // Half bit time passed, sample line to confirm start
                    if (rx_line == 1'b0) begin
                        // Valid start; wait a full bit period before sampling first data bit
                        baud_count <= BAUD_DIV - 1; 
                        rx_bit_count <= 0;
                        state <= RX_DATA;
                    end else begin
                        // False start; go back to idle
                        state <= RX_IDLE;
                    end
                end
            end

            RX_DATA: begin
                if (baud_count > 0)
                    baud_count <= baud_count - 1;
                else begin
                    // One bit period elapsed - sample the next data bit
                    rx_data[rx_bit_count] <= rx_line;  // capture bit (LSB first)
                    rx_bit_count <= rx_bit_count + 1;
                    // Prepare for next bit or move to parity state
                    if (rx_bit_count == WIDTH - 1) begin
                        // Last data bit received; next sample will be parity
                        baud_count <= BAUD_DIV - 1;
                        state <= RX_PARITY;
                    end else begin
                        // More data bits to receive
                        baud_count <= BAUD_DIV - 1;
                        // remain in RX_DATA state for next bit
                    end
                end
            end

            RX_PARITY: begin
                if (baud_count > 0)
                    baud_count <= baud_count - 1;
                else begin
                    // Sample parity bit
                    if (rx_line != expected_parity) 
                        parity_error <= 1'b1;
                    // Now wait for stop bit
                    baud_count <= BAUD_DIV - 1;
                    state <= RX_STOP;
                end
            end

            RX_STOP: begin
                if (baud_count > 0)
                    baud_count <= baud_count - 1;
                else begin
                    // Sample stop bit
                    if (rx_line != 1'b1)
                        framing_error <= 1'b1;
                    // Word reception complete; flag that rx_data is valid
                    rx_ready <= 1'b1;
                    state <= RX_IDLE;
                end
            end

            default: state <= RX_IDLE;
            endcase
        end
    end
endmodule
