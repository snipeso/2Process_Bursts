% creates big table with all the stats together

clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load parameters

P = analysisParameters();
Paths = P.Paths;
Tasks = P.Tasks;
StatsP = P.StatsP;
BandLabels = fieldnames(P.Bands);

AllStats = table();
Labels = {};
TaskLabels = {};

VariableNames = {'Sleep', 'Extended Wake', 'WMZ'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

% KSS
load(fullfile(Paths.Pool, 'Questionnaires_KSS.mat'), 'Data')
Data = zScoreData(Data, 'first');
[Stats, Strings] = standardStats(Data, StatsP);

AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
Labels = cat(1, Labels, 'Subjective sleepiness');
TaskLabels = cat(1, TaskLabels, 'All');


% Power
load(fullfile(Paths.Pool, 'Power_z-scored.mat'), 'Data')
Power = Data;
for Indx_B = 1:2
    for Indx_T=1:numel(Tasks)
        Data = squeeze(Power(:, :, Indx_T, Indx_B));
        [Stats, Strings] = standardStats(Data, StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, [BandLabels{Indx_B}, ' power']);
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end


% Burst amplitudes
load(fullfile(Paths.Pool, 'Bursts_zscoreAmplitude.mat'), 'Data')
Power = Data;
for Indx_B = 1:2
    for Indx_T=1:numel(Tasks)
        Data = squeeze(Power(:, :, Indx_T, Indx_B));
        [Stats, Strings] = standardStats(Data, StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, [BandLabels{Indx_B}, ' burst amplitude']);
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end

% Burst quantities
load(fullfile(Paths.Pool, 'Bursts_zscoreTotCycles.mat'), 'Data')
Power = Data;
for Indx_B = 1:2
    for Indx_T=1:numel(Tasks)
        Data = squeeze(Power(:, :, Indx_T, Indx_B));
        [Stats, Strings] = standardStats(Data, StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, [BandLabels{Indx_B}, ' cycles/min']);
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run stats

% other
Variables = {'Pupillometry_meanDiameter.mat', 'Pupillometry_stdDiameter.mat', ...
    'Microsleeps_nBlinks.mat', 'Microsleeps_prcntMicrosleep.mat'};
VariableLabels = {'Pupil diameter (mean)', 'Pupil diameter (std)', 'Blink rate', 'Microsleeps (%)'};

for Indx_V = 1:numel(Variables)
    
    load(fullfile(Paths.Pool, Variables{Indx_V}), 'Data')
    Data = zScoreData(Data, 'first');
    for Indx_T=1:2
        [Stats, Strings] = standardStats(squeeze(Data(:, :, Indx_T)), StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, VariableLabels{Indx_V});
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end

AllStats.Labels = Labels;
AllStats.Task = TaskLabels;

AllStats = AllStats(:, [4, 5, 1:3]);

%% Table 1

writetable(AllStats, fullfile(Paths.Paper, 'AllStats.xlsx'))
