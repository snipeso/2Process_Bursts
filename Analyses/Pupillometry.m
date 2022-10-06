% change in time of pupillometry measurements
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
XLabels = {'BL 23:00', 'BL 10:00', '23:00', '4:00', '7:00', '10:00', ...
    '15:00', '17:30', '20:00', '23:00', '2:40', 'Post'};
TitleTag = 'Pupillometry';

%%
% pupil diameter
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean');
[AllDiameters, sdAllDiameters, AllPUI] = getPupilDiameter(Path, Participants, Sessions, Tasks);

zAllDiameters = zScoreData(AllDiameters, 'first');
zAllPUI = zScoreData(AllPUI, 'first');
zsdAllDiameters = zScoreData(sdAllDiameters, 'first');


%

%%
% YLim = [2 8];
YLim = [];
% StatParameters = StatsP;
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;
Colors = P.TaskColors;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.4])

A = subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(zAllDiameters, [], [], Colors, Tasks, PlotProps)
ylabel('Diameter (mm) (z-scored)')
title('Diameter')

% A = subfigure([], Grid, [1, 2], [], true, ...
%     PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
% plotBrokenRain(zAllPUI, [], [], Colors, Tasks, PlotProps)
% ylabel('PUI (z-scored)')
% title('PUI')

A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(zsdAllDiameters, [], [], Colors, Tasks, PlotProps)
ylabel('sd diameter (z-scored)')
title('STD diameter')

saveFig([TitleTag, 'Diameter'], Paths.Paper, PlotProps)



%%


Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean', 'Oddball');
[Timecourse, t, AverageBaselines] = getPupilOddball(Path, Participants, Sessions);


% zTimecourse = zScoreData(Timecourse, 'last');
%%


Grid = [3 4];
YLims = [-.4 1];
Coordinates = {[1 1], [1 2], [1 3], [1, 4];
    [2 1], [2 2], [2 3], [2, 4];
    [3 1], [3 2], [3 3], [3, 4]}';

% Colors = [0.6 0.6 0.6; getColors(1, '', 'red')];
Colors = PlotProps.Color.Participants;

Legend = {'Standard', 'Target'};

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.6])

for Indx_S = 1:numel(Sessions)

    Data = squeeze(Timecourse(:, Indx_S, :, :));
    N = nnz(~isnan(Data(:, 1, 1))); % number of participants included

    A = subfigure([], Grid, Coordinates{Indx_S}, [], true, ...
        '', PlotProps);
    plotAngelHair(t, Data, Colors, Legend, PlotProps)
    title([XLabels{Indx_S}, ' (n=', num2str(N), ')'])
    ylim(YLims)
    if Indx_S>1
        legend off
    end

    if Indx_S>8
        xlabel('t(s)')
    end

end

saveFig([TitleTag, 'EvokedResponse'], Paths.Paper, PlotProps)


%% baselines
zAverageBaselines = zScoreData(AverageBaselines, 'first');

figure
plotBrokenRain(zAverageBaselines, [], [], getColors(2), Legend, PlotProps)
ylabel('mm')
title('Average baselines')
saveFig([TitleTag, 'TrialBaselines'], Paths.Paper, PlotProps)



%% 
Range = [0.5 1.8];
[AuC] = extractOddballValues(Timecourse, t, Range);

zAuC = zScoreData(AuC, 'first');


figure
plotBrokenSpaghetti(zAuC, [], [], P.StatsP, PlotProps.Color.Participants, false, PlotProps)
ylabel('mm')
title('AuC Target - Standard')
saveFig([TitleTag, 'AuC'], Paths.Paper, PlotProps)


