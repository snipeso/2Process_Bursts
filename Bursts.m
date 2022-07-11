% Scripts on all the questionnaire outputs

clear
clc
close all


P = getParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
PlotProps = P.Powerpoint;
Labels = P.Labels;
StatsP = P.StatsP;
Gender = P.Gender;

Refresh = false;
fs = 250;
Task = 'Fixation';

Results = fullfile(Paths.Results, 'EEG', 'Bursts');
if ~exist(Results, 'dir')
    mkdir(Results)
end
TitleTag = [Task, '_Bursts'];

MegatTable_Filename = [Task, 'AllBursts.mat'];

load(fullfile(Paths.Data, 'EEG', 'Bursts_Table', MegatTable_Filename), 'BurstTable', 'Missing')


%% plot change in time


zScore = [false, true];
Variables = {'Tot', 'Mean_Coh_amplitude', 'nPeaks'};
Bands = {'Theta', 'Alpha'};

% gender colors
Colors = repmat(getColors(1, '', 'blue'), numel(Participants), 1);
Female = strcmp(Gender, 'F');
Colors(Female, :) = repmat(getColors(1, '', 'pink'), nnz(Female), 1);

Fits = struct();
X = [4 7 10 14.5 17.5 20 23 26.5];
WMZ = 6:7;
TestPoint = 8;

for Z = false %zScore
    for Indx_B = 1:2
        for Indx_V = 1:numel(Variables)

            V =Variables{Indx_V};
            if strcmp(V, 'Tot')
                Matrix = tabulateTable(BurstTable, 'FreqType', 'tabulate', Participants, Sessions);
                Matrix = squeeze(Matrix(:, :, Indx_B));
                Matrix(isnan(Matrix)) = 0;

            elseif strcmp(V, 'nPeaks')
                T = BurstTable(BurstTable.FreqType == Indx_B, :);
                Matrix = tabulateTable(T, 'nPeaks', 'sum', Participants, Sessions);
                Matrix(isnan(Matrix)) = 0;
            else
                T = BurstTable(BurstTable.FreqType == Indx_B, :);
                Matrix = tabulateTable(T, V, 'mean', Participants, Sessions);
            end

            Matrix(logical(Missing(:))) = nan;

            if Z
                Matrix = (Matrix-mean(Matrix, 2, 'omitnan'))./std(Matrix, 0, 2, 'omitnan');
            end

            figure('Units','normalized', 'Position', [0 0 .5 .7])
            Stats = data2D('line', Matrix, Labels.Sessions, [], [], PlotProps.Color.Participants, StatsP, PlotProps);
            Title = [replace(V, '_', ' '), ' ', Bands{Indx_B}];
            title(Title,  'FontSize', PlotProps.Text.TitleSize)

            if Z
                saveFig(strjoin({TitleTag, 'AllSessions', V,  Bands{Indx_B},  'zscore'}, '_'), Results, PlotProps)

                % fit data
                Y  = mean(Matrix(:, 4:11), 'omitnan'); % get only 24h period
                Struct = fitStruct(X, Y, WMZ, TestPoint);
                Struct.Variable = [V, '_', Bands{Indx_B}, '_', Task];
                Fits = catStruct(Fits, Struct);

            else
                saveFig(strjoin({TitleTag, 'AllSessions',  V,  Bands{Indx_B}}, '_'), Results, PlotProps)


                % look at gender differences as well
                figure('Units','normalized', 'Position', [0 0 .5 .7])
                Stats = groupDiff(Matrix, Labels.Sessions, [], [], Colors, StatsP, PlotProps);
                title(Title, 'FontSize', PlotProps.Text.TitleSize)
                saveFig(strjoin({TitleTag, 'Gender', 'BySession', V, Bands{Indx_B}}, '_'), Results, PlotProps)
            end
        end
    end
end


Fit_Table = struct2table(Fits);
writetable(Fit_Table, fullfile(Results, strjoin({TitleTag, 'Fits.csv'}, '_')))


%% Plot effect sizes

Variables = {'Mean_Coh_amplitude', 'Tot'};

Before = nan(numel(Participants), 2, numel(Variables), 2); % band x variable x comparison
After = Before;
Colors = repmat([.5 .5 .5], numel(Variables), 1);
notWMZ_Indx = 7:8;
WMZ_Indx = 9:10;
Start_Indx = 5:6;
Z = true;

for Indx_B = 1:2
    for Indx_V = 1:numel(Variables)

        V = Variables{Indx_V};
        if strcmp(V, 'Tot')
            Matrix = tabulateTable(BurstTable, 'FreqType', 'tabulate', Participants, Sessions);
            Matrix = squeeze(Matrix(:, :, Indx_B));
            Matrix(isnan(Matrix)) = 0;

        elseif strcmp(V, 'nPeaks')
            T = BurstTable(BurstTable.FreqType == Indx_B, :);
            Matrix = tabulateTable(T, 'nPeaks', 'sum', Participants, Sessions);
            Matrix(isnan(Matrix)) = 0;
        else
            T = BurstTable(BurstTable.FreqType == Indx_B, :);
            Matrix = tabulateTable(T, V, 'mean', Participants, Sessions);
        end

        Matrix(logical(Missing(:))) = nan;

        if Z
            Matrix = (Matrix-mean(Matrix, 2, 'omitnan'))./std(Matrix, 0, 2, 'omitnan');
        end



        % Start vs preMWZ
        Before(:, Indx_B, Indx_V, 1) = mean(Matrix(:, Start_Indx), 2, 'omitnan');
        After(:, Indx_B, Indx_V, 1) = mean(Matrix(:, notWMZ_Indx), 2, 'omitnan');

        % preWMZ vs WMZ
        Before(:, Indx_B, Indx_V, 2) = mean(Matrix(:, notWMZ_Indx), 2, 'omitnan');
        After(:, Indx_B, Indx_V, 2) = mean(Matrix(:, WMZ_Indx), 2, 'omitnan');
    end
end


%%

VariableLabels = {'Amplitude', 'Quantity'};
figure('Units','normalized', 'OuterPosition', [0 0 .5 .4])
subplot(1, 2, 1)
Stats = hedgesG(squeeze(Before(:, 1, :, :)), squeeze(After(:, 1, :, :)), StatsP);
plotUFO(Stats.hedgesg, Stats.hedgesgCI, VariableLabels, {'\DeltaDay', '\DeltaWMZ'}, Colors, 'vertical', PlotProps)
legend off
ylim([-3.5 3.5])
xlim([0 3])
ylabel("Hedge's G")
title('Theta')

subplot(1, 2, 2)
Stats = hedgesG(squeeze(Before(:, 2, :, :)), squeeze(After(:, 2, :, :)), StatsP);
plotUFO(Stats.hedgesg, Stats.hedgesgCI, VariableLabels, {'\DeltaDay', '\DeltaWMZ'}, Colors, 'vertical', PlotProps)
ylim([-3.5 3.5])
ylabel("Hedge's G")
xlim([0 3])
title('Alpha')



saveFig(strjoin({TitleTag, 'WMZ', 'HedgesG'}, '_'), Results, PlotProps)

