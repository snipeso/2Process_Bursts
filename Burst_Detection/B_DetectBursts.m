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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get bursts

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};


    % folder locations
    % Source = fullfile(Paths.Preprocessed, 'Clean', 'Waves', Task);
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
    Source_Filtered = fullfile(Paths.Preprocessed, 'Clean', 'Waves_Filtered', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task);
    Destination = fullfile(Paths.Data, 'EEG', 'Bursts_All', Task);

    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end

    Content = getContent(Source);
    for Indx_F = 1:numel(Content)

        % load components data
        Filename_Source = Content{Indx_F};
        Filename_Filtered = replace(Filename_Source, 'Clean.mat', 'Filtered.mat');
        Filename_Destination = replace(Filename_Source, 'Clean.mat', 'Bursts.mat');
        Filename_Cuts = replace(Filename_Source, 'Clean.mat', 'Cuts.mat');
        Levels = split(Filename_Destination, '_');

        if exist(fullfile(Destination, Filename_Destination), 'file') && ~Refresh
            disp(['Skipping ', Filename_Destination])
            continue
        else
            disp(['Loading ', Filename_Source])
        end

        M = load(fullfile(Source, Filename_Source), 'EEG');
        EEG = M.EEG;

        fs = EEG.srate;

        % get timepoints without noise
        NoiseEEG = nanNoise(EEG, fullfile(Source_Cuts, Filename_Cuts));
        Keep_Points = ~isnan(NoiseEEG.data(1, :));

        %     % further remove beginning and end, so only task time
        %     if any(strcmp({NoiseEEG.event.type}, Triggers.Start))
        %         Start = round(NoiseEEG.event(strcmp({NoiseEEG.event.type}, Triggers.Start)).latency);
        %         Keep_Points(1:Start) = 0;
        %     end
        %
        %     if any(strcmp({NoiseEEG.event.type}, Triggers.End))
        %         End = round(NoiseEEG.event(strcmp({NoiseEEG.event.type}, Triggers.End)).latency);
        %         Keep_Points(End:end) = 0;
        %     end

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
        [AllBursts, AllPeaks] = getAllBursts(EEG, FiltEEG, ...
            Clean_BT, Dirty_BT, IsoPeak_Thresholds, Bands, Keep_Points);

        EEG.data = []; % only save the extra ICA information

        % save structures
        parsave(Destination, Filename_Destination, AllBursts, AllPeaks, EEG)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% functions

function parsave(Destination, Filename_Destination, AllBursts, AllPeaks, EEG)

save(fullfile(Destination, Filename_Destination), "AllBursts", "EEG")
Filename = replace(Filename_Destination, 'Bursts.mat', 'IsoPeaks.mat');
save(fullfile(Destination, Filename),"AllPeaks", "EEG")
end

