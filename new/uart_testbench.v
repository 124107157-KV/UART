`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 16:20:32
// Design Name: 
// Module Name: uart_testbench
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


module uart_testbench;
    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk;  // 100 MHz clock period (10 ns) - faster than needed for simulation

    // DUT instance
    reg rst_n;
    reg tx_start;
    reg [31:0] tx_data;
    wire tx_busy;
    wire [31:0] rx_data;
    wire rx_ready;
    reg rx_clear;
    reg parity_even_n;
    wire parity_error;
    wire framing_error;
    // Loopback wiring: connect TX output to RX input
    wire uart_tx;
    wire uart_rx;
    assign uart_rx = uart_tx;

    uart_full_duplex_32bit #(.CLK_FREQ(32000000), .BAUD_RATE(115200)) DUT (
        .clk(clk), .rst_n(rst_n),
        .tx_start(tx_start), .tx_data(tx_data), .tx_busy(tx_busy),
        .rx_data(rx_data), .rx_ready(rx_ready), .rx_clear(rx_clear),
        .parity_even_n(parity_even_n),
        .uart_tx(uart_tx), .uart_rx(uart_rx),
        .parity_error(parity_error), .framing_error(framing_error)
    );

    // Test sequence
    localparam integer NUM_TEST = 5;
    reg [31:0] test_vectors [0:NUM_TEST-1];
    integer idx;
    reg error_flag;

    initial begin
        // Initialize test patterns
        test_vectors[0] = 32'h00000000;
        test_vectors[1] = 32'hFFFFFFFF;
        test_vectors[2] = 32'hA5A5A5A5;
        test_vectors[3] = 32'hF0F0F0F1;
        test_vectors[4] = 32'h12345678;
        // Initialize signals
        rst_n = 0;
        tx_start = 0;
        tx_data = 32'd0;
        rx_clear = 0;
        parity_even_n = 0;  // start with even parity
        error_flag = 0;
        // Apply reset
        #100;
        rst_n = 1;
    end

    // Testbench FSM to send and verify data
    reg [3:0] tb_state = 0;
    reg [3:0] test_count = 0;
    always @(posedge clk) begin
        if (!rst_n) begin
            tb_state <= 0;
            test_count <= 0;
            tx_start <= 0;
            rx_clear <= 0;
            parity_even_n <= 0;
        end else begin
            case(tb_state)
            0: begin  // start of even parity tests
                parity_even_n <= 0;  // even parity mode
                test_count <= 0;
                tb_state <= 1;
            end
            1: begin  // initiate transmission of test_vectors[test_count]
                if (!tx_busy && rx_ready == 0) begin  // ensure previous done
                    tx_data <= test_vectors[test_count];
                    tx_start <= 1'b1;
                    tb_state <= 2;
                end
            end
            2: begin  // drop tx_start after one cycle
                tx_start <= 1'b0;
                tb_state <= 3;
            end
            3: begin  // wait for reception to complete
                if (rx_ready) begin
                    // Check received data matches transmitted
                    if (rx_data !== test_vectors[test_count]) begin
                        $display("ERROR: Data mismatch! Sent %h, got %h", 
                                 test_vectors[test_count], rx_data);
                        error_flag <= 1'b1;
                    end
                    // Check for unexpected errors
                    if (parity_error || framing_error) begin
                        $display("ERROR: Received error flags (parity_error=%b, framing_error=%b) for data %h",
                                 parity_error, framing_error, rx_data);
                        error_flag <= 1'b1;
                    end
                    tb_state <= 4;
                end
            end
            4: begin  // clear the rx_ready flag (simulate CPU read)
                rx_clear <= 1'b1;
                tb_state <= 5;
            end
            5: begin
                rx_clear <= 1'b0;
                // Move to next test vector
                test_count <= test_count + 1;
                if (test_count < 3) begin
                    // More values to test with even parity
                    tb_state <= 1;  // send next
                end else begin
                    // Finished even parity tests, switch to odd parity
                    tb_state <= 6;
                end
            end
            6: begin  // start of odd parity tests
                parity_even_n <= 1;  // odd parity mode
                test_count <= 3;     // (reuse some vectors starting from index 3)
                tb_state <= 7;
            end
            7: begin  // send vectors in odd parity mode
                if (!tx_busy && rx_ready == 0) begin
                    tx_data <= test_vectors[test_count];
                    tx_start <= 1'b1;
                    tb_state <= 8;
                end
            end
            8: begin 
                tx_start <= 1'b0;
                tb_state <= 9;
            end
            9: begin  // wait for rx_ready
                if (rx_ready) begin
                    if (rx_data !== test_vectors[test_count]) begin
                        $display("ERROR: Data mismatch in odd parity! Sent %h, got %h", 
                                 test_vectors[test_count], rx_data);
                        error_flag <= 1'b1;
                    end
                    if (parity_error || framing_error) begin
                        $display("ERROR: Error flags set in odd parity mode for data %h", rx_data);
                        error_flag <= 1'b1;
                    end
                    tb_state <= 10;
                end
            end
            10: begin  // clear ready
                rx_clear <= 1'b1;
                tb_state <= 11;
            end
            11: begin
                rx_clear <= 1'b0;
                // Move to next odd parity test
                test_count <= test_count + 1;
                if (test_count < 5) begin
                    tb_state <= 7;  // continue with next vector
                end else begin
                    tb_state <= 12; // done with all tests
                end
            end
            12: begin
                // All tests done. Optionally, check error_flag.
                if (!error_flag) 
                    $display("All UART tests passed successfully.");
                else 
                    $display("One or more UART tests FAILED.");
                $stop;  // end simulation
            end
            endcase
        end
    end
endmodule
