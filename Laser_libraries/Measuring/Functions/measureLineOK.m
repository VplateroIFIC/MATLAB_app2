function [line,distancePoints] = measureLineOK(laser,gantry,fromX,fromY,toX,toY,measuringVelocity,movingVelocity)
%Measure one line from (fromX,fromY) to (toX,toY) while moving at
%   (velocity) speed.

%Parameters:
%   laser (OPTONCDT2300) is the sensor object,
%   gantry (STAGES) is the gantry stages object,
%   axis (uint) is the axis along which the gantry will move,
%   fromX (double) is the starting X possition (mm),
%   fromY (double) is the starting Y possition (mm),
%   toX (double) is the ending X possition (mm),
%   toY (double) is the ending Y possition (mm),
%   velocity (double) is the speed at which the gantry will move (mm/s)
    
    gantry.MoveTo(gantry.X,fromX,movingVelocity,0);                  %Move the gantry to the initial possition.
    gantry.MoveTo(gantry.Y,fromY,movingVelocity,0);                  %Move the gantry to the initial possition.
    from = [fromX,fromY];
    to = [toX,toY];
    offTime = 0.066;                                       %Time the function laser.PollData delays to get the data.
    distance = pdist([from;to],'euclidean');                %Distance the gantry has to travel.
    
    %Get the number of points we are going to mmeasure
    points = ceil((distance/measuringVelocity+offTime)*laser.SP_Measrate*1000); %Points to measure = time spent * measuring frequency. Time spent = time while moving + offTime
    fprintf("You are going to measure %d points\n",points);
    if points > laser.bufferValueSize
        warning("You are going to need a bigger buffer size: %d",ceil(points/4));
    end
    laser.dataSize = points;
    distancePoints=linspace(0,distance,points);
    
    %Wait until starting possition is reached
    gantry.WaitForMotionAll(-1);
    
    %Measure, move and when movement finishes, get the data and stop output. 
    laser.ClearBuffer;
    gantry.MoveTo(gantry.X,toX,measuringVelocity,0);                  %Move the gantry to the final possition.
    gantry.MoveTo(gantry.Y,toY,measuringVelocity,0); 
    gantry.WaitForMotionAll(-1);
    laser.PollData;
    
    %Save the data
    line = 10.-laser.scaledData;                            %Get the measured line reversed (so it outputs depth and not heaight)
    
end