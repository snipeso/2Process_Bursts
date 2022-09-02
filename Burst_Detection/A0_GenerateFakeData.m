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

Channels = 1500;
Seconds = 6*60;
fs = 250;
bpfilter = [0.5 40];
hpStopfrq = 0.25;

BandLabels = fieldnames(Bands);

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    Destination = fullfile(Paths.Preprocessed, 'Clean', 'Waves', Task);

    Filename = strjoin({'P00', Task, 'NULL', 'Clean.mat'}, '_');

    if exist(fullfile(Destination, Filename), 'file') && ~Refresh
        disp(['Skipping ', Filename])
        continue
    end

    % generate fake data
    EEG = fakeEEG(Channels, Seconds, fs, bpfilter, hpStopfrq);

    % save
    save(fullfile(Destination, Filename), 'EEG');
end