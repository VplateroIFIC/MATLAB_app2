% Testing glue dispensing

%Check gantry delay

% gantry.HomeAll

gantry.MoveToFast(0,-400);
gantry.WaitForMotionAll;
InitPosY=gantry.GetPosition(1);

t = 10;
speed = 10;
delay2 = zeros(100,3);
for i=1:40     
        speed = 60;
        LineLength = t*i/2;
        if LineLength > 601
            break;
        end
        tic
        gantry.MoveBy(1,LineLength,speed,1)
        RealTime = toc;
        yPos = gantry.GetPosition(1);
        if yPos >= 400
            break;
        end
        gantry.MoveToFast(0,-300, 1);
        
        delay2(i,1) = speed;
        delay2(i,2) = LineLength;
        delay2(i,3) = RealTime;
        delay2(i,4) = RealTime - LineLength/speed;
        % delay
        fprintf('\nIteration: %d, Speed: %d, LineLength: %d, Elapsed Time: %3.3f DeltaTime: %3.3f', i, delay2(i,1), delay2(i,2), delay2(i,3), delay2(i,4));
end
disp(' ');

save('delay2.mat','delay2')

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

for i=1:19
    if 3<=i && i<=7
        fprintf('OK\t %d\n', i);
    else 
        fprintf('#\t %d\n', i);
    end
end