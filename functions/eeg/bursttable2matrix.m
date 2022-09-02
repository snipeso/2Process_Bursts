function Matrix = bursttable2matrix(Table, AllMissing, Durations, Variable, Participants, Sessions, Tasks, zScore)
% extracts from a table all the info needed and converts it to a matrix

%%% gather data
Matrix = [];
for Indx_T = 1:numel(Tasks)
    BurstTable = Table(strcmp(Table.Task, Tasks{Indx_T}), :);

    % handle weird data types
    if strcmp(Variable, 'Tot')
        M = tabulateTable(BurstTable, 'FreqType', 'tabulate', Participants, Sessions);
        M(isnan(M)) = 0;

    elseif strcmp(Variable, 'nPeaks')

        M = tabulateTable(BurstTable, 'nPeaks', 'sum', Participants, Sessions);
        M(isnan(M)) = 0;
    else

        M = tabulateTable(BurstTable, Variable, 'mean', Participants, Sessions);
    end

    % set to nan values in which there was no data
    Missing = AllMissing(:, :, Indx_T);
    M(logical(Missing(:))) = nan;

    Matrix = cat(3, Matrix, M);
end

% if the variable is some form of total, and durations are provided,
% normalize the total by the durations
if ~isempty(Durations) && ismember({'Tot', 'nPeaks'}, Variable)
    Matrix = Matrix./Durations;
end

% normalize the data
if zScore
    Matrix = zScoreData(Matrix, 'last');
end
