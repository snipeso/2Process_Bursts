function Answers = qLoadByType(Table)
% from table of questions, gives a single array or cell array depending on
% what the question answer type is

Type = Table.qType{1};
ColNames = Table.Properties.VariableNames;

switch Type
    case {'Slider', 'SliderGroup', 'TypeInput', 'Radio'}
        if isfield(Table, 'numAnswer')
            Answers = Table.numAnswer;
        else
            Answers = Table.numAnswer_1;
        end
    case 'MultipleChoice'
        Cols = ColNames(contains(ColNames, 'numAnswer'));

        Answers = table2array(Table(:, Cols)); 
    case 'skipped'
        Answers = [];
    otherwise
        error('unknown type')
end
