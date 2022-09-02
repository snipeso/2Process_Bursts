function plotBrokenSpaghetti(Data, YLabels, YLims, StatsP, Colors, Flip, PlotProps)
% Plots a confetti spaghetti plot but with gaps and dotted lines to reflect
% overnight changes vs day changes

XPoints = [-8 -4 0 4 7 10 14.5 17.5 20 23 26.5 30];
XLabels = {'BL 23:00', 'BL 10:00', '23:00', '4:00', '7:00', '10:00', ...
    '15:00', '17:30', '20:00', '23:00', '2:40', 'Post'};
Dots = ':';

Sleep = [1:2; 3:4; 11:12];
Wake = 4:11;


if ~isempty(StatsP)
    Stats = pairedttest(Data, [], StatsP);
else
    Stats = [];
    % TODO: plot stars for group comparison
end

% set y axis
if~isempty(YLims)
    ylim(YLims)
    
    if ~isempty(YLabels)
        yticks(linspace(YLims(1), YLims(2), numel(YLabels)))
        yticklabels(YLabels)
    end
end

Dims = size(Data);

% assign rainbow colors if none are provided
if isempty(Colors)
    Colors = reduxColormap(PlotProps.Color.Maps.Rainbow, Dims(1));
end

Colors = makePale(Colors, .4);

%%% plot each participant
hold on
for Indx_P = 1:Dims(1)
    Color = Colors(Indx_P, :);

    % plot overnight changes
    for Indx_N = 1:size(Sleep, 1)
        plot(XPoints(Sleep(Indx_N, :)), Data(Indx_P, Sleep(Indx_N, :)), Dots, 'LineWidth', PlotProps.Line.Width/2, ...
            'Color', Color, 'HandleVisibility', 'off')

        scatter(XPoints(Sleep(Indx_N, :)), Data(Indx_P, Sleep(Indx_N, :)), PlotProps.Scatter.Size/2, ...
            'MarkerFaceColor', Color, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off')
    end

    % plot day changes
    plot(XPoints(Wake), Data(Indx_P, Wake), 'LineWidth', PlotProps.Line.Width/2, ...
        'Color', Color, 'HandleVisibility', 'off')

    scatter(XPoints(Wake), Data(Indx_P, Wake), PlotProps.Scatter.Size/2, ...
        'MarkerFaceColor', Color, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off')
end


%%% plot group means
[ColorGroups, ~, Groups] = unique(Colors, 'rows');
TotGroups = size(ColorGroups, 1);

% get means
if TotGroups == Dims(1) % if there's one color per participant, so no special groups

    MEANS = mean(Data, 1, 'omitnan');
    ColorGroups = [0 0 0];

elseif  TotGroups == 1 % if there's one color for all values

    MEANS = mean(Data, 1, 'omitnan');

else
    % plot a separate mean for each color group
    MEANS = nan(TotGroups, Dims(2));

    for Indx_G = 1:TotGroups
        MEANS(Indx_G, :) = mean(Data(Groups==Indx_G, :), 'omitnan');
    end
end

% plot means
for Indx_G = 1:size(MEANS, 1)

    % plot night
    for Indx_N = 1:size(Sleep, 1)
        plot(XPoints(Sleep(Indx_N, :)), MEANS(Indx_G, Sleep(Indx_N, :)), Dots, 'LineWidth', PlotProps.Line.Width, ...
            'Color', ColorGroups(Indx_G, :),  'HandleVisibility', 'off')

        scatter(XPoints(Sleep(Indx_N, :)), MEANS(Indx_G, Sleep(Indx_N, :)), PlotProps.Scatter.Size, ...
            'filled', 'MarkerFaceColor', ColorGroups(Indx_G, :),  'MarkerEdgeColor', ColorGroups(Indx_G, :), 'HandleVisibility', 'off')
    end

    % plot day
    plot(XPoints(Wake), MEANS(Indx_G, Wake), 'LineWidth', PlotProps.Line.Width, ...
        'Color', ColorGroups(Indx_G, :), 'HandleVisibility', 'on')
    scatter(XPoints(Wake), MEANS(Indx_G, Wake), PlotProps.Scatter.Size, ColorGroups(Indx_G, :), ...
        'filled', 'MarkerEdgeColor',  ColorGroups(Indx_G, :), 'HandleVisibility', 'off')
end

% plot significance stars on top
if ~isempty(Stats)
    plotHangmanStars(Stats, XPoints, [], ColorGroups, PlotProps)
end


% set x axis
xlim([XPoints(1)-2 XPoints(end)+2])
xticks(XPoints)
xticklabels(XLabels)

% adjust y axis
if Flip && mean(MEANS(:, 11))<mean(MEANS(:, 4)) % if SD is lower than BL
    set(gca, 'YDir','reverse')
end


set(gca, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)