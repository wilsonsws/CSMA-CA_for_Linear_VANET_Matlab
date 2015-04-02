% this file is used to calculate interference between cars
%
function carInfmat = carInfmatrixGen(carDistriArray,effectiveRange)
row_number = length(carDistriArray) - 1;
carInfmat = zeros(row_number,row_number);
eps = 10^(-11);
for row = 1:row_number
    for col = 1:row_number
        distance = abs(carDistriArray(col+1) - carDistriArray(row+1));
        if (distance < eps) || (distance > effectiveRange)
            continue;
        else
            carInfmat(row,col) = 1.82 * 10^(-4)/(distance^2);
        end
    end
end

end
        


