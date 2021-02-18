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
measuringVelocity;
movingVelocity;

[Z,X,Y] = measureSensorByXLinesOk(laser,gantry,fromX,toX,fromY,toY,nY,measuringVelocity,movingVelocity)

gantry.Move2Fast(reposo)