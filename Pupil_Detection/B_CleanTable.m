% gets the pupil labs table, and turns it into the structures needed to
% preprocess the pupil data. This involves interpolation, conversion into
% mm. Scripts by Elias Meier and Sophia Snipes.

clear
clc
close all

P = pupilParameters();

Paths = P.Paths;
Tasks = P.Tasks;
Participants = P.Participants;
Sessions = P.Sessions;
new_srate = P.new_srate;

Refresh = true;

Method = '2d c++'; % which way pupil size is calculated. either '2d c++' or 'pye3d 0.3.0 post-hoc'

keep_col = {'pupil_timestamp','confidence','diameter', ...
    'diameter_3d','model_confidence','model_id'};

diameterUnit = 'mm';
zeroTime_ms = 0;

% Conversion factors
Image_px = 192; % total number of pixels in the eye video
Image_cm = 4.5; % video screenshot width in the powerpoint I used to measure irisis
Iris_mm = 12; % average human iris diameter

IrisDiameters = readtable(fullfile(Paths.Data, 'Overviews', 'IrisDiameters.csv'));

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};

    Source = fullfile(Paths.Preprocessed, 'Raw', Task);

    Destination = fullfile(Paths.Preprocessed, 'Raw_mm', Task);
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end

    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)

            % load table of all pupil data
            Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Pupils.mat'}, '_');

            if ~exist(fullfile(Source, Filename), 'file')
                warning([Filename, ' does not exist'])
                continue
            end

            if exist(fullfile(Destination, Filename), 'file') && ~Refresh
                disp(['Skipping ', Filename])
                continue
            end

            load(fullfile(Source, Filename), 'Pupil', 'Annotations')
            if isempty(Pupil)
                warning([Filename 'is empty'])
                continue
            end

            % convert timestamps to ms
            t0 = min(Pupil.pupil_timestamp); % make earliest point 0 from Unix time
            Pupil.unix_timestamp = Pupil.pupil_timestamp;
            Pupil.pupil_timestamp = (Pupil.pupil_timestamp - t0)*1000; % convert to ms

            % select relevant information for each eye
            eye1 = Pupil(Pupil.eye_id==0 & strcmp(Pupil.method, Method), keep_col);
            eye2 = Pupil(Pupil.eye_id==1 & strcmp(Pupil.method, Method), keep_col);

            % apply conversion of diameter in pixels into mm
            Row = strcmp(IrisDiameters.Participant, Participants{Indx_P}) & ...
                strcmp(IrisDiameters.Session, Sessions{Indx_S}) & ...
                strcmp(IrisDiameters.Task, Task);

            Iris1_cm = IrisDiameters.Diameter1(Row);
            Iris2_cm = IrisDiameters.Diameter2(Row);
            eye1.diameter = (eye1.diameter*Image_cm*Iris_mm)/(Iris1_cm*Image_px);
            eye2.diameter = (eye2.diameter*Image_cm*Iris_mm)/(Iris2_cm*Image_px);

            % convert to PDM structure
            diameter = pupil2pdm(eye1, eye2, new_srate);

            % segmenation table for fixation data
            segmentStart = diameter.t_ms(1);
            segmentEnd = diameter.t_ms(end);
            segmentName = {('TRIAL_1')};
            segmentsTable = table(segmentName, segmentStart, segmentEnd);

            % deal with annotations
            if ~isempty(Annotations)

                Destination_Table = fullfile(Paths.Preprocessed, 'SegmentsTables', Task);
                if ~exist(Destination_Table, 'dir')
                    mkdir(Destination_Table)
                end

                segmentstable = prepare_segTable(Annotations);
                segmentstable = add_trialend_unix(segmentstable, Pupil);

                % The shorteneventfile function filters all target trials and
                % their preceding standard trials, so we end up with 80 trials
                % in total (40/40). It also deals with erroneous responses
                % (e.g. twice, or responding to target tones).
                segmentstable = assembleTrials(segmentstable);
                segmentstable = timenorm_events(segmentstable, Pupil);
                segmentstable.Properties.VariableNames = {'message', 'pupil_timestamp'};

                save(fullfile(Destination_Table, Filename), 'segmentstable')
            end

            % save
            save(fullfile(Destination, Filename), 'diameter', 'diameterUnit', 'zeroTime_ms', 'segmentsTable')
            disp([Filename, ' saved']);
        end
    end
end