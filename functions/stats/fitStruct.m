function Struct = fitStruct(X, Y, MWZ, TestPoint)
Y = 1 + Y - min(Y);

Y = Y(:);
X = X(:);

Points = 1:numel(Y);
Points(ismember(Points, [MWZ, TestPoint])) = [];

Fits = {
    'line', 'a*x+b';
    'log', 'a*log(x)+b';
    'isef', 'b-a*exp(-x./19.9)';
    };

Struct = struct();

for Indx_F = 1:size(Fits, 1)

    myfit = fittype(Fits{Indx_F, 2},'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b'});
    [f,gof, output] = fit(X, Y, myfit, 'Exclude', [MWZ, TestPoint]);

    Struct.([Fits{Indx_F, 1}, '_r2']) = gof.rsquare;
    Struct.([Fits{Indx_F, 1}, '_MWZ']) = getResidual(Y(Points), Y(MWZ), f(X(MWZ)));
    [Struct.([Fits{Indx_F, 1}, '_Test']), Struct.([Fits{Indx_F, 1}, '_TestSign'])] = ...
        getResidual(Y, Y(TestPoint), f(X(TestPoint)));
%     figure;plot(f, X, Y)
%     legend off

end

end



function [R, Sign] = getResidual(Y, y, y_pred)
% https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/coefficient-of-determination-r-squared.html#:~:text=Solution,into%20the%20regression%20line%20equation.

Y = [Y; y];

Diff = y-y_pred;
SSR = sum(Diff.^2); % sum squared reression
SST = sum((Y-mean(Y)).^2);

R = 1 - (SSR/SST);

Diff = mean(Diff);
Sign = (Diff/abs(Diff)); % get the sign of the residual

end