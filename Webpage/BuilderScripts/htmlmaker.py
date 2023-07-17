def buildDOTNAME(title, commentsfile, footerfile, pngpath):
    #IMAGEPATH, ~COMMENTS~, ~FOOTER~, ~DOTNAME~

    with open(commentsfile, 'r') as comfile:
                    comments = comfile.read()
    comfile.close

    with open(footerfile, 'r') as footfile:
                    footer = footfile.read()

    footfile.close

    print("Comments are " + comments)
    print("Footer is " + footer)


    with open("DOTNAME.txt") as f:
        lines=f.readlines()
        with open(title + ".html", "w") as f1:
            for line in lines:

                line = line.replace("IMAGEPATH", pngpath)
                line = line.replace("~DOTNAME~", title)
                line = line.replace("~COMMENTS~", comments)
                

                
                line = line.replace("~FOOTER~", footer)
                f1.write(line)
            
        

