function carDistanceCumulate = carUniform(roadLength,carNumber)
paceLength = floor(roadLength/(carNumber-1));
carDistanceCumulate = zeros(1,carNumber + 1);
carDistanceCumulate(1) = -paceLength;
for i = 1:carNumber
    carDistanceCumulate(i+1) = carDistanceCumulate(i) + paceLength;
end

end

