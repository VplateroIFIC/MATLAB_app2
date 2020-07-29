function line = measureAxisLine(laser,gantry,axis,fromPoint,toPoint,velocity)
%Measures a line along one axis (axis) from (fromPoint) to
%   (toPoint) while moving at (velocity) speed.

%Parameters:
%   laser (OPTONCDT2300) is the sensor object,
%   gantry (STAGES) is the gantry stages object,
%   axis (uint) is the axis along which the gantry will move,
%   fromPoint (double) is the starting point in the axis (mm),
%   toPoint (double) is the ending point in the axis (mm),
%   velocity (double) is the speed at which the gantry will move (mm/s)

%Move the gantry to the starting point
    gantry.MoveTo(axis,fromPoint,velocity,0);
    offTime = 0.0066;
    distance = abs(toPoint-fromPoint);

%Stop output and clear buffer
    laser.ClearBuffer;
    
%Get points to measure
    laser.dataSize = ceil((distance/velocity+offTime)*laser.SP_Measrate*1000);

%Wait until starting possition is reached
    gantry.WaitForMotionAll(-1);
    
%Start output, move and get the data
    laser.SoftwareTrigger;
    gantry.MoveToLinear(toPoint,toY,velocity,1);
    laser.PollData;
    
%Get the measured line
    line = laser.scaledData;
    
end

