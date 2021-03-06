function [data] = elliveplot(port, varargin)

load('eltypes.mat', 'eltypes'); % Load possible Edulogger types from file
loggers = varargin(contains(varargin, eltypes)); % Extract variable inputs matching valid types
if isempty(loggers) % If no valid loggers supplied...
    error('No valid Eduloggers selected'); % Throw up an error
end


%% Essential checks
if ~isnumeric(port) % If the port given is not a number...
    error('Port number (port) must be numeric') % Deliver an error
end

%% Create & setup a blank figure
sDim = get(0,'screensize'); % Get screensize

fig = figure(... % Create figure
    'Name', 'Edulog Data', ... % Name figure
    'NumberTitle', 'off', ... % Remove "Figure 1" label
    'Color', 'white', ... % White background
    'Position', [200, 100, sDim(3) - 400, sDim(4) - 200] ... % Resize to the height of the screen - 200
    );


for L = 1:length(loggers)
    % Setup axis
    ax{L} = subplot(...
        min(length(loggers), 3), ... % Determine number of rows (max 3)
        ceil(length(loggers)/3), ... % Determine number of columns
        L ... % Choose sub-plot to draw in
        ); 
    ax{L}.Position([1,3]) = [0.1, 0.8]; % Position plot
    ax{L}.XLabel.String = 'Time (s)'; % Label x-axis
    ax{L}.YLabel.String = loggers{L}; % Label y-axis
    set(ax{L}, ...
        'FontName', 'Verdana', ... % Change font
        'Color', [0.98, 0.98, 1], ... % Axis background
        'XGrid', 'on', ... % Add vertical gridlines
        'XLim', [0, 30], ... % Set axis limits
        'YGrid', 'on', ... % Add horizontal gridlines
        'GridColor', 'white', ... % Make gridlines white
        'GridAlpha', 1, ... % Make gridlines opaque
        'NextPlot', 'add' ...
        );
    
    ln{L} = line(ax{L}, ... % Plot data
        'XData', [0], ... % X data is time
        'YData', [0], ... % Y data is Edulogger values
        'Color', [42, 107, 211]./255, ... % Set colour to royal blue
        'LineWidth', 2 ... % Make lines 2 thick
        );
end

%% Run edulogger
tic % Start a timer
data = []; % Blank array to output data into
while ishandle(fig)
    val = elgetval(port, loggers); % Get value(s) from Edulogger(s)
    val.Time = toc; % Record the time taken
    try
        val.Concern = round(toc, 1) - data(end).Time > 0.4; % Did this timer stop at more than 0.4s after the last time?
    catch
        val.Concern = round(toc, 1) > 0.4; % If there is no last time, did it stop at more than 0.4s?
    end
    data = [data; val]; % Assign measurement to overall data structure
    %% Plot results
    for L = 1:length(loggers) % For each logger...
        set(ln{L}, ...
            'YData', [ln{L}.YData, val.(loggers{L})], ... % Update y data
            'XData', [ln{L}.XData, val.Time] ... % Update x data
            );
        if length(data) > 2 && max([data.Time]) > 25 % After the first 25s...
            ax{L}.XLim = ax{L}.XLim + diff([data(end-1:end).Time]); % Start scrolling the x axis
        end
    end
    
    drawnow
    end
end