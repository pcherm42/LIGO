function trend = foldingAnalysis3(data, foldSize, Fs, startTime, chanName, segsFileName, matfilePath, partialFold)
    %   function trend = foldingAnalysis3(data, foldSize, Fs, startTime, duration, count, chanName, segsFileName)
    % Core function for carrying out data folding, data vetoing and 
    % computation of statistics
    % foldSize is the number of seconds that should be in the final folded
    % sample. The size of data must be divisible by foldSize.
    % startTime is used in creating an output file name
    % -------------------------------------------------------------------------------
        fprintf('    Fs=%d\n',Fs)
        fprintf('    Entering FoldingAnalysis3  with partialFold=%d, foldSize=%d\n',partialFold,foldSize);
        fprintf('    Length of data = %d\n', length(data));
        sigma_cut = 5.0;
    
        % Check for partial fold
        if partialFold == 0;
            fprintf('     Folding full data');
            st = Fs/2 + 1;
            et = length(data) - Fs/2;
            fprintf('     Truncating half seconds...\n');
            partialFoldName = sprintf('');
        else
            fprintf('    Folding partial data');
            st = 1;
            et = length(data);
            partialFoldName = sprintf('_PartialFold_%d',partialFold);
        end
            
        % Number of samples in one fold of the data
        dataPerSec = Fs;
        sfoldSize = foldSize * dataPerSec;
        dataLen = et - st + 1;
        
        % now determine the desired indices of data: st ~ et
        fprintf('    st is %d, et is %d, dataLen is %d\n', st, et, dataLen);
        fprintf('    sfoldSize=%d\n',sfoldSize)
        % Check self consistency of data size
        if mod(dataLen,sfoldSize)~=0
            fprintf('    Warning: number of data points not divisible by foldSize*%d, truncating...\n', Fs)
            fprintf('    the value of foldsize = %d, and the value of sfoldsize = %d\n', foldSize, sfoldSize);
            modu=mod(dataLen,sfoldSize);
            fprintf('    the value of modu = %d, length of data = %d\n', modu, dataLen);
            et = et - modu;
            datalen = et - st + 1;
        end
        fprintf('    Last wanted index is %d\n', et);
            
        % Calculate mean and standard deviation over entire day for
        % use in vetoing large glitches
        fprintf('    Computing global statistics...\n');
        average = mean(data( st : et ) );
        standarddev = std(data( st : et ) );
        fprintf('    -> Global mean = %e, stand dev = %d\n',average,standarddev);
        %Initialize variables used in data vetoing
        fprintf('    Making buffer for number of folds kept and vetoed...\n');
        nkeepfold = 0;
        nvetofold = 0;
        fprintf('    Vetoing intervals with a data value > %e sigma from mean for that day...\n',sigma_cut );
        
        % define iir filter 
        cutoff = 500/(Fs/2); 
        f = [0 cutoff cutoff 1]; 
        cutoff2 = cutoff*1.2;
        f = [0 cutoff cutoff2 1]; 
        m = [ 0 0 1 1 ]; 
    %    n = 50; 
        n = 5; 
        fprintf('    Calling yulewalk with n=%d, f=[%d %d %d %d], m=[%d %d %d %d]\n',n,f,m);
        [b, a] = yulewalk(n, f, m); 
        
        % now update the et (because some data are removed)
        data_iir = filtfilt(b, a, data); 
        average_iir = mean(data_iir); 
        fprintf('    The fold size is %d...\n\n', foldSize);
        sfoldSize = foldSize*Fs;
        dataLen = et - st + 1;
        fprintf('    Looping through analysis with sfoldSize=%d, foldsize=%d\n',sfoldSize,foldSize);
        numOfFolds = floor(dataLen/sfoldSize); 
        fprintf('    Number of folds = %d\n', numOfFolds);
        
        for km = 1 : (numOfFolds-1)
            k = numOfFolds + 1 - km;
            foldLeft =  st + (k-1) * sfoldSize;
            fprintf('foldLeft = %d\n',foldLeft) 
            foldRight = st + k * sfoldSize - 1;
            fprintf('foldRight = %d\n',foldRight)
            %if (foldRight > length(data))
             %   fprintf('foldRight exceeds length of data\n')
              %  foldRight = foldLeft + 1
            %end  
            %fprintf('new foldRight = %d\n',foldRight)
            maxdev = max(abs(data_iir(foldLeft : foldRight, 1 ) - average_iir ));
            if (maxdev > sigma_cut*standarddev)
                data_iir(foldLeft : foldRight) = [];
                data( foldLeft : foldRight) = [];
                fprintf('    Vetoing interval [%d-%d]\n',foldLeft,foldRight);
              %  if (foldRight > length(data))
               %      fprintf('foldRight exceeds length of data\n')
                %     foldRight = length(data)
               % end  
               % fprintf('new foldRight = %d\n',foldRight)
                % now windowing the vetoed region
                Xl = 1:Fs/2;
                Xl = Xl / Fs/2;
                Xl = transpose(Xl);
                prt = foldLeft - 1;
                lprt = prt - Fs/2 + 1;
                rprt = prt + Fs/2;
                fprintf('    Length of data %d, prt %d, lprt %d, and rprt %d \n', length(data), prt, lprt, rprt);
              %  if (rprt > length(data))
             %        fprintf('rprt exceeds length of data')
            %        rprt = length(data)
                %end
                if (rprt > length(data))
                     YleftOld = data(lprt : prt);
                     YrightOld = YleftOld .* 0
                else
                     YleftOld = data(lprt : prt);
                     YrightOld = data(prt + 1 : rprt);
                end
                avg = ( mean(YleftOld) + mean(YrightOld) ) / 2;
                Yright = YrightOld .* (Xl .* Xl) + avg;
                Yleft = YleftOld .*( Xl -1 ) .* (Xl - 1 ) + avg;
                Y = [Yleft; Yright];
                data(lprt : rprt) = Y;
                nvetofold = nvetofold + 1;
            else
                nkeepfold = nkeepfold + 1;
            end
        end
    
        fprintf('    Found nkeepfold=%d, nvetofold=%d\n',nkeepfold,nvetofold); 
        numOfFolds = nkeepfold;
        et = st + numOfFolds * sfoldSize - 1;
        dataLen = et - st + 1;
        fprintf('    size=%d / sfoldSize=%d is numOfFolds=%d \n',dataLen,sfoldSize,numOfFolds);
        % Initialize variables used in averaging
        avgData = zeros(sfoldSize,1);
        stdData = zeros(sfoldSize,1);
        avgerrData = zeros(sfoldSize,1);
        
        fprintf('    Computing statistics\n');
        fprintf('    sfoldSize : %d\n    length: %d\n', sfoldSize, dataLen);
        
            
        fprintf('    Debugging Info: i = %d, sfoldSize = %d, st = %d, et = %d\n', i, sfoldSize, st, et); 
        for countVar = 1 : sfoldSize 
            avgData( countVar ) = mean( data( st + countVar - 1: sfoldSize : et));
            stdData( countVar ) = std( data( st + countVar - 1: sfoldSize : et));
            avgerrData( countVar ) = stdData( countVar ) / sqrt( nkeepfold );
        end
        aa = mean(avgData); 
        fprintf('    Avg of avgData %d, \n    avg %d\n', aa, average); 
        % Define ble for later time-domain plotting
        fract = (0:sfoldSize-1)/sfoldSize;
        
        [date,irrelevant]=evalc('system(horzcat(''tconvert -f %B-%d-%Y '',num2str(startTime)))');
        if chanName(1) == 'H'
            obr_name = 'H1';
        else
            obr_name = 'L1';
        end
        
        fract = ( 0 : sfoldSize - 1 ) / sfoldSize;
        freq = Fs / 2 * linspace( 0, 1, sfoldSize / 2 + 1 );
        PSD = fft( avgData, sfoldSize) / sfoldSize;
        bar = 1;
        [z, p, k] = ellip(6, 3, 50, bar / (Fs/2), 'high');
        [sos, g] = zp2sos( z , p , k );
        Hd = dfilt.df2tsos( sos , g );
        avgDataHP = filter( Hd, avgData );
        avgerrData= stdData / sqrt( nkeepfold );
        
        name = sprintf('%s/%s_folded_veto%s-%f_%dsec.mat', matfilePath, ...
                       strtrim(date), partialFoldName, sigma_cut,foldSize);
        fprintf(name);

        if max(avgData) == 0 && min(avgData) == 0
            error(sprintf('avgData is all zeros. Will not save file.'))
        else
            save (name, 'fract','avgData','avgDataHP','stdData','avgerrData','numOfFolds','nkeepfold','nvetofold','freq','PSD','sfoldSize');
            fprintf('    Saved %s file\n    Exiting from foldingAnalysis\n',name);
        end

        trend = true;
        fprintf('    Exiting foldingAnalysis\n')

    end