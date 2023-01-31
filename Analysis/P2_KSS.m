% Plots and stats about questionnaire data

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;

Labels = P.Labels;
StatsP = P.StatsP;

TitleTag = 'Questionnaires';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load data
[Answers, qLabels, Types] = loadRRT(Paths, Participants, Sessions);
Questions = fieldnames(Answers);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot

%% Figure 3

PlotQuestions = {'KSS'};

Titles = {'Sleepiness (KSS)'};

Flip = true;

Grid = size(PlotQuestions);
Indx = 1;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.6 PlotProps.Figure.Height*0.32])

for Indx_1 = 1:Grid(1)
    for Indx_2 = 1:Grid(2)
        Q = PlotQuestions{Indx_1, Indx_2};
        qL = qLabels.(Q);
        Data = Answers.(Q);
        A = subfigure([], Grid, [Indx_1, Indx_2], [], true, ...
            '', PlotProps);
        A.Position(1) = A.Position(1)+.3;
        A.Position(3) = A.Position(3)-.3;
        plotBrokenSpaghetti(Data, qL, [-.05 1.05], [], PlotProps.Color.Participants, Flip, PlotProps);
        Indx = Indx+1;
        if Indx_1<Grid(1)
            set(gca,'xtick',[])
        end
    end
end

saveFig([TitleTag, '_main_raw'], Paths.Paper, PlotProps)

