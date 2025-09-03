# omnixtend/MemoryNode + oxme-fuse README.md

# Introduction

This document explains how to extend the memory of a RISC-V virtual machine using OmniXtend memory, and how to set up an environment to run the llama 3.2 1B model in llama-cpp on that expanded memory.

# Installation

This section describes how to install and configure QEMU, a pre-built RISC-V image, llama-cpp, and the llama 3.2 1B model.

**System Requirements**

- x86_64 host  
- Two Ethernet ports (e.g., `enp179s0f0np0`, `enp179s0f1np1`)  
- Ubuntu 22.04 Server

### Installing QEMU

```bash
# Install required packages
sudo apt update
sudo apt install ninja-build meson libglib2.0-dev libslirp-dev bison flex python3-pip opensbi u-boot-qemu
pip install tomli

# Clone the QEMU source
git clone https://github.com/qemu/qemu.git
cd qemu
git submodule init
git submodule update --recursive

# Build and install QEMU
mkdir build
cd build
../configure --enable-slirp --target-list="riscv32-softmmu riscv64-softmmu"
make -j $(nproc)
sudo make install
```

### Downloading the Pre-installed RISC-V Image and Booting the VM

```bash
cd
mkdir riscv-vm
cd riscv-vm

# Download Ubuntu 22.04 RISC-V image
wget https://cdimage.ubuntu.com/releases/jammy/release/ubuntu-22.04.5-preinstalled-server-riscv64+unmatched.img.xz
xz -d ubuntu-22.04.5-preinstalled-server-riscv64+unmatched.img.xz

# Expand the image
cp ubuntu-22.04.5-preinstalled-server-riscv64+unmatched.img riscv-ubuntu-22.img
qemu-img resize riscv-ubuntu-22.img +20G

# Launch the VM
/usr/local/bin/qemu-system-riscv64 -machine virt -nographic -m 8G -smp cpus=4 \
-object memory-backend-ram,size=4G,id=m0 -object memory-backend-ram,size=4G,id=m1 \
-numa node,memdev=m0,cpus=0-1,nodeid=0 -numa node,memdev=m1,cpus=2-3,nodeid=1 \
-bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin \
-kernel /usr/lib/u-boot/qemu-riscv64_smode/u-boot.bin \
-netdev user,id=eth0,hostfwd=tcp::10022-:22 -device virtio-net-device,netdev=eth0 \
-drive file=riscv-ubuntu-22.img,format=raw,if=virtio -device virtio-rng-pci

# Default credentials on first boot: ubuntu:ubuntu
# Please change the password after logging in.
```

### Installing llama-cpp and the llama 3.2 1B Model

```bash
# Inside the VM
sudo apt update
sudo apt install build-essential curl libcurl4-openssl-dev cmake python3-pip autoconf ninja-build cython3 python-is-python3

# Clone and build llama.cpp (commit b5255)
git clone -b b5255 --single-branch https://github.com/ggml-org/llama.cpp.git
cd llama.cpp/
cmake -B build
cmake --build build --config Release -j$(nproc)

# Download the llama 3.2 1B model
# https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/tree/main
cd models
wget https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q8_0.gguf
cd ..

# Run interactively
build/bin/llama-cli -m models/Llama-3.2-1B-Instruct-Q8_0.gguf

# Run benchmark
build/bin/llama-bench -m models/Llama-3.2-1B-Instruct-Q8_0.gguf

# Shut down the VM when done
sudo poweroff

```

### Installing OmniXtend MemoryNode and oxmem-fuse

OmniXtend’s MemoryNode is a software remote-memory module supporting the OmniXtend protocol, and oxmem-fuse provides a filesystem interface to access that remote memory.

```bash
# Clone the OmniXtend repository
cd ~
git clone --recurse-submodules https://github.com/etri/omnixtend.git

# Build and run MemoryNode
cd omnixtend/examples/MemoryNode/
make
# Usage: ./memorynode -i <interface> -s <size> -o <offset>
./memorynode -i enp179s0f1np1 -s 1G -o 0x0 &

# Build and mount oxmem-fuse
cd ../oxmem-fuse
make
mkdir om
# Usage: ./oxmem-fuse-dax -f(foreground) --netdev=<my interface> --mac="<dest mac>" --size=<mem size in MB> --base=<offset> <mount point>
./oxmem-fuse-dax -f --netdev=enp179s0f0np0 --mac="04:3f:72:dd:0b:05" --size=1024 --base=0x0 om/
```

After these steps, you will have a 1 GB OmniXtend-backed memory region emulated by MemoryNode, and a file-based interface at om/data to access it.

# Experiments

Use the OmniXtend MemoryNode to extend the memory of a QEMU RISC-V VM and measure llama-cpp inference performance under different memory configurations:

### Local 2 GB RAM (sufficient to load the llama 3.2 1B Q8 model)

```bash
# Launch VM
/usr/local/bin/qemu-system-riscv64 -machine virt -nographic -m 2G -smp cpus=8 \
-object memory-backend-ram,size=2G,id=m0 \
-bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin \
-kernel /usr/lib/u-boot/qemu-riscv64_smode/u-boot.bin \
-netdev user,id=eth0,hostfwd=tcp::10022-:22 -device virtio-net-device,netdev=eth0 \
-drive file=riscv-ubuntu-22.img,format=raw,if=virtio \
-device virtio-rng-pci

# Run llama.cpp benchmark
cd llama.cpp
./build/bin/llama-bench -m models/Llama-3.2-1B-Instruct-Q8_0.gguf -p 16 -n 16

```

### Local 1.4 GB RAM (slightly insufficient for the Q8 model)

```bash
# Launch VM
/usr/local/bin/qemu-system-riscv64 -machine virt -nographic -m 1400M -smp cpus=8 \
-object memory-backend-ram,size=1400M,id=m0 \
-object memory-backend-file,size=1G,id=m1,share=off,mem-path=/home/swsok/omnixtend/examples/oxmem-fuse/om/oxmem \
-bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin \
-kernel /usr/lib/u-boot/qemu-riscv64_smode/u-boot.bin \
-netdev user,id=eth0,hostfwd=tcp::10022-:22 -device virtio-net-device,netdev=eth0 \
-drive file=riscv-ubuntu-22.img,format=raw,if=virtio -device virtio-rng-pci

```

### 1.4 GB Local RAM + 0.6 GB OmniXtend Memory

```bash
# Launch VM
/usr/local/bin/qemu-system-riscv64 -machine virt -nographic -m 2G -smp cpus=8 \
-object memory-backend-ram,size=1400M,id=m0 \
-object memory-backend-file,size=624M,id=m1,share=on,mem-path=om/data \
-bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin \
-kernel /usr/lib/u-boot/qemu-riscv64_smode/u-boot.bin \
-netdev user,id=eth0,hostfwd=tcp::10022-:22 -device virtio-net-device,netdev=eth0 \
-drive file=riscv-ubuntu-22.img,format=raw,if=virtio -device virtio-rng-pci

```
