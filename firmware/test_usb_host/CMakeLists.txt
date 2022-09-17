cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(test_usb_host)

add_executable(test_usb_host)

pico_sdk_init()

set(PICO_PIO_USB_SRC "${CMAKE_CURRENT_LIST_DIR}/pico-pio-usb")

pico_generate_pio_header(test_usb_host ${PICO_PIO_USB_SRC}/usb_tx.pio)
pico_generate_pio_header(test_usb_host ${PICO_PIO_USB_SRC}/usb_rx.pio)

target_sources(test_usb_host PUBLIC
 ${CMAKE_CURRENT_LIST_DIR}/test_usb_host.c
 ${PICO_PIO_USB_SRC}/pio_usb.c
 ${PICO_PIO_USB_SRC}/pio_usb_device.c
 ${PICO_PIO_USB_SRC}/pio_usb_host.c
 ${PICO_PIO_USB_SRC}/usb_crc.c
 )

target_link_options(test_usb_host PRIVATE -Xlinker --print-memory-usage)
target_compile_options(test_usb_host PRIVATE -Wall -Wextra)
target_include_directories(test_usb_host PRIVATE ${PICO_PIO_USB_SRC})

target_link_libraries(test_usb_host PRIVATE pico_stdlib hardware_resets hardware_irq hardware_adc hardware_pio pico_multicore hardware_dma)

# enable usb output, disable uart output
pico_enable_stdio_usb(test_usb_host 1)
pico_enable_stdio_uart(test_usb_host 0)

pico_add_extra_outputs(test_usb_host)
