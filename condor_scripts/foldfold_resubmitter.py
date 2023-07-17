#This guy removes all foldfold files for the bad channels, checks all days for zeros, deletes those days, and writes the name to a dag file
#RUN THIS COMMAND BEFORE DOING THIS: find ~/...Where_your_matfiles_are/matfiles -exec chmod +rwx {} \;
#find ~/FoldingAnalysis/O3/files/matfiles -exec chmod +rwx {} \;
## READS FROM A FILE CALLED foldfold_resub.txt -- should be formatted like:
'''
CAL_DELTAL_EXTERNAL_DQ H1
channel1 location1
channel2 location2
channelN locationN
'''

import os
from subprocess import Popen, PIPE
import sys

## This part defines a function that returns true when the day is only zeros or contains a NaN and false otherwise:
#./run_zeroreader.sh /ldcg/matlab_r2020a path
def zero_checker(filenames):

    with open("zeroreader_imput.temp", "a") as k:
        for fle in filenames:
            k.write(fle)
    


    command = "./run_zeroreader.sh /ldcg/matlab_r2020a"
    t = Popen([command], stdout=PIPE, shell=True)
    (_,__) = t.communicate()
    ___ = t.wait()

    os.system("rm zeroreader_imput.temp")




### THIS PART READS FROM THE FILE AND ORGANIZES THE DATA

with open("foldfold_resub.txt", "r") as f:
    lines = f.readlines()

channels = []
locations = []

for line in lines:
    locations.append(line.split()[1])
    channels.append(line.split()[0])

foldfold_filetypes = ["html", "pdf", "png", "spectra"]



for channel, location in zip(channels, locations):

    ### REMOVE ALL FOLDFOLD FILES FOR DAY ##
    for folder in foldfold_filetypes:
        rm_command = "rm ../files/" + folder + "/" + location + ":" + channel + "*"
        os.system(rm_command)
        os.system("rm ../files/html/" + "index_" + location + ":" + channel + "*")

    ## DELETE DAYS WITH ZEROS ##
    find_command = "find ../files/matfiles/" + channel + "/" + location + " -name " + "*.mat" "> finder.temp"
    os.system(find_command)
    with open("finder.temp", "r") as g:
        files=g.readlines()
    os.system("rm finder.temp")

    counter = 0
    length = len(files)
    print("Counter will reach: " + str(length))
    while counter <= length:
        print("Counter " + str(counter) )
        if counter + 10 < length:
            zero_checker(files[counter:counter+10])
        else:
            zero_checker(files[counter:])
        counter = counter + 11

    with open("statuses.temp", "r") as h:
        statuses=h.readlines()
    os.system("rm statuses.temp")

    for fil, status in zip(files, statuses):
        if status == 1:
            print("File is all zeros: " + fil)
            os.system("rm " + fil)
            print("Removed "+ fil)
        else:
            print("Found nonzero file: "+ fil)

        



### Writes names to foldfold_resub.dag ##

ifo = ''
process = Popen(['pwd'], stdout=PIPE)
stdout = process.communicate()[0].strip('\n')
condorDir = stdout
currentDir = '/'.join(condorDir.split('/')[0:-1])
homeDir = '/'.join(condorDir.split('/')[0:-2])

######################################### RATES BLOCK ###########################################
rates = []

print("NOTE: The RATES are hard-programmed into this script. If you add a new channel, then you have to check the rates block in this script.")

for channel in channels:
    if channel == "CAL-DELTAL_EXTERNAL_DQ":
        rates.append("16384")
    elif channel == "SUS-ETMY_L3_MASTER_OUT_LL_DQ":
        rates.append("16384")
    elif channel == "PEM-EX_ADC_0_12_OUT_DQ":
        rates.append("2048")
    elif channel == "PEM-EY_ADC_0_12_OUT_DQ":
        rates.append("2048")
    else:
        rates.append("8192")

########################################################## end RATES BLOCK ############################################

f = open('foldfold_resub.dag', 'w')
count = 1
for channel, location, rate in zip(channels, locations, rates):
    f.write('JOB ' + str(count) + ' foldfold.sub\n')
    f.write('VARS ' + str(count) + ' ifo="' + location + ':' + channel + ifo + '" loc="' + location + '" foldSize="8" channel="' + channel + 
                '" FS="' + rate + '" dir="' + currentDir + '" months_file="' + homeDir + '/foldfold_periods/Post-O2.csv" jobid="foldfold_' + channel + 
                '_' + location + '" homeDir="' + currentDir + '" \n')
    count += 1

f.close()