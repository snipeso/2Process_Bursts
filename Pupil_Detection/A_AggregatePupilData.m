% goes through "raw" folder structure, gets relevant file, then saves into
% mat in destination.
% from 2process_Bursts.
clear
clc
close all

P = pupilParameters();
Paths = P.Paths;
Tasks = P.Tasks;

Refresh = false;

% get folders to search through
IgnoreFolders = {'Applicants', 'P00', 'CSVs', 'Lazy', 'PXX_Questionnaires', 'Uncertain'};
[Subfolders, Participants] = AllFolderPaths(Paths.Raw, 'PXX', false, IgnoreFolders);
Subfolders(~contains(Subfolders, 'EyeTracking')) = [];


for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};

    Sources = Subfolders(contains(Subfolders, Task));

    % set up destination
    Destination = fullfile(Paths.Preprocessed, 'Raw', Task);
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end

    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sources)

            % get new filename, see if it already exists
            Levels = split(Sources{Indx_S}, '\');
            Session = Levels{end-1};
            Filename = strjoin({Participants{Indx_P}, Task, Session, 'Pupils.mat'}, '_');
            if exist(fullfile(Destination, Filename), 'file') && ~Refresh
                disp(['Already did ', Filename])
                continue
            end

            % get latest folder
            Source = fullfile(Paths.Raw, Participants{Indx_P}, Sources{Indx_S}, 'exports');
            Content = string(ls(Source));
            Content(contains(Content, '.')) = [];

            if isempty(Content)
                warning([char(Source), ' is empty'])
                continue
            end
            Source = fullfile(Source, Content(end));

            % load annotations
            if exist(fullfile(Source, 'annotations.csv'), 'file')
                Annotations = readtable(fullfile(Source, 'annotations.csv'));
            else
                warning([char(Source), ' annotations doesnt exist'])
                Annotations = [];
            end

            % load pupil data
            if exist(fullfile(Source, 'pupil_positions.csv'), 'file')
                Pupil = readtable(fullfile(Source, 'pupil_positions.csv'));
            else
                warning([char(Source), ' pupil_positions doesnt exist'])
                continue
            end

            % save to new destination with standard filename
            save(fullfile(Destination, Filename), 'Annotations', 'Pupil')
            disp(['Finished ', Filename])
        end
    end
end

