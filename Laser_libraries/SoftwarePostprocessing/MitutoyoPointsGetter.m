function Points = MitutoyoPointsGetter(M,min,max)
    %Extracts the points with z in (min,max) of a surface M
    %Surfaces must be given as an Nx3 array, where each S(i,:) is a 3-dimensional
    %vector

    Points = M;
    n=0;
    for i = 1:size(M,1)
        if M(i,3)<max && M(i,3)>min
            n = n+1;
            Points(n,:)=M(i,:);
        end
    end
    Points = Points(1:n,:);
end

