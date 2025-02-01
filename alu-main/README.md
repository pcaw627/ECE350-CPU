# ALU
## Name
Phillip (Liam) Williams

## Description of Design
Design Spec:

+ a Two Level Carry Look-Ahead Adder with support for addition & subtraction
Make sure that you use the fully expanded functions for each cin
    + DO NOT use c[i] = g[i] + p[i]c[i-1]
    + Each CLA block should be connected using the Ps and Gs from the previous blocks
    + If you would like to use a different adder, consult with the instructor

+ bitwise AND, OR without the built in &, &&, |, and || operators

+ 32-bit barrel shifter with SLL and SRA without the <<, <<<, >>, and >>> operators


I implemented the above, along with the associated control signals for LT, EQ, GT, and *signed* overflow. 

For my logic (SLL, SRA, bitwise AND and OR) I also used encapsulation in a similar way to how CLAs break up their operations into 4 8 bit blocks. 

I took care not to use the prebuilt digital operators. 

## Bugs
