function [line,distancePoints] = measureVerticalLine(laser,gantry,fromZ2,toZ2,velocity)

    gantry.MoveTo(gantry.Z2,fromZ2,13,0);                   %Move the gantry to the initial possition.
    offTime = 0.0066;                                       %Time the function laser.PollData delays to get the data.
    distance = abs(toZ2-fromZ2);                            %Distance the gantry has to travel.
    
    %Configure future output
    laser.SP_TriggerCount = 16383;                          %For continous data output when triggered.
    laser.SP_TriggerMode = 3;                               %Software triggering
    laser.SetTriggerMode;
    laser.SetOutputConfig;                                  %For setting SP_Measrate (measuring frequency)
    laser.ClearBuffer;
    
    %Get the number of points we are going to mmeasure
    points = ceil((distance/velocity+offTime)*laser.SP_Measrate*1000); %Points to measure = time spent * measuring frequency. Time spent = time while moving + offTime
    fprintf("You are going to measure %d points\n",points);
    if points > laser.bufferValueSize
        warning("You are going to need a bigger buffer size: %d",ceil(points/4));
    end
    laser.dataSize = points;
    distancePoints=linspace(0,distance,points);
    
    %Wait until starting possition is reached
    gantry.WaitForMotionAll(-1);
    
    %Measure, move and when movement finishes, get the data and stop output. 
    laser.SoftwareTrigger;
    gantry.MoveTo(gantry.Z2,toZ2,velocity,0);                  %Move the gantry to the final possition.
    gantry.WaitForMotionAll(-1);
    laser.PollData;
    laser.SP_TriggerCount = 0;                              %For stopping data output (0 = no data transferred when triggered)
    laser.SetTriggerMode;
    
    %Save the data
    line = laser.scaledData;                            %Get the measured line reversed (so it outputs depth and not heaight)
    save("C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\Results\verticalLineMeasuringResults.mat",...             %Store it in a file
        'line','velocity','distance','distancePoints');

end

