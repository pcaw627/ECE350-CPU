# MULTDIV
## Name
Phillip (Liam) Williams

## Description of Design

////// MULTIPLICATION
I built a Wallace tree multiplier, which first generates a series of partial products, and then groups them in succession into different weights and then adds them together using a series of 3-2 compressors (fancy name for a full adder). This reduction step
is implemented in many different ways (different fanouts, some with mixtures of full adders and half adders).

For the overflow, I initially checked to see if the signs were extended properly by checking if the upper 33 bits of the entire product were the same. However, I found that my partial products weren't propagating all the way and some information was lost- so 
I ended up extending them by an additional 32bits. Then, I was able to look at the upper product and then see if the sign matched the lower product, and if the magnitude was 0 or 1 (anything bigger than that would indicate the product is too big to store in product_lo.)

////// DIVISION
While Wallace trees are fast, one disadvantage is that their hardware can't be reused for division (at least not easily). Additionally, for the class we are required to use sequential memory elements for at least one of these, so I decided to go with a nonrestoring multiplier. While still considered slow in comparison to other algorithms like SRT and Goldstein, this approach is faster than restoring division. 

One limitation of the design from lecture is that it can only handle unsigned values. I accounted for this by taking the absolute value of both dividend and divisor, then setting the sign appropriately at the end.


In addition to implementing the algorithms above themselves, I also accounted for cases such as overflow, exceptions, interrupts, and ctrl_operation latching (so that we can cancel an operation and start another.) 

## Bugs
While I'm seeing 100% green on the Gradescope autotester, switching a ctrl signal to mult won't cancel an ongoing operation for division. While this doesn't impact correctness i feel that this isn't the most power efficient approach, and it could be fixed by either a) going the power-efficient route and canceling the division when ctrl_MULT is raised, or 2) going the performance route and making it so that we can intentionally run both a multiplication operation and a division operation at the same time (this would require two data_result ports, so that wouldn't be too hard to implement within the module itself).
