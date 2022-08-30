function Info = burstParameters()
% parameters for detecting bursts

Info = struct();

Info.Tasks = {'Fixation', 'Standing', 'Oddball'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Burst Parameters

%%% parameters to find bursts in single channels

Info.Min_Peaks = 4;

% parameters for prominent oscillations
Clean_BT = struct();
Clean_BT.isProminent = 1;
Clean_BT.periodConsistency = .7;
Clean_BT.periodMeanConsistency = .7;
Clean_BT.truePeak = 1;
Clean_BT.efficiencyAdj = .6;
Clean_BT.flankConsistency = .5;
Clean_BT.ampConsistency = .25;

Info.Clean_BT = Clean_BT;

% parameters for other oscillations
Dirty_BT = struct();
Dirty_BT.monotonicity = .8;
Dirty_BT.periodConsistency = .6;
Dirty_BT.periodMeanConsistency = .6;
Dirty_BT.efficiency = .8;
Dirty_BT.truePeak = 1;
Dirty_BT.flankConsistency = .5;
Dirty_BT.ampConsistency = .5;

Info.Dirty_BT = Dirty_BT;

%%% Parameters to aggregate across channels
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

% same for matcycle scripts, saved to a different repo (https://github.com/hubersleeplab/matcycle)
if ~exist('addMatcyclePaths.m', 'file')
    addMatcyclePaths() % TODO, find in folder automatically
end


% get path where these scripts were saved
CD = mfilename('fullpath');
% Paths.Analysis = fullfile(extractBefore(Paths.Analysis, 'Analysis'));
Paths.Analysis = fullfile(extractBefore(CD, '2process_Bursts'), '2process_Bursts');

% get all folders in functions
Subfolders = deblank(string(ls(fullfile(Paths.Analysis, 'functions')))); % all content
Subfolders(contains(Subfolders, '.')) = []; % remove all files

for Indx_F = 1:numel(Subfolders)
    addpath(fullfile(CD, Subfolders{Indx_F}))
end

Info.Paths = Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EEG info

% bands used to get burtsts
Bands.ThetaLow = [2 6];
Bands.Theta = [4 8];
Bands.ThetaAlpha = [6 10];
Bands.Alpha = [8 12];

% % bands used to 
% PowerBands.Delta = [1 4];
% PowerBands.Theta = [4 8];
% PowerBands.Alpha = [8 12];
% PowerBands.Beta = [15 25];
% Info.PowerBands = PowerBands;

Info.Bands = Bands;


