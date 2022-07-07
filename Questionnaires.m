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

Fits = struct();
X = [4 7 10 14.5 17.5 20 23 26.5];
After = 6:7;
TestPoint = 8;

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

            % fit data
            Y = mean(Data(:, 4:11), 'omitnan'); % get only 24h period
            Struct = fitStruct(X, Y, After, TestPoint);
            Struct.Variable =  Questions{Indx_Q};
            Fits = catStruct(Fits, Struct);

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

Fit_Table = struct2table(Fits);
writetable(Fit_Table, fullfile(Results, strjoin({TitleTag, 'Fits.csv'}, '_')))

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



%% plot WMZ effects


TempQs = {
    'KSS', 1;
    'DifficultyWake', 1;
    'SleepPropensity', 1;
    'Alertness', -1;
    'Focus', -1;
    'Motivation', -1;
    'Tolerance', 1;
    'Relaxing',-1;
    'GeneralFeeling', -1;
    'DifficultyFixating', 1;
    'DifficultyOddball', 1;

    };

nQs = size(TempQs, 1);
Before = nan(numel(Participants), nQs, 2); % questions x z-score
After = Before;
Colors = repmat([.5 .5 .5], nQs, 1);
notWMZ_Indx = 7:8;
WMZ_Indx = 9:10;
Start_Indx = 5:6;
Z = true;

    for Indx_Q = 1:size(TempQs, 1)
        Q = TempQs{Indx_Q, 1};
        Data = Answers.(Q);

        if strcmp(Types.(Q){1}, 'MultipleChoice')
            continue
        end

        if Z
            Data = zScoreData(Data, 'first');
            Indx_Z = 2;
        end

        Data = Data*TempQs{Indx_Q, 2};


        % Start vs preMWZ
        Before(:, Indx_Q, 1) = mean(Data(:, Start_Indx), 2, 'omitnan');
        After(:, Indx_Q, 1) = mean(Data(:, notWMZ_Indx), 2, 'omitnan');

        % preWMZ vs WMZ
          Before(:, Indx_Q, 2) = mean(Data(:, notWMZ_Indx), 2, 'omitnan');
        After(:, Indx_Q, 2) = mean(Data(:, WMZ_Indx), 2, 'omitnan');
    end

Stats = hedgesG(Before, After, StatsP);
figure('Units','normalized', 'OuterPosition', [0 0 .5 1])
plotUFO(Stats.hedgesg, Stats.hedgesgCI, TempQs(:, 1), {'\DeltaDay', '\DeltaWMZ'}, Colors, 'vertical', PlotProps)
ylim([-3 3])
saveFig(strjoin({TitleTag, 'WMZ', 'HedgesG'}, '_'), Results, PlotProps)

