function Info = burstParameters()
% parameters for detecting bursts

Info = struct();

Info.Tasks = {'Fixation', 'Standing', 'Oddball'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Burst Parameters

%%% parameters to find bursts in single channels

Info.Min_Peaks = 4;

Info.Max_Minutes = 6; % first number of clean minutes to look for bursts in

% BurstThresholds = struct();
% BurstThresholds.monotonicity = .6;
% BurstThresholds.periodConsistency = .6;
% BurstThresholds.periodMeanConsistency = .6;
% BurstThresholds.efficiency = .6;
% BurstThresholds.truePeak = 1;
% BurstThresholds.flankConsistency = .5;
% BurstThresholds.ampConsistency = .6;
% Info.BurstThresholds = BurstThresholds;

% short
BT = struct();
BT(1).periodConsistency = .3;
BT(1).amplitude = 25;
BT(1).Min_Peaks = 3;
BT(1).isProminent = 1;
BT(1).truePeak = 1;

% long
BT(2).monotonicity = .5;
BT(2).periodConsistency = .5;
BT(2).periodMeanConsistency = .5;
BT(2).efficiency = .6;
BT(2).truePeak = 1;
BT(2).flankConsistency = .5;
BT(2).ampConsistency = .5;
% BT(2).efficiencyAdj = .5; TODO????
BT(2).Min_Peaks = 6;


% clean
BT(3).monotonicity = .6;
BT(3).periodConsistency = .6; % C
BT(3).periodMeanConsistency = .6;
BT(3).efficiency = .6;
BT(3).truePeak = 1; % A
BT(3).flankConsistency = .5; % D
BT(3).ampConsistency = .6;% E
BT(3).Min_Peaks = 4;

Info.BurstThresholds = BT;



%%% Parameters to aggregate across channels
Info.MinCoherence = .7;
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
addMatcyclePaths()

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

% bands used to get bursts
Bands.ThetaLow = [2 6];
Bands.Theta = [4 8];
Bands.ThetaAlpha = [6 10];
Bands.Alpha = [8 12];
Bands.AlphaHigh = [10 14];

% % bands used to
% PowerBands.Delta = [1 4];
% PowerBands.Theta = [4 8];
% PowerBands.Alpha = [8 12];
% PowerBands.Beta = [15 25];
% Info.PowerBands = PowerBands;

Info.Bands = Bands;


