% Plots and stats about questionnaire data
clear
clc
close all

P = analysisParameters();
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

qLabels.KSS(2:end-1) = {' '};


%%

PlotQuestions = {'KSS'};

Titles = {'Sleepiness (KSS)'};

Flip = true;

Grid = size(PlotQuestions);
Indx = 1;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.5 PlotProps.Figure.Height*0.3])

for Indx_1 = 1:Grid(1)
    for Indx_2 = 1:Grid(2)
        Q = PlotQuestions{Indx_1, Indx_2};
        qL = qLabels.(Q);
        Data = Answers.(Q);
        A = subfigure([], Grid, [Indx_1, Indx_2], [], true, ...
            '', PlotProps);
        A.Position(1) = A.Position(1)+.11;
        A.Position(3) = A.Position(3)-.11;
        plotBrokenSpaghetti(Data, qL, [0 ceil(max(Data(:)))], [], PlotProps.Color.Participants, Flip, PlotProps)

        padAxis('y')
        title([Titles{Indx_1, Indx_2}], 'FontSize', PlotProps.Text.TitleSize)
        Indx = Indx+1;
        if Indx_1<Grid(1)
            set(gca,'xtick',[])
        end
    end
end

saveFig([TitleTag, '_main_raw'], Paths.Paper, PlotProps)


%% stats


zData = zScoreData(Answers.KSS, 'first');
    Stats = standardStats(zData, StatsP);
