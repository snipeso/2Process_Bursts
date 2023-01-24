% adds all the paths to all the external functions I use. Probably a
% sub-optimal solution, but dealing with submodules is a bitch.
% in 2process_Bursts

disp('Adding external functions...')

Path = mfilename('fullpath');
Path = extractBefore(Path, 'addExternalFunctions');

SubFolders = getContent(Path);
SubFolders(contains(SubFolders, '.')) = [];

for Indx_F = 1:numel(SubFolders)
    disp(['Add ', SubFolders{Indx_F}])
   addpath(fullfile(Path, SubFolders(Indx_F)))
end