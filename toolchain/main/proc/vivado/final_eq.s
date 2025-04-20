
nop
# 64 nops to allow ADC to sample, after which it samples one at a time
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
# start sampling the ADC

# 44kHz signal is set asynchonously, triggering JAL ra, PRESET_START

PRESET_START:

# run FFT to get wave spectrum
fft 5
nop
nop


# initiate low pass modulation factors into registers 1 through 16
PRESET_0:

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

j MODULATE_THEN_IFFT
nop
nop




# initiate low pass frequency modulation factors into registers 1 through 16
PRESET_1:

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

j MODULATE_THEN_IFFT
nop
nop



# initiate high-pass frequency modulation factors into registers 1 through 16
PRESET_2:

addi $1, $0, 0        # r1 = 0
addi $2, $0, 0        # r2 = 0
addi $3, $0, 0        # r3 = 0
addi $4, $0, 0        # r4 = 0
addi $5, $0, 4096        # r5 = 0
addi $6, $0, 4096        # r6 = 0
addi $7, $0, 8192        # r7 = 0
addi $8, $0, 8192        # r8 = 0
addi $9, $0, 16636        # r9 = 0
addi $10, $0, 16636       # r10 = 0
addi $11, $0, 16636       # r11 = 0
addi $12, $0, 16636       # r12 = 0
addi $13, $0, 32767           # r13 = 0
addi $14, $0, 32767           # r14 = 0
addi $15, $0, 32767           # r15 = 0
addi $16, $0, 32767           # r16 = 0
nop
nop

j MODULATE_THEN_IFFT
nop
nop



# after frequency modulation, execute IFFT
MODULATE_THEN_IFFT:

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

ifft 5



# initiate fast-waver time-modulation factors into registers 1 through 16
PRESET_3:

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




# initiate slow-waver time-modulation factors into registers 1 through 16
PRESET_4:

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



# after frequency modulation, execute IFFT
ifft 5




# arbitrary instructions
addi $17, $0, 25           # r14 = 0
addi $18, $0, 24           # r15 = 0
addi $19, $0, 23           # r16 = 0










