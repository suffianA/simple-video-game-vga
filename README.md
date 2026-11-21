# Simple Video Game over VGA (SVGP)

COE758 Project 2 — a simple video game rendered over VGA, written in VHDL for the Xilinx Spartan-3E (Xilinx ISE).

## Overview
- **Display:** 640×480 @ 60 Hz VGA, 25 MHz pixel clock derived from the 50 MHz board oscillator
- **Output:** HSYNC/VSYNC (active-low), 8-bit R/G/B to the video DAC, `DAC_CLK`
- **Input:** `SW[3:0]` player controls, `BTN_SOUTH` reset (both synchronized)

## Layout
| Path | Contents |
|------|----------|
| `src/top.vhd` | Top-level: clock divide, input sync, instantiates timing + pixel generator |
| `src/timing.vhd` | VGA horizontal/vertical counters and sync generation |
| `src/pixel_gen.vhd` | Game logic / per-pixel color generation |
| `src/ff_sync.vhd` | Two-flop synchronizer for async inputs |
| `constraints/` | `.ucf` pin constraints |
| `docs/` | Block diagram |

## Build
1. Create an ISE project targeting the Spartan-3E board, add `src/*.vhd` and the `.ucf` from `constraints/`.
2. Set `top` as the top module, then Synthesize → Implement → Generate Programming File.
3. Program the board with iMPACT and connect a VGA monitor.
