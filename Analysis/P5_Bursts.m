% scripts that gets figure for burst amplitudes vs cycles/sec

clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load parameters

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Tasks = P.Tasks;
TaskColors = P.TaskColors;
Bands = P.Bands;
BandLabels = fieldnames(Bands);

TitleTag = 'Bursts';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load data

% load z-scored
load('E:\Data\Final\All_2processBursts\Bursts_zscoreAmplitude.mat', 'Data')
Amplitudes = Data;

load('E:\Data\Final\All_2processBursts\Bursts_zscoreTotCycles.mat', 'Data')
Tots = Data;

% load raw
load('E:\Data\Final\All_2processBursts\Bursts_rawAmplitude.mat', 'Data')
rawAmplitudes = Data;

load('E:\Data\Final\All_2processBursts\Bursts_rawTotCycles.mat', 'Data')
rawTots = Data;



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Describe changes
clc


AllRaw = cat(5, rawAmplitudes, rawTots);
Labels = {'Amplitudes', 'Tots'};
UnitTypes = {' miV', ' cyc/min'};
Roundedness = 0;
Unit = '%';

BaseIndx = 4; % S1
CompareIndx = [6 11]; % S3 and S8


for Indx_L = 1:numel(Labels)
    for Indx_B = 1:numel(BandLabels)
        for Indx_T = 1:numel(Tasks)
            for C_Indx = CompareIndx
                Data1 = squeeze(AllRaw(:, BaseIndx, Indx_T, Indx_B, Indx_L));

                Data2 = squeeze(AllRaw(:, C_Indx, Indx_T, Indx_B, Indx_L));
                Data = 100*(Data2-Data1)./Data1;

                String = strjoin([Labels{Indx_L}, BandLabels(Indx_B), Sessions(C_Indx), Tasks(Indx_T)], ' ');
                dispDescriptive(Data, String, Unit, Roundedness);
                dispDescriptive(Data1, Sessions{BaseIndx}, UnitTypes{Indx_L}, 2);
                dispDescriptive(Data2, Sessions{C_Indx}, UnitTypes{Indx_L}, 2);
                disp('*')
            end
            disp('***')
        end
        disp('*******')
    end
    disp('____________')

    % Fix BL vs Stand BL (Berger effect)
    Data1 = squeeze(AllRaw(:, 2, 1, 2, Indx_L));
    Data2 = squeeze(AllRaw(:, 2, 3, 2, Indx_L));
    Data = 100*(Data2-Data1)./Data1;

    dispDescriptive(Data, [Labels{Indx_L}, ' Berger'], Unit, Roundedness);
    dispDescriptive(Data1, 'EO', UnitTypes{Indx_L}, 2);
    dispDescriptive(Data2, 'EC', UnitTypes{Indx_L}, 2);

    disp('____________')
end




%% table with actual values

AllRaw = cat(5, rawAmplitudes, rawTots);
Labels = {'Amplitudes', 'Tots'};
CompareIndx = [4 6 11]; % S3 and S8
Roundedness = 1;
UnitTypes = {' miV', ' cyc/min'};

VariableNames = ['Variable', 'Band', 'Task', Sessions(CompareIndx)];
AllStats = table();
for Indx_L = 1:numel(Labels)
    for Indx_B = 1:numel(BandLabels)
        for Indx_T = 1:numel(Tasks)

            AllStrings = [Labels(Indx_L), BandLabels(Indx_B), Tasks(Indx_T)];
            for Indx = CompareIndx
                Data = squeeze(AllRaw(:, Indx, Indx_T, Indx_B, Indx_L));
                String = dispDescriptive(Data, '', UnitTypes{Indx_L}, Roundedness);
                AllStrings = cat(2, AllStrings, String);
            end
            AllStats = cat(1, AllStats, cell2table(AllStrings, 'VariableNames', VariableNames));

        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot

%% Figure 5: Amplitude vs Quantity across sleep deprivation

PlotProps = P.Manuscript;

zScore = [false, true];
Variables = {'Mean_coh_amplitude', 'nPeaks'};
YLabels = {'Amplitude', 'Cycles/min'};
Bands = {'Theta', 'Alpha'};
YLimsZ = [-2.7 3; -2 4];
Grid = [2, 2]; % variables x bands
Flip = false; % flip data if it decreases with SD
StatParameters = []; % could be StatsP
Z = true;
Score = 'zscored';

Indx = 1;

AllData = cat(5, Amplitudes, Tots); % concatenate so I can loop

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.7 PlotProps.Figure.Height*0.55])

for Indx_V = 1:numel(Variables)
    for Indx_B = 1:2
        % adjust labels according to scale
        YLabel = [YLabels{Indx_V}, ' (z-scored)'];
        YLim = YLimsZ(Indx_V, :);

        % assemble data
        Variable = Variables{Indx_V};
        Data = squeeze(AllData(:, :, :, Indx_B, Indx_V));
        % plot
        A = subfigure([], Grid, [Indx_V, Indx_B], [], true, ...
            PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;
        plotBrokenRain(Data, [], YLim, TaskColors, Tasks, PlotProps)
        if Indx_B ==1
            ylabel(YLabel)
        end

        if Indx_V~=2 || Indx_B~=2
            legend off
        end

        if Indx_V ==1
            title(Bands{Indx_B})
        end
    end
end

saveFig(strjoin({TitleTag, 'All', Score}, '_'), Paths.Paper, PlotProps)




%% plot simple figure for graphic abstract

PlotProps = P.Powerpoint;
PlotProps.Line.Alpha = .15;
PlotProps.Text.AxisSize = 20;
PlotProps.Figure.Height = PlotProps.Figure.Width;


Hours = P.XLabels(4:11);
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.26 PlotProps.Figure.Height*0.26])
Data = squeeze(AllData(:, 4:11, 1, 2, 1));
plotConfettiSpaghetti(Data, [], Hours, repmat(getColors(1, '', 'yellow'), numel(Participants), 1), [], PlotProps)
ylabel('Alpha amplitudes (\muV z-scored)')
saveFig(strjoin({TitleTag, 'dummy', 'amplitudes'}, '_'), Paths.Paper, PlotProps)



figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.26 PlotProps.Figure.Height*0.26])
Data = squeeze(AllData(:, 4:11, 1, 2, 2));
plotConfettiSpaghetti(Data, [], Hours, repmat(getColors(1, '', 'blue'), numel(Participants), 1), [], PlotProps)
ylabel('Alpha quantities (cyc/min z-scored)')
saveFig(strjoin({TitleTag, 'dummy', 'quantities'}, '_'), Paths.Paper, PlotProps)


