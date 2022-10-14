function [AllAnswers, Labels, Types] = loadRRT(Paths, Participants, Sessions)
% loads in Questionnaire data, saves it into a structure, with each field a
% matrix P x S

filename = 'Fixation_All.csv';

qIDs = {'RT_OVR_1_sl1', 'enjoyable';
    'RT_OVR_1_sl2', 'relaxing';
    'RRT_OVT_4', 'motivation';
    'RT_FEE_1.1_sl1', 'happy';
    'RT_FEE_1.1_sl2', 'sad';
    'RT_FEE_1.1_sl3', 'angry';
    'RT_FEE_1.1_sl4', 'afraid';
    'RT_FEE_1.2', 'extraFeelings';
    'RT_FEE_2', 'tolerance';
    'RT_FEE_3', 'stress';
    'RT_FEE_4_sl1', 'hungry';
    'RT_FEE_4_sl2', 'thirsty';
    'RT_FEE_4_sl3', 'headache';
    'RT_FEE_4_sl4', 'pain';
    'RT_FEE_4_sl5', 'motivation2';
    'RT_FEE_5', 'generalFeeling';
    'RT_OVR_1_sl1', 'enjoyment';
    'RT_OVR_1_sl2', 'frustration';
    'RT_OVR_2', 'estimatedDuration';
    'RT_OVR_3.1', 'difficultyFixating';
    'RT_OVR_3.2', 'difficultyWake';
    'RT_THO_1', 'thoughts';
    'RT_TIR_1', 'KSS';
    'RT_TIR_2_sl1', 'physicalTiredness';
    'RT_TIR_2_sl2', 'emotionalTiredness';
    'RT_TIR_2_sl3', 'psychTiredness';
    'RT_TIR_2_sl4', 'spiritTiredness';
    'RT_TIR_3.1', 'sleep';
    'RT_TIR_3.2', 'sleepConfidence';
    'RT_TIR_4', 'alertness';
    'RT_TIR_5', 'sleepPropensity';
    'RT_TIR_6', 'focus';
    'RT_oddball', 'difficultyOddball'};


Table = readtable(fullfile(Paths.Data, 'Questionnaires', filename));


%%% special fixes
FeelingIDs = {'RT_FEE_4_sl2', 'RT_FEE_4_sl3', 'RT_FEE_4_sl4', 'RT_FEE_4_sl5'};
FeelingQs = ismember(Table.qID, FeelingIDs);
Table.qLabels(FeelingQs) = repmat(Table.qLabels(find(strcmp(Table.qID, 'RT_FEE_4_sl1'), 1)), nnz(FeelingQs), 1);




AllAnswers = struct();
Labels = struct();
Types = struct();

for Indx_Q = 1:size(qIDs, 1)
    [AllAnswers.(qIDs{Indx_Q, 2}), Labels.(qIDs{Indx_Q, 2}), Types.(qIDs{Indx_Q, 2})] = ...
        qtable2matrix(Table, Participants, Sessions, qIDs{Indx_Q, 1});

end

if any(ismember(fieldnames(Labels), 'DifficultyWake'))
    Labels.DifficultyWake{2} = 'Extremely hard';
end





