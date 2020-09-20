function [Z,X,Y] = measureSensor(laser,gantry,x1,x2,y1,y2,nX,nY,velocity,minValue,maxValue)
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
    
    laser.LoadParameters(3);   %Set trigger mode

    X = linspace(x1,x2,nX);     % X coordinates of the points to measure
    Y = linspace(y1,y2,nY);     % Y coordinates of the points to measure
    Z = zeros(nY,nX);
    
    for i = 1:nX                                    %For each X position
        gantry.MoveTo(gantry.X,X(i),velocity,0);
        for j = 1:nY                                %For each Y position
            if mod(i,2)                             %So the gantry zigzags
                gantry.MoveTo(gantry.Y,Y(nY-j+1),velocity,0);
                gantry.WaitForMotionAll(-1);            %When in possition
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
            else
                gantry.MoveTo(gantry.Y,Y(j),velocity,0);
                gantry.WaitForMotionAll(-1);            %When in possition
                try
                    laser.TriggerValuesAndPoll;
                    measure = laser.AverageValues;      %Averages the values and get the mean
                    if measure > maxValue || measure < minValue
                        Z(j,i) = -1;                    %-1 = not an accepted value
                    else
                        Z(j,i) = 10-measure;            %To store height and not depth
                    end
                catch ME
                    warning("There were error measures:")
                    fprintf(ME.msgtext);
                    Z(j,i)=-2;                          %-2 = error measure
                end
            end
        end
    end
    
    save("C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\Results\sensorMeasuringResults.mat",...   %Store it in a file
        'X','Y','Z'); 
end