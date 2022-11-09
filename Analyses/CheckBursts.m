%  plot all burst patterns
clear
clc
close all

P = analysisParameters();

Participants = P.Participants;
Sessions = P.Sessions;
Tasks = P.Tasks;

Destination = fullfile(P.Paths.Results, 'EEG', 'Bursts', 'Individuals');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end

%%
PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 5;
PlotProps.Axes.yPadding = 10;
PlotProps.Line.Width = 0.5;

Grid = [numel(Sessions), 1];

for Indx_P = 1:numel(Participants)
    for Indx_T = 1:numel(Tasks)
        Task = Tasks{Indx_T};
        figure('units', 'normalized', 'outerposition', [0 0 1 1])

        for Indx_S = 1:numel(Sessions)

            load(fullfile('E:\Data\Final\EEG\Bursts\', Task, ...
                strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Bursts.mat'}, '_')), ...
                'Bursts', 'EEG')

            fs = EEG.srate;

            subfigure([], Grid, [Indx_S, 1], [], true, '', PlotProps);
            plotBurstPatches(Bursts, EEG.nbchan, fs, PlotProps)
            if Indx_S > 1
                legend off
            end

            title(strjoin({Sessions{Indx_S}, Task, Participants{Indx_P}}, ' '))

        end

        saveFig(strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Bursts'}, '_'), Destination, PlotProps)
        
    end

end