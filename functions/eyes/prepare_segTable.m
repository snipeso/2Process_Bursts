function [correct_events] = prepare_segTable(original_events)
% Bring event file into correct format
% INPUT:
% Script by Elias Meier in 2process_Bursts


%empty tables, with variables timestamp and message
% correct_events = table(0, "TRIALID 0", 'VariableNames', {'timestamp','message'});
% tone_events = table(0, "TRIALID 0", 'VariableNames', {'timestamp','message'});
correct_events = struct();
correct_events.timestamp = 0;
correct_events.message = "TRIALID 0";
tone_events = correct_events;


% Determine which tone was the standard and which one the target tone: the
% more abundant one is the standard tone, the other the target.

tone_1 = length(original_events.stimulus(original_events.label == "Tone" & original_events.stimulus == 1));
tone_0 = length(original_events.stimulus(original_events.label == "Tone" & original_events.stimulus == 0));

% label tones in input event file as target and standard tone for clarity
if tone_0 < tone_1
    original_events.label(original_events.label == "Tone" & original_events.stimulus == 0) = {'Target_tone'};
    original_events.label(original_events.label == "Tone" & original_events.stimulus == 1) = {'Standard_tone'};
else
    original_events.label(original_events.label == "Tone" & original_events.stimulus == 0) = {'Standard_tone'};
    original_events.label(original_events.label == "Tone" & original_events.stimulus == 1) = {'Target_tone'};
end


% Add messages (TrialIDs, tone variables, responses) and corresponding
% timestamps to new events file. Tones are yet only saved as variables and
% not as events, but this will be done further down. Responses are saved as
% events.

event_count = 1;
trialid = "TRIALID %d";

%%%%% TODO: get rid of for loop %%%%%%
for event_indx = 1:size(original_events)
    % add TRIALID XX
    if ~isnan(original_events.trialID(event_indx))
        trial_nr = sprintf(trialid,event_count);
        correct_events(event_indx).message = trial_nr;
        event_count = event_count+1;

        % add response events
    elseif original_events.label(event_indx) == "Response"
        correct_events(event_indx).message = "!E TRIAL_EVENT_VAR response";

        % add tone variables
    elseif original_events.label(event_indx) == "Standard_tone"
        correct_events(event_indx).message =  "!V TRIAL_VAR  tone standard";

    elseif original_events.label(event_indx) == "Target_tone"
        correct_events(event_indx).message =   "!V TRIAL_VAR  tone target";
    else
        continue
    end
    correct_events(event_indx).timestamp = original_events.timestamp(event_indx);
end


CE = struct2table(correct_events);
if iscell(CE.timestamp)
    correct_events(cellfun(@isempty, CE.timestamp))= [];
end

%%%%%% TODO: Get rid of for loop %%%%%%%%
% Standard and target tone EVENTS are created, and added to the new events
% table further down.
count = 1;
for t = 1:size(correct_events, 2)
    if strcmp(correct_events(t).message, '!V TRIAL_VAR  tone standard')
        tone_events(count).message = "!E TRIAL_EVENT_VAR Standard Tone";
    elseif strcmp(correct_events(t).message, '!V TRIAL_VAR  tone target')
        tone_events(count).message = "!E TRIAL_EVENT_VAR Target Tone";
    else
        continue
    end
    tone_events(count).timestamp = original_events.timestamp(t)+0.001;
    count = count + 1;

end


% Add tone events to new events table:
correct_events = cat(2, correct_events, tone_events);
correct_events = struct2table(correct_events);
correct_events = sortrows(correct_events, 'timestamp');

end

