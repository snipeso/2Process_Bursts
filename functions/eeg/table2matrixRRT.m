function Matrix = table2matrixRRT(Table, AllMissing, Variable, Participants, Sessions, Tasks, zScore)
% extracts from a table all the info needed and converts it to a matrix

Matrix = [];

for Indx_T = 1:numel(Tasks)
    BurstTable = Table(strcmp(Table.Task, Tasks{Indx_T}), :);

    if strcmp(Variable, 'Tot')
        M = tabulateTable(BurstTable, 'FreqType', 'tabulate', Participants, Sessions);
        M(isnan(M)) = 0;

    elseif strcmp(Variable, 'nPeaks')

        M = tabulateTable(BurstTable, 'nPeaks', 'sum', Participants, Sessions);
        M(isnan(M)) = 0;
    else

        M = tabulateTable(BurstTable, Variable, 'mean', Participants, Sessions);
    end

    Missing = AllMissing(:, :, Indx_T);
    M(logical(Missing(:))) = nan;

    Matrix = cat(3, Matrix, M);
end


if zScore
    Matrix = zScoreData(Matrix, 'last');
end


