# Road Fighter — FPGA Arcade Game

A hardware implementation of the classic arcade game **Road Fighter**, built in Verilog HDL and deployed on the **Basys-3 FPGA board**. The game renders in real-time over VGA at 640×480 resolution, with sprite-based graphics, collision detection, and pseudo-random obstacle generation.

---

## Gameplay

- Control your car using the **left and right buttons** to dodge an oncoming rival car
- The road background scrolls continuously to simulate forward movement
- The rival car spawns at a random horizontal position and moves downward
- A collision freezes the game — press **center button** to restart

---

## Hardware Requirements

| Component | Details |
|---|---|
| FPGA Board | Digilent Basys-3 (Artix-7) |
| Display | VGA monitor (640×480 @ 60Hz) |
| Input | Basys-3 onboard push buttons (BTNL, BTNR, BTNC) |
| Clock | 100 MHz onboard clock (W5) |
| Tool | Xilinx Vivado |

---

## Module Overview

| File | Module | Description |
|---|---|---|
| `Display_sprite.v` | `Display_sprite` | Top-level module — wires all components, drives VGA output, manages sprite rendering and background scrolling |
| `car_fsm.v` | `car_fsm` | Finite State Machine controlling player car movement (IDLE, LEFTCAR, RIGHTCAR, COLLIDE, START) |
| `rival_car_ctrl.v` | `rival_car_ctrl` | Controls rival car vertical descent and random horizontal respawn using LFSR |
| `lfsr.v` | `lfsr8` | 8-bit Linear Feedback Shift Register for pseudo-random number generation (taps: x⁸ + x⁶ + x⁵ + x⁴ + 1) |
| `debouncer.v` | `debouncer` | Hardware button debouncer with 25ms window at 100MHz to eliminate contact noise |
| `constraints.xdc` | — | Pin mapping for VGA (12-bit RGB), HS/VS sync signals, and BTNL/BTNR/BTNC |

---

## Architecture

```
100MHz Clock
     │
     ▼
Display_sprite (Top Level)
     ├── VGA_driver        → generates HS/VS sync + pixel coordinates
     ├── car_fsm           → player position (car_x, car_y) + collision flag
     ├── rival_car_ctrl    → rival position (rival_x, rival_y)
     │       └── lfsr8     → random spawn x-position
     ├── bg_rom            → road background sprite (160×240)
     ├── main_car_rom      → player car sprite (14×16)
     └── rival_car_rom     → rival car sprite (14×16)
```

---

## FSM States (car_fsm)

| State | Description |
|---|---|
| `START` | Resets car to initial position |
| `IDLE` | Car stationary, waiting for input |
| `LEFTCAR` | Car moving left within road bounds |
| `RIGHTCAR` | Car moving right within road bounds |
| `COLLIDE` | Collision detected — freezes game until restart |

---

## How to Run in Vivado

1. Clone the repository and open Vivado
2. Create a new RTL project and add all `.v` files as design sources
3. Add `constraints.xdc` as a constraint file
4. Add the ROM memory files for background and car sprites (`.coe` or block RAM IP)
5. Run **Synthesis → Implementation → Generate Bitstream**
6. Connect Basys-3 via USB, open Hardware Manager, and program the device

---

## Pin Mapping Summary

| Signal | Pin | Description |
|---|---|---|
| `clk` | W5 | 100MHz onboard clock |
| `BTNC` | U18 | Center button — restart |
| `BTNL` | W19 | Left button — move car left |
| `BTNR` | T17 | Right button — move car right |
| `HS` | P19 | VGA Horizontal Sync |
| `VS` | R19 | VGA Vertical Sync |
| `vgaRGB[11:0]` | D17–G19 | 12-bit VGA color output |

---

## Key Design Decisions

**Hardware Transparency** — The color `12'b101000001010` is treated as a transparent key. When a sprite pixel matches this value, the background is rendered instead, enabling clean sprite layering without a dedicated alpha channel.

**LFSR for Randomness** — A hardware-native 8-bit LFSR with polynomial x⁸ + x⁶ + x⁵ + x⁴ + 1 generates pseudo-random rival spawn positions. This avoids any software dependency and synthesizes efficiently on FPGA fabric.

**Debouncing** — All three buttons pass through a 25ms debounce window implemented as a synchronous FSM, preventing false triggers from mechanical contact bounce.

---

## License

MIT License
