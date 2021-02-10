function P = GetRidOfNoise(points,ZTopTolerance,ZBottomTolerance)
    %Outputs a surface with just the points such that ZBottomTolerance<z<ZTopTolerance
    %Surfaces must be given as an Nx3 array, where each S(i,:) is a 3-dimensional
    %vector
    
    P = points(points(:,3)<ZTopTolerance&points(:,3)>ZBottomTolerance,:,:);

end

