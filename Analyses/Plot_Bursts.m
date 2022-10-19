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

