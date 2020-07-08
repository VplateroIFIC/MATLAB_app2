
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry.Connect;

% joy = JOYSTICK (gantry);
% joy = joy.Connect;

% gantry.MotorEnableAll

fid=FIDUCIALS(1);

% cam= CAMERA(5);
% cam = cam.Connect;
% cam.DispCam
% 
% focus = FOCUS(gantry, cam,1);

dispenser = DISPENSER;


fiducial_1 = [133.3216, -359.4739];
fiducial_2 = [277.0741, 223.8666];

petal = PETALCS(0, fiducial_1, fiducial_2);

gluing = PetalDispensing(dispenser,gantry,petal);

cmd = sprintf('DI--');
error = dispenser.SetUltimus(cmd)
pause(0.1)
cmd = sprintf('AU---');
Feedback = dispenser.GetUltimus(cmd)


tic
gantry.WaitForMotionAll()
tic
gluing.StartDispensing()
toc

return

for i=1:10
gluing.DispenseContinius('R0')
variable = sprintf('timeStop%d',i)
load('R0.mat', variable)
end
times = [timeStop1;timeStop2;timeStop3;timeStop4;timeStop5;timeStop6;timeStop7;timeStop8;timeStop9];
save('R0_times.mat', 'times')

gantry.MoveToFast(350,0)
gantry.MoveTo(gantry.Z1,-25,10)
gantry.MoveTo(gantry.Z2,-65,10)
gantry.MotorDisableAll;
gantry.Disconnect;
