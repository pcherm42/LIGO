'''This script reads a text file resubmit_these_days.txt with days formatted like:

CAL-DELTAL_EXTERNAL_DQ L1 2019 December 18
SUS-ETMY_L3_MASTER_OUT_LL_DQ L1 2019 December 18
PEM-EY_MAG_EBAY_SUSRACK_Z_DQ L1 2019 December 29
PEM-EY_MAG_EBAY_SUSRACK_Y_DQ L1 2019 December 29
PEM-CS_MAG_LVEA_VERTEX_Y_DQ L1 2019 December 29

And writes .dag files formatted to be submitted. This script skips resubmitting tuesdays with more than 5 entries. 


'''


import os
from subprocess import Popen, PIPE
import sys, datetime, calendar

chunksize = 30 #how many jobs are in each dag file

def jobwrite(channel, location, year, month, day): #this function returns the proper line in a .dag file without the 'VARS ' + str(jobcounter)
    segs = 'segsAnalysis.txt'

    day = int(day)
    year = int(year)

    if channel == "CAL-DELTAL_EXTERNAL_DQ":
        rate = 16384
    elif channel == "PEM-EX_ADC_0_12_OUT_DQ" or channel == "PEM-EY_ADC_0_12_OUT_DQ":
        rate = 2048
    else:
        rate = 8192

    #The following block is confusing, but it basically is a complicated way to get the starttime, endtime, home and current directories.
    process = Popen(['pwd'], stdout=PIPE)
    stdout = process.communicate()[0].strip('\n')
    condorDir = stdout
    currentDir = '/'.join(condorDir.split('/')[0:-1])
    homeDir = '/'.join(condorDir.split('/')[0:-2])
    process = Popen(['lalapps_tconvert', month + ' ' + str(day) + ' ' + str(year)], stdout=PIPE)
    stdout = process.communicate()[0].strip('\n')
    startTime = int(stdout)
    process = Popen(['lalapps_tconvert', month + ' ' + str(day + 1) + ' ' + str(year)], stdout=PIPE)
    stdout = process.communicate()[0].strip('\n')
    endTime = int(stdout)

    ans = ' startTime="' + str(startTime) + '" endTime="' + str(endTime) + '" foldSize="8" Fs="' + str(rate) + '" times_zoom="0" chanName="' + location + ':' + channel + '" segFileName="' + homeDir + '/segments/' + str(year) + month + location + segs + '" matfilePath="' + currentDir + '/files/matfiles/' + channel + '" numPartialFolds="8" jobid="'+ 'resub_' + channel + '_' + location + '_' + month + '_' + str(day) + '" homeDir="' + currentDir + '" \n'

    return ans

with open("resubmit_these_days.txt", "r") as f:
    lines = f.readlines()

daglines = []

for line in lines:
    chan, loc, year, month, day = line.split()
    date = day + " " + month + " " + year
    weekdy = datetime.datetime.strptime(date, '%d %B %Y').weekday()
    day_name = calendar.day_name[weekdy]

    if day_name != "Tuesday": #the day is not a tuesday, then call the function and append to daglines. else just print "skipping "
        dagline = jobwrite(chan, loc, year, month, day)
        daglines.append(dagline)
    else:
        printstatement = "Skipping " + line
        print(printstatement.strip("\n"))


n = 1
jobcounter = 1

for i, lin in enumerate(daglines):

    if i > n*chunksize:
        n = n + 1
        jobcounter = 1

    dagname = "resub_chunk_" + str(n) + ".dag"
    with open(dagname, "a") as f:
        f.write('JOB ' + str(jobcounter) + ' foldingAnalysis.sub\n')
        f.write( 'VARS ' + str(jobcounter) + lin)
    
    jobcounter = jobcounter + 1