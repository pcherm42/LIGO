function [data, addent, flag] =readget(start, endt, chanName)
    fprintf('      Entering readget with start=%d, endt=%d, chanName=%s\n',start,endt,chanName);
    record = [start endt];

    %{
        The following block is some old stuff which probably doesn't work...

        
    setenv('START', int2str(start));
    setenv('END  ', int2str(endt));
    system('echo "      START = $START"');
    system('echo "      END   = $END"');

    

    fprintf('running version without gw_data_find')

    fprintf('      Before ligo data find with start=/%s/, end=/%s/\n',int2str(start),int2str(endt));
    % advanced ligo
    if (chanName(1) == 'L')
        if (strcmp(chanName(4:end), 'DCS-CALIB_STRAIN_C01') == 1)
            fprintf('      About to call gw_data_find for L1_HOFT\n');
%            system('gw_data_find -o L -t L1_HOFT_C01 -s $START -e $END -u file > /home/reilly.penhorwood/TestFold/myFileList.txt');
        else
            fprintf('      About to call gw_data_find for L1_R\n');
%            system('gw_data_find -o L -t L1_R -s $START -e $END -u file > /home/reilly.penhorwood/TestFold/myFileList.txt');
%            system('gw_data_find -o L -t L1_R -s $START -e $END -u file');
        end
    else
        if (strcmp(chanName(4:end), 'DCS-CALIB_STRAIN_C01') == 1)
            fprintf('      About to call gw_data_find for H1_HOFT\n');
 %           system('gw_data_find -o H -t H1_HOFT_C01 -s $START -e $END -u file > /home/reilly.penhorwood/TestFold/myFileList.txt');
        else
            fprintf('      About to call gw_data_find for H1_R\n');
  %          system('gw_data_find -o H -t H1_R -s $START -e $END -u file > /home/reilly.penhorwood/TestFold/myFileList.txt');
        end
    end
    fprintf('      start: %s end: %s\n', int2str(start), int2str(endt));

    %}

    startIndex = 1;

    stringstart = string(start);
    stringend = string(endt);

    fprintf('      Calling readFrames, chanName=%s, start=%d, endt-start=%d, 1, 1\n',chanName,start,endt-start);
    if (chanName(1) == 'L')
        string_filename_segment = strjoin([string(start),string(endt),"L1.temp"],"");
        char_filename_segment = char(string_filename_segment);
        gw_command = char(strjoin(["gw_data_find -o L -t L1_R -s ",stringstart," -e ",stringend," -u file > ",string_filename_segment],""))
        system(gw_command);
        [data, addent, flag] = readFrames(char_filename_segment, chanName, start, endt-start, 1, 1);
        fprintf('      Returned from readFrames, exiting readget\n');
    else
        string_filename_segment = strjoin([string(start),string(endt),"H1.temp"],"");
        char_filename_segment = char(string_filename_segment);
        gw_command = char(strjoin(["gw_data_find -o H -t H1_R -s ",stringstart," -e ",stringend," -u file > ",string_filename_segment],""))
        system(gw_command);
        [data, addent, flag] = readFrames(char_filename_segment, chanName, start, endt-start, 1, 1);
        fprintf('      Returned from readFrames, exiting readget\n');
    end
    rm_temp_file = strjoin(["rm ",string_filename_segment],"");
    system(char(rm_temp_file));
    return;
end