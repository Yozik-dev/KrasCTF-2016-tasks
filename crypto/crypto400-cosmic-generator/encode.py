# -*- coding: utf-8 -*-

import re


class FootnoteNumbers(object):
    def __init__(self):
        self.count = 0

    def __call__(self, match):
        self.count += 1
        
        if self.count > ENCODED_GAMMA_LEN:
            return chr(0) * 48
        else:
            i = (self.count - 1)*10
            return str(gm_s[i:i+10]) + chr(0) * 38


def lfsr(seed, mask):
    result = seed
    nbits = mask.bit_length()-1
    while True:
        result = (result << 1)
        xor = result >> nbits
        if xor != 0:
            result ^= mask

        yield xor, result

gamma = lfsr(0b101,0b101010011011)

f = open("spacesecrets.jpg", "rb")
w = open("censored.jpg", "wb")

gm = []
gm_s = ""

for ch in f.read():
    tmp_byte = 0
    for cnt in range(8):
        xor, result = next(gamma)
        gm.append(xor)
        gm_s += str(xor)
        tmp_byte = tmp_byte + 2**(7-cnt) * xor
        # print(tmp_byte, xor)
    w.write(chr(tmp_byte ^ ord(ch)))


f.close()
w.close()

ENCODED_GAMMA_LEN = 12

assert ENCODED_GAMMA_LEN < 14

empty_pcap = open("empty.pcap","rb").read()

a = re.compile('\\x00' * 48)
new_pcap = re.sub(a, FootnoteNumbers(), empty_pcap)

pcap = open("new_pcap.pcap", "wb")
pcap.write(new_pcap)
pcap.close()

print(gm[:ENCODED_GAMMA_LEN * 10])