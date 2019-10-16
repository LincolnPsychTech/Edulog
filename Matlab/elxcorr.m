function [r, lag] = elxcorr(data, correlates)
% Cross-Correlate events from Edulogger data
%
% The input "data" is a structure generated by running an Edulogger experiment,
% consisting of the following fields:
% Time: The time (s) since the start of the experiment of each sample.
% (double)
% Concern: Whether or not each sample took more than twice the specified
% sample rate to retrieve (logical)
% An additional field for each kind of Edulogger used, containing the
% measurements taken at each point in data.Time.
% 
% r is a table showing the correlation coefficient between the two fields
% denoted by its row and variable names
% lag is a table showing the lag at which the maximum correlation
% coefficient between the two fields denoted by its row and variable names
% occurred

for c = correlates % For each corrlate...
    ts.(c{:}) = [data([data.(c{:})]).Time]; % Extract timestamps of events
end

corrmat = [... % Create row of vertical pairs containing every combination of two fields
    reshape(meshgrid(correlates), 1, []); ...
	reshape(meshgrid(correlates)', 1, []) ...
    ];

r = table(... % Create a table to store r values, which has...
    'Size', repmat(length(correlates), 1, 2), ... % ...the same number of rows and columns as there are fields
    'VariableTypes', repmat("double", 1, length(correlates)), ... % ...contents of type "double"
    'VariableNames', correlates, ... % ...the strings contained in "correlates" as variable names
    'RowNames', correlates ... % ...the strings contained in "correlates" as row names
    );
lag = r; % Create an identical table to store lag

for corrs = corrmat % For each field pair...
    [tempR, tempLag] = xcorr(ts.(corrs{1}), ts.(corrs{2})); % Cross-correlate the two fields
    [~, i] = max(tempR); % Find the maximum r value
    r{corrs{1}, corrs{2}} = tempR(i); % Store the maximum r value
    lag{corrs{1}, corrs{2}} = tempLag(i); % Store the lag which gives the largest r value
end