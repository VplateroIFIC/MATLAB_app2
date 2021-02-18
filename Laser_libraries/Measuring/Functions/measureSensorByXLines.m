function [Z,X,Y] = measureSensorByXLines(laser,gantry,x1,x2,y1,y2,nY,velocity)
%Measures the square [x1,x2]x[y1,y2] by nY lines parallel to the x axis, at
%speed (velocity).

    line = measureLine(laser,gantry,x1,y1,x2,y1,velocity);
    pointsPerLine = size(line,2);
    fprintf("Vas a medir %d puntos\n",pointsPerLine);
    Z = zeros(nY,pointsPerLine);
    Y = linspace(y1,y2,nY);
    X = linspace(x1,x2,pointsPerLine);
    
    for i = 1:nY                                        %For each Y position
        gantry.MoveTo(gantry.Y,Y(i),velocity,1);  
        line = measureLine(laser,gantry,x1,Y(i),x2,Y(i),velocity);
        lineSize = size(line,2);
        if lineSize < pointsPerLine
            Z = Z(:,1:lineSize);
            fprintf("Nuevo tamaño de la línea:%d\n",lineSize);
            pointsPerLine = lineSize;
        end
        Z(i,:) = line(1:pointsPerLine);
    end 
    

    
    save(".\Laser_libraries\Results\sensorMeasuringByXLineResults.mat",... %Store it in a file
        'X','Y','Z'); 
end

