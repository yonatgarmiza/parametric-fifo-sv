# Synchronous FIFO – SystemVerilog
Clean RTL implementation with verification-driven development approach.

## Overview

This project implements a parameterized synchronous FIFO in SystemVerilog, developed using clean RTL design principles and verification-driven methodology.

The FIFO operates in a single clock domain and uses pointer-based full/empty detection with wrap-bit logic.  
A fully self-checking testbench is included to validate functionality and corner cases.

---

## Features

- Parameterized `WIDTH` and `DEPTH`
- Pointer-based FIFO implementation
- Wrap-bit full detection logic
- Simultaneous read and write support
- Self-checking testbench
- Assertion-based verification
- Full and drain stress testing
- Clean RTL structure (separated RTL and TB)

---

## Parameters

- `WIDTH` – Data width (default: 8)
- `DEPTH` – Number of FIFO entries (default: 256)

⚠️ **Note:**  
`DEPTH` must be a power of 2.  
The design relies on `$clog2(DEPTH)` and MSB wrap-bit detection for correct full/empty behavior.

---

## Interface

### Inputs

- `clk` – System clock  
- `reset` – Active-high synchronous reset  
- `write_en` – Write enable  
- `read_en` – Read enable  
- `data_in [WIDTH-1:0]` – Input data  

### Outputs

- `data_out [WIDTH-1:0]` – Output data  
- `full` – FIFO full flag  
- `empty` – FIFO empty flag  

---

## Design Architecture

- Memory implemented as: `mem [DEPTH-1:0]`
- Write and read pointers include an extra MSB for wrap detection

### Flag Logic

- `empty` when `w_ptr == r_ptr`
- `full` when write address equals read address **and** wrap bits are different

---

## Read Behavior

- `data_out` updates only when `read_en` is asserted and FIFO is not empty
- Output data becomes valid one clock cycle after read enable
- This design is **not show-ahead**

---

## Simultaneous Read & Write

- Read and write operations may occur in the same clock cycle (when not full/empty)
- Write and read pointers advance independently
- FIFO occupancy remains unchanged when both operations occur simultaneously

---

## Verification Strategy

The testbench includes:

- Reset validation
- Single write → read test
- Sequential write/read order verification
- Full condition test (fill to DEPTH)
- Drain test (read all entries)
- Simultaneous read/write validation
- Assertions for:
  - Data correctness
  - Flag correctness
  - Order preservation

Simulation terminates automatically using `$fatal` on failure.

---

## Simulation

Compatible with standard SystemVerilog simulators:

- Vivado XSIM
- ModelSim
- Questa
- Xcelium

### Steps

1. Compile `fifo_sync.sv`
2. Compile `fifo_sync_tb.sv`
3. Run simulation
4. Observe console output for pass/fail messages

---

## Project Structure

parametric-fifo-sv/
│
├── rtl/
│ └── fifo_sync.sv
│
├── tb/
│ └── fifo_sync_tb.sv
│
└── README.md


---

## Learning Objectives

This project demonstrates:

- Parameterized RTL design
- Pointer-based FIFO architecture
- Wrap-bit full detection
- Assertion-based verification
- Verification-driven development mindset
