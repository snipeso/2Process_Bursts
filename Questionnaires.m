% Scripts on all the questionnaire outputs

clear
clc
close all


P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Powerpoint;
Labels = P.Labels;
StatsP = P.StatsP;
Gender = P.Gender;


Results = fullfile(Paths.Results, 'Questionnaires');
if ~exist(Results, 'dir')
    mkdir(Results)
end
TitleTag = 'RRT_Questionnaires';

%%% Load data
[Answers, qLabels, Types] = loadRRT(Paths, Participants, Sessions);


Questions = fieldnames(Answers);


%% plot every question

for Z  = [false true]
    for Indx_Q = 1:numel(Questions)

        Data = Answers.(Questions{Indx_Q});

        % differences by question type
        switch Types.(Questions{Indx_Q}){1}
            case 'Radio'
                YLims = [];
            case 'MultipleChoice'
                continue
            otherwise
                YLims = [0 1];
        end

        % z score data
        if Z
            YLims = [];
            ZType = 'zscore';

            Data = zScoreData(Data, 'first');

        else
            ZType = 'raw';
        end


        figure('Units','normalized', 'Position', [0 0 .5 .7])

        Stats = data2D('line', Data, Labels.Sessions, qLabels.(Questions{Indx_Q}), ...
            YLims, PlotProps.Color.Participants, StatsP, PlotProps);
        title(Questions{Indx_Q}, 'FontSize', PlotProps.Text.TitleSize)
        saveFig(strjoin({TitleTag, 'All', 'BySession', Questions{Indx_Q}, ZType}, '_'), Results, PlotProps)
    end
    close all
end


%% gender effects

Colors = repmat(getColors(1, '', 'blue'), numel(Participants), 1);
Female = strcmp(Gender, 'F');
Colors(Female, :) = repmat(getColors(1, '', 'pink'), nnz(Female), 1);

for Indx_Q = 1:numel(Questions)

    Data = Answers.(Questions{Indx_Q});

    % differences by question type
    switch Types.(Questions{Indx_Q}){1}
        case 'Radio'
            YLims = [];
        case 'MultipleChoice'
            continue
        otherwise
            YLims = [0 1];
    end
    figure('Units','normalized', 'Position', [0 0 .5 .7])
    Stats = groupDiff(Data, Labels.Sessions, qLabels.(Questions{Indx_Q}), YLims, Colors, StatsP, PlotProps);
    title(Questions{Indx_Q}, 'FontSize', PlotProps.Text.TitleSize)
    saveFig(strjoin({TitleTag, 'Gender', 'BySession', Questions{Indx_Q}}, '_'), Results, PlotProps)
end



%% plot type of thoughts

Ans = Answers.Sleep;
L = qLabels.Sleep;
Data = zeros(numel(L), numel(Sessions));

for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2)
        A = Ans{Indx_P, Indx_S};
        A(isnan(A)) = [];
        
        if isempty(A)
            continue
        end
        Data(A, Indx_S) = Data(A, Indx_S)+1;
    end
end

