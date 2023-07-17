#!/bin/sh

# This script creates a new directory for standard Folding Analysis
# __Foldfold.sh  matlab_wrapper.sh foldfold.sub runFoldfold.sh foldingAnalysis.sub gen_sub.py gen_foldfold.py foldfold_wrapper.sh
# need to be updated in the new directory

while :; do
    case $1 in
        -m|--matlab) # Set flag to indicate hat the matlab directory should be compied
            matlab=1;
            shift
            ;; 
        -h|--help) # Display help information
            echo This script is used to create a new directory for the FoldGPS system. ./creatDir.sh [Directory Name] will create a new directory with the required subdirectories and move the required scripts into their proper locations. Use the -m flag to create a new local matlab folder.
            exit
            ;;
        *)
            break
            ;;
    esac
done

[[ ! -z  $1  ]] && [[ ! -d $1 ]] || { echo 1>&2 "arg1 must be a valid directory name"; exit 1; }

echo -e "Creating directory $1 ---\n\tDon't forget to update matlab/__Foldfold.sh  matlab/matlab_wrapper.sh runFoldfold.sh condor/gen_sub.py condor/gen_foldfold.py matlab/foldfold_wrapper.sh"

dir_name=$1
mkdir $dir_name; cd $dir_name;
cp -s ../ALLCHANNEL .; touch channels.txt

# Move old scripts -- may point to old directories
cp ../common_scripts/*.sh .
../build_dir.sh
cd condor/; mkdir log; cp ../../condor/* .;
mv gen_sub.py gen_sub.py.common; mv gen_foldfold.py gen_foldfold.py.common;  
cd ../;
if [ ! -z $matlab ]; then 
    echo -e "Copying matlab directory"; mkdir matlab; cd matlab; cp ../../matlab/* .; 
    mv foldfold_wrapper.sh foldfold_wrapper.sh.common; 
    mv matlab_wrapper.sh matlab_wrapper.sh.common; 
else
    echo "Making a symbolic matlab";
    ln -s ../matlab matlab;
fi