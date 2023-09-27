% Plot burst properties over time, topographies, and statistics for the
% paper

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

Refresh = false;
fs = 250;

TitleTag = 'Bursts';

%%% Load data

MegaTable_Filename = 'RRT_AllBursts.mat';
TablePath = fullfile(Paths.Data, 'EEG', 'Bursts_Table');
DataPath = fullfile(Paths.Data, 'EEG', 'Bursts');

if exist(fullfile(TablePath, MegaTable_Filename), 'file') && ~Refresh
    load(fullfile(TablePath, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations')
else
    [BurstTable, Missing, Durations] = loadAllBursts(DataPath, Participants, Sessions, Tasks);
    save(fullfile(TablePath, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations', '-v7.3')
end

% Use durations in minutes rather than seconds
Durations = Durations/60;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots

%% Figure X-Y Amplitude vs Quantity across sleep deprivation

PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.yPadding = 30;
PlotProps.Figure.Padding = 15;

zScore = [false, true];
Variables = {'Mean_coh_amplitude', 'nPeaks'};
YLabels = {'Amplitude', '# oscillations/min'};
Bands = {'Theta', 'Alpha'};
% YLims = [-3.5 6];
YLimsZ = [-3.5 3.5; -2 4.4];
YLims = [];
% YLimsZ = [];
Grid = [2, 2]; % variables x bands
Flip = false; % flip data if it decreases with SD
StatParameters = []; % could be StatsP
Z = true;

Indx = 1;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.7])
for Indx_V = 1:numel(Variables)
    for Indx_B = 1:2
        % adjust labels according to scale
        if Z
            YLabel = [YLabels{Indx_V}, ' (z-scored)'];
            YLim = YLimsZ(Indx_V, :);
            Score =  'zscore';
        else
            YLabel = YLabels{Indx_V};
            YLim = YLims(Indx_V, :);
            Score = 'raw';
        end

        % assemble data
        Variable = Variables{Indx_V};
        Matrix = bursttable2matrix(BurstTable(BurstTable.FreqType == Indx_B, :), ...
            Missing, Durations, Variable, Participants, Sessions, Tasks, Z);

        % plot
        A = chART.sub_plot([], Grid, [Indx_V, Indx_B], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
        plotBrokenRain(Matrix, [], YLim, TaskColors, Tasks, PlotProps)
        ylabel(YLabel)
        if Indx_V~=2 || Indx_B~=2
            legend off
        end

        if Indx_V==1
            title(Bands{Indx_B}, 'FontSize', PlotProps.Text.TitleSize)
        end

    end


end
saveFig(strjoin({TitleTag, 'All', Score}, '_'), Paths.Paper, PlotProps)






%% Assemble topography data

load('Chanlocs123.mat')
Topos = nan(numel(Participants), numel(Sessions), numel(Tasks), numel(Chanlocs), 2, 2);


for Indx_T = 1:numel(Tasks)
    for Indx_S = 1:numel(Sessions)
        for Indx_B = 1:2 % loop through frequencies
            for Indx_P = 1:numel(Participants)

                % load data
                T = BurstTable(BurstTable.FreqType == Indx_B & strcmp(BurstTable.Participant, Participants{Indx_P}) & ...
                    strcmp(BurstTable.Session, Sessions{Indx_S}) & strcmp(BurstTable.Task, Tasks{Indx_T}), :);

                if isempty(T)
                    continue
                end

                % allign all the channels involved with their average
                % amplitudes and number of peaks
                Ch = [T.Coh_Burst_Channels{:}];
                Amps = [T.Coh_amplitude{:}];
                Tots = [T.Coh_Burst_nPeaks{:}];

                % for each channel, find out how many were involved in
                % theta and alpha
                for Indx_Ch = 1:numel(Chanlocs)

                    Ch_Mean = mean(Amps(Ch==Indx_Ch), 'omitnan');
                    Ch_Tot = sum(Tots(Ch==Indx_Ch), 'omitnan')/Durations(Indx_P, Indx_S, Indx_T);

                    if Ch_Tot == 0
                        Ch_Mean = 0;
                    end

                    Topos(Indx_P, Indx_S, Indx_T, Indx_Ch, Indx_B, 1) = Ch_Mean;
                    Topos(Indx_P, Indx_S, Indx_T, Indx_Ch, Indx_B, 2)  = Ch_Tot;
                end
            end
        end
    end
end

% z score each variable separately
zTopos(:, :, :, :, :, 1) = zScoreData(squeeze(Topos(:, :, :, :, :, 1)), 'last');
zTopos(:, :, :, :, :, 2) = zScoreData(squeeze(Topos(:, :, :, :, :, 2)), 'last');



%% Figure X Burst topopgraphies

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 10;
PlotProps.Axes.yPadding = 15;
Grid = [1, 2];
miniGrid = [2 2];
zScore = true;
Bands = {'Theta', 'Alpha'};
Variables = {'Mean_coh_amplitude', 'nPeaks'};
VariableLabels = {'Amplitude', 'Peaks'};
CLabels = {'\muV', 'peaks/min'};
CLims = [-8 8];
BL = 4;
SD = 11;

L= struct;
L.t = 't-values';
load('Chanlocs123.mat', 'Chanlocs')

for Indx_T = 1:numel(Tasks)


    figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.3])

    for Indx_B = 1:numel(Bands)

        Space = subaxis(Grid, [1, Indx_B], [], PlotProps.Indexes.Letters{Indx_B}, PlotProps);

        for Indx_V = 1:numel(Variables)

            % plot average across all sessions
            Data = squeeze(mean(mean(zTopos(:, :, Indx_T, :, Indx_B, Indx_V), 1, 'omitnan'), 2, 'omitnan'));

            A = chART.sub_plot(Space, miniGrid, [Indx_V, 1], [], false, {}, PlotProps);
            plotTopoplot(Data, [], Chanlocs, [], CLabels{Indx_V}, 'Linear', PlotProps)

            if Indx_V ==1
                title(Bands{Indx_B}, 'FontSize', PlotProps.Text.TitleSize)
            end

            X = get(gca, 'XLim');
            Y = get(gca, 'YLim');
            text(X(1)-diff(X)*.15, Y(1)+diff(Y)*.5, VariableLabels{Indx_V}, ...
                'FontSize', PlotProps.Text.TitleSize, 'FontName', PlotProps.Text.FontName, ...
                'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);



            % plot change from main1 to main 8
            Data1 = squeeze(zTopos(:, BL, Indx_T, :, Indx_B, Indx_V));
            Data2 = squeeze(zTopos(:, SD, Indx_T, :, Indx_B, Indx_V));

            A = chART.sub_plot(Space, miniGrid, [Indx_V, 2], [], false, {}, PlotProps);
            Stats = topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps);

            if Indx_V ==1
                title('Start vs End', 'FontSize', PlotProps.Text.TitleSize)
            end
        end
    end

    % fix colormaps
    Fig = gcf;
    Pos = [];
    Linear = [3 4 7 8 12 13  16 17];
    for Indx_Ch = 1:numel(Fig.Children)
        if ~ismember(Indx_Ch, Linear)
            Fig.Children(Indx_Ch).Colormap = reduxColormap(PlotProps.Color.Maps.Divergent, PlotProps.Color.Steps.Divergent);
        else
            Fig.Children(Indx_Ch).Colormap = reduxColormap(PlotProps.Color.Maps.Linear, PlotProps.Color.Steps.Linear);
        end
    end

    saveFig(strjoin({TitleTag, 'Topographies', Tasks{Indx_T}}, '_'), Paths.Paper, PlotProps)
end










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stats


%% number of bursts (mean, min/max), average peaks per burst, average coherent channels. Range for overall fewest recording, and overall mostest

Matrix = bursttable2matrix(BurstTable, Missing, Durations, 'Tot', Participants, Sessions, Tasks, false);
Matrix = Matrix/60;