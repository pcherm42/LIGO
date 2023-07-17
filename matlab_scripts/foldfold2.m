function foldfold2(ifo, location, foldS, channel, NFFT, currentDir, months_file)%, glitch_file)
    Version = version
    
    Memory = java.lang.Runtime.getRuntime.maxMemory
    
    foldS = str2num(foldS);
    npart = 8;
    months_file = sprintf('%s', months_file);
    months_table = readtable(months_file)
    months_month = char(table2array(months_table(:,1)));
    months_year = num2str(table2array(months_table(:,3)));
    months_ndays = table2array(months_table(:,2));
    
    %addpath(pwd)
    dirname = sprintf('%s/files/matfiles/%s/%s', currentDir,channel,location);
    currentDir = sprintf('%s/files/html/', currentDir);
    fprintf('Running foldfold in directory %s\n', cd(currentDir));
    fprintf('Moving to directory %s\n', pwd);
    
    filesDir = '..';
    
    fprintf('Dirname = %s\n', dirname);
    
    labelsummary = sprintf('All of %s',ifo);
    fnamepeakssummary = sprintf('%s/peakfiles/%s_peaks.txt',filesDir,ifo);
    fnamematsummary = sprintf('%s/matfiles/%s/%s/%s_sum.mat',filesDir,channel,location,ifo);
    fnamepdfsummary = sprintf('%s/pdf/%s_sum.pdf',filesDir,ifo);
    fnamepngsummary = sprintf('%s/png/%s_sum.png',filesDir,ifo);
    fnamespectrasummary = sprintf('%s/spectra/%s_spectra.txt',filesDir,ifo);
    
    NFFT = str2num(NFFT);
    
    Fs = NFFT;
    
    minmonth = 1;
    maxmonth = length(months_ndays)
    
    fnameindex = sprintf('index_%s.html',ifo);
    fidindex = fopen(fnameindex,'w');
    fprintf(fidindex,['<center><h1>Folded plots for %s data</h1>\n<table width="60%%" ' ...
                      'border=1 cellpadding=5>'],channel);
    fprintf(fidindex,['<tr><td><center>Grand summary of folded %s data ' ...
                      '<br><a href="%s">Link to spectral peaks list</' ...
                      'a><br><a href="%s">Link to .mat summary file</' ...
                      'a><br><a href="%s"><img width="100%%" src="%s"></a>\n<br><center><a href="%s"><br>full size post process plot</a></center>'],channel,fnamepeakssummary,fnamematsummary,fnamepdfsummary,fnamepngsummary, [fnamepdfsummary(1:end-4) 'post_process.pdf']);

    chan_loc = strjoin([string(channel),string(location)],", ");
    
    for month = minmonth:maxmonth

        % Find Monthly Summary Files
    
        % Find files for this month
        month_name = strtrim(months_month(month,:));
        year_name = strtrim(months_year(month,:));
        fnamepattern = sprintf('%s/%s-*-%s_folded_veto-*_%dsec.mat', ...
                               dirname,month_name,year_name, foldS);
        dirlist = dir(fnamepattern);
        fprintf('Found %d files matching the pattern: %s\n', ...
                length(dirlist),fnamepattern);
        if length(dirlist) == 0
            fprintf('Moving on to next month\n');
            if month == minmonth
                minmonth = minmonth + 1;
            end
            continue;
        end
    
        % Create report files for the month
        fnamehtmlmonth = sprintf('./%s%s_%s.html',ifo,month_name,year_name);
        fnamematmonth = sprintf('%s/%s%s_%s_folded.mat',dirname, ifo,month_name,year_name);
        fnamepeaksmonth = sprintf('%s/peakfiles/%s%s_%s_peaks.txt',filesDir,ifo,month_name,year_name);
        fnamespectramonth = sprintf('%s/spectra/%s%s_%s_spectra.txt', ...
                                  filesDir,ifo,month_name,year_name);
        fprintf(fidindex,'<tr><td><center><a href="%s">Day-by-day plots for %s %s</a><br><a href="%s">Link to spectral peaks list</a><br>\n<a href="%s">Link to .mat summary file</a>',fnamehtmlmonth,month_name,year_name,fnamepeaksmonth,fnamematmonth);
        fidhtmlmonth = fopen(fnamehtmlmonth,'w');
        fprintf(fidhtmlmonth,'<center><h1>Folded plots for %s %s </h1>\n<table>\n',month_name,year_name);
        labelmonth = sprintf('%s %s %s',ifo,month_name,year_name);
        fnamepdfmonth = sprintf('%s/pdf/%s_%s_%s_sum.pdf',filesDir,ifo,month_name,year_name);
        fnamepngmonth = sprintf('%s/png/%s_%s_%s_sum.png',filesDir,ifo,month_name,year_name);
        fprintf(fidindex,'<br><a href="%s"><img width="100%%" src="%s"></a>\n',fnamepdfmonth,fnamepngmonth);
        fprintf(fidhtmlmonth,'<hr><a href="%s"><img width="50%%" src="%s"></a><br>Sum of averages for %s %s %s\n<br><center><a href="%s"><br>full size post process</a></center>',fnamepdfmonth,fnamepngmonth,ifo,month_name,year_name, [fnamepdfmonth(1:end-4) 'post_process.pdf']);
        fprintf(fidhtmlmonth,'<table border=1 cellpadding=5>');
    
        % Analyze days in month
        fprintf('Looping over days in %s %s\n',month_name,year_name);
        ndayspercol = 5;
        nday = 0;
        colwidth = 100/ndayspercol;

        strmonth_name = convertCharsToStrings(month_name); %ADDED 5/26/2020 to include dates to plots
        stryear_name = convertCharsToStrings(year_name); %ADDED 5/26/2020 to include dates to plots
        month_year = join([strmonth_name,stryear_name],", "); %ADDED 5/26/2020 to include dates to plots
        for day = 1:length(dirlist)
            fnameday = strtrim(dirlist(day).name);
            daystring = extractBetween(convertCharsToStrings(fnameday),"-","-20"); %ADDED 5/26/2020 to include dates to plots
            day_month_year = join([daystring,month_year]); %ADDED 5/26/2020 to include dates to plots
            chan_loc_day_month_year = join([channel,location,day_month_year],", "); %ADDED 5/26/2020 to include dates to plots
            fnamedayfull = sprintf('%s/%s',dirname,fnameday);
    
            % Compute statistics of the day
            thisday = load(fnamedayfull);
            nsec = thisday.nkeepfold;
            if (nsec>0)
                fprintf('---   Processing file %s - secondsanalyzed = %d\n',fnameday,nsec);
                fprintf('fnamedayfull = %s\n', fnamedayfull);
                nday = nday + 1;
                if (mod(nday,ndayspercol)==1)
                    fprintf(fidhtmlmonth,'<tr>\n');
                end
                thisavg = thisday.avgData;
                thisavgHP = thisday.avgDataHP;
                if (nday==1)
                    sumsec = nsec;
                    sumavg = nsec*thisavg;
                    sumavgHP = nsec*thisavgHP;
                else
                    sumsec = sumsec + nsec;
                    sumavg = sumavg + nsec*thisavg;
                    sumavgHP = sumavgHP + nsec*thisavgHP;
                end
                labelday = sprintf('%s',fnameday);
    
                % Save day information
                fnamepeaksday = sprintf('%s/peakfiles/%s%s_peaks.txt',filesDir,ifo,fnameday);
                fnamespectraday = sprintf('%s/spectra/%s%s_spectra.txt',filesDir,ifo,fnameday);
                fnamepdfday = sprintf('%s/pdf/%s%s.pdf',filesDir,ifo,fnameday);
                fnamepngday = sprintf('%s/png/%s%s.png',filesDir,ifo,fnameday);
                [status ycleaned] = makeplots(thisday.fract, ...
                                              thisday.avgData,Fs,labelday,fnamepeaksday,fnamepdfday,fnamepngday,fnamespectraday, foldS, chan_loc_day_month_year, true);
    
                % Make plots for partial folds
                fnamehtmlday = sprintf('%s/html/%s%s.html',filesDir, ...
                                       ifo,fnameday);
                day_num = strsplit(fnameday, '-');
                day_num = char(day_num(2));
    
                fprintf(fidhtmlmonth, ['<td width=%d%%><center><a href="%s">Link to spectral peak list</a><br><a href="%s"><img width=100%% src="%s"></a><br>%s %s\n<a href=%s> <br>full size post process plot</a>'], colwidth, fnamepeaksday, fnamepdfday, fnamepngday,ifo, ...
                        fnameday, [fnamepdfday(1:end - 4) 'post_process.pdf']);
    
    
                fidhtmlday = fopen(fnamehtmlday,'w');
                fnamepatternPartial = sprintf('%s/%s-%s-%s_folded_veto_PartialFold*_%dsec.mat',dirname,month_name,day_num,year_name, foldS);
                dirlistPartial = dir(fnamepatternPartial);
    
                if length(dirlistPartial) > 0
                    fprintf(fidhtmlmonth, [' <a href=%s> <br> Partial ' ...
                                        'Plots </a>'], fnamehtmlday);
                    fprintf(fidhtmlday,['<center><h1>Partial Folded plots ' ...
                                        'for %s %s, %s </h1>\n<table ' ...
                                        'border=1 cellpadding=5>\n'], ...
                                        month_name, day_num, year_name);
                end
    
                npart = 0;
                npartspercol = 4;
                colwidthPartial = 100/npartspercol;
                for partial = 1:length(dirlistPartial)
                    fnamepart = strtrim(dirlistPartial(partial).name);
                    fnamepartfull = sprintf('%s/%s',dirname, ...
                                                  fnamepart);
    
                    fprintf('---   Processing file %s ---\n',fnamepart);
                    fprintf('fnamepartfull = %s\n', fnamepartfull);
    
                    thispart = load(fnamepartfull);
                    nsecPartial = thispart.nkeepfold;
    
                    npart = npart + 1;
                    if (mod(npart,npartspercol)==1)
                        fprintf(fidhtmlday,'<tr>\n');
                    end
                    thisavgPartial = thispart.avgData;
                    thisavgHPPartial = thispart.avgDataHP;
                    if (npart==1)
                        sumsecPartial = nsecPartial;
                        sumavgPartial = nsecPartial*thisavgPartial;
                        sumavgHPPartial = nsecPartial*thisavgHPPartial;
                    else
                        sumsecPartial = sumsecPartial + nsecPartial;
                        sumavgPartial = sumavgPartial + nsecPartial*thisavgPartial;
                        sumavgHPPartial = sumavgHPPartial + nsecPartial*thisavgHPPartial;
                    end
                    labelpart = sprintf('%s',fnamepart);
                    fnamepeakspart = sprintf('%s/peakfiles/%s%s_peaks.txt', ...
                                            filesDir,ifo,fnamepart);
                    fnamespectrapart = sprintf('%s/spectra/%s%s_spectra.txt', ...
                                               filesDir,ifo,fnamepart);
                    fnamepdfpart = sprintf('%s/pdf/%s%s.pdf',filesDir,ifo, ...
                                          fnamepart);
                    fnamepngpart = sprintf('%s/png/%s%s.png',filesDir,ifo, ...
                                          fnamepart);
    
                    [status ycleaned] = makeplots(thispart.fract, ...
                                                  thispart.avgData,Fs, ...
                                                  labelpart,fnamepeakspart, ...
                                                  fnamepdfpart,fnamepngpart, ...
                                                  fnamespectrapart, foldS, chan_loc_day_month_year, false);
                    fprintf(fidhtmlday, ['<td width=%d%%><center><br><a href="%s"><img  ' ...
                                        'width=100%% src="%s"></a><br>%s ' ...
                                        '%s\n<a href=%s> <br>full size post process plot</a>'], colwidthPartial, fnamepdfpart, fnamepngpart,ifo, fnamepart, [fnamepdfpart(1:end - 4) 'post_process.pdf']);
                end
            else
                fprintf('   *Skipping* file %s - secondsanalyzed = %d\n',fnameday,nsec);
            end
            fprintf('\n')
        end
        fprintf('\n---   Finished folding days - Folding month now\n')
        sumavg = sumavg / sumsec;
        chan_loc_month_year = join([channel,location,month_year],", "); %ADDED 5/26/2020 to include dates to plots
        [status ycleaned] = makeplots(thisday.fract,sumavg,Fs, ...
                                      labelmonth,fnamepeaksmonth,fnamepdfmonth,fnamepngmonth,fnamespectramonth, foldS, chan_loc_month_year, true);
        sumavgHP = sumavgHP / sumsec;
        if (month==minmonth)
            sumsumsec = sumsec;
            sumsumavg = sumsec*sumavg;
            sumsumavgHP = sumsec*sumavgHP;
        else
            sumsumsec = sumsumsec + sumsec;
            sumsumavg = sumsumavg + sumsec*sumavg;
            sumsumavgHP = sumsumavgHP + sumsec*sumavgHP;
        end
    
        fprintf(fidhtmlmonth,'</table></center>');
        fclose(fidhtmlmonth);
        fract = thisday.fract;
        save(fnamematmonth,'fract','sumavg', 'sumsec', 'sumavgHP', ...
             'ycleaned');
        fprintf('Saved month file to %s\n\n', fnamematmonth);
    end
    
    sumsumavg = sumsumavg / sumsumsec;
    sumsumavgHP = sumsumavgHP / sumsumsec;
    foldS;
    [status ycleaned] = makeplots(thisday.fract,sumsumavg,Fs, ...
                                  labelsummary,fnamepeakssummary,fnamepdfsummary,fnamepngsummary,fnamespectrasummary, foldS, chan_loc, true);
    save(fnamematsummary,'fract','sumsumavg', 'sumsumsec', 'sumsumavgHP', 'ycleaned');
    
    
    fprintf('\nDone!\n')