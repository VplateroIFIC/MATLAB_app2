function measure = MoveAndMeasure(laser,gantry,deltaX,deltaY,velocity,wait)
    
    gatry.MoveBy(gantry.X,deltaX,velocity,wait);
    gatry.MoveBy(gantry.Y,deltaY,velocity,wait);
    
    laser.TriggerValuesAndPoll;
    measure = laser.AverageValues;
end