function Points = SensorPointsGetter(X,Y,Z,min,max)
    %Extracts the points with z in (min,max) of a surface given in grid
    %format, this is X as a 1xn vector, Y as a 1xm vector and Z as a nxm
    %matrix with Z(i,j) as the z coordinate of the point of x=X(i), y=Y(j)

    Points = zeros(size(Z,1)*size(Z,2),3);
    n=0;
    for i = 1:size(Z,1)
        for j = 1:size(Z,2)
            if Z(i,j)<max && Z(i,j)>min
                n=n+1;
                Points(n,1)=X(j);
                Points(n,2)=Y(i);
                Points(n,3)=Z(i,j);
            end
        end
    end
    Points=Points(1:n,:);
end