close all
clc
clear

addpath('C:\Users\colas\Code\2Process_Bursts\Analysis')
P = analysisParameters();
PlotProps = P.Manuscript;
PlotProps.Text.FontSize = PlotProps.Text.AxisSize;
PlotProps.Line.Width = 5;

% SleepStarts = [-1 23, 47]; % hours from first midnight
SleepStarts = [0 28 ]; % hours from first midnight
SleepEnds = SleepStarts+[4 7];
SleepMidpoint = 3.5; % circadian midpoint of sleep

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.5 PlotProps.Figure.Height*0.28])

hold on


% homeostatic curve
PlotProps.Color = 'k';
plot2process(SleepStarts, SleepEnds, SleepMidpoint, 'homeostatic',  PlotProps);

PlotProps.Color = getColors(1, '', 'gray');
plot2process(SleepStarts, SleepEnds, SleepMidpoint, 'circadian',  PlotProps);


% background information
PlotProps.Color = 'k';
plot2process(SleepStarts, SleepEnds, SleepMidpoint, 'labels', PlotProps);


legend({'Sleep homeostasis', 'Circadian rhythm'})
set(legend, 'location', 'northwest')
ylim([0 4])

PlotProps = P.Manuscript;
PlotProps.Color.Background = 'none';
set(gca, 'Color', 'none')
saveFig('dummy2process', P.Paths.Paper, PlotProps)
