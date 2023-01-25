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
Tasks = P.Tasks(1:2);
TaskColors = P.TaskColors;
Bands = P.Bands;
BandLabels = fieldnames(Bands);
TitleTag = 'Pupillometry';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

load(fullfile(Paths.Pool, 'Pupillometry_z-scoredmeanDiameter.mat'), 'Data')
meanDiameter = Data;

load(fullfile(Paths.Pool, 'Pupillometry_z-scoredstdDiameter.mat'), 'Data')
stdDiameter = Data;

load(fullfile(Paths.Pool, 'Pupillometry_zAuC.mat'), 'Data')
AuC = Data;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots

%% Figure 9: plot diameter across sessions

PlotProps = P.Manuscript;
YLim = [];
StatParameters = StatsP;
Flip = false;
Grid = [1, 3];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*1.2 PlotProps.Figure.Height*0.32])

subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(meanDiameter, [], [-2.3 3], Colors, Tasks, PlotProps)
ylabel('Pupil diameter (z-scored)')
set(legend, 'location', 'northwest')


A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(stdDiameter, [], [-2.3 3], Colors, Tasks, PlotProps)
ylabel('SD pupil diameter (z-scored)')
legend off


A = subfigure([], Grid, [1, 3], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenSpaghetti(AuC, [], [-2 5], [], PlotProps.Color.Participants, false, PlotProps);
ylabel('Oddball AUC (z-scored)')


saveFig([TitleTag, 'Diameter'], Paths.Paper, PlotProps)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extra stats

%% AUC stats
%%% these are for the response of the oddball to tones. AUC = area under
%%% the curve.

PlotProps = P.Manuscript;
clc

    disp('AUC')

    % gather data
    Data = AuC;
    Stats = standardStats(Data, StatsP);

disp('******')

% get all pairwise stats
figure;
Stats = plotBrokenSpaghetti(Data, [], [], StatsP, PlotProps.Color.Participants, false, PlotProps);


% identify comparisons that have more than 10 participants
MinN = 10;

N = checkMissingComparisons(AuC);

I = find(N>10);
[r, c] = ind2sub([12, 12], I);

for Indx_I = 1:numel(I)
    dispStat(Stats, [r(Indx_I), c(Indx_I)], ...
        strjoin({Sessions{r(Indx_I)}, 'vs', Sessions{c(Indx_I)}}, ' '));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stats

%% special comparison of oddball vs fixation for 23:00 recordings
clc

S_Indexes = [1 3 10];
S_Labels = {'BL Pre', 'Pre', 'SD7'};

for Indx_S = 1:numel(S_Indexes)

    Data1 = squeeze(meanDiameter(:, S_Indexes(Indx_S), 1));
    Data2 = squeeze(meanDiameter(:, S_Indexes(Indx_S), 2));

    Stats = pairedttest(Data1, Data2, StatsP);
    dispStat(Stats, [1 1], S_Labels{Indx_S});
end


