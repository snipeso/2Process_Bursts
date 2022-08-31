% Plots and stats about questionnaire data
clear
clc
close all

P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;

Labels = P.Labels;
StatsP = P.StatsP;

TitleTag = 'Questionnaires';


%%% Load data
[Answers, qLabels, Types] = loadRRT(Paths, Participants, Sessions);
Questions = fieldnames(Answers);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% Figure X, Effect of sleep deprivation on subjective ratings

PlotQuestions = {'KSS', 'SleepPropensity'; 
    'DifficultyWake', 'DifficultyOddball'; 
    'Alertness', 'GeneralFeeling'}';

Grid = size(PlotQuestions);
Indx = 1;
figure('Units','centimeters','Position',[0 0 PlotProps.W, PlotProps.H*0.5])
for Indx_1 = 1:Grid(1)
for Indx_2 = 1:Grid(2)
Q = PlotQuestions{Indx_1, Indx_2};
Data = Answers.(Q);
    A = subfigure([], Grid, [Indx_1, Indx_2], [], true, ...
        PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;

    
    title(Q, 'FontSize', PlotProps.Text.TitleSize)


end
end
