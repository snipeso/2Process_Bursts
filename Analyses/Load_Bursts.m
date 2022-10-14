clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks;
TaskColors = P.TaskColors;

Refresh = false;
fs = 250;

TitleTag = 'Bursts';

%%% Load data

MegaTable_Filename = 'RRT_AllBursts.mat';
TablePath = fullfile(Paths.Data, 'EEG', 'Bursts_Table');
DataPath = fullfile(Paths.Data, 'EEG', 'Bursts');

if exist(fullfile(TablePath, MegaTable_Filename), 'file') && ~Refresh
    load(fullfile(TablePath, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations')
else
    [BurstTable, Missing, Durations] = loadAllBursts(DataPath, Participants, Sessions, Tasks);
    save(fullfile(TablePath, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations', '-v7.3')
end

% Use durations in minutes rather than seconds
Durations = Durations/60;


%% Pool data

Bands = {'Theta', 'Alpha'};
Variables = {'Mean_coh_amplitude', 'nPeaks'};
VariableNames = {'Amplitude', 'Tots'};
zScore = {true, false};



for Indx_Z = 1:numel(zScore)
    Z = zScore(Indx_Z);
    if Z
        Score =  'zscore';
    else
        Score = 'raw';
    end

    for Indx_V = 1:numel(Variables)

        Data = nan(numel(Participants), numel(Sessions), numel(Tasks), numel(Bands));
        for Indx_B = 1:numel(Bands)
            Variable = Variables{Indx_V};
            Matrix = bursttable2matrix(BurstTable(BurstTable.FreqType == Indx_B, :), ...
                Missing, Durations, Variable, Participants, Sessions, Tasks, Z);

            Data(:, :, :, Indx_B) = Matrix;
        end

        % save

        save(fullfile(Paths.Pool, [TitleTag, '_', Score, VariableNames{Indx_V}]), 'Data')
    end
end

