% Figure plotting the distribution of mean burst amplitudes for example
% participants

clear
clc
close all

P= analysisParameters();
Tasks = P.Tasks;
PlotProps = P.Manuscript;
Paths = P.Paths;

Participants = {'P15', 'P16'};
Sessions = {'Main1', 'Main8'};
SessionLabels = {'SD1', 'SD8'};


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
PlotProps.Axes.yPadding = 20;


Grid = [4 6];

xLims = [3 14];
yLimsTot = [0 10; 0 17];
yLimsAmp = [0 30];
% Legend = [SessionLabels, 'Null'];
Legend = SessionLabels;

Colors = getColors([numel(Tasks), numel(Sessions)]);
Colors = flip(flip(Colors, 1), 3);
Colors(1, :, :) = repmat([.5 .5 .5], 3, 1);
% Colors = cat(2, Colors, repmat(PlotProps.Color.Generic, numel(Participants), 1));

Indx = 1;
figure('units', 'centimeters', 'Position', [0 0 PlotProps.Figure.Width*1.5, ...
    PlotProps.Figure.Height*.6])

%%% plot histogram of # bursts per minute per frequency for each task
for Indx_T = 1:numel(Tasks)
    for Indx_P = 1:numel(Participants)

        %%% distribution of number of bursts
        Data = squeeze(Totals(Indx_P, :, Indx_T, :))';

        if Indx_T==1
            Letter = PlotProps.Indexes.Letters{Indx_P};
        else
            Letter = '';
        end

        A  = subfigure([], Grid, [2*Indx_P-1, Indx_T], [], true, Letter, PlotProps);
        A.Position(2) = A.Position(2)-0.01;
        A.Position(4) = A.Position(4)-0.01;
        plotZiggurat(Data, '', FreqEdges(1:end-1), [Participants{Indx_P}, ' bursts/min'], ...
            squeeze(Colors(:, :, Indx_T)), Legend, PlotProps)
        set(legend, 'ItemTokenSize', [5 5])
        xlim(xLims)
        ylim(yLimsTot(Indx_P, :))
        if Indx_T ~= 1
            ylabel('')
        end
        title(Tasks{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)

        if Indx_P ==2 || Indx_T>1
            legend off
        end


        %%% distribution of mean amplitude
        Data = squeeze(Amps(Indx_P, :, Indx_T, :))';
        A = subfigure([], Grid, [2*Indx_P, Indx_T], [], true, '', PlotProps);
        A.Position(2) = A.Position(2)+0.01;
        A.Position(4) = A.Position(4)+0.01;

        plotZiggurat(Data, 'Frequency', FreqEdges(1:end-1), [Participants{Indx_P}, ' amplitude (\muV)'], ...
            squeeze(Colors(:, :, Indx_T)), '', PlotProps)
        xlim(xLims)
        ylim(yLimsAmp)
        if Indx_T ~= 1
            ylabel('')
        end
    end
end



Indx_B = 2;
Indx_S = [4 11];

%%% plot raw parameter changes
Variables = {'TotBursts', 'Globality', 'Duration',  'Amplitude', 'TotCycles'};
YLabels = {'burst/min', 'gloablity (% channels)', 'duration (s)'  'amplitude (\muV)', 'cycles/min',};
CornerCoordinates = {[2 4], [4 4], [2 5], [4 5], [4 6]};
Sizes = {[2, 1], [2, 1], [2, 1], [2, 1], [4, 1]};

for Indx_V = 1:numel(Variables)

    load(fullfile(Paths.Pool, ['Bursts_raw', Variables{Indx_V}, '.mat']), 'Data')
    Data = squeeze(Data(:, Indx_S, :, Indx_B));
    Data = permute(Data, [1 3 2]);

    if strcmp(Variables{Indx_V}, 'Globality')
        Data = Data*100;
    end

      A = subfigure([], Grid, CornerCoordinates{Indx_V}, Sizes{Indx_V}, true, PlotProps.Indexes.Letters{Indx_V+2}, PlotProps);
       A.Position(1) = A.Position(1)+0.02;

       if Indx_V ==numel(Variables)
           A.Position(3) = A.Position(3);
       else
        A.Position(3) = A.Position(3)-0.02;
       end
     plotSimpleChange(Data, Tasks, PlotProps.Color.Participants, PlotProps)
     ylabel(YLabels{Indx_V})

end

saveFig('Example_Burst', Paths.Paper, PlotProps)




%% plot example screenshot

Task = 'Fixation';
Participant = 'P15';

load(fullfile('E:\Data\Final\EEG\Bursts', Task, [Participant, '_', Task, '_Main8_Bursts.mat']), 'Bursts')
load(fullfile('E:\Data\Preprocessed\Clean\Waves', Task, [Participant, '_', Task, '_Main8_Clean.mat']), 'EEG')

% assign conventional labels
for Indx_B = 1:numel(Bursts)
    Period = 1/Bursts(Indx_B).Mean_period;
    if Period > 4 && Period <=6
        Bursts(Indx_B).FinalBand = '4-6 Hz';
    elseif  Period > 6 && Period <= 9
        Bursts(Indx_B).FinalBand = '6-9 Hz';
    elseif Period > 9 && Period<=11
        Bursts(Indx_B).FinalBand = '9-11 Hz';
    elseif Period<= 4
        Bursts(Indx_B).FinalBand = '< 4 Hz';
    elseif Period >11

        Bursts(Indx_B).FinalBand = '> 11 Hz';
    end

end



PlotProps = P.Manuscript;

Colors = [
    getColors(1, '', 'blue'); 
    getColors(1, '', 'green'); 
    getColors(1, '', 'yellow')
    getColors(1, '', 'orange');];
figure('units', 'centimeters', 'Position', [0 0 PlotProps.Figure.Width*1.5, PlotProps.Figure.Height*.6])
Axes = subfigure([], [1 1], [1, 1], [], false, '', PlotProps);
plotExampleBurstData(EEG, 20, Bursts, 'FinalBand', Colors, PlotProps)
% xlim([177 187])
xlim([139.5 149.5])
ylim([-10 2500])
xlabel('time (s)')
saveFig('Example_Data', Paths.Paper, PlotProps)


%% plot distribution for presentations

Indx_P = 2;
Indx_S = 2;
Indx_T = 2;

xLims = [4 12];
PlotProps = P.Powerpoint;
PlotProps.Patch.Alpha = 1;
PlotProps.Color.Background = 'none';


  figure('Units','normalized', 'Position',[0 0 .2 .3])
  axis square
 Data = squeeze(Totals(Indx_P, Indx_S, Indx_T, :))';


        plotZiggurat(Data', 'Frequency', FreqEdges(1:end-1), 'Bursts/min', ...
            getColors(1, '', 'blue'), '', PlotProps)
  xlim(xLims)
  xticks(4:2:12)
saveFig(strjoin({'Demo', 'Tots'}, '_'), Paths.Powerpoint, PlotProps)

  figure('Units','normalized', 'Position',[0 0 .2 .3])
  axis square
  Data = squeeze(Amps(Indx_P, Indx_S, Indx_T, :));
        plotZiggurat(Data, 'Frequency', FreqEdges(1:end-1), 'Amplitude (\muV)', ...
            getColors(1, '', 'yellow'), '', PlotProps)
        xticks(4:2:12)
        xlim(xLims)
saveFig(strjoin({'Demo', 'Amps'}, '_'), Paths.Powerpoint, PlotProps)
