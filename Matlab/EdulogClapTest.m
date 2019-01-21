function [test, tFig, start] = EdulogClapTest(port, dur, sps, loggers)

%% Essential checks
if dur < 15
    error('Duration must be at least 15 seconds to allow for peaks to be visible.')
end

%% Run
interval = 5 + rand()*(dur - 5); %calculate interval before beep to allow time for peaks to be visible
[test, start] = EdulogRun(port, dur, sps, loggers); %start gathering data
waitfor(start,'Started');
pause(interval) %wait for the interval
sound(sin(1:5000), 10*1000) %play a loud and annoying sound
for n = 1:dur*sps
    test(n).Event = false;
end
i = round(interval*sps); %transform interval to integer
test(i).Event = true;
tFig = EdulogPlot(test, loggers);