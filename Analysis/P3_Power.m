% Script to plot change in power

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

P = analysisParameters();
Paths = P.Paths;
Sessions = P.Sessions;
Tasks = P.Tasks;
TaskColors = P.TaskColors;
Bands = P.Bands;
BandLabels = fieldnames(Bands);
StatsP = P.StatsP;
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
Indx_B = 1;
Indx_T = 2;

Grid = [1, 1];
StatParameters = [];
Flip = false;
YLim = [-1.1, 1.9];


Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.35 PlotProps.Figure.Height*.25])

% gather data
Data = squeeze(Power(:, :, Indx_T, Indx_B));

% plot
A = chART.sub_plot([], Grid, [1, Indx_B], [], true, '', PlotProps);
plotBrokenSpaghetti(Data, [], YLim, [], PlotProps.Color.Participants, false, PlotProps)
ylabel('Theta power (z-scored)')

if Indx_B~=1
    legend off
end


chART.save_figure(TitleTag, Paths.Paper, PlotProps)


