% converts EEG to EDF

clear
clc
close all

Refresh = false;
Task = 'Oddball';
Source = fullfile('E:\Data\Preprocessed\Clean\Waves\', Task);

Destination = fullfile('E:\Public\2Process_Bursts\EEG', Task);
MetadataDestination = fullfile('E:\Public\2Process_Bursts\Metadata');

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

if ~exist(MetadataDestination, 'dir')
    mkdir(MetadataDestination)
end

Files = getContent(Source);

for Indx_F = 1:numel(Files)
    Filename = Files{Indx_F};
    NewFilename = replace(Filename, '.mat', '.edf');

    if ~Refresh && exist(fullfile(Destination, NewFilename), 'file')
        disp(['already did ', NewFilename])
        continue
    end

    load(fullfile(Source, Filename), 'EEG')

    EEG = eeg_checkset(EEG);
    writeeeg(fullfile(Destination, NewFilename), EEG.data, EEG.srate, ...
        'TYPE', 'EDF', 'EVENT', EEG.event, 'Label', {EEG.chanlocs.labels});
end

Chanlocs = EEG.chanlocs;

ChanlocsTable = struct2table(Chanlocs);
writetable(ChanlocsTable, fullfile(MetadataDestination, 'EEG_Chanlocs.csv'))

