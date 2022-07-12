function [ERPs, fs, Chanlocs, Times] = ERPOddball(Paths, Participants, Sessions, Events, TimeLimits, BaseLimits)

Task = 'Oddball';
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task);
Path = fullfile(Paths.Preprocessed, 'Clean', 'ERP', Task);

ERPs = nan(numel(Participants), numel(Sessions), numel(Events));



for Indx_P = 1:numel(Participants)

    for Indx_S = 1:numel(Sessions)

        Filename_Source = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Clean.mat'}, '_');
        Filename_Cuts = replace(Filename_Source, 'Clean.mat', 'Cuts.mat');
        if ~exist(fullfile(Path, Filename_Source), 'file')
            warning(['Skipping ', Filename_Source])
            continue
        end

        load(fullfile(Path, Filename_Source), 'EEG');
        Chanlocs = EEG.chanlocs;
        fs = EEG.srate;

        StimTypes = {EEG.event.type}; % all trigger types
        StimTypes = StimTypes(ismember(StimTypes, Events)); % trigger types that define epochs

        % clean EEG
        EEG = nanNoise(EEG, fullfile(Source_Cuts, Filename_Cuts));

        for Indx_E = 1:numel(Events)

            % epoch EEG
            epoEEG = pop_epoch(EEG, Events(Indx_E), TimeLimits);
            epoEEG = pop_rmbase(epoEEG, BaseLimits);

            Times = epoEEG.times;
            nPoints = numel(Times);

            Data = epoEEG.data;

            Data = squeeze(mean(Data, 3, 'omitnan'));
            ERPs(Indx_P, Indx_S, Indx_E, 1:numel(Chanlocs), 1:nPoints) = Data;
        end
    end
    clc
    disp(['Finished ', Filename_Source])
end