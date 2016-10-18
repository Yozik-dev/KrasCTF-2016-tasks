# -*- coding: utf-8 -*-


def follow(N):
    ct = [[0 for d in range(N)] for i in range(N)]

    # two direction
    # 1. step i++. cycle: i++ j-- till j == 0
    # 2. step j++. cycle: j++ i-- till i == 0
    ci = 1
    i = 0
    j = 0
    ct[0][0] = 1
    while ci < ((N * N) / 2):
        j += 1
        ci += 1
        ct[i][j] = ci

        while j != 0:
            ci += 1
            j -= 1
            i += 1
            ct[i][j] = ci

        if ci > ((N * N) / 2):
            break

        i += 1
        ci += 1
        ct[i][j] = ci
        while i != 0:
            ci += 1
            j += 1
            i -= 1
            ct[i][j] = ci

    # mega-hack. Just rotate the matrix.
    for i in range(N):
        for j in range(i):
            ct[i][N - 1 - j] = (N * N + 1) - ct[N - 1 - i][j]

    return ct


def main():
    p1 = open("plaintexts/1.txt", "r").read()
    p2 = open("plaintexts/2.txt", "r").read()
    p3 = open("plaintexts/3.txt", "r").read()

    c1 = open("ciphertexts/1.txt", "w")
    c2 = open("ciphertexts/2.txt", "w")
    c3 = open("ciphertexts/3.txt", "w")

    c1.write(encrypt(p1, 15))
    c1.close()

    c2.write(encrypt(p2, 8))
    c2.close()

    c3.write(encrypt(p3, 16))
    c3.close()


def encrypt(pt, N):
    ct = follow(N)

    ct_text = ""
    for i in range(N):
        for j in range(N):
            ct_text += pt[ct[i][j] - 1]
    return ct_text


def show(ct):
    for line in ct:
        print('  '.join(str(v).zfill(2) for v in line))


def test(ciphertext, N):
    trn = follow(N)
    plaintext = ['' for c in ciphertext]

    for i in range(N):
        for j in range(N):
            plaintext[trn[i][j]-1] = ciphertext[i*N+j]

    return ''.join(plaintext)


if __name__ == "__main__":
    main()

    c1 = open("ciphertexts/1.txt", "r").read()
    c2 = open("ciphertexts/2.txt", "r").read()
    c3 = open("ciphertexts/3.txt", "r").read()
    p1 = open("plaintexts/1.txt", "r").read()
    p2 = open("plaintexts/2.txt", "r").read()
    p3 = open("plaintexts/3.txt", "r").read()

    print(p1 == test(c1, 15))
    print(p2 == test(c2, 8))
    print(p3 == test(c3, 16))
