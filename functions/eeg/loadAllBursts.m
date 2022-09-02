function [AllBursts, Missing, Durations] = loadAllBursts(Path, Participants, Sessions, Tasks)

if ~iscell(Tasks)
    Tasks = {Tasks};
end

AllBursts = table();
Missing = zeros(numel(Participants), numel(Sessions), numel(Tasks));
Durations = nan(numel(Participants), numel(Sessions), numel(Tasks));

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            %%% Load data
            Task = Tasks{Indx_T};
            Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Bursts.mat'}, '_');
            if ~exist(fullfile(Path, Filename), 'file')
                warning(['Skipping ', Filename])
                Missing(Indx_P, Indx_S, Indx_T) = 1;
                continue
            end

            load(fullfile(Path, Filename), 'Bursts', 'EEG')

            % Save recording durations
            Durations(Indx_P, Indx_S, Indx_T) = EEG.clean_t/EEG.srate;


            %%% Reload information into table

            % remove fields that I only sometimes have
            if isfield(Bursts, 'roundinessMean')
                Bursts = rmfield(Bursts, 'roundinessMean');
            end
            if isfield(Bursts, 'EO') % more trouble than its worth
                Bursts = rmfield(Bursts, {'EO', 'Microsleep'});
            end

            % remove fields that don't contain helpful info
            Bursts = rmfield(Bursts, {'PeakIDs', 'NegPeakID', 'PosPeakID', 'MidUpID', 'MidDownID', ...
                'NextMidDownID', 'PrevPosPeakID', 'truePeak', 'isProminent', 'ampRamp', ...
                });

            % assign a value to empty fields
            Fields = fieldnames(Bursts);
            for Indx_F = 1:numel(Fields)
                for Indx_B = 1:numel(Bursts)
                    if isempty(Bursts(Indx_B).(Fields{Indx_F}))
                        Bursts(Indx_B).(Fields{Indx_F}) = nan;
                    end
                end
            end

            % convert to table
            T = struct2table(Bursts);

            % metadata
            T.Participant = repmat(Participants(Indx_P), size(T, 1), 1);
            T.Session = repmat(Sessions(Indx_S), size(T, 1), 1);
            T.Task = repmat(Tasks(Indx_T), size(T, 1), 1);

            % add to overall table
            AllBursts = cat(1, AllBursts, T);
        end
    end
    disp(['Finished ', Participants{Indx_P}])
end


%%% Calculate some extra information

% mean amplitude of all coherent peaks
AllBursts.Mean_coh_amplitude = cellfun(@mean, AllBursts.Coh_amplitude);

% whether theta or alpha
Type = nan(size(AllBursts, 1), 1);
Type(1./AllBursts.Mean_period>4 & 1./AllBursts.Mean_period<= 8) = 1; % theta
Type(1./AllBursts.Mean_period>8 & 1./AllBursts.Mean_period<= 12) = 2; % alpha
AllBursts.FreqType = Type;

% duration
AllBursts.Duration = (AllBursts.All_End - AllBursts.All_Start)/fs;


%%% In case I don't use all the sessions

Missing = squeeze(Missing);
Durations = squeeze(Durations);
