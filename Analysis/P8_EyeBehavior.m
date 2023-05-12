%%% plot microsleep data

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load parameters

P = analysisParameters();
Paths = P.Paths;
StatsP = P.StatsP;
Tasks = P.Tasks(1:2);
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

%% Figure 8: plot blinks and microsleeps across sessions

PlotProps = P.Manuscript;
YLim = [];
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.7 PlotProps.Figure.Height*0.28])

A = subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Blinks, [], [0 53], Colors, Tasks, PlotProps)
set(legend, 'location', 'northwest')
ylabel('Blinks/min')


A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Microsleeps, [], [0 40], Colors, Tasks, PlotProps)
legend off
ylabel('Microsleeps (%)')

saveFig(TitleTag, Paths.Paper, PlotProps)


