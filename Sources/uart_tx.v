`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 16:18:23
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    parameter WIDTH = 32
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,           // trigger to start transmission
    input  wire [WIDTH-1:0] tx_data,      // parallel data to transmit
    input  wire       parity_even_n,      // parity mode (0=even, 1=odd)
    input  wire       baud_tick,          // baud rate strobe (1 cycle pulse)
    output reg        tx_line,            // serial TX output line
    output reg        tx_busy             // transmitter busy flag
);
    // States for TX FSM
    localparam [2:0] IDLE=3'd0, START=3'd1, DATA=3'd2, PARITY=3'd3, STOP=3'd4;
    reg [2:0] state;
    reg [5:0] tx_bit_count;         // needs to count up to 32
    reg       parity_bit; 
    reg [WIDTH-1:0] data_buf;      // buffer to hold data being shifted (LSB first)

    // Parity generator instance (combinational)
    wire calc_parity;
    uart_parity_gen #(.WIDTH(WIDTH)) PARITY_GEN (
        .data(data_buf),
        .parity_even_n(parity_even_n),
        .parity_bit(calc_parity)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_line <= 1'b1;       // idle line is high
            tx_busy <= 1'b0;
            tx_bit_count <= 0;
            data_buf <= {WIDTH{1'b0}};
            parity_bit <= 1'b0;
        end else begin
            case (state)
            IDLE: begin
                tx_line <= 1'b1;
                tx_busy <= 1'b0;
                tx_bit_count <= 0;
                if (tx_start) begin
                    // Latch data and compute parity when transmission starts
                    data_buf <= tx_data;
                    parity_bit <= (^tx_data) ^ parity_even_n;  // even parity XOR, invert if odd
                    tx_busy <= 1'b1;
                    state <= START;
                end
            end

            START: begin
                // Send start bit (0) for one baud period
                if (baud_tick) begin
                    tx_line <= 1'b0;
                    // After one tick, move to DATA state
                    state <= DATA;
                    tx_bit_count <= 0;
                end
            end

            DATA: begin
                if (baud_tick) begin
                    // Output next data bit
                    tx_line <= data_buf[0];               // LSB first
                    data_buf <= {1'b0, data_buf[WIDTH-1:1]};  // shift right
                    tx_bit_count <= tx_bit_count + 1;
                    // If all data bits sent, move to PARITY
                    if (tx_bit_count == WIDTH-1) begin
                        state <= PARITY;
                    end
                end
            end

            PARITY: begin
                if (baud_tick) begin
                    tx_line <= parity_bit;  // send parity bit
                    state <= STOP;
                end
            end

            STOP: begin
                if (baud_tick) begin
                    tx_line <= 1'b1;   // send stop bit (line high)
                    // After stop bit, return to IDLE (transmission complete)
                    state <= IDLE;
                    tx_busy <= 1'b0;
                end
            end

            default: state <= IDLE;
            endcase
        end
    end
endmodule

