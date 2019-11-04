#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Script to generate the template file and update the translation files.
#
# Copyright (C) 2019 Joachim Stolberg
# LGPLv2.1+
# 
# Copy the script into the mod root folder and adapt the last code lines to you needs.

from __future__ import print_function
import os, fnmatch, re, shutil

pattern_lua = re.compile(r'[ \.=^\t]S\("(.+?)"\)', re.DOTALL)
pattern_tr = re.compile(r'(.+?[^@])=(.+)')

def gen_template(templ_file, lkeyStrings):
    lOut = []
    lkeyStrings.sort()
    for s in lkeyStrings:
        lOut.append("%s=" % s)
    open(templ_file, "wt").write("\n".join(lOut))

def read_lua_file_strings(lua_file):
    lOut = []
    text = open(lua_file).read()
    for s in pattern_lua.findall(text):
        s = re.sub(r'"\.\.\s+"', "", s)
        s = re.sub("@[^@=n]", "@@", s)
        s = s.replace("\n", "@n")
        s = s.replace("\\n", "@n")
        s = s.replace("=", "@=")
        lOut.append(s)
    return lOut

def inport_tr_file(tr_file):
    dOut = {}
    if os.path.exists(tr_file):
        for line in open(tr_file, "r").readlines():
            s = line.strip()
            if s == "" or s[0] == "#":
                 continue
            match = pattern_tr.match(s)
            if match:
                dOut[match.group(1)] = match.group(2)
    return dOut

def generate_template(templ_file):
    lOut = []
    for root, dirs, files in os.walk('./'):
        for name in files:
            if fnmatch.fnmatch(name, "*.lua"):
                fname = os.path.join(root, name)
                found = read_lua_file_strings(fname)
                print(fname, len(found))
                lOut.extend(found)
    lOut = list(set(lOut))
    lOut.sort()
    gen_template(templ_file, lOut)
    return lOut

def update_tr_file(lNew, mod_name, tr_file):
    lOut = ["# textdomain: %s\n" % mod_name]
    if os.path.exists(tr_file):
        shutil.copyfile(tr_file, tr_file+".old")
    dOld = inport_tr_file(tr_file)
    for key in lNew:
        val = dOld.get(key, "")
        lOut.append("%s=%s" % (key, val))
    lOut.append("##### not used anymore #####")
    for key in dOld:
        if key not in lNew:
            lOut.append("%s=%s" % (key, dOld[key]))
    open(tr_file, "w").write("\n".join(lOut))
    
data = generate_template("./locale/template.txt")
update_tr_file(data, "techage", "./locale/techage.de.tr")
#update_tr_file(data, "techage", "./locale/techage.fr.tr")
print("Done.\n")
