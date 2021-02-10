function [Z,X,Y] = measureSensorByYLines(laser,gantry,x1,x2,y1,y2,nX,velocity)
%MEASURESENSORBYLINES Summary of this function goes here
%   Detailed explanation goes here

    X = linspace(x1,x2,nX);                             % X coordinates of the points to measure
    distance = abs(y2-y1);                              % Distance to travel
    pointsPerLine = ceil(distance/velocity*laser.SP_Measrate*1000);
    Y = linspace(y1,y2,pointsPerLine);
    Z = zeros(pointsPerLine,nX);
    
    for i = 1:nX                                        %For each X position
        gantry.MoveTo(gantry.X,X(i),velocity,1);
        line=measureLine(laser,gantry,X(i),y2,X(i),y1,velocity);
        Z(:,i) = line(1:pointsPerLine);
    end 
    
    save("C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\Results\sensorMeasuringByYLineResults.mat",... %Store it in a file
        'X','Y','Z'); 

end

