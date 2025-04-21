
# Register conventions:
# $1-16 are dedicated FFT/IFFT registers
# $17 PRESET_ADDR
# $18 ADC_READY (ready for processing new sample, ~44kHz)


MAIN:

addi $20, $20, 5
nop
bne $18, $0, AUDIO
nop

j MAIN







AUDIO:
# initiate low pass modulation factors into registers 1 through 16
addi $1, $0, 32767        # r1 = 0
addi $2, $0, 32767        # r2 = 0
addi $3, $0, 16636        # r3 = 0
addi $4, $0, 16636        # r4 = 0
addi $5, $0, 16636        # r5 = 0
addi $6, $0, 16636        # r6 = 0
addi $7, $0, 16636        # r7 = 0
addi $8, $0, 16636        # r8 = 0
addi $9, $0, 8192        # r9 = 0
addi $10, $0, 8192       # r10 = 0
addi $11, $0, 4096       # r11 = 0
addi $12, $0, 4096       # r12 = 0
addi $13, $0, 0           # r13 = 0
addi $14, $0, 0           # r14 = 0
addi $15, $0, 0           # r15 = 0
addi $16, $0, 0           # r16 = 0
nop
nop

# run FFT (arg lowkey doesn't matter)
fft 1
nop
nop

# modulate $0 $i: sets fft_regs[i] = fft_regs[i] * $i/MAX_16
mod $0, $1, 0
mod $0, $2, 0
mod $0, $3, 0
mod $0, $4, 0
mod $0, $5, 0
mod $0, $6, 0
mod $0, $7, 0
mod $0, $8, 0
mod $0, $9, 0
mod $0, $10, 0
mod $0, $11, 0
mod $0, $12, 0
mod $0, $13, 0
mod $0, $14, 0
mod $0, $15, 0
mod $0, $16, 0

# after modulation, continue processing through IFFT
ifft 1
nop
nop

# reset r18 to 0 and r19 to 1
addi $18, $0, 0           # r18 = 0
addi $19, $0, 1

j MAIN







