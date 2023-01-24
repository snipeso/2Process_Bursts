% load data for blinks and microsleeps

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Tasks = {'Fixation', 'Oddball'};
Refresh = true;

TitleTag = 'Microsleeps';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data 

% load in data table of all eye closures
AllBlinks = fullfile(Paths.Data, 'Eyes', 'Blinks', 'AllBlinks.mat');
BlinkLocation = fullfile(Paths.Preprocessed, 'Pupils', 'Raw');
if Refresh || ~exist(AllBlinks, 'file')
    [BlinkTable, RecordingDurations, Confidence] = getBlinks(BlinkLocation, Participants, Sessions, Tasks);

    if ~exist('E:\Data\Final\Eyes\Blinks', 'dir')
        mkdir('E:\Data\Final\Eyes\Blinks')
    end

    save(AllBlinks, 'BlinkTable', 'RecordingDurations', 'Confidence')
else
    load(AllBlinks, 'BlinkTable', 'RecordingDurations', 'Confidence')
end

MicrosleepThreshold = 1;
BlinkThreshold = 1; % anything less is a blink, more is a microsleep


% save data to matrix
TotBlinks = nan(numel(Participants), numel(Sessions), numel(Tasks)); % blinks per minute
MicrosleepDur = TotBlinks; % percent time microsleeping

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)

            Dur = squeeze(RecordingDurations(Indx_P, Indx_S, Indx_T))/60; % in minutes
            T = BlinkTable(strcmp(BlinkTable.Participant, Participants{Indx_P}) & ...
                strcmp(BlinkTable.Session, Sessions{Indx_S}) & strcmp(BlinkTable.Task, Tasks{Indx_T}), :);

            TotBlinks(Indx_P, Indx_S, Indx_T) = nnz(T.Duration<BlinkThreshold)/Dur;
            MicrosleepDur(Indx_P, Indx_S, Indx_T) = sum(T.Duration(T.Duration>=MicrosleepThreshold))/Dur;
        end
    end
end


%%% save to pool

% blinks
Data = TotBlinks; % P x S x T
save(fullfile(Paths.Pool, [TitleTag, '_nBlinks.mat']), 'Data')


% microsleeps
Data = MicrosleepDur; % P x S x T
save(fullfile(Paths.Pool, [TitleTag, '_prcntMicrosleep.mat']), 'Data')









