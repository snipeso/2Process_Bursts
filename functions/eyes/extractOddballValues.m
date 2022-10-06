function [AuC] = extractOddballValues(Timecourse, t, Range)
% gets summary values for all the average timecourses

Dims = size(Timecourse);

Window = dsearchn(t(:), Range(:));

AuC = nan(Dims(1), Dims(2));

for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2)
        Tc = squeeze(Timecourse(Indx_P, Indx_S, :, Window(1):Window(2)));
        AuC(Indx_P, Indx_S) = mean(Tc(2, :)-Tc(1, :), 'omitnan');
    end
end