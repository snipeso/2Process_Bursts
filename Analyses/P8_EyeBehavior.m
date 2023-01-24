%%% plot microsleep data

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load parameters

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks(1:2);
TaskColors = P.TaskColors;
Bands = P.Bands;
BandLabels = fieldnames(Bands);
TitleTag = 'Microsleeps';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

load(fullfile(Paths.Pool, 'Microsleeps_nBlinks.mat'), 'Data')
zBlinks = zScoreData(Data, 'first');
Blinks = Data;

load(fullfile(Paths.Pool, 'Microsleeps_prcntMicrosleep.mat'), 'Data')
zMicrosleeps =zScoreData(Data, 'first');
Microsleeps = Data;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot

%% Figure 10: plot blinks and microsleeps across sessions

PlotProps = P.Manuscript;
YLim = [];
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.32])

A = subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Blinks, [], [0 53], Colors, Tasks, PlotProps)
set(legend, 'location', 'northwest')
ylabel('Blinks/min')


A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Microsleeps, [], [0 40], Colors, Tasks, PlotProps)
legend off
ylabel('Microsleeps duration (%)')

saveFig(TitleTag, Paths.Paper, PlotProps)


