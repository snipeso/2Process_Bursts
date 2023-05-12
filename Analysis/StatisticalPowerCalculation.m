
clear
clc
close all

DataPath = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper2\Figures';
Filename = 'AllData.csv';

AllData = readtable(fullfile(DataPath, Filename));


%%
clc

AllMeasurements = unique(AllData.Measurement);

for Indx_M = 1:numel(AllMeasurements)

    Data = AllData.zValue(strcmp(AllData.Measurement, AllMeasurements{Indx_M}) & ...
        strcmp(AllData.Session, 'S1') & strcmp(AllData.Condition, 'Fixation'));
    if isempty(Data)
        continue
    end
    M1 = mean(Data, 'omitnan');
    STD = std(Data, 'omitnan');
%     N = nnz(~isnan(Data));
N = 18;
    DF = N-1;

    M2 = sampsizepwr('t', [M1, STD], [], .8, N);

    % Cohen's d
    d = (M2 - M1)/STD;

    % Hedge's g
    g = d/sqrt(N/DF);

    disp(['Hedges g for ' AllMeasurements{Indx_M},' (N=', num2str(N), '): ', num2str(g)])

end