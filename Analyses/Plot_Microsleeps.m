clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks;
TaskColors = P.TaskColors;
Bands = P.Bands;
BandLabels = fieldnames(Bands);
TitleTag = 'Microsleeps';


load(fullfile(Paths.Pool, 'Microsleeps_nBlinks.mat'), 'Data')
zBlinks = zScoreData(Data, 'first');
Blinks = Data;

load(fullfile(Paths.Pool, 'Microsleeps_prcntMicrosleep.mat'), 'Data')
zMicrosleeps =zScoreData(Data, 'first');
Microsleeps = Data;


%% plot across sessions

PlotProps = P.Manuscript;
YLim = [];
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

A = subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Blinks, [], [0 53], Colors, Tasks, PlotProps)
ylabel('blinks/min')
legend off

A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Microsleeps, [], [0 40], Colors, Tasks, PlotProps)
ylabel('Microsleeps duration (%)')

saveFig(TitleTag, Paths.Paper, PlotProps)


%% stats
clc

for Indx_T = 1:numel(Tasks)-1

    disp(strjoin({Tasks{Indx_T}, 'Blinks'}, ' '))

    % gather data
    Data = squeeze(zBlinks(:, :, Indx_T));
    Stats = standardStats(Data, StatsP);

    disp(strjoin({Tasks{Indx_T}, 'Microsleeps'}, ' '))


    % gather data
    Data = squeeze(zMicrosleeps(:, :, Indx_T));
    Stats = standardStats(Data, StatsP);


end
disp('******')



