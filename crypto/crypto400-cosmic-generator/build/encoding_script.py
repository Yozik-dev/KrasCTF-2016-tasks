def lfsr(seed, mask):
    result = seed
    nbits = mask.bit_length()-1
    while True:
        result = (result << 1)
        xor = result >> nbits
        if xor != 0:
            result ^= mask

        yield xor, result


gamma = lfsr(seed, polynom)

f = open("spacesecrets.jpg", "rb")
w = open("censored.jpg", "wb")

for ch in f.read():
    tmp_byte = 0
    for cnt in range(8):
        xor, result = next(gamma)
        tmp_byte = tmp_byte + 2 ** (7 - cnt) * xor
    w.write(chr(tmp_byte ^ ord(ch)))

f.close()
w.close()