% converts EEG to EDF

clear
clc
close all

Refresh = false;
Task = 'Oddball';
Source = fullfile('E:\Data\Preprocessed\Pupils\Raw\', Task);

Destination = fullfile('E:\Public\2Process_Bursts\Pupils\', Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = getContent(Source);

for Indx_F = 1:numel(Files)
    Filename = Files{Indx_F};
    NewFilename = replace(Filename, '.mat', '.csv');

    if ~Refresh && exist(fullfile(Destination, NewFilename), 'file')
        disp(['already did ', NewFilename])
        continue
    end

    load(fullfile(Source, Filename), 'Pupil', 'Annotations')

    writetable(Pupil, fullfile(Destination, NewFilename))

    AnnotationFilename = replace(NewFilename, 'Pupils', 'Annotations');
    writetable(Annotations, fullfile(Destination, AnnotationFilename))
    disp(['Finished ', NewFilename])
end


