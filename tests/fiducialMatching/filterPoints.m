
function [DistanciaCentroideN,DistanciaSimNX,DistanciaSimNY]=filterPoints(keypoints)
% funcion para filtrado extra de matches

N=length(keypoints);
for i=1:N
    keypointsMat(i,1)=keypoints{i}(1);
    keypointsMat(i,2)=keypoints{i}(2);
end

centroideX=mean(keypointsMat(:,1)); centroideY=mean(keypointsMat(:,2));
KeypointsTransformed(:,1)=keypointsMat(:,1)-centroideX;
KeypointsTransformed(:,2)=keypointsMat(:,2)-centroideY;

DistanciaCentroide=sqrt(KeypointsTransformed(:,1).^2+KeypointsTransformed(:,2).^2); 
maxDistancia=max(DistanciaCentroide);
DistanciaCentroideN = DistanciaCentroide/maxDistancia; % normalizo con la máxima distancia (modular) al centroide

for j=1:length(keypoints)
    x=KeypointsTransformed(j,1);
    y=KeypointsTransformed(j,2);
    xSim=-KeypointsTransformed(j,1);
    ySim=-KeypointsTransformed(j,2);
    
    
    P=[x,y];
    PSim=[xSim,ySim];
    
    DistanciaSimNX(j)=sqrt((PSim(1)-P(1))^2)/maxDistancia;
    DistanciaSimNY(j)=sqrt((PSim(2)-P(2))^2)/maxDistancia;
end

end