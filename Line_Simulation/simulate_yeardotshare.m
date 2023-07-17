clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wave_type = 'peaks'; %options: 'peaks', 'triangle', 'sin', 'cos', 'sawtooth'
sigma_strain = 0.1;
sigma_auxchan = 3.3;
coupling = .01; %Auxillary coupling coefficient
nbinpersec = 8192; %Sample Rate
base_freq = 1; %"Hz"
halfwidth = .01; %in SECONDS
delta = -.00001; %Hz, how far to drift from base_freq
value = 1.5*base_freq*sigma_auxchan; %Height of artifacts should scale with these guys
dayfrac = 1/10; %what fraction of a day to simulate folding
ncycles = round(dayfrac*24*60*60/8); %how many times over a day we simulate folding (24 hrs 60 mins 60 sec / length) - THIS DOES NOT AFFECT OVERALL DAY SKIPPING;
year_length = 10; %How many days to run
bandpassquerey = false; %Generate -> Contaminate --> Bandpass(true/false) --> Dot together --> Display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  YEAR_LOOP  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%% Experimental sample rate problem bug fix %%%%%
%{
if abs(round(nbinpersec/base_freq)-(nbinpersec/base_freq)) > 0
    nbinpersec = lcm(nbinpersec,base_freq)
    disp("Fixing nbinpersec with lcm")
end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbinspercycle = nbinpersec*8.;
Dotshare_matrix = zeros(nbinspercycle,year_length);
binshift = 0;
seconds_day = 24*60*60;
tickspersec = base_freq+delta;
nbinpertick = nbinpersec/tickspersec;
residue = 0;


for day = 1:year_length
    fprintf('Day is %d. Binshift is %d. Cycleshift is %f. Timeshift is %f\n', day, binshift, residue, binshift/nbinpersec)
    sim = dotsim(binshift, delta, base_freq, sigma_strain, sigma_auxchan, nbinpersec, value, ncycles, coupling, halfwidth, bandpassquerey, wave_type);
    share = sim;
    Dotshare_matrix(:,day) = share;
    t = day*seconds_day;
    ticks = tickspersec*t;
    residue = mod(ticks,1); %how far through a cycle we are
    binshift = round(residue*nbinpertick);
end


%%%%%%%%%%%%%%%%%%%%%%%%       PLOTTING      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TrimmedDates = 1:year_length;


sz1 = size(Dotshare_matrix,1);
sz2 = size(Dotshare_matrix,2);
ylabels = nan(sz1,1);
xlabels = num2cell(nan(sz2,1));
times_raw = 1:nbinspercycle;
times = times_raw/nbinpersec;


Datefreq = 15; %days
timefreq = sz1/16;

cnt = 1;

%make y labels
while cnt < sz1 + 1

    if mod(cnt,timefreq) == 0
        ylabels(cnt) = floor(2*times(cnt))/2;
    end

    cnt = cnt + 1;

end

cnt2 = 1;

%make x labels
while cnt2 < sz2 + 1
    if mod(cnt2,Datefreq) == 0
        xlabels{cnt2} = TrimmedDates(cnt2);%string(Datestrings(cnt2));
    end
    cnt2 = cnt2 + 1;     
end

figure

f = plot(times,share);
title('Last Column of Dotshare Matrix');


figure
h = heatmap(abs(Dotshare_matrix));
h.FontSize = 6;
h.Colormap = flipud(gray);
h.ColorbarVisible = 'off';
h.GridVisible = 'off';
h.XDisplayLabels = xlabels;
h.YDisplayLabels = ylabels;
h.YLabel = 'Seconds';
h.Title = 'Dotshare Matrix';
%saveas(h,'result.png') 
