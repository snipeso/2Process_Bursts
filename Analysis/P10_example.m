clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'All';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Channels = P.Channels.All.All;
Participants = P.Participants;
Tasks = P.Tasks;
PlotProps = P.Manuscript;

%%
Path = 'E:\Data\Final\EEG\Unlocked\window8s_duration6m';
Task = 'Fixation';

Sessions = {'Main2', 'Main8'};
Range = [1 40];
YLim = [-2 1.5];
Grid = [1, numel(Sessions)+1];


for Indx_P = 1:numel(Participants)
    figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.32])
AllData = [];
    Participant = Participants{Indx_P};
for Indx_S = 1:numel(Sessions)

    load(fullfile(Path, Task, strjoin({Participant, Task, Sessions{Indx_S}, 'Welch.mat'}, '_')),...
        'Power', 'Freqs', 'Chanlocs')


     Data = mean(Power(labels2indexes(Channels,Chanlocs), :), 1, 'omitnan');
AllData = cat(1, AllData, Data);

    A = subfigure([], Grid, [1, Indx_S], [], true, ...
        PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        fooofFit(Freqs, Data, Range, true);
        title(Sessions{Indx_S})
        ylim(YLim)
xlabel('Frequencies')
ylabel('log power')
        legend off
end

 A = subfigure([], Grid, [1, Indx_S+1], [], true, ...
        PlotProps.Indexes.Letters{Indx_S+1}, PlotProps);

 Labels = P.Labels;
lData = log(AllData);
lData(isinf(lData)) = nan;
plot(log(Freqs), lData)
  X = log(Freqs);

    xticks(log(Labels.logBands))
    xticklabels(Labels.logBands)
legend(Sessions)
    xLims = log([1 40]);
xlim(xLims)
xlabel('Log frequencies')
ylabel('log power')

saveFig(Participant, 'C:\Users\Sophia Snipes\Desktop\Slopes\Individuals', PlotProps)
end