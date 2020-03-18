function data = eldummy(dur, adj, varargin)
% Function to emulate Edulogger data as produced when using @elrun. Data is 
% generated via commonly used mathematical functions which are easily 
% identifiable, as such this function should not and can not be used to
% believably falsify data. It is intended for testing experiment code and
% for teaching students to work with Edulogger data.
% dur = Experiment duration in seconds
% adj = Adjustment, how often should events happen? Relative to 1 (greater
% than 1 in high groups, less than 1 in low groups)
% varargin = Which Eduloggers to gather data from

load('eltypes.mat', 'eltypes'); % Load possible Edulogger types from file
loggers = varargin(contains(varargin, eltypes)); % Extract variable inputs matching valid types
if isempty(loggers) % If no valid loggers supplied...
    error('No valid Eduloggers selected'); % Throw up an error
end

data = struct(); % Blank data strcture
for n = 1:dur*5 % For each pretend sample
    data(n).Time = n/5 + (rand()-0.5)/5; % Generate a time with random variation
    data(n).Concern = false; % Pretend timing was fine
end

ev = false(1, length(data)); % Blank event logical matrix
i = floor( rand(1, round(adj*dur/30)) .* dur*5 ); % Event every roughly 30s (adjusted according to adj)
i(i == 0) = 1; % Index must be at least 1
ev(i) = true; % Create events at that index
data = elevents(data, "ExampleEvent", ev); % Apply event data to data structure

x = 1:dur*5; % x values for any generated curves
for l = cellfun(@string, loggers)
    switch l
        case 'GSR'
            raw = sin(...
                x ... % Start with x values
                ./( 5.*rand(1,dur*5) ) ... % Divide by 5 with random variation, no adjust (set wavelength to 5s)
                ) ... % Take sin
                + rand(1,dur*5) ... % Add <1 random variation
                + 4; % Shift up to GSR acceptable range
            evmask = 1 + 0.5.*sin( ... % Mask for events: sin wave of variance between 0.5 and 1.5....
                0:pi/12:2*pi ... % ...covering a range from 0 to 2pi, with 25 intervals (5s)
                );
            for e = find(ev) % For each event
                for n = 1:min(length(evmask), length(raw)-e) % For each point following that event, up until either the length of ev mask or the end of the data
                    raw(e+n) = evmask(n) * raw(e+n); % Apply evmask
                end
            end
            
            
        case 'EKG'
            raw = smooth(rand(1,dur*5).*500 - 250)' + 2000; % <+-500 random variation, shifted up to normal EKG range
            beatmask = 1 + 0.05.*sin( ... % Mask for beats: sin wave of variance between 0.95 and 1.05....
                -pi:pi/1.5:pi ... % ...covering a range from -pi to pi, with 3 intervals (0.8s)
                ); 
            beatmask(beatmask == min(beatmask)) = min(beatmask) * 0.9; % Make drop more pronounced
            beati = floor( rand(1, round(dur/0.9)) .* dur*5 ); % beat every roughly 0.9s
            for e = find(ev) % For each event...
                beati = [beati, e + floor( rand(1, round( 10/(adj^-2) )) .* 50 )]; % Add additional beats after event
            end
            for b = beati % For each beat
                for n = 1:min(length(beatmask), length(raw)-b) % For each point following that beat, up until either the length of beatmask or the end of the data
                    raw(b+n) = beatmask(n) * raw(b+n); % Apply beatmask
                end
            end
            
            
        otherwise
            raw = sin(1:dur*5) + rand(1,dur*5); % Sin wave with random mask
            warning(['Functionality to generate ' l{:} ' data is in progress. A sin wave with random variation has been supplied as a placeholder.']); % Deliver warning
            
            
    end
    
    for n = 1:length(data) % For each datapoint...
        data(n).(l) = raw(n); % Apply raw data
    end
end