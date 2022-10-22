function Stats = standardStats(Data, StatsP)
% produces the standard set of stats for the paper:
% - BL pre vs BL post
% - SD1 vs SD8
% - WMZ estimate
% Data is a P x S matrix.


% overnight change
Data1 = Data(:, 1);
Data2 = Data(:, 2);

Stats = pairedttest(Data1, Data2, StatsP);
dispStat(Stats, [1 1], 'BL overnight change:')

% sleep deprivation change
Data1 = Data(:, 4);
Data2 = Data(:, 11);

Stats(2) = pairedttest(Data1, Data2, StatsP);
dispStat(Stats(2), [1 1], 'SD change:')


% WMZ change
[Data2, Data1] = WMZinterp(Data(:, 8:11));
Stats(3) = pairedttest(Data1, Data2, StatsP);
dispStat(Stats(3), [1 1], 'WMZ change:')

% return to baseline
Data1 = Data(:, 2);
Data2 = Data(:, 12);

Stats(2) = pairedttest(Data1, Data2, StatsP);
dispStat(Stats(2), [1 1], 'Post to BL:')

% last night changes
Data1 = Data(:, 11);
Data2 = Data(:, 12);

Stats(2) = pairedttest(Data1, Data2, StatsP);
dispStat(Stats(2), [1 1], 'Return to BL:')

disp('______________')