function Answers = fixRTs(Answers, Paths)
% for some reason, RTs were not correctly recorded, so I need to use the
% triggers.

Participants = unique(Answers.Participant);
Sessions = unique(Answers.Session);
Filepath = fullfile(Paths.Preprocessed, 'ICA', 'SET', 'Oddball');


for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        Filename = strjoin({Participants{Indx_P}, 'Oddball', ...
            Sessions{Indx_S}, 'ICA.set'}, '_');

        if ~exist(fullfile(Filepath, Filename), 'file')
            warning(['no eeg for ', Filename])
            continue
        end

        EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
        fs = EEG.srate;

        Indexes = find(strcmp(Answers.Participant, Participants{Indx_P}) & ...
            strcmp(Answers.Session, Sessions{Indx_S}));
        T = Answers(Indexes, :);
        nTrials = size(T, 1);

        TriggerTypes = {EEG.event.type};
        TriggerLatencies = [EEG.event.latency];
        StimTriggers = find(ismember(TriggerTypes, {'S 11', 'S 10'}));

        if nTrials ~=numel(StimTriggers)
            warning(['missmatch triggers for ', Filename])
            RM = zeros(nTrials, 1);
            %             TriggerSequence = TriggerTypes(~ismember(TriggerTypes, {'S 11', 'S 10', 'S  4', 'boundary'}));
            for Indx_T = 1:nTrials
                TrialTrigs = T.Triggers{Indx_T};
                LastTrigTable = ['S', num2str(T.Triggers{Indx_T}(end))];
                LastTrigEEG = TriggerTypes{StimTriggers(1)-1};
                SecondLastTrigEEG = TriggerTypes{StimTriggers(1)-2};
                if strcmp(LastTrigTable, LastTrigEEG) || strcmp(LastTrigTable, SecondLastTrigEEG)
                    StimTriggers(1) = [];
                else
                    RM(Indx_T) = 1;
                end


                %                 if  ~all(ismember(TriggerSequence(1:numel(TrialTrigs)), append('S',split(num2str(TrialTrigs), '  ')')))
                %                     RM(Indx_T) = 1;
                %                 else
                %                     TriggerSequence(1:numel(TrialTrigs)) = [];
                %                 end

            end

            % remove trials for hwich there is no EEG
            Answers(Indexes(logical(RM)), :) = [];

            % recalculate
            Indexes = find(strcmp(Answers.Participant, Participants{Indx_P}) & ...
                strcmp(Answers.Session, Sessions{Indx_S}));
            T = Answers(Indexes, :);
            nTrials = size(T, 1);
            StimTriggers = find(ismember(TriggerTypes, {'S 11', 'S 10'}));
        end

        RTs = nan(nTrials, 1);
        for Indx_T = 1:nTrials
            StimIndx = StimTriggers(Indx_T);
            RespIndx = StimIndx+1;
            if RespIndx<= nTrials && strcmp(TriggerTypes{RespIndx}, 'S  4') % only if response was given
                RTs(Indx_T) = (TriggerLatencies(RespIndx) - TriggerLatencies(StimIndx))/fs;

            end
        end

        Answers.RT(Indexes) = RTs;

    end
end