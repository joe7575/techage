#!/usr/bin/env python
# -*- coding: utf-8 -*-
#

import sys
import pprint
import mistune

def formspec_escape(text):
    text = text.replace("\\", "")
    text = text.replace("[", "\\\\[")
    text = text.replace("]", "\\\\]")
    text = text.replace(";", "\\\\;")
    text = text.replace(",", "\\\\,")
    text = text.replace('"', '\\"')
    text = text.replace('\n', '\\n')
    return text

lTitel = []
lText = []
lItemName = []
lPlanTable = []
lTocLinks = []

def lua_table(name, lData):
    lOut = []
    lOut.append("%s = {" % name)
    for line in lData:
        lOut.append('  "%s",' % line)
    lOut.append("}\n\n")
    return "\n".join(lOut)

def lua_test_table(name, lData):
    lOut = []
    lOut.append("%s = {" % name)
    for lines in lData:
        for line in lines[:-1]:
            lOut.append('  "%s\\n"..' % line)
        if len(lines) > 0:
            lOut.append('  "%s\\n",' % lines[-1])
        else:
            lOut.append('  "",')
    lOut.append("}\n\n")
    return "\n".join(lOut)

class MyRenderer(mistune.Renderer):
    def __init__(self, *args, **kwargs):
        mistune.Renderer.__init__(self, *args, **kwargs)
        self.TextChunck = []
        self.ItemName = ""
        self.PlanTable = ""
        self.is_first_header = True
    
    def add_last_paragraph(self):
        """
        Used to add a text block before the next header or at the end of the document
        """
        lText.append(self.TextChunck)
        self.TextChunck = []
        lItemName.append(self.ItemName)
        self.ItemName = ""
        lPlanTable.append(self.PlanTable)
        self.PlanTable = ""
    ##
    ## Block Level
    ##
    def block_code(self, code, lang):
        text = formspec_escape(code.strip())
        lines = text.split("\n")
        text2 = "\n    " + "\n    ".join(lines) + "\n"
        self.TextChunck.append(text2)
        return ""

    # ~ def block_quote(self, text):
        # ~ print "block_quote", text
        # ~ self.TextChunck.append("\n%s\n" % text)
        # ~ return ""

    def header(self, text, level, raw=None):
        if not self.is_first_header:
            self.add_last_paragraph()
        self.is_first_header = False
        lTitel.append("%u,%s" % (level, formspec_escape(text)))
        lTocLinks.append({"level": level, "header": formspec_escape(text), "link": self.src_name})
        return ""
        
    def hrule(self):
        self.TextChunck.append("\n----------------------------------------------------\n")
        return ""

    def paragraph(self, text):
        lines = text.split("\\n") + [""]
        self.TextChunck.extend(lines)
        return ""
        
    def list(self, body, ordered=True):
        lines = body.split("\n")
        self.TextChunck.extend(lines)
        return ""
        
    def list_item(self, text):
        return "  - %s\n" % text.strip()
    ##
    ## Span Level
    ##
    def emphasis(self, text):
        return "*%s*" % formspec_escape(text)

    def double_emphasis(self, text):
        return "*%s*" % formspec_escape(text)

    def codespan(self, text):
        return "'%s'" % formspec_escape(text)

    def text(self, text):
        return formspec_escape(text)

    def link(self, link, title, content):
        """
        Used for plans and images:
        [myimage](/image/)
        [myplan](/plan/)
        """
        if link == "/image/":
            self.ItemName = content
        elif link == "/plan/":
            self.PlanTable = content
        return ""

    def autolink(self, link, is_email=False):
        return link
        
    # ~ 
    # ~ double_emphasis(text)
    # ~ image(src, title, alt_text)
    # ~ linebreak()
    # ~ newline()
    # ~ link(link, title, content)
    # ~ strikethrough(text)
    # ~ text(text)
    # ~ inline_html(text)


def parse_md_file(src_name, mod, manual):
    print("Read Lua file '%s'" % src_name)
    renderer = MyRenderer()
    md = mistune.Markdown(renderer=renderer)
    md.renderer.src_name = src_name
    md.render(file(src_name).read())
    md.renderer.add_last_paragraph()

def gen_lua_file(dest_name):
    print("Write Lua file '%s'" % dest_name)
    lOut = ["%s.%s = {}\n\n" % (mod, manual)]
    lOut.append(lua_table("%s.%s.aTitel" % (mod, manual), lTitel))
    lOut.append(lua_test_table("%s.%s.aText" % (mod, manual), lText))
    lOut.append(lua_table("%s.%s.aItemName" % (mod, manual), lItemName))
    lOut.append(lua_table("%s.%s.aPlanTable" % (mod, manual), lPlanTable))
    file(dest_name, "w").write("".join(lOut))
    
def gen_toc_md_file(dest_name, titel):
    print("Write MD file '%s'" % dest_name)
    lOut = ["# "+ titel]
    lOut.append("")
    for item in lTocLinks:
        list_item = "    " * (item["level"] - 1) + "-"
        link = "%s#%s" % (item["link"], item["header"].lower().replace(" ", "-"))
        lOut.append("%s [%s](%s)" % (list_item, item["header"], link))
    file(dest_name, "w").write("\n".join(lOut))
    
mod = "techage"
manual = "manual_DE"
parse_md_file("./manual_DE.md", mod, manual)
parse_md_file("./manual_ta1_DE.md", mod, manual)
parse_md_file("./manual_ta2_DE.md", mod, manual)
parse_md_file("./manual_ta3_DE.md", mod, manual)
gen_lua_file("../doc/manual_DE.lua")
gen_toc_md_file("./toc_DE.md", "Inhaltsverzeichnis")
