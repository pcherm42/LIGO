function yeardotshare(auxifo, auxlocation, auxfoldS, auxchannel, auxNFFT, primifo, primlocation, primfoldS, primchannel, primNFFT, currentDir, months_file)%, glitch_file)
    
    dotweighquerey = false;
    bandpassquerey = true;
    
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
    Dotshare_matrix = [];
    

    
    
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

                dotproduct = matcompare(char(primfilname), 'avgData', primFs, char(auxfilname), 'avgData', auxFs, bandpassquerey); %avgData vs suumsumavg name error occurs here

                data(counter) = dotproduct;

                DateString = sprintf('%s-%s-%s', dayofmonth, month_name, year_name)
                dates(counter) = datenum(DateString);

                cellarray = dotshare(char(primfilname), 'avgData', primFs, char(auxfilname), 'avgData', auxFs, bandpassquerey);
                day_dotshare = cellarray{1};
                

                Dotshare_matrix = [Dotshare_matrix, day_dotshare];



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
    TrimmedDates = string(datetime(TrimmedDates,'ConvertFrom', 'datenum'));
    times = 8*cellarray{2};
    %Datestrings = datetime(TrimmedDates,'ConvertFrom', 'datenum');
    reso = size(Dotshare_matrix,2);
    xs = linspace(0,8,reso);





    reset(gca)
    reset(gcf)
    figure
    %heatmap(xs,datetime(TrimmedDates,'ConvertFrom', 'datenum'), )
    %heatmap(Dotshare_matrix)


    %skip=2;
    %SqSize = 100;
    %columnselection = 234;
    %DWN = DWN(:,columnselection);
    %DWN = Dotshare_matrix(end-SqSize+1:end, 1:SqSize); %takes a square
    %DWN = Dotshare_matrix(1:skip:end,:); %skips samples
    

    sz1 = size(Dotshare_matrix,1);
    sz2 = size(Dotshare_matrix,2);
    ylabels = nan(sz1,1);
    xlabels = num2cell(nan(sz2,1));


    Datefreq = 15; %days
    timefreq = sz1/16;

    cnt = 1;

    %make y labels
    while cnt < sz1 + 1

        if mod(cnt,timefreq) == 0
            ylabels(cnt) = floor(2*times(cnt))/2;
        end

        cnt = cnt + 1;

    end

    cnt2 = 1;

    %make x labels
    while cnt2 < sz2 + 1

        if mod(cnt2,Datefreq) == 0
            xlabels{cnt2} = TrimmedDates(cnt2);%string(Datestrings(cnt2));
        end

        cnt2 = cnt2 + 1;
        
    end


    if dotweighquerey == true
        normaldotprod = abs(TrimmedData)/max(abs(TrimmedData));
        counter = 1;
        while counter < sz2 + 1
            Dotshare_matrix(:,counter) = normaldotprod(counter)*Dotshare_matrix(:,counter);
            counter = counter + 1;
        end
    end





         





    plottitle = sprintf('Dotshare %s:%s and %s:%s', primlocation, primchannel, auxlocation, auxchannel);
    plottitle = strrep(plottitle, '_', ' ');

    %xamount = numel(xlabels);
    %yamount = numel(ylabels);
    %dotsharesize = size(Dotshare_matrix);


    


    tiledlayout(4,1)

    nexttile([3,1])

    h = heatmap(Dotshare_matrix)
    h.FontSize = 6;
    h.Colormap = flipud(gray);
    h.Title = plottitle;
    h.ColorbarVisible = 'off';
    h.GridVisible = 'off';
    h.XDisplayLabels = xlabels;
    h.YDisplayLabels = ylabels;
    %h.XLabel = 'Date';
    h.YLabel = 'Seconds';

    nexttile


    j = heatmap(abs(transpose(TrimmedData)))
    j.Colormap = flipud(gray);
    j.FontSize = 6;
    j.ColorbarVisible = 'off';
    j.GridVisible = 'off';
    j.XDisplayLabels = nan(size(j.XDisplayLabels));
    j.YDisplayLabels = nan(size(j.YDisplayLabels));
    j.YLabel = 'Full Dot Product';
    j.XLabel = 'Date';





    outputfilename = sprintf('YearDotshare_%s_%s_%s.fig', auxlocation, primchannel, auxchannel);
    matfilename = sprintf('YearDotshare_%s_%s_%s.mat', auxlocation, primchannel, auxchannel);
    fig = gcf;



    %saveas(gcf,outputfilename)
    %savefig(fig,outputfilename)
    savefig(outputfilename)
    matout = {Dotshare_matrix, TrimmedDates};
    save(matfilename, 'matout')

    outputfilename = sprintf('YearDotshare_%s_%s_%s.png', auxlocation, primchannel, auxchannel);
    print(outputfilename, '-dpng', '-r600')
    
    
    fprintf('\nDone!\n')
    quit(0,"force")
    
end

%Include ifo in the filename dotproduct_ifo_Chan1-Chan2.mat
%outputs
%save Data arrays
%EV for Strain dotted with random channel
%saving a .fig file rather than a .png