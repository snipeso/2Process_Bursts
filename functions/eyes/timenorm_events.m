function [normalized_timestamps] = timenorm_events(unix_timestamps, Pupil)
% Convert unix timestamps to absolute timestamps in ms
% Script by Elias Meier in 2process_Bursts

t0 = Pupil.unix_timestamp(1);
normalized_timestamps = unix_timestamps;
% timestamp to seconds:
normalized_timestamps.timestamp = (unix_timestamps.timestamp - t0)*1000; 
% *1000 to get ms
end

