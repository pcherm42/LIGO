function [data, segLocList] = readsciencedata( startTime, duration, chanName, segFileName, Fs, foldSize)
    %ReadScienceData: read data that is already on the ligo cluster
    %startTime=962641856; %This the startime I generally use for default. It is
    %already divisible by 32.
        ntry = 20;  %originally set to 3
    
        startTime
        duration
        chanName 
        segFileName
        Fs
        foldSize
        blocksize = 900;
        segLocList = 0;
        flag = 0;
        segListPrt = 1;
        fprintf('    Entering readsciencedata with startTime=%d, duration=%d\n',startTime,duration);
        start=datestr(now);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        % Read in the science segments and create the array of science segments in this range
        % 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        scisegs=dlmread(segFileName);
        if (strcmp(chanName(4:13), 'CAL-DELTAL')==0) & (strcmp(chanName(4:13), 'SUS-ETMY_L')==0)
            tempEndtime = startTime + duration;  
            scisegs = []; 
            scisegs = [startTime tempEndtime]; 
        end
        scisize=size(scisegs);
        
        fprintf('    Found %d total science segments\n', scisize(1));
        
        dataarray = [];
        for i=1:scisize(1)
            if scisegs(i,2)>= startTime & scisegs(i,1)<= (startTime+duration)
                dataarray = [dataarray; scisegs(i,:)];    
            end
        end
        arraysize=size(dataarray);
    
        if strcmp(chanName(4:13), 'CAL-DELTAL')==1 | strcmp(chanName(4:13), 'SUS-ETMY_L')==1
            if arraysize(1) == 0
                fprintf('ERROR: No science segments in this range\nContinue checking for the next range...\n');
                data = 0;
                return;
            end
        end
        
        fprintf('Segments in this range before shortening\n');
        for i = 1:arraysize(1)
            fprintf('    Segment %d: %d - %d\n', i, dataarray(i,1), ...
                    dataarray(i,2));
        end
    
        % Remove first and last 10 folds of each segment
        dataarray(:,1) = dataarray(:,1) + 10 * foldSize;
        dataarray(:,2) = dataarray(:,2) - 20 * foldSize;
    
        % Check if any need to be removed (ie. total length is less
        % than 20 folds)
        emptySegments = [];
        for i = 1:arraysize(1)
            if dataarray(i,1) > dataarray(i,2)
                emptySegments = [emptySegments i];
            end
        end
        dataarray([emptySegments],:) = [];
        arraysize=size(dataarray);
        
        if arraysize(1) == 0
            fprintf('ERROR: No science segments in this range\nContinue checking for the next range...\n');
            data = 0;
            return;
        end
            
        fprintf('1 data array 1: %d, and data array 2: %d\n', dataarray(1, 1), dataarray(1, 2)); 
        arraysize=size(dataarray);
        fprintf('    Found %d science segments in this range\n\n', arraysize(1));
        if dataarray(1,1)<startTime
            fprintf('check 1');
            dataarray(dataarray==dataarray(1,1))=startTime;
        end
        
        fprintf('2 data array 1: %d, and data array 2: %d\n', dataarray(1, 1), dataarray(1, 2));
        
        if dataarray(arraysize(1),2)>(startTime+duration)
            fprintf('check 2');
            dataarray(dataarray==dataarray(arraysize(1),2))=(startTime+duration);
        end
        arraysize=size(dataarray);
        
        % Sync first segment to midnight
        if mod( dataarray(1,1) - startTime, foldSize)
            dataarray(1,1) = dataarray(1,1) + (foldSize - mod( dataarray(1,1) ...
                                                              - startTime, foldSize));
        end
    
        % sync accross the seg boundaries based on number of second fold
        dataarray(1, 2) = dataarray(1, 2) - mod( dataarray(1, 2) - dataarray(1, 1), foldSize); 
        sDataarray = size(dataarray); 
        
        fprintf('3 data array 1: %d, and data array 2: %d\n', dataarray(1, 1), dataarray(1, 2));
        
        for segCount = 2 : sDataarray(1)
            if mod( dataarray(segCount, 1) - dataarray(segCount - 1, 2), ...
                    foldSize)
                dataarray(segCount, 1) = dataarray(segCount, 1) + (foldSize - mod( dataarray(segCount, 1) - dataarray(segCount - 1, 2), foldSize));
            end
            dataarray(segCount, 2) = dataarray(segCount, 2) - mod(dataarray(segCount, 2) - dataarray(segCount, 1), foldSize); 
        end 
        
        fprintf('4 data array 1: %d, and data array 2: %d\n', dataarray(1, 1), dataarray(1, 2));
        
        
        if strcmp(chanName(4:13), 'CAL-DELTAL') ==0 & strcmp(chanName(4:13), 'SUS-ETMY_L')==0
            endTime = startTime + duration; 
            dataarray=[startTime, endTime]; 
        end
        fprintf('5 data array 1: %d, and data array 2: %d\n', dataarray(1, 1), dataarray(1, 2));
        
        % Check if any need to be removed (ie. total length is less
        % than 0)
        emptySegments = [];
        for i = 1:arraysize(1)
            if dataarray(i,1) > dataarray(i,2)
                emptySegments = [emptySegments i];
            end
        end
        dataarray([emptySegments],:) = [];
        arraysize=size(dataarray);
    
        if arraysize(1) == 0
            fprintf('ERROR: No science segments in this range\nContinue checking for the next range...\n');
            data = 0;
            return;
        end
    
        % Finished modifing segments, output result
        fprintf('6 data array 1: %d, and data array 2: %d\n', dataarray(1, 1), dataarray(1, 2));
        arraysize=size(dataarray);
        for i=1:arraysize(1)
            fprintf('    Segment %d: %d - %d\n', i, dataarray(i,1), dataarray(i,2));
        end
        leng=0;
        for i=1:arraysize(1)
            leng = leng + (dataarray(i,2)-dataarray(i,1));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % If the duration is less than the blocksize, read all of the data once but if not, loop through and add to the data list
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if duration<=blocksize & (startTime + duration)<=dataarray(1,2)
            
            fprintf('readget1..'); 
            for itry = 1:ntry
                try
                    fprintf('    Calling readFrames with currentTime=%d and duration=%d (try %d)...\n',dataarray(1,1), duration+startTime,itry);
                    [data, addent, flag]=readget(dataarray(1,1), duration+startTime, chanName);
                    break;
                catch err
                    disp(err);
                    fprintf(['    NDS2 ERROR on try %d for this ' ...
                             'block...\n'],itry);
                    if (itry == ntry)
                        error(['    NDS2 hard failure - aborting ' ...
                               'run\n']);
                    end
                end
            end
        else
            success = 0;
            for itry = 1:ntry
                try
                    
                    fprintf('readget 2...'); 
                    fprintf('    Calling readFrames with currentTime=%d and duration=%d (try %d)...\n',dataarray(1,1),min(dataarray(1,1)+blocksize, dataarray(1,2)),itry);
                    dataarray(1,1)
                    abs(min(dataarray(1,1)+blocksize, dataarray(1,2)))
                    [data, addent, flag] =readget(dataarray(1,1),abs(min(dataarray(1,1)+blocksize, dataarray(1,2))), chanName);
                    segLocList(segListPrt) = segLocList(segListPrt) + addent;
                    if flag > 0
                        segListPrt = segListPrt + 1;
                        segLocList = [segLocList 0];
                    end
                    success = 1;
                    break;
                catch err
                    disp(err)
                    disp(err.message)
                    fprintf('    NDS2 ERROR on try %d for this block...\n',itry);
                    if (itry == ntry)
                        error(['    NDS2 hard failure - aborting ' ...
                               'run\n']);
                    end
                end
            end
            if success == 1 
                % fprintf('    Returned from readFrames...\n');
    
    
            else
                fprintf('    Warning: giving up on this block\n')
                error('    Warning: giving up on this block\n')
                data.data = [];
            end
            success = 0;
            toDo=0;
            for i=1:arraysize(1)
                toDo=toDo+(dataarray(i,2)-dataarray(i,1));
            end
            toDo=toDo-min(blocksize, dataarray(1,2)-dataarray(1,1));
            if blocksize >= (dataarray(1,2)-dataarray(1,1))
                dataarray(1,:)=[]; 
                if size(dataarray, 1) == 0 %In case when there is only one segment in the range      
                    datasize=size(data);
                    fprintf('    Exiting readsciencedata...\n');
                    return;
                end        
                currentTime=dataarray(1,1);
            else
                currentTime=dataarray(1,1)+blocksize;
            end
            arraysize = size(dataarray);
            
            while(arraysize(1) > 0)
                success = 0;
                for itry = 1:ntry
                    try
                        fprintf('    Calling readFrames with currentTime=%d and duration=%d (try %d)...\n',currentTime,min(currentTime+blocksize, dataarray(1,2)),itry);             
                        fprintf('readget 3...'); 
                        [tempData, addent,  flag] = readget(currentTime, abs(min(currentTime+blocksize, dataarray(1,2))), chanName); 
                        tempDataSize = size(tempData);
                        fprintf('read %d new data', tempDataSize(1)); 
                        data = [data;tempData];
                        
                        segLocList(segListPrt) = segLocList(segListPrt) + addent;
                        if flag > 0
                            segListPrt = segListPrt + 1;
                            segLocList = [segLocList 0];
                        end
                        success = 1;
                        
                        datasize=size(data);
                        fprintf('new data size is %d', datasize(1));
                        ratio = (datasize(1)/Fs)/leng; 
                        fprintf('    Ratio completed: %d\n',ratio);
                        break;
                    catch err
                        disp(err);
                        fprintf('    NDS2 ERROR on try %d for this block...\n',itry);
                        if (itry == ntry)
                            error('    NDS2 hard failure - aborting run\n');
                        end
                    end
                end
                toDo=toDo-min(blocksize, dataarray(1,2)-currentTime);
                if blocksize >= (dataarray(1,2)-currentTime) & ( arraysize(1) > 1 )
                    dataarray(1,:)=[];
                    currentTime=dataarray(1,1);
                elseif arraysize(1) == 1 & blocksize >= (dataarray(1,2)-currentTime)
                    dataarray(1,:)=[];
                else
                    currentTime=currentTime+blocksize;
                end
                arraysize=size(dataarray, 1);
                if (success == 0)
                    error('    NDS2 hard failure - aborting run\n');
                end
            end
            %fprintf('    Exited while loop...\n');
            toDo = [];
            currentTime = [];
        end
        datasize = size(data);
        
        
        fprintf('new    Exiting readsciencedata...\n');
    end