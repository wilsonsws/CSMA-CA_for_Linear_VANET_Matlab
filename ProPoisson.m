%泊松数据源
%
%到达帧数量符合泊松过程，即在时间间隔t内，有k个帧到达的概率为((lambda*t)^k * exp(-lambda*t))/k!
%由泊松过程性质，两个相邻帧之间到达时间的间隔服从指数分布，即间隔时间为y的概率为A = 1-exp(-lambda*t)
%A表示最终的概率，所以归一化为0-1
%注意平均间隔是指数分布的期望，即1/lambda = a
%
function y = ProPoisson(a)
y=0;
while y == 0
    A = rand(1);%（0,1）的随机数
    y = floor((-a) * log(1-A));
end