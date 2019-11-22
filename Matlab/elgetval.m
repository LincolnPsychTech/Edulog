function val = elgetval(port, varargin)
% Get individual value from specified Eduloggers
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
if isempty(varargin) % If no valid loggers supplied...
    error('No valid Eduloggers selected'); % Throw up an error
end

preface = ['http://localhost:' num2str(port) '/NeuLogAPI?']; % Construct the string to preface any argument passed to the Eduloggers

for l = 1:length(varargin) % For each logger...
    resp = webread([preface, 'GetSensorValue:[', char(varargin{l}), '],[1]']); % Send command to the edulogger: The preface, a request for values and the logger type
    val.(varargin{l}) = str2num(resp(... % Find indices at which resp is equal to...
            resp == '0' | ... % ...0
            resp == '1' | ... % ...1
            resp == '2' | ... % ...2
            resp == '3' | ... % ...3
            resp == '4' | ... % ...4
            resp == '5' | ... % ...5
            resp == '6' | ... % ...6
            resp == '7' | ... % ...7
            resp == '8' | ... % ...8
            resp == '9' | ... % ...9
            resp == '.' | ... % ...a decimal point
            resp == '-'   ... % ...a minus sign
            )); 
end
end