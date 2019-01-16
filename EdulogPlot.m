function fig = EdulogPlot(data, loggers)
addpath(genpath('Plotting'))

sDim = get(0,'screensize');

y = [];
for l = 1:length(loggers)
    y = [y; [data.(loggers{l})]];
end

close all
fig = figure;
g = gramm('x',[data.Time], 'y',y);
g.set_names('x','Time (s)', 'y','');
g.facet_grid(loggers', [], 'scale','free');
g.geom_line();
g.draw();
fig.Position([2,4]) = [100, sDim(4) - 200];
fig.Position([1,3]) = [200, sDim(3) - 400];
