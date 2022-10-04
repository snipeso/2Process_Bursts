% This script identifies the blinks in each recording, and longer
% "microsleeps" across time.


clear
clc
close all


P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = {'Fixation', 'Oddball'};
Colors = P.TaskColors(1:2, :);
Refresh = false;



if 

