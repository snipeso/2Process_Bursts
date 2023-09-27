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

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.35 PlotProps.Figure.Height*.25])
plotBrokenSpaghetti(squeeze(Microsleeps(:, :, 2)), [], [0 40], [], PlotProps.Color.Participants, false, PlotProps)

legend off
ylabel('Ocular microsleeps (%)')

chART.save_figure(TitleTag, Paths.Paper, PlotProps)


