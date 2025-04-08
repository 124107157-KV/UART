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

## License

This project is licensed under the [MIT License](LICENSE).

## Author

- [Keerthivasan Palani](https://github.com/124107157-KV)

## Acknowledgments

- This project was inspired by fundamental UART design concepts and the SERV RISC-V processor.
- Special thanks to the hardware design and FPGA communities for their continued support and shared resources.
