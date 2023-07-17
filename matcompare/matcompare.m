function out = matcompare(path1, varname1, samplerate1, path2, varname2, samplerate2)


    file1 = load(path1);
    file2 = load(path2);
    var1= file1.(varname1);
    var2 = file2.(varname2);


    
    while samplerate1 < samplerate2

        down = movmean(var2, 2);
        var2 = downsample(down,2);
        half = samplerate2/2;
        samplerate2 = half;
    end

    
    while samplerate2 < samplerate1

        down = movmean(var1, 2);
        var1 = downsample(down,2);
        half = samplerate1/2;
        samplerate1 = half;
    end


    mean_1 = mean(var1);
    mean_2 = mean(var2);
    x = var1 - mean_1;
    y = var2 - mean_2;
    product = sum(x.*y, 'all');
    stddev1 = std(var1);
    stddev2 = std(var2);
    normalizer = 1./(stddev1*stddev2*sqrt(samplerate1));
    normedproduct = product*normalizer;
    
    out = normedproduct;






end