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

TitleTag = 'EffectSizes';
Categories = struct();

Categories.Sleep = {'SOL', 'NREM3'};

Categories.SWA = { 'raw'};
Categories.Power = {'raw'};
Categories.Bursts = {'rawTots', 'rawAmplitude'};
Categories.Pupillometry = {'meanDiameter', 'stdDiameter'};
Categories.Microsleeps = {'prcntMicrosleep', 'nBlinks'};
Categories.Behavior = {'meanRT', 'stdRT', 'performance'};
Categories.Questionnaires = {'sleepPropensity', 'focus', 'motivation', 'alertness', ...
    'KSS', 'difficultyWake', ...
    'tolerance', 'difficultyFixating', 'generalFeeling'};

VariableNames.Sleep = Categories.Sleep;
VariableNames.SWA = { 'SWA'};
VariableNames.Power = {'Power'};
VariableNames.Bursts = {'# bursts', 'Amplitude'};
VariableNames.Pupillometry = {'Mean diameter', 'Std diameter'};
VariableNames.Microsleeps = {'% Microsleep', '# blinks'};
VariableNames.Behavior = {'Mean RT', 'Std RT', 'Performance'};
VariableNames.Questionnaires = {'Sleep propensity', 'Focus', 'Motivation', 'Alertness', ...
    'KSS', 'Difficulty wake',  ...
    'Tolerance', 'Difficulty fixating', 'Mood'};


Signs.Sleep = [-1 1];
Signs.SWA = 1;
Signs.Power = 1;
Signs.Bursts = [1 1];
Signs.Pupillometry = [-1 1];
Signs.Microsleeps = [1 1];
Signs.Behavior = [1 1 -1];
Signs.Questionnaires = [1 -1 -1 -1, 1  1, 1 1 -1];



ColorCategories = [ .5 .5 .5; % dark blue for sleep architecture
    getColors(1, '', 'blue'); % blue for SWA
    getColors(1, '', 'teal'); % for power
    getColors(1, '', 'green'); % for bursts
    getColors(1, '', 'yellow'); % pupil
    getColors(1, '', 'orange'); % blinks
    getColors(1, '', 'red'); % for behavior
    getColors(1, '', 'pink')]; % for questionnaires


CategoryNames = fieldnames(Categories);
CategoryNames_Disp  = {'sa', 'pw', 'pw', 'bu', 'pu', 'et', 'be', 'qu'};



%% gather data

SD = nan(numel(Participants), 2, 2); % P x 2 (start vs end) x V x z-score (false, true) % TODO could also control for pre
WMZ_Data = [];
SD_Colors = [];
SD_Names = {};
Indx = 1;
WMZ_Indexes = 8:11;
WMZ_Names = {};
WMZ_Colors = [];

for Indx_C = 1:numel(CategoryNames)
    V = Categories.(CategoryNames{Indx_C});

    for Indx_V = 1:numel(V)



        Sign = Signs.(CategoryNames{Indx_C})(Indx_V);
        Color = ColorCategories(Indx_C, :);

        % handle weird data formats
        if strcmp(CategoryNames{Indx_C}, 'Sleep')

            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            SD(:, :, Indx, 1) = Sign*Data(:, [2 3]); % pre and post nights

            % z-score data
            zData = zScoreData(Data, 'first');
            SD(:, :, Indx, 2) = Sign*zData(:, [2 3]);

            % assemble "metadata"
            Name =  [VariableNames.(CategoryNames{Indx_C}){Indx_V}, ' (', CategoryNames_Disp{Indx_C} , ')'];
            Indx = Indx+1;
            WMZ_Points = [];


        elseif strcmp(CategoryNames{Indx_C}, 'SWA')

            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            SD(:, :, Indx, 1) = Sign*[Data(:, 2, 2), Data(:, 3, 1)]; % last hour of pre, first hour of post

            % z-scored data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_z-scored.mat']), 'Data')

            SD(:, :, Indx, 2) = Sign*[Data(:, 2, 2), Data(:, 3, 1)]; % last hour of pre, first hour of post


            % assemble "metadata"
            Name =  ['SWA (', CategoryNames_Disp{Indx_C}, ')'];
            Indx = Indx+1;
            WMZ_Points = [];

        elseif strcmp(CategoryNames{Indx_C}, 'Power')

            Vtemp = {'raw', 'z-scored'}; % internal loop through z-scored data

            WMZ_Points = [];
            Name = {};

            for Indx_B = 1:numel(BandLabels) % loop through bands

                for Indx_T = 1:numel(Tasks) % loop through tasks

                    WMZ_temp = [];
                    for Indx_Vtemp = 1:numel(Vtemp) % do both raw and z-scored

                        % load data
                        load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', Vtemp{Indx_Vtemp}, '.mat']), 'Data')

                        SD(:, :, Indx, Indx_Vtemp) = Sign*squeeze(Data(:, [4 11], Indx_T, Indx_B));
                        WMZ_temp = cat(4, WMZ_temp, Sign*squeeze(Data(:, WMZ_Indexes, Indx_T, Indx_B)));

                    end

                    WMZ_Points = cat(3, WMZ_Points, WMZ_temp); % TODO, one day fix, there's probably a better way
                    Name =  cat(1, Name, strjoin({BandLabels{Indx_B}, Tasks{Indx_T}, ['(', CategoryNames_Disp{Indx_C}, ')']}, ' '));
                    Indx = Indx+1;
                end
            end

            Color = repmat(Color, numel(BandLabels)*numel(Tasks), 1);

        elseif strcmp(CategoryNames{Indx_C}, 'Bursts')
            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            zData = zScoreData(Data, 'first');

            WMZ_Points = [];
            Name = {};
            for Indx_B = 1:numel(BandLabels) % loop through bands

                for Indx_T = 1:numel(Tasks) % loop through tasks

                    SD(:, :, Indx, 1) = Sign*squeeze(Data(:, [4 11], Indx_T, Indx_B));
                    SD(:, :, Indx, 2) = Sign*squeeze(zData(:, [4 11], Indx_T, Indx_B));

                    WMZ_temp = cat(4, Sign*squeeze(Data(:, WMZ_Indexes, Indx_T, Indx_B)), Sign*squeeze(zData(:, WMZ_Indexes, Indx_T, Indx_B)));
                    WMZ_Points = cat(3, WMZ_Points, WMZ_temp);

                    % metadata
                    Name =  cat(1, Name, strjoin({VariableNames.(CategoryNames{Indx_C}){Indx_V}, BandLabels{Indx_B}, Tasks{Indx_T},  ['(', CategoryNames_Disp{Indx_C}, ')']}, ' '));
                    Indx = Indx+1;

                end
            end

            Color = repmat(Color, numel(BandLabels)*numel(Tasks), 1);

        elseif strcmp(CategoryNames{Indx_C}, 'Pupillometry') || strcmp(CategoryNames{Indx_C}, 'Microsleeps')

            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            % z-score data
            zData = zScoreData(Data, 'first');

            WMZ_Points = [];
            Name = {};

            for Indx_T = 1:numel(Tasks)-1 % loop through tasks

                % save data
                SD(:, :, Indx, 1) = Sign*squeeze(Data(:, [4 11], Indx_T));
                SD(:, :, Indx, 2) = Sign*squeeze(zData(:, [4 11], Indx_T));

                WMZ_temp = cat(4, Sign*squeeze(Data(:, WMZ_Indexes, Indx_T)), Sign*squeeze(zData(:, WMZ_Indexes, Indx_T)));
                WMZ_Points = cat(3, WMZ_Points, WMZ_temp);

                % save metadata
                Name =  cat(1, Name, strjoin({VariableNames.(CategoryNames{Indx_C}){Indx_V}, Tasks{Indx_T},  ['(', CategoryNames_Disp{Indx_C}, ')']}, ' '));
                Indx = Indx+1;

            end

            Color = repmat(Color, numel(Tasks)-1, 1);

        else

            % load data
            load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

            % z-score data
            zData = zScoreData(Data, 'first');

            SD(:, :, Indx, 1) = Sign*Data(:, [4 11]);
            SD(:, :, Indx, 2) = Sign*zData(:, [4 11]);


            WMZ_Points = cat(4, Sign*Data(:, WMZ_Indexes), Sign*zData(:, WMZ_Indexes));

            % metadata
            Name = strjoin({VariableNames.(CategoryNames{Indx_C}){Indx_V},  ['(', CategoryNames_Disp{Indx_C}, ')']}, ' ');
            Indx = Indx+1;

        end

        SD_Names = cat(1, SD_Names, Name);
        SD_Colors = cat(1, SD_Colors, Color);

        if ~isempty(WMZ_Points)
            WMZ_Data = cat(3, WMZ_Data, WMZ_Points);
            WMZ_Names = cat(1, WMZ_Names, Name);
            WMZ_Colors = cat(1, WMZ_Colors, Color);
        end

    end
end


[WMZ, noWMZ] = WMZinterp(squeeze(WMZ_Data(:, :, :, 1)));
[zWMZ, znoWMZ] = WMZinterp(squeeze(WMZ_Data(:, :, :, 2)));

WMZ = cat(3, WMZ, zWMZ);
noWMZ = cat(3, noWMZ, znoWMZ);

%% plot effect sizes

Grid = [1, 4];
PlotProps = P.Manuscript;
PlotProps.Scatter.Size = 10;
PlotProps.Line.Width = 1;

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width*1.3, PlotProps.Figure.Height*.9])
% figure('units', 'normalized', 'outerposition', [0 0 .5 1])

A = chART.sub_plot([], Grid, [1, 2], [], true, '', PlotProps);
A.Position(1) =  A.Position(1)-.1;
A.Position(3) = A.Position(3)+.1;
Stats = plotEffectSizes(SD, 'vertical', true, SD_Colors, SD_Names, ...
    {'Raw', 'Z-scored'}, PlotProps, StatsP, Labels);
title('A: Sleep Deprivation', 'FontSize', PlotProps.Text.TitleSize)

legend off

Data = permute(cat(4, WMZ, noWMZ), [1 4, 2, 3]);

A = chART.sub_plot([], Grid, [1, 4], [], true, '', PlotProps);
A.Position(1) =  A.Position(1)-.1;
A.Position(3) = A.Position(3)+.1;
Stats = plotEffectSizes(Data, 'vertical', true, WMZ_Colors, WMZ_Names, ...
    {'Raw', 'Z-scored'}, PlotProps, StatsP, Labels);
title('B: WMZ', 'FontSize', PlotProps.Text.TitleSize)
legend( {'Raw', 'Z-scored'}, 'location', 'southeast')
saveFig(TitleTag, Paths.Paper, PlotProps)
