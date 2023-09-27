


load(fullfile('E:\Data\Preprocessed\Clean\Waves\Oddball', 'P10_Oddball_Main7_Clean.mat'), 'EEG')

P = analysisParameters();
PlotProps = P.Powerpoint;
PlotProps.Color.Background = 'none';
figure('units', 'normalized', 'Position',[0 0 .5 .5])
Axes = chART.sub_plot([], [1 1], [1, 1], [], false, '', PlotProps);

Data = EEG.data(labels2indexes(77, EEG.chanlocs), EEG.srate*315.2:EEG.srate*316.75);
t = linspace(0, numel(Data)/EEG.srate, numel(Data));
plot(t, Data, 'LineWidth', 3, 'Color', 'k')


hold on

Burst = 147:242;

plot(t(Burst), Data(Burst), 'LineWidth', 6, 'Color', getColors(1, '', 'red'))
axis off

chART.save_figure('Example_Burst', P.Paths.Powerpoint, PlotProps)






