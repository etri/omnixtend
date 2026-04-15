# OmniXtend Demo Setup

This guide describes how to set up and run a demonstration of the OmniXtend memory coherence protocol using FPGA platforms. The demo includes a host node and a memory node, operating over an Ethernet-based coherence protocol.

---

## 🧩 Hardware Configuration

- **Host Node**: Xilinx VCU118
- **Memory Node**: Xilinx AU280
- **Vivado Version**: 2021.2
- **SD Card**: SanDisk 16GB (used for OS boot)
- **Connection**: SD card connects to VCU118 via PMOD adapter

---

## 📀 Operating System Image

Download the OS image (`sdcard.img`) from the [Releases](../../releases) section of this repository.

To write the image to the SD card, use:

```bash
sudo dd if=./sdcard.img of=/dev/sdX bs=4k status=progress
```

> Replace `/dev/sdX` with the appropriate device identifier for your SD card.

### SD Card Content Layout

```
├── latmem
│   ├── latmem
│   ├── latmem.c
│   ├── latmemfar
│   ├── latmemfar.c
│   ├── Makefile
│   └── README.md
├── lost+found
├── sgemm_meca
├── sgemm_meca2
├── sortbench
└── stream_c.exe
```

---

## ⚙️ System Setup Instructions

1. Write the appropriate bitstream to **both** the host (VCU118) and memory (AU280) nodes using Vivado 2021.2.
2. Power **on the AU280** memory node **first** and wait until it stabilizes.
3. Insert the prepared SD card into the VCU118 (via PMOD adapter).
4. Power **on the VCU118**. The operating system should boot, visible through UART.
5. Once booted, log in with:
   ```
   Username: root
   Password: fpga
   ```
6. The memory-mapped range `0x200000000 ~ 0x3FFFFFFFF` is accessible and backed by the memory node.
7. Use the `devmem` utility to verify memory access and perform read/write operations.

---

## 📊 Running Benchmarks

Benchmark tests are included in the SD card image but execution procedures are **TBD (To Be Defined)**. Please refer to the top-level `latmem`, `sortbench`, and `sgemms` binaries on the SD card for performance validation tools.

More detailed benchmark usage instructions will be provided in future updates.

---

## Troubleshooting

| Symptom | Possible Cause | Solution |
|---------|---------------|----------|
| No UART output after power-on | SD card not detected | Re-seat PMOD adapter and verify SD card image |
| `devmem` returns bus error | AU280 not ready | Power cycle AU280 and wait for link stabilization |
| Memory read returns all zeros | Bitstream mismatch | Re-program both boards with matching bitstreams |

---
