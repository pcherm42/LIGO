% startTime & endTime correspond to the actual start & end of the time period;
% if puting the startTime identical as the endTime, this program will examine 1600s data

function one = run(startTime, endTime, foldSize, Fs, times_zoom, chanName, segFileName, workingDirPath, numPartialFolds)
    %path(path, '/usr/share/ligotools/matlab')
%    workingDirPath
   fprintf('Entering run with startTime=%s, endTime=%s foldSize=%s, Fs=%s, times_zoom=%s\n-> chanName=%s\n-> segFileName=%s\n-> workingDirPath=%s\n-> numPartialFolkds=%s\n',startTime,endTime,foldSize,Fs,times_zoom,chanName,segFileName,workingDirPath,numPartialFolds);
    startTime = str2num(startTime);
    endTime = str2num(endTime);
    foldSize = str2num(foldSize);
    Fs = str2num(Fs);
    times_zoom = str2num(times_zoom);
    numPartialFolds = str2num(numPartialFolds);
    %workingDirPath = ['/home/weigang.liu/public_html/advancedLIGO_3/2016/files/matfiles/' workingDirPath];
%    startTime
%    endTime
%    foldSize
%    times_zoom
%    chanName
%    segFileName
%    numPartialFolds

    % this part is only for automated cron jobs to produce updated plots every time when a piece of new data come out
    label = [chanName '8sec_40Hz_lowpass'];
    filePath = workingDirPath;
    dataPerSec = 16384 / 2;
    if chanName(1) == 'H'
        filePath = [filePath '/H1'];
    else
        filePath = [filePath '/L1'];
    end


    sigma_cut = 5.0;
    nday = 1;
    oneDayInSec = 86400;
    dur = endTime - startTime;
    fprintf('Calling AnalyzeData3 with startTime=%d, dur=%d, foldSize=%d, Fs=%d\n-> chanName=%s\n-> segFilename=%s\n-> filePath=%s, numPartialFolds=%d\n',startTime,dur,foldSize,Fs,chanName,segFileName,filePath,numPartialFolds);
    trend = AnalyzeData3(startTime, dur, foldSize, Fs, chanName, segFileName, filePath, numPartialFolds);
    fprintf('Exiting run...\n')
    one = 1;
end
