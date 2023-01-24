% Script to plot change in power

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

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
TitleTag = 'Power';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

load(fullfile(Paths.Pool, 'Power_z-scored.mat'), 'Data')
Power = Data;

load(fullfile(Paths.Pool, 'Power_spectrum.mat'), 'Data', 'Freqs', 'ChLabels')
Spectrum = Data;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot

%% Figure 3: power by session

PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.yPadding = 30;
PlotProps.Figure.Padding = 15;


Grid = [1, numel(BandLabels)];
StatParameters = [];
Flip = false;
YLim = [-1.1, 1.9];

YLabel = ' power (z-scored)';

Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.32])

for Indx_B = 1:numel(BandLabels)

    % gather data
    Data = squeeze(Power(:, :, :, Indx_B));

    % plot
    A = subfigure([], Grid, [1, Indx_B], [], true, ...
        PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
    plotBrokenRain(Data, [], YLim, TaskColors, Tasks, PlotProps)
    ylabel([BandLabels{Indx_B} YLabel])

    if Indx_B~=1
        legend off
    end
end

saveFig(TitleTag, Paths.Paper, PlotProps)



%% Figure 4: spectrograms

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 35;
PlotProps.Axes.xPadding = 20;
PlotProps.Axes.yPadding = 15;

YLim = [-1 3.2];
BL_Indx =1;
xLog = true;
Grid = [numel(ChLabels), numel(Tasks)];
Colors = flip(flip(getColors([numel(Tasks), numel(Sessions)-3]), 3), 1);


figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Width*.75])
for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(Tasks)

        subfigure([], Grid, [Indx_Ch, Indx_T], [], false, ...
            '', PlotProps);

        Data = squeeze(Spectrum(:, 4:11, Indx_T, Indx_Ch, :));
        spectrumDiff(Data, Freqs, BL_Indx, P.Labels.Sessions(4:11), squeeze(Colors(:, :, Indx_T)), xLog, PlotProps, [], P.Labels);
        legend off

        if Indx_Ch == 1
            title(Tasks{Indx_T})
        end

        ylim(YLim)
        if Indx_Ch<numel(ChLabels)
            xlabel('')
        end

        if Indx_T>1
            ylabel('')
        else
            ylabel([ChLabels{Indx_Ch}, ' power (z-scored)'])
        end

        A = gca;
        A.Children(3).LineStyle = '--';
        A.Children(4).LineStyle = '--';

        if Indx_T ==1 && Indx_Ch==1
            legend(['S1', repmat({''}, 1, 5),'WMZ', 'S8'], 'location', 'northwest')
            set(legend, 'ItemTokenSize', [20 20])
        end

    end
end

saveFig([TitleTag, '_spectrums'], Paths.Paper, PlotProps)



