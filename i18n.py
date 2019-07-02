#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Generate a template file for translation purposes


import os, fnmatch, re

pattern = re.compile(r'[ \.=^\t]S\("(.+?)"\)', re.DOTALL)

def gen_template(templ_file, lkeyStrings):
    lOut = []
    lkeyStrings = list(set(lkeyStrings))
    lkeyStrings.sort()
    for s in lkeyStrings:
        lOut.append("%s=" % s)
    file(templ_file, "wt").write("\n".join(lOut))

def read_strings(fname):
    lOut = []
    text = file(fname).read()
    for s in pattern.findall(text):
        s = re.sub(r'"\.\.\s+"', "", s)
        lOut.append(s)
    return lOut

def i18n(templ_file):
    lOut = []
    for root, dirs, files in os.walk('./'):
        for name in files:
            if fnmatch.fnmatch(name, "*.lua"):
                fname = os.path.join(root, name)
                found = read_strings(fname)
                print fname, len(found)
                lOut.extend(found)
    gen_template(templ_file, lOut)
    
i18n("./locale/template.txt")
print "Done.\n"
