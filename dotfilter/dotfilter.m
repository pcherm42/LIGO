function out = dotfilter(levels, ifo, foldS, currentdir, monthfile, auxchannel, auxlocation, channeltags)

    %This is the main boi who runs everything and does the filtering.


    %init some variables

    correlation_factor = 1;


    %%% NOTE THAT THE channeldata, dotproducts, and Ranks must match the size of channeltags


    channeldata = {[], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    []};

    dotproducts = {[], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    []};

    Ranks = {[], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    [], ...
    []};

    

    %convert the imputs to the function to actually useful forms
    counter = 1;
    while counter < length(channeltags) + 1
        Cell = channeltags{counter};
        name = Cell{1};
        convertedform = channeltagconverter(ifo, name, foldS);
        dataget_cell = dataget(convertedform{1}, convertedform{2}, convertedform{3}, auxchannel, auxlocation, currentdir, monthfile, channeltags);
        channeldata{counter} = dataget_cell{1};
        counter = counter + 1;
    end

    convertedform = channeltagconverter(ifo, 'CAL-DELTAL_EXTERNAL_DQ', foldS);
    dataget_cell = dataget(convertedform{1}, convertedform{2}, convertedform{3}, auxchannel, auxlocation, currentdir, monthfile, channeltags);
    straindata = dataget_cell{1};



    %% Calculate dotproducts for the first time

    yearlength = size(straindata,2);
    dotsums = size(length(channeltags), yearlength);
    counter = 1;
    while counter < length(channeltags) + 1

        daycounter = 1;
        while daycounter <= yearlength
            dotproducts{counter}(:,daycounter) = statdot(channeldata{counter}(:,daycounter), straindata(:,daycounter));
            dotsums(counter, daycounter) = sum(dotproducts{counter}(:,daycounter), 'all'); 
            daycounter = daycounter + 1;
        end
        counter = counter + 1;
    end

    %% Downsample all data down to the lowest number

    counter = 1;
    samplerates = 1:length(channeltags);
    while counter < length(channeltags) + 1
        samplerates(counter) = channeltags{counter}{2};
        counter = counter + 1;
    end

    smallsample = min(samplerates);
    
    counter = 1;
    while counter < length(channeltags) + 1
        daycounter = 1;
        downsampled = [];
        while daycounter < yearlength + 1
            var1 = dotproducts{counter}(:,daycounter);
            rate = length(var1)/8;
            while rate > smallsample
                down = movmean(var1, 2);
                var1 = downsample(down,2);
                rate = length(var1)/8;
            end
            downsampled = [downsampled,var1];
            daycounter = daycounter + 1;
        end
        dotproducts{counter} = downsampled;
        counter = counter + 1;
    end

    counter = 1;
    while counter < length(channeltags) + 1
        daycounter = 1;
        downsampled = [];
        while daycounter < yearlength + 1
            var1 = channeldata{counter}(:,daycounter);
            rate = length(var1)/8;
            while rate > smallsample
                down = movmean(var1, 2);
                var1 = downsample(down,2);
                rate = length(var1)/8;
            end
            downsampled = [downsampled,var1];
            daycounter = daycounter + 1;
        end
        channeldata{counter} = downsampled;
        counter = counter + 1;
    end

    daycounter = 1;
    downsampled = [];
    while daycounter < yearlength + 1
        var1 = straindata(:,daycounter);
        rate = length(var1)/8;
        while rate > smallsample
            down = movmean(var1, 2);
            var1 = downsample(down,2);
            rate = length(var1)/8;
        end
        downsampled = [downsampled,var1];
        daycounter = daycounter + 1;
    end
    straindata = downsampled;

    %Create a ranking and save it
    rankmatrix = zeros(length(channeltags), yearlength);
    daycounter = 1;
    while daycounter < yearlength + 1
        days_dotpoducts = abs(dotsums(:,daycounter));
        [~,I] = sort(days_dotpoducts, 'descend');

        rk = 1;
        while rk < length(channeltags) + 1
            idx = I(rk);
            rankmatrix(idx, daycounter) = rk;
            rk = rk + 1;
        end

        daycounter = daycounter + 1;
    end


    %rankmatrix_master = 1./rankmatrix;


    %%%%%%%%% I Need to rethink the whole main loop, we should optimize for least amount of things.


    %% main loop
    levels = str2num(levels);
    level = 1;
    removed_ranks = zeros(length(channeltags), yearlength);
    while level < levels + 1



        %%%%%%%%%%%%%%%%%%%%%%% Subtract out the highest ranked dot product & populate the removed_ranks playlist. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        daycounter = 1;
        while daycounter < yearlength + 1
            counter = 1;
            while counter < length(channeltags) + 1
                if rankmatrix(counter,daycounter) == min(rankmatrix(:,daycounter))
                    projection = projuv(channeldata{counter}(:,daycounter), straindata(:,daycounter));
                    d = straindata(:,daycounter) - correlation_factor*projection*channeldata{counter}(:,daycounter);
                    straindata(:,daycounter) = d(:);
                    d=zeros(size(d));
                    Postdot = sum(statdot(channeldata{counter}(:,daycounter), straindata(:,daycounter)), 'all');
                    fprintf('Day: %g, Channel: %s, Predot: %g, Postdot: %g.\n', daycounter, channeltags{counter}{1}, dotsums(counter,daycounter), Postdot);

                    removed_ranks(counter,daycounter) = removed_ranks(counter,daycounter) + 1/level;
                end
                counter = counter + 1;
            end
            daycounter = daycounter + 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%% Recalculate DotProducts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        yearlength = size(straindata,2);
        dotsums = size(length(channeltags), yearlength);
        daycounter = 1;
        while daycounter < yearlength + 1
            counter = 1;
            while counter < length(channeltags) + 1
                dotproducts{counter}(:,daycounter) = statdot(channeldata{counter}(:,daycounter), straindata(:,daycounter));
                dotsums(counter, daycounter) = sum(dotproducts{counter}(:,daycounter), 'all'); 
                counter = counter + 1;
            end
            daycounter = daycounter + 1;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%% Re-rank %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        rankmatrix = zeros(length(channeltags), yearlength);
        daycounter = 1;
        while daycounter < yearlength + 1
            days_dotpoducts = abs(dotsums(:,daycounter));
            [~,I] = sort(days_dotpoducts, 'descend');

            rk = 1;
            while rk < length(channeltags) + 1
                idx = I(rk);
                rankmatrix(idx, daycounter) = rk;
                rk = rk + 1;
            end
            daycounter = daycounter + 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        level = level + 1;
    end

    out = {straindata, removed_ranks};
    
end

%Include ifo in the filename dotproduct_ifo_Chan1-Chan2.mat
%outputs
%save Data arrays
%EV for Strain dotted with random channel
%saving a .fig file rather than a .png
