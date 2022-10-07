function [Timecourse, t, AverageBaselines, MissingData] = getPupilOddball(Path, Participants, Sessions)
% Timecourse is a P x S x T x t matrix, with T=2 (target and standard), and
% t = is [-0.5 2]

Task = 'Oddball';
Window = [- 0.5 2];
fs = 50; % sampling rate of pupillometry

BaselineWindow = [1, fs*0.5]; % relative to the whole window
MinPoints = 2/3; % amount of data that must still be present to include trial
MinTrials = 15;
MinTrialPoints = 10;
MinSessions = 6;

Triggers = {'TRIAL_EVENT_VAR Standard Tone', 'TRIAL_EVENT_VAR Target Tone'};

t = linspace(Window(1), Window(2), fs*diff(Window));
TrialLength = numel(t);
Timecourse = nan(numel(Participants), numel(Sessions), 2, TrialLength);
MissingData = Timecourse;
AverageBaselines = nan(numel(Participants), numel(Sessions), 2);

for Indx_P = 1:numel(Participants)

    % gather first for both eyes, then choose eye with most data
    TotTrials = zeros(2, numel(Sessions), 2); % eyes x sessions x tone type
    MeanTrials = nan(2, numel(Sessions), 2, TrialLength); % eyes x tone type
    mdTrials = MeanTrials;
    AllBaselines = TotTrials;

    for Indx_S = 1:numel(Sessions)

        Filename = strjoin([Participants(Indx_P), Task, Sessions(Indx_S), 'Pupils.mat'], '_');

        if ~exist(fullfile(Path, Filename), 'file')
            warning([Filename, ' does not exist'])
            continue
        end

        % pupil data
        load(fullfile(Path, Filename), 'Rightdata', 'Leftdata')


        % triggers
        TriggerPath = replace(Path, 'Clean', 'SegmentsTables');
        if ~exist(fullfile(TriggerPath, Filename), 'file')
            warning([Filename, ' does not have triggers'])
            continue
        end

        load(fullfile(TriggerPath, Filename), 'segmentstable')


        for Indx_E = 1:2
            if Indx_E ==1
                EyeData = Leftdata;
            else
                EyeData = Rightdata;
            end

            % assemble timecourses
            for Indx_T = 1:2

                % get starts and ends of all trials
                ToneStamps = segmentstable.pupil_timestamp(contains(segmentstable.message, Triggers{Indx_T}));
                Starts = ToneStamps + Window(1)*1000;
                Starts = dsearchn(EyeData(:, 1), Starts); % get precise timestamps


                % average pupil data for all these timepoints
                AllTrials = nan(numel(Starts), TrialLength);

                for Indx_Tr = 1:numel(Starts) % only calculate it once, in case there are rounding errors

                    Points = Starts(Indx_Tr):Starts(Indx_Tr)+TrialLength-1;

                    % handle if there's a few samples missing
                    if Points(end)>size(EyeData, 1)
                        N = Points(end)- size(EyeData, 1);
                        warning([Filename, ' trial ', num2str(Indx_Tr), ' is missing ', num2str(N), ' points'])
                        EyeData(size(EyeData, 1)+1:Points(end), :) = nan;
                    end
                    Trial = EyeData(Points, 2);

                    % check that there's enough data before including in
                    % analysis
                    if nnz(~isnan(Trial)) >= TrialLength*MinPoints
                        AllTrials(Indx_Tr, :) = Trial;
                        TotTrials(Indx_E, Indx_S, Indx_T) = TotTrials(Indx_E, Indx_S, Indx_T)+1;
                    end
                end

                % correct each trial by baseline
                Baselines = mean(AllTrials(:, BaselineWindow(1):BaselineWindow(2)), 2, 'omitnan');
                AllTrials = AllTrials - Baselines;
                AllBaselines(Indx_E, Indx_S, Indx_T) = mean(Baselines, 'omitnan');

                % baseline corrected missing data 
                MD = sum(isnan(AllTrials))-mean(sum(isnan(AllTrials(:, BaselineWindow(1):BaselineWindow(2))))); % also baseline-corrected
                mdTrials(Indx_E, Indx_S, Indx_T, :) = MD;

                MD = sum(isnan(AllTrials)); % actual missing data
                if any(size(AllTrials, 1)-MD < MinTrialPoints)
                    warning(['systematically missing data in ' Filename])
                    continue
                end
                % average all trials for a specific eye and trigger type
                % together
                MeanTrials(Indx_E, Indx_S, Indx_T, :) = mean(AllTrials, 1, 'omitnan');
            end
        end
    end

    % select eye with largest amount of clean data
    TotTrials(TotTrials<MinTrials) = nan; % don't consider recordings without many trials
    nCleanTrials = squeeze(sum(sum(TotTrials, 2, 'omitnan'), 3, 'omitnan')); % only look at total number of targets, since its the smaller category
    [~, CleanestEye] = max(nCleanTrials);

    % remove from that eye any recordings that don't have enough data
    MeanTrials = squeeze(MeanTrials(CleanestEye, :, :, :));

    % remove sessions that don't have enough trials
    TotTrials = squeeze(TotTrials(CleanestEye, :, :));
    rmSessions = any(isnan(TotTrials), 2); % in either targets or standards

    if nnz(rmSessions)>=MinSessions
        warning(['Removing ', Participants{Indx_P}, ' because of too little data'])
        continue
    end
    MeanTrials(rmSessions, :, :) = nan; % if either targets or standards are missing

    Timecourse(Indx_P, :, :, 1:TrialLength) = MeanTrials;

    mdTrials = squeeze(mdTrials(CleanestEye, :, :, :));
    MissingData(Indx_P, :, :, 1:TrialLength) = mdTrials;

    % same for baselines
    AllBaselines = squeeze(AllBaselines(CleanestEye, :, :));
    AllBaselines(rmSessions, :) = nan;
    AverageBaselines(Indx_P, :, :) = AllBaselines;
    disp(['Finished ', Participants{Indx_P}])
end

