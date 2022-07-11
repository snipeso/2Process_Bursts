clear
clc
close all


P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Powerpoint;
Labels = P.Labels;
StatsP = P.StatsP;
Gender = P.Gender;
Refresh = false;

Events = {'S 10', 'S 11'}; % target first
TimeLimits = [-.5 1.5];
BaseLimits = [-500 0];

ERP_Filename = 'ERP_Oddball.mat';
ERP_Source = fullfile(Paths.Data, 'EEG', 'ERP');
if ~exist(ERP_Source, 'dir')
    mkdir(ERP_Source)
end


if Refresh || ~exist(fullfile(ERP_Source, ERP_Filename), 'file')

    [ERP, fs, Chanlocs, Times] = ERPOddball(Paths, Participants, Sessions, Events, TimeLimits, BaseLimits);

    save(fullfile(ERP_Source, ERP_Filename), 'ERP', 'fs', 'Chanlocs', 'Times')
else
    load(fullfile(ERP_Source, ERP_Filename), 'ERP', 'fs', 'Chanlocs', 'Times')
end









