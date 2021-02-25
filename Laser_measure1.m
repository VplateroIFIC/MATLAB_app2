function [Z,X,Y] = Laser_measure1(laser,gantry,Corner1,Corner2,nX,nY,velocity,minValue,maxValue)
    %Measure a grid of nX*nY points in the rectangle [x1,x2]*[y1,y2],
    %moving the gantry at (velocity) speed, with minValue and maxValue as
    %the minimun and maximum accepted values.
    
    %Parameters:
    %   laser (OPTONCDT2300) is the laser sensor object
    %   gantry (STAGES) is the gantry stages object
    %   x1, x2 (double) are the x possition boundaries of the area which
    %       will be measured
    %   y1, y2 (double) are the y possition boundaries of the area which
    %       will be measured
    %   velocity (double) is the speed at which the gantry moves (mm/s)
    %   minValue, maxValue are the minimum and maximun accepted (or expected) 
    %       values for the measure
    
%   Corner1 [X, Y, Nan, Z1, Z2, U];
%    Start = Corner1;
%    Start(gantry.vectorZ1,gantry.vectorU) = NaN;
    x(1:2) = [Corner1(gantry.vectorX), Corner2(gantry.vectorX)];
    y(1:2) = [Corner1(gantry.vectorY), Corner2(gantry.vectorY)];
    z(1:2) = [Corner1(gantry.vectorZ2), Corner2(gantry.vectorZ2)];


X = linspace(x(1),x(2),nX);
Y = linspace(y(1),y(2),nY);
Z = zeros(nY,nX);

gantry.Move2Fast(Corner1,'wait',1);

    laser.LoadParameters(3);   %Set trigger mode
    
    for i = 1:nX                                    %For each X position
        gantry.MoveTo(gantry.X,X(i),velocity,0);
        for j = 1:nY                                %For each Y position
            if mod(i,2)                             %Odd line
                gantry.MoveTo(gantry.Y,Y(nY-j+1),velocity,0);
%                 gantry.WaitForMotionAll(-1);            %When in possition
            else 
                gantry.MoveTo(gantry.Y,Y(j),velocity,0);
%                 gantry.WaitForMotionAll(-1); 
            end
                try
                    laser.TriggerValuesAndPoll;
                    measure = laser.AverageValues;      %Averages the values and get the mean
                    if measure > maxValue || measure < minValue
                        Z(nY-j+1,i) = -1;                    %-1 = not an accepted value
                    else
                        Z(nY-j+1,i) = 10-measure;            %To store height and not depth
                    end
                catch ME
                    warning("There were error measures:")
                    fprintf(ME.message);
                    Z(nY-j+1,i)=-2;                          %-2 = error measure
                end
                gantry.WaitForMotionAll(-1);
            end
        end
    
    save(".\Laser_libraries\Results\sensorMeasuringResults2.mat",...   %Store it in a file
        'X','Y','Z'); 
end