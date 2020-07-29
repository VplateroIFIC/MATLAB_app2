function line = measureLine(laser,gantry,fromX,fromY,toX,toY,velocity)
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
    
    gantry.MoveToLinear(fromX,fromY,13,0);                  %Move the gantry to the initial possition.
    from = [fromX,fromY];
    to = [toX,toY];
    offTime = 0.0066;                                       %Time the function laser.PollData delays to get the data.
    distance = pdist([from;to],'euclidean');                %Distance the gantry has to travel.
    
    %Configure future output
    laser.SP_TriggerCount = 16383;                          %For continous data output when triggered.
    laser.SP_TriggerMode = 3;                               %Software triggering
    laser.SetTriggerMode;
    laser.SetOutputConfig;                                  %For setting SP_Measrate (measuring frequency)
    laser.ClearBuffer;
    
    %Get the number of points we are going to mmeasure
    points = ceil((distance/velocity+offTime)*laser.SP_Measrate*1000); %Points to measure = time spent * measuring frequency. Time spent = time while moving + offTime
    printf("You are going to measure %d points\n",points);
    if points > laser.bufferValueSize
        warning("You are going to need a bigger buffer size: %d",ceil(points/4));
    end
    laser.dataSize = points;
    
    %Wait until starting possition is reached
    gantry.WaitForMotionAll(-1);
    
    %Measure, move and when movement finishes, get the data and stop output. 
    laser.SoftwareTrigger;
    gantry.MoveToLinear(toX,toY,velocity,1);
    laser.PollData;
    laser.SP_TriggerCount = 0;                              %For stopping data output (0 = no data transferred when triggered)
    laser.SetTriggerMode;
    
    %Save the data
    line = laser.scaledData;                                %Get the measured line
    save("Results\lineMeasuringResults.mat",...             %Store it in a file
        'line','velocity','distance');      
    
end