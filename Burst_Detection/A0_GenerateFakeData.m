% creates EEG for an artificial participant who had 123 channels and 100
% minutes of data, one for each task.


clear
clc
close all

Info = burstParameters();
Paths = Info.Paths;
Bands = Info.Bands;

Tasks = Info.Tasks;
Refresh = false;

Channels = 123;
Seconds = 100*60;
fs = 250;
bpfilter = [0.5 40];

BandLabels = fieldnames(Bands);

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    Destination = fullfile(Paths.Preprocessed, 'Clean', 'Waves', Task);

    for Indx_B = 1:numel(BandLabels)
        if ~exist(fullfile(Destination, BandLabels{Indx_B}), 'dir')
            mkdir(fullfile(Destination, BandLabels{Indx_B}))
        end
    end

    Filename = strjoin({'P00', Task, 'NULL', 'Clean.mat'}, '_');

    if exist(fullfile(Destination, Filename), 'file') && ~Refresh
        disp(['Skipping ', Filename])
        continue
    end

    % generate fake data
    EEG = fakeEEG(Channels, Seconds, fs, bpfilter);

    % save
    save(fullfile(Destination, Filename), 'EEG');
end