# This script adds the correct links to the footer.

import os

command = os.system("ls *_footer.txt > feet.temp")
with open('feet.temp') as f:
    files = f.readlines()
f.close()
command = os.system("rm feet.temp")

for file in files:


    name = file.strip()
    name = name.replace("_footer.txt", "")
    name = name.strip()
    figpath = "https://ldas-jobs.ligo.caltech.edu/~sherman.thompson/Yearcompare/" + name + ".fig"
    figpath = figpath.replace("--","_")

    with open(file.strip(),"a") as f:
        f.write("A date-stampted visualization is avalible for download " + "<a href="+ '"' + figpath + '"' + ">" + "here." +"</a>")
        f.close

