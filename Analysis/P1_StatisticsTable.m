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

AllDataTable = table();

% KSS
load(fullfile(Paths.Pool, 'Questionnaires_KSS.mat'), 'Data') % P x S
zData = zScoreData(Data, 'first');

T = mat2table(Data, zData, 'KSS', P.Participants, P.Labels.Sessions);
AllDataTable = [AllDataTable; T];

[Stats, Strings] = standardStats(zData, StatsP);

AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
Labels = cat(1, Labels, 'Subjective sleepiness');
TaskLabels = cat(1, TaskLabels, 'All');


% Power
load(fullfile(Paths.Pool, 'Power_raw.mat'), 'Data') % P x S x T x B
Power = Data;
load(fullfile(Paths.Pool, 'Power_z-scored.mat'), 'Data') % P x S x T x B
zPower = Data;
T = mat2table(Power, zPower, 'Power', P.Participants, P.Labels.Sessions, P.Tasks, BandLabels);
AllDataTable = [AllDataTable; T];

for Indx_B = 1:2
    for Indx_T=1:numel(Tasks)
        Data = squeeze(zPower(:, :, Indx_T, Indx_B));
        [Stats, Strings] = standardStats(Data, StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, [BandLabels{Indx_B}, ' power']);
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end


% Burst amplitudes
load(fullfile(Paths.Pool, 'Bursts_rawAmplitude.mat'), 'Data')
Power = Data;

load(fullfile(Paths.Pool, 'Bursts_zscoreAmplitude.mat'), 'Data')
zPower = Data;

T = mat2table(Power, zPower, 'Amplitude', P.Participants, P.Labels.Sessions, P.Tasks, BandLabels);
AllDataTable = [AllDataTable; T];

for Indx_B = 1:2
    for Indx_T=1:numel(Tasks)
        Data = squeeze(zPower(:, :, Indx_T, Indx_B));
        [Stats, Strings] = standardStats(Data, StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, [BandLabels{Indx_B}, ' burst amplitude']);
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end

% Burst quantities
load(fullfile(Paths.Pool, 'Bursts_rawTotCycles.mat'), 'Data')
Power = Data;

load(fullfile(Paths.Pool, 'Bursts_zscoreTotCycles.mat'), 'Data')
zPower = Data;

T = mat2table(Power, zPower, 'Quantity', P.Participants, P.Labels.Sessions, P.Tasks, BandLabels);
AllDataTable = [AllDataTable; T];

for Indx_B = 1:2
    for Indx_T=1:numel(Tasks)
        Data = squeeze(zPower(:, :, Indx_T, Indx_B));
        [Stats, Strings] = standardStats(Data, StatsP);

        AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
        Labels = cat(1, Labels, [BandLabels{Indx_B}, ' cycles/min']);
        TaskLabels = cat(1, TaskLabels, Tasks{Indx_T});
    end
end


% other
Variables = {'Pupillometry_meanDiameter.mat', 'Pupillometry_stdDiameter.mat', ...
    'Pupillometry_zAuC.mat', 'Microsleeps_nBlinks.mat', 'Microsleeps_prcntMicrosleep.mat'};
VariableLabels = {'Pupil diameter (mean)', 'Pupil diameter (std)', 'Pupil oddball response', 'Blink rate', 'Microsleeps (%)'};

for Indx_V = 1:numel(Variables)

    load(fullfile(Paths.Pool, Variables{Indx_V}), 'Data')
    if ~contains(Variables{Indx_V}, 'zAuC')
        zData = zScoreData(Data, 'first');
    else % special case for AuC, because like power, the z-scoring was done with an additional dimention (timepoints)
        zData = Data;
        load(fullfile(Paths.Pool, 'Pupillometry_AuC.mat'), 'Data')
    end

    T = mat2table(Data, zData, VariableLabels{Indx_V}, P.Participants, P.Labels.Sessions, P.Tasks);
    AllDataTable = [AllDataTable; T];


    for Indx_T=1:2
        if numel(size(zData))<3 && Indx_T>1
            continue
        end
        [Stats, Strings] = standardStats(squeeze(zData(:, :, Indx_T)), StatsP);

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
writetable(AllDataTable, fullfile(Paths.Paper, 'AllData.csv'))