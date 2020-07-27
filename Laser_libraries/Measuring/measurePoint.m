function data = measurePoint(laser,gantry,radius,n)
   
    velocity = 5;
    wait = 0;
    data = zeros(1,n);

%Create normally distributed random array
    Xposition = randn(1,n-1)/5*radius;
    Yposition = randn(1,n-1)/5*radius;

%Get starting position
    startPosition = zeros(1,2);
    startPosition(1) = gantry.GetPostion(gantry.X);
    startPosition(2) = gantry.GetPostion(gantry.Y);
    
%Measure the first value
   laser.TriggerValuesAndPoll;
   data(1) = laser.AverageValues;
   
%Measure values
    for i=2:n
        data(i) = MoveAndMeasure(laser,gantry,Xposition(i-1),Yposition(i-1),velocity,wait);
        gantry.MoveTo(gantry.X,startPosition(1),velocity,wait);
    end   
end