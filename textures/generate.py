#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Script to generate the palette PNG file.
#
# Copyright (C) 2022 Joachim Stolberg
# LGPLv2.1+

from PIL import Image

MainColors = [
  0x000080, 0x008000, 0x800000, 0x008080, 0x808000, 0x800080,
  0x0000FF, 0x00FF00, 0xFF0000, 0x00FFFF, 0xFFFF00, 0xFF00FF,
  0x0080FF, 0x8000FF, 0x80FF00, 0x00FF80, 0xFF8000, 0xFF0080,
]

def generate():
    img = Image.new("RGB", (18, 15), color='#000000')

    # Main colors
    for x in range(0,18):
      img.putpixel((x, 0), MainColors[x])

    # Grey scale
    for x in range(0,18):
      img.putpixel((x, 1), (x * 15, x * 15, x * 15))

    # 216 colors palette
    idx = 36
    for r in range(0,6):
      for g in range(0,6):
        for b in range(0,6):
          x = idx % 18
          y = int(idx / 18)
          img.putpixel((x, y), (r * 0x33, g * 0x33, b * 0x33))
          idx += 1

    img.save("techage_palette256.png", "PNG")

generate()
