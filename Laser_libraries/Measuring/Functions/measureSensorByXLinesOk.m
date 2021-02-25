function [Z,X,Y] = measureSensorByXLinesOk(laser,gantry,x1,x2,y1,y2,nY,measuringVelocity,movingVelocity)
%Measures the square [x1,x2]x[y1,y2] by nY lines parallel to the x axis, at
%speed (velocity).
%At low speed it works well
    
    laser.LoadParameters(1);

    Y = linspace(y1,y2,nY);                             % X coordinates of the points to measure
    distance = abs(x2-x1);                              % Distance to travel
    pointsPerLine = ceil(distance/measuringVelocity*laser.SP_Measrate*1000);
    X = linspace(x1,x2,pointsPerLine);
    Z = zeros(nY,pointsPerLine);
    
    for i = 1:nY                                        %For each X position
        gantry.MoveTo(gantry.Y,Y(i),movingVelocity,1);
        fprintf("Line %d: \t",i);
        line=measureLineOK(laser,gantry,x1,Y(i),x2,Y(i),measuringVelocity,movingVelocity);
        Z(i,:) = line(1:pointsPerLine);
    end 
    
    save(".\Laser_libraries\Results\sensorMeasuringByXLineResults2.mat",... %Store it in a file
        'X','Y','Z'); 

end