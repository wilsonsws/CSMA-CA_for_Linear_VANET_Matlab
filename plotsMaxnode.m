clear all
load('2k3s60maxnode1');
fnlSet = maxInsNode;
for i = 2:4
    load(['2k1s60maxnode',num2str(i)]);
    fnlSet = fnlSet + maxInsNode;
end
%{
load('2k1s60maxnode1')
fstSet = maxInsNode;
load('2k1s60maxnode3');
secSet = maxInsNode;
load('2k1s60maxnode2');
TriSet = maxInsNode;
load('2k1s60maxnode4');
ThrSet = maxInsNode;
load('2k1s60maxnode5');
FifSet = maxInsNode;
%}
roadLength = 2000;
totalSecond = 3;
PhyRate = 2*10^6;
maxCarNumber = 60;
minCarNumber = 8;
numberPace = 2;

upperBoundF = 4.68*10^7/(roadLength*totalSecond) * ones(1,length(fnlSet));
upperBoundC = 7.2*10^7/(roadLength*totalSecond) * ones(1,length(fnlSet));
%upperBoundF = 4.68*10^7/(roadLength*totalSecond*PhyRate/1000) * ones(1,length(fnlSet));
%upperBoundC = 7.2*10^7/(roadLength*totalSecond*PhyRate/1000) * ones(1,length(fnlSet));
%fnlSet = zeros(1,length(secSet));

xline = minCarNumber:numberPace:maxCarNumber;
xlinelabel = floor(roadLength./xline);
fnlSet = PhyRate*fnlSet/(4*roadLength); % TC
%fnlSet = ceil(fnlSet/(4*roadLength/1000));

plot(xline,fnlSet,'b-o');%吞吐率与站点数目的关系
hold on;
plot(xline,upperBoundF,'m-x');
hold on;
plot(xline,upperBoundC,'r-^');
hold on;
set(gca,'xticklabel',xlinelabel);
xlim([minCarNumber maxCarNumber]);
%ylim([0,7]); %Density
ylim([4500,13000]);
%ylim([1*10^7,6*10^7]); % totalThroughput
xlabel('Average Distance Between Vehicles (m)');
ylabel('Maximal Instantaneous Transmission Capacity (bps/m)');
% title('Relation  and throughput');
legend('Maximal Instantaneous Transmission Capacity','Proposed Upper Bound in [10]','Theoretical Upper Bound',3);
grid;