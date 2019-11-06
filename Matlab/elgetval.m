function val = elgetval(port, varargin)
% Run specified Eduloggers for a specified duration at a specified temporal
% resolution.
%
% "port" is the port Eduloggers are connected to, this is visible on the
% Neulog API window.
% "loggers" is a one dimensional cell array, with each string specifying
% the name of a different Edulogger as described in the Neulog API
% literature:
% https://neulog.com/wp-content/uploads/2014/06/NeuLog-API-version-7.pdf
%
% The output "data" is one row of a structure generated when running an 
% Edulogger experiment, consisting of one field for each kind of Edulogger 
% used, containing the measurements taken at each point in data.Time. 
% Fieldnames should line up with the names specified in "loggers".
if iscell([varargin{:}]) % If input argument was supplied as a cell
    varargin = varargin{:}; % Remove the extraneous layer
end
load('eltypes.mat', 'eltypes'); % Load possible Edulogger types from file
loggers = varargin(contains(varargin, eltypes)); % Extract variable inputs matching valid types
if isempty(loggers) % If no valid loggers supplied...
    error('No valid Eduloggers selected'); % Throw up an error
end

preface = ['http://localhost:' num2str(port) '/NeuLogAPI?']; % Construct the string to preface any argument passed to the Eduloggers

for l = 1:length(loggers) % For each logger...
    resp = webread([preface, 'GetSensorValue:[', loggers{l}, '],[1]']); % Send command to the edulogger: The preface, a request for values and the logger type
    val.(loggers{l}) = str2num(resp(findnum(resp))); % Parse edulogger response to isolate value
end


    function i = findnum(str)
        % Find values in a string which can be converted to numeric without
        % returning an error.
        %
        % "str" is the string in which to find numbers
        %
        % "i" is a logical matrix with the indices of numbers in the string as
        % true.
        
        i = find(... % Find indices at which str is equal to...
            str == '0' | ... % ...0
            str == '1' | ... % ...1
            str == '2' | ... % ...2
            str == '3' | ... % ...3
            str == '4' | ... % ...4
            str == '5' | ... % ...5
            str == '6' | ... % ...6
            str == '7' | ... % ...7
            str == '8' | ... % ...8
            str == '9' | ... % ...9
            str == '.' | ... % ...a decimal point
            str == '-'   ... % ...a minus sign
            );
    end
end