% 跟车模型中，车辆间距X符合对数正态分布

function carDistanceCumulate = carDistri(roadlength,carnumber)
averageCarDistance = floor(roadlength/carnumber); %平均车距
Miu = log(averageCarDistance) - 0.5; % 平均车距 E = exp(Miu + sigma^2/2) so....
carDistanceArrayTemp = lognrnd(Miu,1,1,carnumber);
carDistanceCumulate = zeros(1,carnumber + 1);

for i = 1:carnumber
    carDistanceCumulate(i+1) = carDistanceCumulate(i) + carDistanceArrayTemp(i);
end

end

    


