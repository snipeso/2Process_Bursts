function diameter = pupil2pdm(eye1, eye2, new_srate)
% Convert pupil data tables from both eyes (with columns mm and timestamp)
% into structure used by PDM (PupilDiameterModel).
% Script by Elias Meier in 2process_Bursts

% Input:
% Pupil data tables with columns mm and timestamps (eye1 and eye2).
% New sampling rate (new_srate).

% Output:
% Structure with fields: diameter for left and right eye and timestamps.

diameter = struct();

% If one eye wasn't recorded (or bad data quality), copy data from
% available eye (because processing model requires input from two eyes)
if isempty(eye1)
    eye1 = eye2;
elseif isempty(eye2)
    eye2 = eye1;
end

% Interpolate diameter vectors so they have same sampling rate
Tot_Duration = max(eye1.pupil_timestamp(end), eye2.pupil_timestamp(end));
t = linspace(0, Tot_Duration, new_srate*Tot_Duration);

diameter.L = transpose(interp1(eye1.pupil_timestamp, eye1.diameter, t, 'linear'));
diameter.R = transpose(interp1(eye2.pupil_timestamp, eye2.diameter, t, 'linear'));
diameter.t_ms = transpose(t);