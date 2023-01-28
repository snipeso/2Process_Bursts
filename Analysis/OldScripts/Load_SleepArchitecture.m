
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load and set parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Nights = P.Nights;


Stages = {'wake',  'n1', 'n2', 'n3', 'rem',};
ExtraVariables = {'sol', 'sd', 'waso', 'se', 'rol'};
TableLabels = {'Wake (min)', 'N1', 'N2', 'N3' 'REM', 'SOL', 'SD', 'WASO', 'SE', 'ROL'};

%%% gather data from everyone

Stages_Matrix = nan(numel(Participants), numel(Nights)+1, numel(Stages));
ExtraVariables_Matrix = nan(numel(Participants), numel(Nights)+1, numel(Stages));

for Indx_P = 1:numel(Participants)

    % get sleep data
    for Indx_N  = 1:numel(Nights)

        % get location
        Folder = strjoin({Participants{Indx_P}, 'Sleep', Nights{Indx_N}}, '_');
        Path = fullfile(Paths.Scoring, 'Sleep', Folder);

        % get scoring info
        [Percent, Minutes, SleepQuality] = loadScoring(Path);

        % load into matrices
        for Indx_S = 1:numel(Stages)
            Stages_Matrix(Indx_P, Indx_N, Indx_S) = Minutes.(Stages{Indx_S});
        end

        for Indx_eV = 1:numel(ExtraVariables)
            ExtraVariables_Matrix(Indx_P, Indx_N, Indx_eV) = SleepQuality.(ExtraVariables{Indx_eV});
        end
    end

    %%% get MWT data (for potential future reference)
    Folder = strjoin({Participants{Indx_P}, 'MWT', 'Main'}, '_');
    Path = fullfile(Paths.Scoring, 'MWT', Folder);

    % get scoring info
    [Percent, Minutes, SleepQuality] = loadScoring(Path);
    if isempty(fieldnames(Percent))
        continue
    end

    % load into matrices
    for Indx_S = 1:numel(Stages)
        Stages_Matrix(Indx_P, end, Indx_S) = Minutes.(Stages{Indx_S});
    end

    for Indx_eV = 1:numel(ExtraVariables)
        ExtraVariables_Matrix(Indx_P, end, Indx_eV) = SleepQuality.(ExtraVariables{Indx_eV});
    end
end

% join variables
Matrix = cat(3, Stages_Matrix(:, 1:numel(Nights), :), ExtraVariables_Matrix(:, 1:numel(Nights), :));
Labels = [Stages, ExtraVariables];


% create table
Table = sleepArchitecture(Matrix, TableLabels, Nights);
disp(Table)


%% save to pool

% SOL
Data = squeeze(Matrix(:, :, strcmp(Labels, 'sol')));
save(fullfile(Paths.Pool, 'Sleep_SOL.mat'), 'Data')

% SOL
Data = squeeze(Matrix(:, :, strcmp(Labels, 'n3')));
save(fullfile(Paths.Pool, 'Sleep_NREM3.mat'), 'Data')
