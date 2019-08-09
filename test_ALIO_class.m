%% TESTING/DEBUGGING ALIO CLASS %%

clc
clear all

%% ADDING THE LIB TO THE PATH, CREATING OBJECT %%

% addpath('D:\Code\MATLAB_app\STAGES');
ASCS=STAGES(2); %OBJETO ascs
 %methodsview('ACS.SPiiPlusNET.Api'); % sacar por pantalla la información de los métodos

%% TEST:1 PRUEBA CONEXIÓN %%

ASCS=Connect(ASCS); %%connecting
% ASCS.gantry


%% test:1 B PRUEBA DESCONEXION %%

Disconnect(ASCS); %%disconnecting


%% TEST 2: PRUEBA ENABLE/DISABLE AXES %%

xAxis=0;
yAxis=1;
z1Axis=4;
z2Axis=5;
uAxis=6;

MotorEnable(ASCS,xAxis)
disp('x axis enabled')

MotorEnable(ASCS,xAxis)
disp('x axis disabled')


%% enable all motors %%

MotorEnable(ASCS,xAxis)
MotorEnable(ASCS,yAxis)
MotorEnable(ASCS,z1Axis)
MotorEnable(ASCS,uAxis)

%% Disable all motors %%

MotorDisable(ASCS,xAxis)
MotorDisable(ASCS,yAxis)
MotorDisable(ASCS,z1Axis)
MotorDisable(ASCS,uAxis)

%% TEST 3: PRUEBA HOME + wait until movement is done%%

xpos=GetPosition(ASCS,xAxis);
disp('X pos before homing is');
disp(xpos);

Home(ASCS,xAxis);
WaitForMotion(ASCS,xAxis,-1);

xpos=GetPosition(ASCS,xAxis);
disp('X pos after homing is');
disp(xpos);

%% TEST 4: MOVIMIENTO RELATIVO %%

delta=-100;
velocity=15;

xpos=GetPosition(ASCS,xAxis);
disp('x pos before relative movement is');
disp(xpos);

MoveBy(ASCS,xAxis,delta,velocity);
WaitForMotion(ASCS,xAxis,-1);

xpos=GetPosition(ASCS,xAxis);
disp('x pos after relative movement is');
disp(xpos);


%% TEST 5: ABOTAR MOVIMIENTO %%
time=2;

MotionAdvancedHomeAsync(ASCS,0,xAxis);
pause(2)

MotionAbort(ASCS,xAxis);




%% TEST 6: DESCONECTAR GANTRY %%

ASCSDisconnect(ASCS); %%disconnecting
ASCS.gantry







