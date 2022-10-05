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
 [AllDiameters, AllPUI] = getPupilDiameter(Path, Participants, Sessions, Tasks);

zAllDiameters = zScoreData(AllDiameters, 'first');
zAllPUI = zScoreData(AllPUI, 'first');



% 

%%
% YLim = [2 8];
YLim = [];
% StatParameters = StatsP;
StatParameters = StatsP;
Flip = false;
Grid = [1, 2];
Indx=1;

  figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.3])

  A = subfigure([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(zAllDiameters, [], [], Colors, Tasks, PlotProps)
ylabel('Diameter (mm) (z-scored)')
     title('Diameter')

       A = subfigure([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
plotBrokenRain(zAllPUI, [], [], Colors, Tasks, PlotProps)
ylabel('PUI (z-scored)')
     title('PUI')

saveFig('Diameter', Paths.Paper, PlotProps)
