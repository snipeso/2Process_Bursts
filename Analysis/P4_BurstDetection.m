% Figure plotting the distribution of mean burst amplitudes for example
% participants

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load parameters

P = analysisParameters();
Tasks = P.Tasks;
Paths = P.Paths;

Participants = {'P15', 'P16'};
Sessions = {'Main1', 'Main8'};
SessionLabels = {'S1', 'S8'};

FreqEdges = 2:.25:14;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



%% Figure S3: plot example screenshot

Task = 'Fixation';
Participant = 'P15';
PlotProps = P.Powerpoint;
PlotProps.FontName = 'Tw Cen MT';
PlotProps.Figure.Padding = 5;
PlotProps.Axes.xPadding = 5;
PlotProps.Axes.yPadding = 30;

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

Colors = [
    getColors(1, '', 'blue');
    getColors(1, '', 'green');
    getColors(1, '', 'yellow')
    getColors(1, '', 'orange');];
% figure('units', 'centimeters', 'Position', [0 0 PlotProps.Figure.Width*1, PlotProps.Figure.Height*.5])
figure('units', 'normalized', 'outerposition', [0 0 1 1])
Axes = subfigure([], [1 1], [1, 1], [], false, '', PlotProps);
Axes.Position(2) = Axes.Position(2)+ .025;
Bursts = [];
plotExampleBurstData(EEG, 20, Bursts, 'FinalBand', Colors, PlotProps)
% xlim([139.5 149.5])
xlim([141.5 149.5])
ylim([-10 2500])
xlabel('Time (s)')

% saveFig('Example_Data', Paths.Paper, PlotProps)




%% Figure 6: example bursts & cycle measures

PlotProps = P.Manuscript;
PlotProps.Patch.Alpha = 0.5;
PlotProps.Axes.yPadding = 18;
PlotProps.Axes.xPadding = 15;

Grid = [4 6];

xLims = [3 14];
yLimsTot = [0 10; 0 20];
yLimsAmp = [0 30];
Legend = SessionLabels;

Colors = getColors([numel(Tasks), numel(Sessions)]);
Colors = flip(flip(Colors, 1), 3);
Colors(1, :, :) = repmat([.5 .5 .5], 3, 1);

Indx = 1;
figure('units', 'centimeters', 'Position', [0 0 PlotProps.Figure.Width, ...
    PlotProps.Figure.Height*.44])

%%% plot histogram of # bursts per minute per frequency for each task
Base = nan(2, 1); % keep track of where the second plot is, to align
Shift = 0;
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
        A.Position(1) = A.Position(1)-Shift;
        A.Position(2) = A.Position(2)-0.01;
        A.Position(4) = A.Position(4)-0.01;


        H = A.Position(4);


        plotZiggurat(Data, '', FreqEdges(1:end-1),  'Bursts/min', ...
            squeeze(Colors(:, :, Indx_T)), Legend, PlotProps)

                set(legend, 'ItemTokenSize', [5 5])
        if Indx_P ==2 || Indx_T>1
            legend off
        end

        xlim(xLims)
        ylim(yLimsTot(Indx_P, :))
        if Indx_T ~= 1
            ylabel('')
            A = gca;
            set(A.YAxis, 'Visible', 'off')
        end
        title([Participants{Indx_P}, ' ' Tasks{Indx_T}], 'FontSize',PlotProps.Text.AxisSize)


        %%% distribution of mean amplitude
        Data = squeeze(Amps(Indx_P, :, Indx_T, :))';
        A = subfigure([], Grid, [2*Indx_P, Indx_T], [], true, '', PlotProps);
        A.Position(1) = A.Position(1)-Shift;
        A.Position(2) = A.Position(2)+0.03;
        A.Position(4) = H;
        Base(Indx_P) = A.Position(2);

        Shift = Shift + .005;
        plotZiggurat(Data, 'Frequency (Hz)', FreqEdges(1:end-1), 'Amplitude (\muV)', ...
            squeeze(Colors(:, :, Indx_T)), '', PlotProps)
        xlim(xLims)
        ylim(yLimsAmp)

        if Indx_T ~= 1
            ylabel('')
            A = gca;
            set(A.YAxis, 'Visible', 'off')
        end

    end
end

PlotProps.Axes.xPadding = 20;

Indx_B = 2;
Indx_S = [4 11];

%%% plot raw parameter changes
Variables = {'TotBursts', 'Globality', 'Duration',  'Amplitude', 'TotCycles'};
YLabels = {'Bursts/min', 'Gloablity (% channels)', 'Duration (s)'  'Amplitude (\muV)', 'Cycles/min',};
CornerCoordinates = {[2 4], [4 4], [2 5], [4 5], [4 6]};
Sizes = {[2, 1], [2, 1], [2, 1], [2, 1], [4, 1]};
YLims = {[0 150], [2 28], [.5 1.7], [6 22], [0 1200]};

for Indx_V = 1:numel(Variables)

    load(fullfile(Paths.Pool, ['Bursts_raw', Variables{Indx_V}, '.mat']), 'Data')
    Data = squeeze(Data(:, Indx_S, :, Indx_B));
    Data = permute(Data, [1 3 2]);

    if strcmp(Variables{Indx_V}, 'Globality')
        Data = Data*100;
    end
    CC = CornerCoordinates{Indx_V};
    A = subfigure([], Grid, CC, Sizes{Indx_V}, true, PlotProps.Indexes.Letters{Indx_V+2}, PlotProps);

    if CC(1) == 2
        A.Position(2) = Base(1);
    else
        A.Position(2) = Base(2);
    end
    A.Position(4) = A.Position(4)-0.02;

    if Indx_V ==numel(Variables)
        ytickangle(90)
    end
    plotSimpleChange(Data, Tasks, PlotProps.Color.Participants, PlotProps);
    ylabel(YLabels{Indx_V})
    ylim(YLims{Indx_V})


    if Indx_V ==1
        legend('Alpha S1 to S8', 'location', 'northwest')
        set(legend, 'ItemTokenSize', [10 10])
    end
end

saveFig('Example_Burst', Paths.Paper, PlotProps)




%% 

Task = 'Game';
Participant = 'P10';
Session = 'Session2';

PlotProps = P.Manuscript;
PlotProps.Text.FontName = 'Tw Cen MT';
PlotProps.Figure.Padding = 5;
PlotProps.Axes.xPadding = 5;
PlotProps.Axes.yPadding = 30;

load(fullfile('E:\Data\Preprocessed\Clean\Waves', Task, [Participant, '_', Task, '_', Session, '_Clean.mat']), 'EEG')


figure('units', 'centimeters', 'Position', [0 0 PlotProps.Figure.Width*1, PlotProps.Figure.Height*.5])
Axes = subfigure([], [1 1], [1, 1], [], false, '', PlotProps);
Axes.Position(2) = Axes.Position(2)+ .025;
plotExampleBurstData(EEG, 20, [], 'FinalBand', [], PlotProps)
setAxisProperties(PlotProps);
% xlim([139.5 149.5])
xlim([141.5 149.5])
ylim([-10 2500])
xlabel('Time (s)')