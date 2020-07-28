function [Z,X,Y] = measureSensor(laser,gantry,x1,x2,y1,y2,nX,nY,velocity)
    X = linspace(x1,x2,nX);
    Y = linspace(y1,y2,nY);
    Z = zeros(nX,nY);
    
    for i = 1:nX
        for j = 1:nY
            gantry.MoveTo(gantry.X,X(i),velocity,0);
            if mod(i,2)
                gantry.MoveTo(gantry.Y,Y(nY-j+1),velocity,1);
            else
                gantry.MoveTo(gantry.Y,Y(j),velocity,1);
            end
            gantry.WaitForMotionAll(-1);
            try
                Z(i,j) = 10-mean(measurePoint(laser,gantry,0.01,10));
            catch ME
                warning("Something occured during measurement")
                fprintf(ME.msgtext);
                Z(i,j)=0;
            end
        end
    end
end