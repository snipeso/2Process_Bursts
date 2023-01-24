function NewData = closeGaps(Data, fs, MaxSize)
% in an array with nan's, provides interpolated values for smaller gaps

[Starts, Ends] = data2windows(isnan(Data));

Gaps = (Ends-Starts)/fs;

% keep list of only larger gaps
SmallGaps = Gaps<MaxSize;
Starts(SmallGaps) = [];
Ends(SmallGaps) = [];

% interpolate all missing data
NewData = fillmissing(Data, 'linear');

% restore nans for the larger gaps
for Indx_G = 1:numel(Starts)
    NewData(Starts(Indx_G):Ends(Indx_G)) = nan;
end