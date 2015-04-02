function ChannelBusy = channelStateJudge(vectorInf,vectorActive,threshold)
totalInf = vectorInf * vectorActive;
% totalInf
if totalInf >= threshold
    ChannelBusy = 1;
else
    ChannelBusy = 0;
end
end