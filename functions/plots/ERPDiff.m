function Stats = ERPDiff(Data, Times, BL_Indx, XLims, LineLabels, Colors, PlotProps, StatsP)
% plots changes in power spectrum, highlighting significant frequencies
% different from specified BL_Indx. It also marks where the theta range is.
% Data is a P x S x Freq matrix.


% Just use the specified range (also to avoid extra statistics)

XIndx = dsearchn(Times', XLims');

Data = Data(:, :, XIndx(1):XIndx(2));
Times = Times(XIndx(1):XIndx(2));

% y limits
Means = squeeze(mean(Data, 1, 'omitnan'));
Min = min(Means(:));
Max = max(Means(:));


%%% Get stats
Data1 = squeeze(Data(:, BL_Indx, :)); % baseline
Data2 = Data;
Data2(:, BL_Indx, :) = []; % sessions to compare to the baseline
Stats = pairedttest(Data1, Data2, StatsP);
Stats.freqs = Times;


Dims = size(Data1);

Sig = [zeros(1, Dims(2)); Stats.p_fdr < StatsP.Alpha];

% plot
plotGloWorms(squeeze(mean(Data, 1, 'omitnan')), Times, logical(Sig), Colors, PlotProps)

ylim([Min Max])
xlabel('Time (ms)')

xlim(XLims)
ylabel('Voltage (\muV)')


if ~isempty(LineLabels)
    Alpha = num2str(StatsP.Alpha);
    Sig = ['p<', Alpha(2:end)];
    legend([LineLabels, Sig])
    Stats.lines = LineLabels;
Stats.lines(BL_Indx) = [];
end

