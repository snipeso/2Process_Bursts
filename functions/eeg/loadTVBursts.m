function [AllBursts, AllMissing] = loadTVBursts(Path, Splits, Participants, Sessions, fs)
% gets a big table with all the bursts for all the participants and all the
% sessions, split into smaller windows

AllBursts = table();
AllMissing = [];


TablePath = fullfile(Path, 'TV_AllBursts.mat');
if exist(TablePath, 'file')
    load(TablePath, 'BurstTable', 'Missing')
else
    DataPath = fullfile(extractBefore(Path, 'Bursts_Table'), 'Bursts', 'TV');
    [BurstTable, Missing] = loadAllBursts(DataPath, Participants, Sessions, 'TV');

    %%% calculate things

    % mean amplitude of all coherent peaks
    BurstTable.Mean_Coh_amplitude = cellfun(@mean, BurstTable.Coh_amplitude);

    % whether theta or alpha
    Type = nan(size(BurstTable, 1), 1);
    Type(1./BurstTable.Mean_period>4 & 1./BurstTable.Mean_period<= 8) = 1; % theta
    Type(1./BurstTable.Mean_period>8 & 1./BurstTable.Mean_period<= 12) = 2; % alpha
    BurstTable.FreqType = Type;

    % duration
    BurstTable.Duration = (BurstTable.All_End - BurstTable.All_Start)/fs;

    % identify main location
    load('Chanlocs123.mat', 'Chanlocs')
    BurstTable = burstSpots(BurstTable, Channels.bigROI, Chanlocs, 'bigROI');

    % save
    save(TablePath, 'BurstTable', 'Missing')
end


AllSessions = BurstTable.Session;

All_Ends = discretize((BurstTable.All_End/fs)/60, Splits);
All_Ends(isnan(All_Ends)) = max(unique(All_Ends));
All_Ends = string(All_Ends);

% terrible hack to get the numbering system to work
New_Sessions = [char(AllSessions), repmat('_', numel(AllSessions), 1), char(All_Ends)];
New_Sessions = replace(string(New_Sessions), ' ', '');

BurstTable.NewSessions = New_Sessions;









