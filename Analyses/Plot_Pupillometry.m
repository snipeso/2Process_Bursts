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

load(fullfile(Paths.Pool, 'Pupillometry_zAuC.mat'), 'Data')
AuC = Data;


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
plotBrokenRain(meanDiameter, [], [-2.3 3], Colors, Tasks, PlotProps)
ylabel('Diameter (mm) (z-scored)')
title('Diameter')
legend off

A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(stdDiameter, [], [-2.3 3], Colors, Tasks, PlotProps)
ylabel('sd diameter (z-scored)')
title('STD diameter')

saveFig([TitleTag, 'Diameter'], Paths.Paper, PlotProps)


%% mean diameter stats
clc

for Indx_T = 1:numel(Tasks)-1
    disp(strjoin({Tasks{Indx_T}, 'Mean'}, ' '))

    % gather data
    Data = squeeze(meanDiameter(:, :, Indx_T));
    Stats = standardStats(Data, StatsP);
end
disp('******')



%% std diameter stats
clc

for Indx_T = 1:numel(Tasks)-1
    disp(strjoin({Tasks{Indx_T}, 'STD'}, ' '))

    % gather data
    Data = squeeze(stdDiameter(:, :, Indx_T));
    Stats = standardStats(Data, StatsP);
end
disp('******')


%% AUC stats
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
        strjoin({Sessions{r(Indx_I)}, 'vs', Sessions{c(Indx_I)}}, ' '))
end





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



%% plot response to targets



Grid = [3 4];
% YLims = [-.4 1];
YLims = [-3.3 5];
Coordinates = {[1 1], [1 2], [1 3], [1, 4];
    [2 1], [2 2], [2 3], [2, 4];
    [3 1], [3 2], [3 3], [3, 4]}';

% Colors = [0.6 0.6 0.6; getColors(1, '', 'red')];
Colors = PlotProps.Color.Participants;

Legend = {'Standard', 'Target'};

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.6])
AllN = nan(1, numel(Sessions));
for Indx_S = 1:numel(Sessions)

    Data = squeeze(zTimecourse(:, Indx_S, :, :));
    N = nnz(~isnan(Data(:, 1, 1))); % number of participants included

    AllN(Indx_S) = N;
    Coordinate = Coordinates{Indx_S};
    A = subfigure([], Grid, Coordinate, [], true, ...
        '', PlotProps);
    plotAngelHair(t, Data, Colors, Legend, PlotProps)
    title([XLabels{Indx_S}, ' (n=', num2str(N), ')'])
    ylim(YLims)
    if Indx_S>1
        legend off
    else
        set(legend, 'ItemTokenSize', [10 10], 'location', 'southwest')
    end

    if Indx_S>8
        xlabel('t(s)')
    end

    if Coordinate(2) ==1
        ylabel('diameter (z-scored)')
    end
end

saveFig([TitleTag, 'EvokedResponse'], Paths.Paper, PlotProps)
