% Power over time

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
Participants = P.Participants;
StatsP = P.StatsP;
Tasks = P.Tasks;
PlotProps = P.Manuscript;


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

Grid = [numel(BandLabels), numel(Tasks)];
StatParameters = [];
Flip = false;
Ch_Indx = [1, 3];
YLim = [-1.3, 2.8;
    -1 5.1];

YLabel = 'power (z-scored)';

Indx = 1;
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.5])

for Indx_B = 1:2
    for Indx_T = 1:numel(Tasks)

        % gather data
        Data = squeeze(bData(:, :, Indx_T, Ch_Indx(Indx_B), Indx_B));

        % plot
        A = subfigure([], Grid, [Indx_B, Indx_T], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;

        plotBrokenSpaghetti(Data, [], YLim(Indx_B, :), StatParameters, PlotProps.Color.Participants, Flip, PlotProps)
        yticks(round(YLim(Indx_B, 1)):1:YLim(Indx_B, 2))
        if Indx_B==1
            title(Tasks{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)
            set(gca,'xtick',[])
        end

        if Indx_T == 1
            ylabel([BandLabels{Indx_B}, ' ', YLabel])
        end

    end
end

saveFig(TitleTag, Paths.Paper, PlotProps)





