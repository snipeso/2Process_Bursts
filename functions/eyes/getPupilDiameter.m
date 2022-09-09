function [AllDiameters] = getPupilDiameter(Path, Participants, Sessions, Task)
% calculates mean pupil diameter and similar measures

MinData = 1/3; % proportion of data that must still be present to be used in analysis

AllDiameters = nan(numel(Participants), numel(Sessions));

for Indx_P = 1:numel(Participants)

    PrcntData = nan(2, numel(Sessions));
    Diameter = PrcntData;

    for Indx_S = 1:numel(Sessions)



        Filename =  strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Pupils.mat'}, '_');
        if ~exist(fullfile(Path, Filename), 'file')
            warning([Filename, ' doesnt exist'])
            continue
        end

        load(fullfile(Path, Filename), 'Rightdata', 'Leftdata')

        % get proportion of data included in file for each eye
        PrcntData(1, Indx_S) = nnz(~isnan(Leftdata(:, 2)))/size(Leftdata, 1);
        PrcntData(2, Indx_S) = nnz(~isnan(Rightdata(:, 2)))/size(Rightdata, 1);

        % calculate diameter
        Diameter(1, Indx_S) = mean(Leftdata(:, 2), 'omitnan');
        Diameter(2, Indx_S) = mean(Rightdata(:, 2), 'omitnan');

    end

    % select eye with largest amount of clean data
    PrcntData(PrcntData<MinData) = nan;
    nCleanRecordings = sum(~isnan(PrcntData), 2);
    [~, CleanestEye] = max(nCleanRecordings);

    % remove from that eye any recordings that don't have enough data
    Diameter = Diameter(CleanestEye, :);
    PrcntData = PrcntData(CleanestEye, :);
    Diameter(isnan(PrcntData)) = nan;

    AllDiameters(Indx_P, :) = Diameter;

    disp(['Finished ', Participants{Indx_P}])
end


