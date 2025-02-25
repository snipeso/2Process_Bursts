function Stats = spectrumDiff(Data, AllFreqs, BL_Indx, LineLabels, Colors, ...
    xLog, PlotProps, StatsP, Labels)
% plots changes in power spectrum, highlighting significant frequencies
% different from specified BL_Indx. It also marks where the theta range is.
% Data is a P x S x Freq matrix.
% From 2process_Bursts


% Just use the specified range (also to avoid extra statistics)

XLims = Labels.FreqLimits;
XIndx = dsearchn(AllFreqs', XLims');

Data = Data(:, :, XIndx(1):XIndx(2));
Freqs = AllFreqs(XIndx(1):XIndx(2));

% Adjustments for a log scale
if xLog
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Labels.logBands))

    X = log(Freqs);

    xticks(log(Labels.logBands))
    xticklabels(Labels.logBands)

    xLims = log(Freqs([1, end]));

else
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Labels.Bands)

    X = Freqs;
    xticks(Labels.Bands)
    xticklabels(Labels.Bands)

    xLims = Freqs([1, end]);
end

% y limits
Means = squeeze(nanmean(Data, 1));
Min = min(Means(:));
Max = max(Means(:));


%%% Get stats
if ~isempty(StatsP)
    Data1 = squeeze(Data(:, BL_Indx, :)); % baseline
    Data2 = Data;
    Data2(:, BL_Indx, :) = []; % sessions to compare to the baseline
    Stats = pairedttest(Data1, Data2, StatsP);
    Stats.freqs = Freqs;
    Stats.lines = LineLabels;
    Stats.lines(BL_Indx) = [];
    Dims = size(Data1);

    Sig = [zeros(1, Dims(2)); Stats.p_fdr < StatsP.Alpha];
else
    Dims = size(Data);
    Sig = zeros(Dims(2), Dims(3));
end

% plot
plotGloWorms(squeeze(mean(Data, 1, 'omitnan')), X, logical(Sig), Colors, PlotProps)

ylim([Min Max])
ylabel(Labels.zPower)

xlim(xLims)
xlabel(Labels.Frequency)
h=gca; h.XAxis.TickLength = [0 0];
h=gca; h.YAxis.TickLength = [0 0];


if ~isempty(LineLabels) && ~isempty(StatsP)
    Alpha = num2str(StatsP.Alpha);
    Sig = ['p<', Alpha(2:end)];
    legend([LineLabels, Sig])
    elseif ~isempty(LineLabels) 
legend(LineLabels)
set(legend, 'ItemTokenSize', [10 10])
end

