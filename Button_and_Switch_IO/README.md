# Button Debounce and LED Control (Arty S7-50)

> **Goal:** Prove the board + toolchain are solid by debouncing a pushbutton and driving LED patterns from a clean, debounced press. Includes short/long press behavior and a simple state machine.

---

## Overview
This project demonstrates **button debouncing** and **LED pattern control** on the **Arty S7-50** FPGA board.  
The `button.sv` module:
- Debounces a mechanical button input
- Detects **short** vs **long** presses
- Cycles through **four LED patterns** on each short press
- Shows a **running animation** while the button is long-pressed

---

## Features
- **Button Debouncing:** Filters mechanical bounce to prevent false triggers.
- **Long-Press Detection:** Recognizes a hold > 2 seconds (configurable).
- **State Machine:** Cycles four distinct LED patterns per short press.
- **Animated Pattern:** Displays a running LED effect during long press.
- **Parameterizable:** Adjust `CLK_HZ` and `DEBOUNCE_MS` via parameters.

