%% TESTING AUTOFOCUS ROUTINE %%

%% clearing all %%
% 
% clc
% clear all
% imaqreset;
% 
% %% declaring objects to talk to dtages and cameras %%
% nSite=2;  %Valencia
% gantry=STAGES(nSite);
% cam=CAMERA;
% 
% %% conecting to both devices %%
% 
% gantry=gantry.Connect;
% cam=cam.Connect;
% 
% %% enable all stages %%
% 
% gantry.MotorEnableAll;
% 
% 
% %% display preview window %%
% 
% cam.DispCam

%%%%%%%%%%% performing autofocus %%%%%%%%%%
 %% AUTOCOUS %%
clearvars -except keepVariables cam gantry nSite
 % Initial values %



cam.DispCam
zAxis=4;
Pini=gantry.GetPosition(zAxis);
Rini=0.4;   %Rango de enfoque
div=4;   %divisiones iniciales del rango
velocity=2;   %1.5 mm/s velocidad

R=Rini;
% Z0=gantry.GetPosition(zAxis);
Z0=Pini;
fprintf('initial Z position is %4.4f\n',Z0);
gantry.MoveTo(zAxis,Z0,velocity);
gantry.WaitForMotion(zAxis,-1);
fprintf(' Z position moved to %4.4f\n',Z0);
threshold=0.05;
delta=R/div;
P0=Z0-R/2;
Pn=Z0+R/2;
s=300;   % size of the roi
ImageTest=cam.OneFrame;
[n,m]=size(ImageTest);
RoiSize=[s,s];
RoiCoordX=m/2-RoiSize/2:m/2+RoiSize/2;
RoiCoordY=n/2-RoiSize/2:n/2+RoiSize/2;
FocusType='BREN';
% imageTest=cam.OneFrame;


%% Performing global search %%
 total=tic;
zCont=1;
fCont=1;
iterations=5;
Fopt=zeros(1,100);
ImCont=1;

% fprintf('initial P0 is %4.4f\n',P0);
% fprintf('initial Pn is %4.4f\n',Pn);
% fprintf('initial R is %4.4f\n',R);
% fprintf('initial delta is %4.4f\n',delta);

for i=1:iterations
FocusValue=zeros(1,20);   
Z=zeros(1,20);
z=P0;
for j=1:div+1
    % setting gantry at new position %
   GantryMov=tic;
   gantry.MoveTo(zAxis,z,velocity);
   gantry.WaitForMotion(zAxis,-1);
   Zref=gantry.GetPosition(zAxis);
   Z(zCont)=Zref;
   timeMov=toc(GantryMov);
   % taking picture, appling ROI %
   takeImage=tic;
   if (i==1 && j==1)
   image=cam.OneFrame;
   end
   image=cam.OneFrame;
   timeImage=toc(takeImage);
   
   ROI=image(RoiCoordX,RoiCoordY);
   imwrite(image,strcat('D:\Code\MATLAB_app\tests\focus\images\image_',num2str(ImCont),'_F_',num2str(Zref),'.jpg'));
   imwrite(ROI,strcat('D:\Code\MATLAB_app\tests\focus\images\imageROI_',num2str(ImCont),'.jpg'));
   ImCont=ImCont+1;
   % Asking focus parameter %
   Fvalue=tic;
   FocusValue(fCont)=fmeasure(ROI,FocusType);
   timeFvalue=toc(Fvalue);
   z=z+delta;
   fprintf('Time movement: %4.4f  Time image: %4.4f time focus: %4.4f  Z: %4.4f   Focus Value: %4.4f \n',timeMov,timeImage,timeFvalue,Z(zCont),FocusValue(fCont))
   fCont=fCont+1;
   zCont=zCont+1;
end



%  Finding local optimal %

Z(Z==0)=[];
FocusValue(FocusValue==0)=[];
focusAll{i}=FocusValue;
zAll{i}=Z;

Fopt(i)=max(FocusValue);
index=find(FocusValue==max(FocusValue));
Zopt(i)=Z(index);
fprintf('optimal focus was %4.4f\n',Fopt(i));
fprintf('optimal Z was %4.4f\n',Zopt(i));
% defining new range %

div=3;
newR=max([abs(Zopt(i)-P0),abs(Zopt(i)-Pn)]);
P0=Zopt(i)-newR/2;
Pn=Zopt(i)+newR/2;
delta=newR/div;
fprintf('new P0 is %4.4f\n',P0);
fprintf('new Pn is %4.4f\n',Pn);
fprintf('new R is %4.4f\n',newR);
fprintf('new delta is %4.4f\n',delta);


if i>1 && abs(Zopt(i)-Zopt(i-1))<threshold
    break
end
end

zAll=cell2mat(zAll);
FocusAll=cell2mat(focusAll);

% Fitting results to a quadratic polynomial %
% Z(Z==0)=[];
% FocusValue(FocusValue==0)=[];
X=Z;
Y=FocusValue;

p=polyfit(X,Y,2);
Zfinal=-(p(2)/(2*p(1)));

if (Zfinal>=Pini-Rini/2 || Zfinal<=Pini+Rini/2)
% Moving to Zfinal  %
gantry.MoveTo(zAxis,Zfinal,velocity);
gantry.WaitForMotion(zAxis,-1);
end
TotalTime=toc(total);

fprintf('Z optimal values is %2.4f\n',Zfinal)
fprintf('Number of iterations is %i\n',i)
fprintf('total number of measures is %i\n',length(FocusValue))
fprintf('total tima consumed is %4.4f\n',TotalTime)

%  plotting %
x=Pini-Rini:0.01:Pini+Rini;
y=p(1)*x.^2+p(2)*x+p(3);
figure,
plot(X,Y,'*');
hold on
plot(x,y)



%% disable all axes %%


% gantry.MotorDisableAll;
% 
% 
% %% disconnect camera and gantry %%
% 
% 
% gantry=gantry.Disconnect;
% cam.Disconnect;






