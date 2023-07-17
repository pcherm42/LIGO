%This script takes a {Dotshare_matrix, trimmeddates} from yeardotshare and outputs a zoomed in set of data from the given parameters.
function yeardotshare_zoomin(matoutpath, xlow, xhigh, ylow, yhigh, FS) 

    matoutfile = load(matoutpath);
    matout = matoutfile.('matout');
    Matrix = matout{1};
    Dates = matout{2};

    FS = round(str2double(FS));
    xlow = round(str2double(xlow));
    xhigh = round(str2double(xhigh));
    ylow = round(str2double(ylow)*FS);
    yhigh = round(str2double(yhigh)*FS);
    times = (1:8*FS)/FS;
    

    Matrix = Matrix(ylow:yhigh,xlow:xhigh);

    sz1 = size(Matrix,1);
    sz2 = size(Matrix,2);
    ylabels = num2cell(nan(sz1,1));
    xlabels = num2cell(nan(sz2,1));



    Datefreq = round(sz2/10); %days
    timefreq = round(sz1/16);

    shifty = ylow;
    shiftx = xlow;
    cnt = 1;

    %make y labels
    while cnt < sz1 + 1

        if mod(cnt,timefreq) == 0
            ylabels{cnt} = round(times(cnt + shifty), 4);
        end

        cnt = cnt + 1;

    end

    cnt2 = 1;

    %make x labels
    while cnt2 < sz2 + 1

        if mod(cnt2,Datefreq) == 0
            xlabels{cnt2} = string(Dates(cnt2 + shiftx));      %string(Datestrings(cnt2));
        end

        cnt2 = cnt2 + 1;
        
    end


    [~, name, ~] = fileparts(matoutpath);


    plottitle = strcat(name, sprintf(' Zoomed x:%s:%s to y:%s:%s', num2str(xlow), num2str(xhigh), num2str(ylow/FS,3), num2str(yhigh/FS,3)));
    plottitle = strrep(plottitle, '_', ' ');



    




    h = heatmap(abs(Matrix));
    h.FontSize = 6;
    h.Colormap = flipud(gray);
    h.Title = plottitle;
    h.ColorbarVisible = 'off';
    h.GridVisible = 'off';
    h.XDisplayLabels = xlabels;
    h.YDisplayLabels = ylabels;
    %h.XLabel = 'Date';
    h.YLabel = 'Seconds';


    outputfilename = strcat(name, sprintf('_x:%s:%s_y:%s:%s.fig', num2str(xlow), num2str(xhigh), num2str(ylow/FS,3), num2str(yhigh/FS,3)));
    %fig = gcf;




    savefig(outputfilename)
    outputfilename = strcat(name, sprintf('_x:%s:%s_y:%s:%s.png', num2str(xlow), num2str(xhigh), num2str(ylow/FS,3), num2str(yhigh/FS,3)));
    print(outputfilename, '-dpng', '-r500')
    %saveas(gcf, outputfilename)
    
    
    fprintf('\nDone!\n')
    quit(0,"force")
    


end