#!/usr/bin/env python
# -*- coding: utf-8 -*-
#

import re
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
    #print ">>>>"+text+"<<<<"
    return text

def header_escsape(header):
    header = header.lower()
    header = header.replace(" ", "-")
    header = header.replace("/", "")
    return header

lTitel = []
lText = []
lItemName = []
lPlanTable = []
lTocLinks = []

def reset():
    global lTitel, lText, lItemName, lPlanTable, lTocLinks
    
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

def lua_text_table(name, lData):
    lOut = []
    lOut.append("%s = {" % name)
    for lines in lData:
        for line in lines[:-1]:
            line = line.replace('<br>', '\\n')
            lOut.append('  "%s\\n"..' % line)
        if len(lines) > 0:
            lOut.append('  "%s\\n",' % lines[-1])
        else:
            lOut.append('  "",')
    lOut.append("}\n\n")
    return "\n".join(lOut)

class WikiLinkInlineLexer(mistune.InlineLexer):
    def enable_wiki_link(self):
        # add wiki_link rules
        self.rules.wiki_link = re.compile(
            r'\['                     # [
            r'([\s\S]+?\|[\s\S]+?)'   # name| img-type
            r'\](?!\])'               # ]
        )

        # Add wiki_link parser to default rules
        # you can insert it some place you like
        # but place matters, maybe 3 is not good
        self.default_rules.insert(3, 'wiki_link')

    def output_wiki_link(self, m):
        text = m.group(1)
        name, itype = text.split('|')
        # you can create an custom render
        # you can also return the html if you like
        return self.renderer.wiki_link(name, itype)

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
        lines = text.split("\\n")
        lines = ["    " + item for item in lines]
        self.TextChunck.extend(lines)
        self.TextChunck.append("")
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

    def wiki_link(self, name, itype):
        """
        Used for plans and images:
        [myimage|image]
        [myplan|plan]
        """
        if itype == "image":
            self.ItemName = name
        elif itype == "plan":
            self.PlanTable = name
        return ""

    def autolink(self, link, is_email=False):
        return link
        
    def linebreak(self):
        return "\\n"
        
    def newline(self):
        return "\\n"

    def inline_html(self, text):
        print(text)
    # ~ 
    # ~ double_emphasis(text)
    # ~ image(src, title, alt_text)
    # ~ link(link, title, content)
    # ~ strikethrough(text)
    # ~ inline_html(text)


def parse_md_file(src_name, mod, manual):
    print("Read Lua file '%s'" % src_name)
    renderer = MyRenderer()
    inline = WikiLinkInlineLexer(renderer)
    # enable the feature
    inline.enable_wiki_link()
    md = mistune.Markdown(renderer=renderer, inline=inline)
    md.renderer.src_name = src_name
    md.render(open(src_name, 'r').read())
    md.renderer.add_last_paragraph()

def gen_lua_file(dest_name):
    print("Write Lua file '%s'" % dest_name)
    lOut = ["%s.%s = {}\n\n" % (mod, manual)]
    lOut.append(lua_table("%s.%s.aTitel" % (mod, manual), lTitel))
    lOut.append(lua_text_table("%s.%s.aText" % (mod, manual), lText))
    lOut.append(lua_table("%s.%s.aItemName" % (mod, manual), lItemName))
    lOut.append(lua_table("%s.%s.aPlanTable" % (mod, manual), lPlanTable))
    open(dest_name, "w").write("".join(lOut))
    
def gen_toc_md_file(dest_name, titel, level_range=[1,6]):
    print("Write MD file '%s'" % dest_name)
    lOut = ["# "+ titel]
    lOut.append("")
    for item in lTocLinks:
        if item["level"] in range(*level_range):
            list_item = "    " * (item["level"] - level_range[0]) + "-"
            link = "%s#%s" % (item["link"], header_escsape(item["header"]))
            lOut.append("%s [%s](%s)" % (list_item, item["header"], link))
    open(dest_name, "w").write("\n".join(lOut))
    
def gen_file_local_toc(dest_name, level_range=[1,6]):
    lOut = []
    for item in lTocLinks:
        if item["level"] in range(*level_range):
            list_item = "    " * (item["level"] - level_range[0]) + "-"
            link = "#%s" % (item["header"].replace(" ", "-").replace("\\", ""))
            lOut.append("%s [%s](%s)" % (list_item, item["header"].replace("\\", ""), link))
    open(dest_name, "w").write("\n".join(lOut))

########################### German #########################
mod = "techage"
manual = "manual_DE"
parse_md_file("./manual_DE.md", mod, manual)
parse_md_file("./manual_ta1_DE.md", mod, manual)
parse_md_file("./manual_ta2_DE.md", mod, manual)
parse_md_file("./manual_ta3_DE.md", mod, manual)
parse_md_file("./manual_ta4_DE.md", mod, manual)
parse_md_file("./manual_ta5_DE.md", mod, manual)
gen_lua_file("../doc/manual_DE.lua")
gen_toc_md_file("./toc_DE.md", "Inhaltsverzeichnis")

########################### English #########################
reset()
mod = "techage"
manual = "manual_EN"
parse_md_file("./manual_EN.md", mod, manual)
parse_md_file("./manual_ta1_EN.md", mod, manual)
parse_md_file("./manual_ta2_EN.md", mod, manual)
parse_md_file("./manual_ta3_EN.md", mod, manual)
parse_md_file("./manual_ta4_EN.md", mod, manual)
parse_md_file("./manual_ta5_EN.md", mod, manual)
gen_lua_file("../doc/manual_EN.lua")
gen_toc_md_file("./toc_EN.md", "Table of Contents")

########################### Lua Manual #########################
reset()
parse_md_file("./ta4_lua_controller_EN.md", mod, manual)
gen_file_local_toc("toc.txt", level_range=[2,4])


