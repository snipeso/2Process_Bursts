% load sleep data

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;

Participants = P.Participants;
Nights = P.Nights;
Bands.SWA = [2 4];

Hour = 60*60/20;
MaxHour = 12;
Channels = P.Channels;

TitleTag = 'SWA';
Source = fullfile(Paths.Data, 'EEG', 'Unlocked', 'window4s_full', 'Sleep');

%%% load each dataset
SWA_first = nan(numel(Participants), numel(Nights), MaxHour, 122, 513); % particpants, nights, max hours, channels, frequencies
SWA_last = SWA_first;

for Indx_P = 1:numel(Participants)
    for Indx_N = 1:numel(Nights)
        Filename = strjoin({Participants{Indx_P}, 'Sleep', Nights{Indx_N}, 'Welch.mat'}, '_');

        if ~exist(fullfile(Source, Filename), 'file')
            warning(['Missing ', Filename])
            continue
        end

        load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs', 'visnum')


        % start from first hour
        % get only NREM, identify epochs by hour
        NREM = find(ismember(visnum, [-2 -3]));
        NREM_Order = 1:numel(NREM);
        Bins = discretize(NREM_Order, 0:Hour:Hour*MaxHour);

        for Indx_H = 1:MaxHour
            Epochs = NREM(Bins==Indx_H);
            SWA_first(Indx_P, Indx_N, Indx_H, :, :) = squeeze(mean(Power(:, Epochs, :), 2, 'omitnan'));
        end

        % start from last hour
        NREM = flip(NREM);
        for Indx_H = 1:MaxHour
            Epochs = NREM(Bins==Indx_H);
            SWA_last(Indx_P, Indx_N, Indx_H, :, :) = squeeze(mean(Power(:, Epochs, :), 2, 'omitnan'));
        end
    end
    disp(['Finished ' Participants{Indx_P}])
end


% remove entirely NaN hours
NoHours = isnan(squeeze(mean(mean(mean(mean(SWA_first, 5, 'omitnan'), 4, 'omitnan'), 1, 'omitnan'), 2, 'omitnan')));
SWA_first(:, :, NoHours, :, :) = [];
SWA_last(:, :, NoHours, :, :) = [];


zData = zScoreData(SWA_first, 'last');
zData_last = zScoreData(SWA_last, 'last');
chData = meanChData(zData, Chanlocs, Channels.All, 4);
bData = squeeze(bandData(chData, Freqs, Bands, 'last'));

raw_chData = meanChData(SWA_first, Chanlocs, Channels.All, 4);
raw_bData = squeeze(bandData(raw_chData, Freqs, Bands, 'last'));
% save data in pool

%
%     D =
%     FreqRes = Freqs(2)-Freqs(1);
%   SWA = sum(D, 2, 'omitnan').*FreqRes;


%% Save to pool
% P x N x H (1st and last)

% raw values
EdgeHours = cat(3, SWA_first(:, :, 1, :, :), SWA_last(:, :, 1, :, :));
EdgeHours = meanChData(EdgeHours, Chanlocs, Channels.All, 4);
EdgeHours = bandData(EdgeHours, Freqs, Bands, 'last');

Data = EdgeHours;
save(fullfile(Paths.Pool, 'SWA_raw.mat'), 'Data')

% z-scored values
EdgeHours = cat(3, zData(:, :, 1, :, :), zData_last(:, :, 1, :, :));
EdgeHours = meanChData(EdgeHours, Chanlocs, Channels.All, 4);
EdgeHours = bandData(EdgeHours, Freqs, Bands, 'last');

Data = EdgeHours;
save(fullfile(Paths.Pool, 'SWA_z-scored.mat'), 'Data')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% plot NREM spectrums, z-scored, raw

Grid = [1 2];
BL_Indx = 1;
xLog = true;
PlotProps = P.Manuscript;

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])
A = chART.sub_plot([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{1}, PlotProps);

Data = squeeze(raw_chData(:, 1, :, :, :));
spectrumDiff(Data, Freqs, BL_Indx, [], getColors([1 size(Data, 2)]), xLog, PlotProps, [], P.Labels);
title('Raw', 'FontSize', PlotProps.Text.TitleSize)
ylabel('PSD')


A = chART.sub_plot([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{2}, PlotProps);

Data = squeeze(chData(:, 1, :, :, :));
spectrumDiff(Data, Freqs, BL_Indx, [], getColors([1 size(Data, 2)]), xLog, PlotProps, [], P.Labels);
title('Z-scored', 'FontSize', PlotProps.Text.TitleSize)
saveFig([TitleTag, '_spectrums_BL'], Paths.Paper, PlotProps)


%% plot change from 1st h pre, to 1st h post spectrum

xLog = true;
yLims = [1 40];

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])
A = chART.sub_plot([], Grid, [1, 1], [], true, ...
    PlotProps.Indexes.Letters{1}, PlotProps);

Data = log(squeeze(raw_chData(:, [2 3], 1, :, :)));
plotSpectrumMountains(Data, Freqs, xLog, yLims, PlotProps, P.Labels)
title('Log', 'FontSize', PlotProps.Text.TitleSize)
ylabel('PSD (log)')


A = chART.sub_plot([], Grid, [1, 2], [], true, ...
    PlotProps.Indexes.Letters{2}, PlotProps);

Data = squeeze(chData(:, [2 3], 1, :, :));
plotSpectrumMountains(Data, Freqs, xLog, yLims, PlotProps, P.Labels)
title('Z-scored', 'FontSize', PlotProps.Text.TitleSize)
saveFig([TitleTag, '_spectrums_SD'], Paths.Paper, PlotProps)


%% plot change in z-scored SWA across hours for all nights

Grid = [1 numel(Nights)];
yLims = [0 70];
% yLims = [-1.2 2.5];
figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

for Indx_N = 1:numel(Nights)

%            Data = squeeze(bData(:, Indx_N, :));
    Data = squeeze(raw_bData(:, Indx_N, :));
    A = chART.sub_plot([], Grid, [1, Indx_N], [], true, ...
        PlotProps.Indexes.Letters{Indx_N}, PlotProps);
    plotConfettiSpaghetti(Data, [], [], PlotProps.Color.Participants, yLims, PlotProps)
    title(Nights{Indx_N})
    ylim(yLims)
end

saveFig([TitleTag, '_SWA_overnight_z'], Paths.Paper, PlotProps)

%%
figure
data3D(bData(:, [1 3], :), 1, Nights([1 3]), string(1:8),  getColors(8, 'rainbow'), P.StatsP, PlotProps)


%% with raw data, plot change from 1st h to last h

% EdgeHours = log(cat(3, SWA_first(:, :, 1, :, :), SWA_last(:, :, 1, :, :)));
EdgeHours = cat(3, SWA_first(:, :, 1, :, :), SWA_last(:, :, 1, :, :));

EdgeHours = meanChData(EdgeHours, Chanlocs, Channels.All, 4);
EdgeHours = bandData(EdgeHours, Freqs, Bands, 'last');
% yLims = [1.5 4.5];
yLims = [0 250];

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width PlotProps.Figure.Height*0.35])

for Indx_N = 1:numel(Nights)

    Data = squeeze(EdgeHours(:, Indx_N, :, :, :));
    A = chART.sub_plot([], Grid, [1, Indx_N], [], true, PlotProps.Indexes.Letters{Indx_N}, PlotProps);
    plotConfettiSpaghetti(Data, [], [], PlotProps.Color.Participants, yLims, PlotProps)
    ylim(yLims)
end


%%

Start = squeeze(EdgeHours(:, 1, 1, :, :));
EndPre = squeeze(EdgeHours(:, 2, 2, :, :));
StartPost = squeeze(EdgeHours(:, 3, 1, :, :));
figure

%     Data = [StartPost, EndPre]./Start;

% Data = [StartPost, Start]./Start;
Data = [End, Start]./Start;
plotConfettiSpaghetti(Data, [], [], PlotProps.Color.Participants, yLims, PlotProps)


%% stats
clc

Stats = pairedttest(squeeze(bData(:, 1, 1:6)), squeeze(bData(:, 3, 1:6)), P.StatsP);
dispStat(Stats, [1 1], 'zscored SWA')
Stats = pairedttest(log(squeeze(raw_bData(:, 1, 1:6))), log(squeeze(raw_bData(:, 3, 1:6))), P.StatsP);
dispStat(Stats, [1 1], 'raw SWA')


%% seasons

SWA = squeeze(raw_bData(:, 2, 1));
Months = [ 2 2 2.2 2.2 2.4 3 3.2 5.4 5.8 6.2 6 6.2 10.4 10.8 11.1 11.2 11.2 12]';


figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.5 PlotProps.Figure.Height*0.2])
scatter(Months, SWA, 100, PlotProps.Color.Participants, 'filled')
title('SWA by season')
xlim([1 12])
set(gca, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)

saveFig([TitleTag, '_SWA_seasons'], Paths.Paper, PlotProps)


%% age

Age =  [23 23 21 23 25 23 20 20 nan 22 26 23 nan 23 22 18 24 22 ]';

figure('units', 'centimeters', 'position', [0 0 PlotProps.Figure.Width*.5 PlotProps.Figure.Height*0.2])
scatter(Age, SWA, 100, PlotProps.Color.Participants, 'filled')
title('SWA by age')
% xlim([1 12])
set(gca, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)

saveFig([TitleTag, '_SWA_age'], Paths.Paper, PlotProps)