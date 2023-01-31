function Table = mat2table(Matrix, zMatrix, Measurement, Participants, Sessions, Tasks, Bands)
% turns the matrices into the same table structure

Dims = size(Matrix);

Table = cell2table(cell(numel(Matrix), 4), 'VariableNames', {'Measurement', 'Participant', 'Session', 'Condition'});

Indx = 1;
switch numel(Dims)
    case 2

        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)

                Table.Measurement{Indx} = Measurement;
                Table.Participant(Indx) = Participants(Indx_P);
                Table.Session(Indx) = Sessions(Indx_S);
                Table.Condition{Indx} = '-';
                Table.Value(Indx) = Matrix(Indx_P, Indx_S);
                Table.zValue(Indx) = zMatrix(Indx_P, Indx_S);
                Indx = Indx+1;
            end
        end

    case 3
        for Indx_P = 1:numel(Participants)
            for Indx_T = 1:Dims(3)
                for Indx_S = 1:numel(Sessions)

                    Table.Measurement{Indx} =  Measurement;
                    Table.Participant(Indx) = Participants(Indx_P);
                    Table.Session(Indx) = Sessions(Indx_S);
                    Table.Condition(Indx) = Tasks(Indx_T);
                    Table.Value(Indx) = Matrix(Indx_P, Indx_S, Indx_T);
                    Table.zValue(Indx) = zMatrix(Indx_P, Indx_S, Indx_T);
                    Indx = Indx+1;
                end

            end
        end

    case 4
        for Indx_P = 1:numel(Participants)
            for Indx_T = 1:numel(Tasks)
                for Indx_B = 1:numel(Bands)
                    for Indx_S = 1:numel(Sessions)

                        Table.Measurement(Indx) = {strjoin([Bands(Indx_B), Measurement], ' ')};
                        Table.Participant(Indx) = Participants(Indx_P);
                        Table.Session(Indx) = Sessions(Indx_S);
                        Table.Condition(Indx) = Tasks(Indx_T);
                        Table.Value(Indx) = Matrix(Indx_P, Indx_S, Indx_T, Indx_B);
                        Table.zValue(Indx) = zMatrix(Indx_P, Indx_S, Indx_T, Indx_B);
                        Indx = Indx+1;
                    end
                end
            end
        end

    otherwise
        error('Dont know this dimention of matrix')

end

