# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

            .text

start:      mv a0, zero              # t0 = 0
            li a1, 0x11111111
            li a2, 0x22222222
            add a0, a2, a1           # func2
            li a1, 0x11111111
            li a2, 0xFFFFFFFF
            add a0, a2, a1           # func2
            li a1, 0x11FEFF0f
            li a2, 0x1211FF41
            add a0, a2, a1           # func2