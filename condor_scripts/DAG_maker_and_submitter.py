#!/bin/python
# -*- coding: utf-8 -*
from subprocess import Popen, PIPE
import sys, datetime, calendar
import os

#This contains some important functions.

def makeDags(month, year):
    names = []
    year = int(year)

    #Get some information
    
    LOCATIONS = ['H1', 'L1']
    MONTHS = {'January':'01', 'February':'02', 'March':'03', 'April':'04', 'May':'05', 'June':'06',
          'July':'07', 'August':'08', 'September':'09', 'October':'10', 'November':'11', 'December':'12'}
          
    NEXTMONTHS = {'January':'February', 'February':'March', 'March':'April', 'April':'May', 'May':'June', 'June':'July',
          'July':'August', 'August':'September', 'September':'October', 'October':'November', 'November':'December', 'December':'January'}
          
          
    process = Popen(['pwd'], stdout=PIPE)
    stdout = process.communicate()[0]
    stdout = str(stdout, 'utf-8').strip('\n')
    condorDir = stdout
    currentDir = '/'.join(condorDir.split('/')[0:-1])
    homeDir = '/'.join(condorDir.split('/')[0:-2])

    segs = 'segsAnalysis.txt' #This is basically the end of the segfilename, check the f.write statements for the actual name.
    nextMonth = NEXTMONTHS[month]
    nextYear = year
    if nextMonth == 'January':
        nextYear += 1

    print('Creating dags for', month + '/' + str(year), 'with', segs)

    lastDay = calendar.monthrange(int(year), int(MONTHS[month]))[1]

    channels = open('../channels.txt').readlines()

    #This part does the work
    for channel in channels:

        rate = channel.split()[1]
        channel = channel.split()[0]

        for location in LOCATIONS:
            name = str(year) + '_' + month + '_' + channel + '_' + location + '.dag'
            f = open(name, 'w')

            for day in range(1, lastDay):

                process = Popen(['lalapps_tconvert', month + ' ' + str(day) + ' ' + str(year)], stdout=PIPE)
                stdout = process.communicate()[0]
                stdout = str(stdout, 'utf-8').strip('\n')


                startTime = int(stdout)

                process = Popen(['lalapps_tconvert', month + ' ' + str(day + 1) + ' ' + str(year)], stdout=PIPE)
                stdout = process.communicate()[0]
                stdout = str(stdout, 'utf-8').strip('\n')


                endTime = int(stdout)

                f.write('JOB ' + str(day) + ' foldingAnalysis.sub\n')
                f.write('VARS ' + str(day) + ' startTime="' + str(startTime) + '" endTime="' + str(endTime) +
                    '" foldSize="8" Fs="' + str(rate) + '" times_zoom="0" chanName="' + location + ':' + channel +
                    '" segFileName="' + homeDir + '/segments/' + str(year) + month + location + segs + '" matfilePath="' + currentDir + '/files/matfiles/' + channel +
                    '" numPartialFolds="8" jobid="' + channel + '_' + location + '_' + month + '_' + str(day) + '" homeDir="' + currentDir + '" \n')

            process = Popen(['lalapps_tconvert', month + ' ' + str(lastDay) + ' ' + str(year)], stdout=PIPE)
            stdout = process.communicate()[0]
            stdout = str(stdout, 'utf-8').strip('\n')


            startTime = int(stdout)

            process = Popen(['lalapps_tconvert', nextMonth + ' 1 ' + str(nextYear)], stdout=PIPE)
            stdout = process.communicate()[0]
            stdout = str(stdout, 'utf-8').strip('\n')

            endTime =  int(stdout)


            f.write('JOB ' + str(lastDay) + ' foldingAnalysis.sub\n')
            f.write('VARS ' + str(lastDay) + ' startTime="' + str(startTime) + '" endTime="' + str(endTime) +
                '" foldSize="8" Fs="' + str(rate) + '" times_zoom="0" chanName="' + location + ':' + channel +
                '" segFileName="' + homeDir + '/segments/' + str(year) + month + location + segs + '" matfilePath="' + currentDir + '/files/matfiles/' + channel +
                '" numPartialFolds="8" jobid="' + channel + '_' + location + '_' + month + '_' + str(lastDay) + '" homeDir="' + currentDir + '" \n')
            f.close()


            names.append(name)
    
    return names


def submitDAGS(NAMES):
    for NAME in NAMES:
        sub_command = os.system("condor_submit_dag " + NAME)

        #This bit catches errors
        if sub_command !=0:
            print("Submission error, writing filename to resubmit_these.txt")
            with open("resubmit_these.txt", "a+") as g:
                g.seek(0)
                ch = g.read(100)
                if len(ch) > 0 :
                    g.write("\n")
                g.write(NAME)