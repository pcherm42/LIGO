#!/bin/python
# -*- coding: utf-8 -*-
from subprocess import Popen, PIPE
import sys, datetime, calendar
import os

now = datetime.datetime.now()


LOCATIONS = ['H1', 'L1']

MONTHS = {'January':'01', 'February':'02', 'March':'03', 'April':'04', 'May':'05', 'June':'06',
          'July':'07', 'August':'08', 'September':'09', 'October':'10', 'November':'11', 'December':'12'}

NEXTMONTHS = {'January':'February', 'February':'March', 'March':'April', 'April':'May', 'May':'June', 'June':'July',
          'July':'August', 'August':'September', 'September':'October', 'October':'November', 'November':'December', 'December':'January'}

process = Popen(['pwd'], stdout=PIPE)
stdout = process.communicate()[0].strip('\n')
condorDir = stdout
currentDir = '/'.join(condorDir.split('/')[0:-1])
homeDir = '/'.join(condorDir.split('/')[0:-2])


segs = 'segsAnalysis.txt'
#segs = 'segs.txt'

if len(sys.argv) < 2:
    print('Must inclue month for submission')
    print('Try November')
    print(MONTHS)
    exit(1)

month = sys.argv[1]
year = now.year
nextMonth = NEXTMONTHS[month]

'''
if len(sys.argv) > 2:
    segs = sys.argv[2]
'''

if len(sys.argv) > 2:
    year = int(sys.argv[2])

nextYear = year
if nextMonth == 'January':
    nextYear += 1

print('Creating dags for', month + '/' + str(year), 'with', segs)

lastDay = calendar.monthrange(year, int(MONTHS[month]))[1]

channels = open('../channels.txt').readlines()

for channel in channels:


    rate = channel.split()[1]
    channel = channel.split()[0]

    for location in LOCATIONS:
        f = open(str(year) + '_' + month + '_' + channel + '_' + location + '.dag', 'w')
        name = str(year) + '_' + month + '_' + channel + '_' + location + '.dag'

        for day in range(1, lastDay):

            process = Popen(['lalapps_tconvert', month + ' ' + str(day) + ' ' + str(year)], stdout=PIPE)
            stdout = process.communicate()[0].strip('\n')

            startTime = int(stdout)

            process = Popen(['lalapps_tconvert', month + ' ' + str(day + 1) + ' ' + str(year)], stdout=PIPE)
            stdout = process.communicate()[0].strip('\n')

            endTime = int(stdout)

            f.write('JOB ' + str(day) + ' foldingAnalysis.sub\n')
            f.write('VARS ' + str(day) + ' startTime="' + str(startTime) + '" endTime="' + str(endTime) +
                '" foldSize="8" Fs="' + str(rate) + '" times_zoom="0" chanName="' + location + ':' + channel +
                '" segFileName="' + homeDir + '/segments/' + str(year) + month + location + segs + '" matfilePath="' + currentDir + '/files/matfiles/' + channel +
                '" numPartialFolds="8" jobid="' + channel + '_' + location + '_' + month + '_' + str(day) + '" homeDir="' + currentDir + '" \n')

        process = Popen(['lalapps_tconvert', month + ' ' + str(lastDay) + ' ' + str(year)], stdout=PIPE)
        stdout = process.communicate()[0].strip('\n')

        startTime = int(stdout)

        process = Popen(['lalapps_tconvert', nextMonth + ' 1 ' + str(nextYear)], stdout=PIPE)
        stdout = process.communicate()[0].strip('\n')

        endTime =  int(stdout)


        f.write('JOB ' + str(lastDay) + ' foldingAnalysis.sub\n')
        f.write('VARS ' + str(lastDay) + ' startTime="' + str(startTime) + '" endTime="' + str(endTime) +
                '" foldSize="8" Fs="' + str(rate) + '" times_zoom="0" chanName="' + location + ':' + channel +
                '" segFileName="' + homeDir + '/segments/' + str(year) + month + location + segs + '" matfilePath="' + currentDir + '/files/matfiles/' + channel +
                '" numPartialFolds="8" jobid="' + channel + '_' + location + '_' + month + '_' + str(lastDay) + '" homeDir="' + currentDir + '" \n')
        f.close()


        os.system("condor_submit_dag " + name)