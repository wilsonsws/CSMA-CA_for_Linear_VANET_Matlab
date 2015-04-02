%最大数据帧长
function y = MaxLength(PacketBuff,CollitionStations)
max=0;
for i = 1:CollitionStations(1)
    if PacketBuff(CollitionStations(i+1),2) > max
        max = PacketBuff(CollitionStations(i+1),2);
    end
end
y=max;
