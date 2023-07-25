function out = dotshare(path1, varname1, samplerate1, path2, varname2, samplerate2, bandpassquerey)


    file1 = load(path1);
    file2 = load(path2);
    var1= file1.(varname1);
    var2 = file2.(varname2);

    if numel(var1) < numel(var2)
        times = file1.("fract");
    else
        times = file2.("fract");
    end

    
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

    % bandpass
    if bandpassquerey == true
        NFFT = length(var1);
        Fs = samplerate1;
        Y = fft(var1, NFFT);
        L = length(Y);

        fhigh = 50; flow = 10; 
        nbinmax = round(fhigh*length(Y)/Fs + 1); 
        nbinmin = round(flow*length(Y)/Fs + 1); 
        bandY = zeros(size(Y)); 
        bandY(nbinmin:nbinmax) = Y(nbinmin:nbinmax); 
        bandY(end - nbinmax + 2: end - nbinmin + 2) = Y(end - nbinmax + 2 : end - nbinmin + 2); 
        bandY(1) = 0; 
        bandY(L/2 + 1) = 0.; 
        var1 = ifft(bandY);
    end

    if bandpassquerey == true
        NFFT = length(var2);
        Fs = samplerate2;
        Y = fft(var2, NFFT);
        L = length(Y);

        fhigh = 50; flow = 10; 
        nbinmax = round(fhigh*length(Y)/Fs + 1); 
        nbinmin = round(flow*length(Y)/Fs + 1); 
        bandY = zeros(size(Y)); 
        bandY(nbinmin:nbinmax) = Y(nbinmin:nbinmax); 
        bandY(end - nbinmax + 2: end - nbinmin + 2) = Y(end - nbinmax + 2 : end - nbinmin + 2); 
        bandY(1) = 0; 
        bandY(L/2 + 1) = 0.; 
        var2 = ifft(bandY);
    end


    mean_1 = mean(var1);
    mean_2 = mean(var2);
    x = var1 - mean_1;
    y = var2 - mean_2;
    x = abs(x);
    y = abs(y);
    product = sum(x.*y, 'all');
    %stddev1 = std(var1);
    %stddev2 = std(var2);
    %normalizer = 1./(stddev1*stddev2*sqrt(samplerate1));
    %normedproduct = product*normalizer;
    
    out = {(x.*y)/product,times};





end