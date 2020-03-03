% Testing glue dispensing

%Check gantry delay

% gantry.HomeAll

gantry.MoveToFast(0,-400);
gantry.WaitForMotionAll;
InitPosY=gantry.GetPosition(1);

t = 10;
speed = 10;
delay = zeros(100,3);
for i=10:13
    for j = 1:3        
        speed = i;
        LineLength = t*speed;
        if LineLength > 601
            break;
        end
        tic
        gantry.MoveBy(1,LineLength,speed,1)
        RealTime = toc
        yPos = gantry.GetPosition(1);
        if yPos >= 400
            break;
        end
        gantry.MoveToFast(0,-300, 1);
        
        delay(i+j,1) = speed;
        delay(i+j,2) = LineLength;
        delay(i+j,3) = RealTime;
        delay(i+j,4) = RealTime - LineLength/speed;
        % delay
        fprintf('\nIteration: %d, Speed: %d, LineLength: %d, Elapsed Time: %3.3f DeltaTime: %3.3f', i*j, delay(i,1), delay(i,2), delay(i,3), delay(i,4));
    end
end
disp(' ');

filemane = 'delay1.m'
save (filename, delay);
% speed = 8;
% delta = zeros(1,50);
% for i=1:50
%     speed = i;
%     array (i) = speed;
%     if i == 1
%         delta(i) = 0;
%     else
%     delta(i) = array(i) - array(i-1);
%     end
% end


% tic
% gluing.StartDispensing
% toc

% tic
% gantry.MoveBy(1,LineLength,10,1);
% toc