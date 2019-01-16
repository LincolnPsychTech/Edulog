function [test, tFig] = EdulogTest(port, dur, sps, loggers)
start = input('Press ''Enter'' to test eduloggers...\n', 's');
if isempty(start)
    testcycle = 'No';
    cont = false;
    while cont == false
        switch testcycle
            case 'No'
                test = EdulogRun(port, dur, sps, loggers);
                tFig = EdulogPlot(test, loggers);
                testcycle = questdlg('Does this data look reasonable?','Test Eduloggers','Yes','No', 'Cancel','Yes');
                close all
            case 'Yes'
                cont = true;
                close all
            case 'Cancel'
                cont = true;
                close all
                error('Edulogger test cancelled')
        end
    end
else
    error('Edulogger test cancelled')
    test = NaN;
    tFig = NaN;
end
end