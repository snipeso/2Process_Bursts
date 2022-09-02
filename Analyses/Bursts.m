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
    save(fullfile(Path, MegaTable_Filename), 'BurstTable', 'Missing', 'Durations')
end

% Use durations in minutes rather than seconds
Durations = Durations/60;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots

%% Figure X-Y Amplitude vs Quantity across sleep deprivation


zScore = [false, true];
Variables = {'Mean_coh_amplitude', 'Tot'};
YLabels = {'Amplitude (\miV)', '# bursts/min'};
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
















