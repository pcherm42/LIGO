function out = fftbandpass(data,samplerate,lowerband,upperband)

    frequencyseries = fft(data);
    L = numel(data);
    f = samplerate*(0:(L/2))/L;

    for i = 1:numel(f)
        if f(i) < lowerband || f(i) > upperband
            frequencyseries(i) = 0.;
        end
    end

    out = ifft(frequencyseries);

end


