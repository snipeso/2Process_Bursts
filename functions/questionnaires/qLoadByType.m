function Answers = qLoadByType(Table)
% from table of questions, gives a single array or cell array depending on
% what the question answer type is

Type = Table.qType{1};
ColNames = Table.Properties.VariableNames;

switch Type
    case 'Slider'
        if isfield(Table, 'numAnswer')
            Ans = Table.numAnswer;
        else
            Ans = Table.numAnswer_1;
        end
    case 'MultipleChoice'
        Cols = ColNames(contains(ColNames, 'numAnswer'));

        Ans = table2array(Table(:, Cols));
    otherwise
        error('unknown type')
end
