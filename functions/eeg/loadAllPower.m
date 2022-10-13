function [AllData, Freqs, Chanlocs] = loadAllPower(Source, Participants, Sessions, Tasks)
% [AllData, Freqs, Chanlocs] = loadAllPower(P, Source, Tasks)
% For 2process_Bursts

% load all power from main tasks. Takes P from analysisParameters(), Source
% is the folder with the FFT data (split by task), and Tasks is the list
% of task folders to include.
% Results in variable "AllData": P x S x T x Ch x F; and Chanlocs and Freqs

AllData = nan(numel(Participants), numel(Sessions), numel(Tasks));

% get little name tag
A = getContent(fullfile(Source, Tasks{1}));
B = split(A(1), '_');
Tag = B(end);

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        for Indx_T = 1:numel(Tasks)
            Task = Tasks{Indx_T};

            %%% load data
            Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, char(Tag)}, '_');
            Path = fullfile(Source, Task, Filename);
            
            % deal with missing data
            if ~exist(Path, 'file')
                warning(['Missing ', Filename])
                if not(Indx_P==1 && Indx_S ==1 && Indx_T==1)
                    AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = nan; %#ok<NODEF>
                end
                continue
            end
            
            load(Path, 'Power', 'Freqs', 'Chanlocs')
            
            % deal with weirdly missing data
            if isempty(Power)
                 AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = nan;
                continue
            end
            
            % save
            AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = Power;
            clear Power
        end
    end
end