clear all
close all

%% Initialise window
win = get(groot); % Get screen details
fig = figure(... % Create a figure
    'Position', win.ScreenSize, ... % Make figure full screen
    'KeyPressFcn', @keypress ... % Add listener for key presses
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

%% Instructions
inst.String = 'You will be asked a series of questions, on screen will be the word "True" or "False". If the word is True, please answer the question truthfully. If the word is False, please give a false answer. Once you have answered the question, press any key to move on. Press any key to begin.'; % Set instruction text
waitfor(fig, 'UserData'); % Wait for a keypress
fig.UserData = []; % Reset keypress listener
inst.String = ""; % Clear instructions
drawnow

%% Initialise baseline trials
cont = false;
while ~cont % Until a correct response is received
   bt = inputdlg('How many baseline trials to run?'); % Ask experimenter how many trials to run
   bt = str2double(bt{:}); % Convert to number
   
   if isnan(bt) % If input was not numeric...
       err = msgbox('Value must be numeric'); % Deliver prompt
       waitfor(err); % Wait for acknowledgement
   elseif bt < 4 % If input is too low...
       err = msgbox('Must perform at least 4 trials'); % Deliver prompt
       waitfor(err); % Wait for acknowledgement
   else % If input is correct...
       cont = true; % Break the loop
   end
end 

ttBase = []; % Create blank base trial table
p = 0.25; % Probability of lie
for t = 1:bt % For each base trial
    ttBase = [ttBase; struct(... % Append details for this trial to trial table
        'Question', ['Q', num2str(t)], ... % Number the question
        'Time', [NaN, NaN], ... % Placeholder variable for time of start and finish
        'Truth', ~logical(round(rand()+p-0.5)) ... % Choose whether it is true or false
        )];
end
if sum([ttBase.Truth]) == length(ttBase) % If no trials are false...
    ttBase( randi([1 length(ttBase)]) ).Truth = false; % Pick a question at random and make it false
end

%% Start baseline trials
tic % Start a timer
dtBase = []; % Create blank data table
for trial = 1:length(ttBase)
    ttBase(trial).Time(1) = toc; % Record start time
    fig.UserData = []; % Reset keypress listener
    if ttBase(trial).Truth % If this trial is truth...
        inst.String = "Truth"; % Instruct participant to tell the truth
    else % If this trial is lie...
        inst.String = "Lie"; % Instruct participant to lie
    end
    drawnow
    
    while isempty(fig.UserData) % Until a response from participant...
        val = elgetval(22002, 'GSR'); % Get GSR value from Edulogger
        val.Time = toc; % Get time
        try
            val.Concern = round(toc, 1) - data(end).Time > 0.4; % Did this timer stop at more than 0.4s after the last time?
        catch
            val.Concern = round(toc, 1) > 0.4; % If there is no last time, did it stop at more than 0.4s?
        end
        val.Truth = ttBase(trial).Truth; % Store whether event was truth or lie
        dtBase = [dtBase; val]; % Append value to data structure
        drawnow
    end
    ttBase(trial).Time(2) = toc; % Record end time
    inst.String = ""; % Clear instructions
    drawnow
    pause(0.1) % 0.1s ISI
end

dtBase = elgsrsplit(dtBase); % Split tonic and phasic GSR
for e = ttBase' % For each question...
    dtBase = elevents(dtBase, num2str(e.Question), e.Time(1)); % Append start time as event to data structure
end


%% Calculate baselines
elplot(dtBase)

truth = struct(); lies = struct();
[~, truth.Lower, truth.Upper, truth.Center] = isoutlier(abs([dtBase([dtBase.Truth]).Phasic]));
[~, lies.Lower, lies.Upper, lies.Center] = isoutlier(abs([dtBase(~[dtBase.Truth]).Phasic]));

%% Initialise test trials
cont = false;
while ~cont % Until a correct response is received
   tt = inputdlg('How many test trials to run?'); % Ask experimenter how many trials to run
   tt = str2double(tt{:}); % Convert to number
   
   if isnan(tt) % If input was not numeric...
       err = msgbox('Value must be numeric'); % Deliver prompt
       waitfor(err); % Wait for acknowledgement
   elseif tt < 4 % If input is too low...
       err = msgbox('Must perform at least 4 trials'); % Deliver prompt
       waitfor(err); % Wait for acknowledgement
   else % If input is correct...
       cont = true; % Break the loop
   end
end 

ttTest = []; % Create blank test trial table
p = 0.25; % Probability of lie
for t = 1:tt % For each base trial
    ttTest = [ttTest; struct(... % Append details for this trial to trial table
        'Question', ['Q', num2str(t)], ... % Number the question
        'Time', [NaN, NaN], ... % Placeholder variable for time of start and finish
        'Truth', ~logical(round(rand()+p-0.5)) ... % Choose whether it is true or false
        )];
end
if sum([ttTest.Truth]) == length(ttTest) % If no trials are false...
    ttTest( randi([1 length(ttTest)]) ).Truth = false; % Pick a question at random and make it false
end

%% Instructions 2
inst.String = 'You will now be asked the same questions again, but it is up to you to choose which ones you will lie about. Do not let the experimentor know you are lying, try not to make it too obvious.';
waitfor(fig, 'UserData'); % Wait for a keypress
fig.UserData = []; % Reset keypress listener
inst.String = ""; % Clear instructions
drawnow

%% Start test trials
tic % Start a timer
dtTest = []; % Create blank data table
for trial = 1:length(ttTest)
    ttTest(trial).Time(1) = toc; % Record start time
    fig.UserData = []; % Reset keypress listener
    inst.String = "..."; % Instruct participant to lie
    drawnow
    
    while isempty(fig.UserData) % Until a response from participant...
        val = elgetval(22002, 'GSR'); % Get GSR value from Edulogger
        val.Time = toc; % Get time
        try
            val.Concern = round(toc, 1) - data(end).Time > 0.4; % Did this timer stop at more than 0.4s after the last time?
        catch
            val.Concern = round(toc, 1) > 0.4; % If there is no last time, did it stop at more than 0.4s?
        end
        val.Truth = ttBase(trial).Truth; % Store whether event was truth or lie
        dtTest = [dtTest; val]; % Append value to data structure
        drawnow
    end
    dtTest(trial).Time(2) = toc; % Record end time
    inst.String = ""; % Clear instructions
    drawnow
    pause(0.1) % 0.1s ISI
end

dtTest = elgsrsplit(dtTest); % Split tonic and phasic GSR
for e = ttBase' % For each question...
    dtTest = elevents(dtTest, num2str(e.Question), e.Time(1)); % Append start time as event to data structure
end

%% Identify lies
dtTest = elevents(dtTest, ...
    "Truth", [dtTest.Phasic] < min(truth.Upper, lies.Lower), ...
    "Lies", [dtTest.Phasic] > max(truth.Upper, lies.Lower) ...
    );
elplot(dtTest, 'GSR', 'Truth', 'Lies')


%% Close
close all


%% Functions
function keypress(app, event)
app.UserData = event.Key; % Set the UserData of the figure to equal the key which was just pressed
end