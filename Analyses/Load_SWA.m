% load sleep data

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;

Participants = P.Participants;
Nights = P.Nights;
Bands.SWA = [1 4];

Hour = 60*60/20;
MaxHour = 12;
Channels = P.Channels.All.All;

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
        NREM = find(ismember(visnum, [-1 -2 -3]));
        NREM_Order = 1:size(NREM);
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
end


% remove entirely NaN hours
NoHours = isnan(squeeze(mean(mean(mean(mean(SWA_first, 5, 'omitnan'), 4, 'omitnan'), 1), 2)));
SWA_first(:, :, NoHours, :, :) = [];
SWA_last(:, :, NoHours, :, :) = [];


zData = zScoreData(SWA_first, 'last');
chData = meanChData(zData, Chanlocs, Channels.All, 4);
bData = squeeze(bandData(chData, Freqs, Bands, 'last'));


% save data in pool

%
%     D =
%     FreqRes = Freqs(2)-Freqs(1);
%   SWA = sum(D, 2, 'omitnan').*FreqRes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% plot NREM spectrums, z-scored, raw





%% plot change from 1st h pre, to 1st h post spectrum





%% plot change in z-scored SWA across hours for all nights




%% with raw data, plot change from 1st h to last h










