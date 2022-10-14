function [WMZ, noWMZ] = WMZinterp(Data)
% function to identify the "expected" location for the WMZ, vs the actual
% location.
% Data is a P x S[8:11] x whatever matrix

% time of day
X_WMZ = [20 23];
X_noWMZ = [17.5 26.5]; % outer edges, to establish data trajectory without the WMZ

X = mean(X_WMZ); % location to compare

Dims = size(Data);

% linear interpolation to the same point based on outer edge data vs WMZ data
WMZ = nan(Dims(1), Dims(3));
noWMZ = WMZ;
for Indx_1 = 1:Dims(1)
    for Indx_2 = 1:Dims(3)
        WMZ(Indx_1, Indx_2) = interp1(X_WMZ, squeeze(Data(Indx_1, 2:3, Indx_2)), X);
        noWMZ(Indx_1, Indx_2) = interp1(X_noWMZ, squeeze(Data(Indx_1, [1 4], Indx_2)), X);
    end
end