function [RightData, LeftData, MeanData ] = EqualizeLength(TSPrep, LTSProc, RTSProc, MeanTSProc, LDiaProc, RDiaProc, MeanDiaProc)
%Stretch data to length before processing, so that all vectors (left,right,
%mean) have same length
%   Detailed explanation goes here
% left eye
if isequal(LDiaProc, RDiaProc)
%     prep(:,1) = TSprep;
%     prep(:,2) = LDiaPrep;
    nan_times = nan(size(TSPrep));
    nan_times(ismember(TSPrep, LTSProc)) = LTSProc;
    nan_dia = nan(size(TSPrep));
    nan_dia(ismember(nan_times, TSPrep)) = LDiaProc;
    LeftData(:,1) = TSPrep; %nan_times before
    LeftData(:,2) = nan_dia;
    RightData = LeftData;
    MeanData = LeftData;
else
    %left eye
%     prep(:,1) = TSprep;
    L_nan_times = nan(size(TSPrep));
    L_nan_times(ismember(TSPrep, LTSProc)) = LTSProc;
    L_nan_dia = nan(size(TSPrep));
    L_nan_dia(ismember(L_nan_times, TSPrep)) = LDiaProc;
    LeftData(:,1) = TSPrep; %L_nan_times before
    LeftData(:,2) = L_nan_dia;
    
    %right eye
%     prep(:,1) = TSPrep;
    R_nan_times = nan(size(TSPrep));
    R_nan_times(ismember(TSPrep, RTSProc)) = RTSProc;
    R_nan_dia = nan(size(TSPrep));
    R_nan_dia(ismember(R_nan_times, TSPrep)) = RDiaProc;
    RightData(:,1) = TSPrep; %R_nan_times before
    RightData(:,2) = R_nan_dia;
    
    % mean
    Mean_nan_times = nan(size(TSPrep));
    Mean_nan_times(ismember(TSPrep, MeanTSProc)) = MeanTSProc;
    Mean_nan_dia = nan(size(TSPrep));
    Mean_nan_dia(ismember(Mean_nan_times, TSPrep)) = MeanDiaProc;
    MeanData(:,1) = TSPrep; %Mean_nan_times before
    MeanData(:,2) = Mean_nan_dia;
end

