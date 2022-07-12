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
Refresh = false;

Events = {'S 10', 'S 11'}; % target first
TimeLimits = [-.5 1.5];
BaseLimits = [-500 0];

ERP_Filename = 'ERP_Oddball.mat';
ERP_Source = fullfile(Paths.Data, 'EEG', 'ERP');
if ~exist(ERP_Source, 'dir')
    mkdir(ERP_Source)
end


Results = fullfile(Paths.Results, 'EEG', 'ERPs');
if ~exist(Results, 'dir')
    mkdir(Results)
end
TitleTag =  'Oddball_ERPs';


if Refresh || ~exist(fullfile(ERP_Source, ERP_Filename), 'file')

    [ERP, fs, Chanlocs, Times] = ERPOddball(Paths, Participants, Sessions, Events, TimeLimits, BaseLimits);

    save(fullfile(ERP_Source, ERP_Filename), 'ERP', 'fs', 'Chanlocs', 'Times')
else
    load(fullfile(ERP_Source, ERP_Filename), 'ERP', 'fs', 'Chanlocs', 'Times')
end


% z-score data
% zERP = zScoreData(ERP, 'first');


sERP = smoothFreqs(ERP, Times, 'last', 10);


%%


Channels = [75 62 129];
ChLabels = {'Oz', 'Pz', 'Cz'};
Channels = labels2indexes(Channels, Chanlocs);
XLims = [-250 1000];
BL_Indx = 1;

for Indx_Ch = 1:numel(Channels)
    figure('Units', 'normalized', 'outerposition', [0 0 1 1])
    for Indx_S = 1:numel(Sessions)
        Data = squeeze(sERP(:, Indx_S, :, Channels(Indx_Ch), :));

        Data = Data(:, [2 1], :);
        subplot(3, 4, Indx_S)
        ERPDiff(Data, Times, BL_Indx, XLims, {}, getColors(2), PlotProps, StatsP);
        title([Sessions{Indx_S}, ' ', ChLabels{Indx_Ch}])
    end
    setLims(3, 4, 'y');
      saveFig(strjoin({TitleTag, ChLabels{Indx_Ch}}, '_'), Results, PlotProps)
end

