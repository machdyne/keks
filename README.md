# Keks Game Console

Keks is a 32-bit FPGA-based video game console and computer designed as a fun educational platform for teaching and learning about computers, electronics, FPGAs and programming.

![Keks Game Console](https://github.com/machdyne/keks/blob/0ec64c9bf5efc4cf7926da4405d466fae49035fd/keks.png)

This repo contains schematics, PCB layouts, pinouts, firmware, gateware, documentation and a 3D printable case.

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

It should also be possible to transfer gateware and games to the MicroSD card over the USB-C port but this is not yet implemented.

## Games

* [pong](games/pong)

## Firmware

Keks ships with RP2040 [firmware](firmware) based on the [Müsli](https://github.com/machdyne/musli) firmware which allows it to communicate with [ldprog](https://github.com/machdyne/ldprog).

The firmware is responsible for initializing the system, [configuring and outputting the RP clock](https://www.raspberrypi.com/documentation/pico-sdk/hardware.html#hardware_clocks), configuring the FPGA and detecting USB HID events.

The RP clock (CLK\_RP) is 48MHz by default. Keks also has a 100 MHz oscillator on board (CLK\_100).

*The following description is still under development and may change.*

*If an inserted FAT-formatted MicroSD card contains a bitstream file in the root directory named GATEWARE.BIN it will be used to configure the FPGA after power-on.*

*The RP2040 firmware also acts as an SPI master and sends updates to the FPGA when the status of the gamepads/joysticks change.*

In addition to the 4 CSPI signals and CLK\_RP there are 6 other signals connected to both the RP2040 and the FPGA: RP\_TX, RP\_RX, and RP\_INT, CDONE, CRESET and BTN.

### Updating the Firmware

To build the latest firmware you will need to install the [Raspberry Pi Pico SDK](https://github.com/raspberrypi/pico-sdk).

Set the `PICO_SDK_PATH` environment variable to your SDK path.

```
$ git clone https://github.com/machdyne/keks
$ cd keks/firmware/keks
$ mkdir build
$ cd build
$ cmake ..
$ make
```

The firmware can then be updated by holding down the (small) BOOTSEL button, connecting the USB-C port to your computer, and then dragging and dropping a new UF2 file to the device filesystem.

## DDMI

See this [my_hdmi_device fork](https://github.com/machdyne/my_hdmi_device) for an example of outputting video on the DDMI port.

See this [SmolDVI fork](https://github.com/machdyne/SmolDVI) for another example of outputting video on the DDMI port.

## Pinouts

 * [DDMI](https://github.com/machdyne/ddmi)

## License

The contents of this repo are released under the [Lone Dynamics Open License](LICENSE.md) with the following exceptions:

- The KiCad design files contain parts of the [kicad-pmod](https://github.com/mithro/kicad-pmod) library which is released under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).

- The KiCad design files may contain symbols and footprints released under other licenses; please contact us if we've failed to give proper attribution.

Note: You can use these designs for commercial purposes but we ask that instead of producing exact clones, that you either replace our trademarks and logos with your own or add your own next to ours.

