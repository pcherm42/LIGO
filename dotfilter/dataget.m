function out = dataget(primlocation, primfoldS, primchannel, auxchannel, auxlocation, currentDir, months_file, channeltags)

    auxfoldS = primfoldS;
    bandpassquerey = true;


    

    
    primfoldS = str2double(primfoldS);
    months_file = sprintf('%s', months_file);
    months_table = readtable(months_file);
    months_month = char(table2array(months_table(:,1)));
    months_year = num2str(table2array(months_table(:,3)));
    months_ndays = table2array(months_table(:,2));
    
    primdirname = sprintf('%s/files/matfiles/%s/%s', currentDir,primchannel,primlocation);
    auxdirname = sprintf('%s/files/matfiles/%s/%s', currentDir,auxchannel,auxlocation);
    
    minmonth = 1;
    maxmonth = length(months_ndays);
    

    dates = zeros(366,1);
    counter = 1;
    Matrix = [];
    
    
    for month = minmonth:maxmonth
    
        % Find files for this month
        month_name = strtrim(months_month(month,:));
        year_name = strtrim(months_year(month,:));
        primfnamepattern = sprintf('%s/%s-*-%s_folded_veto-5.000000_%dsec.mat', ...
                               primdirname,month_name,year_name, primfoldS);
        primdirlist = dir(primfnamepattern); %'CAL-DELTAL_EXTERNAL_DQ'

        if length(primdirlist) == 0
            %fprintf('Moving on to next month\n');
            if month == minmonth
                minmonth = minmonth + 1;
            end
            continue;
        end

        
    
        % Analyze days in month
        for day = 1:length(primdirlist)

            primnameday = strtrim(primdirlist(day).name);
            primnamedayfull = sprintf('%s/%s',primdirname,primnameday);
            
            dayofmonthcell = extractBetween(primnamedayfull,join([month_name,'-']),'-');
            dayofmonth = dayofmonthcell{1};

            primfilname = sprintf('%s/%s-%s-%s_folded_veto-5.000000_%dsec.mat', ...
                               primdirname,month_name,dayofmonth,year_name, primfoldS); %September-30-2019_folded_veto-5.000000_8sec.mat

            primlist = dir(primfilname);
            auxfilname = sprintf('%s/%s-%s-%s_folded_veto-5.000000_%ssec.mat', ...
                               auxdirname,month_name,dayofmonth,year_name, auxfoldS);

            auxlist = dir(auxfilname);

            lengths = 1:length(channeltags);
            cnt = 1;
            while cnt < length(channeltags) + 1;
                tstdirname = sprintf('%s/files/matfiles/%s/%s', currentDir,channeltags{cnt}{1},auxlocation);
                tstfilname = sprintf('%s/%s-%s-%s_folded_veto-5.000000_%ssec.mat', ...
                               tstdirname,month_name,dayofmonth,year_name, auxfoldS);
                tstlist = dir(tstfilname);
                lengths(cnt) = length(tstlist);
                cnt = cnt + 1;
            end

            straindirname = sprintf('%s/files/matfiles/%s/%s', currentDir,'CAL-DELTAL_EXTERNAL_DQ', primlocation);
            strainfilname = sprintf('%s/%s-%s-%s_folded_veto-5.000000_%ssec.mat', ...
                               straindirname,month_name,dayofmonth,year_name, auxfoldS);
            strainlist = dir(strainfilname);
            


            

            if min(lengths) > 0 && length(strainlist) > 0
                fprintf('Getting file %s \n', primfilname)

                DateString = sprintf('%s-%s-%s', dayofmonth, month_name, year_name);
                dates(counter) = datenum(DateString);
                file1 = load(char(primfilname));
                day_data = file1.('avgData');
                % bandpass
                if bandpassquerey == true
                    NFFT = length(day_data);
                    Fs = NFFT/8;
                    Y = fft(day_data, NFFT);
                    L = length(Y);

                    fhigh = 50; flow = 10; 
                    nbinmax = round(fhigh*length(Y)/Fs + 1); 
                    nbinmin = round(flow*length(Y)/Fs + 1); 
                    bandY = zeros(size(Y)); 
                    bandY(nbinmin:nbinmax) = Y(nbinmin:nbinmax); 
                    bandY(end - nbinmax + 2: end - nbinmin + 2) = Y(end - nbinmax + 2 : end - nbinmin + 2); 
                    bandY(1) = 0; 
                    bandY(L/2 + 1) = 0.; 
                    day_data_filt = ifft(bandY);
                end

                Matrix = [Matrix, day_data_filt];
                times = file1.('fract');

                counter = counter + 1;
                
            else
            end
        end
    end
    out = {Matrix, dates, times};
    
end

%Include ifo in the filename dotproduct_ifo_Chan1-Chan2.mat
%outputs
%save Data arrays
%EV for Strain dotted with random channel
%saving a .fig file rather than a .png