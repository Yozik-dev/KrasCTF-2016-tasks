import urllib3
import re

#http://photo.99px.ru/photos/tags/ejiki/

url_index = "http://okslukina.narod.ru/photoalbumezik.html"
url = "http://okslukina.narod.ru/"

jpg_re = re.compile("\"(.*?\.jpg)\"")
png_re = re.compile("\"(.*?\.png)\"")
bmp_re = re.compile("\"(.*?\.bmp)\"")

http = urllib3.PoolManager()
r = http.request("GET", url_index)

pics = []
pics += jpg_re.findall(r.data.decode())
pics += png_re.findall(r.data.decode())
pics += bmp_re.findall(r.data.decode())

for p in pics:
    r = http.request("GET", url + p)
    with open(p, 'wb') as out:
        out.write(r.data)
    print(p)
