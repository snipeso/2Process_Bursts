function [AllDiameters, AllPUI] = getPupilDiameter(Path, Participants, Sessions, Tasks)
% calculates mean pupil diameter and similar measures

MinData = 1/3; % proportion of data that must still be present to be used in analysis

AllDiameters = nan(numel(Participants), numel(Sessions), numel(Tasks));
AllPUI = AllDiameters;


for Indx_P = 1:numel(Participants)

    PrcntData = nan(2, numel(Sessions), numel(Tasks));
    Diameter = PrcntData;
    PUI = PrcntData;
    for Indx_S = 1:numel(Sessions)

        for Indx_T = 1:numel(Tasks)
            Task = Tasks{Indx_T};

            Filename =  strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Pupils.mat'}, '_');
            if ~exist(fullfile(Path, Task, Filename), 'file')
                warning([Filename, ' doesnt exist'])
                continue
            end

            load(fullfile(Path, Task, Filename), 'Rightdata', 'Leftdata')

            for Indx_E = 1:2
                if Indx_E ==1
                    EyeData = Leftdata;
                else
                    EyeData = Rightdata;
                end

                % get proportion of data included in file for each eye
                PrcntData(Indx_E, Indx_S, Indx_T) = nnz(~isnan(EyeData(:, 2)))/size(EyeData, 1);

                % calculate diameter
                Diameter(Indx_E, Indx_S, Indx_T) = mean(EyeData(:, 2), 'omitnan');

                %PUI
                aa = movmean(EyeData(:, 2), 32, 'omitnan', 'Endpoints', 'discard');
                bb = aa(1:32:end);
                PUI(Indx_E, Indx_S, Indx_T) = sum(abs(diff(bb)), 'omitnan');

            end
        end
    end

    % select eye with largest amount of clean data
    PrcntData(PrcntData<MinData) = nan;
    nCleanRecordings = sum(sum(~isnan(PrcntData), 2), 3);
    [~, CleanestEye] = max(nCleanRecordings);

    % remove from that eye any recordings that don't have enough data
    Diameter = Diameter(CleanestEye, :, :);
    PrcntData = PrcntData(CleanestEye, :, :);
    Diameter(isnan(PrcntData)) = nan;
    AllDiameters(Indx_P, :, :) = Diameter;

    PUI = PUI(CleanestEye, :, :);
    PUI(isnan(PrcntData)) = nan;
    AllPUI(Indx_P, :, :) = PUI;

    disp(['Finished ', Participants{Indx_P}])
end


