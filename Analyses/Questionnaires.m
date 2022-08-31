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
        qL = qLabels.(Q);
        Data = Answers.(Q);
        A = subfigure([], Grid, [Indx_1, Indx_2], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
        plotBrokenSpaghetti(Data, qL, [0 ceil(max(Data(:)))], [], PlotProps.Color.Participants, PlotProps)

        title(Q, 'FontSize', PlotProps.Text.TitleSize)
    end
end

saveFig(Paths.Paper, [TitleTag, '_main_raw'], PlotProps)


%% Figure X, same as above, but z-scored

yLim = [-1 5];


Indx = 1;
figure('Units','centimeters','Position',[0 0 PlotProps.W, PlotProps.H*0.5])
for Indx_1 = 1:Grid(1)
    for Indx_2 = 1:Grid(2)
        Q = PlotQuestions{Indx_1, Indx_2};
        qL = qLabels.(Q);
        Data = Answers.(Q);
        Data = zScoreData(Data, 'first');
        A = subfigure([], Grid, [Indx_1, Indx_2], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
        plotBrokenSpaghetti(Data, qL, yLim, [], PlotProps.Color.Participants, PlotProps)

        title(Q, 'FontSize', PlotProps.Text.TitleSize)
    end
end

saveFig(Paths.Paper, [TitleTag, '_main_z-scored'], PlotProps)



%% TODO (when waiting for co-author feedback): suppl all questions


