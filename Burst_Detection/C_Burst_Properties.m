% This is to identify additional features of the bursts that aren't part of
% the bycycle thing. Mostly:
% - channel extention
% - FFT in data ?
% - eyes open/closed
% - task info:
%   - tone or stimulus present (followed by button press or not)
%   - button response present (or absent if should have been)

clear
clc
close all

Info = getInfo();

Paths = Info.Paths;
Bands = Info.Bands;
MinCoherence = Info.MinCoherence;
MinCorr = Info.MinCorr;
Refresh = false;
Task = 'TV';

Source_Bursts = fullfile(Paths.Data, 'EEG', 'Bursts_All', Task);
Source_EEG = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);

Destination_Bursts = fullfile(Paths.Data, 'EEG', 'Bursts', Task);
if ~exist(Destination_Bursts, 'dir')
    mkdir(Destination_Bursts)
end

Content = getContent(Source_Bursts);
Content(~contains(Content, 'Burst')) = [];
for Indx_F = 1:numel(Content)

    Filename_Bursts = Content{Indx_F};
    Filename_EEG = replace(Filename_Bursts, 'Bursts.mat', 'Clean.mat');

    if exist(fullfile(Destination_Bursts, Filename_Bursts), 'file') && ~Refresh
        disp(['Skipping ', Filename_Bursts])
        continue
    else
        disp(['Loading ', Filename_Bursts])
    end

    load(fullfile(Source_EEG, Filename_EEG), 'EEG')

    fs = EEG.srate;
    [nCh, nPnts] = size(EEG.data);

    % load in eye data
    Source_Eyes = fullfile(Paths.Data, ['Pupils_', num2str(fs)], Task);
    Filename_Eyes = replace(Filename_Bursts, 'Bursts.mat', 'Pupils.mat');
    if exist(fullfile(Source_Eyes, Filename_Eyes), 'file')
        load(fullfile(Source_Eyes, Filename_Eyes), 'Eyes')
    else
        warning(['no eye tracking for ', Filename_Eyes])
        Eyes.DQ = nan;
    end

    % load bursts
    load(fullfile(Source_Bursts, Filename_Bursts), 'AllBursts')

    % assemble bursts
    Bursts = aggregateBursts(AllBursts, EEG, MinCoherence);

    % get properties of the main channel
    Bursts = burstPeakProperties(Bursts, EEG);
    Bursts = meanBurstPeakProperties(Bursts); % just does the mean of the main peak's properties

    % get all coherent channels
%     Bursts = getAllInvolvedChannels(Bursts, EEG, MinCoherence, MinCorr);
    
    % classify the burst
    Bursts = classifyBursts(Bursts);

    % Get microsleep information for each burst

    for Indx_B = 1:numel(Bursts)
        if ~isnan(Eyes.DQ) && Eyes.DQ ~= 0
            B = Bursts(Indx_B);

            Bursts(Indx_B).EO = Eyes.EO(round(Eyes.DQ), B.NegPeakID);
            Bursts(Indx_B).Microsleep = Eyes.Microsleeps(round(Eyes.DQ), B.NegPeakID);

            % determine % time spent eyes open
            Start = B.Start;
            End = B.End;
            EO = Eyes.EO(round(Eyes.DQ), Start:End);
            if all(isnan(EO)) % if there is no microsleep information
                prcntEO = nan;
                prcntMicrosleep = nan;
            else
                prcntEO = nnz(EO==1)/nnz(EO==0 | EO==1);

                MS = Eyes.Microsleeps(round(Eyes.DQ), Start:End);
                prcntMicrosleep = nnz(MS==1)/nnz(MS==0 | MS==1);
            end

            Bursts(Indx_B).prcntEO = prcntEO;
            Bursts(Indx_B).prcntMicrosleep = prcntMicrosleep;
        else
            Bursts(Indx_B).prcntEO = nan;
            Bursts(Indx_B).prcntMicrosleep = nan;
        end
    end

    % save
    EEG.data = [];
    save(fullfile(Destination_Bursts, Filename_Bursts), 'Bursts', 'EEG')
    disp(['Finished ', Filename_Bursts])
    clear Eyes EEG
end


