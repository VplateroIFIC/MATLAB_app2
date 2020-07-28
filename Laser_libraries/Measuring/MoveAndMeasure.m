function measure = MoveAndMeasure(laser,gantry,deltaX,deltaY,velocity,wait)
    
    gantry.MoveBy(gantry.X,deltaX,velocity,0);
    gantry.MoveBy(gantry.Y,deltaY,velocity,wait);
    gantry.WaitForMotionAll(-1);
    
    laser.TriggerValuesAndPoll;
    measure = laser.AverageValues;
end