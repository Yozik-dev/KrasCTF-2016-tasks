# -*- coding: utf-8 -*-

import random, fpdf, sys
import codecs

alph = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя0123456789'
hpla = [d for d in range(len(alph))]


def text_to_lowercase(text):
    output_file = open("plaintext_lower.txt", "w")
    output_file.write(text.decode('utf-8').lower().encode('utf-8'))
    output_file.close()


def rename_files_by_counter(dir):
    import os
    for index, f in enumerate(os.listdir(dir)):
        os.rename("%s\%s" % (dir, f), "%s\%d.jpg" % (dir, index))


def build_pdf(indices, dir):
    pdf = fpdf.FPDF()
    pdf.add_page()

    i = 0
    j = 0
    for index in indices:
        if j == 12:
            if i == 15:
                pdf.add_page()
                i, j = 0, 0
            j = 0
            i += 1
        j += 1
        pdf.image("%s\%d.jpg" % (dir, index), 5 + j * 15, 5 + i * 15, 10, 10)
    pdf.output("ciphertext.pdf", "F")


if __name__ == "__main__":
    text = codecs.open("plaintext_simple.txt", "r", "utf-8").read()
    alph = codecs.open("alphabet.txt", "r", "utf-8").read()
    random.shuffle(hpla)
    print(text)

    conv = {}
    for i, byte in enumerate(alph):
        conv[ord(byte)] = i

    ciphertext = []
    for byte in text:
        if ord(byte) in conv:
            ciphertext.append(conv[ord(byte)])

    print(ciphertext)
    build_pdf(ciphertext, "images\cat")
    print(conv)
