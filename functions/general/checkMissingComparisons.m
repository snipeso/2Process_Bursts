function N = checkMissingComparisons(Data)
% Data is a P x S matrix
Dims = size(Data);

N = nan(Dims(2));
for Indx_S1 = 1:Dims(2)
    for Indx_S2 = Indx_S1+1:Dims(2)
    if Indx_S1 == Indx_S2
        continue
    end
D1 = Data(:, Indx_S1);
D2 = Data(:, Indx_S2);

     N(Indx_S1, Indx_S2) = sum(nnz(not(isnan(D2)|isnan(D1))));

    end
end


