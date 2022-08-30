% Filters data repeatedly into rather narrow bands so that it can find the
% bursts.

clear
clc
close all

Info = getInfo();
Paths = Info.Paths;
Bands = Info.Bands;

Task = 'TV';
Refresh = false;

BandLabels = fieldnames(Bands);

% Source = fullfile(Paths.Preprocessed, 'Clean', 'Waves', Task);
Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
Destination = fullfile(Paths.Preprocessed, 'Clean', 'Waves_Filtered', Task);

for Indx_B = 1:numel(BandLabels)
    if ~exist(fullfile(Destination, BandLabels{Indx_B}), 'dir')
        mkdir(fullfile(Destination, BandLabels{Indx_B}))
    end
end

Content = getContent(Source);
for Indx_F = 1:numel(Content)

    % load components data
    Filename_Source = Content{Indx_F};

    if contains(Filename_Source, 'set')
        Filename_Destination = replace(Filename_Source, 'Clean.set', 'Filtered.mat');

        if exist(fullfile(Destination, BandLabels{end}, Filename_Destination), 'file') && ~Refresh
            disp(['Skipping ', Filename_Source])
            continue
        end

        EEG = pop_loadset('filename', Filename_Source, 'filepath', Source);
    else
        Filename_Destination = replace(Filename_Source, 'Clean.mat', 'Filtered.mat');

        if exist(fullfile(Destination, BandLabels{end}, Filename_Destination), 'file') && ~Refresh
            disp(['Skipping ', Filename_Source])
            continue
        end

        m = load(fullfile(Source, Filename_Source), 'EEG');
        EEG = m.EEG;
    end
    fs = EEG.srate;

    for Indx_B = 1:numel(BandLabels)
        parBands = Bands;
        Band = parBands.(BandLabels{Indx_B});
        FiltEEG = EEG;

        % filter all the data
        FiltEEG.data = hpfilt(FiltEEG.data, fs, Band(1));
        FiltEEG.data = lpfilt(FiltEEG.data, fs, Band(2));

        FiltEEG.Band = Band;

        % save
        save(fullfile(Destination, BandLabels{Indx_B}, Filename_Destination), 'FiltEEG')
        disp(['Finished ', Filename_Destination, ' ', BandLabels{Indx_B}])
    end
end


