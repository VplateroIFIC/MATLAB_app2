for i=1:10
gluing.DispenseContinius('R0')
variable = genvarname(sprintf('timeStop%d',i))
load('R0_times.mat', timeStop)
eval([variable '  = timeStop'])
end
%Hacemos una matriz con todos los 10 vectores conseguidos
times = [timeStop1;timeStop2;timeStop3;timeStop4;timeStop5;timeStop6;timeStop7;timeStop8;timeStop9;timeStop10];
save('R0_times.mat', 'times')

media = mean(times);
save('R0.mat', times)

gantry.MoveToFast(350,0)
gantry.MoveTo(gantry.Z1,-25,10)
gantry.MoveTo(gantry.Z2,-65,10)
gantry.MotorDisableAll;
gantry.Disconnect;

return

for i=1:28
    timeStop(i) = mean(times(i));
end

return

for i=1:10
variable = genvarname(sprintf('timeStop%d',i))
eval([variable '  = i*2'])
end