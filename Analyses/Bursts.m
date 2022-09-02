% Plot burst properties over time, topographies, and statistics for the
% paper

clear
clc
close all


P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
Labels = P.Labels;
StatsP = P.StatsP;


Refresh = false;
fs = 250;


%%% Load data

MegatTable_Filename = 'RRT_AllBursts.mat';
Path = fullfile(Paths.Data, 'EEG', 'Bursts_Table');

if exist(fullfile(Path, MegatTable_Filename), 'file') && ~Refresh
    load(fullfile(Path, MegatTable_Filename), 'BurstTable', 'Missing', 'Durations')
else
    [BurstTable, Missing, Durations] = loadAllBursts(Path, Participants, Sessions, Tasks);
    save(fullfile(Path, MegatTable_Filename), 'BurstTable', 'Missing', 'Durations')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots

%% Figure X-Y Amplitude vs Quantity across sleep deprivation




















