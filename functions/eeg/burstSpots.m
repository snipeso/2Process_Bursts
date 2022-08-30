function BurstTable = burstSpots(BurstTable, ROI, Chanlocs, ColName)
% assigns burst based on how many involved channels are in the ROI
% could be either one of the ROIs, or 0, none of them.

ROInames = fieldnames(ROI);

BurstTable.(ColName) = zeros(size(BurstTable, 1), 1);

% convert ROIs to current indexing
for Indx_R = 1:numel(ROInames)
    ROI.(ROInames{Indx_R}) = labels2indexes( ROI.(ROInames{Indx_R}), Chanlocs);
end

for Indx_B = 1:size(BurstTable, 1)
    Ch = BurstTable.Coh_Burst_Channels{Indx_B};

    for Indx_R = 1:numel(ROInames)
        Prcnt = nnz(ismember(Ch,  ROI.(ROInames{Indx_R})))/numel(Ch);
        if Prcnt >= .5
            BurstTable.(ColName)(Indx_B) = Indx_R;
            break
        end
    end
end