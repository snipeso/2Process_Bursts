% plot comparing effect sizes of raw and z-scored data from start and end
% of SD period, and for WMZ

clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Labels = P.Labels;
StatsP = P.StatsP;
Tasks = P.Tasks;
TaskColors = P.TaskColors;
Bands = P.Bands;
BandLabels = lower(fieldnames(Bands));

TitleTag = 'Trajectories';
Categories = struct();


Categories.Power = {'raw'};
Categories.Pupillometry = {'meanDiameter', 'stdDiameter'};
Categories.Microsleeps = {'prcntMicrosleep', 'nBlinks'};
Categories.Behavior = {'meanRT', 'stdRT', 'performance'};
Categories.Questionnaires = { 'KSS', 'difficultyWake'};

VariableNames.Power = {'Power'};
VariableNames.Pupillometry = {'Mean diameter', 'Std diameter'};
VariableNames.Microsleeps = {'% Microsleep', '# blinks'};
VariableNames.Behavior = {'Mean RT', 'Std RT', 'Performance'};
VariableNames.Questionnaires = { 'KSS', 'Difficulty wake'};

Signs.Power = 1;
Signs.Pupillometry = [-1 1];
Signs.Microsleeps = [1 1];
Signs.Behavior = [1 1 -1];
Signs.Questionnaires = [ 1  1];

ColorCategories = [
    getColors(1, '', 'teal'); % for power
    getColors(1, '', 'yellow'); % pupil
    getColors(1, '', 'orange'); % blinks
    getColors(1, '', 'red'); % for behavior
    getColors(1, '', 'pink')]; % for questionnaires


CategoryNames = fieldnames(Categories);
CategoryNames_Disp  = {'pw', 'pu', 'et', 'be', 'qu'};



%% gather data

Indx_T = 2; % use oddball

SD = nan(numel(Participants), numel(Sessions)); % P x 2 (start vs end) x V x z-score (false, true) % TODO could also control for pre
SD_Colors = [];
SD_Names = {};
Indx = 1;


for Indx_C = 1:numel(CategoryNames)
    V = Categories.(CategoryNames{Indx_C});

    for Indx_V = 1:numel(V)

        Sign = Signs.(CategoryNames{Indx_C})(Indx_V);
        Color = ColorCategories(Indx_C, :);

        % handle weird data formats
        if  strcmp(CategoryNames{Indx_C}, 'Power')

            Name = {};

            for Indx_B = 1:numel(BandLabels) % loop through bands

                % load data
                load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')
                SD(:, :, Indx) = Sign*squeeze(Data(:, :, Indx_T, Indx_B));

                Name =  cat(1, Name, strjoin({BandLabels{Indx_B}, Tasks{Indx_T}, ['(', CategoryNames_Disp{Indx_C}, ')']}, ' '));
                Indx = Indx+1;
            end

            Color = repmat(Color, numel(BandLabels), 1);


        elseif strcmp(CategoryNames{Indx_C}, 'Pupillometry') || strcmp(CategoryNames{Indx_C}, 'Microsleeps')

            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            Name = {};

            % save data
            SD(:, :, Indx) = Sign*squeeze(Data(:, :, Indx_T));

            % save metadata
            Name =  cat(1, Name, strjoin({VariableNames.(CategoryNames{Indx_C}){Indx_V}, Tasks{Indx_T},  ['(', CategoryNames_Disp{Indx_C}, ')']}, ' '));
            Indx = Indx+1;
        else

            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            SD(:, :, Indx) = Sign*Data;

            % metadata
            Name = strjoin({VariableNames.(CategoryNames{Indx_C}){Indx_V},  ['(', CategoryNames_Disp{Indx_C}, ')']}, ' ');
            Indx = Indx+1;

        end

        SD_Names = cat(1, SD_Names, Name);
        SD_Colors = cat(1, SD_Colors, Color);
    end
end

%% plot individuals

close all
Grid = [numel(SD_Names), 1];

PlotProps = P.Manuscript;

for Indx_P = 1:numel(Participants)
   figure('units', 'normalized', 'OuterPosition', [0 0 .2 1], 'color', 'w')

    for Indx_V = 1:numel(SD_Names)

        Data = squeeze(SD(Indx_P, :, Indx_V));
        A = subfigure([], Grid, [Indx_V, 1], [], false, '', PlotProps);
       plotBrokenSpaghetti(Data, [], [], [], SD_Colors(Indx_V, :), false, PlotProps)
        title([SD_Names{Indx_V}, ' ', Participants{Indx_P}])
        if Indx_V < numel(SD_Names)
        axis off
        end
    end
end

