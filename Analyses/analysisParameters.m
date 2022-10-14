function P = analysisParameters()
% analysis parameters for 2-process bursts paper

P.Sessions = {'BaselinePre', 'BaselinePost', 'MainPre', 'Main1', 'Main2', ...
    'Main3', 'Main4', 'Main5', 'Main6', 'Main7', 'Main8', 'MainPost'};

Labels.Sessions = {'BL-Pre', 'BL-Post', 'Pre', '4:00', '7:00', '10:00', ...
    '15:00', '17:30', '20:00', '23:00', '2:40', 'Post'};

P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.Gender = {'M', 'M', 'M', 'F', 'M', 'F', 'F', 'M'...
    'F', 'F', 'M', 'M', 'M', 'F', 'F', 'F', 'M', 'F'};

P.Nights = {'Baseline', 'NightPre', 'NightPost'};


Labels.logBands = [1 2 4 8 16 32]; % x markers for plot on log scale
Labels.Bands = [1 4 8 15 25 35 40]; % normal scale
Labels.FreqLimits = [1 40];
Labels.zPower = 'PSD z-scored';
Labels.Power = 'PSD Amplitude (\muV^2/Hz)';
Labels.Frequency = 'Frequency (Hz)';
Labels.Epochs = {'Encoding', 'Retention1', 'Retention2', 'Probe'}; % for M2S task
Labels.Amplitude = 'Amplitude (\muV)';
Labels.Time = 'Time (s)';
Labels.ES = "Hedge's G";
Labels.t = 't-values';
Labels.r = 'r-values';
Labels.Correct = '% Correct';
Labels.RT = 'RT (s)';
P.Labels = Labels;


P.Tasks = {'Fixation','Oddball',  'Standing'};


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
Paths.Results = fullfile(Core, 'Results', '2process_Bursts');
Paths.Pool = fullfile(Paths.Data, 'All_2processBursts');
Paths.Scoring = fullfile(Core, 'Scoring');
Paths.Paper = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper3\Figures';

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

P.Paths = Paths;

addpath(genpath(extractBefore(mfilename('fullpath'), 'getParameters'))) % add current repo's functions

% get path where these scripts were saved
CD = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(CD, '2process_Bursts'), '2process_Bursts');

% get all folders in functions
Subfolders = deblank(string(ls(fullfile(Paths.Analysis, 'functions')))); % all content
Subfolders(contains(Subfolders, '.')) = []; % remove all files

for Indx_F = 1:numel(Subfolders)
    addpath(fullfile(Paths.Analysis, 'functions', Subfolders{Indx_F}))
end




%%% chART stuff for plotting
% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addchARTpaths() % TODO, find in folder automatically
end

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

Manuscript.Figure.Padding = 25;
Manuscript.Axes.yPadding = 20;

P.TaskColors = flip(getColors(3));

P.Manuscript = Manuscript; % for papers
P.Powerpoint = Powerpoint; % for presentations
P.Poster = Poster;
P.Format = Format; % plots just to view data


%%% Stats

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
StatsP.Correlation = 'Spearman';
P.StatsP = StatsP;


P.XLabels = {'BL 23:00', 'BL 10:00', '23:00', '4:00', '7:00', '10:00', ...
    '15:00', '17:30', '20:00', '23:00', '2:40', 'Post'};



%%% EEG stuff

% ROIs selected independently of data
Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];
Backspot = [66 71 76 84 65 70 75 83 90 69 74 82 89];
Centerspot = [129 7 106 80 55 31 30 37 54 79 87 105 36 42 53 61 62 78 86 93 104 35 41 47  52 92 98 103 110, 60 85 51 97];

Channels.preROI.Front = Frontspot;
Channels.preROI.Center = Centerspot;
Channels.preROI.Back = Backspot;


All = 1:128;

All(ismember(All, [49, 56, 107, 113, 126, 127, 48, 63, 68, 73, 81, 88, 94, 99, 119])) = [];

Channels.All.All = All;

P.Channels = Channels;

Bands.Theta = [4 8];
Bands.Alpha = [8 12];


P.Bands = Bands;