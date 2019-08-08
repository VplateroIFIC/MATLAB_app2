%% TESTING/DEBUGGING ALIO CLASS %%

clc
clear all

%% ADDING THE LIB TO THE PATH, CREATING OBJECT %%

addpath('D:\Code\MATLAB_app\ALIO.m');
ASCS=ALIO; %OBJETO ascs
 %methodsview('ACS.SPiiPlusNET.Api'); % sacar por pantalla la información de los métodos

%% TEST:1 PRUEBA CONEXIÓN %%

Connect(ASCS); %%connecting
ASCS.gantry



%% TEST 2: PRUEBA ENABLE/DISABLE AXES %%

xAxis=2;
yAxis=0;
z1Axis=3;
uAxis=4;

ASCS.MotionEnable(ASCS,xAxis)
disp('x axis enabled')

ASCS.MotionDisable(ASCS,xAxis)
disp('x axis disabled')


%% enable all motors %%

ASCS.MotionEnable(ASCS,xAxis)
ASCS.MotionEnable(ASCS,yAxis)
ASCS.MotionEnable(ASCS,z1Axis)
ASCS.MotionEnable(ASCS,uAxis)

%% Disable all motors %%

ASCS.MotionDisable(ASCS,xAxis)
ASCS.MotionDisable(ASCS,yAxis)
ASCS.MotionDisable(ASCS,z1Axis)
ASCS.MotionDisable(ASCS,uAxis)

%% TEST 3: PRUEBA HOME + wait until movement is done%%

xpos=StatusGetItem(ASCS,xAxis,1,0);
disp('X pos before homing is');
disp(xpos);

MotionAdvancedHomeAsync(ASCS,0,xAxis);
MotionWaitForMotionDone(ASCS,xAxis,0,-1);

xpos=StatusGetItem(ASCS,xAxis,1,0);
disp('X pos after homing is');
disp(xpos);

%% TEST 4: MOVIMIENTO RELATIVO %%

delta=-100;
velocity=15;

xpos=StatusGetItem(ASCS,xAxis,1,0);
disp('x pos before relative movement is');
disp(xpos);

MotionMoveInc(ASCS,0,xAxis,delta,velocity);
MotionWaitForMotionDone(ASCS,xAxis,0,-1);

xpos=StatusGetItem(ASCS,xAxis,1,0);
disp('x pos after relative movement is');
disp(xpos);


%% TEST 5: ABOTAR MOVIMIENTO %%
time=2;

MotionAdvancedHomeAsync(ASCS,0,xAxis);
pause(2)

MotionAbort(ASCS,xAxis);




%% TEST 6: DESCONECTAR GANTRY %%

Disconnect(ASCS); %%disconnecting
ASCS.gantry







