function [X,Y,Z] = Laser_measure1(laser,gantry,Corner1,Corner2,nLines,velocity,name)
    %Measure a grid of pointsPerLine*nLines points in the rectangle [x1,x2]*[y1,y2],
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
    
    maxValue = 10;
    minValue = -10;
%   Corner1 [X, Y, Nan, Z1, Z2, U];
%    Start = Corner1;
%    Start(gantry.vectorZ1,gantry.vectorU) = NaN;
    x(1:2) = [Corner1(gantry.vectorX), Corner2(gantry.vectorX)];
    y(1:2) = [Corner1(gantry.vectorY), Corner2(gantry.vectorY)];
    %z(1:2) = [Corner1(gantry.vectorZ2), Corner2(gantry.vectorZ2)];

    distance = abs(x(2)-x(1));
    pointsPerLine = ceil(distance/velocity*laser.SP_Measrate*1000);
    X = linspace(x(1),x(2),pointsPerLine);
    Y = linspace(y(1),y(2),nLines);  
    Z = zeros(nLines,pointsPerLine);

    gantry.Move2Fast(Corner1,'wait',true);

    laser.LoadParameters(1);   %Set Continuous mode
    %1=Continous sending, 2=Trigger continous sending, 3=Trigger 1000 values
    
    for i = 1:nLines                                    %For each X position
        fprintf("Line %d: \t",i);
        gantry.MoveTo(gantry.Y,Y(i),velocity,0);
%             if mod(i,2)                             %Odd line
%                 gantry.MoveTo(gantry.Y,Y(nLines-i+1),velocity,0);
%             else                                    %Even line
                gantry.MoveTo(gantry.Y,Y(i),velocity,0);
%             end
                %try
                    line=measureLineOK(laser,gantry,x(1),Y(i),x(2),Y(i),velocity,velocity+10);
                    Z(i,:) = line(1:pointsPerLine);
                    Z(Z > maxValue) = -10;      % Remove values out of range
                    Z(Z < minValue) = -10;
                %catch ME
                %    warning("There were error measures:")
                %    fprintf(ME.message);
                %    Z(nLines-i+1,i)=-2;                          %-2 = error measure
                %end
                gantry.WaitForMotionAll(-1);
    end
            measuresFileName = sprintf("%s_%dlines_%dmmseg.mat",name, nLines, velocity);
            pathFile = sprintf(".\\Laser_libraries\\Results\\%s", measuresFileName);
            save(pathFile,'X','Y','Z'); 
end