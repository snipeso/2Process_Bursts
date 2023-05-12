% converts EEG to EDF

clear
clc
close all

Refresh = false;
Task = 'Standing';
Source = fullfile('E:\Data\Final\EEG\Bursts', Task);

Destination = fullfile('E:\Public\2Process_Bursts\Bursts\', Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = getContent(Source);

for Indx_F = 1:numel(Files)
    Filename = Files{Indx_F};
    NewFilename = replace(Filename, '.mat', '.csv');

    if ~Refresh && exist(fullfile(Destination, NewFilename), 'file')
        disp(['already did ', NewFilename])
        continue
    end

    load(fullfile(Source, Filename), 'Bursts', 'EEG')

    writetable(struct2table(Bursts), fullfile(Destination, NewFilename))
    save(fullfile(Destination, Filename), 'Bursts', 'EEG')

    Noise = array2table(double(EEG.keep_points)');

    writetable(Noise, fullfile(Destination, replace(NewFilename, 'Bursts', 'KeepTime')))
    disp(['Finished ', NewFilename])
end


