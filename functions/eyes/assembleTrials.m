function short_event = assembleTrials(seg_table)
% gets only information from the targets and preceding standards
% Script by Elias Meier in 2process_Bursts

TrialIDs = find(contains(seg_table.message, 'TRIALID'));
TrialIDs(end+1) = size(seg_table, 1);

short_event = table();

for Indx_T = 1:numel(TrialIDs)-1
    if any(contains(seg_table.message(TrialIDs(Indx_T):TrialIDs(Indx_T+1)), 'standard'))
        continue
    end
    
    % gather the lines from the previous trial and the current one
    short_event = [short_event; seg_table(TrialIDs(Indx_T-1):TrialIDs(Indx_T+1)-1, :)]; %#ok<AGROW> 
end