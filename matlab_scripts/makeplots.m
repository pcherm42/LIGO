function [status, ycleaned] = makeplots(fract,y,Fs,label, fnamepeaks,fnamepdf,fnamepng,fnamespectra, foldSize, channel, full)
    PASS = 'band pass';

    nstr = fnamepdf(1:end - 4); 
    nstr = [nstr '.mat']; 
    nstr;
    fractSize = length(fract); 
    fol = fractSize / Fs; 
    sfol=fol*Fs; 
    if foldSize == 1
        fractt = (-fractSize / 2 : sfol - fractSize / 2 - 1)/16384;
    end
    fractt = foldSize * fract - .5; 
    
    fprintf('fractt and y: %d, %d\n', length(fractt), length(y)); 
    % for 16 parts only sfol=fol*16384 /16;
    % fractt = (-512:sfol-513)/16384;
    % for 16 parts only fol = fol / 16;
    
    
    L = length(y);
    fprintf('the lenght of y: %d\n', length(y)); 
    T = 1/Fs;
    t = (0:L-1)*T;
    NFFT = L;
    Y = fft(y,NFFT);
    %Y = fft(y, NFFT)/L; 
    freq = Fs/2*linspace(0,1-2/L,L/2);
    spectrum = 2.*abs(Y(1:L/2));
    %fprintf('length(spectrum)=%d, length(f)=%d\n',length(spectrum),length(freq));
    %fprintf('args, freq: %d, spectrum: %d\n', freq, spectrum);
    %[npeak,peakbin,peakfreq,peakval,avgleft,stdleft,avgright,stdright,snr] = getpeaks(freq,spectrum);
    full = false;
    if full
        fprintf('Found %d peaks for %s\n',npeak,label);
        fprintf('fnamepeaks = %s\n', fnamepeaks)
        fidpeaks = fopen(fnamepeaks,'w');
        fprintf(fidpeaks,'%% %s:\n%%\n',fnamepeaks);
        fprintf(fidpeaks,'%% Peaks found in folded data of %s\n%%\n',label);
        fprintf(fidpeaks,'%% Legend:\n%% Peak_No,Bin_No,Freq,Value,AveLeft,StdLeft,AveRight,Stdright,Max_SNR\n%%\n');
        for peak = 1:npeak
            fprintf(fidpeaks,'%d,%d,%f,%e,%e,%e,%e,%e,%f\n',peak,peakbin(peak),peakfreq(peak),peakval(peak),avgleft(peak),stdleft(peak),avgright(peak),stdright(peak),snr(peak));
        end
        fclose(fidpeaks);
    end
    figure; 
    subplot(3,2,[1 2]);
    fol;
    plot(fractt,y);
    % for 1/16 only xlim([-1/32 fol-1/32])
    % if n > 0 
    %   xlim([-1/32 fol-1/32]) 
    %  else 
    xlim([-.5 fol-.5]);
    %end
    
    %if n > 0
    %xlim([-fol/2-foldSize/2+(n-1)*fol   fol - fol/2 - foldSize/2 + n * fol])
    %end

    % Create spectra files
    fidspectra = fopen(fnamespectra, 'w');
    fprintf(fidspectra,'%% %s:\n%%\n',fnamespectra);
    fprintf(fidspectra,['%% Spectra of folded data of %s\n%%\' ...
                      'n'],label);
    fprintf(fidspectra,'%% Legend:\n%% Bin_No,Freq,Value\n%%\n');
    for bin = 1:length(spectrum)
        fprintf(fidspectra, '%d, %d, %d\n', bin, freq(bin), spectrum(bin));
    end
    fclose(fidspectra);
    
    titlestr = sprintf('%s', channel);
    title(titlestr, 'Interpreter','none');
    xlabel('Seconds','FontSize',9); %ADDED 5/28/2020 to add labels
    ylabel('Counts'); %ADDED 5/28/2020 to add labels



    subplot(3,2,3);
    semilogy(freq,spectrum,'color','red');
    ylim([min(spectrum)/10. 10.*max(spectrum)]);
    titlestr = sprintf('Spectrum of Folded Data');
    title(titlestr, 'Interpreter','none','FontSize',8);
    ylabel('Counts per Root Hertz','FontSize',8); %ADDED 5/28/2020 to add labels
    xlabel('Hertz'); %ADDED 5/28/2020 to add labels
    
    %peaks removed
    %for peak = 1:npeak
    %   Y(peakbin(peak)) = 0.;
    %   if (peakbin(peak)==1)
    %      Y(L/2+1) = 0.;
    %   else
    %      Y(L-peakbin(peak)+2) = 0.;
    %   end
    %end
    
    finalY = zeros(size(Y));
    tstr = '';

    % low pass
    if strcmp(PASS,'low pass')
        fcutoff = 50;
        nbinmax = round(fcutoff*length(Y)/Fs + 1);
        lowY = zeros(size(Y));  
        lowY(1:nbinmax) = Y(1:nbinmax); 
        lowY(end - nbinmax + 2:end) = Y(end - nbinmax + 2:end); 
        lowY(1) = 0; 
        lowY(L/2+1) = 0.;
        finalY = lowY;

        tstr = sprintf('Low pass (>%dHz removed)', fcutoff);
    end
    
    % bandpass
    if strcmp(PASS, 'band pass')
        fhigh = 50; flow = 10; 
        nbinmax = round(fhigh*length(Y)/Fs + 1); 
        nbinmin = round(flow*length(Y)/Fs + 1); 
        bandY = zeros(size(Y)); 
        bandY(nbinmin:nbinmax) = Y(nbinmin:nbinmax); 
        bandY(end - nbinmax + 2: end - nbinmin + 2) = Y(end - nbinmax + 2 : end - nbinmin + 2); 
        bandY(1) = 0; 
        bandY(L/2 + 1) = 0.; 
        finalY = bandY;

        tstr = sprintf('%dHz to %dHz band pass',  flow, fhigh);
    end

    % high pass
    if strcmp(PASS, 'high pass')
        for ibin = 2:nbinmax
            Y(ibin) = 0.;
            Y(L-ibin+2) = 0.;
        end
        Y(1) = 0.;
        Y(L/2+1) = 0.;
        finalY = Y;
    end

    % Band pass
    ycleaned = ifft(finalY); 
    %save(nstr, 'y', 'fract', 'ycleaned', 'bandY', 'Y', 'L', 'Fs');

    % Low pass
    %ycleaned = ifft(lowY);
    % ycleaned = ifft(Y); 
    
    
    subplot(3,2,4);
    finalSpectrum = 2.*abs(finalY(1:L/2));
    semilogy(freq,finalSpectrum,'color','red');
    ylim([min(finalSpectrum)/10. 10.*max(finalSpectrum)]);
    titlestr = sprintf('Spectrum of Folded Data after Filtering');
    title(titlestr, 'Interpreter','none','FontSize',8);
    ylabel('Counts per Root Hertz','FontSize',8); %ADDED 5/28/2020 to add labels
    xlabel('Hertz'); %ADDED 5/28/2020 to add labels
    
    subplot(3,2,[5 6]);
    % for i=1:length(fract)
    %     fractt(i)=fract(i)-0.5;
    % end
    
    
    % Ynew = fft(y,length(y))/length(y);
    % ynew = ifft(Ynew); 
    % plot(fractt, ynew); 
    
    
    plot(fractt,ycleaned);
    % for 1/16 only: 
    % if n > 0
    %    xlim([-1/32 fol-1/32])
    % else 
    xlim([-.5 fol-.5]);
    %end  
    %xlim([-fol/2-foldSize/2+(n-1)*fol   fol - fol/2 - foldSize/2 + n * fol])
    

    title(tstr, 'Interpreter', 'none');
    ylabel('Counts'); %ADDED 5/28/2020 to add labels
    xlabel('Seconds'); %ADDED 5/28/2020 to add labels
    print('-dpdf',fnamepdf);
    print('-dpng',fnamepng);
    status = 0;
    figure; 
    plot(fractt,ycleaned); title(tstr, 'Interpreter', 'none');
    fnamepdf2 = [fnamepdf(1:end-4) 'post_process.pdf'];
    print('-dpdf', fnamepdf2); 
    
end