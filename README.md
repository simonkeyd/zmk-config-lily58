# Lily58 ZMK Firmware Builder

Build and deploy ZMK firmware for Lily58 keyboard with nice!nano v2 controllers and nice!view displays.

## Layout

![keymap](keymap.svg)

## Prerequisites

1. [Install and setup ZMK](https://zmk.dev/)

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/simonkeyd/lily58-nicenano-zmk.git
   cd lily58-nicenano-zmk
   ```

2. Build firmware for both halves:
   ```bash
   make all
   ```

3. Flash firmware:
   ```bash
   make deploy-left   # For left half
   make deploy-right  # For right half
   ```
   Double-tap reset button when prompted to enter bootloader mode.
