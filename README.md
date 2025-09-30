# ARTY_S7_PROJECTS
Set of projects to get a hang of ARTY S7 FPGA, final goal to implement a DDR3 controller and test it.

# FPGA Learning Roadmap on Arty S7

## 🎯 Goal
Step-by-step FPGA projects on the Arty S7 board, building the skills needed to **design, implement, and test a DDR3 memory controller**.

---

## 📂 Project Roadmap

### Project 1: Blinky
- Implement a simple LED blink using an onboard clock divider.
- Deliverables:
  - HDL design (Verilog/VHDL)
  - Simulation of clock divider
  - Demo running on Arty S7

---

### Project 2: Button & Switch I/O
- Learn to read input from push buttons and switches.
- Implement debouncing logic and LED pattern changes.
- Deliverables:
  - Input synchronization logic
  - State machine for LED patterns
  - Simulation + hardware demo

---

### Project 3: UART Communication
- Set up UART to communicate with a PC.
- Send/receive characters and display activity on LEDs.
- Deliverables:
  - UART TX/RX modules
  - Testbench with stimulus
  - Serial terminal demo

---

### Project 4: FIFO & Clock Domain Crossing
- Implement synchronous and asynchronous FIFOs.
- Practice clock domain crossing (CDC) concepts.
- Deliverables:
  - FIFO modules (sync + async)
  - CDC verification in simulation
  - Demo buffering data from one clock domain to another

---

### Project 5: AXI4-Lite Peripheral
- Create a simple AXI4-Lite slave peripheral.
- Control LEDs or counters via AXI transactions.
- Deliverables:
  - AXI4-Lite slave interface HDL
  - Testbench for AXI transactions
  - Vivado block design integration

---

### Project 6: AXI4-Stream Data Path
- Build a streaming data pipeline using AXI4-Stream.
- Test with generated data flowing through FIFO and out to UART/LEDs.
- Deliverables:
  - AXI4-Stream modules
  - Testbench with stimulus packets
  - On-board streaming demo

---

### Project 7: DDR3 Controller Integration
- Study Xilinx MIG (Memory Interface Generator) IP for DDR3.
- Connect MIG DDR3 controller to AXI interconnect.
- Write/Read test patterns to DDR3 memory.
- Deliverables:
  - DDR3 memory testbench
  - Write/read verification
  - Hardware demo with DDR3 test patterns

---

## 📘 Learning Outcomes
- Master FPGA fundamentals on the Arty S7.
- Gain hands-on practice with **state machines, CDC, FIFOs, and AXI protocols**.
- Learn how to integrate and test complex IP like DDR3 memory controllers.
- Build confidence moving from **simple I/O designs** to **high-speed memory systems**.

---

## 🛠️ Tools & Requirements
- **Board**: Digilent Arty S7 (Spartan-7 FPGA)
- **Software**: Xilinx Vivado (WebPACK edition)
- **Languages**: Verilog / VHDL
- **Simulator**: Vivado Simulator / ModelSim / Questa
- **Extras**: USB-to-UART cable, Serial terminal (PuTTY / TeraTerm)

---

## 🚀 Final Milestone
A **working DDR3 memory controller on the Arty S7**, verified by writing and reading back data patterns from external DDR3 memory.  
This demonstrates end-to-end FPGA design flow, protocol understanding, and memory system testing.
