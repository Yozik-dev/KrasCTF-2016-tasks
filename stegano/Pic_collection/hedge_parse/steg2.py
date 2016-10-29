import os
import hashlib

flag_str = "Your flag: jxlACtLQc2"
flag_str_hex = [hex(ord(c))[2:] for c in flag_str]

m = hashlib.md5()
alph = list()

for f in os.listdir('.'):
    if f[-3:] != 'jpg':
        continue
    b = open(f, 'rb').read()
    m.update(b)
    h = m.hexdigest()[-2:]
    alph.append(h)

print(alph)
    
h_ok, h_no = 0, 0    
for h in flag_str_hex:
    if h in alph:
        h_ok += 1
    else:
        h_no += 1
print("OK/NO: {}:{}".format(h_ok, h_no))

    
    
