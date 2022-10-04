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
Tasks = P.Tasks;


% pupil diameter
Task = 'Fixation';
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean', Task);
 [AllDiameters] = getPupilDiameter(Path, Participants, Sessions, Task);

zAllDiameters = zScoreData(AllDiameters, 'first');
% PUI



% 

%%
% YLim = [2 8];
YLim = [];
% StatParameters = StatsP;
StatParameters = StatsP;
Flip = false;


  figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.6])

     plotBrokenSpaghetti(AllDiameters, [], YLim, ...
                    StatParameters, PlotProps.Color.Participants, Flip, PlotProps)
     title('Diameter')