#reads resubmit_these.txt and resubmits the DAGS

import os

with open("resubmit_these.txt", "r") as f:
    files = f.readlines()

resub = []

for x in files:
    y = x.strip("\n")
    rm_command = "rm -v " + y + ".*"
    print("Doing: " + rm_command)
    os.system(rm_command)


    submit_command = "condor_submit_dag " + x
    print("Doing: " + submit_command)
    status = os.system(submit_command)

    #This bit catches errors
    if status != 0:
        print("Submission error, writing filename to resubmit_these.txt")

        resub.append(x)


with open('resubmit_these.txt','w'): pass

for z in resub:
    with open("resubmit_these.txt", "a+") as g:
        g.seek(0)
        ch = g.read(100)
        if len(ch) > 0 :
            g.write("\n")
        g.write(x)
