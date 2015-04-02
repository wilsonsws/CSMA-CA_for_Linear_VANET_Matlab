clear all
load('2k3s60sResult1')
fstSet = sResult;
load('2k3s60sResult3');
secSet = sResult;
load('2k3s60sResult2');
TriSet = sResult;
load('2k3s60sResult4');
ThrSet = sResult;
%load('2k3s60sResult5');
%FifSet = sResult;
roadLength = 2000;
totalSecond = 3;
PhyRate = 2*10^6;
maxCarNumber = 60;
minCarNumber = 8;
numberPace = 2;
%upperBound = (4.8*10^7/(roadLength*totalSecond)) * ones(1,length(fstSet));
upperBoundF = 4.68*10^7/(roadLength*totalSecond*PhyRate/1000) * ones(1,length(secSet));
upperBoundC = 6.2896*10^7/(roadLength*totalSecond*PhyRate/1000) * ones(1,length(secSet));
fnlSet = zeros(1,length(secSet));

xline = minCarNumber:numberPace:maxCarNumber;
xlinelabel = floor(roadLength./xline);
%fnlSet = (fstSet + secSet + TriSet)/(3*roadLength*totalSecond);
%fnlSet = (TriSet + secSet + fstSet + ThrSet)/4;

for i = 1:((maxCarNumber-minCarNumber)/numberPace + 1)
    fnlSet(i) = max([fstSet(i),secSet(i),TriSet(i),ThrSet(i)]); % total Througthput
end
%}
%fnlSet = fnlSet/(roadLength*totalSecond); % Transmission Capacity
fnlSet = fnlSet/(roadLength*totalSecond*PhyRate/1000); %Density
plot(xline,fnlSet,'b-o');%吞吐率与站点数目的关系
hold on;
plot(xline,upperBoundF,'m-x');
hold on;
plot(xline,upperBoundC,'r-^');
hold on;
set(gca,'xticklabel',xlinelabel);
xlim([minCarNumber,maxCarNumber]);
ylim([0,7]); %Density
%ylim([4000,12000]);
%ylim([1*10^7,6*10^7]); % totalThroughput
xlabel('Average Distance Between Vehicles (m)');
ylabel('Average Density of Simultaneous Transmitters (1/km)');
% title('Relation  and throughput');
legend('Average Density of Simultaneous Transmitters','Proposed Upper Bound in [10]','Theoretical Upper Bound',3);
grid;