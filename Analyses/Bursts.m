% Plot burst properties over time, topographies, and statistics for the
% paper

clear
clc
close all

P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks;

Refresh = false;
fs = 250;


%%% Load data

MegaTable_Filename = 'RRT_AllBursts.mat';
Path = fullfile(Paths.Data, 'EEG', 'Bursts_Table');

if exist(fullfile(Path, MegaTable_Filename), 'file') && ~Refresh
    load(fullfile(Path, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations')
else
    [BurstTable, Missing, Durations] = loadAllBursts(Path, Participants, Sessions, Tasks);
    save(fullfile(Path, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations', '-v7.3')
end

% Use durations in minutes rather than seconds
Durations = Durations/60;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots

%% Figure X-Y Amplitude vs Quantity across sleep deprivation


zScore = [false, true];
Variables = {'Mean_coh_amplitude', 'nPeaks'};
YLabels = {'Amplitude (\miV)', '# oscillations/min'};
Bands = {'Theta', 'Alpha'};
YLims = [-3.5 6];
YLimsZ = [-3.5 6];
Grid = [2, numel(Tasks)];
Flip = false; % flip data if it decreases with SD
StatParameters = []; % could be StatsP

for Indx_B = 1:2
    for Z = zScore

        Indx = 1;
        figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.W PlotProps.Figure.H*0.6])
        for Indx_T = 1:numel(Tasks)
            for Indx_V = 1:numel(Variables)

                % adjust labels according to scale
                if Z
                    YLabel = [YLabels{Indx_V}, ' (z-scored)'];
                    YLim = YLimsZ;
                    Score =  'zscore';
                else
                    YLabel = YLabels{Indx_V};
                    YLim = YLims;
                    Score = 'raw';
                end

                % assemble data
                Variable = Variables{Indx_V};
                Matrix = bursttable2matrix(BurstTable(BurstTable.FreqType == Indx_B, :), ...
                    Missing, Durations, Variable, Participants, Sessions, Tasks, Z);

                % plot
                A = subfigure([], Grid, [Indx_V, Indx_T], [], true, ...
                    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
                plotBrokenSpaghetti(squeeze(Matrix(:, :, Indx_T)), [], YLim, ...
                    StatParameters, PlotProps.Color.Participants, Flip, PlotProps)

                if Indx_V==1
                    title(Tasks{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)
                end

                ylabel(YLabel)

            end
        end

        saveFig(strjoin({TitleTag, 'AllSessions', Bands{Indx_B}, Score}, '_'), Paths.Paper, PlotProps)
    end
end




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
                Tots = [T.Coh_nPeaks{:}];

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
zTopos(:, :, :, :, 1) = zScoreData(squeeze(Topos(:, :, :, :, 1)), 'last');
zTopos(:, :, :, :, 2) = zScoreData(squeeze(Topos(:, :, :, :, 2)), 'last');



%% Figure X Burst topopgraphies

Grid = [1, 2];
miniGrid = [2 2];
zScore = true;
Bands = {'Theta', 'Alpha'};
Variables = {'Mean_coh_amplitude', 'nPeaks'};
CLabels = {'\miV', 'peaks/min'};
CLims = [-8 8];
BL = 4;
SD = 11;

load('Chanlocs123.mat', 'Chanlocs')

for Indx_T = 1:numel(Tasks)


    figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.W PlotProps.Figure.H*0.6])

    for Indx_B = 1:numel(Bands)

        Space = subaxis(Grid, [1, Indx_B], [], PlotProps.Indexes.Letters{Indx_B}, PlotProps);

        for Indx_V = 1:numel(Variables)

            % plot average across all sessions
            Data = squeeze(mean(mean(zTopos(:, :, Indx_T, :, Indx_B, Indx_V), 1, 'omitnan'), 2, 'omitnan'));

            A = subfigure(Space, miniGrid, [Indx_V, 1], [], false, {}, PlotProps);
            plotTopoplot(Data, [], Chanlocs, [], CLabels{Indx_V}, 'Linear', PlotProps)

            if Indx_V ==1
                title(Bands{Indx_B}, 'FontSize', PlotProps.Text.TitleSize)
            end


            % plot change from main1 to main 8
            Data1 = squeeze(zTopos(:, BL, Indx_T, :, Indx_B, Indx_V));
            Data2 = squeeze(zTopos(:, SD, Indx_T, :, Indx_B, Indx_V));

            A = subfigure(Space, miniGrid, [Indx_V, 2], [], false, {}, PlotProps);
            Stats = topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps);

            if Indx_V ==1
                title('Start vs End', 'FontSize', PlotProps.Text.TitleSize)
            end
        end
    end

    saveFig(strjoin({TitleTag, 'Topographies', Tasks{Indx_T}}, '_'), Paths.Paper, PlotProps)
end










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stats


%% number of bursts (mean, min/max), average peaks per burst, average coherent channels. Range for overall fewest recording, and overall mostest


