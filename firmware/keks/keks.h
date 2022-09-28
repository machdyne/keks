/**
 * Copyright (c) 2022 Lone Dynamics Corporation. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef KEKS_H_
#define KEKS_H_

#define MUSLI_SPI_RX_PIN   24		// CSPI_SO
#define MUSLI_SPI_CSN_PIN  25
#define MUSLI_SPI_SCK_PIN  26
#define MUSLI_SPI_TX_PIN   27		// CSPI_SI

#define MUSLI_CMD_READY 0x00
#define MUSLI_CMD_INIT 0x01

#define MUSLI_CMD_GPIO_SET_DIR 0x10
#define MUSLI_CMD_GPIO_DISABLE_PULLS 0x11
#define MUSLI_CMD_GPIO_PULL_UP 0x12
#define MUSLI_CMD_GPIO_PULL_DOWN 0x13

#define MUSLI_CMD_GPIO_GET 0x20
#define MUSLI_CMD_GPIO_PUT 0x21

#define MUSLI_CMD_SPI_READ 0x80
#define MUSLI_CMD_SPI_WRITE 0x81

#define MUSLI_CMD_REBOOT 0xf0

#define ICE40_CDONE 22
#define ICE40_CRESET 23

#define KEKS_CLKOUT 21

#define KEKS_TX 16			// rpint spi master mosi
#define KEKS_RX 17			// spi slave hold
#define KEKS_HOLD KEKS_RX

#define KEKS_LED_R 20
#define KEKS_LED_G 19
#define KEKS_LED_B 18
#define KEKS_BTN 28
#define KEKS_INT 29			// rpint master clk

#define KEKS_SD_SCK	6
#define KEKS_SD_MISO	4
#define KEKS_SD_MOSI	7
#define KEKS_SD_SS	5

#endif
