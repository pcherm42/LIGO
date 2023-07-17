function dotfilter_driver(levels, ifo, dotweighquerey, auxlocation, auxfoldS, auxchannel, auxNFFT, currentdir, monthfile)

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
    {'PEM-EY_ADC_0_12_OUT_DQ', 2048}}; %%Might want to take out the smallest ranked channels. BE CAREFUL CHANGING HIS SIZE, DOTFILTER HAS THE OTHER ARRAYS THAT NEED TO BE LIKE THIS GUY


    imput_cell = channeltagconverter(ifo, auxchannel, auxfoldS);
    dataget_cell = dataget(imput_cell{1} , imput_cell{2}, imput_cell{3}, auxchannel, auxlocation, currentdir, monthfile, channeltags);
    auxdata = dataget_cell{1};
    dates = dataget_cell{2};

    dotfilter_cell = dotfilter(levels, ifo, auxfoldS, currentdir, monthfile, auxchannel, auxlocation, channeltags);
    dotfilteredstrain = dotfilter_cell{1};
    top_ranks = dotfilter_cell{2};
    Dotshare_matrix = zeros(size(dotfilteredstrain));

    %% Calculate their dot product next

    daycounter = 1;
    while daycounter < size(dotfilteredstrain,2) + 1
        DotProduct = statdot(dotfilteredstrain(:,daycounter), auxdata(:,daycounter));
        TrimmedData(daycounter) = sum(DotProduct, 'all');
        Dotshare_matrix(:,daycounter) = abs(DotProduct)/sum(abs(DotProduct));
        daycounter = daycounter + 1;
    end

    TrimmedData = transpose(TrimmedData);


    %%%%%%% end dot product.




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

    cnt = 1;

    %make y labels
    while cnt < sz1 + 1

        if mod(cnt,timefreq) == 0
            %ylabels(cnt) = floor(2*times(cnt))/2;
            ylabels(cnt) = times(cnt);
        end

        cnt = cnt + 1;

    end

    cnt2 = 1;

    %make x labels
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







    plottitle = sprintf('Dotshare %s:%s and %s:%s', ifo, 'CAL_DELTAL_EXTERNAL_DQ', auxlocation, auxchannel);
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


    j = plot(TrimmedData)
    %j.XDisplayLabels = nan(size(j.XDisplayLabels));
    %j.YDisplayLabels = nan(size(j.YDisplayLabels));
    ylabel('Dot Product post Dotfilter');
    xlabel('Date');
    xlim([0,length(TrimmedData)])





    outputfilename = sprintf('dotfilter_%s_%s_%s_%s.fig', levels, auxlocation, auxchannel);
    matfilename = sprintf('dotfilter_%s_%s_%s_%s.mat',levels, auxlocation, auxchannel);
    fig = gcf;



    %saveas(gcf,outputfilename)
    %savefig(fig,outputfilename)
    savefig(outputfilename)
    matout = {Dotshare_matrix, TrimmedDates};
    save(matfilename, 'matout')

    outputfilename = sprintf('dotfilter_%s_%s_%s_%s.png', levels, auxlocation, auxchannel);
    print(outputfilename, '-dpng', '-r600')

    clf('reset');

    top_ranks_matrix = top_ranks;

    cnt = 1;
    sz1 = size(top_ranks_matrix,1);

    ylabels = {};


    %make y labels
    while cnt < sz1 + 1
        ylabels{cnt} = strrep(channeltags{cnt}{1}, '_', '-');
        cnt = cnt + 1;
    end

    plottitle = 'Dotfilter Top Ranks';

    h = heatmap(top_ranks_matrix);
    h.FontSize = 6;
    h.Colormap = flipud(gray);
    h.Title = plottitle;
    h.ColorbarVisible = 'off';
    h.GridVisible = 'off';
    h.XDisplayLabels = xlabels;
    h.YDisplayLabels = ylabels;
    %h.XLabel = 'Date';
    h.YLabel = '';

    outputfilename = sprintf('ranks_%s_%s_%s.png', levels, auxlocation, auxchannel);
    print(outputfilename, '-dpng', '-r600')





    fprintf('\nDone!\n')
    quit(0,"force")
    
end
