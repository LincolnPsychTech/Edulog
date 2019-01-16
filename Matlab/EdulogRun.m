function output = EdulogRun(port, dur, sps, loggers)


addpath(genpath('Data'))

if exist('C:\neulog_api', 'dir')
    error('Neulog API not found, please <a href="https://neulog.com/software/">install</a>.')
end

%% Essential checks
if ~isnumeric(port)
    error('Port number (port) must be numeric')
end

switch isnumeric(sps)
    case true
        if sps > 5
            error('SPS exceeds max temporal resolution, please choose a value lower than 5')
        elseif sps < 0
            error('Cannot take fewer than 0 samples per second')
        end
    case false
        error('Samples per second (sps) must be numeric')
end

if ~isnumeric(dur)
    error('Duration (dur) must be a numeric value')
end


%% Run edulogger
preface = ['http://localhost:' num2str(port) '/NeuLogAPI?'];

for n = 1:dur*sps %for each sample
    tic
    while toc < 1/sps %until 1sps^-1 has elapsed
        for l = 1:length(loggers) %for each logger
            data.(loggers{l}){n} = webread([preface, 'GetSensorValue:[', loggers{l}, '],[1]']);
        end
        %data.GSR{n} = webread([preface, 'GetSensorValue:[GSR],[1]']); %take GSR
        %data.Pulse{n} = webread([preface, 'GetSensorValue:[Pulse],[1]']); %take Pulse
        data.Time(n) = toc; %take Time
        data.Concern(n) = round(toc, 1) > 2/sps; %did this sample take more than twice the desired time to retrieve?
    end
end

%% Transform data
output=struct();
data.Time = cumsum(data.Time); %convert time to a cumulative sum
for n = 1:dur*sps %for each sample
    for l = 1:length(loggers) %for each logger
        output(n).(loggers{l}) = str2num(data.(loggers{l}){n}(findnum(data.(loggers{l}){n}))); %extract numeric value and save in output structure
    end
    %output(n).GSR = str2num(data.GSR{n}(findnum(data.GSR{n}))); %extract numeric value from GSR and save in output structure
    %output(n).Pulse = str2num(data.Pulse{n}(findnum(data.Pulse{n}))); %extract numeric value from Pulse and save in output structure
    output(n).Time = data.Time(n); %save timestamp to output structure
    output(n).Concern = data.Concern(n); %save Concern to output structure
end
end