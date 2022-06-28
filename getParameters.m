function P = getParameters()
% Paramters used for multiple scripts

P.Sessions = {'BaselinePre', 'BaselinePost', 'MainPre', 'Main1', 'Main2', ...
    'Main3', 'Main4', 'Main5', 'Main6', 'Main7', 'Main8', 'MainPost'};

Labels.Sessions = {'BL-Pre', 'BL-Post', 'Pre', '4:00', '7:00', '10:00', ...
    '15:00', '17:30', '20:00', '23:00', '2:40', 'Post'};

P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.Gender = {'M', 'M', 'M', 'F', 'M', 'F', 'F', 'M'...
    'F', 'F', 'M', 'M', 'M', 'F', 'F', 'F', 'M', 'F'};

P.Labels = Labels;



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

P.Paths = Paths;

addpath(genpath(extractBefore(mfilename('fullpath'), 'getParameters'))) % add current repo's functions

% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addchARTpaths() % TODO, find in folder automatically
end
