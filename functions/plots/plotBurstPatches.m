function plotBurstPatches(Bursts, nCh, fs, PlotProps)

DoneColors = [0 0 0 0];
Legend = {};

hold on
for Indx_B = 1:numel(Bursts)
    if isempty(Bursts(Indx_B).Mean_period)
        Freq = 1/Bursts(Indx_B).period;
        warning('empty burst?!')
    else
    Freq = 1/Bursts(Indx_B).Mean_period;
    end

    if Freq < 4
        Color = getColors(1, '', 'pink');
        if ~DoneColors(1)
            HV = 'on';
            DoneColors(1) = 1;
            Legend = cat(2, Legend, '<4Hz');
        else
            HV = 'off';
        end

    elseif Freq < 8
        Color = getColors(1, '', 'red');

        if ~DoneColors(2)
            HV = 'on';
             DoneColors(2) = 1;
              Legend = cat(2, Legend, '<8Hz');
        else
            HV = 'off';
        end

    elseif Freq < 12
        Color = getColors(1, '', 'blue');

        if ~DoneColors(3)
            HV = 'on';
             DoneColors(3) = 1;
              Legend = cat(2, Legend, '<12Hz');
        else
            HV = 'off';
        end

    else
        Color = getColors(1, '', 'yellow');

        if ~DoneColors(4)
            HV = 'on';
             DoneColors(4) = 1;
              Legend = cat(2, Legend, '>12Hz');
        else
            HV = 'off';
        end

    end


    % plot lines for each sub-channel
    Ch = Bursts(Indx_B).Coh_Burst_Channels;
    Starts =  Bursts(Indx_B).Coh_Burst_Starts/fs;
    Ends = Bursts(Indx_B).Coh_Burst_Ends/fs;
    plot([Starts(:), Ends(:)]', [Ch(:), Ch(:)]', 'LineWidth',PlotProps.Line.Width, 'Color', [Color, .2], 'HandleVisibility','off')

    Start = Bursts(Indx_B).Start/fs;
    End = Bursts(Indx_B).End/fs;
    Ch = Bursts(Indx_B).Channel;
    plot([Start, End], [Ch, Ch], 'LineWidth',PlotProps.Line.Width*2, 'Color', Color, 'HandleVisibility', HV)
end

axis tight
ylim([0 nCh+1])

legend(Legend)

chART.set_axis_properties(PlotProps)
