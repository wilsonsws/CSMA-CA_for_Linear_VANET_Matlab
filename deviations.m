clear all
%load('2k3s60sResult1');
fnlSet = 0;
for i = 1:4
    load(['2k3s60sResult',num2str(i)]);
    fnlSet = fnlSet + sResult;
end

fnlSet = fnlSet/4;
stanDeviation = 0;
for i = 1:4
    load(['2k3s60sResult',num2str(i)]);
    stanDeviation = (sResult - fnlSet).^2 + stanDeviation;
end
stanDeviation = (stanDeviation/4).^(1/2);

avgeStanDev = 0;
for j = 1:27
    avgeStanDev = stanDeviation(j) + avgeStanDev;
end
avgeStanDev = avgeStanDev/27;

