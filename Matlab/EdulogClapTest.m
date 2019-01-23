function [test, tFig] = EdulogClapTest(port, dur, sps, loggers)

%% Essential checks
if dur < 15
    error('Duration must be at least 15 seconds to allow for peaks to be visible.')
end

%% Run
interval = 5 + rand()*(dur - 10); %calculate interval before beep to allow time for peaks to be visible
parfor i = 1 %without pausing execition
    start(timer( ... %start a timer
        'StartDelay', interval, ... %wait for the interval
        'TimerFcn', 'sound(sin(1:5000), 10*1000)' ... %play a loud and annoying sound
        ));
end
test = EdulogRun(port, dur, sps, loggers); %meanwhile start gathering data
for n = 1:dur*sps
    test(n).Event = false;
end
i = round(interval*sps); %transform interval to index
test(i).Event = true;
tFig = EdulogPlot(test, loggers);