% Previous methods used either fixed thresholds or standard-deviation based
% thresholds to determine theta events. This is not ok when there's a
% highly variable amount of that oscillation in the signal.
clear
clc
close all

P = burstParameters();

Signals = [];
Titles = {};

% load high-theta signal
load('E:\Data\Preprocessed\Clean\Waves\Game\P10_Game_Session2_Clean.mat')
Signals = cat(1, Signals, EEG.data(11, 1:180*EEG.srate));
Titles = cat(1, Titles, 'HighTheta');

% load low-theta signal
load('E:\Data\Preprocessed\Clean\Waves\Game\P05_Game_Session2_Clean.mat')
Signals = cat(1, Signals, EEG.data(11, 1:180*EEG.srate));
Titles = cat(1, Titles, 'LowTheta');

% load no-theta signal
load('E:\Data\Preprocessed\Clean\Waves\Fixation\P03_Fixation_MainPre_Clean.mat')
Signals = cat(1, Signals, EEG.data(labels2indexes(60, EEG.chanlocs), 1:180*EEG.srate));
Titles = cat(1, Titles, 'NoTheta');

% load alpha signal
load('E:\Data\Preprocessed\Clean\Waves\Fixation\P09_Fixation_BaselinePost_Clean.mat')
Signals = cat(1, Signals, EEG.data(labels2indexes(72, EEG.chanlocs), 1:180*EEG.srate));
Titles = cat(1, Titles, 'Alpha');

[Power, Freqs] = quickPower(Signals, EEG.srate, 4, .5);
lPower = logPower(Power);

Dims = size(Signals);
%% Plot data

Colors = getColors(Dims(1));
figure
hold on
for Indx_S = 1:Dims(1)
    plot(log(Freqs), lPower(Indx_S, :), 'Color', Colors(Indx_S, :), 'LineWidth', 2);
end
legend(Titles)
xlim(log([2 40])); xticks(log([2 4 8 16 32])); xticklabels([2 4 8 16 32])