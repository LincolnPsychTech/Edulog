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
sps = 5; % Set samples per second to typical value

for l = cellfun(@string, loggers)
    switch l
        
        case 'GSR'
            x = 1:dur*5; % x values for generated curve
            raw = sin(...
                x ... % Start with x values
                ./( sps.*rand(1,dur*sps) ) ... % Divide by 5 with random variation, no adjust (set wavelength to 5s)
                ) ... % Take sin
                + rand(1,dur*sps) ... % Add <1 random variation
                + 4; % Shift up to GSR acceptable range
            evmask = 1 + 0.5.*sin( ... % Mask for events: sin wave of variance between 0.5 and 1.5....
                0:pi/floor(sps*5/2):2*pi ... % ...covering a range from 0 to 2pi, with 25 intervals (5s)
                );
            for e = find(ev) % For each event
                for n = 1:min(length(evmask), length(raw)-e) % For each point following that event, up until either the length of ev mask or the end of the data
                    raw(e+n) = evmask(n) * raw(e+n); % Apply evmask
                end
            end
            
            
        case 'EKG'
            raw = smooth(rand(1,dur*sps).*500 - 250)' + 2000; % <+-500 random variation, shifted up to normal EKG range
            beatmask = 1 + 0.05.*sin( ... % Mask for beats: sin wave of variance between 0.95 and 1.05....
                -pi:pi/1.5:pi ... % ...covering a range from -pi to pi, with 3 intervals (0.8s)
                ); 
            beatmask(beatmask == min(beatmask)) = min(beatmask) * 0.9; % Make drop more pronounced
            bi = 0.9; % Beat interval
            x = bi:bi:dur; % x values to start with
            xmask = rand(1, length(x)).*bi - bi*0.2; % Create random mask to apply +- half a beat interval random variation
            beati = round(( x + xmask ).*5); % Apply xmask and convert to indices
            for e = find(ev) % For each event...
                beatstore = beati(beati > e & beati < e+sps*5); % Isolate the area of beati which this event would cover
                if ~isempty(beatstore)
                    bx = min(beatstore./sps):bi/1.2:max(beatstore./sps); % x values for new beats
                    bxmask = rand(1, length(bx)).*0.2 - 0.1; % Create random mask to apply +-20% beat interval random variation
                    newbeats = round(sps.*(bx + bxmask)); % Make new array of beats with smaller beat interval
                    beati(beati > e & beati < e+sps*5) = []; % Clear beats from original location covered by e
                    beati = sort([beati newbeats]); % Replace with new beats
                end
            end
            for b = beati % For each beat
                for n = 1:min(length(beatmask), length(raw)-b) % For each point following that beat, up until either the length of beatmask or the end of the data
                    raw(b+n) = beatmask(n) * raw(b+n); % Apply beatmask
                end
            end
            
            
        case 'Pulse'
            raw = zeros(1, dur*sps);
            bi = 0.85; % Beat interval
            x = bi:bi:dur; % x values to start with
            xmask = rand(1, length(x)).*0.2 - 0.1; % Create random mask to apply +-20% beat interval random variation
            beati = round(( x + xmask ).*5); % Apply xmask and convert to indices
            for e = find(ev) % For each event...
                beatstore = beati(beati > e & beati < e+sps*5); % Isolate the area of beati which this event would cover
                if ~isempty(beatstore)
                    bx = min(beatstore./sps):bi/1.2:max(beatstore./sps); % x values for new beats
                    bxmask = rand(1, length(bx)).*0.2 - 0.1; % Create random mask to apply +-20% beat interval random variation
                    newbeats = round(sps.*(bx + bxmask)); % Make new array of beats with smaller beat interval
                    beati(beati > e & beati < e+sps*5) = []; % Clear beats from original location covered by e
                    beati = sort([beati newbeats]); % Replace with new beats
                end
            end
            bpm = [0 (60*sps)./diff(sort(beati))];
            
            for n = 1:length(raw) % For each datapoint...
                [~, i] = min(abs( n - beati )); % Find index of closest beat
                raw(n) = bpm(i) + rand()*std(bpm) - std(bpm)/2; % Assign the corresponding bpm value to that index, with random variation
            end            
            
            
        otherwise
            raw = sin(1:dur*sps) + rand(1,dur*sps); % Sin wave with random mask
            warning(['Functionality to generate ' l{:} ' data is in progress. A sin wave with random variation has been supplied as a placeholder.']); % Deliver warning
            
            
    end
    
    for n = 1:length(data) % For each datapoint...
        data(n).(l) = raw(n); % Apply raw data
    end
end