function data = eldummy(dur, adj, varargin)

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

for l = cellfun(@string, loggers)
    switch l
        case 'GSR'
            raw = sin((1:dur*5)./(5.*rand(1,dur*5))) + rand(1,dur*5) + 4; % Sin wave at radomly varying frequency with noise mask, shifted up to look like GSR
            evmask = sin(0:pi/12:2*pi).* 0.5 + 1; % Mask for events: sin wave adjusted upwards
            for e = find(ev) % For each event
                for n = 1:min(length(evmask), length(raw)-e) % For each point following that event, up until either the length of ev mask or the end of the data
                    raw(e+n) = evmask(n) * raw(e+n); % Apply evmask
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