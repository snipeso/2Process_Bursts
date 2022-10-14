clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters


P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = {'Fixation', 'Oddball'};
Colors = P.TaskColors(1:2, :);
XLabels = Labels.Sessions;

TitleTag = 'Pupillometry';


% load diameter
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean');
[AllDiameters, sdAllDiameters] = getPupilDiameter(Path, Participants, Sessions, Tasks);

zAllDiameters = zScoreData(AllDiameters, 'first');
zsdAllDiameters = zScoreData(sdAllDiameters, 'first');

% load trial response
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean', 'Oddball');
[Timecourse, t, AverageBaselines, MissingData] = getPupilOddball(Path, Participants, Sessions);

zTimecourse = zScoreData(Timecourse, 'first');

% area under the curve
Range = [0.5 1.8];
[AuC] = extractOddballValues(Timecourse, t, Range); 
[zAuC] = extractOddballValues(zTimecourse, t, Range); 

%% save to pool

% mean diameter
Data = AllDiameters; % P x S x T
save(fullfile(Paths.Pool, [TitleTag, '_meanDiameter.mat']), 'Data')

% standard deviation of diameter
Data = sdAllDiameters; % P x S x T
save(fullfile(Paths.Pool, [TitleTag, '_stdDiameter.mat']), 'Data')

% z-scored mean diameter
Data = zAllDiameters; % P x S x T
save(fullfile(Paths.Pool, [TitleTag, '_z-scoredmeanDiameter.mat']), 'Data')

% z-scored standard deviation of diameter
Data = zsdAllDiameters; % P x S x T
save(fullfile(Paths.Pool, [TitleTag, '_z-scoredstdDiameter.mat']), 'Data')

% AuC
Data = AuC; % P x S
save(fullfile(Paths.Pool, [TitleTag, '_AuC.mat']), 'Data')

% AuC z-scored
Data = zAuC; % P x S
save(fullfile(Paths.Pool, [TitleTag, '_zAuC.mat']), 'Data')
