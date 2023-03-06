function [Slopes, Intercepts, Power, Freqs] = getSlopes(EEG, Ranges, Datatype, FitType)
% in 2process-Bursts

Window = 4;


switch Datatype
    case 'ICA'
        tmpdata = eeg_getdatact(EEG, 'component', 1:size(EEG.icaweights,1));
        nRanges = size(Ranges, 1);
    otherwise
        dip('NormalEEG')
        tmpdata = EEG.data;
end

if ~exist("FitType", 'var')
    FitType = '';
end


[Power, Freqs] = quickPower(tmpdata, EEG.srate, Window); % for components
nChannels = size(Power, 1);


switch FitType
    case 'fooof'

        disp('getting fooof slopes')
        Slopes = nan( nChannels, nRanges);
        Intercepts = nan(nChannels, nRanges);

        for Indx_Ch = 1:nChannels
            for Indx_R = 1:nRanges
                try
                [Slopes(Indx_Ch, Indx_R), Intercepts(Indx_Ch, Indx_R)] = fooofFit(Freqs, ...
                    Power(Indx_Ch, :), Ranges(Indx_R, :), false);
                catch
                     Slopes(Indx_Ch, Indx_R)= nan;
                         Intercepts(Indx_Ch, Indx_R) = nan;
                         warning('fooof didnt fit!')
                end
            end
        end


    otherwise
        disp('getting fitted slopes')

        % get indexes
        Delta = dsearchn(Freqs', [3, 6]')';
        Beta = dsearchn(Freqs', [15, 40]');

        Delta = Delta(1):Delta(2);
        Beta = round(linspace(Beta(1), Beta(2), numel(Delta)));
        Indx = [Delta, Beta];


        Slopes = nan(1, nChannels);
        Intercepts = nan(1, nChannels);
        for Indx_Ch = 1:nChannels

            [Slopes(Indx_Ch), Intercepts(Indx_Ch)] = quickFit(log(Freqs(Indx)), ...
                log(Power(Indx_Ch, Indx)), false);

        end

end