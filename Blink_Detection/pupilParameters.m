function P = pupilParameters()
% assign parameters for pupil preprocessing scripts


Paths = struct();

Paths.Raw = 'G:\LSM\Data\Raw';
Paths.Preprocessed = 'E:\Data\Preprocessed\Pupils';
Paths.Data = 'E:\Data\Final\Eyes';
Paths.dataModels = 'C:\Users\colas\Projects\PhD\Others\pupil-size\code\dataModels';
Paths.helperfunctions = 'C:\Users\colas\Projects\PhD\Others\pupil-size\code\helperFunctions';

P.Paths = Paths;


P.Participants = {'P01','P02', 'P03', 'P04', 'P05', 'P06', 'P07','P08', ...
    'P09','P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.Sessions = {'BaselinePre', 'BaselinePost', 'Main1', 'Main2', 'Main3', 'Main4', ...
    'Main5', 'Main6', 'Main7', 'Main8', 'MainPre', 'MainPost'};

P.Tasks = {'Fixation', 'Oddball'};

P.new_srate = 50/1000;


% add path of functions
CD = mfilename('fullpath');

Paths_Analysis = fullfile(extractBefore(CD, 'Blink_Detection'), 'functions');

% % get all folders in functions
Subfolders = deblank(string(ls(fullfile(Paths_Analysis, 'functions')))); % all content
Subfolders(contains(Subfolders, '.')) = []; % remove all files

for Indx_F = 1:numel(Subfolders)
    addpath(fullfile(Paths_Analysis, 'functions', Subfolders{Indx_F}))
end





