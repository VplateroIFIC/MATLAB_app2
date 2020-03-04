% this scrip compute the distances of all the nominal position of the sensor fiducials 
% to the petal fiducial in the bottom when the petal is side 1 and side 2. In theory, the 
% distance should be the same for both cases

for side=1:2
sideLabel=['side',num2str(side)];
petal.(sideLabel)=PETALCS(side);

sensors=petal.(sideLabel).sensorLabel;
n=length(sensors);

origin.(sideLabel)=petal.(sideLabel).upper_petalFid;
cont=1;
for i=1:n
fiducialsPetal=petal.(sideLabel).fiducials_gantry.(sensors{i});
for j=1:length(fiducialsPetal) 
curretFiducial=fiducialsPetal{j};  
dist.(sideLabel)(cont)=sqrt((origin.(sideLabel)(1)-curretFiducial(1))^2+(origin.(sideLabel)(2)-curretFiducial(2))^2);
cont=cont+1;
end
end
end

dist.side1-dist.side2