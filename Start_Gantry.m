
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

dispenser = DISPENSER;


fiducial_1 = [133.3216, -359.4739];
fiducial_2 = [277.0741, 223.8666];

petal = PETALCS(0, fiducial_1, fiducial_2);

gluing = PetalDispensing(dispenser,gantry,petal)

cmd = sprintf('DI--');
error = dispenser.SetUltimus(cmd)
pause(0.1)
cmd = sprintf('AU---');
Feedback = dispenser.GetUltimus(cmd)
