function mileage = GetMileAgeOfTracklet(pos)
    %pos = [[2,3];[4,5];[6,9];];
    len = length(pos);
    if(len >= 3)
        mileage = sum((pos(2:len,1)-pos(1:len-1,1)).^2+...
                  (pos(2:len,2)-pos(1:len-1,2)).^2);
    else
        mileage = 0;
    end
end