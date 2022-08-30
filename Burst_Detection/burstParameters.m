function Info = burstParameters()
% parameters for detecting bursts

Info = struct();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

Info.MinCoherence = .75;
Info.MinCorr = .8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

if exist( 'D:\Data\Raw', 'dir')
    Core = 'D:\Data\';
elseif exist( 'F:\Data\Raw', 'dir')
    Core = 'F:\Data\';
elseif  exist( 'E:\Data\Raw', 'dir')
    Core = 'E:\Data\';
else
    error('no data disk!')
% Core = 'E:\'
end

Paths.Preprocessed = fullfile(Core, 'Preprocessed');
Paths.Core = Core;

Paths.Datasets = 'G:\LSM\Data\Raw';
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.Results = fullfile(Core, 'Results', 'Theta_Bursts');

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addchARTpaths() % TODO, find in folder automatically
end

% same for matcycle scripts, saved to a different repo (https://github.com/hubersleeplab/matcycle)
if ~exist('addMatcyclePaths.m', 'file')
    addMatcyclePaths() % TODO, find in folder automatically
end


% get path where these scripts were saved
CD = mfilename('fullpath');
% Paths.Analysis = fullfile(extractBefore(Paths.Analysis, 'Analysis'));
Paths.Analysis = fullfile(extractBefore(CD, 'Theta_Bursts'), 'Theta-SD-vs-WM');

addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','tasks'))
addpath(fullfile(Paths.Analysis, 'functions','stats'))
addpath(fullfile(Paths.Analysis, 'functions','questionnaires'))
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))


% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, '\ThetaDetection\'));

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','tasks'))
addpath(fullfile(Paths.Analysis, 'functions','stats'))
addpath(fullfile(Paths.Analysis, 'functions','pupils'))
addpath(fullfile(Paths.Analysis, 'functions','external'))


Info.Paths = Paths;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting settings
% These use chART (https://github.com/snipeso/chART) plots. Each figure
% takes a struct that holds all the parameters for plotting (e.g. font
% names, sizes, etc). These are premade in chART, but can be customized.


% plot sizes depending on which screen being used
Pix = get(0,'screensize');
if Pix(3) < 2000
    Format = getProperties({'LSM', 'SmallScreen'});
else
    Format = getProperties({'LSM', 'LargeScreen'});
end

Manuscript = getProperties({'LSM', 'Manuscript'});
Powerpoint =  getProperties({'LSM', 'Powerpoint'});
Poster =  getProperties({'LSM', 'Poster'});

Info.Manuscript = Manuscript; % for papers
Info.Powerpoint = Powerpoint; % for presentations
Info.Poster = Poster;
Info.Format = Format; % plots just to view data


% ROIs selected independently of data
Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];
Backspot = [66 71 76 84 65 70 75 83 90 69 74 82 89];
Centerspot = [129 7 106 80 55 31 30 37 54 79 87 105 36 42 53 61 62 78 86 93 104 35 41 47  52 92 98 103 110, 60 85 51 97];

Channels.preROI.Front = Frontspot;
Channels.preROI.Center = Centerspot;
Channels.preROI.Back = Backspot;


Frontspot = [128 32 33 34 25 26 27 28 29 23 24 20 13 21 22 18 19 12 6 17 15 16 11 14 9 10 4 5  8 2 3 124 118 112 1 123 117 111 125 122 116];
Backspot = [64 59 60 61 68 65 66 67 69 70 71 73 74 81 75 72 62 82 88 83 76 89 84 77 78 94 90 85 91 95];

Channels.bigROI.Front = Frontspot;
Channels.bigROI.Back = Backspot;

Format.Colors.preROI = getColors(numel(fieldnames(Channels.preROI)));
Format.Colors.bigROI = getColors(numel(fieldnames(Channels.bigROI)));

Channels.Remove = [49 56 107 113 126 127 17 48 119];

Info.Channels = Channels;



Bands.ThetaLow = [2 6];
Bands.Theta = [4 8];
Bands.ThetaAlpha = [6 10];
Bands.Alpha = [8 12];

PowerBands.Delta = [1 4];
PowerBands.Theta = [4 8];
PowerBands.Alpha = [8 12];
PowerBands.Beta = [15 25];
Info.PowerBands = PowerBands;

Info.Bands = Bands;

Triggers.SyncEyes = 'S192';
Triggers.Start = 'S  1';
Triggers.End = 'S  2';
Triggers.Stim = 'S  3';
Triggers.Resp = 'S  4';

Info.Triggers = Triggers;


StatsP = struct();

StatsP.ANOVA.ES = 'eta2';
StatsP.ANOVA.ES_lims = [0 1];
StatsP.ANOVA.nBoot = 2000;
StatsP.ANOVA.pValue = 'pValueGG';
StatsP.ttest.nBoot = 2000;
StatsP.ttest.dep = 'pdep'; % use 'dep' for ERPs, pdep for power
StatsP.Alpha = .05;
StatsP.Trend = .1;
StatsP.Paired.ES = 'hedgesg';
StatsP.Paired.Benchmarks = -2:.5:2;
StatsP.FreqBin = 1; % # of frequencies to bool in spectrums stats
StatsP.minProminence = .1; % minimum prominence for when finding clusters of g values
Info.StatsP = StatsP;


Labels.logBands = [1 2 4 8 16 32]; % x markers for plot on log scale
Labels.Bands = [1 4 8 15 25 35 40]; % normal scale
Labels.FreqLimits = [1 40];
Labels.zPower = 'PSD z-scored';
Labels.Power = 'PSD Amplitude (\muV^2/Hz)';
Labels.logPower = 'log PSD';
Labels.Frequency = 'Frequency (Hz)';
Labels.Epochs = {'Encoding', 'Retention1', 'Retention2', 'Probe'}; % for M2S task
Labels.Amplitude = 'Amplitude (\muV)';
Labels.Time = 'Time (s)';
Labels.ES = "Hedge's G";
Labels.t = 't-values';
Labels.Correct = '% Correct';
Labels.RT = 'RT (s)';

Info.Labels = Labels;