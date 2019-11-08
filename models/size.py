lOut = []
for line in file("techage_boiler_large.obj"):
	words = line.split(" ")
	if words[0] == "v":
		words[1] = "%1.6f" % (float(words[1]) * 1.2)
		words[3] = "%1.6f" % (float(words[3]) * 1.2)
		line = " ".join(words)
	lOut.append(line.strip())
file("techage_boiler_bigger.obj", "wt").write("\n".join(lOut))
