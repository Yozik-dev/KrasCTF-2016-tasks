import os
import hashlib
import shutil

dir = "./hedge_parse/"
out_dir = "./steg_out"

try:
    shutil.rmtree(out_dir)
except:
    pass
os.mkdir(out_dir)

flag_str = "Secret code: UR-500"
flag_str_hex = [hex(ord(c))[2:] for c in flag_str]

poz_i, poz_j = 8, 16

alph = dict()

for f in os.listdir(dir):
    if f[-3:] != 'jpg':
        continue
    b = open(dir + f, 'rb')
    h = hashlib.sha224(b.read()).hexdigest()
    b.close()
    h = h[poz_i] + h[poz_j]    
    alph.setdefault(f, [h, 0])

print(sorted([x[0] for x in alph.values()]))  

i = 1
for c in flag_str_hex:
   cur = {'pic': '', 'uses': 1000}
   for pic in alph.keys():
       h, uses = alph[pic]
       if c == h and uses < cur['uses']:
           cur['pic'] = pic
           cur['uses'] = uses
   print("{:03} -- {} -- {}".format(i, c, cur['pic']))
   shutil.copyfile(dir + cur['pic'], "{}/{}.jpg".format(out_dir, i))
   i += 1
   alph[cur['pic']][1] += 1
   
# for k in alph.keys():
    # print("{} -- {}".format(alph[k], chr(int(alph[k][0], 16))))
   
            
        
    
    
