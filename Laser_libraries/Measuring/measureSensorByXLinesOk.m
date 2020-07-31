function [Z,X,Y] = measureSensorByXLinesOk(laser,gantry,x1,x2,y1,y2,nY,measuringVelocity,movingVelocity)
%MEASURESENSORBYLINES Summary of this function goes here
%   Detailed explanation goes here
    
    laser.LoadParameters(1);

    Y = linspace(y1,y2,nY);                             % X coordinates of the points to measure
    distance = abs(x2-x1);                              % Distance to travel
    pointsPerLine = ceil(distance/measuringVelocity*laser.SP_Measrate*1000);
    X = linspace(x1,x2,pointsPerLine);
    Z = zeros(nY,pointsPerLine);
    
    for i = 1:nY                                        %For each X position
        gantry.MoveTo(gantry.Y,Y(i),movingVelocity,1);
        line=measureLineOK(laser,gantry,x1,Y(i),x2,Y(i),measuringVelocity,movingVelocity);
        Z(i,:) = line(1:pointsPerLine);
    end 
    
    save("C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\Results\sensorMeasuringByXLineResults.mat",... %Store it in a file
        'X','Y','Z'); 

end