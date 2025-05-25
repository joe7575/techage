#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# install mistune v0.8.4 with: pip install mistune==0.8.4

import re
import mistune

assert(mistune.__version__ == "0.8.4")

__version__ = "1.0"

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

class MarkdownToLua(mistune.Renderer):
    def __init__(self, *args, **kwargs):
        mistune.Renderer.__init__(self, *args, **kwargs)
        self.item_name = ""
        self.plan_table = ""
        self.is_first_header = True
        self.text_chunck = []
        self.lTitle = []
        self.lText = []
        self.lItemName = []
        self.lPlanTable = []
        print("Markdown-to-Lua v%s" % __version__)

    def m2l_formspec_escape(self, text):
        text = text.replace("\\", "")
        text = text.replace("[", "\\\\[")
        text = text.replace("]", "\\\\]")
        text = text.replace(";", "\\\\;")
        text = text.replace(",", "\\\\,")
        text = text.replace('"', '\\"')
        text = text.replace('\n', '\\n')
        return text

    def m2l_add_last_paragraph(self):
        """
        Used to add a text block before the next header or at the end of the document
        """
        self.lText.append(self.text_chunck)
        self.text_chunck = []
        self.lItemName.append(self.item_name)
        self.item_name = ""
        self.lPlanTable.append(self.plan_table)
        self.plan_table = ""
    ##
    ## Block Level
    ##
    def block_code(self, code, lang):
        text = self.m2l_formspec_escape(code.strip())
        lines = text.split("\\n")
        lines = ["    " + item for item in lines]
        self.text_chunck.extend(lines)
        self.text_chunck.append("")
        return ""

    def header(self, text, level, raw=None):
        if not self.is_first_header:
            self.m2l_add_last_paragraph()
        self.is_first_header = False
        self.lTitle.append("%u,%s" % (level, self.m2l_formspec_escape(text)))
        return ""
        
    def hrule(self):
        self.text_chunck.append("\n----------------------------------------------------\n")
        return ""

    def paragraph(self, text):
        lines = text.split("\\n") + [""]
        self.text_chunck.extend(lines)
        return ""
        
    def list(self, body, ordered=True):
        lines = body.split("\n")
        self.text_chunck.extend(lines)
        return ""
        
    def list_item(self, text):
        return "  - %s\n" % text.strip()
    ##
    ## Span Level
    ##
    def emphasis(self, text):
        return "*%s*" % self.m2l_formspec_escape(text)

    def double_emphasis(self, text):
        return "*%s*" % self.m2l_formspec_escape(text)

    def codespan(self, text):
        return "'%s'" % self.m2l_formspec_escape(text)

    def text(self, text):
        return self.m2l_formspec_escape(text)

    def link(self, link, title, content):
        """
        Used for plans and images:
        [myimage](/image/)
        [myplan](/plan/)
        """
        if link == "/image/":
            self.item_name = content
        elif link == "/plan/":
            self.plan_table = content
        return content

    def wiki_link(self, name, itype):
        """
        Used for plans and images:
        [myimage|image]
        [myplan|plan]
        """
        if itype == "image":
            self.item_name = name
        elif itype == "plan":
            self.plan_table = name
        return ""

    def autolink(self, link, is_email=False):
        return link
        
    def linebreak(self):
        return "\\n"
        
    def newline(self):
        return "\\n"

    def inline_html(self, text):
        #print(text)
        pass

    def parse_md_file(self, src_name):
        print(" - Read MD file '%s'" % src_name)
        inline = WikiLinkInlineLexer(self)
        # enable the feature
        inline.enable_wiki_link()
        md = mistune.Markdown(renderer=self, inline=inline)
        md.renderer.src_name = src_name
        md.render(open(src_name, 'r').read())
        md.renderer.m2l_add_last_paragraph()

    def lua_table(self, key, lData):
        lOut = []
        lOut.append("  %s = {" % key)
        for line in lData:
            lOut.append('    "%s",' % line)
        lOut.append("  }")
        return "\n".join(lOut)

    def lua_text_table(self, key, lData):
        lOut = []
        lOut.append("  %s = {" % key)
        for lines in lData:
            for line in lines[:-1]:
                line = line.replace('<br>', '\\n')
                lOut.append('    "%s\\n"..' % line)
            if len(lines) > 0:
                lOut.append('    "%s\\n",' % lines[-1])
            else:
                lOut.append('    "",')
        lOut.append("  }")
        return "\n".join(lOut)

    def gen_lua_file(self, dest_name):
        print(" - Write Lua file '%s'" % dest_name)
        lOut = []
        s = ",\n".join([self.lua_table("titles", self.lTitle), 
                self.lua_text_table("texts", self.lText), 
                self.lua_table("images", self.lItemName), 
                self.lua_table("plans", self.lPlanTable)])
        open(dest_name, "w").write("return {\n%s\n}" % s)
        print("done.")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_DE.md")
m2l.gen_lua_file("../doc/manual_DE.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta1_DE.md")
m2l.gen_lua_file("../doc/manual_ta1_DE.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta2_DE.md")
m2l.gen_lua_file("../doc/manual_ta2_DE.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta3_DE.md")
m2l.gen_lua_file("../doc/manual_ta3_DE.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta4_DE.md")
m2l.gen_lua_file("../doc/manual_ta4_DE.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta5_DE.md")
m2l.gen_lua_file("../doc/manual_ta5_DE.lua")


m2l = MarkdownToLua()
m2l.parse_md_file("./manual_EN.md")
m2l.gen_lua_file("../doc/manual_EN.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta1_EN.md")
m2l.gen_lua_file("../doc/manual_ta1_EN.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta2_EN.md")
m2l.gen_lua_file("../doc/manual_ta2_EN.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta3_EN.md")
m2l.gen_lua_file("../doc/manual_ta3_EN.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta4_EN.md")
m2l.gen_lua_file("../doc/manual_ta4_EN.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta5_EN.md")
m2l.gen_lua_file("../doc/manual_ta5_EN.lua")


m2l = MarkdownToLua()
m2l.parse_md_file("./manual_FR.md")
m2l.gen_lua_file("../doc/manual_FR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta1_FR.md")
m2l.gen_lua_file("../doc/manual_ta1_FR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta2_FR.md")
m2l.gen_lua_file("../doc/manual_ta2_FR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta3_FR.md")
m2l.gen_lua_file("../doc/manual_ta3_FR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta4_FR.md")
m2l.gen_lua_file("../doc/manual_ta4_FR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta5_FR.md")
m2l.gen_lua_file("../doc/manual_ta5_FR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_pt-BR.md")
m2l.gen_lua_file("../doc/manual_pt-BR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta1_pt-BR.md")
m2l.gen_lua_file("../doc/manual_ta1_pt-BR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta2_pt-BR.md")
m2l.gen_lua_file("../doc/manual_ta2_pt-BR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta3_pt-BR.md")
m2l.gen_lua_file("../doc/manual_ta3_pt-BR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta4_pt-BR.md")
m2l.gen_lua_file("../doc/manual_ta4_pt-BR.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta5_pt-BR.md")
m2l.gen_lua_file("../doc/manual_ta5_pt-BR.lua")


m2l = MarkdownToLua()
m2l.parse_md_file("./manual_RU.md")
m2l.gen_lua_file("../doc/manual_RU.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta1_RU.md")
m2l.gen_lua_file("../doc/manual_ta1_RU.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta2_RU.md")
m2l.gen_lua_file("../doc/manual_ta2_RU.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta3_RU.md")
m2l.gen_lua_file("../doc/manual_ta3_RU.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta4_RU.md")
m2l.gen_lua_file("../doc/manual_ta4_RU.lua")

m2l = MarkdownToLua()
m2l.parse_md_file("./manual_ta5_RU.md")
m2l.gen_lua_file("../doc/manual_ta5_RU.lua")
