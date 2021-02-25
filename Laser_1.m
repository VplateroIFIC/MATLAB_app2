laser = OPTONCDT2300;
laser.SetupConnect;
laser.LoadParameters(1);

% Start measuring
laser.ClearBuffer
laser.AvailableValues
laser.GetConfiguration

    %Measure a grid of nX*nY points in the rectangle [x1,x2]*[y1,y2],
    
addpath (".\Laser_libraries\Measuring\Functions\");

fromX = -425.2216
fromY = 87.4868
toX = -273.5990
toY = 186.3398

nY = 10;
measuringVelocity = 5;
movingVelocity = 30;

nX = 100;
nY = 100;

function [Z,X,Y] = measureSensor(laser,gantry,StartPos,StopPos,nX,nY,velocity,minValue,maxValue)


%[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity)

Corner1 = [-425.2216   87.4868       NaN   91.6428 -100.2567         0];
Corner2 = [-273.5990  186.3398       NaN   91.6428 -100.2567         0];
velocity = 10;
maxValue = 10;
minValue = 5;

[Z,X,Y] = Laser_measure1(laser, gantry, Corner1, Corner2, velocity, maxValue, minValue);
%
return
gantry.Move2Fast(reposo)


%% Probando

fromX = corner1(1)
fromY = corner1(2)
toY = corner2(2)
toX = corner2(1)

%% Probando
nY = 10;
measuringVelocity = 2
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_10Lines_2mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')


%% Probando
nY = 10;
measuringVelocity = 5
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_10Lines_5mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

%% Probando
nY = 30;
measuringVelocity = 15
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_30Lines_15mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

%%
nY = 30;
measuringVelocity = 15
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_30Lines_15mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

%%
nY = 100;
measuringVelocity = 15
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_100Lines_15mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

%%
nY = 30;
measuringVelocity = 10
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_30Lines_10mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

%%
nY = 30;
measuringVelocity = 5
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Jig_30Lines_5mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

%%

laser.PowerOff
gantry.Move2Fast(reposo)
gantry.MotorDisableAll
