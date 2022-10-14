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


qLabels.SleepPropensity = replace(string(qLabels.SleepPropensity), ' sleep', '');

%%
for Indx_Q = 1:numel(Questions)

    Data = Answers.(Questions{Indx_Q}); % P x S
    save(fullfile(Paths.Pool, [TitleTag, '_', Questions{Indx_Q}, '.mat']), 'Data')

end