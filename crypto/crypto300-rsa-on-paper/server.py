from Crypto.PublicKey import RSA
import random, sys


def miller_rabin_pass(a, s, d, n):
    a_to_power = pow(a, d, n)
    if a_to_power == 1:
        return True
    for i in range(s-1):
        if a_to_power == n - 1:
            return True
        a_to_power = (a_to_power * a_to_power) % n
    return a_to_power == n - 1


def miller_rabin(n):
    d = n - 1
    s = 0
    while d % 2 == 0:
        d >>= 1
        s += 1

    for repeat in range(20):
        a = 0
        while a == 0:
            a = random.randrange(n)
        if not miller_rabin_pass(a, s, d, n):
            return False
    return True


def next_prime(num):
    if (not num & 1) and (num != 2):
        num += 1
    if miller_rabin(num):
        num += 1
    while True:
        if miller_rabin(num):
            break
        num += 2
    return num


def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)


def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m


def start(message):

    d = modinv(e, fi)

    assert (e*d) % fi == 1

    key = RSA.construct((p * q, e, d, p))

    ct = key.encrypt(message, None)[0]

    public = open("publickey.pem", "w")
    public.write(key.publickey().exportKey())
    public.close()

    secret = open("secret.enc", "w")
    secret.write(str(ct))
    secret.close()

    assert key.decrypt(ct) == message

    check = open("secret.enc", "r").read()
    check_pt = key.decrypt(int(check))

    assert check_pt == message


p = 32317006071311007300714876688669951960444102669715484032130345427524655138867890893197201411522913463688717960921898019494119559150490921095088152386448283120630877367300996091750197750389652106796057638384067568276792218642619756161838094338476170470581645852036305042887575891541065808607552399123930385521914333389668342420684974786564569494856176035326322058077805659331026192708460314150258592864177116725943603718461857357598351152301645904403697613233287231227125684710820209725157101726931323469678542580656697935045997268352998638215525166389437335543602135433229604645318478604952148193555853611059596231637L
q = 32317006071311007300714876688669951960444102669715484032130345427524655138867890893197201411522913463688717960921898019494119559150490921095088152386448283120630877367300996091750197750389652106796057638384067568276792218642619756161838094338476170470581645852036305042887575891541065808607552399123930385521914333389668342420684974786564569494856176035326322058077805659331026192708460314150258592864177116725943603718461857357598351152301645904403697613233287231227125684710820209725157101726931323469678542580656697935045997268352998638215525166389437335543602135433229604645318478604952148193555853611059596232273L
n = p * q
e = 19L
fi = (p-1) * (q-1)
message = int("whyplutoisnotaplanetanymore is a flag".encode("hex"), 16)

p = next_prime(2*4096 + 1)
q = next_prime(p)

print(p, q)

#start(message)