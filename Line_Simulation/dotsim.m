function out = dotsim(binshift, delta, base_freq, sigma_strain, sigma_auxchan, nbinpersec, value, ncycles, coupling, halfwidth, bandpassquerey, wave_type)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INITIALIZE AUXDATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nbintot = nbinpersec*8;
    auxchan_data = random('norm',0.,sigma_auxchan,nbintot,1);
    periodic_correction_factor = 1000; %moves between the peaks "value" and the height for the periodic functions, ensures cross-compatibility
    peaks_factor = 4;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NEAR-INTEGER COMB CHAN1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %secday = 24*60*60;
    nbinspercycle = nbinpersec*8;

    freq = delta + base_freq;
    binsperiod = round(nbinpersec/freq); %how many bins pass for each frequency cycle
    

    binsperiodcounter = binshift;
    cyclecounter = 1;
    halfwidth = round(halfwidth*nbinpersec);

    %disp(binsperiodcounter)


    if strcmp(wave_type, 'peaks')
        while cyclecounter < ncycles + 1
            bincounter = 1;
            while bincounter < (nbinspercycle + 1)
                if binsperiodcounter/binsperiod == 1
                    height = peaks_factor*value/ncycles;
                    centerindex = bincounter;
                    auxchan_data = peakmaker(auxchan_data, halfwidth, height, centerindex);% auxchan_data(bincounter) + value/ncycles;
                    binsperiodcounter = 1;
                else
                    binsperiodcounter = binsperiodcounter + 1;
                end
                bincounter = bincounter + 1;
            end
            cyclecounter = cyclecounter + 1;
        end
    elseif strcmp(wave_type, 'triangle')
        height = periodic_correction_factor*value/ncycles;
        fold = 1:nbintot;
        base_time = fold/nbinpersec;
        while cyclecounter < ncycles + 1
            timephase = nbintot*cyclecounter;
            fold = height*sawtooth(2*pi*freq*(base_time + timephase + binshift/nbinpersec),.5);
            auxchan_data = auxchan_data + transpose(fold);
            cyclecounter = cyclecounter + 1;
        end
    elseif strcmp(wave_type, 'sin')
        height = periodic_correction_factor*value/ncycles;
        fold = 1:nbintot;
        base_time = fold/nbinpersec;
        while cyclecounter < ncycles + 1
            timephase = nbintot*cyclecounter;
            fold = height*sin(2*pi*freq*(base_time + timephase + binshift/nbinpersec));
            auxchan_data = auxchan_data + transpose(fold);
            cyclecounter = cyclecounter + 1;
        end
    elseif strcmp(wave_type, 'cos')
        height = periodic_correction_factor*value/ncycles;
        fold = 1:nbintot;
        base_time = fold/nbinpersec;
        while cyclecounter < ncycles + 1
            timephase = nbintot*cyclecounter;
            fold = height*cos(2*pi*freq*(base_time + timephase + binshift/nbinpersec));
            auxchan_data = auxchan_data + transpose(fold);
            cyclecounter = cyclecounter + 1;
        end
    elseif strcmp(wave_type, 'sawtooth')
        height = periodic_correction_factor*value/ncycles;
        fold = 1:nbintot;
        base_time = fold/nbinpersec;
        while cyclecounter < ncycles + 1
            timephase = nbintot*cyclecounter;
            fold = height*sawtooth(2*pi*freq*(base_time + timephase + binshift/nbinpersec));
            auxchan_data = auxchan_data + transpose(fold);
            cyclecounter = cyclecounter + 1;
        end
    end

    %disp(8*nbinpersec-centerindex)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREATE & CONTAMINATE THE STRAIN CHANNEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strain_data_pure = random('norm',0.,sigma_strain,nbintot,1);
    strain_data = strain_data_pure;

    strain_data = strain_data + auxchan_data*coupling;
    mean_strain = mean(strain_data);
    std_strain = std(strain_data);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BANDPASS 10-50 HZ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if bandpassquerey
        
        auxchan_data = fftbandpass(auxchan_data,nbinpersec,10,50);
        strain_data = fftbandpass(strain_data,nbinpersec,10,50);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALCULATE DOTPRODUCT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mean_auxchan = mean(auxchan_data);
    std_auxchan = std(auxchan_data);
    
    dotprodterms = 1:nbintot;
    dotprodterms(:) = (strain_data-mean_strain).*(auxchan_data(:)-mean_auxchan)/(sqrt(nbintot)*std_strain*std_auxchan);

    out = dotprodterms;
end