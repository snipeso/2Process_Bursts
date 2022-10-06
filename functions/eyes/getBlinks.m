function [BlinkTable, RecordingDurations, Confidence] = getBlinks(BlinkLocation, Participants, Sessions, Tasks)
% gets a table of all the blinks/microsleeps in each recording

Method = '2d c++';
ConfidenceColumn = 'confidence';
ConfidenceThreshold = 0.5; % threshold for considering eyes open or closed
fs = 50;

BlinkTable = table();
RecordingDurations = nan(numel(Participants), numel(Sessions), numel(Tasks));
Confidence = RecordingDurations;

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)
            Source = fullfile(BlinkLocation, Tasks{Indx_T}, ...
                strjoin({Participants{Indx_P}, Tasks{Indx_T}, ...
                Sessions{Indx_S}, 'Pupils.mat'}, '_'));

            if ~exist(Source, 'file')
                warning([Source 'does not exist'])
                continue
            end

            load(Source, 'Pupil')

            if isempty(Pupil)
                warning([Source ' is empty'])
                continue
            end

            % only use one model
            Pupil = Pupil(strcmp(Pupil.method, Method), :);

            % get recording duration
            RecordingDurations(Indx_P, Indx_S, Indx_T) = max(Pupil.pupil_timestamp)-min(Pupil.pupil_timestamp);

            % use the eye with the largest confidence values (excluding 0
            % and eyes-closed values)
            if numel(unique(Pupil.eye_id))==2 % if there are two eyes in the first place
                Eye1 = Pupil.confidence(Pupil.eye_id==0);
                Eye2 = Pupil.confidence(Pupil.eye_id==1);

                if mean(Eye1(Eye1>0.5))>=mean(Eye2(Eye2>0.5))
                    Eye_ID = 0;
                else
                    Eye_ID = 1;
                end

            elseif numel(unique(Pupil.eye_id))==1
                Eye_ID = unique(Pupil.eye_id);
            else
                continue
            end

            % get correctly sampled data
            [Eye, ~] = cleanEye(Pupil, Eye_ID, ConfidenceColumn, fs);

            % get vector of eyes open
            [EyeOpen, ~] = classifyEye(Eye, fs, ConfidenceThreshold); % not using internal microsleep identifier so that I'm flexible

            [Starts, Ends] = data2windows(not(EyeOpen));

            T = table();
            T.Participant = repmat(Participants(Indx_P), numel(Starts), 1);
            T.Session = repmat(Sessions(Indx_S), numel(Starts), 1);
            T.Task = repmat(Tasks(Indx_T), numel(Starts), 1);

            T.Start = Starts';
            T.End = Ends';
            T.Duration = (Ends'-Starts')./fs;

            % skip if there is super long "sleep", which rather indicates poor data
            % quality
            if any(T.Duration > 120)
                continue
            end

            % save confidence of data
            Confidence(Indx_P, Indx_S, Indx_T) = mean(Eye(Eye<.9 & Eye>.1), 'omitnan');


            BlinkTable = [BlinkTable; T];
        end
    end
    disp(['Finished ', Participants{Indx_P}])
end
