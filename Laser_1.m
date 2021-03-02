
load('Febrero_19.mat', 'tool2','jig1')
corner1 = tool2.corner1
corner2 = tool2.corner2

nLines = 200;
velocity = 60;

[tool1.X,tool1.Y,tool1.Z] = Laser_measure1(laser,gantry,tool1.corner1,tool1.corner2,nLines,velocity, 'tool1');

[tool2.X,tool2.Y,tool2.Z] = Laser_measure1(laser,gantry,tool2.corner1,tool2.corner2,nLines,velocity,'tool2');

gantry.Move2Fast(reposo)
laser.PowerOff
Close_Gantry
return




% Start measuring
laser.ClearBuffer
laser.AvailableValues
laser.GetConfiguration

laser.ClearBuffer
pause(0.1)
laser.PollData
line = 10.-laser.scaledData
% line = 10.-laser.scaledData

offTime = 0.066;
    Distance = abs(corner2(1)-corner1(1))
    points = ceil((Distance/Velocity+offTime)*laser.SP_Measrate*1000); %Points to measure = time spent * measuring frequency. Time spent = time while moving + offTime
    fprintf("You are going to measure %d points\n",points);
    %if points > laser.bufferValueSize 
    %%Cálculo estimado del tamaño del buffer: ¡incorrecto!
    %    warning("You are going to need a bigger buffer size: %d",ceil(points/4));
    %end
    laser.dataSize = points;
    distancePoints=linspace(0,Distance,points);
    laser.ClearBuffer;
    gantry.MoveTo(gantry.X,corner1(1),Velocity,0);                  %Move the gantry to the final possition.
%     gantry.MoveTo(gantry.Y,toY,measuringVelocity,0); 
    gantry.WaitForMotionAll(-1);
    laser.PollData;
    line = 10.-laser.scaledData                  

%Measure a grid of nX*nY points in the rectangle [x1,x2]*[y1,y2],
    

fromX = -425.2216
fromY = 87.4868
toX = -273.5990
toY = 186.3398

nY = 10;
measuringVelocity = 5;
movingVelocity = 30;

nX = 100;
nY = 100;

[Z,X,Y] = measureSensor(laser,gantry,StartPos,StopPos,nX,nY,velocity,minValue,maxValue)


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
laser.PowerOff









%% Probando

fromX = corner1(1)
fromY = corner1(2)
toY = corner2(2)
toX = corner2(1)

%% Probando
nY = 5;
measuringVelocity = 60
movingVelocity = measuringVelocity+20;
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Tool1_5Lines_15mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')


%% Probando
nY = 50;
measuringVelocity = 15
gantry.Move2Fast(corner1)
tic;
[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity);
measuringTime = toc
save ('./Laser_libraries/Tool1_50Lines_15mmseg.mat', 'X','Y','Z', 'measuringVelocity','nY','measuringTime')

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

%% Reduce by points density
dX = 10;                % points/mm
L = abs(X(1)-X(end));   %Lenght of the measured lines
step = round(L/dX,2);
Xr = X(1:step:end);
Zr = Z(:,1:step:end);
surf(Xr,Y,Zr)

%% Reduce by number of points per line
nX = 200;                % points/line
L = abs(X(1)-X(end));    %Lenght of the measured lines
step = round(size(X,2)/nX);
Xr = X(1:step:end);
Zr = Z(:,1:step:end);
surf(Xr,Y,Zr)

%% Filter 3-d
Z_med3 = medfilt3(Z, [5,5,5]);
%% Filter 2-d [5 points around]
Z_med2 = medfilt2(Z, [5,5]);   

%save('pqfile.csv','Xr','-ascii')

laser.PowerOff
gantry.Move2Fast(reposo)
gantry.MotorDisableAll
