function yearcompare(auxifo, auxlocation, auxfoldS, auxchannel, auxNFFT, primifo, primlocation, primfoldS, primchannel, primNFFT, currentDir, months_file)%, glitch_file)
    
    auxfoldS = str2double(auxfoldS);
    primfoldS = str2double(primfoldS);
    months_file = sprintf('%s', months_file);
    months_table = readtable(months_file)
    months_month = char(table2array(months_table(:,1)));
    months_year = num2str(table2array(months_table(:,3)));
    months_ndays = table2array(months_table(:,2));
    
    auxdirname = sprintf('%s/files/matfiles/%s/%s', currentDir,auxchannel,auxlocation);
    primdirname = sprintf('%s/files/matfiles/%s/%s', currentDir,primchannel,primlocation);
    
    auxNFFT = str2double(auxNFFT);
    primNFFT = str2double(primNFFT);
    
    auxFs = auxNFFT;
    primFs = primNFFT;
    
    minmonth = 1;
    maxmonth = length(months_ndays);
    

    data = zeros(366,1);
    dates = zeros(366,1);
    counter = 1;

    
    
    for month = minmonth:maxmonth

    
        % Find files for this month
        month_name = strtrim(months_month(month,:));
        year_name = strtrim(months_year(month,:));
        auxfnamepattern = sprintf('%s/%s-*-%s_folded_veto-5.000000_%dsec.mat', ...
                               auxdirname,month_name,year_name, auxfoldS);
        primfnamepattern = sprintf('%s/%s-*-%s_folded_veto-5.000000_%dsec.mat', ...
                               primdirname,month_name,year_name, primfoldS);
        auxdirlist = dir(auxfnamepattern);
        primdirlist = dir(primfnamepattern);

        if length(auxdirlist) == 0
            fprintf('Moving on to next month\n');
            if month == minmonth
                minmonth = minmonth + 1;
            end
            continue;
        end

        
    
        % Analyze days in month
        for day = 1:min(length(primdirlist),length(auxdirlist))
            
        
            auxfnameday = strtrim(auxdirlist(day).name);


            auxfnamedayfull = sprintf('%s/%s',auxdirname,auxfnameday);

            dayofmonthcell = extractBetween(auxfnamedayfull,join([month_name,'-']),'-');
            dayofmonth = dayofmonthcell{1};

            primfilname = sprintf('%s/%s-%s-%s_folded_veto-5.000000_%dsec.mat', ...
                               primdirname,month_name,dayofmonth,year_name, primfoldS); %September-30-2019_folded_veto-5.000000_8sec.mat

            primlist = dir(primfilname);

            auxfilname = sprintf('%s/%s-%s-%s_folded_veto-5.000000_%dsec.mat', ...
                               auxdirname,month_name,dayofmonth,year_name, auxfoldS);

            auxlist = dir(auxfilname);

            


            if length(primlist) > 0 && length(auxlist) > 0

                dotproduct = matcompare(char(primfilname), 'avgData', primFs, char(auxfilname), 'avgData', auxFs); %avgData vs suumsumavg name error occurs here

                data(counter) = dotproduct;

                DateString = sprintf('%s-%s-%s', dayofmonth, month_name, year_name)
                dates(counter) = datenum(DateString);


                counter = counter + 1;
                

            else

            end

            

            
                               

    
            % Compute statistics of the day
            %This is where your code goes!!


            



            
                
    
        end
        
    end

    counter = counter -1;



    TrimmedData = data(1:counter);
    TrimmedDates = dates(1:counter);





    reset(gca)
    reset(gcf)
    figure
    plot(datetime(TrimmedDates,'ConvertFrom', 'datenum'), TrimmedData)
    %plot(TrimmedData)
    plottitle = sprintf('Dot Product of %s:%s and %s:%s', primlocation, primchannel, auxlocation, auxchannel);
    title(plottitle,'Interpreter','none');

    outputfilename = sprintf('YearCompare_%s_%s_%s.fig', auxlocation, primchannel, auxchannel);
    xlabel('Dates')
    ylabel('Dot Product')
    %xtickformat('MM-dd-yyyy')

    fig = gcf;



    %saveas(gcf,outputfilename)
    %savefig(fig,outputfilename)
    savefig(outputfilename)

    %After this line, I was trying to get it to save .png and .fig
    outputfilename = sprintf('YearCompare_%s_%s_%s.png', auxlocation, primchannel, auxchannel);
    saveas(gcf, outputfilename)
    %End of trying to get it to save .png in addtion to .fig

    
    
    fprintf('\nDone!\n')
    quit(0,"force")
    
end

%Include ifo in the filename dotproduct_ifo_Chan1-Chan2.mat
%outputs
%save Data arrays
%EV for Strain dotted with random channel
%saving a .fig file rather than a .png
%START WITH A FULL ONE AND TAKE THE HOLES OUT... NOT THE OTHER WAY AROUND!!!