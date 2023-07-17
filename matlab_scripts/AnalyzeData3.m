% Gets data from NDS2 server and analyzes it
% @param date Is the string Julian Date that will be used to create the
% filename in foldingAanlysis. MUST BE A STRING!

function trend= AnalyzeData3(startTime, duration, foldSize, oneSecLength, chanName, segfileName, matfilePath, numPartialFolds)
    fprintf('line %d\n', 7); 
    fprintf('  Starting AnalyzeData 3 with startTime=%d, duration=%d, foldSize=%d\n',startTime,duration,foldSize);
    fprintf('line %d\n', 9); 
    fakedata = 0;
    runningoncluster = 1;
    startdelay = 1;
    
    if fakedata == 1
        fprintf('Generating fake random data...\n');
        totalsamples = duration*oneSecLength;
        data = normrnd(0,1.,totalsamples,1);
        fprintf('Fake data generated\n');
    else
        if runningoncluster == 1
            fprintf('  Calling readsciencedata...\n');
            [data, segDurList]=readsciencedata(startTime, duration, chanName,  segfileName, oneSecLength, foldSize);
            fprintf('the length of data is %d,  Returned from readsciencedata...\nsegfile name: %s, datafind command: %s/n', length(data), segfileName);

%redundant because runningoncluster is always 1
        %else
            %fprintf('  Calling getsciencedata...\n');
            %data=getsciencedata(startTime, duration);
            %fprintf('  Returned from getsciencedata...\n');
        end  
    end
    
    
    % when data = 0, return to run.m and preceed to the next range
    if length(data) == 0
        trend = false;
        fprintf('trend is false\n'); 
        return;
    end
    
    leng = length(data);
    fprintf('Length of data is %d', length(data)); 
    % construct segList
    l = length(segDurList);
    if l == 1
        segList = segDurList;
    else 
        segList = [segDurList(1)]; 
        for i = 2 : l - 1 
            segList = [segList segDurList(i) + segList(i - 1)];
        end  
    end
    
    Xl = 1 : oneSecLength;
    Xl = Xl / oneSecLength;
    Xl = transpose(Xl);

    fprintf('Value of size(data) is %f\n',size(data))
    fprintf('Value of oneSecLength is %f\n',oneSecLength)

    % fix the gaps, now scale the first second of data
    OldYFirstSec = data( 1 : oneSecLength, 1 );
    YFirstSec = OldYFirstSec .* (Xl .* Xl);
    data( 1 : oneSecLength, 1 ) = YFirstSec;  
    % fix gaps in betw gaps based on segList
    n = length(segList);
    fprintf('length of data %d\n\n', length(data));
    for i = 1 : n - 1
        fprintf('length of data %d\n\n', length( data ) );
        prt = segList(i) * oneSecLength;
        leftPrt = (segList(i) - 1) * oneSecLength + 1;
        rightPrt = (segList(i) + 1) * oneSecLength - 1;
        fprintf('rightprt is %d, and length of the data is %d\n', rightPrt, length(data));
        YleftOld = data(leftPrt : prt);
        YrightOld = data(prt : rightPrt);
        avg = ( mean(YleftOld) + mean(YrightOld) ) / 2;
        Yright = YrightOld .* (Xl .* Xl) + avg;
        Yleft = YleftOld .* ( Xl -1 ) .* (Xl - 1 ) + avg;
        Y = [Yleft; Yright];
        right = rightPrt + 1;
        fprintf('right is %d\n', right);
        data(leftPrt : right) = Y;
        fprintf('ad line 75\n'); 
        fprintf('i is %d, and n is %d\n', i, n); 
    end
    
    %  injecting a peak in each second
    %  secNum = 1; 
    %  while secNum * oneSecLength < length(data)
    %  data(secNum * oneSecLength - 2) = data(secNum * 16384 - 2) + 1 * 10 ^(-7); 
    %  data(secNum * oneSecLength - 1) = data(secNum * 16384 - 1) + 3 * 10 ^ (-7 ); 
    %  data(secNum * oneSecLength) = 7 * 10 ^(-7) + data(secNum * 16384); 
    %  data(secNum * oneSecLength + 1) = 3 * 10^(-7) + data(secNum * 16384 + 1); 
    %  data(secNum * oneSecLength + 2) = 1 * 10^(-7) +  data(secNum * 16384 + 2); 
    %  secNum = secNum + 1; 
    %  end
    
    if size(data)>0
        fprintf('  Calling foldingAnalysis 3 ... with starting time %d\n', startTime);
        trend = 9; 
        matfilePath
        trend=foldingAnalysis3(data, foldSize, oneSecLength, startTime, chanName, segfileName, matfilePath, 0);

        fprintf('  Creating %d partial folds...\n', ...
                numPartialFolds);

        partialFoldSizes = zeros(1,numPartialFolds);
        for i=floor(length(data)/foldSize/oneSecLength):-1:1
            partialFoldSizes(mod(i,numPartialFolds) + 1) = ...
                partialFoldSizes(mod(i,numPartialFolds) + 1) + 1;
        end
        partialFoldSizes = partialFoldSizes * foldSize * oneSecLength;
        
        for i = 1:numPartialFolds
            newData = data( (sum(partialFoldSizes(1:i-1))+1): ...
                  (sum(partialFoldSizes(1:i)) ));

            fprintf('Entering fold %d \n', i);

            Trend=foldingAnalysis3(newData, foldSize, oneSecLength, startTime, chanName, segfileName, matfilePath, i);
        end
        
        fprintf('  Returned from foldingAnalysis 3...\n');
    else
        trend = false;
        fprintf('   No science segments in interval, no call to foldingAnalysis\n');
    end
    fprintf('Exiting AnalyzeData3\n')
end