%% SOLUTION TO THE FLATNESS PROBLEM BY CONVEX HULL ALGORITHM %%
%% input matrix M:
% column 1: X coordenates
% column 2 : Y coordinates
% column 3 : Z coordinates
%Robust Convex Hull-based Algoritm for Straightness and Flatness
%Determination in Coordinate Measuring (Gyula Hermann)

function flatness=flatness_conhull(M)

X=M(:,1);
Y=M(:,2);
Z=M(:,3);

dt = delaunayTriangulation(M);
[ch v] = convexHull(dt);
% trisurf(ch, dt.Points(:,1),dt.Points(:,2),dt.Points(:,3), 'FaceColor', 'cyan')

N=length(ch);
min_dis=0.5;

for i=1:N
    
    P1=[X(ch(i,1)) Y(ch(i,1)) Z(ch(i,1))];
    P2=[X(ch(i,2)) Y(ch(i,2)) Z(ch(i,2))];
    P3=[X(ch(i,3)) Y(ch(i,3)) Z(ch(i,3))];
    
    Normal=cross(P1-P2,P1-P3);
    
    D=-Normal(1)*P3(1)-Normal(2)*P3(2)-Normal(3)*P3(3);
    
    plano_0=[Normal(1) Normal(2) Normal(3) D];
    plano=plano_0/norm(plano_0);
    
    dis=abs(plano(1)*X(:)+plano(2)*Y(:)+plano(3)*Z(:)+plano(4))/sqrt(plano(1)^2+plano(2)^2+plano(3)^2);
    
    max_dis_local(i)=max(dis);
    
    planos(i,:)=plano(:);
    
    clearvars plano D P1 P2 P3 dis Q v
    
end

flatness=min(max_dis_local);
plano_opt=planos(find(max_dis_local==flatness),:);

A=plano_opt(1);
B=plano_opt(2);
C=plano_opt(3);
D=plano_opt(4);
color='b';
alpha=0.5;
len=600;

% hold on
% draw_plane(A, B, C, D, color, alpha, len)

end
