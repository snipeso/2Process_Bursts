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


FreqEdges = 2:.25:14;


%%% load data
Totals = nan(numel(Participants), numel(Sessions)+1, numel(Tasks), numel(FreqEdges)-1);
Amplitudes = struct();
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            % load data
            Source = fullfile(Paths.Data, 'EEG', 'Bursts', Tasks{Indx_T});
            Filename = strjoin({Participants{Indx_P}, Tasks{Indx_T}, Sessions{Indx_S}, 'Bursts.mat'}, '_');
            load(fullfile(Source, Filename), 'EEG', 'Bursts')

            % get distribution of bursts by frequency
            Freqs = 1./[Bursts.Mean_period];
            QuantFreqs = discretize(Freqs, FreqEdges);
            QuantFreqs(isnan(QuantFreqs)) = [];
            TotFreqs = tabulate(QuantFreqs);

            % get minutes of recording
            Min = (EEG.clean_t/EEG.srate)/60;

            % bursts per minute
            Totals(Indx_P, Indx_S, Indx_T, 1:size(TotFreqs, 1)) = TotFreqs(:, 2)/Min;


            % amplitudes
            Amplitudes.(Participants{Indx_P}).(Tasks{Indx_T}).(Sessions{Indx_S}) = [Bursts.Mean_Coh_amplitude];
        end
    end
end


% make null a third session
for Indx_T = 1:numel(Tasks)
    % load data
    Source = fullfile(Paths.Data, 'EEG', 'Bursts', Tasks{Indx_T});
    Filename = strjoin({'P00', Tasks{Indx_T}, 'NULL', 'Bursts.mat'}, '_');
    load(fullfile(Source, Filename), 'EEG', 'Bursts')

    % get distribution of bursts by frequency
    Freqs = 1./[Bursts.Mean_period];
    QuantFreqs = discretize(Freqs, FreqEdges);
    QuantFreqs(isnan(QuantFreqs)) = [];
    TotFreqs = tabulate(QuantFreqs);

    % get minutes of recording
    Min = (EEG.clean_t/EEG.srate)/60;

    % bursts per minute
    for Indx_P = 1:numel(Participants)
        Totals(Indx_P, numel(Sessions)+1, Indx_T, 1:size(TotFreqs, 1)) = TotFreqs(:, 2)/Min;
    end
end


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

    plotFlames(Data, Colors, 0.5, PlotProps)
    ylabel([Participants{Indx_P}, ' amplitudes'])

end


saveFig('Example_Burst', Paths.Paper, PlotProps)








