# Full-Duplex 32-bit UART for SERV RISC-V

This project implements a full-duplex Universal Asynchronous Receiver/Transmitter (UART) designed for the SERV RISC-V environment. The design supports a 32-bit data width with configurable parity (even/odd) and is targeted for a 32 MHz system clock with a 115200 bps baud rate. It is fully synthesizable in Verilog and includes a self-checking testbench for simulation and verification.

## Overview

The UART module is composed of several submodules:

- **Baud Rate Generator:** Produces a baud tick from a 32 MHz clock for a baud rate of 115200 bps.
- **Transmitter (`uart_tx.v`):** Serializes 32-bit data into a UART frame (start bit, 32 data bits, parity bit, and stop bit) using a finite state machine (FSM).
- **Receiver (`uart_rx.v`):** Deserializes incoming serial data, validates it (including parity and stop-bit checking), and outputs a 32-bit word along with error flags.
- **Top-Level Module (`uart_full_duplex_32bit.v`):** Integrates the baud generator, transmitter, and receiver for simultaneous (full-duplex) communication.
- **Testbench (`uart_tb.v`):** Provides a self-checking simulation environment that loops back transmitted data to verify correct operation and error detection.

## Features

- **Full-Duplex Operation:** Enables simultaneous transmission and reception over independent TX and RX lines.
- **32-bit Data Frames:** Supports transferring a full 32-bit word in each frame.
- **Configurable Parity:** Offers selectable parity modes (even/odd) for error detection.
- **Synthesizable Verilog Code:** Suitable for integration into FPGA/ASIC designs using industry-standard tools such as Xilinx Vivado or Intel Quartus.
- **Self-Checking Testbench:** Automatically verifies correct data transfer, parity correctness, and framing integrity.

## File Structure

```
UART/
│
├── README.md                    # Project overview and instructions
├── uart_baud_gen.v              # Baud rate generator module
├── uart_tx.v                    # UART transmitter module
├── uart_rx.v                    # UART receiver module
├── uart_full_duplex_32bit.v     # Top-level full-duplex UART module
└── uart_tb.v                    # Simulation testbench
```

## Getting Started

### Prerequisites

- **Verilog Synthesis and Simulation Tools:**  
  Tools like Xilinx Vivado, Intel Quartus, or ModelSim.
- **Git:** To clone the repository.
- **SERV RISC-V Environment (Optional):**  
  If integrating into a SERV RISC-V based system, ensure your SERV RISC-V toolchain and environment are set up.

### Installation

Clone the repository using Git:

```bash
git clone https://github.com/yourusername/UART.git
```

### Synthesis and Simulation

1. **Synthesis:**
   - Open your FPGA tool (e.g., Vivado).
   - Create a new project and add all Verilog source files.
   - Set `uart_full_duplex_32bit.v` as the top-level module.
   - Run synthesis to generate the hardware netlist.

2. **Simulation:**
   - Open the simulation environment (e.g., Vivado Simulator or ModelSim).
   - Load the `uart_tb.v` testbench.
   - Run the simulation to verify that all tests pass. The testbench should report that "All UART tests passed successfully" if everything is working correctly.

3. **Integration:**
   - Instantiate the top-level module (`uart_full_duplex_32bit.v`) in your larger design (e.g., within a SERV RISC-V system) for serial communication.

## Usage

- **Transmitter Interface:**  
  Input 32-bit parallel data via `tx_data` and initiate a transmission with the `tx_start` signal. The `tx_busy` signal indicates when the module is in the middle of a transmission.

- **Receiver Interface:**  
  The receiver outputs the 32-bit data on `rx_data` and flags when new data is available with `rx_ready`. Error flags (`parity_error` and `framing_error`) indicate reception issues. The `rx_clear` signal is used to acknowledge the received data.

- **Configuration:**  
  Configure the parity mode with the `parity_even_n` signal (0 for even parity, 1 for odd parity). The baud rate and clock frequency are defined by the parameters in the design (32 MHz and 115200 bps by default).

## Key Data Points and Design Insights

- **Block Diagram Insights:**
  - **Modular Architecture:**  
    The design is clearly divided into distinct blocks, including a baud rate generator, transmitter, and receiver. These blocks operate collaboratively to implement the full-duplex UART.
  - **Full-Duplex Operation:**  
    Separate TX and RX paths are identified, enabling simultaneous transmission and reception of data.
  - **Frame Structure:**  
    The transmitter’s FSM is designed to send a start bit, followed by 32 data bits (LSB-first), a configurable parity bit (even/odd), and finally, a stop bit.

- **RTL Schematic Observations:**
  - **Clear Module Interconnection:**  
    The RTL schematic illustrates proper interconnection of the FSM, shift registers, and counters, confirming that the design is both modular and structured.
  - **Timing and Synchronization:**  
    The schematic confirms that the baud rate generator is used to derive the required bit-timing, and the receiver samples the data in the middle of each bit period. The design uses a half-bit delay at the start to center the sampling window.
  - **Parameterization for Scalability:**  
    The use of parameters for data width, clock frequency, and baud rate (e.g., 32 MHz clock and 115200 bps) makes the design adaptable to similar applications, such as integration with the SERV RISC-V processor.

- **Simulation Waveform Highlights:**
  - **Correct Frame Generation:**  
    Simulation waveforms verify that each transmitted frame includes a precise start bit, all 32 data bits in the correct order, the appropriate parity bit, and a stop bit.
  - **Error Detection Validation:**  
    The waveforms demonstrate that parity and stop bit checks function as expected—error flags (parity_error and framing_error) are asserted only under fault conditions.
  - **Seamless Full-Duplex Operation:**  
    The simulation confirms that simultaneous transmission and reception occur without interference, proving the efficacy of the separate TX and RX paths.

- **Additional Diagram Insights:**
  - **Sampling Technique:**  
    Detailed diagrams highlight the design decision to use mid-bit sampling, achieved by introducing a half-bit delay for the start bit, thereby improving robustness in asynchronous operation.
  - **Error Handling:**  
    The analysis confirms that error detection (for both parity and framing errors) is an integral part of the design, with dedicated circuitry ensuring any transmission anomalies are flagged.
  - **Design for Reliability:**  
    The integration of these data points underlines the design’s focus on reliability and error tolerance, which is crucial for industrial or RISC-V-based applications.

- **Performance and Throughput:**
  - **Effective Data Throughput:** With a frame consisting of 1 start bit, 32 data bits, 1 parity bit, and 1 stop bit (total 35 bits), the effective data throughput is approximately:  
    \[
    \text{Effective Throughput} = 115200 \times \frac{32}{35} \approx 105,000 \text{ bits per second}
    \]
    This calculation shows how efficient the design is when transmitting larger data words compared to a standard 8-bit UART.
  - **Baud Tick Generation:** The calculated baud divider using a 32 MHz clock and a 115200 bps baud rate is approximately 278, ensuring the bit period is close to the desired timing with minimal error.

- **Parameterization and Scalability:**
  - **Configurable Parameters:** The design is fully parameterized, making it easy to adjust the data width, clock frequency, and baud rate. This allows the UART to be adapted for various applications beyond SERV RISC-V.
  - **Modularity:** The clear separation into submodules (baud rate generator, transmitter, receiver, parity generator) enables reuse in different projects and simplifies debugging and future enhancements.

- **FSM Efficiency and Sampling Accuracy:**
  - **Finite State Machines:** Both the transmitter and receiver employ efficient state machines with minimal state counts (e.g., IDLE, START, DATA, PARITY, STOP), ensuring a robust yet simple control mechanism.
  - **Mid-Bit Sampling:** The receiver uses a half-bit delay to center the sampling point on each bit, which enhances resilience against clock mismatches and asynchronous noise—a critical factor in reliable serial communication.

- **Error Detection and Robustness:**
  - **Parity and Framing Checks:** The receiver provides dedicated error flags (`parity_error` and `framing_error`) that are asserted if any discrepancy is observed in the parity computation or if the stop bit is not detected as high. This built-in error detection is crucial for mission-critical and industrial applications.
  - **Testbench Validation:** Extensive simulation with diverse test vectors (such as all zeros, all ones, alternating patterns, and mixed values) confirms that the design correctly identifies both normal and erroneous conditions.

- **Resource Utilization:**
  - **Optimized for Low Resource Consumption:** The design’s modular architecture and efficient FSM implementation are crafted to use minimal FPGA resources (logic slices, flip-flops), making it suitable for integration in resource-constrained environments or embedded systems.
  - **Scalability for Complex Systems:** Although designed for 32-bit data, the parameterization ensures that the architecture can be easily scaled for wider data paths or additional error-checking features if needed.

- **Integration and Future Enhancements:**
  - **Ease of Integration:** With a clear top-level module (`uart_full_duplex_32bit.v`) that encapsulates all UART functionality, the design is easy to integrate into larger systems such as the SERV RISC-V environment.
  - **Extendibility:** The design framework allows for future additions, such as configurable stop bits, support for multi-buffering, or more advanced error correction strategies, based on application needs.
  - **Comparative Advantage:** Compared with traditional 8-bit UART designs, the 32-bit approach reduces per-word overhead and enhances data throughput for applications that require larger data transactions.

- **Verification and Community Feedback:**
  - **Comprehensive Testbench:** The self-checking testbench not only validates functionality but also demonstrates the design under various operating conditions—serving as a template for user-driven testing in their specific setups.
  - **Encouragement for Contributions:** The repository welcomes community feedback, suggestions for improvements, and contributions to further enhance reliability, performance, and feature sets.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

- [Keerthivasan Palani](https://github.com/124107157-KV)

## Acknowledgments

- This project was inspired by fundamental UART design concepts and the SERV RISC-V processor.
- Special thanks to the hardware design and FPGA communities for their continued support and shared resources.
