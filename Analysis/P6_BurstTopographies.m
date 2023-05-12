% script for figure plotting topographies

clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load parameters

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks;
TaskColors = P.TaskColors;

Refresh = false;

TitleTag = 'Bursts_Topo';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data


load('E:\Data\Final\All_2processBursts\Bursts_Topo_Amplitude.mat', 'Data', 'Chanlocs')
Amplitudes = zScoreData(Data, 'last');


load('E:\Data\Final\All_2processBursts\Bursts_Topo_Tots.mat', 'Data')
Tots = zScoreData(Data, 'last');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot


%% Figure 8: topography of amplitudes and burst quantities

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 10;
PlotProps.Axes.yPadding = 10;
PlotProps.Axes.xPadding = 10;
PlotProps.External.EEGLAB.TopoRes = 500;
PlotProps.Text.IndexSize = 24;
Grid = [2, 1];
miniGrid = [1 2];
miniminiGrid = [2 4];
zScore = true;
Bands = {'Theta', 'Alpha'};
Variables = {'Mean_coh_amplitude', 'nPeaks'};
VariableLabels = {'Amplitude', 'Quantity'};
CLabels = {'\muV (z-scored)', 'cycles/min (z-scored)'};

CLims_Average  = { [-0.5 .7], [-1 2.4];
    [-0.4 1], [-.7 2.1]};

CLims = [-10 10];
BL = 4;
SD = 11;

XShift = .16;
L= struct;
L.t = 't-values';

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*1.2 PlotProps.Figure.Height*0.6])
Txt = annotation('textbox', [0.02 0.79 0.2 0.2], 'string', PlotProps.Indexes.Letters{1}, ...
    'Units', 'normalized', 'FontSize', PlotProps.Text.IndexSize, 'FontName', PlotProps.Text.FontName, ...
    'FontWeight', 'Bold', 'LineStyle', 'none');

Txt = annotation('textbox', [0.02 0.3 0.2 0.2], 'string', PlotProps.Indexes.Letters{3}, ...
    'Units', 'normalized', 'FontSize', PlotProps.Text.IndexSize, 'FontName', PlotProps.Text.FontName, ...
    'FontWeight', 'Bold', 'LineStyle', 'none');

Txt = annotation('textbox', [0.502 0.79 0.2 0.2], 'string', PlotProps.Indexes.Letters{2}, ...
    'Units', 'normalized', 'FontSize', PlotProps.Text.IndexSize, 'FontName', PlotProps.Text.FontName, ...
    'FontWeight', 'Bold', 'LineStyle', 'none');

Txt = annotation('textbox', [0.502 0.3 0.2 0.2], 'string', PlotProps.Indexes.Letters{4}, ...
    'Units', 'normalized', 'FontSize', PlotProps.Text.IndexSize, 'FontName', PlotProps.Text.FontName, ...
    'FontWeight', 'Bold', 'LineStyle', 'none');

%%% plot average topographies

Space = subaxis(Grid, [1, 1], [], '', PlotProps); % the row
Space(1) = Space(1)+20;
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
        if Indx_T ==1
            yTitle(XShift, VariableLabels{1}, PlotProps)
        end

        % quantities
        Data = squeeze(mean(mean(Tots(:, :, Indx_T, :, Indx_B), 1, 'omitnan'), 2, 'omitnan'));
        Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T], [], false, {}, PlotProps);
        A = gca;
        A.Units = 'pixels';
        shiftaxis(Axis, Axis.Position(3)*.1, []);
        plotTopoplot(Data, [], Chanlocs, CLims_Average{2, Indx_B}, '', 'Linear', PlotProps)

        if Indx_T ==1
            yTitle(XShift, VariableLabels{2}, PlotProps)
        end

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

Space = subaxis(Grid, [2, 1], [], '', PlotProps);
Space(1) = Space(1)+20;
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

        if Indx_T ==1
            yTitle(XShift, VariableLabels{1}, PlotProps)
        end

        % quantities
        Data1 = squeeze(Tots(:, BL, Indx_T, :, Indx_B));
        Data2 = squeeze(Tots(:, SD, Indx_T, :, Indx_B));
        Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T], [], false, {}, PlotProps);
        A = gca;
        A.Units = 'pixels';
        shiftaxis(Axis, Axis.Position(3)*.1, []);
        topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps);
        colorbar off

        if Indx_T ==1
            yTitle(XShift, VariableLabels{2}, PlotProps)
        end
    end

    % colorbars
    Axis = subfigure(miniSpace, miniminiGrid, [1, Indx_T+1], [], false, {}, PlotProps);
    Axis.Position(1) = Axis.Position(1)-.015;
    Axis.Position(3) = Axis.Position(3)+.01;
    plotColorbar('Divergent', CLims, 't-values', PlotProps)

    Axis = subfigure(miniSpace, miniminiGrid, [2, Indx_T+1], [], false, {}, PlotProps);
    Axis.Position(1) = Axis.Position(1)-.015;
    Axis.Position(3) = Axis.Position(3)+.01;
    plotColorbar('Divergent', CLims, 't-values', PlotProps)
end


% fix colormaps
Fig = gcf;

for Indx_Ch = 1:numel(Fig.Children)
    if Indx_Ch < 22
        Fig.Children(Indx_Ch).Colormap = reduxColormap(PlotProps.Color.Maps.Divergent, PlotProps.Color.Steps.Divergent);
    else
        Fig.Children(Indx_Ch).Colormap = reduxColormap(PlotProps.Color.Maps.Linear, PlotProps.Color.Steps.Linear);
    end
end


saveFig(TitleTag, Paths.Paper, PlotProps)