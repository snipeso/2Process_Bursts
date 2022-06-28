function [AllAnswers, Labels, Types] = loadRRT(Paths, Participants, Sessions)
% loads in Questionnaire data, saves it into a structure, with each field a
% matrix P x S

filename = 'Fixation_All.csv';

qIDs = {'RT_OVR_1_sl1', 'GeneralExperience';
    'RRT_OVT_4', 'Motivation';
    'RT_FEE_1.1_sl1', 'Happy';
    'RT_FEE_1.1_sl2', 'Sad';
    'RT_FEE_1.1_sl3', 'Angry';
    'RT_FEE_1.1_sl2', 'Afraid';
    'RT_FEE_1.2', 'ExtraFeelings';
    'RT_FEE_2', 'Tolerance';
    'RT_FEE_3', 'Stress';
    'RT_FEE_4_sl1', 'Hungry';
    'RT_FEE_4_sl2', 'Thirsty';
    'RT_FEE_4_sl3', 'Headache';
    'RT_FEE_4_sl4', 'Pain';
    'RT_FEE_4_sl5', 'Motivation2';
    'RT_FEE_5', 'GeneralFeeling';
    'RT_OVR_1_sl1', 'Enjoyment';
    'RT_OVR_1_sl2', 'Frustration';
    'RT_OVR_2', 'EstimatedDuration';
    'RT_OVR_3.1', 'DifficultyFixating';
    'RT_OVR_3.2', 'DifficultyWake';
    'RT_THO_1', 'Thoughts';
    'RT_TIR_1', 'KSS';
    'RT_TIR_2_sl1', 'PhysicalTiredness';
    'RT_TIR_2_sl2', 'EmotionalTiredness';
    'RT_TIR_2_sl1', 'PsychTiredness';
    'RT_TIR_2_sl1', 'SpiritTiredness';
    'RT_TIR_3.1', 'Sleep';
    'RT_TIR_3.2', 'SleepConfidence';
    'RT_TIR_4', 'Alertness';
    'RT_TIR_5', 'SleepPropensity';
    'RT_TIR_6', 'Focus';
    'RT_oddball', 'DifficultyOddball'};


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





