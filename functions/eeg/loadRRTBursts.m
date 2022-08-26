function [AllBursts, AllMissing] = loadRRTBursts(Path, Tasks, Participants, Sessions)
% loads all bursts information into a single table

AllBursts = table();
AllMissing = [];

for Indx_T = 1:numel(Tasks)
    TablePath = fullfile(Path, [Tasks{Indx_T}, 'AllBursts.mat']);
    if exist(TablePath, 'file')
        load(TablePath, 'BurstTable', 'Missing')
    else
        DataPath = fullfile(extractBefore(Path, 'Bursts_Table'), 'Bursts', Tasks{Indx_T});
        [BurstTable, Missing] = loadAllBursts(Path, Participants, Sessions, Tasks{Indx_T});

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

    BurstTable.Task = repmat(Tasks(Indx_T), size(BurstTable, 1), 1);

    AllBursts = cat(1, AllBursts, BurstTable);
    AllMissing = cat(3, AllMissing, Missing);

end