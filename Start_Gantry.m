
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry = gantry.Connect;

joy = JOYSTICK (gantry);
joy = joy.Connect;

gantry.MotorEnableAll

fid=FIDUCIALS(1);

% cam= CAMERA(5);
% cam = cam.Connect;
% cam.DispCam
% 
% focus = FOCUS(gantry, cam,1);

dispenser = DISPENSER

gluing = PetalDispensing(dispenser,gantry)

cmd = sprintf('DI--');
error = dispenser.SetUltimus(cmd)
pause(0.1)
cmd = sprintf('AU---');
Feedback = dispenser.GetUltimus(cmd)
