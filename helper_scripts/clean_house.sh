#This deletes all files created by scripts

read -t 5 -r -s -p $'Clean all file directories in current directory? Press enter to continue... timout in 5 seconds.'

rm -v condor/2019*
rm -v condor/2020*
rm -v matlab/*.temp
rsync -a --delete ~/empty/ out/
find files -type f -delete