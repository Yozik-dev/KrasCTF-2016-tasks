import os
import hashlib
import sys

dir = "hedge_parse/"

flag_str = "Secret code: UR-500"
flag_str_hex = [hex(ord(c))[2:] for c in flag_str]

for i in range(32):
    for j in range(32):

        alph = list()

        for f in os.listdir(dir):
            if f[-3:] != 'jpg':
                continue
            b = open(dir + f, 'rb').read()
            h = hashlib.sha224(b).hexdigest()
            h = h[i] + h[j]
            alph.append(h)
            
        h_ok, h_no = 0, 0    
        for h in flag_str_hex:
            if h in alph:
                h_ok += 1
            else:
                h_no += 1
        print("{},{} -- OK/NO: {}:{}".format(i, j, h_ok, h_no))
        
        if not h_no:
            print("Finita la commedia!")
            print(sorted(alph))
            sys.exit()

    
    
