
function y = Add(CollisionStations,index)
CollisionStations(1) = CollisionStations(1) + 1;%CollisionStations(1)指示发送站点的个数
i = CollisionStations(1);
CollisionStations(i+1) = index;
y = CollisionStations;
