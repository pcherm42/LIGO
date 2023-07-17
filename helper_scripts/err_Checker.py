#find -L ./out/*.err -maxdepth 1  -type f ! -size 0
import os
import time
from datetime import datetime
from collections import OrderedDict

os.system("find -L ./out/*.err -maxdepth 1  -type f ! -size 0 > O3_errlist_temp.txt")
with open("O3_errlist_temp.txt", "r") as f:
    fls = f.readlines()
os.system("rm O3_errlist_temp.txt")

fls_cleaned_ = []

for fil in fls:
    fls_cleaned_.append(fil.replace('./out/', ''))

fls_cleaned = list(OrderedDict.fromkeys(fls_cleaned_))

print("There are " + str(len(fls_cleaned)) + " nonempty error files.")

now = datetime.now()
today_time = str(now.strftime("%m-%d-%Y_%H:%M:%S")).strip()
missname = "nonemptyerr_files_" + today_time + ".txt"
print("Writing nonempty error files to: " + missname)
with open(missname, "a") as g:
    g.write("Nonempty Error Files:\n")
    for item in fls:
        g.write(item)
    g.write("\n")