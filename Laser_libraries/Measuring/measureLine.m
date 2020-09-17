function [line,distancePoints] = measureLine(laser,gantry,fromX,fromY,toX,toY,velocity)
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
    
    gantry.MoveTo(gantry.X,fromX,velocity,0);                  %Move the gantry to the initial possition.
    gantry.MoveTo(gantry.Y,fromY,velocity,0);                  %Move the gantry to the initial possition.
    from = [fromX,fromY];
    to = [toX,toY];
    distance = pdist([from;to],'euclidean');                %Distance the gantry has to travel.
    
    %Configure future output
    laser.SP_TriggerCount = 16383;                          %For continous data output when triggered.
    laser.SP_TriggerMode = 3;                               %Software triggering
    laser.SetTriggerMode;
    laser.SetOutputConfig;                                  %For setting SP_Measrate (measuring frequency)
    laser.ClearBuffer;
    
    %Wait until starting possition is reached
    gantry.WaitForMotionAll(-1);
    
    %Measure, move and when movement finishes, get the data and stop output. 
    laser.ClearBuffer;
    laser.SoftwareTrigger;
    %while laser.AvailableValues < 1
    %end
    gantry.MoveTo(gantry.X,toX,velocity,0);                  %Move the gantry to the final possition.
    gantry.MoveTo(gantry.Y,toY,velocity,0); 
    gantry.WaitForMotionAll(-1);
    laser.dataSize = laser.AvailableValues;
    laser.PollData;
    laser.SP_TriggerCount = 1000;                              %For stopping data output (0 = no data transferred when triggered)
    laser.SetTriggerMode;
    distancePoints=linspace(0,distance,laser.dataSize);
    
    %Save the data
    line = 10.-laser.scaledData;                            %Get the measured line reversed (so it outputs depth and not heaight)
    save("C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\Results\lineMeasuringResults.mat",...             %Store it in a file
        'line','velocity','distance','distancePoints');      
    
end