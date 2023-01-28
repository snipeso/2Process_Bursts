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
Bands = P.Bands;
BandLabels = fieldnames(Bands);
TitleTag = 'Pupillometry';
PlotProps = P.Manuscript;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

load(fullfile(Paths.Pool, [TitleTag, '_OddballResponse.mat']), 'Data', 't')
zTimecourse = Data;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% plot response to targets


Grid = [3 4];
YLims = [-2 4];
% YLims = [-3.3 5];
Coordinates = {[1 1], [1 2], [1 3], [1, 4];
    [2 1], [2 2], [2 3], [2, 4];
    [3 1], [3 2], [3 3], [3, 4]}';

XLabels = P.Labels.Sessions;

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
        xlabel('Time (s)')
    end

    if Coordinate(2) ==1
        ylabel('Diameter (z-scored)')
    end
end

saveFig([TitleTag, 'EvokedResponse'], Paths.Paper, PlotProps)
