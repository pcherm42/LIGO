ID = fopen('zeroreader_imput.temp', 'r');
filelist = textscan(ID, '%s');
fclose(ID);

files = filelist{1};

writer = fopen('statuses.temp', 'w');

length(files)

for n = 1:length(files)

                
    file = string(files(n));
    filedat = load(file);
    data = filedat.avgData;
    maxmin= abs(max(data) - min(data))

    if maxmin == 0
        stat = 1;
    else
        stat = 0;
    end

    fprintf(writer, '%d\n',stat);

end

fclose(writer);