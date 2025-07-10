
# 📘 Project Summary: Final Project for Digital Logic Design

**Course**: Digital Logic Design  
**Academic Year**: 2022/2023  
**Instructor**: Prof. Gianluca Palermo  
**Authors**:  
- Daniel Shala – ID: 10710181  
- Jurij Diego Scandola – ID: 10709931  
**Final Grade**: 28/30 (in pairs)

---

## 🎯 Objective

The goal of this project is to implement a **hardware component in VHDL** capable of interfacing with memory and routing a data signal through a multiplexer to one of four output channels based on an input command.

---

## ⚙️ Component Functionality

- The system receives a serial input signal `i_w`, with the first 2 bits selecting the output channel (`Z0`–`Z3`), and the remaining bits (up to 16) indicating the **memory address**.
- The input is only considered valid when `i_start = 1`, and this condition lasts between 2 and 18 clock cycles.
- The data read from memory is output to the selected channel, and the `o_done` signal is asserted for 1 clock cycle to signal completion.

---

## 🔌 Interface

| Signal       | Direction | Description                                 |
|--------------|-----------|---------------------------------------------|
| `i_clk`      | Input     | System clock                                |
| `i_rst`      | Input     | Asynchronous reset                          |
| `i_start`    | Input     | Start of transmission                       |
| `i_w`        | Input     | Serial data input                           |
| `i_mem_data` | Input     | 8-bit data received from memory             |
| `o_mem_addr` | Output    | 16-bit memory address                       |
| `o_mem_en`   | Output    | Memory enable                               |
| `o_mem_we`   | Output    | Memory write enable (must be 0 to read)     |
| `o_z0`–`o_z3`| Output    | 8-bit multiplexer output channels           |
| `o_done`     | Output    | High for 1 clock cycle when output is valid |

---

## 🧠 FSM Design

The component is implemented as a **Finite State Machine (FSM)** with 8 states:

1. **IDLE** – Wait for `i_start = 1`
2. **HEADER** – Store channel selection bits
3. **GET_ADDRESS** – Accumulate memory address bits while `i_start = 1`
4. **WAIT_RAM** – Wait for memory to respond
5. **GET_DATA** – Retrieve and route data to the selected channel
6. **WAIT_DATA** – Delay to handle synchronization
7. **WRITE_OUT** – Finalize write to output channel
8. **DONE** – Reset internal state and return to IDLE

---

## ✅ Testing & Results

Tests included edge cases and functional coverage:

- **Start = 1 for 18 cycles** → maximum address input (0xFFFF), routed to Z3.
- **Start = 1 for 2 cycles** → minimum input (0x0000), routed to Z0.
- **Asynchronous Reset** → verified proper reset behavior mid-operation.
- **Stress test** → verified system behavior across 1276 input events.

Simulation passed in **Behavioral**, **Post-Synthesis Functional**, and **Timing** stages.

---

## 🚀 Optimizations

- FSM-based logic replaced initial counter-based design for better accuracy.
- Temporary states (e.g., `WAIT_DATA`) added to ensure timing correctness.
- Reduced use of latches to avoid synthesis warnings in Vivado.
