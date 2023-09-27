function plotSimpleChange(Data, xLabels, Colors, PlotProps)
% Data is a P x T x S(2) matrix, where separate line plots are done for each T

Dims = size(Data);

% Colors = makePale(Colors, .4);

hold on

for Indx_T = 1:Dims(2)
    X = Indx_T + [-0.35 .35];

    for Indx_P = 1:Dims(1)
        Y = squeeze(Data(Indx_P, Indx_T, :));
        C = Colors(Indx_P, :);
        plot(X, Y, '-', 'MarkerFaceColor', C, 'Color', [C, 0.5], 'LineWidth', PlotProps.Line.Width);
%         scatter(X, Y, PlotProps.Line.MarkerSize, C, 'filled', 'MarkerFaceAlpha', 0.5)
    end
end

% group labels
xticks(1:Dims(2))
if ~isempty(xLabels)
xticklabels(xLabels)
end
xlim([0.35 Dims(2)+0.65])

chART.set_axis_properties(PlotProps)