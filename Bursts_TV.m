% Scripts on all the questionnaire outputs

clear
clc
close all


P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = {'TV1', 'TV2', 'TV3', 'TV4', 'TV5', 'TV6'};
PlotProps = P.Powerpoint;
Labels = P.Labels;
StatsP = P.StatsP;
Gender = P.Gender;

Refresh = false;
fs = 250;
Task = 'Fixation';

Results = fullfile(Paths.Results, 'EEG', 'Bursts');
if ~exist(Results, 'dir')
    mkdir(Results)
end
TitleTag = 'Bursts_TV';

MegatTable_Filename = [Task, 'AllBursts.mat'];

Path = fullfile(Paths.Data, 'EEG', 'Bursts_Table');
Splits = 0:20:80; % in minutes
% Splits = [0 90];
[AllBursts, AllMissing] = loadTVBursts(Path, Splits, Participants, Sessions, fs);

AllBursts.Session = AllBursts.NewSessions;
AllBursts.Task = repmat({'TV'}, size(AllBursts, 1), 1);
%%
zScore = [false, true];
% Variables = {'Tot', 'Mean_Coh_amplitude', 'nPeaks'};
Variables = {'Tot', 'Mean_Coh_amplitude'};
YLabels = {'# Bursts', 'Amplitude', '# Peaks'};
Bands = {'Theta', 'Alpha'};
YLims = [-3.5 6];

xLabels = [7 10 14.5 17.5 20 23];
newxLabels = nan(numel(Splits)-1, numel(xLabels));
newxLabels(end, :) = xLabels;
for Indx_X = 1:size(xLabels, 2)
NewT = [xLabels(Indx_X)-flip(Splits(2:end-1))/60]';
newxLabels(1:end-1, Indx_X) = NewT;
end
newxLabels = newxLabels(:)';

    for Z = true%zScore
        for Indx_B = 1:2
            for Indx_V = 1:numel(Variables)

                Variable =Variables{Indx_V};
                Matrix = table2matrixRRT(AllBursts(AllBursts.FreqType == Indx_B, :), ...
                    AllMissing, Variable, Participants, unique(AllBursts.Session), {'TV'}, Z);

                figure('units', 'centimeters', 'position', [0 0 30 30])
                plotConfettiSpaghetti(squeeze(Matrix(:, :)), [], newxLabels, PlotProps.Color.Participants, PlotProps)

                Title = strjoin({replace(Variable, '_', ' '), Bands{Indx_B}, 'TV'}, ' ');
                                title(Title,  'FontSize', PlotProps.Text.TitleSize)

                if Z
                    ylabel('z-scores')
                    %                     ylim(YLims)
                    Score =  'zscore';               
                else
                    Score = 'raw';
                end

                saveFig(strjoin({TitleTag, 'AllSessions', replace(Title, ' ', '_'), Score}, '_'), Results, PlotProps)
            end
        end
    end

