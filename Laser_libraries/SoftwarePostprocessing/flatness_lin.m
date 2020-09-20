%% SOLUTION TO THE FLATNESS PROBLEM BY USING LINEARIZED OPTIMIZATION ALGORITHM %%
%% input matrix M:
% column 1: X coordenates
% column 2 : Y coordinates
% column 3 : Z coordinates
% Verification of form tolerances Part I: Basic issues, flatness,
% and straightness (Kirsten Carr* and Placid Ferreira)

function flatness=flatness_lin(M)

X=M(:,1);
Y=M(:,2);
Z=M(:,3);

N=length(X);

U=1/sqrt(3)*ones(3,1);
T_0=[0 0 1]';

G =[ dot(T_0,U) -norm(cross(T_0,U)) 0;
    norm(cross(T_0,U)) dot(T_0,U)  0;
    0              0           1];

Fi =[ T_0 (U-dot(T_0,U)*T_0)/norm(U-dot(T_0,U)*T_0) cross(U,T_0) ];

S =Fi*G*inv(Fi);

comp=S*T_0;


sign=0;
error=0.000001;
dis_0=(T_0(1)*X+T_0(2)*Y+T_0(3)*Z)/sqrt(T_0(1)^2+T_0(2)^2+T_0(3)^2);

d_0=max(dis_0)-min(dis_0);

while sign==0
    
    A=[(-S*M')' ones(N,1) zeros(N,1);
        (S*M')' zeros(N,1) -ones(N,1);
        -1 -1 -1 0 0];
    
    b=[zeros(2*N,1);
        -1];
    
    lb=[0; 0;0; 0; []; []];
    f=[0; 0; 0; -1; 1];
    
    x = linprog(f,A,b,[],[],lb);
    
    T_p=[x(1) x(2) x(3)];
    
    T=S^-1*T_p'/norm(T_p);
    
    dis=(T(1)*X+T(2)*Y+T(3)*Z)/sqrt(T(1)^2+T(2)^2+T(3)^2);
    
    d=max(dis)-min(dis);
    
    e=abs(d-d_0);
    d_0=d;
    if e<error
        
        sign=1;
    end
    
    
    clearvars A b x T_p d S G Fi S
    
    G =[ dot(T,U) -norm(cross(T,U)) 0;
        norm(cross(T,U)) dot(T,U)  0;
        0              0           1];
    
    Fi =[ T (U-dot(T,U)*T)/norm(U-dot(T,U)*T) cross(U,T) ];
    
    S =Fi*G*inv(Fi);
    
end

flatness=d_0;


end


