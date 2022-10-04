% Power over time

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

% ROI = 'preROI';
ROI = 'All';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
Participants = P.Participants;
StatsP = P.StatsP;
Tasks = P.Tasks;


ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

Duration = 6; % minutes
WelchWindow = 8;

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = 'Power';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(Filepath, Participants, Sessions, Tasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure

%% Power by session

PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.yPadding = 30;
PlotProps.Figure.Padding = 15;
TaskColors = P.TaskColors;

Grid = [1, numel(BandLabels)];
StatParameters = [];
Flip = false;
% Ch_Indx = [1, 3];
Ch_Indx = [1 1];
YLim = [-1.3, 2.8;
    -1 5.1];

YLabel = 'Power (z-scored)';

Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

for Indx_B = 1:2

    % gather data
    Data = squeeze(bData(:, :, :, Ch_Indx(Indx_B), Indx_B));

    % plot
    A = subfigure([], Grid, [1, Indx_B], [], true, ...
        PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
    plotBrokenRain(Data, [], [], TaskColors, Tasks, PlotProps)
    ylabel(YLabel)

    %         yticks(round(YLim(Indx_B, 1)):1:YLim(Indx_B, 2))
    % title([BandLabels{Indx_B}, ' ', ChLabels{Ch_Indx(Indx_B)}])
    title([BandLabels{Indx_B}])
    if Indx_B~=2
        legend off
    end
end

saveFig(TitleTag, Paths.Paper, PlotProps)





