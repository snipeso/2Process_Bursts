% scripts that gets figure for burst amplitudes vs cycles/sec

clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load parameters


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

load('E:\Data\Final\All_2processBursts\Bursts_zscoreAmplitude.mat', 'Data')
Amplitudes = Data;


load('E:\Data\Final\All_2processBursts\Bursts_zscoreTots.mat', 'Data')
Tots = Data;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot

%% Figure 7: Amplitude vs Quantity across sleep deprivation

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

AllData = cat(5, Amplitudes, Tots); % concatenate so I can loop

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



