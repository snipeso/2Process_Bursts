function plotBrokenRain(Data, YLabels, YLims, Colors, Legend, PlotProps)
% Data is a P x S x T matrix, Colors is a T x 3 matrix.


XPoints = [-8 -4 0 4 7 10 14.5 17.5 20 23 26.5 30];
TaskWidth = 0.6;

% XLabels = {'BL Pre (23:00)', 'BL Post (10:00)', 'Pre (23:00)', 'SD1 (4:00)', 'SD2 (7:00)', 'SD3 (10:00)', ...
%     'SD4 (15:00)', 'SD5 (17:30)', 'SD6 (20:00)', 'SD7 (23:00)', 'SD8 (2:40)', 'Post'};

XLabels = {'BL Pre', 'BL Post', 'Pre', 'SD1', 'SD2', 'SD3', ...
    'SD4', 'SD5', 'SD6', 'SD7', 'SD8', 'Post'};
Dots = ':';

Sleep = [1:2; 3:4; 11:12];
Wake = 4:11;

% set y axis
if~isempty(YLims)
    ylim(YLims)

    if ~isempty(YLabels)
        yticks(linspace(YLims(1), YLims(2), numel(YLabels)))
        yticklabels(YLabels)
    end

        x = XPoints(9)-1.3;
    y = YLims(1);
    w = 5.6;
    h = diff(YLims);
    rectangle('Position', [x, y, w, h], 'FaceColor', [0.05 .05 .05 .05], 'EdgeColor', 'none')

end

Dims = size(Data);

if Dims(3)>2
Shifts = linspace(-TaskWidth, TaskWidth, Dims(3)); % distance from center point for each task
elseif Dims(3)==2
    Shifts = [-.3 .3];
else
    Shifts = 0;
end



%%% plot each participant
hold on
for Indx_T = 1:Dims(3)
    Color = Colors(Indx_T, :);
    for Indx_S = 1:Dims(2)

    X = XPoints(Indx_S)+Shifts(Indx_T);
    scatter(X*ones(Dims(1), 1), squeeze(Data(:, Indx_S, Indx_T)), ...
        PlotProps.Scatter.Size/4, Color,'filled', 'MarkerFaceAlpha', PlotProps.Patch.Alpha, ...
        'HandleVisibility','off')
    end
end


%%% plot task means
for Indx_T = 1:Dims(3)
    
    Color = Colors(Indx_T, :);
    % plot night
    for Indx_N = 1:size(Sleep, 1)
        X = XPoints(Sleep(Indx_N, :)) + Shifts(Indx_T);
        MEAN = squeeze(mean(Data(:, Sleep(Indx_N, :), Indx_T), 1, 'omitnan'));
        
        plot(X, MEAN, Dots, 'LineWidth', PlotProps.Line.Width, ...
            'Color', Color,  'HandleVisibility', 'off') % connecting lines

        scatter(X, MEAN, PlotProps.Scatter.Size, 'filled', ...
            'MarkerFaceColor', Color,  'MarkerEdgeColor', Color, 'HandleVisibility', 'off') % mean dots
    end

    % plot day
    X = XPoints(Wake)+Shifts(Indx_T);
    MEAN = squeeze(mean(Data(:, Wake, Indx_T), 'omitnan'));
    
    plot(X, MEAN, 'LineWidth', PlotProps.Line.Width, ...
        'Color', Color, 'HandleVisibility', 'on')
    
    scatter(X, MEAN, PlotProps.Scatter.Size, Color, ...
        'filled', 'MarkerEdgeColor',  Color, 'HandleVisibility', 'off')
end


% set x axis
xlim([XPoints(1)-2 XPoints(end)+2])
xticks(XPoints)
xticklabels(XLabels)


setAxisProperties(PlotProps)

legend(Legend)
  set(legend, 'ItemTokenSize', [10 10])