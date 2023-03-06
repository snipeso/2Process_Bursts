


clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'All';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
Participants = P.Participants;
Tasks = P.Tasks;

FactorLabels = {'Session', 'Task'};

Duration = 6; % minutes
WelchWindow = 8;

SmoothFactor = 2; % for spectral plots

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = 'FOOOF';


Range = [1 40];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

%%% load power data
Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(Filepath, Participants, Sessions, Tasks);
chData = squeeze(meanChData(AllData, Chanlocs, Channels.(ROI), 4)); % P x S x T x F



%%
%%% calculate fooof
Slopes = nan(numel(Participants), numel(Sessions), numel(Tasks));
Intercepts = Slopes;



for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(Tasks)
            [Slopes(Indx_P, Indx_S, Indx_T), Intercepts(Indx_P, Indx_S, Indx_T)] = ...
                fooofFit(Freqs, squeeze(chData(Indx_P, Indx_S, Indx_T, :)), Range, false);
        end
    end
    disp(['Finished ', Participants{Indx_P}])
end


%% save

Data = Slopes; % P x S x T 
save(fullfile(Paths.Pool, [TitleTag, '_slopes.mat']), 'Data')
Data = Intercepts; % P x S x T 
save(fullfile(Paths.Pool, [TitleTag, '_intercepts.mat']), 'Data')


