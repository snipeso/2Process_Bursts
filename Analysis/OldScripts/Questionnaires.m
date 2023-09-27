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

qLabels.SleepPropensity{1} = "Can't sleep";
qLabels.SleepPropensity{2} = "Hard to sleep";
qLabels.SleepPropensity{end} = "Tired, but can't sleep";
qLabels.SleepPropensity{end-1} = "Most I've wanted sleep";

qLabels.SleepPropensity = replace(qLabels.SleepPropensity, ' sleep', '')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% Figure X, Effect of sleep deprivation on subjective ratings

PlotQuestions = {'KSS', 'SleepPropensity';
    'DifficultyWake', 'DifficultyOddball';
    'Alertness', 'GeneralFeeling'};

Titles = {'Sleepiness (KSS)', 'Desire to sleep';
    'Difficulty staying awake', 'Difficulty oddball';
    'Alertness', 'Mood'};

Flip = true;

Grid = size(PlotQuestions);
Indx = 1;
figure('Units','centimeters','Position',[0 0 PlotProps.Figure.Width, PlotProps.Figure.Height*0.7])
for Indx_1 = 1:Grid(1)
    for Indx_2 = 1:Grid(2)
        Q = PlotQuestions{Indx_1, Indx_2};
        qL = qLabels.(Q);
        Data = Answers.(Q);
        A = chART.sub_plot([], Grid, [Indx_1, Indx_2], [], true, ...
            '', PlotProps);
        A.Position(1) = A.Position(1)+.07;
        A.Position(3) = A.Position(3)-.07;
        plotBrokenSpaghetti(Data, qL, [0 ceil(max(Data(:)))], [], PlotProps.Color.Participants, Flip, PlotProps)

        padAxis('y')
        title([ PlotProps.Indexes.Letters{Indx}, ': ', Titles{Indx_1, Indx_2}], 'FontSize', PlotProps.Text.TitleSize)
        Indx = Indx+1;
        if Indx_1<Grid(1)
            set(gca,'xtick',[])
        end
    end
end

chART.save_figure([TitleTag, '_main_raw'], Paths.Paper, PlotProps)


%% Figure X, same as above, but z-scored

yLim = [-1 5];


Flip = true;

Grid = size(PlotQuestions);
Indx = 1;
figure('Units','centimeters','Position',[0 0 PlotProps.Figure.Width, PlotProps.Figure.Height*0.7])
for Indx_1 = 1:Grid(1)
    for Indx_2 = 1:Grid(2)
        Q = PlotQuestions{Indx_1, Indx_2};
        Data = Answers.(Q);
         Data = zScoreData(Data, 'first');
        A = chART.sub_plot([], Grid, [Indx_1, Indx_2], [], true, ...
            '', PlotProps);
        A.Position(1) = A.Position(1)+.07;
        A.Position(3) = A.Position(3)-.07;
        plotBrokenSpaghetti(Data, [], [], [], PlotProps.Color.Participants, Flip, PlotProps)

        padAxis('y')
        title([ PlotProps.Indexes.Letters{Indx}, ': ', Titles{Indx_1, Indx_2}], 'FontSize', PlotProps.Text.TitleSize)
        Indx = Indx+1;
        if Indx_1<Grid(1)
            set(gca,'xtick',[])
        end
    end
end

chART.save_figure([TitleTag, '_main_z-scored'], Paths.Paper, PlotProps)



%% TODO (when waiting for co-author feedback): suppl all questions



%% table of all SD effect sizes (to decide who to include in table)


T = table(cell(numel(Questions), 1), nan(numel(Questions), 1), nan(numel(Questions), 1), nan(numel(Questions), 1),'VariableNames',{'question', 'p', 't', 'g'});

for Indx_Q = 1:numel(Questions)
Data = Answers.(Questions{Indx_Q});
BL = Data(:, 4);
SD = Data(:, 11);

try
Stats = pairedttest(BL, SD, StatsP);    
catch
    continue
end

T.question(Indx_Q) = Questions(Indx_Q);
T.p(Indx_Q) = Stats.p;
T.t(Indx_Q) = Stats.t;
T.g(Indx_Q) = Stats.hedgesg;

end


Sig = T(T.p<.05, :);


