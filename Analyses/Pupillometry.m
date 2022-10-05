% change in time of pupillometry measurements
clear
clc
close all




P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = {'Fixation', 'Oddball'};
Colors = P.TaskColors(1:2, :);

% pupil diameter
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean');
 [AllDiameters] = getPupilDiameter(Path, Participants, Sessions, Tasks);

zAllDiameters = zScoreData(AllDiameters, 'first');
% PUI



% 

%%
% YLim = [2 8];
YLim = [];
% StatParameters = StatsP;
StatParameters = StatsP;
Flip = false;


  figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.5 PlotProps.Figure.Height*0.3])
plotBrokenRain(zAllDiameters, [], [], Colors, Tasks, PlotProps)
ylabel('Diameter (mm) (z-scored)')
     title('Diameter')

saveFig('Diameter', Paths.Paper, PlotProps)
