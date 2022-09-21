# Keks Game Console

Keks is a 32-bit FPGA-based video game console and computer designed as a fun educational platform for teaching and learning about computers, electronics, FPGAs and programming.

![Keks Game Console](https://github.com/machdyne/keks/blob/0ec64c9bf5efc4cf7926da4405d466fae49035fd/keks.png)

This repo contains schematics, pinouts, firmware, gateware and documentation.

Additional examples will be added soon.

Find more information on the [Keks product page](https://machdyne.com/product/keks-game-console/).

## Blinky 

Building the blinky example requires [Yosys](https://github.com/YosysHQ/yosys), [nextpnr-ice40](https://github.com/YosysHQ/nextpnr) and [IceStorm](https://github.com/YosysHQ/icestorm).

Assuming they are installed, you can simply type `make` to build the gateware, which will be written to output/blinky.bin. You can then connect the USB-C port to your computer and use the latest version of [ldprog](https://github.com/machdyne/ldprog) to write the gateware to the device.

## Programming

The RP2040 firmware and FPGA SRAM can be programmed over the USB-C port.

Configure the FPGA SRAM:

```
$ ldprog -k -s blinky.bin
```

It should also be possible to transfer gateware and games to the SD card over the USB-C port but this is not yet implemented.

## Firmware

Keks ships with RP2040 [firmware](firmware) based on the [Müsli](https://github.com/machdyne/musli) firmware which allows it to communicate with [ldprog](https://github.com/machdyne/ldprog).

The firmware is responsible for initializing the system, [configuring and outputting the system clock](https://raspberrypi.github.io/pico-sdk-doxygen/group__hardware__clocks.html#details), configuring the FPGA and detecting USB HID events.

The system clock (CLK\_RP) is 126MHz by default.

After FPGA configuration is complete the RP2040 firmware configures the RP2040 to act as an SPI slave on the CSPI bus, allowing the FPGA to access the RP2040 SRAM, flash, USB HID controller registers as well as issue commands. 

In addition to the 4 CSPI signals there are 6 other signals connected to both the RP2040 and the FPGA: RP\_TX, RP\_RX, and RP\_INT, CDONE, CRESET and BTN.

The firmware can be updated by holding down the BOOTSEL button, connecting the USB-C port to your computer, and then dragging and dropping a new UF2 file to the device filesystem.

## DDMI

See this [SmolDVI fork](https://github.com/machdyne/SmolDVI) for an example of outputting video on the DDMI port.

## Pinouts

 * [DDMI](https://github.com/machdyne/ddmi)
