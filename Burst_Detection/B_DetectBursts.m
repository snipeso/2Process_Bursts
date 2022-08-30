% loads in filtered data, finds the bursts in each channel, removes the
% overlapping ones.

clear
clc
close all

Info = getInfo();

Paths = Info.Paths;
Bands = Info.Bands;
Triggers = Info.Triggers;
BandLabels = fieldnames(Bands);

Tasks = Info.Tasks;
Refresh = false;

% Parameters for bursts TODO: check relative importance of either
Clean_BT = Info.Clean_BT;
Dirty_BT = Info.Dirty_BT;
Min_Peaks = Info.Min_Peaks;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get bursts

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};

    % folder locations
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task); % normal data
    Source_Filtered = fullfile(Paths.Preprocessed, 'Clean', 'Waves_Filtered', Task); % extremely filtered data
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task); % timepoints marked as artefacts
    Destination = fullfile(Paths.Data, 'EEG', 'Bursts_AllChannels', Task);

    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end

    Content = getContent(Source);
    for Indx_F = 1:numel(Content)

        % load data
        Filename_Source = Content{Indx_F};
        Filename_Filtered = replace(Filename_Source, 'Clean.mat', 'Filtered.mat');
        Filename_Destination = replace(Filename_Source, 'Clean.mat', 'Bursts.mat');
        Filename_Cuts = replace(Filename_Source, 'Clean.mat', 'Cuts.mat');

        if exist(fullfile(Destination, Filename_Destination), 'file') && ~Refresh
            disp(['Skipping ', Filename_Destination])
            continue
        else
            disp(['Loading ', Filename_Source])
        end

        M = load(fullfile(Source, Filename_Source), 'EEG');
        EEG = M.EEG;

        % get timepoints without noise
        NoiseEEG = nanNoise(EEG, fullfile(Source_Cuts, Filename_Cuts));
        Keep_Points = ~isnan(NoiseEEG.data(1, :));

        % need to concatenate structures
        FiltEEG = EEG;
        FiltEEG.Band = [];

        for Indx_B = 1:numel(BandLabels) % get bursts for all provided bands

            % load in filtered data
            Band = Bands.(BandLabels{Indx_B});
            F = load(fullfile(Source_Filtered, BandLabels{Indx_B}, Filename_Filtered));
            FiltEEG(Indx_B) = F.FiltEEG;
        end

        % get bursts in all data
        AllBursts = getAllBursts(EEG, FiltEEG, Clean_BT, Min_Peaks, Bands, Keep_Points);

        EEG.data = []; % only save the extra ICA information

        % save structures
        parsave(Destination, Filename_Destination, AllBursts, EEG)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% functions

function parsave(Destination, Filename_Destination, AllBursts, EEG)
save(fullfile(Destination, Filename_Destination), "AllBursts", "EEG")
end

