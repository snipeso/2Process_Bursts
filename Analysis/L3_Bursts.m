%%% script to load data pertaining to bursts. Quite slow!

clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Tasks = P.Tasks;

fs = 250;

TitleTag = 'Bursts';

%%% Load data
DataPath = fullfile(Paths.Data, 'EEG', 'Bursts');

[BurstTable, Missing, Durations] = loadAllBursts(DataPath, Participants, Sessions, Tasks);


% Use durations in minutes rather than seconds
Durations = Durations/60;


%% Pool data

Bands = {'Theta', 'Alpha'};
Variables = {'Mean_coh_amplitude', 'nPeaks', 'Duration', 'globality_bursts'};
VariableNames = {'Amplitude', 'TotCycles', 'Duration', 'Globality'};
zScore = {true, false};


for Indx_Z = 1:numel(zScore)
    Z = zScore{Indx_Z};
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
        save(fullfile(Paths.Pool, [TitleTag, '_', Score, VariableNames{Indx_V}, '.mat']), 'Data')
    end
end


% do tot
Data = bursttable2matrix(BurstTable, Missing, Durations, 'Tot', Participants, Sessions, Tasks, false);
save(fullfile(Paths.Pool, [TitleTag, '_rawTotBursts.mat']), 'Data')


% do percent of recording



%% assemble topographic data

load(fullfile(Paths.Analysis, 'Chanlocs123.mat'))
All_Amps = nan(numel(Participants), numel(Sessions), numel(Tasks), numel(Chanlocs), 2);
All_Tots = All_Amps;

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            for Indx_B = 1:2 % loop through frequencies

                % load data
                T = BurstTable(BurstTable.FreqType == Indx_B & strcmp(BurstTable.Participant, Participants{Indx_P}) & ...
                    strcmp(BurstTable.Session, Sessions{Indx_S}) & strcmp(BurstTable.Task, Tasks{Indx_T}), :);

                if isempty(T)
                    continue
                end

                % allign all the channels involved with their average
                % amplitudes and number of peaks
                Ch = [T.Coh_Burst_Channels{:}];
                Amps = [T.Coh_amplitude{:}];
                Tots = [T.Coh_Burst_nPeaks{:}];

                % for each channel, find out how many were involved in
                % theta and alpha
                for Indx_Ch = 1:numel(Chanlocs)

                    Ch_Mean = mean(Amps(Ch==Indx_Ch), 'omitnan');
                    Ch_Tot = sum(Tots(Ch==Indx_Ch), 'omitnan')/Durations(Indx_P, Indx_S, Indx_T);

                    if Ch_Tot == 0
                        Ch_Mean = 0;
                    end

                    All_Amps(Indx_P, Indx_S, Indx_T, Indx_Ch, Indx_B) = Ch_Mean;
                    All_Tots(Indx_P, Indx_S, Indx_T, Indx_Ch, Indx_B)  = Ch_Tot;
                end
            end
        end
    end
    disp(['Finished ', Participants{Indx_P}])
end

% save
Data = All_Amps;
save(fullfile(Paths.Pool, [TitleTag, '_Topo_Amplitude.mat']), 'Data', 'Chanlocs')

Data = All_Tots;
save(fullfile(Paths.Pool, [TitleTag, '_Topo_Tots.mat']), 'Data', 'Chanlocs')


% burst demographics BL pre, BL post, SD1, SD8. # bursts, globality,
% duration (s). cycles x min. [median and IQ range]




