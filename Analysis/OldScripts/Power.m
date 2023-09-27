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

% ChLabels = fieldnames(Channels.(ROI));
PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.yPadding = 30;
PlotProps.Figure.Padding = 15;
TaskColors = P.TaskColors;

Grid = [1, numel(BandLabels)];
StatParameters = [];
Flip = false;
% Ch_Indx = [1, 3];
Ch_Indx = [1 1, 1];
YLim = [-1.3, 2.8;
    -1 5.1];

YLabel = 'Power (z-scored)';

Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

for Indx_B = 1:numel(BandLabels)

    % gather data
    Data = squeeze(bData(:, :, :, Ch_Indx(Indx_B), Indx_B));

    % plot
    A = chART.sub_plot([], Grid, [1, Indx_B], [], true, ...
        PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
    plotBrokenRain(Data, [], [], TaskColors, Tasks, PlotProps)
    ylabel(YLabel)

    %         yticks(round(YLim(Indx_B, 1)):1:YLim(Indx_B, 2))
%     title([BandLabels{Indx_B}, ' (', ChLabels{Ch_Indx(Indx_B)}, ')'])
    title([BandLabels{Indx_B}], 'FontSize', PlotProps.Text.TitleSize)
    if Indx_B~=2
        legend off
    end
end

saveFig(TitleTag, Paths.Paper, PlotProps)


%% plot spectrums

SmoothFactor=2;

% average channel data into 2 spots
sData = smoothFreqs(zData, Freqs, 'last', SmoothFactor);
chData = meanChData(sData, Chanlocs, Channels.preROI, 4);

ChLabels = fieldnames(Channels.preROI);

%%

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 35;
PlotProps.Axes.xPadding = 20;
PlotProps.Axes.yPadding = 25;

YLim = [-1 3.2];
BL_Indx =1;
xLog = true;
Grid = [numel(ChLabels), numel(Tasks)];
Colors = flip(flip(getColors([numel(Tasks), numel(Sessions)-3]), 3), 1);


figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Width])
for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(Tasks)
        A = chART.sub_plot([], Grid, [Indx_Ch, Indx_T], [], false, ...
            '', PlotProps);

        Data = squeeze(chData(:, 4:11, Indx_T, Indx_Ch, :));
        spectrumDiff(Data, Freqs, BL_Indx, P.Labels.Sessions(4:11), squeeze(Colors(:, :, Indx_T)), xLog, PlotProps, [], P.Labels);
        legend off
        title([Tasks{Indx_T}, ' ', ChLabels{Indx_Ch}])
        ylim(YLim)
        if Indx_Ch<numel(ChLabels)
            xlabel('')
        end

        if Indx_T>1
            ylabel('')
        end

        A = gca;
        A.Children(3).LineStyle = ':';
        A.Children(4).LineStyle = ':';

        if Indx_T ==1 && Indx_Ch==numel(ChLabels)
            legend(['4:00', repmat({''}, 1, 5),'WMZ', '2:40'])
        end

    end
end

saveFig([TitleTag, '_spectrums'], Paths.Paper, PlotProps)

