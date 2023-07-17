% Script to simulate dot product for strain and auxiliary channels
% with correlated artifacts in particular time samples

clear *
close all

% Sigmas to use for random values in strain and aux channels

sigma_strain = 0.1;
nauxchan = 2;
sigma_auxchan(1) = 3.3;
sigma_auxchan(2) = 3.2;

% Coupling factors to strain channel:

coupling_auxchan(1) = .01;
coupling_auxchan(2) = 0;%-0.05;

% Number of bins per second in time sample

nbinpersec = 16384;

% Artifact channels/positions/values to add (each second):

%%%%%%%%%%%%%%%%%%%%%%%% REGULAR ARTIFACT SECTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nartifact = 0;
artifact_auxchan(1) = 1;
artifact_auxchan(2) = 1;
artifact_auxchan(3) = 2;
artifact_auxchan(4) = 2;
artifact_position(1) = .01; %seconds in each second (0,1)
artifact_position(2) = .2;
artifact_position(3) = .5;
artifact_position(4) = .7;
artifact_value(1) = 30.*sigma_auxchan(artifact_auxchan(1));
artifact_value(2) = 40.*sigma_auxchan(artifact_auxchan(2));
artifact_value(3) = 20.*sigma_auxchan(artifact_auxchan(3));
artifact_value(4) = 10.*sigma_auxchan(artifact_auxchan(4));

% Simulate raw data for auxiliary channels, including artifacts

nbintot = nbinpersec*8;
auxchan_data = zeros(nbintot,nauxchan);
for chan = 1:nauxchan
   auxchan_data(:,chan) = random('norm',0.,sigma_auxchan(chan),nbintot,1);
end
for artifact = 1:nartifact
   chan = artifact_auxchan(artifact);
   position = artifact_position(artifact);
   value = artifact_value(artifact);
   for sec = 1:8
      binindex = round((sec-1)*nbinpersec + position*nbinpersec);
      auxchan_data(binindex,chan) = auxchan_data(binindex,chan) + value;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NEAR-INTEGER COMB CHAN1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

base_freq = 1; %"Hz"
day_shift = 0; %The frequency ought to drift mover over several days
delta = -0.00002;
chan = 1;
value = 200.*sigma_auxchan(chan);
ncycles = round(24*60*60/8); %how many times over a day we cycle (24 hrs 60 mins 60 sec / length);
nbinsperday = nbinpersec*60*60*24;
nbinspercycle = nbinpersec*8;



freq = delta + base_freq;
binsperiod = round(nbinpersec/freq); %how many bins pass for each frequency cycle

binsperiodcounter = mod(nbinsperday*day_shift,binsperiod) + 1;
cyclecounter = 1;

while cyclecounter < ncycles + 1
    bincounter = 1;
    while bincounter < (nbinspercycle + 1)
        if binsperiodcounter/binsperiod == 1
            auxchan_data(bincounter,chan) = auxchan_data(bincounter,chan) + value/ncycles;
            binsperiodcounter = 1;
        else
            binsperiodcounter = binsperiodcounter + 1;
        end
        bincounter = bincounter + 1;
    end
    cyclecounter = cyclecounter + 1;
end    




% Create random strain data 

strain_data_pure = zeros(nbintot,1);
strain_data_pure = random('norm',0.,sigma_strain,nbintot,1);
strain_data = strain_data_pure;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% and add artifacts via the aux couplings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for chan = 1:nauxchan
    strain_data = strain_data + auxchan_data(:,chan)*coupling_auxchan(chan);
end
mean_strain = mean(strain_data);
std_strain = std(strain_data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BANDPASS 10-50 HZ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bandpassquerey = true;


if bandpassquerey
    for chan = 1:nauxchan
        auxchan_data(:,chan) = bandpass(auxchan_data(:,chan),[10,50],nbinpersec);
    end
    strain_data = bandpass(strain_data,[10,50],nbinpersec);
    strain_data_pure = bandpass(strain_data_pure,[10,50],nbinpersec);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ts = 1:nbinspercycle;
ts = ts/nbinpersec;

figure(1);
subplot(nauxchan+1,1,1);
plot(ts,strain_data,'color','blue');
hold on
plot(ts,strain_data_pure,'color','red');
legend('Strain with contamination','Pure strain');
for chan = 1:nauxchan
   subplot(nauxchan+1,1,chan+1);
   plot(ts,auxchan_data(:,chan));
   legendstr = sprintf('Auxiliary channel %d',chan);
   legend(legendstr);
end

for chan = 1:nauxchan
   mean_auxchan(chan) = mean(auxchan_data(:,chan));
   std_auxchan(chan) = std(auxchan_data(:,chan));
   fprintf('Auxiliary channel %d:\n  Nominal std = %f\n  Actual std =   %f\n',chan,sigma_auxchan(chan),std_auxchan(chan));
end

sigma_data = std(strain_data);
fprintf('Strain channel:\n  Nominal std = %f\n  Actual std =   %f\n',sigma_strain,std_strain);

dotprodterms = zeros(nbintot,nauxchan);
for chan = 1:nauxchan
   dotprodterms(:,chan) = (strain_data-mean_strain).*(auxchan_data(:,chan)-mean_auxchan(chan))/(sqrt(nbintot)*std_strain*std_auxchan(chan));
   dotprod(chan) = sum(dotprodterms(:,chan));
   fprintf('Dot product with auxiliary channel %d is %f\n',chan,dotprod(chan));
end

figure(2);
for chan = 1:nauxchan
   subplot(nauxchan,1,chan);
   plot(ts,dotprodterms(:,chan));
   legendstr = sprintf('Dot product terms for channel %d',chan);
   legend(legendstr);
end



%{
figure(3);
edges = [0:0.01:1];
nbinhist = length(edges);
dotprodcounts = zeros(nauxchan,nbinhist);
for chan = 1:nauxchan
   dotprodcounts(chan,:) = hist(abs(dotprodterms(:,chan)),edges);
   subplot(nauxchan,1,chan);
   semilogy(edges(1:nbinhist),dotprodcounts(chan,:),'o');
%   loglog(edges(1:nbinhist),dotprodcounts(chan,:),'o');
   hold on
   dist_expect = nbintot*(edges(2)-edges(1)) * besselk(0,edges*sqrt(nbintot)) * sqrt(nbintot) *2/pi;
%   dist_expect = nbintot/(edges(2)-edges(1)) * besselk(0,edges*sqrt(nbintot)) / (pi);
%   dist_expect = nbintot*(edges(2)-edges(1)) * besselk(0,edges*sqrt(nbintot)) / (pi*sigma_strain*sigma_auxchan(chan));
   plot(edges,dist_expect,'color','green');
   xlim([min(edges) max(edges)]);
   ylim([0.1 nbintot]);
   titlestr = sprintf('Distribution of dot product terms for aux channel %d',chan);
   title(titlestr);
   legend('Measured distribution','Ideal distribution (no contamination)');
end				
%}