function Stats = topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps)
% topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps)
%
% plots the t-values (color) and significant channels (white dots) of
% Data2 vs Data1 using chART plots.
% Data are P x Ch matrices.
% Chanlocs is an EEGLAB channel structure.
% CLims is the limits for the colormap. If none is provided, then the
% min/max is used, centered on 0.
% StatsP is a structure with statistics info (see analysisParameters).
% PlotProps is a structure with plotting info (see chART).
% in 2process_Bursts.

%%% Statistics
Stats = pairedttest(Data1, Data2, StatsP);

ES = Stats.(StatsP.Paired.ES);
Sig =  Stats.sig;
t_values = Stats.t;

% save max significant Hedge's g, # of sig channels, and # channels with
% G>1
Stats.ES_top1 = nnz(ES >= 1);

ES(~Sig) = nan; % only consider significant channels for rest
[Stats.ES_maxG, Indx] = max(ES);
Stats.ES_maxGch = Chanlocs(Indx).labels;
Stats.sigtot = nnz(Sig);


%%% Plot

% get colorlimits
if isempty(CLims)
    Max = max(abs([quantile(t_values, .01), quantile(t_values, .99)]));
    CLims = [-Max Max];
end

plotTopoplot(Stats.t, Stats, Chanlocs, CLims, 't-values', 'Divergent', PlotProps)


