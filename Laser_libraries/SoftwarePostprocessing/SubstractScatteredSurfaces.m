function [surfDiference] = SubstractScatteredSurfaces(S1,S2)
%Fits S1 to S2 points and gives S2-S1;
%Surfaces must be given as an Nx3 array, where each S(i,:) is a 3-dimensional
%vector

V = griddata(S1(:,1),S1(:,2),S1(:,3),S2(:,1),S2(:,2),'v4');
surfDiference = [S2(:,1),S2(:,2),S2(:,3)-V];

end