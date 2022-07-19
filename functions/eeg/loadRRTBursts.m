function [AllBursts, AllMissing] = loadRRTBursts(Path, Tasks)
% loads all bursts information into a single table

AllBursts = table();
AllMissing = [];

for Indx_T = 1:numel(Tasks)
    load(fullfile(Path, [Tasks{Indx_T}, 'AllBursts.mat']), 'BurstTable', 'Missing')
    BurstTable.Task = repmat(Tasks(Indx_T), size(BurstTable, 1), 1);

    AllBursts = cat(1, AllBursts, BurstTable);
    AllMissing = cat(3, AllMissing, Missing);

end