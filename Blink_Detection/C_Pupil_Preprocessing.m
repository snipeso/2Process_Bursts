% Scripts for cleaning pupil data (removing blinks, artefacts, etc) using
% PhysioData toolbox.
% Scripts by Elias Meier, modified by Sophia Snipes.

clear
close all
clc

P = pupilParameters();
paths = P.Paths;
Tasks = P.Tasks;
Refresh = true;

MaxCloseGap = 0.5; % largest gap size to interpolate
MinChunkSize = 0.5; % smallest allowable chunk of data

addpath(paths.dataModels);
addpath(paths.helperfunctions);

for Indx_T = 1:numel(Tasks)
    task = Tasks{Indx_T};
    all_files = dir(fullfile(paths.Preprocessed, 'Raw_mm', task));
    all_files(ismember({all_files.name}, {'.', '..'})) = [];

    Destination = fullfile(paths.Preprocessed, 'Clean', task);
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end

    for Indx_AF = 1:size(all_files)
        filename = all_files(Indx_AF).name;

        if exist(fullfile(Destination, filename), 'file') && ~Refresh
            continue
        end

        load(fullfile(paths.Preprocessed, 'Raw_mm', task, filename), 'diameter');

        try
            M = PupilDataModel([paths.Preprocessed,'\Raw_mm\', task, '\'], filename, PupilDataModel.getDefaultSettings);
            M.filterRawData
            M.processValidSamples
            M.analyzeSegments
            M.plotData
            object = struct(M);
        catch
            clc
            warning(['Failed ', filename])
            continue
        end

        % Make sure left,right,mean in one trial have same length!
        old_t = diameter.t_ms;
        L_new_t = M.leftPupil_ValidSamples.samples.t_ms;
        R_new_t = M.rightPupil_ValidSamples.samples.t_ms;
        Mean_new_t = M.meanPupil_ValidSamples.samples.t_ms;
        L_new_dia = M.leftPupil_ValidSamples.samples.pupilDiameter;
        R_new_dia = M.rightPupil_ValidSamples.samples.pupilDiameter;
        Mean_new_dia = M.meanPupil_ValidSamples.samples.pupilDiameter;
        [Rightdata, Leftdata, Meandata] = EqualizeLength(old_t, L_new_t, R_new_t, Mean_new_t, L_new_dia, R_new_dia, Mean_new_dia);

        Old = Leftdata;

        % get sampling rate
        fs = 1/(mode(diff(old_t))/1000);
        RD = Rightdata; % temp

        % fill in short gaps with linear interpolation
        Rightdata(:, 2) = closeGaps(Rightdata(:, 2), fs, MaxCloseGap);
        Leftdata(:, 2) = closeGaps(Leftdata(:, 2), fs, MaxCloseGap);

        % remove little chunks of data
        Rightdata(:, 2) = removeDebris(Rightdata(:, 2), fs, MinChunkSize);
        Leftdata(:, 2) = removeDebris(Leftdata(:, 2), fs, MinChunkSize);


        save(fullfile(Destination, filename), 'Rightdata', 'Leftdata', 'Meandata', 'fs')

        if contains(filename, 'BaselinePost')
            close all
        end
    end
end

close all






