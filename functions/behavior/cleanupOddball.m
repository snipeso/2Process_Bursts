function Answers = cleanupOddball(AllAnswers)
% Makes a nice table.
% Types: 0 is correct rejection, 1 is correct response, 2 is false alarm

% remove mystery entries where there's nothing
AllAnswers(isnan([AllAnswers.ISI{:}]), :) = [];

% set up new table with only relevant information
Answers = AllAnswers(:, {'Participant', 'Session', 'condition', 'ISI'});

Answers.ISI = cell2mat(Answers.ISI);
Answers.condition = string(Answers.condition);
Answers.Participant = string(Answers.Participant);
Answers.Session = string(Answers.Session);

for Indx_T = 1:size(Answers, 1)
    Answers.Trial(Indx_T) =  AllAnswers.trialID{Indx_T}.id;
    Answers.StimTime(Indx_T) =  AllAnswers.tone{Indx_T}.toneTime;
    
    try
    if iscell(AllAnswers.keyPresses{Indx_T})
    Answers.keyPress(Indx_T) = AllAnswers.keyPresses{Indx_T}{1}{2};
    Answers.button(Indx_T) =  string(AllAnswers.keyPresses{Indx_T}{1}{1});
    else
        Answers.keyPress(Indx_T) = nan;
        Answers.button(Indx_T) = "";
    end
    Answers.RT(Indx_T) = Answers.keyPress(Indx_T) - Answers.StimTime(Indx_T);

    catch


        a=1
    end

    % determine type of answer
    if strcmp(Answers.condition(Indx_T), 'Standard') && ~isnan(Answers.keyPress(Indx_T))
        Answers.Type(Indx_T) = 2;
    elseif strcmp(Answers.condition(Indx_T), 'Target') && ~isnan(Answers.keyPress(Indx_T))
         Answers.Type(Indx_T) = 1;
    else
        Answers.Type(Indx_T) = 0;
    end

end