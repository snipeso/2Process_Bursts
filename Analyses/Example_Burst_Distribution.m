% Figure plotting the distribution of mean burst amplitudes for example
% participants

clear
clc
close all

Info = analysisParameters();
Tasks = Info.Tasks;
PlotProps = Info.Manuscript;

Participants = {'P01', 'P15'};
Sessions = {'Main1', 'Main8'};
SessionLabels = {'Start', 'End'};


% make null a third session

%%

Grid = [numel(Participants), numel(Tasks)+1];
xLims = [2 14];
Legend = [SessionLabels, 'Null'];

Colors = getColors([numel(Tasks), numel(Sessions)]);
Colors = cat(2, Colors, repmat(PlotProps.Color.Generic, numel(Participants), 1));

Indx = 1;
figure('units', 'centimeters', 'Position', [0 0 PlotProps.W, PlotProps.H*.5])

%%% plot histogram of # bursts per minute per frequency for each task
for Indx_T = 1:numel(Tasks)
    for Indx_P = 1:numel(Participants)

        Data = squeeze(Totals(Indx_P, :, Indx_T, :));

        if Indx_P ==numel(Participants)
            xLabel = 'Frequency';
        else
            xLabel = '';
        end

        Axes = subfigure([], Grid, [Indx_P, Indx_T], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
        plotZiggurat(Data, xLabel, [], [Participants{Indx_P}, ' bursts/min'], ...
            squeeze(Colors(Indx_T, :, :)), Legend, PlotProps)
        xlim(xLims)
        title(Tasks{Indx_T})

    end
end


%%% plot violin plots of amplitudes of all bursts for each task
for Indx_P = 1:numel(Participants)
    Data = Amplitudes.(Participants{Indx_P});

    Axes = subfigure([], Grid, [Indx_P, numel(Tasks)+1], [], true, ...
        PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;

    plotFlames(Data)

end











