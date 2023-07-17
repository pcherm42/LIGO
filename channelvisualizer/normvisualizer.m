function normvisualizer(ifo, currentdir, monthfile, dotweighquerey) %This may need to run on more than 1TB of Memory machines.... The common killed error is a result of running out of memory for CAL channel with the large samplerate.

    auxfoldS = '8';
    auxlocation = ifo;
    

    channeltags = {{'PEM-EX_MAG_EBAY_SUSRACK_X_DQ', 8192}, ...
    {'PEM-EX_MAG_EBAY_SUSRACK_Y_DQ', 8192}, ...
    {'PEM-EX_MAG_EBAY_SUSRACK_Z_DQ', 8192}, ...
    {'PEM-EY_MAG_EBAY_SUSRACK_X_DQ', 8192}, ...
    {'PEM-EY_MAG_EBAY_SUSRACK_Y_DQ', 8192}, ...
    {'PEM-EY_MAG_EBAY_SUSRACK_Z_DQ', 8192}, ...
    {'PEM-CS_MAG_EBAY_SUSRACK_X_DQ', 8192}, ...
    {'PEM-CS_MAG_EBAY_SUSRACK_Y_DQ', 8192}, ...
    {'PEM-CS_MAG_EBAY_SUSRACK_Z_DQ', 8192}, ...
    {'PEM-CS_MAG_LVEA_VERTEX_X_DQ', 8192}, ...
    {'PEM-CS_MAG_LVEA_VERTEX_Y_DQ', 8192}, ...
    {'PEM-CS_MAG_LVEA_VERTEX_Z_DQ', 8192}, ...
    {'PEM-EX_ADC_0_12_OUT_DQ', 2048}, ...
    {'PEM-EY_ADC_0_12_OUT_DQ', 2048}, ...
    {'CAL-DELTAL_EXTERNAL_DQ', 16384}}; %%Might want to take out the smallest ranked channels. BE CAREFUL CHANGING HIS SIZE, DOTFILTER HAS THE OTHER ARRAYS THAT NEED TO BE LIKE THIS GUY

    for i = 1:length(channeltags)
        auxchannel = 'CAL-DELTAL_EXTERNAL_DQ';
        imput_cell = channeltagconverter(ifo, channeltags{i}{1}, auxfoldS);
        dataget_cell = dataget(imput_cell{1} , imput_cell{2}, imput_cell{3}, auxchannel, auxlocation, currentdir, monthfile, channeltags);
        auxdata = dataget_cell{1};
        dates = dataget_cell{2};

        daycounter = 1;
        clear daydata absdaydata Dotshare_matrix TrimmedData
        while daycounter < size(auxdata,2) + 1
            daydata(:) = auxdata(:,daycounter);
            absdaydata(:) = abs(daydata(:));
            daysum = sum(absdaydata);
            Dotshare_matrix(:,daycounter) = absdaydata(:)/daysum;
            TrimmedData(daycounter) = sum(Dotshare_matrix(:,daycounter));
            daycounter = daycounter + 1;
        end
        
        TrimmedDates = dates(1:daycounter);
        TrimmedDates = string(datetime(TrimmedDates,'ConvertFrom', 'datenum'));
        l = length(Dotshare_matrix(:,1));
        times = 1:l;
        times = times/l;
        times = 8*times - .5;

        reset(gca)
        reset(gcf)
        figure

        sz1 = size(Dotshare_matrix,1);
        sz2 = size(Dotshare_matrix,2);
        ylabels = nan(sz1,1);
        xlabels = num2cell(nan(sz2,1));


        Datefreq = 15; %days
        timefreq = sz1/16;

        

        %make y labels
        cnt = 1;
        while cnt < sz1 + 1

            if mod(cnt,timefreq) == 0
                %ylabels(cnt) = floor(2*times(cnt))/2;
                ylabels(cnt) = times(cnt);
            end

            cnt = cnt + 1;

        end

    

        %make x labels
        cnt2 = 1;
        while cnt2 < sz2 + 1

            if mod(cnt2,Datefreq) == 0
                xlabels{cnt2} = TrimmedDates(cnt2);
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


        plottitle = sprintf('Normed Data %s:%s', auxlocation, channeltags{i}{1});
        plottitle = strrep(plottitle, '_', ' ');


    


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
        h.YLabel = 'Seconds';

        nexttile


        j = plot(TrimmedData)
        ylabel('Norm');
        xlabel('Date');
        xlim([0,length(TrimmedData)])





        outputfilename = sprintf('channeldata_%s_%s.fig', auxlocation, channeltags{i}{1});
        fig = gcf;
        savefig(outputfilename)
        outputfilename = sprintf('channeldata_%s_%s.png', auxlocation, channeltags{i}{1});
        print(outputfilename, '-dpng', '-r600')

        clf('reset');
    end





    fprintf('\nDone!\n')
    quit(0,"force")
    
end
