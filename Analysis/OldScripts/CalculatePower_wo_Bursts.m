% calculate power from EEG after removing timepoints with theta and alpha
clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
% Tasks = P.Tasks;
Tasks = {'Standing'};
Bands = P.Bands;

MinDuration = 60; % seconds
WelchWindow = 8; % duration of window to do FFT
Overlap = .75; % overlap of hanning windows for FFT

Refresh = true;

BandLabels = fieldnames(Bands);

Source_EEG = fullfile(Paths.Preprocessed, 'Clean', 'Waves');
Source_Bursts = fullfile(Paths.Data, 'EEG', 'Bursts');
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts');
Destination = fullfile(Paths.Data, 'EEG', 'BurstLessPower');

for Indx_T = 1:numel(Tasks)
    Task=Tasks{Indx_T};

    Files = getContent(fullfile(Source_EEG, Task));

    for Indx_F = 90%1:numel(Files)
        Filename_EEG = Files{Indx_F};
        Filename_Bursts = replace(Filename_EEG, 'Clean', 'Bursts');
        Filename_Cuts = replace(Filename_EEG, 'Clean', 'Cuts');
        Cuts_Filepath = fullfile(Source_Cuts, Task, Filename_Cuts);

        if contains(Filename_EEG, 'P00')
            continue
        end

        Burst_Path = fullfile(Source_Bursts, Task, Filename_Bursts);
        if ~exist(Burst_Path, 'file')
            warning(['No bursts for ', Filename_EEG])
            continue
        end

        % skip if refresh
        D = fullfile(Destination, 'Whole', Task);
        if ~exist(D, 'dir')
            mkdir(D)
        end
        if ~Refresh && exist(fullfile(D, replace(Filename_Bursts, 'Bursts', 'Whole')), 'file')
            disp(['Skipping ', Filename_Bursts])
            continue
        end

        % load data
        load(fullfile(Source_EEG, Task, Filename_EEG), 'EEG')
        load(Burst_Path, 'Bursts')

        fs = EEG.srate;
        Chanlocs = EEG.chanlocs;

        % power with bursts

        % make nan all timepoints marked as noise
        EEG = nanNoise(EEG, Cuts_Filepath);

        Temp = rmNaN(EEG);
        [Power, Freqs] = getPower(Temp.data, fs, WelchWindow, Overlap);
        Duration = size(Temp.data, 2)/fs;
        save(fullfile(D, replace(Filename_Bursts, 'Bursts', 'Whole')), ...
            'Power', 'Freqs', 'fs', 'Chanlocs', 'Duration')


        % power without each burst category
        MeanFreqs = 1./[Bursts.Mean_period];
        for Indx_B = 1:numel(BandLabels)
            Range = Bands.(BandLabels{Indx_B});
            B = Bursts(MeanFreqs>Range(1) & MeanFreqs<=Range(2));

            if isfield(B, 'All_Start')
                Starts = [B.All_Start];
                Ends = [B.All_End];
            else
                continue
            end

            Temp = pop_select(EEG, 'nopoint', [Starts', Ends']);
            Temp = rmNaN(Temp);

            if size(Temp.data, 2) < fs*MinDuration
                continue
            end

            [Power, Freqs] = getPower(Temp.data, fs, WelchWindow, Overlap);

            Tag =  ['wo', BandLabels{Indx_B}];
            D = fullfile(Destination, Tag, Task);
            if ~exist(D, 'dir')
                mkdir(D)
            end
            Duration = size(Temp.data, 2)/fs;
            save(fullfile(D, replace(Filename_Bursts, 'Bursts', Tag)), ...
                'Power', 'Freqs', 'fs', 'Chanlocs', 'Duration')
        end
        disp(['Finished ', Filename_Bursts])
    end
end




function [Power, Freqs] = getPower(Data, fs, WelchWindow, Overlap)
% calculates power

nfft = 2^nextpow2(WelchWindow*fs);
noverlap = round(nfft*Overlap);
window = hanning(nfft);
[Power, Freqs] = pwelch(Data', window, noverlap, nfft, fs);
Power = Power';
Freqs = Freqs';

end













