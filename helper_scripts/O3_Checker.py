#Checks to see if all the .mat files were created by folding analysis. Does not check for foldfold.

import os
import time
from datetime import datetime
from collections import OrderedDict

#makes a file list, reads in all the files, and then deletes the file list. This method is kind of slow and bad but works.
os.system("find files/matfiles -type f > O3_filelist_temp.txt")
with open("O3_filelist_temp.txt", "r") as f:
    paths = f.readlines()
os.system("rm O3_filelist_temp.txt")


filetypes = ["_folded_veto-5.000000_8sec.mat", "_folded_veto_PartialFold_1-5.000000_8sec.mat", "_folded_veto_PartialFold_2-5.000000_8sec.mat",
        "_folded_veto_PartialFold_3-5.000000_8sec.mat", "_folded_veto_PartialFold_4-5.000000_8sec.mat", "_folded_veto_PartialFold_5-5.000000_8sec.mat",
        "_folded_veto_PartialFold_6-5.000000_8sec.mat", "_folded_veto_PartialFold_7-5.000000_8sec.mat", "_folded_veto_PartialFold_8-5.000000_8sec.mat"]

months = ["April", "May", "June", "July", "August", "September", "November", "December", "January", "February", "March"]

years = ["2019","2019","2019","2019","2019","2019","2019","2019","2020","2020","2020"]
day_amounts = [30, 31, 30, 31, 31, 30, 30, 31, 31, 29, 27]

locations = ["L1", "H1"]


channels = ["PEM-EY_MAG_EBAY_SUSRACK_Z_DQ","PEM-EY_MAG_EBAY_SUSRACK_Y_DQ","CAL-DELTAL_EXTERNAL_DQ","PEM-CS_MAG_LVEA_VERTEX_Y_DQ",
    "PEM-CS_MAG_EBAY_SUSRACK_Z_DQ","PEM-CS_MAG_LVEA_VERTEX_X_DQ","SUS-ETMY_L3_MASTER_OUT_LL_DQ","PEM-EX_MAG_EBAY_SUSRACK_Y_DQ",
    "PEM-EX_MAG_EBAY_SUSRACK_X_DQ","PEM-CS_MAG_EBAY_SUSRACK_X_DQ","PEM-CS_MAG_LVEA_VERTEX_Z_DQ",
    "PEM-EX_MAG_EBAY_SUSRACK_Z_DQ","PEM-CS_MAG_EBAY_SUSRACK_Y_DQ","PEM-EY_MAG_EBAY_SUSRACK_X_DQ","PEM-EX_ADC_0_12_OUT_DQ",
    "PEM-EY_ADC_0_12_OUT_DQ"]

missing = []
missing_HR = []


for idx, month in enumerate(months):
    year = years[idx]
    days = day_amounts[idx]
    day = 1
    while day <= days:
        if day < 10:
            stringday = "0"+str(day)
        else:
            stringday = str(day)
        print("Checking files for " + month + ", " + stringday)

        for channel in channels:
            for location in locations:
                for ftype in filetypes:
                    path = "files/matfiles/" + channel + "/" + location + "/" + month + "-" + stringday + "-" + year + ftype + "\n"
                    if path in paths:
                        print("Found: " + path.strip("\n"))
                        break
                    else:
                        missing.append(path.strip("\n"))
                        missing_HR.append(channel + " " + location + " "+ year + " " + month + " " + stringday)


        day = day +1

print("Checking done... If no lines following, then all the O3 .mat files are present from folding analysis. Here are the results:")

time.sleep(5)

for fil in missing:
    print("Missing file: " + fil)

def ask_user():
    yes = ["y","Y","yes","Yes"]
    no = ["n","N","no","No"]
    check = str(raw_input("Write missing files to a text document? (y/n): ")).lower().strip() #Need raw_imput sice LIGO uses old python
    try:
        if check in yes:
            return True
        elif check in no:
            return False
        else:
            print('Invalid Input')
            return ask_user()
    except Exception as error:
        print("Please enter valid inputs")
        print(error)
        return ask_user()


missing_HR_cleaned = list(OrderedDict.fromkeys(missing_HR))

ask = ask_user()
if ask:
    now = datetime.now()
    today_time = str(now.strftime("%m-%d-%Y_%H:%M:%S")).strip()
    missname = "missing_files_" + today_time + ".txt"
    print("Writing missing files to: " + missname)
    with open(missname, "a") as g:
        g.write("Missing files:\n")
        for item in missing:
            g.write(item + "\n")
        g.write("\n")
        g.write("Missing days:\n")
        for d in missing_HR_cleaned:
            g.write(d + "\n")
        
    print("Done!")
else:
    print("Done!")


#files contains entries like: files/matfiles/CAL-DELTAL_EXTERNAL_DQ/L1/September-16-2019_folded_veto_PartialFold_1-5.000000_8sec.mat