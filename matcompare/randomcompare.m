function out = randomcompare();

    sz1 = 2^14;
    sz2 = 2^14;
    sigma1 = 10;
    sigma2 = 11;


    dat1 = normrnd(0,sigma1,1,sz1);
    dat2 = normrnd(0,sigma2,1,sz1);

    var1 = dat1;
    var2 = dat2;
    samplerate1 = sz1;
    samplerate2 = sz2;


    
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



