function measure = MoveAndMeasure(laser,gantry,deltaX,deltaY,velocity)
    
    gantry.MoveBy(gantry.X,deltaX,velocity,0);
    gantry.MoveBy(gantry.Y,deltaY,velocity,0);
    gantry.WaitForMotionAll(-1);
    
    laser.TriggerValuesAndPoll;
    measure = laser.AverageValues;
end