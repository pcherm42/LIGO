%example call = audiomaker(H1_CAL-DELTAL_EXTERNAL_DQ_sum.mat, ycleaned, 16384)
function one = audiomaker(filename, varname, FS)
    name = strcat(filename, "_", varname, ".wav");
    f = load(filename);
    uncleandata = f.(varname);
    data = (uncleandata - min(uncleandata)) / ( max(uncleandata) - min(uncleandata) )*2.-1.;
    audiowrite(name,data,FS);

    one =1;