# OmniXtend-Chisel

Chisel-based implementation of the OmniXtend memory coherence protocol, designed for seamless integration with the **Chipyard** SoC framework.

## Overview

This module provides high-level Chisel components that implement the OmniXtend protocol stack, including TileLink-over-Ethernet (TLoE) bridges, protocol transactors, and configurable coherence interfaces.

## Key Components

- **OXBridge**: TileLink-to-Ethernet bridge module for connecting on-chip coherence fabric to Ethernet-based memory nodes
- **OXTransactor**: Protocol transactor handling TLoE message sequencing, flow control, and credit management
- **OXConfig**: Parameterized configuration interface for flexible deployment across different SoC topologies

## Integration with Chipyard

This module is designed to be used as a Chipyard generator. To integrate:

1. Add this repository as a submodule under `generators/`
2. Register the module in `build.sbt`
3. Use the provided `WithOmniXtend` config fragment to enable OmniXtend in your SoC design

## Build

```bash
sbt compile
sbt test
```

## Dependencies

- Scala 2.13+
- Chisel 3.5+
- Chipyard (for SoC integration)
