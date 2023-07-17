#!/bin/bash                                                                              
# ------------------------------------------------------------------
# [Weigang Liu] Setting up directories for folding algrithm                           
#          This script will set up the diretories for folding scripts...
# ------------------------------------------------------------------ 

DIRECTORY_OUT="out"
DIRECTORY_FILES="files"
DIRECTORY_FILES_MATFILES="./files/matfiles"
DIRECTORY_FILES_MATFILES_DELTAL="./files/matfiles/DELTAL"
DIRECTORY_FILES_MATFILES_DELTAL_H1="./files/matfiles/DELTAL/H1"
DIRECTORY_FILES_MATFILES_DELTAL_L1="./files/matfiles/DELTAL/L1"
DIRECTORY_FILES_PDF="./files/pdf"
DIRECTORY_FILES_PNG="./files/png"
DIRECTORY_FILES_PEAKFILES="./files/peakfiles"
DIRECTORY_FILES_HTML="./files/html"
DIRECTORY_FILES_SPECTRA="./files/spectra"
DIRECTORY_CONDOR="condor"
DIRECTORY_CONDOR_LOG="condor/log"

if [ ! -d "$DIRECTORY_OUT" ]; then
    mkdir "$DIRECTORY_OUT"
fi

if [ ! -d "$DIRECTORY_FILES" ]; then
    mkdir "$DIRECTORY_FILES"
fi

if [ ! -d "$DIRECTORY_FILES_MATFILES" ]; then
    mkdir "$DIRECTORY_FILES_MATFILES"
fi

if [ ! -d "$DIRECTORY_FILES_MATFILES_DELTAL" ]; then
    mkdir "$DIRECTORY_FILES_MATFILES_DELTAL"
fi

if [ ! -d "$DIRECTORY_FILES_MATFILES_DELTAL_H1" ]; then
    mkdir "$DIRECTORY_FILES_MATFILES_DELTAL_H1"
fi

if [ ! -d "$DIRECTORY_FILES_MATFILES_DELTAL_L1" ]; then
    mkdir "$DIRECTORY_FILES_MATFILES_DELTAL_L1"
fi

if [ ! -d "$DIRECTORY_FILES_PDF" ]; then
    mkdir "$DIRECTORY_FILES_PDF"
fi

if [ ! -d "$DIRECTORY_FILES_PNG" ]; then
    mkdir "$DIRECTORY_FILES_PNG"
fi

if [ ! -d "$DIRECTORY_FILES_PEAKFILES" ]; then
    mkdir "$DIRECTORY_FILES_PEAKFILES"
fi

if [ ! -d "$DIRECTORY_FILES_HTML" ]; then
    mkdir "$DIRECTORY_FILES_HTML"
fi

if [ ! -d "$DIRECTORY_FILES_SPECTRA" ]; then
    mkdir "$DIRECTORY_FILES_SPECTRA"
fi

if [ ! -d "$DIRECTORY_CONDOR" ]; then
    mkdir "$DIRECTORY_CONDOR"
    mkdir "$DIRECTORY_CONDOR_LOG"
fi

for chan in $(cat ALLCHANNEL | awk -F' ' '{print $1}');do

    dir="./files/matfiles/$chan"
    dirH="${dir}/H1"
    dirL="${dir}/L1"
    if [ ! -d "$dir" ]; then
        mkdir "$dir"
    fi
    
    if [ ! -d "$dirH" ]; then
        mkdir "$dirH"
    fi
    
    if [ ! -d "$dirL" ]; then
        mkdir "$dirL"
    fi
done    