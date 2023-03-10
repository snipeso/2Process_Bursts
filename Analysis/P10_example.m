




clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'All';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Channels = P.Channels.All.All;
Participants = P.Participants;
Tasks = P.Tasks;
PlotProps = P.Manuscript;


Path = 'E:\Data\Final\EEG\Unlocked\window8s_duration6m';
Task = 'Fixation';
Participant = 'P15';
Sessions = {'Main2', 'Main8'};
Range = [1 40];

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.8 PlotProps.Figure.Height*0.32])
Grid = [1, numel(Sessions)];
for Indx_S = 1:numel(Sessions)

    load(fullfile(Path, Task, strjoin({Participant, Task, Sessions{Indx_S}, 'Welch.mat'}, '_')),...
        'Power', 'Freqs', 'Chanlocs')

     Data = mean(Power(labels2indexes(Channels,Chanlocs), :), '1', 'omitnan');


    A = subfigure([], Grid, [1, 1], [], true, ...
        PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        fooofFit(Freqs, Data, Range, true);
        title(Sessions{Indx_S})

end




