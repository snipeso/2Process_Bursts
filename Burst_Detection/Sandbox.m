clear
clc
close all

Info = burstParameters();
Paths = Info.Paths;
Bands = Info.Bands;
BandLabels = fieldnames(Bands);

% place to try different parameters for burst detection

Task = 'PVT'; % Game or PVT
Session = 'Session2Comp';
Participant = 'P15';
Filename_Source = strjoin({Participant, Task, Session, 'Clean.mat'}, '_');



%%


Min_Peaks = 4;

BT = struct();
BT.monotonicity = .6;
BT.periodConsistency = .6;
BT.periodMeanConsistency = .6;
BT.efficiency = .6;
BT.truePeak = 1;
BT.flankConsistency = .5;
BT.ampConsistency = .6;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
Source = fullfile(Paths.Preprocessed, 'Clean', 'Waves', Task); % normal data
Source_Filtered = fullfile(Paths.Preprocessed, 'Clean', 'Waves_Filtered', Task); % extremely filtered data
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task); % timepoints marked as artefacts


% load data
Filename_Filtered = replace(Filename_Source, 'Clean.mat', 'Filtered.mat');
Filename_Cuts = replace(Filename_Source, 'Clean.mat', 'Cuts.mat');

M = load(fullfile(Source, Filename_Source), 'EEG');
EEG = M.EEG;
fs = EEG.srate;

% get timepoints without noise
NoiseEEG = nanNoise(EEG, fullfile(Source_Cuts, Filename_Cuts));
Keep_Points = ~isnan(NoiseEEG.data(1, :));

% need to concatenate structures
FiltEEG = EEG;
FiltEEG.Band = [];

for Indx_B = 1:numel(BandLabels) % get bursts for all provided bands

    % load in filtered data
    Band = Bands.(BandLabels{Indx_B});
    F = load(fullfile(Source_Filtered, BandLabels{Indx_B}, Filename_Filtered));
    FiltEEG(Indx_B) = F.FiltEEG;
end


% %% clean
% BT = struct();
% BT.isProminent = 1;
% BT.periodConsistency = .7;
% BT.periodMeanConsistency = .7;
% BT.truePeak = 1;
% BT.efficiencyAdj = .6;
% % BT.flankConsistency = .5;
% BT.ampConsistency = .25;
% 
% 
% %% dirty
% BT = struct();
% BT.monotonicity = .6;
% BT.periodConsistency = .6;
% BT.periodMeanConsistency = .6;
% BT.efficiency = .6;
% BT.truePeak = 1;
% BT.flankConsistency = .5;
% BT.ampConsistency = .5;
% % BT.efficiencyAdj = .6;

%% single channel

Ch = 11;
Indx_B = 2;

Ch = labels2indexes(Ch, EEG.chanlocs);

Signal = EEG.data(Ch, :);
fSignal = FiltEEG(Indx_B).data(Ch, :);

Peaks = peakDetection(Signal, fSignal);
Peaks = peakProperties(Signal, Peaks, fs);
BT.period = 1./Bands.(BandLabels{Indx_B}); % add period threshold
[Bursts, BurstPeakIDs, Diagnostics] = findBursts(Peaks, BT, Min_Peaks, Keep_Points);

plotBursts(Signal, fs, Peaks, BurstPeakIDs, BT)

%% Everything
% get bursts in all data
AllBursts = getAllBursts(EEG, FiltEEG, BT, Min_Peaks, Bands, Keep_Points);



%%
previewBursts(EEG, 20, AllBursts, 'Band')


%%
Bursts = burstPeakProperties(AllBursts, EEG);
        Bursts = meanBurstPeakProperties(Bursts); % just does the mean of the main peak's properties


%% Final distibution of bursts

figure
histogram(1./[Bursts.Mean_period])


%% power in and out of bursts
WelchWindow = 8; % duration of window to do FFT
Overlap = .75; % overlap of hanning windows for FFT
  nfft = 2^nextpow2(WelchWindow*fs);
            noverlap = round(nfft*Overlap);
            window = hanning(nfft);

EEG1 = pop_select(EEG, 'nopoint', [[AllBursts.Start]', [AllBursts.End]']);
 [Power1, Freqs] = pwelch(EEG1.data', window, noverlap, nfft, fs);
 [Power, ~] = pwelch(EEG.data', window, noverlap, nfft, fs);

 %%

figure('units', 'normalized', 'Position', [0 0 .5 .5])
subplot(1, 3, 1)
plot(log(Freqs), log(Power)', 'Color', [.5 .5 .5 .2], 'LineWidth', 1)
title('Original Data')
xlim(log([1 40]))

subplot(1, 3, 2)
plot(log(Freqs), log(Power1)', 'Color', [.5 .5 .5 .2], 'LineWidth', 1)
title('Burstless Data')
xlim(log([1 40]))


subplot(1, 3, 3)
hold on
plot(log(Freqs), log(mean(Power, 2)), 'LineWidth',2)
plot(log(Freqs), log(mean(Power1, 2)), 'LineWidth',2)
legend({'original', 'burstless'})
xlim(log([1 40]))

