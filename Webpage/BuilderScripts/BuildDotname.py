#Basically, the way this works is that you run this, making sure that DOTNAME.css, DOTNAME.txt-- the raw templates, and htmlmaker, are in the same directory
#You make some edits to the comments or footers, then run the following command:
#python BuildDotname.py
#This is the scheme for editing the html files.


import os
import htmlmaker

command = os.system("ls *.png > pngs.temp")
with open('pngs.temp') as f:
    files = f.readlines()
f.close()
command = os.system("rm pngs.temp")


for file in files:
    file = file.strip()
    print("Making html for " + file)
    name = file.replace(".png", "")
    name = name.strip()

    commentsfilename = name + "_comments.txt"
    f= open(commentsfilename,"a")
    f.close
    footerfilename = name + "_footer.txt"
    f= open(footerfilename,"a")
    f.close

    htmlmaker.buildDOTNAME(name, commentsfilename, footerfilename, file)
