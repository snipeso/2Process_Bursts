function Durations = loadBurstDuration(Path, Participants, Sessions, Tasks, Bands)
% gets durations of 

BandLabels = fieldnames(Bands);
Durations = nan(numel(Participants), numel(Sessions), numel(Tasks), numel(BandLabels));

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            %%% Load data
            Task = Tasks{Indx_T};
            Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Bursts.mat'}, '_');
            if ~exist(fullfile(Path, Task, Filename), 'file')
                warning(['Skipping ', Filename])
                continue
            end

            load(fullfile(Path, Task, Filename), 'Bursts', 'EEG')

            % Get duration of clean data
            Valid_T = EEG.keep_points;

            % Only consider bursts in valid times
            Frequencies = [Bursts.Frequency];
            for Indx_B = 1:numel(BandLabels)
                Band = Bands.(BandLabels{Indx_B});
                BurstTime = bursts2time(Bursts(Frequencies>=Band(1) & Frequencies<Band(2)), numel(Valid_T));
                BurstTime = BurstTime & Valid_T; % just to be sure

                Durations(Indx_P, Indx_S, Indx_T, Indx_B) = nnz(BurstTime)/nnz(Valid_T);
            end
        end
    end
    disp(['Finished' Participants{Indx_P}])
end