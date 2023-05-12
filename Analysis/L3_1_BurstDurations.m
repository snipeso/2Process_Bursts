%%% Gets the duration of bursts as % of the recording.

clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Tasks = P.Tasks;
Bands = P.Bands;
BandLabels = fieldnames(Bands);

fs = 250;

TitleTag = 'Bursts';

%%% Load data
DataPath = fullfile(Paths.Data, 'EEG', 'Bursts');


Data = loadBurstDuration(DataPath, Participants, Sessions, Tasks, Bands);
save(fullfile(Paths.Pool, 'PrcntBurst.mat'), 'Data')



%% find out how much a given burst occupies the recording

clc

for Indx_B = 1:numel(BandLabels)
    for S = [4 11]
        for Indx_T = 1:numel(Tasks)
            D = 100*Data(:, S, Indx_T, Indx_B);
            dispDescriptive(D, [Sessions{S},' ', BandLabels{Indx_B}, ' ', Tasks{Indx_T}], '%', 0);
        end
        disp('*')
    end
    disp('_________')
end