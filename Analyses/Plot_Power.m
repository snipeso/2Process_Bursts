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
TitleTag = 'Power';


load(fullfile(Paths.Pool, 'Power_z-scored.mat'), 'Data')
Power = Data;

load(fullfile(Paths.Pool, 'Power_spectrum.mat'), 'Data', 'Freqs', 'ChLabels')
Spectrum = Data;


%% Plot power by session


PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.yPadding = 30;
PlotProps.Figure.Padding = 15;
TaskColors = P.TaskColors;

Grid = [1, numel(BandLabels)];
StatParameters = [];
Flip = false;
YLim = [-1.3, 2.8;
    -1 5.1];

YLabel = 'Power (z-scored)';

Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

for Indx_B = 1:numel(BandLabels)

    % gather data
    Data = squeeze(Power(:, :, :, Indx_B));

    % plot
    A = subfigure([], Grid, [1, Indx_B], [], true, ...
        PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
    plotBrokenRain(Data, [], [], TaskColors, Tasks, PlotProps)
    ylabel(YLabel)

    title([BandLabels{Indx_B}], 'FontSize', PlotProps.Text.TitleSize)
    if Indx_B~=2
        legend off
    end
end

saveFig(TitleTag, Paths.Paper, PlotProps)


%% Power band stats
clc

for Indx_B = 1:numel(BandLabels)
    for Indx_T = 1:numel(Tasks)

        disp(strjoin({Tasks{Indx_T}, BandLabels{Indx_B}}, ' '))

    % gather data
    Data = squeeze(Power(:, :, Indx_T, Indx_B));
 Stats = standardStats(Data, StatsP);
    end
    disp('******')
end





%% plot spectrograms

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
        A.Children(3).LineStyle = ':';
        A.Children(4).LineStyle = ':';

        if Indx_T ==1 && Indx_Ch==numel(ChLabels)
            legend(['SD1', repmat({''}, 1, 5),'WMZ', 'SD8'])
        end

    end
end

saveFig([TitleTag, '_spectrums'], Paths.Paper, PlotProps)



