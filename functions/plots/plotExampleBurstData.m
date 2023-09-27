function plotExampleBurstData(EEG, YGap, Bursts, ColorCode, Colors, PlotProps)

[nCh, nPnts] = size(EEG.data);
t = linspace(0, nPnts/EEG.srate, nPnts);

Data = EEG.data;
DimsD = size(Data);

Y = YGap*DimsD(1):-YGap:0;
Y(end) = [];

hold on

%%% plot EEG
% Color = [.3 .3 .3];
Color = [.5 .5 .5];

Data = Data+Y';

plot(t, Data,  'Color', Color, 'LineWidth', PlotProps.Line.Width/3, 'HandleVisibility','off')

set(gca, 'YTick', [], 'YColor', 'none', 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)


if isempty(Bursts)
    return
end


%%% plot bursts

if isempty(ColorCode)
    Colors = 'b';
else
    % get colors for all the types of burst

    if ischar(Bursts(1).(ColorCode))
        Groups = unique({Bursts.(ColorCode)});
    else
        Groups = unique([Bursts.(ColorCode)]);
    end

    if ~isempty(Colors)
    elseif numel(Groups) <= 8
        Colors = getColors(numel(Groups));
    elseif numel(Groups) <= 20
        Colors = jet(numel(Groups));
    else
        Colors = rand(numel(Groups), 3);
    end

end

for Indx_C = 1:numel(Groups)
    plot([1 1], [-100 -101], 'Color', Colors(Indx_C, :), 'LineWidth', PlotProps.Line.Width, 'HandleVisibility','on')
end

for Indx_B = 1:numel(Bursts)

    B = Bursts(Indx_B);

    Start = B.Start;
    End = B.End;



    Ch = B.Channel;
    if isfield(B, 'involved_ch')
        AllCh = B.involved_ch;
    elseif isfield(B, 'Coh_Burst_Channels')
        AllCh = B.Coh_Burst_Channels;
    else
        AllCh = [];
    end

    Ch(Ch>DimsD(1)) = [];

    if isempty(ColorCode)
        C  = Colors;
    else
        C = Colors(ismember(Groups, B.(ColorCode)), :); % get appropriate color, and make it slightly translucent
    end

    % plot all channels involved
    for Indx_Ch = 1:numel(AllCh)
        Ch2 = B.Coh_Burst_Channels(Indx_Ch);
        Start2 = B.Coh_Burst_Starts(Indx_Ch);
        End2 =  B.Coh_Burst_Ends(Indx_Ch);

        Burst = EEG.data(Ch2, Start2:End2)+Y(Ch2)';
        plot(t(Start2:End2), Burst', 'Color', C, 'LineWidth', PlotProps.Line.Width/3, 'HandleVisibility','off');
    end


    % plot main burst
    Burst = EEG.data(Ch, Start:End)+Y(Ch);
    plot(t(Start:End), Burst', 'Color', [C], 'LineWidth', PlotProps.Line.Width, 'HandleVisibility','off');
end


xlim(Bursts(1).Start/EEG.srate+[0 20])
legend(Groups,  'FontSize', PlotProps.Text.AxisSize)