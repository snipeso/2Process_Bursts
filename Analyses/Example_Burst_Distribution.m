% Figure plotting the distribution of mean burst amplitudes for example
% participants

clear
clc
close all

P = analysisParameters();
Tasks = P.Tasks;
PlotProps = P.Manuscript;
Paths = P.Paths;

Participants = {'P15', 'P16'};
Sessions = {'Main1', 'Main8'};
SessionLabels = {'Start', 'End'};


FreqEdges = 2:.25:14;


%%% load data
Totals = nan(numel(Participants), numel(Sessions), numel(Tasks), numel(FreqEdges)-1);
Amps = Totals;
Amplitudes = struct();
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            % load data
            Source = fullfile(Paths.Data, 'EEG', 'Bursts', Tasks{Indx_T});
            Filename = strjoin({Participants{Indx_P}, Tasks{Indx_T}, Sessions{Indx_S}, 'Bursts.mat'}, '_');
            load(fullfile(Source, Filename), 'EEG', 'Bursts')

            % get distribution of bursts by frequency
%             Freqs = 1./[Bursts.period];
Freqs = 1./[Bursts.Mean_period];
            QuantFreqs = discretize(Freqs, FreqEdges);
           

            for Indx_F = 1:numel(FreqEdges)-1
                B = QuantFreqs==Indx_F;
                if nnz(B)<10 % skip if not many bursts
                    continue
                end
                Amps(Indx_P, Indx_S, Indx_T, Indx_F) = mean([Bursts(B).Mean_amplitude], 'omitnan');
            end

             QuantFreqs(isnan(QuantFreqs)) = [];
            TotFreqs = tabulate(QuantFreqs);

            % get minutes of recording
            Min = (EEG.clean_t/EEG.srate)/60;

            % bursts per minute
            Totals(Indx_P, Indx_S, Indx_T, 1:size(TotFreqs, 1)) = TotFreqs(:, 2)/Min;

            % amplitudes
            Amplitudes.(Participants{Indx_P}).(Tasks{Indx_T}).(Sessions{Indx_S}) = [Bursts(QuantFreqs).Mean_amplitude];
        end
    end
end

% 
% % make null a third session
% for Indx_T = 1:numel(Tasks)
%     % load data
%     Source = fullfile(Paths.Data, 'EEG', 'Bursts', Tasks{Indx_T});
%     Filename = strjoin({'P00', Tasks{Indx_T}, 'NULL', 'Bursts.mat'}, '_');
%     load(fullfile(Source, Filename), 'EEG', 'Bursts')
% 
%     % get distribution of bursts by frequency
%     Freqs = 1./[Bursts.Mean_period];
%     QuantFreqs = discretize(Freqs, FreqEdges);
%     QuantFreqs(isnan(QuantFreqs)) = [];
%     TotFreqs = tabulate(QuantFreqs);
% 
%     % get minutes of recording
%     Min = (EEG.clean_t/EEG.srate)/60;
% 
%     % bursts per minute
%     for Indx_P = 1:numel(Participants)
%         Totals(Indx_P, numel(Sessions)+1, Indx_T, 1:size(TotFreqs, 1)) = TotFreqs(:, 2)/Min;
%     end
% end


%%
PlotProps = P.Manuscript;
PlotProps.Patch.Alpha = 0.5;


Grid = [numel(Participants), numel(Tasks)];

miniGrid = [2, 1];
xLims = [3 14];
yLimsTot = [0 17; 0 39];
yLimsAmp = [0 30];
% Legend = [SessionLabels, 'Null'];
Legend = SessionLabels;

Colors = getColors([numel(Tasks), numel(Sessions)]);
Colors = flip(flip(Colors, 1), 3);
Colors(1, :, :) = repmat([.5 .5 .5], 3, 1);
% Colors = cat(2, Colors, repmat(PlotProps.Color.Generic, numel(Participants), 1));

Indx = 1;
figure('units', 'centimeters', 'Position', [0 0 PlotProps.Figure.Width, PlotProps.Figure.Height*.7])

%%% plot histogram of # bursts per minute per frequency for each task
for Indx_T = 1:numel(Tasks)
    for Indx_P = 1:numel(Participants)

                Space = subaxis(Grid, [Indx_P, Indx_T], [], PlotProps.Indexes.Letters{Indx}, PlotProps);  Indx = Indx+1;
        
        %%% distribution of number of bursts
        Data = squeeze(Totals(Indx_P, :, Indx_T, :))';

        Axes = subfigure(Space, miniGrid, [1, 1], [], false, ...
           '', PlotProps);
        plotZiggurat(Data, '', FreqEdges(1:end-1), [Participants{Indx_P}, ' bursts/min'], ...
            squeeze(Colors(:, :, Indx_T)), Legend, PlotProps)
        xlim(xLims)
        ylim(yLimsTot(Indx_P, :))
        if Indx_T ~= 1
            ylabel('')
        end
        title(Tasks{Indx_T})

        if Indx_P ==2 || Indx_T>1
            legend off
        end


        %%% distribution of mean amplitude
        Data = squeeze(Amps(Indx_P, :, Indx_T, :))';
                Axes = subfigure(Space, miniGrid, [2, 1], [], false, ...
           '', PlotProps);

                 plotZiggurat(Data, 'Frequency', FreqEdges(1:end-1), [Participants{Indx_P}, ' amplitude (\muV)'], ...
            squeeze(Colors(:, :, Indx_T)), '', PlotProps)
        xlim(xLims)
        ylim(yLimsAmp)
        if Indx_T ~= 1
            ylabel('')
        end
    end
end



saveFig('Example_Burst', Paths.Paper, PlotProps)








