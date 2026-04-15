# Scripts

Common environment setup, build automation, and deployment scripts for the OmniXtend project.

## Overview

This directory contains helper scripts for building, configuring, and deploying OmniXtend components across different environments, including host machines, FPGA boards, and simulation platforms.

## Script Categories

### Environment Setup

- Configure build toolchains for Chisel (Scala/SBT) and Verilog (Vivado) workflows
- Set up network interfaces for OmniXtend Ethernet communication
- Initialize FPGA programming environments

### Build Automation

- Unified build scripts for compiling C, Verilog, and Chisel components
- Bitstream generation workflows for supported FPGA platforms (VCU118, AU280)

### Deployment

- FPGA programming and configuration utilities
- MemoryNode service management
- Network interface setup for OmniXtend traffic

## Usage

All scripts are designed to be run from the repository root:

```bash
# Example: setup the build environment
source scripts/setup_env.sh

# Example: build all components
./scripts/build_all.sh
```

Refer to individual script headers for detailed usage instructions and required environment variables.
