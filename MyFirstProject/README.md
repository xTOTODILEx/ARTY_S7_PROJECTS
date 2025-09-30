
# Project 1: Blinky (Arty S7)

## 🎯 Objective
Get the Arty S7 FPGA board **set up and tested** by running the classic **blinky LED** design.  
This confirms the hardware is properly powered, recognized by Vivado, and able to run custom Verilog code.

---

## 🛠️ Steps

### 1. Hardware Setup
- Connect Arty S7 board to PC using USB cable.
- Ensure jumper is set to **JTAG** for programming.
- Power on the board and check the "DONE" LED lights up after configuration.

### 2. Tool Setup
- Install **Xilinx Vivado WebPACK** (free edition).
- Verify the board is detected under *Hardware Manager* in Vivado.

### 3. HDL Code (Verilog)
Simple clock divider + LED toggle.