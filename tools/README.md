# Tools

Utility applications and scripts for developing, debugging, and analyzing OmniXtend protocol traffic.

## Traffic Analyzer (Wireshark Dissector)

A Lua-based Wireshark dissector for decoding OmniXtend/TLoE protocol frames in real-time or from capture files.

### Features

- Decodes OmniXtend Ethernet frames (EtherType `0xAAAA`)
- Parses TileLink channel messages (A, B, C, D, E channels)
- Displays protocol fields with syntax coloring in Wireshark
- Supports both live capture and offline `.cap` file analysis

### Usage

**Live Capture:**
```bash
cd traffic_analyzer
./wireshark.sh <interface> [ethertype]
# Default: interface=enp1s0f0np0, ethertype=0xAAAA
```

**Offline Analysis:**
```bash
wireshark -X lua_script:omnixtend.lua -r <capture-file>
```

### Files

| File | Description |
|------|-------------|
| `omnixtend.lua` | Main Wireshark dissector plugin |
| `tilelink.lua` | TileLink message field definitions and parser |
| `header.lua` | OmniXtend/TLoE header structure definitions |
| `helpers.lua` | Common utility functions |
| `coloring` | Wireshark coloring rules for OmniXtend frames |
| `wireshark.sh` | Convenience script for launching Wireshark with the plugin |
| `OmniXtend202010.cap` | Sample capture file for testing |
