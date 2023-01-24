function [event_file_trialend] = add_trialend_unix(event_file, pupil_file)
% Create a TRIAL_END table (markers 0.001 s before beginning of next
% trial), and add this information to the event file (which will be
% completed with that. TRIAL_ENDs are a requirement for the preprocessing
% model.
% Script by Elias Meier in 2process_Bursts


% INPUT:
% Pupil data (only important for get last timestamp in recording)
% Event file, containing TRIAL_IDs and information about tones and
% responses.
% OUTPUT: 
% Completed event file, also including now TRIAL_END information.

% Create table for all TRIAL_END events with according timestamp. 
% trial_end_table(1,1) = table({"TRIAL_END"});
% trial_end_table(1,2) = table(pupil_file.pupil_timestamp(end)); % Last TRIAL_END of recording 
% trial_end_table.Properties.VariableNames = {'message','timestamp'};

trial_end_table = struct();
trial_end_table.message = "TRIAL_END";
trial_end_table.timestamp = 0;

% Count is set to 2 to make sure that TRIAL_END we added is not
% overwritten.
count = 2; 

% Start at index 2 to prevent TRIAL_END before first trial even started
for Indx = 2:size(event_file, 1)
   if contains(event_file.message{Indx}, "TRIALID")
       trial_end_table(count).message = "TRIAL_END";
       trial_end_table(count).timestamp = (event_file.timestamp(Indx) - 0.001); 
       count = count+1;
   else
       continue
   end
end

trial_end_table = struct2table(trial_end_table);

event_file_trialend = [event_file; trial_end_table]; % merge TRIAL_ENDs to rest of events
event_file_trialend  = sortrows(event_file_trialend, 'timestamp');
event_file_trialend = event_file_trialend(:,[2 1]);
end

