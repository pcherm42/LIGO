function [data,addent, flag,lastIndex,errCode,sRate,times] = readFrames(fileList,chanName,startGPSTime,duration,fileListIsInMemory, startIndex)
    
    %fileList
    %chanName
    %startGPSTime
    %duration
    %fileListIsInMemory
    %startIndex
        
        %   fprintf('in readFrames...\n');
        %   fprintf('arguments: fileList: %s, \nchanName: %s,\nstartGPSTime: %d\n, duration: %d,\nfileListIsInMemory: %d\n', fileList, chanName, startGPSTime, duration, fileListIsInMemory); 
        
        %
        % usage: [data,lastIndex,errCode,sRate,times] = readFrames(fileList,chanName,startGPSTime,duration,fileListIsInMemory,startIndex)
        %
        % Examples:
        %
        % 1. Read 60 s of H1:LSC-DARM_ERR from files listed in a lal cache file myLALCacheFile.txt (e.g., as returned by ligo_data_find):
        %
        %   x = readFrames('myLALCacheFile.txt','H1:LSC-DARM_ERR',940000000,60);
        %
        % 2. Read 60 s of H1:LSC-DARM_ERR if myFileList is a list of filenames held in memory (note fileListIsInMemory is set to 1):
        %
        %   x = readFrames(myFileList,'H1:LSC-DARM_ERR',940000000,60,1);
        %
        % 3. Read every 60 s of H1:LSC-DARM_ERR data from a list of files, myFileList:
        %
        %   myFileList = cellstr([ '/path/filename1' '/path/filename2' '/path/filename3' ...]);
        %   myChannel = 'H1:LSC-DARM_ERR';
        %   startGPSTime = 940000000;
        %   endGPSTime = 940000000 + 86400;
        %   duration = 60;
        %   startIndex = 1;
        %   while (startGPSTime < endGPSTime)
        %        [x,lastIndex] = readFrames(myFileList,myChannel,startGPSTime,duration,1,startIndex);
        %
        %        % DO SOMETHING WITH x...
        %
        %        % Update for the next call in the loop:
        %        startGPSTime = startGPSTime + duration;
        %        startIndex = lastIndex; 
        %   end
        %
        % Inputs:
        %
        % fileList: A filename with a lal-cache style list of frame files or a list of filenames. (See isListNotFile option below.)
        % chanName: The name of the channel to read from the frames.
        % startGPSTime: The GPS start time of first sample to return.
        % duration: The duration in seconds to return.
        % fileListIsInMemory: Set this to 1 if fileList is a list of filenames, and not a fileName with this list. (Optional.)
        % startIndex: The index from which to start in the list of files (optional, default is 1)
        %
        % Outputs:
        %
        % data: The data from channel.
        % lastIndex: The last index used in the list of files
        % errCode: The error code returned (0 means no error)
        % sRate: The sample rate of this channel.
        % times: The times, 0 corresponds to startGPSTime.
        %
        % Note the last two Input options are useful if a long list of files held in memory is sent to readFrames over and over,
        % with each call running on the next sequential subset of the files. For example, if fileList contains the list of files
        % covering an entire day, and we wish to run on every 60 seconds of data, then set isListNotFile to 1 and duration to 60,
        % and after each call to readFrames update startGPSTime to startGPSTime + duration, and update startIndex to the returned
        % value of lastIndex. The readFrames function will then pick up from the correct place in the fileList from which the last
        % call left off.
        % Initialize variables:
        % fprintf('first line\n');
        %fprintf('check the value of fileList: %s\n', fileList);
        errCode = 0;
        endGPSTime = startGPSTime + duration;
        durationFound = 0;
        fileLocalHostStr = 'file://localhost';
        fileLocalHostStrLen = length(fileLocalHostStr);
        data = [];
        
        % set default values:
        % fprintf('check the value of nargin: %d\n', nargin);
        if (nargin < 5)
            fileListIsInMemory = 0;
        end
        if (nargin < 6)
            startIndex = 1;
        end
        
        % fprintf('check the value of fileListIsInMemory: %d \n', fileListIsInMemory);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Read in the fileList or initialize listOfFiles
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if (fileListIsInMemory > 0)
            % listOfFiles = fileList;
            % the line below is added on May 11, 2014
            [listOfFiles] = textread(fileList,'%s');
        else
            %   [tmp1, tmp2, tmp3, tmp4, listOfFiles] = textread(fileList,'%s %s %s %s %s');
            %   [listOfFiles, tmp1, tmp2, tmp3, tmp4] = textread(fileList,'%s %s %s %s %s');
            [listOfFiles] = textread(fileList,'%s');
        end
        cellOfFiles = cellstr(listOfFiles);
        fprintf('Reading from files: \n');
        fprintf('%s \n', cellOfFiles{:});
        listOfFilesLen = length(listOfFiles);
        
        %fprintf('check the value of listOfFiles: \n, with lenght %d\n', listOfFilesLen);
        %for i = 1 : listOfFilesLen
        %    str1 = sprintf('%s', char(listOfFiles(i)));
        %    fprintf('%s\n', str1);
        %end
        %fprintf('check the value of listOfFilesLen = %d\n', listOfFilesLen);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Here is the main loop over the listOfFiles.
        %
        % Note that listOfFiles contains lines like this,
        %
        % H R 954115168 32 file://localhost/data/node150/frames/S6/L0/LHO/H-R-95411/H-R-954115168-32.gwf
        % H R 954115200 32 file://localhost/data/node150/frames/S6/L0/LHO/H-R-95411/H-R-954115200-32.gwf
        %
        % or is a list like this,
        %
        % [ '/path/filename1' '/path/filename2' '/path/filename3' ...]
        % 
        % Keeping everything past file://localhost, go through the list of files and parse out the
        % filename, GPS start times, and duration of each file and read the data from each file with
        % data between startGPSTime and endGPSTime. Break of of the loop when endGPSTime is reached.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %  fprintf('before list filepaths, startIndex is unknown, listOfFileLen is %d\n', listOfFilesLen);
        %record=['/test/node250/frames/O1/raw/L1/L-L1_R-113123/L-L1_R-1131234624-64.gwf'];
        for j = startIndex : listOfFilesLen
            fprintf("j= %d: %s\n",j,char(listOfFiles(j)));
            %    fprintf('in the for loop, j is %d\n', j);
            % fprintf('in the for loop, and the value of index j = %d\n', j);
            % Get the filename with the path from each line in listOfFiles.
            thisLine = char(listOfFiles(j)); % convert this line into char data
            thisPos = findstr(fileLocalHostStr,thisLine); % find the position of the fileLocalHostStr string:
                                                          % printf('this line: %s\nthis position: %d\n',thisLine,thisPos);
            if(~isempty(thisPos))
                thisFile = thisLine((thisPos+fileLocalHostStrLen):end);  % slice out the filename with the path:
                                                                         %fprintf('check the value of this file: \n%s\n',thisFile);   
            else
                thisFile = thisLine;
            end
            %  record = [record; thisFile]; 
            %  fprintf('this file: %s\n',thisFile);
            % parse out the GPS time and duration and get the start/end time of thisFile.
            regExOut = regexp(thisFile,'-(?<GPS>\d+)-(?<DUR>\d+)\.','names');
            thisStartTime = str2num(regExOut.GPS);
            thisDuration = str2num(regExOut.DUR);
            thisEndTime = thisStartTime + thisDuration;
            if (thisEndTime <= startGPSTime)
                %fprintf('continue...\n');
                continue; % This file ends before the start of the data we want; continue to the next file
            elseif (thisStartTime >= endGPSTime)
                % fprintf('break...\n');
                break; % This file starts after the end of the data we want; break out of the loop
            else
                % This file contains some of the data we want.  Read it out using frgetvect.
                gpsStart = max( [startGPSTime,thisStartTime] );
                gpsEnd = min( [endGPSTime,thisEndTime] );
                dur = gpsEnd - gpsStart;
    
                % Try multiple times to retreive data - Sometimes
                % frgetvec returns an empty vector
                tempData = [];
                
                try
                    %fprintf('Im in try block, just before the more data are obtained by calling frgetvect.\n');
                    %thisData = frgetvect(thisFile,chanName,gpsStart,dur);
                    %data = [data;thisData];
                    
                    fprintf('Calling frgetvect(%s, %s, %d, %d);\n', thisFile,chanName,gpsStart,dur);
                    tempData = frgetvect(thisFile,chanName,gpsStart, ...
                                         dur, 0);
                    % injecting a peak in each second
                    %  secNum = 1;
                    %  while secNum * 16384 < length(tempData)
                    %  tempData(secNum * 16384 - 2) = tempData(secNum * 16384 - 2) + 1 * 10 ^(-7);
                    %  tempData(secNum * 16384 - 1) = tempData(secNum * 16384 - 1) + 3 * 10 ^ (-7 );
                    %  tempData(secNum * 16384) = 4 * 10 ^(-7) + tempData(secNum * 16384);
                    %  tempData(secNum * 16384 + 1) = 3 * 10^(-7) + tempData(secNum * 16384 + 1);
                    %  tempData(secNum * 16384 + 2) = 1 * 10^(-7) +  tempData(secNum * 16384 + 2);
                    % secNum = secNum + 1;
                    %end
                    if(length(tempData) == 0)
                        error(sprintf(['Error reading data from %s ' ...
                                       '\n'],thisFile));
                    end
                                    
                    data = [data; tempData];
                    tempData = []; 
                    %fprintf('Now print the parameters, file name : %s, chanName: %s, gpsStart: %d, dur: %d \n', thisFile, chanName, gpsStart, dur);
                    durationFound = durationFound + dur;
                    %fprintf('the data durationFound is %d\n', durationFound);
                catch
                    errCode = 1;
                    fprintf('Error reading data from %s \n',thisFile);
                    error(sprintf('Error reading data from %s \n',thisFile));
                end
                if (thisEndTime >= endGPSTime)
                    % This file ends after the end of the data we want; break out of the loop.
                    %fprintf('thisEndTime >= endGPSTime, \nThis file ends after the end of the data we want; break out of the loop.\n');
                    break;
                end
            end
        end
        %     fprintf('the error codes\n');
        % Set lastIndex to the last index used in the loop above: 
        lastIndex = j;
        if (length(data) == 0)
            fprintf('No data found \n');
            fprintf('lastIndex=%d',lastIndex);
            error('frgetvec did not return any a data, lastIndex=%d',lastIndex);
            errCode = 2;
        elseif (durationFound < duration)
            fprintf('Some data is missing \n');
            error('frgetvec did not return all the data');
            errCode = 3;
        end
        if (nargout > 3)
            nSamples = length(data);
            sRate = floor(nSamples/duration + 0.5);
        end
        if (nargout > 4)
            deltaT = 1.0/(1.0*sRate);
            times = (0:nSamples-1)*deltaT;
        end
        % fprintf('the errorCode is %d\n, and the value of nargout is %d\n', errCode, nargout);
        
        %fprintf('duration is %d \n', duration);
        addent = duration;
        if duration < 900  
            %  fprintf('  hit the end of the segment, evaluate addent...\n  The start time is %d, and the duration is %d, the last elem in data %d \n', startGPSTime, duration,data(length(data)));
            flag = 1;
        else
            flag = 0;
        end
        return;