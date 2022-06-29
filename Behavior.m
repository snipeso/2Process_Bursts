% scripts plotting the response times, lapses and false alarms of the
% auditory oddball

clear
clc
close all


Refresh = false;

P = getParameters();
Paths = P.Paths;
Task = 'Oddball';


TaskData = fullfile(Paths.Data, 'Behavior', 'Oddball_Trials.mat');
if ~exist(TaskData, 'file') || Refresh
    AllAnswers = importOddball(Paths.Datasets, Task, fullfile(Paths.Data, 'Behavior'));
    Answers = cleanupOddball(AllAnswers);
    save(TaskData, 'Answers')
else
    load(TaskData, 'Answers')
end

