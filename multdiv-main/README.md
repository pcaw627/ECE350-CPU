# MULTDIV
## Name
Phillip (Liam) Williams

## Description of Design
Design Spec:

I built a Wallace tree multiplier, which first generates a series of partial products, and then groups them in succession into different weights and then adds them together using a series of 3-2 compressors (fancy name for a full adder). This reduction step
is implemented in many different ways (different fanouts, some with mixtures of full adders and half adders).

For the overflow, I initially checked to see if the signs were extended properly by checking if the upper 33 bits of the entire product were the same. However, I found that my partial products weren't propagating all the way and some information was lost- so 
I ended up extending them by an additional 32bits. Then, I was able to look at the upper product and then see if the sign matched the lower product, and if the magnitude was 0 or 1 (anything bigger than that would indicate the product is too big to store in product_lo.)

## Bugs
