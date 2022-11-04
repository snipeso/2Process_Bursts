% converts mat files to csv that R can read for stats

P = analysisParameters();
Paths = P.Paths;
AllParticipants = P.Participants;
Sessions = P.Sessions;

Destination = fullfile(Paths.Stats, 'Data');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Tasks = P.Tasks;

load('E:\Data\Final\All_2processBursts\Bursts_rawAmplitude.mat')

AllAmps = Data;
Bands = {'Theta', 'Alpha'};

load('E:\Data\Final\All_2processBursts\Bursts_rawTots.mat')

AllTots = Data;

for Indx_B = 1:2
    for Indx_T = 1:numel(Tasks)

%         Participants = repmat(AllParticipants', numel(Sessions), 1);
        Participants = repmat([1:17, 19]', numel(Sessions), 1);
        Amps = squeeze(AllAmps(:, :, Indx_T, Indx_B));
        Amps = Amps(:);

        Tots = squeeze(AllTots(:, :, Indx_T, Indx_B));
        Tots = Tots(:);

        Table = table(Participants, Amps, Tots, 'VariableNames', {'Participant', 'Amplitude', 'Quantity'});
        writetable(Table, fullfile(Destination, [Tasks{Indx_T}, '_', Bands{Indx_B}, '_Bursts.csv']))
    end
end