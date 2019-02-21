function [w] = EdulogLivePlot(port, sps, loggers)
close all % Close any open figures
w = EdulogPlotWindow;
w.Setup(port, sps, loggers);