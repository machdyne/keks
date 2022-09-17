cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(keks)

add_executable(keks
        keks.c
        )

target_compile_definitions(keks PUBLIC
        PICO_DEFAULT_UART_INSTANCE=uart0
        PICO_DEFAULT_UART_BAUD_RATE=115200
        PICO_DEFAULT_UART_TX_PIN=24
        PICO_DEFAULT_UART_RX_PIN=9
        )

target_include_directories(keks PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}
        ${CMAKE_CURRENT_LIST_DIR}/fs
        ${CMAKE_CURRENT_LIST_DIR}/fs/fatfs
        )

target_sources(keks PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/keks.c
        ${CMAKE_CURRENT_LIST_DIR}/fs/fs.c
        ${CMAKE_CURRENT_LIST_DIR}/fs/fatfs/ff.c
        ${CMAKE_CURRENT_LIST_DIR}/fs/fatfs/sdmm.c
        )

pico_sdk_init()

pico_enable_stdio_usb(keks 0)
pico_enable_stdio_uart(keks 1) 

target_link_libraries(keks PRIVATE pico_stdlib hardware_resets hardware_uart hardware_irq hardware_spi pico_multicore)

pico_add_extra_outputs(keks)
