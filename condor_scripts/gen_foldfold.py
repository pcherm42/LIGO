#!/bin/python
from subprocess import Popen, PIPE
import sys
import os

LOCATIONS = ['H1', 'L1']

ifo = ''
if len(sys.argv) > 1:
    ifo = sys.argv[1]

process = Popen(['pwd'], stdout=PIPE)
stdout = process.communicate()[0].strip('\n')
condorDir = stdout
currentDir = '/'.join(condorDir.split('/')[0:-1])
homeDir = '/'.join(condorDir.split('/')[0:-2])

channels = open('../ALLCHANNEL')
channels = channels.readlines()

count = 1

f = open('foldfold.dag', 'w')
for channel in channels:
    rate = channel.split()[1]
    channel = channel.split()[0]

    for location in LOCATIONS:

        f.write('JOB ' + str(count) + ' foldfold.sub\n')
        f.write('VARS ' + str(count) + ' ifo="' + location + ':' + channel + ifo + '" loc="' + location + '" foldSize="8" channel="' + channel + 
                '" FS="' + rate + '" dir="' + currentDir + '" months_file="' + homeDir + '/foldfold_periods/Post-O2.csv" jobid="foldfold_' + channel + 
                '_' + location + '" homeDir="' + currentDir + '" \n')
        count += 1
f.close()