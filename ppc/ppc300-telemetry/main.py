import random
import re
import qrcode
import qrtools
import cv2
import numpy as np
# I found freedom. Losing all hope was freedom
import subprocess


def encryption_and_answer():
    key = 'Ifudfedm oigalhp a reo. on reo.Lsn l oewsfedm'
    half = len(key) / 2
    return ''.join([key[i] + key[half+i+1] for i in range(half)])


def generate_qrs():
    data = 'ZGVmIGVuY3J5cHRpb24oKToNCiAgICBrZXkgPSAnSWZ1ZGZlZG0gb2lnYWxocCBhIHJlby4gb24gcmVvLkxzbiBsIG9ld3NmZWRtJw0KICAgIGhhbGYgPSBsZW4oa2V5KSAvIDINCiAgICByZXR1cm4gJycuam9pbihba2V5W2ldICsga2V5W2hhbGYraSsxXSBmb3IgaSBpbiByYW5nZShoYWxmKV0pDQoNCg0KaWYgX19uYW1lX18gPT0gJ19fbWFpbl9fJzoNCiAgICBwcmludCBlbmNyeXB0aW9uKCk='
    for i in range(len(data)):
        line = 'The next symbol of key is "'+data[i]+'"\n'
        img = qrcode.make(line, box_size=10, border=2, fit=False)
        img.save('qrs/%d.png' % i)


def resize_qrs():
    for i in range(300):
        filename = 'qrs/'+str(i)+'.png'
        command = ['convert', filename, '-resize', '100x100', filename]
        subprocess.check_output(command)


def check_qrs():
    total = ''
    for i in range(300):
        filename = 'qrs/'+str(i)+'.png'
        qr = qrtools.QR()
        qr.decode(filename)
        c = re.findall('"(\w)"', qr.data)
        if len(c):
            total += c[0]

    print total


# http://docs.opencv.org/3.0-beta/doc/py_tutorials/py_gui/py_video_display/py_video_display.html
def play_video():
    cap = cv2.VideoCapture('bh.mp4')

    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    output = cv2.VideoWriter('result.avi', fourcc, 30, (1280, 720))
    i = 0
    g = 0
    while(cap.isOpened()):
        ret, frame = cap.read()
        if not ret:
            break

        if i % 29 == 0 and g < 300:
            image_file = 'qrs/' + str(g) + '.png'
            next_qr = cv2.imread(image_file)
            x_offset = random.randint(0, 1000)
            y_offset = random.randint(0, 600)
            frame[y_offset:y_offset+next_qr.shape[0], x_offset:x_offset+next_qr.shape[1]] = next_qr
            g += 1
            print g
        output.write(frame)
        i += 1

    cap.release()
    output.release()
    cv2.destroyAllWindows()


def main():
    play_video()


if __name__ == '__main__':
    main()
