%./run_yearcompare.sh /ldcg/matlab_r2020b H1:PEM-EY_ADC_0_12_OUT_DQ H1 8 PEM-EY_ADC_0_12_OUT_DQ 2048 H1:CAL-DELTAL_EXTERNAL_DQ H1 8 CAL-DELTAL_EXTERNAL_DQ 16384 /home/sherman.thompson/FoldingAnalysis/O3 /home/sherman.thompson/FoldingAnalysis/foldfold_periods/Post-O2.csv
function out = channeltagconverter(ifo, name, primfoldS)


    primlocation = ifo;
    primchannel = name;

    %% This thing needs to swap in the channel name ('name') for everywhere it appears in the variables in out. It also needs to swap the IFO in too.

    out = {primlocation, primfoldS, primchannel};

end