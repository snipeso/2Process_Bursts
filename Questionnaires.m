% Scripts on all the questionnaire outputs

clear
clc
close all


P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;


%%% Load data
[Answers, Labels, Types] = loadRRT(Paths, Participants, Sessions);