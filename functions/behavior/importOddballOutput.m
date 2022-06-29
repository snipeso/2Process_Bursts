function Output = importOddballOutput(filepath, OutputType, extraFields)
% TEMP: old import bhavioral output function; to be reviewed
% extraFields should be a 2 x n cell array, with the first row indicating
% the field name, and the second the field value


TrialStruct = struct();

% convert from txt to cell array
Text = fileread(filepath);
TextTrials = splitlines(Text);

% convert JSON in each cell to struct
if strcmp(TextTrials{1}(1:7), '{"pupil')
    Start = 2;
else
    Start = 1;
end

for Indx_T = Start:numel(TextTrials)

    % skip empty rows
    if isempty(TextTrials{Indx_T})
        continue
    end

    % convert from JSON to struct
    Struct = jsondecode(TextTrials{Indx_T});
    if isempty(fieldnames(Struct))
        continue
    end

    % add new possible field names to ongoing trials structure
    NewFields = fieldnames(Struct);
    NewStruct = struct();
    for Field = NewFields'
        NewStruct.(Field{1}) = Struct.(Field{1});
    end

    % Add extra fields to struct
    if exist('extraFields', 'var') && numel(extraFields) > 0
        for Indx_F = 1:size(extraFields, 2)

            NewStruct.(extraFields{1, Indx_F}) = extraFields{2, Indx_F};

        end
    end

    % add pre-existing fieldnames to current structure, blank
    FNS = fieldnames(NewStruct);
    FNTS = fieldnames(TrialStruct);
    OldFields = setdiff(FNTS, FNS);
    for Field = OldFields'
        NewStruct.(Field{1}) = nan;
    end

    % add current structure to ongoing trials structure
    TrialStruct  = catStruct(TrialStruct, NewStruct);
end

% change output based on what was specified
switch OutputType
    case 'table'
        Output = struct2table(TrialStruct);
    otherwise
        Output = TrialStruct;
end

