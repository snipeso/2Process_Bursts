function yTitle(XShift, Text, PlotProps)

  X = get(gca, 'XLim');
    Y = get(gca, 'YLim');
    text(X(1)-diff(X)*XShift, Y(1)+diff(Y)*.5, Text, ...
        'FontSize', PlotProps.Text.TitleSize, 'FontName', PlotProps.Text.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);