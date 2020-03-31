function newpath = elinstall()
% Function to install Edulogger functions. Functions will be installed to a
% subfolder of the Matlab user path called "Edulog", the path for this
% folder will be outputted.

elpath = erase( mfilename('fullpath'), '\elinstall' ); % Get path of current function
elfiles = dir(elpath); % Get details of all files in same folder as this function
elfiles(1:2) = []; % Remove . and .. from beginning of file names
newpath = [userpath '\Edulog']; % New path to store functions in based on userpath

if ~exist(newpath, 'dir') % If there is no Edulog folder within the user path...
    mkdir(newpath) % Create subfolder within userpath called "Edulog"
else % If there is already an Edulog folder...
    delans = questdlg('There is already a folder called "Edulog" added to the user path, replace existing files?', 'Path Conflict', ...
        'Yes', 'Cancel', 'Yes'); % Ask user if they want to delete the existing path
    if ~strcmp(delans, 'Yes') % If they answered yes...
        error('Install terminated by user');
    end
end

inst = [...
    'addpath(''' newpath ''');' ... % Write command to add new folder to path
    'disp(''Edulogger functions loaded.'');' % Write command to notify user that Edulogger functions loaded successfully
    ];
if ~contains(fileread([userpath '\startup.m']), inst) % If commands are not already in startup file...
    su = fopen([userpath '\startup.m'], 'a'); % Access/create startup file
    fwrite(su, inst); % Write commands to startup file
    fclose(su); % Close startup file
end

for f = elfiles' % For each file...
    copyfile([f.folder, '\', f.name], [newpath, '\', f.name], 'f'); % Copy it to the subfolder within userpath
end
disp('Files copied successfully. Edulogger functions will be added to path when Matlab next restarts.'); % Print success message
