% Scripts on all the questionnaire outputs

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
fs = 250;
Task = 'Fixation';

Results = fullfile(Paths.Results, 'EEG', 'Bursts');
if ~exist(Results, 'dir')
    mkdir(Results)
end
TitleTag = 'Bursts';

MegatTable_Filename = [Task, 'AllBursts.mat'];

Path = fullfile(Paths.Data, 'EEG', 'Bursts_Table');
Splits = 20; % in minutes
[AllBursts, AllMissing] = loadTVBursts(Path, Splits);

