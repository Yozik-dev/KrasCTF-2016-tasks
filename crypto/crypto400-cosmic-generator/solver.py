def Berlekamp_Massey_algorithm(sequence):
    '''
    Can be used online: http://bma.bozhu.me/
    '''
    N = len(sequence)
    s = sequence[:]

    for k in range(N):
        if s[k] == 1:
            break
    f = set([k + 1, 0])  # use a set to denote polynomial
    l = k + 1

    g = set([0])
    a = k
    b = 0

    for n in range(k + 1, N):
        d = 0
        for ele in f:
            d ^= s[ele + n - l]

        if d == 0:
            b += 1
        else:
            if 2 * l > n:
                f ^= set([a - b + ele for ele in g])
                b += 1
            else:
                temp = f.copy()
                f = set([b - a + ele for ele in f]) ^ g
                l = n + 1 - l
                g = temp
                a = b
                b = n - l + 1

    # output the polynomial
    def print_poly(polynomial):
        result = ''
        lis = sorted(polynomial, reverse=True)
        for i in lis:
            if i == 0:
                result += '1'
            else:
                result += 'x^%s' % str(i)

            if i != lis[-1]:
                result += ' + '

        return result

    return (print_poly(f), l)


def lfsr(seed, mask):
    result = seed
    nbits = mask.bit_length() - 1
    while True:
        result = (result << 1)
        xor = result >> nbits
        if xor != 0:
            result ^= mask

        yield xor, result


if __name__ == "__main__":
    sequence = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]
    print(Berlekamp_Massey_algorithm(sequence)) # => ('x^11 + x^9 + x^7 + x^4 + x^3 + x^1 + 1', 11)

    img = open("censored.jpg", "rb").read()
    result_img = open("uncensored.jpg", "wb")

    gamma = lfsr(0b101, 0b101010011011)

    ind = 0
    for ch in img:

        tmp_byte = 0
        for cnt in range(8):
            xor, result = next(gamma)
            tmp_byte = tmp_byte + 2 ** (7 - cnt) * xor

        result_img.write(chr(ord(ch) ^ tmp_byte))

    result_img.close()
