function Data = removeDebris(Data, fs, MaxSize)
% removes from array with nan gaps all data that is smaller than MaxSize

% identify chunks of data
[Starts, Ends] = data2windows(~isnan(Data));
Chunks = (Ends-Starts)/fs;

% keep only smaller chunks
BigChunks = Chunks>MaxSize;
Starts(BigChunks) = [];
Ends(BigChunks) = [];

% set to NaN data that is in small chunks
for Indx_C = 1:numel(Starts)
    Data(Starts(Indx_C):Ends(Indx_C)) = nan;
end
