clc
clear all

%%%% EXAMPLE HOW TO USE THE GANTRY WITH MATLAB USING NET ASSEMLY %%%%

%% LOADING THE LIBRARY %%

gantry = NET.addAssembly('F:\Gantry_code\Matlab_app\ACS.SPiiPlusNET.dll');
%methodsview('ACS.SPiiPlusNET.Api')

%% CONNECTING TO GANTRY %%

%generate pointer to the gantry %
Port = 701;
% Address="10.0.0.100";
Address=("10.0.0.100");

pGantry=ACS.SPiiPlusNET.Api;
OpenCommEthernetTCP(pGantry,Address,Port);



%% asking feedback position %%

%Asking current position X
xAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_0;
yAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_1;
zAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_4;


Xpos=GetFPosition(pGantry,xAxis);
Ypos=GetFPosition(pGantry,yAxis);
Zpos=GetFPosition(pGantry,zAxis);


%% TEST2: MOVING 100MM X, VELOCITY 5MM/S %%


Xena=1;
Yena=2;
Zena=3;

d1 = NET.createArray('ACS.SPiiPlusNET.Axis',3);
d1.Set(0,xAxis);
d1.Set(1,yAxis);
d1.Set(2,zAxis);

setVel=2;
goPoint=2;

% axis=[xAxis,yAxis,zAxis];

Enable(pGantry,xAxis);
Enable(pGantry,yAxis);
Enable(pGantry,zAxis);

% EnableM(pGantry,[1 1 0 0 1]);


%% moving %%
velocity=5;
delta=100;

SetVelocity(pGantry,xAxis,velocity);


flag=ACS.SPiiPlusNET.MotionFlags.ACSC_AMF_RELATIVE;
ToPoint(pGantry,flag,xAxis,delta);


%% DISABLE ALL AXES %%


DisableAll(pGantry);





