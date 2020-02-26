clear all
close all

%% Initialise window
win = get(groot); % Get screen details
fig = figure(... % Create a figure
    'Position', win.ScreenSize, ... % Make figure full screen
    'KeyPressFcn', @keypress, ... % Add listener for key presses
    'UserData', struct('Key', [], 'Data', []) ...
    );
ax = axes(fig, ... % Create axis in figure
    'Position', [0 0 1 1], ... % Make axis occupy entire figure
    'XLim', win.ScreenSize([1 3]), ... % Set X axis limits to screen width (pixels)
    'YLim', win.ScreenSize([2 4]), ... % Set Y axis limits to screen height (pixels)
    'Color', [0.5 0.5 0.5], ...% Set background colour to grey
    'TickLength', [0 0] ... % Remove tick marks
    );
inst = annotation('textbox', ... % Create a textbox
    'Position', [0.1 0.1 0.8 0.8], ... % Set its position to be 10% from each screen edge
    'EdgeColor', 'none', ... % Remove outline
    'VerticalAlignment', 'middle', ... % Set vertical alignment to center
    'HorizontalAlignment', 'center', ... % Set horizontal alignment to center
    'FontSize', 40 ... % Set font size to 40
    );

%% Load stimulus
stim = struct(...
    'y', round( sin(1:1000) ), ...
    'Fs', 8192, ...
    'nBits', 16 ...
    );

%% Instructions
inst.String = "Please connect a GSR and EKG Eduloggers now. Press any key when ready.";
fig.UserData.Key = [];
while isempty(fig.UserData.Key)
    drawnow
end
inst.String = [];

%% Start sampling
inst.String = "At some point in the next minute, you will hear a loud sound which may startle you.";
drawnow
tic % Start a timer
dur = randi([15 45], 1); % Choose how long to wait before playing stimulus
data = elrun(22002, dur, 'GSR', 'EKG'); % Run the Eduloggers until the stimulus is played

%% Sound stimulus
inst.String = []; % Clear instructions
drawnow
sound(stim.y, stim.Fs, stim.nBits); % Play a brief, surprising sound

%% Continue sampling
while toc < 60 % Until the remainder of the full 60 seconds has passed
    val = elgetval(22002, 'GSR', 'EKG'); % Get values from Eduloggers
    val.Time = toc; % Record the time taken
    val.Concern = round(toc, 1) - data(end).Time > 0.4; % Did this timer stop at more than 0.4s after the last time?
    data = [data; val]; % Assign measurement to overall data structure
end

%% Close window
close(fig) % Close window

%% Record when stimulus was presented
data = elevents(data, 'Stimulus', dur);

%% Analyse data
data = elgsrsplit(data);
data = elscr(data, 'median');
data = elbeat(data);

%% Plot results
elplot(data, 'Phasic', 'EKG', 'Stimulus', 'SCR')

%% Save data
save('example_data.mat', 'data');

%% Functions
function keypress(app, event)
app.UserData.Key = event.Key; % Set the UserData of the figure to equal the key which was just pressed
end