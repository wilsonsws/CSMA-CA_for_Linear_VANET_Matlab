% A = 1.82 * 10^(-4)
clear all
maxCarNumber = 86;
minCarNumber = 10;
numberPace = 4;
roadLength = 2100;
effectiveRange = 300;
totalSecond = 1;
Threshold = 10^(-10);
maxBackoffTime = 100; % 最大退避时间
PhyRate = 2*10^6 ;           %物理层数据率 bit/s
SlotTime = 20*10^(-6);       %时隙间隔 s
TotalTime = totalSecond/SlotTime;    %观测总时隙个数
SIFS = 0.5;        %SIFS相当于0.5个时隙
DIFS = 2.5;        %DIFS相当于2.5个时隙 
ACK = 14*8/(PhyRate*SlotTime); %ACK 转化成时隙个数
AverageArrivalTime = 110;    %平均到达时间 slottime
% AveragePacketLength = 100;    %平均帧长
PacketLength = 1024; % 固定帧长 slottime 1024*8bit帧长 = 204.8 slottime 帧长
Buffer_Threshold = 8*10^6/(PhyRate*SlotTime);%缓存门限
sResult = zeros(1,((maxCarNumber-minCarNumber)/numberPace+1)); %记录结果用
maxInsNode = zeros(1,((maxCarNumber-minCarNumber)/numberPace+1));

for M = minCarNumber:numberPace:maxCarNumber %M工作站数目

ChannelBusy = 0;   %信道忙闲标志初始化
Throughput = 0;%吞吐量初始化
maxSimulNode = 0; %同时传输最大节点数
NormDis = 0; %范数差 中间量
% Start = 0; %有无数据开始发送标志
Collision = zeros(1,M); %有无冲突标志
DeferenceTime = zeros(1,M); %发送期
ArrivalTime = zeros(1,M );  %到达时间
%PacketLength = zeros(1,M) ; %帧长
HasPacket = zeros(1,M);%有无缓存标志
CW = zeros(1,M); %争用窗口
BackoffTimer = zeros(1,M); %回退时间
PacketBuff = zeros(M,1501);  %缓存器
% CollisionStations = zeros(1,M+1);    %冲突站记录
CurBufferSize = zeros(1,M);  %当前缓存器帧长
activeArray = zeros(M,1); % 已激活车辆节点情况
activeArraytemp = zeros(M,1);
%quarterHead = 1+M/4;
%quarterEnd = 3*M/4;

while 1
    carDistanceArray = carDistri(roadLength,M); % 跟车模型生成车辆分布
    if carDistanceArray(M+1) < roadLength
            break;
    end
    
    for kh = 2:M+1
        if (carDistanceArray(kh)-carDistanceArray(1)) > (roadLength/4)
            quarterHead = kh;
            break;
        end
    end
    for ke = M+1:-1:2
        if (carDistanceArray(ke)-carDistanceArray(1)) < (roadLength*3/4)
            quarterEnd = ke;
            break;
        end
    end
end
carInfmatrix = carInfmatrixGen(carDistanceArray,effectiveRange); % 车辆间干扰记录矩阵

for i = 1:M
    ArrivalTime(i) = ProPoisson(AverageArrivalTime); %初始化到达时间  
    % PacketLength(i) =ProPoisson(AveragePacketLength);%初始化分组长度
    CW(i) = 32; %初始化竞争窗口
    BackoffTimer(i) = maxBackoffTime; %初始化退避时间 1000 
end

for t = 1:TotalTime
    for i = 1:M
        if t == ArrivalTime(i)
            %目前不能发送，push分组进PackeBuff，修改退避计数器
            if CurBufferSize(i) < Buffer_Threshold - PacketLength
                PacketBuff = Push(PacketBuff,i,PacketLength);
                CurBufferSize(i) = CurBufferSize(i) + PacketLength;
                HasPacket(i) = 1;
                if BackoffTimer(i) == maxBackoffTime
                    BackoffTimer(i) = ReSet(CW(i));%退避计数器达到最大1000时，重置退避计数器
                end
            end
            %更新到达时间和帧长
            ArrivalTime(i) = ProPoisson(AverageArrivalTime) + PacketLength + t;
            % PacketLength(i) = ProPoisson(AveragePacketLength);
        end
    end

    for i = 1:M
        % ChannelBusy = channelStateJudge(carInfmatrix(i,:),activeArray,Threshold); % 干扰强度判决，CCA mode1
        if HasPacket(i) == 1 && channelStateJudge(carInfmatrix(i,:),activeArray,Threshold) == 0 %PackeBuff中有数据包发送并且信道空闲
            if BackoffTimer(i) == 0 %退避时间=0 -> 发送
                %%% CollisionStations = Add(CollisionStations,i);%加入冲突站点序列中
                % Start = 1;
                activeArraytemp(i) = 1;
                % disp('i');
            else
                BackoffTimer(i) = BackoffTimer(i) - 1;%退避时间!=0 -> 退避时间-1
            end
        end
    end   
    activeArray = activeArraytemp; % 更新处于激活状态的节点
    
    if norm(activeArray,2) ~= 0 %信道改为忙碌
        % ChannelBusy = 1;
        % n = CollisionStations(1);
        for i = 1:M
            if activeArray(i) == 1 && DeferenceTime(i) == 0
                collisionJudge = channelStateJudge(carInfmatrix(i,:),activeArray,Threshold); % 此处用于判断碰撞节点，当N个发射节点同时发射且导致相互间干扰大于门限时，视为碰撞
                if collisionJudge == 0 % 没有发生碰撞
                    DeferenceTime(i) = floor(t + SIFS + DIFS + ACK + PacketBuff(i,2));
                    %PacketBuff(CollitionStations(2),2)数据长度
                    %成功发送时间
                    Collision(i) = 0;%没有碰撞
                    % disp('ii');
                else
                    % DeferenceTime(CollisionStations(i)) = floor(t + DIFS + MaxLength(PacketBuff,CollisionStations));
                    DeferenceTime(i) = floor(t + DIFS + PacketBuff(i,2)); % 不再关注最长帧，对每个帧分别处理。可能不合理。
                    Collision(i) = 1;%发生碰撞
                end
            end
        end
        % Start=0;
    end
    
    for i = 1:M
        % if t == DeferenceTime(i) && norm(activeArray,2) ~= 0 
        if t == DeferenceTime(i) % 信道忙的时候达到站点的等待时间
            % disp('ttt');
            if Collision(i) == 0
                % n = CollisionStations(2);
                CurBufferSize(i) = CurBufferSize(i) - PacketBuff(i,2);
                Throughput = Throughput + PacketBuff(i,2)* SlotTime * PhyRate;
                % disp('iii');
                PacketBuff = Pop(PacketBuff,i);
                CW(i) = 32;
                k = PacketBuff(i,1);
                if k ==0 %如果没有数据等待发送，将HasPacket置0，BackoffTimer置Max
                    HasPacket(i) = 0;
                    BackoffTimer(i) = maxBackoffTime;
                else%还有数据分发送，修改碰撞计数器
                    BackoffTimer(i) = ReSet(CW(i));
                end    
            else
                %  n = CollisionStations(1);
                % for t = 1:n
                    % j = CollisionStations(t+1);
                CW(i) = Increase(CW,i);
                BackoffTimer(i) = ReSet(CW(i));
                % end    
            end
            % CollisionStations = zeros(1,M+1);
            DeferenceTime(i) = 0;
            activeArray(i) = 0;
            activeArraytemp(i) = 0;
            Collision(i) = 0;
        end
    end

    NormDis = norm(activeArray(quarterHead:quarterEnd),1) - norm(Collision(quarterHead:quarterEnd),1);
    if NormDis > maxSimulNode
        maxSimulNode = NormDis;
    end
    
end

% sResult(M-4) = Throughput/(TotalTime* SlotTime * PhyRate);%吞吐率
sResult((M-minCarNumber)/numberPace+1) = Throughput/(totalSecond * PhyRate);
maxInsNode((M-minCarNumber)/numberPace+1) = maxSimulNode;

end

xline = minCarNumber:numberPace:maxCarNumber;
%plot(xline,sResult,'b-o');%吞吐率与站点数目的关系
plot(xline,maxInsNode,'b-o')
hold on;
plot(xline,sResult,'r-o');
hold on;
xlabel('number of potential transmitters');
ylabel('Total Throughputs');
title('Relation between number of transmitters and throughput');
grid;
%save([num2str(floor(roadLength/1000)),'k',num2str(totalSecond),'s',num2str(maxCarNumber)],'sResult');