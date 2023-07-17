function out = dotfilterproduct(data1, data2)


    var1= data1;
    var2 = data2;

    
    while length(var1) < length(var2)
        down = movmean(var2, 2);
        var2 = downsample(down,2);
    end

    
    while length(var2) < length(var1)
        down = movmean(var1, 2);
        var1 = downsample(down,2);
    end

    samplerate = length(var1)/8;


    mean_1 = mean(var1);
    mean_2 = mean(var2);
    x = var1 - mean_1;
    y = var2 - mean_2;
    stddev1 = std(var1);
    stddev2 = std(var2);
    product = x.*y;
    normalizer = 1./(stddev1*stddev2*sqrt(samplerate));
    normedproduct = product*normalizer;
    
    out = normedproduct;





end