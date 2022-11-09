


clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks;
TaskColors = P.TaskColors;

Refresh = false;
fs = 250;

TitleTag = 'Bursts';

load('E:\Data\Final\All_2processBursts\Bursts_Topo_Amplitude.mat', 'Data', 'Chanlocs')
Amplitudes = zScoreData(Data, 'last');


load('E:\Data\Final\All_2processBursts\Bursts_Topo_Tots.mat', 'Data')
Tots = zScoreData(Data, 'last');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot


%%

PlotProps = P.Manuscript;
% PlotProps.Figure.Padding = 10;
PlotProps.Axes.yPadding = 10;
PlotProps.Axes.xPadding = 10;
Grid = [2, 1];
miniGrid = [1 2];
miniminiGrid = [2 4];
zScore = true;
Bands = {'Theta', 'Alpha'};
Variables = {'Mean_coh_amplitude', 'nPeaks'};
VariableLabels = {'Amplitude', '# Cycles'};
CLabels = {'\muV (z-scored)', 'peaks/min (z-scored)'};

CLims_Average  = { [-0.5 1], [-1 2.5];
    [-0.4 .9], [-.7 2]};

CLims = [-8 8];
BL = 4;
SD = 11;

L= struct;
L.t = 't-values';

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*1.1 PlotProps.Figure.Height*0.5])


%%% plot average topographies

Space = subaxis(Grid, [1, 1], [], PlotProps.Indexes.Letters{1}, PlotProps); % the row

for Indx_B = 1:2
    miniSpace = subaxis(miniGrid, [1, Indx_B], [], '', PlotProps, Space); % the column
    miniSpace(3) = miniSpace(3)*1.1;

    for Indx_T = 1:numel(Tasks)

        % amplitudes
        Data = squeeze(mean(mean(Amplitudes(:, :, Indx_T, :, Indx_B), 1, 'omitnan'), 2, 'omitnan'));
        Axis = subfigure(miniSpace, miniminiGrid, [1, Indx_T], [], false, {}, PlotProps);
        A = gca;
        A.Units = 'pixels';
        shiftaxis(Axis, Axis.Position(3)*.1, []);
        plotTopoplot(Data, [], Chanlocs, CLims_Average{1, Indx_B}, '', 'Linear', PlotProps)
        title(Tasks{Indx_T})

        % quantities
        Data = squeeze(mean(mean(Tots(:, :, Indx_T, :, Indx_B), 1, 'omitnan'), 2, 'omitnan'));
        Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T], [], false, {}, PlotProps);
        A = gca;
        A.Units = 'pixels';
        shiftaxis(Axis, Axis.Position(3)*.1, []);
        plotTopoplot(Data, [], Chanlocs, CLims_Average{2, Indx_B}, '', 'Linear', PlotProps)
    end

    % colorbars
    Axis = subfigure(miniSpace, miniminiGrid, [1, Indx_T+1], [], false, {}, PlotProps);
    Axis.Position(1) = Axis.Position(1)-.015;
    Axis.Position(3) = Axis.Position(3)+.01;
    plotColorbar('Linear', CLims_Average{1, Indx_B}, CLabels{1}, PlotProps)

    Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T+1], [], false, {}, PlotProps);
    Axis.Position(1) = Axis.Position(1)-.015;
    Axis.Position(3) = Axis.Position(3)+.01;
    plotColorbar('Linear', CLims_Average{2, Indx_B}, CLabels{2}, PlotProps)
end



%%% plot t-values

Space = subaxis(Grid, [2, 1], [], PlotProps.Indexes.Letters{2}, PlotProps);

for Indx_B = 1:2
    miniSpace = subaxis(miniGrid, [1, Indx_B], [], '', PlotProps, Space); % the column
    miniSpace(3) = miniSpace(3)*1.1;

    for Indx_T = 1:numel(Tasks)

        % amplitudes
        Data1 = squeeze(Amplitudes(:, BL, Indx_T, :, Indx_B));
            Data2 = squeeze(Amplitudes(:, SD, Indx_T, :, Indx_B));
        Axis = subfigure(miniSpace, miniminiGrid, [1, Indx_T], [], false, {}, PlotProps);
        A = gca;
        A.Units = 'pixels';
        shiftaxis(Axis, Axis.Position(3)*.1, []);
       topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps);
       colorbar off
        title(Tasks{Indx_T})

        % quantities
          Data1 = squeeze(Tots(:, BL, Indx_T, :, Indx_B));
            Data2 = squeeze(Tots(:, SD, Indx_T, :, Indx_B));
        Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T], [], false, {}, PlotProps);
        A = gca;
        A.Units = 'pixels';
        shiftaxis(Axis, Axis.Position(3)*.1, []);
        topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps);
        colorbar off
    end

    % colorbars
    Axis = subfigure(miniSpace, miniminiGrid, [1, Indx_T+1], [], false, {}, PlotProps);
    Axis.Position(1) = Axis.Position(1)-.015;
    Axis.Position(3) = Axis.Position(3)+.01;
    plotColorbar('Linear', CLims, 't-values', PlotProps)

    Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T+1], [], false, {}, PlotProps);
    Axis.Position(1) = Axis.Position(1)-.015;
    Axis.Position(3) = Axis.Position(3)+.01;
    plotColorbar('Linear', CLims, 't-values', PlotProps)
end
