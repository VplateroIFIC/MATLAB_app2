function [G,I,pointsFromCOM] = InertiaTensorAndCOM(points)
    %Obtains the COM, the inertia matrix (referred to the coordinate axes)
    %and the surface centered at the COM from surface points.
    %Surfaces must be given as an Nx3 array, where each S(i,:) is a 3-dimensional
    %vector

    I=zeros(3);
    n=size(points,1);
    G=zeros(1,3);

    for i=1:n
        for j=1:3
            G(j)=G(j)+points(i,j);
        end
    end
    for j=1:3
        G(j)=G(j)/n;
    end
    
    pointsFromCOM = points-G;

    for i=1:n
        for l=1:3
            for k=1:3
                I(l,k)=I(l,k)+(pointsFromCOM(i,l))*(pointsFromCOM(i,k));
            end
        end
    end 
end