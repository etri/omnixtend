# OmniXtend-Verilog

Verilog RTL implementation of the OmniXtend memory coherence protocol, targeting FPGA synthesis and Chipyard-based SoC integration.

## Overview

This module provides synthesizable Verilog RTL for OmniXtend protocol logic, including Ethernet MAC interfacing, TLoE packet framing, and TileLink channel handling. Designed for direct integration into Chipyard-generated SoC designs via BlackBox wrappers.

## Module Hierarchy

- **ox_top**: Top-level module integrating all OmniXtend protocol components
- **ox_eth_mac**: Ethernet MAC interface supporting 10G/25G link speeds
- **ox_tloe_framer**: TLoE frame encoder/decoder for Ethernet payload packing
- **ox_tilelink_handler**: TileLink A/D channel request and response handler
- **ox_credit_manager**: Flow control and credit-based backpressure logic

## Supported Platforms

| Platform        | Interface | Status   |
|----------------|-----------|----------|
| Xilinx VCU118  | 10G SFP+  | Verified |
| Xilinx AU280   | 10G QSFP  | Verified |

## Simulation

```bash
# Run Verilog testbench
make sim
make sim_wave   # with waveform dump
```

## Synthesis

Synthesizable with Vivado 2021.2+. Constraint files for supported platforms are included under `constraints/`.
