clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

% ROI = 'preROI';
ROI = 'All';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
Participants = P.Participants;
StatsP = P.StatsP;
Tasks = P.Tasks;


ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

Duration = 6; % minutes
WelchWindow = 8;

SmoothFactor=2; % for spectral plots

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = 'Power';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(Filepath, Participants, Sessions, Tasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');

% same for raw values
raw_chData = meanChData(AllData, Chanlocs, Channels.(ROI), 4);
raw_bData = bandData(raw_chData, Freqs, Bands, 'last');


% average channel data into 2 spots
sData = smoothFreqs(zData, Freqs, 'last', SmoothFactor);
chData = meanChData(sData, Chanlocs, Channels.preROI, 4);

ChLabels = fieldnames(Channels.preROI);


%% Save ROI power to pool

% z-scored
Data = squeeze(bData); % P x S x T x B
save(fullfile(Paths.Pool, [TitleTag, '_z-scored.mat']), 'Data')

% raw
Data = squeeze(raw_bData); % P x S x T x B
save(fullfile(Paths.Pool, [TitleTag, '_raw.mat']), 'Data')


%% Save spectrums to pool

Data = squeeze(chData); % P x S x T x ROI x F
save(fullfile(Paths.Pool, [TitleTag, '_spectrum.mat']), 'Data', 'Freqs', 'ChLabels')




