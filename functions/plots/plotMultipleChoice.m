function plotMultipleChoice(Answers, Labels, xLabels, PlotProps)

Dims = size(Answers);
Data = zeros(numel(Labels), Dims(2));


for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2)
        A = Answers{Indx_P, Indx_S};
        A(isnan(A)) = [];
        
        if isempty(A)
            continue
        end
        Data(A, Indx_S) = Data(A, Indx_S)+1;
    end
end


h = bar(Data', .5, 'stacked');
xticklabels(xLabels)
ylabel('# answers')

Colors = flip(getColors(numel(h)));

for Indx_h = 1:numel(h)
    h(Indx_h).EdgeColor = 'none';
    h(Indx_h).FaceColor = Colors(Indx_h, :);
end

set(gca, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)
legend(Labels, 'location', 'northwest')

A=2'