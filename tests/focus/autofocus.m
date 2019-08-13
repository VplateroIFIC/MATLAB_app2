%% TESTING AUTOFOCUS ROUTINE %%

% declaring objects to talk to dtages and cameras %

gantry=STAGES;
cam=CAMERA;

% conecting to both devices %

gantry=gantry.connect;
cam=cam.Connect;

% enable all stages %

gantry.MotorEnableAll;


% display preview window %

cam.DispCam

%%%%%%%%%%% performing autofocus %%%%%%%%%%
tic

% Initial values %

zAxis=4;

R=0.2;   %Rango de enfoque
div=5;   %divisiones iniciales del rango
velocity=1.5;   %1.5 mm/s velocidad
Z0=gantry.GetPosition(zAxis);
disp('current Z position is %4.4',Z0);
threshold=0.02;
delta=R/v;
P0=Z0-R/2;
Pn=Z0+R/2;
s=320;   % size of the roi
imageTest=cam.OneFrame;
[n,m]=size(Image_test);
RoiSize=[s,s];
RoiCoordX=m/2-roiSize/2:m/2+roiSize/2;
RoiCoordY=n/2-roiSize/2:n/2+roiSize/2;
FocusType='LAPV';

% Performing global search %

zCont=1;
fCont=1;
Z=zeros(1,300);
FocusValue=zeros(1,300);
iterations=200;
Fopt=zeros(1,100);

for i=1:iterations
z=P0;
while (z<=Pn)
    % setting gantry at new position %
   gantry.MoveTo(zAxis,z,velocity);
   gantry.WaitForMotion(zAxis,-1);
   Z(zCont)=gantry.GetPosition(zAxis);
   zCont=zCont+1;
   % taking picture, appling ROI %
   image=cam.OneFrame;
   ROI=image(RoiCoordX,RoiCoordY);
   % Asking focus parameter %
   FocusValue(fCont)=fmeasure(ROI,FocusType);
   fCont=fCont+1;
   z=z+delta;
end

%  Finding local optimal %
Fopt(i)=max(FocusValue);
index=find(FocusValue==max(FocusValue));
Zopt=Z(index);
% defining new range %
newR=max([abs(Zopt-P0),abs(Zopt-Pn)]);
P0=Zopt-newR/2;
Pn=Zopt+newR/2;
delta=delta*newR/R;
if i>1 && abs(Fopt(i)-Fopt(i-1))<threshold
    break
end
end


% Fitting results to a quadratic polynomial %

X=Z;
Y=FocusValue;

p=polyfit(X,Y,2);
Zfinal=-p(2)/p(1);
gantry.MoveTo(zAxis,Zfinal,velocity);
gantry.WaitForMotion(zAxis,-1);

time=toc;

disp('focus optimal values is %4.4',Zfinal);
disp('total tima consumed is %4.4',time)







