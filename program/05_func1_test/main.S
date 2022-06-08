# RISC-V simple counter program
#
# Stanislav Zhelnio, 2020
#

            .text

start:      mv a0, zero              # t0 = 0
            mv a1, zero 
            mv a2, zero
            addi a1, a1, 3
            addi a2, a2, 1
            add a0, a2, a1    # func1