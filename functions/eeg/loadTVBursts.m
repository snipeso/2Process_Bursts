function [BurstTable, Missing] = loadTVBursts(Path, Splits, Participants, Sessions, fs)
% gets a big table with all the bursts for all the participants and all the
% sessions, split into smaller windows


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

    %     % identify main location
    %     load('Chanlocs123.mat', 'Chanlocs')
    %     BurstTable = burstSpots(BurstTable, Channels.bigROI, Chanlocs, 'bigROI');

    NewBurstTable = table();
    NewBurstTable.nPeaks = BurstTable.nPeaks;
    NewBurstTable.Band = BurstTable.Band;
    NewBurstTable.Channel = BurstTable.Channel;
    NewBurstTable.Sign = BurstTable.Sign;
    NewBurstTable.Start = BurstTable.Start;
    NewBurstTable.End = BurstTable.End;
    NewBurstTable.All_Start = BurstTable.All_Start;
    NewBurstTable.All_End = BurstTable.All_End;
    NewBurstTable.globality_bursts = BurstTable.globality_bursts;
    NewBurstTable.Mean_voltageNeg = BurstTable.Mean_voltageNeg;
    NewBurstTable.Mean_voltagePos = BurstTable.Mean_voltagePos;
    NewBurstTable.Mean_periodNeg = BurstTable.Mean_periodNeg;
    NewBurstTable.Mean_periodPos = BurstTable.Mean_periodPos;
    NewBurstTable.Mean_amplitude = BurstTable.Mean_amplitude;
    NewBurstTable.Mean_efficiency = BurstTable.Mean_efficiency;
    NewBurstTable.Mean_monotonicity = BurstTable.Mean_monotonicity;
    NewBurstTable.Mean_period = BurstTable.Mean_period;
    NewBurstTable.Mean_nExtraPeaks = BurstTable.Mean_nExtraPeaks;
    NewBurstTable.Mean_prominence = BurstTable.Mean_prominence;
    NewBurstTable.Mean_drsym = BurstTable.Mean_drsym;
    NewBurstTable.Mean_periodPeakPos = BurstTable.Mean_periodPeakPos;
    NewBurstTable.Mean_tpsym = BurstTable.Mean_tpsym;
    NewBurstTable.Type = BurstTable.Type;
    NewBurstTable.Participant = BurstTable.Participant;
    NewBurstTable.Session = BurstTable.Session;
    NewBurstTable.FreqType = BurstTable.FreqType;
    NewBurstTable.Duration = BurstTable.Duration;
    NewBurstTable.Mean_Coh_amplitude = BurstTable.Mean_Coh_amplitude;


    BurstTable = NewBurstTable;


    % save
    save(TablePath, 'BurstTable', 'Missing', '-v7.3')
end


AllSessions = BurstTable.Session;

All_Ends = discretize((BurstTable.All_End/fs)/60, Splits);
All_Ends(isnan(All_Ends)) = max(unique(All_Ends));
All_Ends = string(All_Ends);

% terrible hack to get the numbering system to work
New_Sessions = [char(AllSessions), repmat('_', numel(AllSessions), 1), char(All_Ends)];
New_Sessions = replace(string(New_Sessions), ' ', '');

BurstTable.NewSessions = New_Sessions;









