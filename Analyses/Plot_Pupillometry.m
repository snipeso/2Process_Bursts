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
TitleTag = 'Pupillometry';


load(fullfile(Paths.Pool, 'Pupillometry_z-scoredmeanDiameter.mat'), 'Data')
meanDiameter = Data;

load(fullfile(Paths.Pool, 'Pupillometry_z-scoredstdDiameter.mat'), 'Data')
stdDiameter = Data;


%% plot diameter across sessions

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
plotBrokenRain(meanDiameter, [], [], Colors, Tasks, PlotProps)
ylabel('Diameter (mm) (z-scored)')
title('Diameter')
legend off

A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(stdDiameter, [], [], Colors, Tasks, PlotProps)
ylabel('sd diameter (z-scored)')
title('STD diameter')

saveFig([TitleTag, 'Diameter'], Paths.Paper, PlotProps)


%% stats
clc

for Indx_T = 1:numel(Tasks)-1

    disp(strjoin({Tasks{Indx_T}, 'Mean'}, ' '))

    % gather data
    Data = squeeze(meanDiameter(:, :, Indx_T));
    Stats = standardStats(Data, StatsP);

    disp(strjoin({Tasks{Indx_T}, 'STD'}, ' '))


    % gather data
    Data = squeeze(stdDiameter(:, :, Indx_T));
    Stats = standardStats(Data, StatsP);


end
disp('******')


%% special comparison of oddball vs fixation for 23:00 recordings
clc

S_Indexes = [1 3 10];
S_Labels = {'BL Pre', 'Pre', 'SD7'};

for Indx_S = 1:numel(S_Indexes)

    Data1 = squeeze(meanDiameter(:, S_Indexes(Indx_S), 1));
    Data2 = squeeze(meanDiameter(:, S_Indexes(Indx_S), 2));

    Stats = pairedttest(Data1, Data2, StatsP);
    dispStat(Stats, [1 1], S_Labels{Indx_S})
end


