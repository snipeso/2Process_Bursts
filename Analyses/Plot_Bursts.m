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

TitleTag = 'Bursts';

load('E:\Data\Final\All_2processBursts\Bursts_zscoreAmplitude.mat', 'Data')
Amplitudes = Data;


load('E:\Data\Final\All_2processBursts\Bursts_zscoreTots.mat', 'Data')
Tots = Data;


%% Figure X-Y Amplitude vs Quantity across sleep deprivation

PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.yPadding = 30;
PlotProps.Figure.Padding = 15;

zScore = [false, true];
Variables = {'Mean_coh_amplitude', 'nPeaks'};
YLabels = {' amplitude', ' cycles/min'};
Bands = {'Theta', 'Alpha'};
YLimsZ = [-2.7 3; -2 4];
Grid = [2, 2]; % variables x bands
Flip = false; % flip data if it decreases with SD
StatParameters = []; % could be StatsP
Z = true;
Score = 'zscored';

Indx = 1;

AllData = cat(5, Amplitudes, Tots);

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width, PlotProps.Figure.Height*0.65])
for Indx_V = 1:numel(Variables)
    for Indx_B = 1:2
        % adjust labels according to scale
        YLabel = [YLabels{Indx_V}, ' (z-scored)'];
        YLim = YLimsZ(Indx_V, :);

        % assemble data
        Variable = Variables{Indx_V};
        Data = squeeze(AllData(:, :, :, Indx_B, Indx_V));
        % plot
        A = subfigure([], Grid, [Indx_V, Indx_B], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
        plotBrokenRain(Data, [], YLim, TaskColors, Tasks, PlotProps)
        ylabel([BandLabels{Indx_B}, YLabel])
        if Indx_V~=2 || Indx_B~=2
            legend off
        end

    end


end
saveFig(strjoin({TitleTag, 'All', Score}, '_'), Paths.Paper, PlotProps)

%%% stats


%% amplitudes
clc
for Indx_B = 1:numel(BandLabels)
    for Indx_T = 1:numel(Tasks)

        disp(strjoin({Tasks{Indx_T}, BandLabels{Indx_B}, 'Amps'}, ' '))

        % gather data
        Data = squeeze(Amplitudes(:, :, Indx_T, Indx_B));
        Stats = standardStats(Data, StatsP);
    end
    disp('******')
end



%% tots

clc
for Indx_B = 1:numel(BandLabels)
    for Indx_T = 1:numel(Tasks)

        disp(strjoin({Tasks{Indx_T}, BandLabels{Indx_B}, 'Tots'}, ' '))

        % gather data
        Data = squeeze(Tots(:, :, Indx_T, Indx_B));
        Stats = standardStats(Data, StatsP);
    end
    disp('******')
end



%%
PlotProps = P.Powerpoint;
YLims = [-3.2 2.1; -1.85 2.5];
YLabels = {'Amplitude (z-scored)', '# oscillations/min (z-scored)'};
Indx_T = 1;


for Indx_B = 1:numel(BandLabels)

    Data = squeeze(Amplitudes(:, :, Indx_T, Indx_B));

    figure('Units','normalized', 'Position', [0 0 .4 .6])
    %   plotBrokenRain(Data, [], YLims(1, :), TaskColors, Tasks, PlotProps)
    plotBrokenSpaghetti(Data, [], YLims(1, :), [], PlotProps.Color.Participants, false, PlotProps)
    ylabel('Amplitude (z-scored)')
    legend off
    % title([BandLabels{Indx_B}, ' Amplitudes'], 'FontSize', PlotProps.Text.TitleSize)
    saveFig(strjoin({TitleTag, 'Amplitude', BandLabels{Indx_B}}, '_'), Paths.Powerpoint, PlotProps)


    Data = squeeze(Tots(:, :, Indx_T, Indx_B));

    figure('Units','normalized', 'Position', [0 0 .4 .6])
    %   plotBrokenRain(Data, [], YLims(2, :), TaskColors, Tasks, PlotProps)
    plotBrokenSpaghetti(Data, [], YLims(2, :), [], PlotProps.Color.Participants, false, PlotProps)
    ylabel('# oscillations/min (z-scored)')
    % title([BandLabels{Indx_B}, ' Occurrences'], 'FontSize', PlotProps.Text.TitleSize)
    saveFig(strjoin({TitleTag, 'Tots', BandLabels{Indx_B}}, '_'), Paths.Powerpoint, PlotProps)

end







