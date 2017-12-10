addi r3, 10(r0)
subi r4, 11(r0)
sw r0, 28(r0)
sw r0, 29(r0)
lw r2, 39(r4)
add r1, r2, r1
sw r1, 41(r4)
addi r4, 1(r4)
bnez r4, -4
halt
