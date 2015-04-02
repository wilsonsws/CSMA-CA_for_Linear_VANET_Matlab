clear all
maxCarNumber = 20;
minCarNumber = 5;
sResult = zeros(1,maxCarNumber - minCarNumber + 1); %记录结果用

for M = minCarNumber:maxCarNumber %M工作站数目
ChannelBusy = 0;   %信道忙闲标志
Start = 0; %有无数据开始发送标志
Collision = 0;%有无冲突标志
DeferenceTime = 0; %发送期
Throughput = 0;%吞吐量
ArrivalTime = zeros(1,M );  %到达时间
PacketLength = zeros(1,M) ; %帧长
HasPacket = zeros(1,M);%有无缓存标志
CW = zeros(1,M);%争用窗口
BackoffTimer = zeros(1,M);%回退时间
PacketBuff = zeros(M,1501);  %缓存器
CollisionStations = zeros(1,M+1);    %冲突站记录
PhyRate = 2*10^6 ;           %物理层数据率
SlotTime = 20*10^(-6);       %时隙间隔
TotalTime = 2/SlotTime;    %观测总时隙个数
SIFS = 0.5;        %SIFS相当于0.5个时隙
DIFS = 2.5;        %DIFS相当于2.5个时隙 
ACK = 14*8/(PhyRate*SlotTime); %ACK 转化成时隙个数
AverageArrivalTime = 110;    %平均到达时间
AveragePacketLength = 50;    %平均帧长
CurBufferSize = zeros(1,M);  %当前缓存器帧长
Buffer_Threshold = 8*10^6/(PhyRate*SlotTime);%缓存门限
%activeArray = zeros(1,M);

%carDistanceArray = cardistri(roadLength,M);
%arInfmatrix(carDistanceArray);

for i = 1:M
    ArrivalTime(i) = ProPoisson(AverageArrivalTime); %初始化到达时间  
    PacketLength(i) =ProPoisson(AveragePacketLength);%初始化分组长度
    CW(i) = 32; %初始化竞争窗口
    BackoffTimer(i) = 1000; %初始化退避时间 1000 
end

for t = 1:TotalTime
    for i = 1:M
        if t == ArrivalTime(i)
            %目前不能发送，push分组进PackeBuff，修改退避计数器
            if CurBufferSize(i) < Buffer_Threshold - PacketLength(i)
                PacketBuff = Push(PacketBuff,i,PacketLength(i));
                CurBufferSize(i) = CurBufferSize(i) + PacketLength(i);
                HasPacket(i) = 1;
                if BackoffTimer(i) == 1000
                    BackoffTimer(i) = ReSet(CW(i));%退避计数器达到最大1000时，重置退避计数器
                end
            end
            %更新到达时间和帧长
            ArrivalTime(i) = ProPoisson(AverageArrivalTime) + PacketLength(i) + t;
            PacketLength(i) = ProPoisson(AveragePacketLength);
        end
    end

    for i = 1:M
        if HasPacket(i) == 1 && ChannelBusy == 0 %PackeBuff中有数据包发送并且信道空闲
            if BackoffTimer(i) == 0 %退避时间=0 -> 发送
                CollisionStations = Add(CollisionStations,i);%加入冲突站点序列中
                Start = 1;
                %activeArray(i) = 1;
            else
                BackoffTimer(i) = BackoffTimer(i) - 1;%退避时间!=0 -> 退避时间-1
            end
        end
    end
    
    if Start == 1%信道改为忙碌
        ChannelBusy = 1;
        n = CollisionStations(1);
        
        if n == 1%信道中只有一个站点发送数据则为正常发送情况
            DeferenceTime = floor(t + SIFS + DIFS + ACK + PacketBuff(CollisionStations(2),2));
            %PacketBuff(CollitionStations(2),2)数据长度
            %成功发送时间
            Collision=0;%没有碰撞
        else
            DeferenceTime = floor(t + DIFS + MaxLength(PacketBuff,CollisionStations));
            Collision=1;%发生碰撞
        end
        Start=0;        
    end
    
    if t == DeferenceTime && ChannelBusy == 1%信道忙的时候达到站点的等待时间
        if Collision == 0
            n = CollisionStations(2);
            CurBufferSize(n) = CurBufferSize(n) - PacketBuff(n,2);
            Throughput = Throughput + PacketBuff(n,2)* SlotTime * PhyRate;
            PacketBuff = Pop(PacketBuff,n);
            CW(n) = 32;
            k = PacketBuff(n,1);
            if k ==0%如果没有数据等待发送，将HasPacket置0，BackoffTimer置Max
                HasPacket(n) = 0;
                BackoffTimer(n) = 1000;
            else%还有数据分发送，修改碰撞计数器
                BackoffTimer(n) = ReSet(CW(n));
            end    
        else
            n = CollisionStations(1);
            for i = 1:n
                j = CollisionStations(i+1);
                CW(j) = Increase(CW,j);
                BackoffTimer(j) = ReSet(CW(j));
            end    
        end
        CollisionStations = zeros(1,M+1);
        DeferenceTime = 0;
        ChannelBusy = 0;
        Collition = 0;
    end
end
sResult(M-4) = Throughput/(TotalTime* SlotTime * PhyRate);%吞吐率
end

xline = minCarNumber:1:maxCarNumber;
plot(xline,sResult,'b-o');%吞吐率与站点数目的关系
hold on;
xlabel('工作站数目(个)');
ylabel('吞吐率');
title('工作站数目和吞吐率的关系');
grid;