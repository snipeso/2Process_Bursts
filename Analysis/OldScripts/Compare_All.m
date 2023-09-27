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
BandLabels = fieldnames(Bands);
TitleTag = 'Compare';

Categories = struct();

Categories.Sleep = {'SOL', 'NREM3'};
Categories.SWA = {'raw'};
Categories.Power = {'raw'}
% Categories.SWA = {'z-scored'};
% Categories.Power = {'z-scored'};
Categories.Bursts = {'rawTots', 'rawAmplitude'};
% Categories.Bursts = {'zscoreTots', 'zscoreAmplitude'};
Categories.Pupillometry = {'meanDiameter', 'stdDiameter'};
% Categories.Pupillometry = {'z-scoredmeanDiameter', 'z-scoredstdDiameter'};
Categories.Microsleeps = {'prcntMicrosleep', 'nBlinks'};
Categories.Behavior = {'meanRT', 'stdRT', 'performance'};
Categories.Questionnaires = {'sleepPropensity', 'motivation', 'alertness', ...
    'KSS',  'difficultyWake', ...
  'difficultyFixating', 'generalFeeling'};

Signs.Sleep = [-1 1];
Signs.SWA = 1;
Signs.Power = 1;
Signs.Bursts = [1 1];
Signs.Pupillometry = [-1 1];
Signs.Microsleeps = [1 1];
Signs.Behavior = [1 1 -1];
Signs.Questionnaires = [1 -1 -1, 1  1, 1 -1];


ColorCategories = [ [0 25 104]/255; % dark blue for sleep architecture
    getColors(1, '', 'blue'); % blue for SWA
    getColors(1, '', 'teal'); % for power
    getColors(1, '', 'green'); % for bursts
    getColors(1, '', 'yellow'); % pupil
    getColors(1, '', 'orange'); % blinks
    getColors(1, '', 'red'); % for behavior
    getColors(1, '', 'pink')]; % for questionnaires


CategoryNames = fieldnames(Categories);

%% gather data

SD = nan(numel(Participants), 2); % P x 2 (start vs end) x V % TODO could also control for pre
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

        load(fullfile(Paths.Pool, [CategoryNames{Indx_C}, '_', V{Indx_V}, '.mat']), 'Data')

        Sign = Signs.(CategoryNames{Indx_C})(Indx_V);
        Color = ColorCategories(Indx_C, :);

        % handle weird data formats
        if strcmp(CategoryNames{Indx_C}, 'Sleep')

            SD(:, :, Indx) = Sign*Data(:, [2 3]); % last hour of pre, first hour of post
            Name =  ['Sleep ', V{Indx_V}];
            Indx = Indx+1;

            WMZ_Points = [];


        elseif strcmp(CategoryNames{Indx_C}, 'SWA')
            SD(:, :, Indx) = Sign*[Data(:, 2, 2), Data(:, 3, 1)]; % last hour of pre, first hour of post
            Name =  ['SWA ', V{Indx_V}];

            % save color
            Indx = Indx+1;

            WMZ_Points = [];

        elseif strcmp(CategoryNames{Indx_C}, 'Power') || strcmp(CategoryNames{Indx_C}, 'Bursts')

            WMZ_Points = [];
            Name = {};
            for Indx_B = 1:numel(BandLabels) % loop through bands

                for Indx_T = 1:numel(Tasks) % loop through tasks

                    SD(:, :, Indx) = Sign*squeeze(Data(:, [4 11], Indx_T, Indx_B));
                    Name =  cat(1, Name, strjoin({CategoryNames{Indx_C}, V{Indx_V}, BandLabels{Indx_B}, Tasks{Indx_T}}, ' '));
                    Indx = Indx+1;

                    WMZ_Points = cat(3, WMZ_Points, Sign*squeeze(Data(:, WMZ_Indexes, Indx_T, Indx_B)));
                end
            end

            Color = repmat(Color, numel(BandLabels)*numel(Tasks), 1);

        elseif strcmp(CategoryNames{Indx_C}, 'Pupillometry') || strcmp(CategoryNames{Indx_C}, 'Microsleeps')

            WMZ_Points = [];
            Name = {};

            for Indx_T = 1:numel(Tasks)-1 % loop through tasks

                SD(:, :, Indx) = Sign*squeeze(Data(:, [4 11], Indx_T));
                Name =  cat(1, Name, strjoin({CategoryNames{Indx_C}, V{Indx_V}, Tasks{Indx_T}}, ' '));

                % save color
                Indx = Indx+1;

                WMZ_Points = cat(3, WMZ_Points, Sign*squeeze(Data(:, WMZ_Indexes, Indx_T)));
            end

            Color = repmat(Color, numel(Tasks)-1, 1);

        else

            SD(:, :, Indx) = Sign*Data(:, [4 11]);
            Name = strjoin({CategoryNames{Indx_C}, V{Indx_V}}, ' ');
            Indx = Indx+1;

            WMZ_Points = Sign*Data(:, WMZ_Indexes);

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


[WMZ, noWMZ] = WMZinterp(WMZ_Data);


%% plot SD data

% calculate changes
Stats = pairedttest(squeeze(SD(:, 1, :)), squeeze(SD(:, 2, :)), StatsP);
% [~, Order] = sort(abs(Stats.hedgesg), 'descend');
Order = 1:numel(SD_Names);

Data =  squeeze(SD(:, 2, :)) - squeeze(SD(:, 1, :));

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 100;
PlotProps.Scatter.Size = 15;

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width*1.1 PlotProps.Figure.Height*.7])

Stats = corrAll(Data(:, Order), Data(:, Order), '', SD_Names(Order), '', ...
    SD_Names(Order), StatsP, PlotProps, 'FDR');
axis square
chART.save_figure(strjoin({TitleTag, 'SD'}, '_'), Paths.Paper, PlotProps)


%% plot WMZ data

% calculate changes
Stats = pairedttest(WMZ, noWMZ, StatsP);
[~, Order] = sort(abs(Stats.hedgesg), 'descend');
% Order = 1:numel(WMZ_Names);

Data =  squeeze(noWMZ - WMZ);


Grid = [1 4];
PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 100;
PlotProps.Scatter.Size = 15;

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width*2 PlotProps.Figure.Height])
Axes = chART.sub_plot([], Grid, [1 1], [], true, PlotProps.Indexes.Letters{1}, PlotProps);
Axes.Position(1) = Axes.Position(1)+.08;
Axes.Position(3) = Axes.Position(3)-.08;
% Axes.Position(4) = Axes.Position(4)-.02;
plotUFO(Stats.hedgesg(Order), Stats.hedgesgCI(Order, :), WMZ_Names(Order), {}, WMZ_Colors(Order, :), 'vertical', PlotProps);
set(gca, 'XDir','reverse')
xlim([.5 numel(WMZ_Names)+.5])

ylabel(P.Labels.ES)
title('SD effect', 'FontSize',PlotProps.Text.TitleSize)

Axes = chART.sub_plot([], Grid, [1 2], [1 3], true, PlotProps.Indexes.Letters{2}, PlotProps);
Stats = corrAll(Data(:, Order), Data(:, Order), '', '', '', ...
    WMZ_Names(Order), StatsP, PlotProps, 'FDR');


