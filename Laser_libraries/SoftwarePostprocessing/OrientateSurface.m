function [orientedPoints] = OrientateSurface(points)
    %Orientates the surface points so that its principal axes of inertia
    %become the coordinate axes.
    %Surfaces must be given as an Nx3 array, where each S(i,:) is a 3-dimensional
    %vector

[~,I,pointsFromCOM] = InertiaTensorAndCOM(points);
[V,~] = eig(I);
V = sortrows(V','descend')';
orientedPoints = pointsFromCOM*V;

end

