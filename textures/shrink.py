import os, fnmatch


print ">>> Convert"
for filename in os.listdir("./"):
    if fnmatch.fnmatch(filename, "*.png"):
        print(filename)
        os.system("pngquant --skip-if-larger --quality=8-32 --output ./%s.new  ./%s" % (filename, filename))

print "\n>>> Copy"
for filename in os.listdir("./"):
    if fnmatch.fnmatch(filename, "*.new"):
        print(filename)
        os.remove("./" + filename[:-4])
        os.rename("./" + filename, "./" + filename[:-4])

