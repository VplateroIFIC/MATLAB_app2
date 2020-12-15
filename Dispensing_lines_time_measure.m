
module = 'R3S0'                   % Module to measure


% filename_partial = 'R3S0_times.mat'    % Partial measures
% filename_final = 'R3S0.mat'          % Final measurements

filename_partial = sprintf('%s_times.mat',module);
filename_final = sprintf('%s.mat', module);

for i=1:10
gluing.DispenseContinius('R3S0')
variable = genvarname(sprintf('timeStop%d',i))
load(filename_partial, 'timeStop')
eval([variable ' = timeStop'])
end
%Hacemos una matriz con todos los 10 vectores conseguidos
times = [timeStop1;timeStop2;timeStop3;timeStop4;timeStop5;timeStop6;timeStop7;timeStop8;timeStop9;timeStop10];
save(filename_partial, 'timeStop')

media = mean(times);
timeStop = media;
save('filename_final', 'timeStop')

%return

gantry.MoveToFast(0,400)
gantry.WaitForMotionAll();
gantry.MoveTo(gantry.Z1,-16,5)
gantry.MoveTo(gantry.Z2,-100,5)
gantry.WaitForMotionAll();
gantry.MotorDisableAll;
gantry.Disconnect;

return


for i=1:length( timeStop )
    timeStop(i) = mean(times(i));
end

return

% for i=1:10
% variable = genvarname(sprintf('timeStop%d',i))
% eval([variable '  = i*2'])
% end