% Script to load in pupillometry data

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters


P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Tasks = {'Fixation', 'Oddball'};

TitleTag = 'Pupillometry';

SmoothFactor=.2; % for response plots

% load diameter
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean');
[AllDiameters, sdAllDiameters] = getPupilDiameter(Path, Participants, Sessions, Tasks);

zAllDiameters = zScoreData(AllDiameters, 'first');
zsdAllDiameters = zScoreData(sdAllDiameters, 'first');

% load trial response
Path = fullfile(Paths.Preprocessed, 'Pupils', 'Clean', 'Oddball');
[Timecourse, t, AverageBaselines, MissingData] = getPupilOddball(Path, Participants, Sessions);

sTimecourse = smoothFreqs(Timecourse, t, 'last', SmoothFactor);
zTimecourse = zScoreData(sTimecourse, 'first');

% area under the curve
Range = [0.5 2];
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

% save z-timecorse
Data = zTimecourse;
save(fullfile(Paths.Pool, [TitleTag, '_OddballResponse.mat']), 'Data', 't')

