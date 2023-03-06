% script to plot figure on changes in pupil size

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
Tasks = P.Tasks;
TaskColors = P.TaskColors;
TitleTag = 'FOOOF';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

load(fullfile(Paths.Pool, [TitleTag, '_slopes.mat']), 'Data')
Slopes = Data;
zSlopes = zScoreData(Slopes, 'first');

load(fullfile(Paths.Pool, [TitleTag, '_intercepts.mat']), 'Data')
Intercepts = Data;
zIntercepts = zScoreData(Intercepts, 'first');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots

%% Figure 9: plot diameter across sessions

PlotProps = P.Manuscript;
YLim = [];
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.8 PlotProps.Figure.Height*0.32])

subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Slopes, [], [-1.7 -1], Colors, Tasks, PlotProps)
ylabel('Slopes')
set(legend, 'location', 'northwest')


A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(Intercepts, [], [.5 1.3], Colors, Tasks, PlotProps)
ylabel('Intercepts')
legend off



% saveFig([TitleTag, 'Diameter'], Paths.Paper, PlotProps)



%% zscore


PlotProps = P.Manuscript;
YLim = [];
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.8 PlotProps.Figure.Height*0.32])

subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(zSlopes, [], [-3 3], Colors, Tasks, PlotProps)
ylabel('Slopes (z-scored)')
set(legend, 'location', 'northwest')


A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(zIntercepts, [], [-3 3], Colors, Tasks, PlotProps)
ylabel('Intercepts (z-scored)')
legend off


%% stats
clc

VariableNames = {'Sleep', 'Extended Wake', 'WMZ'};

AllStats = table();
AllLabels = {};
AllTasks = {};

for Indx_T = 1:numel(Tasks)
disp([Tasks{Indx_T}, ' Slopes:'])
[Stats, Strings] = standardStats(squeeze(zSlopes(:, :, Indx_T)), StatsP);

 AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
 AllTasks = [AllTasks; Tasks{Indx_T}];
 AllLabels = [AllLabels; 'Slopes'];

disp('Intercepts:')
[Stats, Strings] = standardStats(squeeze(zIntercepts(:, :, Indx_T)), StatsP);
 AllStats = [AllStats; cell2table(Strings, 'VariableNames', VariableNames)];
 AllTasks = [AllTasks; Tasks{Indx_T}];
  AllLabels = [AllLabels; 'Intercepts'];

end

AllStats.Labels = AllLabels;
AllStats.Task = AllTasks;
AllStats = AllStats(:, [4, 5, 1:3]);

writetable(AllStats, fullfile('C:\Users\Sophia Snipes\Desktop\Slopes', 'AllStats.xlsx'))
