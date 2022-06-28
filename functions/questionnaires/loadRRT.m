function [Answers, Labels] = loadRRT(Paths, Participants, Sessions)
% loads in Questionnaire data, saves it into a structure, with each field a
% matrix P x S

filename = 'Fixation_All.csv';

qIDs = {'RT_OVR_1_sl1', 'GeneralExperience';
    'RRT_OVT_4', 'Motivation';
    'RT_FEE_1.1_sl1', 'Happy';
    'RT_FEE_1.1_sl2', 'Sad';
    'RT_FEE_1.1_sl3', 'Angry';
    'RT_FEE_1.1_sl2', 'Afraid';
    };





Answers = readtable(fullfile(Paths.Data, 'Questionnaires', filename));

[AnsAll, Labels] = qtable2matrix(Answers, Participants, Sessions, 'RT_TIR_1',  'numAnswer_1');