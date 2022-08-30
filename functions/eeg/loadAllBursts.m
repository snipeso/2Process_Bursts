function [AllBursts, Missing] = loadAllBursts(Path, Participants, Sessions, Tasks)

if ~iscell(Tasks)
    Tasks = {Tasks};
end

AllBursts = table();
Missing = zeros(numel(Participants), numel(Sessions), numel(Tasks));

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            Task = Tasks{Indx_T};
            Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Bursts.mat'}, '_');
            if ~exist(fullfile(Path, Filename), 'file')
                warning(['Skipping ', Filename])
                Missing(Indx_P, Indx_S, Indx_T) = 1;
                continue
            end

            load(fullfile(Path, Filename), 'Bursts');

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

            Fields = fieldnames(Bursts);
            for Indx_F = 1:numel(Fields)
                for Indx_B = 1:numel(Bursts)
                    if isempty(Bursts(Indx_B).(Fields{Indx_F}))
                        Bursts(Indx_B).(Fields{Indx_F}) = nan;
                    end
                end
            end

            T = struct2table(Bursts);

            T.Participant = repmat(Participants(Indx_P), size(T, 1), 1);
            T.Session = repmat(Sessions(Indx_S), size(T, 1), 1);

            AllBursts = cat(1, AllBursts, T);
        end     
    end
     disp(['Finished ', Participants{Indx_P}])
end

Missing = squeeze(Missing);