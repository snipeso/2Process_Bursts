% This script identifies the blinks in each recording, and longer
% "microsleeps" across time.

clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = {'Fixation', 'Oddball'};
Colors = P.TaskColors(1:2, :);
Refresh = true;

% load in data table of all eye closures
AllBlinks = fullfile(Paths.Data, 'Eyes', 'Blinks', 'AllBlinks.mat');
BlinkLocation = fullfile(Paths.Preprocessed, 'Pupils', 'Raw');
if Refresh || ~exist(AllBlinks, 'file')
    [BlinkTable, RecordingDurations, Confidence] = getBlinks(BlinkLocation, Participants, Sessions, Tasks);

    if ~exist('E:\Data\Final\Eyes\Blinks', 'dir')
        mkdir('E:\Data\Final\Eyes\Blinks')
    end

    save(AllBlinks, 'BlinkTable', 'RecordingDurations', 'Confidence')
else
    load(AllBlinks, 'BlinkTable', 'RecordingDurations', 'Confidence')
end


%%

MicrosleepThreshold = 1;
BlinkThreshold = 1; % anything less is a blink, more is a microsleep


% save data to matrix
TotBlinks = nan(numel(Participants), numel(Sessions), numel(Tasks)); % blinks per minute
MicrosleepDur = TotBlinks; % percent time microsleeping

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            Dur = squeeze(RecordingDurations(Indx_P, Indx_S, Indx_T))/60; % in minutes
            T = BlinkTable(strcmp(BlinkTable.Participant, Participants{Indx_P}) & ...
                strcmp(BlinkTable.Session, Sessions{Indx_S}) & strcmp(BlinkTable.Task, Tasks{Indx_T}), :);

            TotBlinks(Indx_P, Indx_S, Indx_T) = nnz(T.Duration<BlinkThreshold)/Dur;
            MicrosleepDur(Indx_P, Indx_S, Indx_T) = sum(T.Duration(T.Duration>=MicrosleepThreshold))/Dur;
        end
    end
end


% z-score
zTotBlinks = zScoreData(TotBlinks, 'first');
zMicrosleepDur = zScoreData(MicrosleepDur, 'first');


%% plot

Grid = [1 2];
Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

A = subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(TotBlinks, [], [], Colors, Tasks, PlotProps)
ylabel('blinks/min')
title('Blinks')


A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(MicrosleepDur, [], [], Colors, Tasks, PlotProps)
ylabel('% duration')
title('Microsleeps')
legend off

saveFig('EyeClosure', Paths.Paper, PlotProps)

%% plot confidence

figure
plotBrokenRain(Confidence, [], [], Colors, Tasks, PlotProps)
title('Average signal confidence (0.1<c<.95)')

saveFig('Confidence', Paths.Paper, PlotProps)
