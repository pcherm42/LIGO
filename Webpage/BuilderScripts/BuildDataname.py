import os
import htmlmaker

files = os.listdir("X:\SSD_Documents\LIGO\Webpage\BuilderScripts\DataDays")

for file in files:
    name = file.replace('.html', '')

    commentsfilename = name + "_comments.txt"
    f= open(commentsfilename,"w+")
    f.close
    footerfilename = name + "_footer.txt"
    f= open(footerfilename,"w+")
    f.close

    htmlmaker.buildDOTNAME(name, commentsfilename, footerfilename, file)
