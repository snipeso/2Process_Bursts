function [Answers, Labels] = qtable2matrix(Table, Participants, Sessions, qID)
% pulls out all the answers to a specific question in a table, and sorts it
% into a P x S matrix.

if ismember(Table.qType(1), {'Slider'})
Answers = nan(numel(Participants), numel(Sessions));
else
Answers = cell([numel(Participants), numel(Sessions)]);
end


for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)

        
        % get answer of specific session for specific participant
        QuestionIndexes = strcmp(Table.qID, qID) & ...
            strcmp(Table.dataset, Participants{Indx_P}) & ...
            strcmp(Table.Level2, Sessions{Indx_S});

        Ans = qLoadByType(Table(QuestionIndexes, :));
        
        
        % handle problems
        if numel(Ans) < 1
            continue
        elseif numel(Ans) > 1
            error(['Not unique answers for ', qID, ' in ' Participants{Indx_P}, ' ', Sessions{Indx_S} ])
        end
        
        % save in appropriate way
        if numel(Ans) ==1 && (isa(Ans, 'double') || isa(Ans, 'single'))
            Answers(Indx_P, Indx_S) = Ans;
        else
            Answers{Indx_P, Indx_S} = Ans;
        end
        
    end
end


%%% gather labels
Labels = Table.qLabels(find(QuestionIndexes, 1));
Labels = replace(Labels, '//', '-');
Labels = split(Labels, '-');

% hack, because sometimes // splits labels, sometimes just / -.-"
if numel(Labels) == 1
    Labels = split(Labels, '/');
end

% cut short really long labels
for Indx_L = 1:numel(Labels)
    if contains( Labels{Indx_L}, ',')
        Labels{Indx_L} = extractBefore(Labels{Indx_L}, ',');
    end
end


