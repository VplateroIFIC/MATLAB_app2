
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry = gantry.Connect;

joy = JOYSTICK (gantry);
joy = joy.Connect;

% gantry.MotorEnableAll

fid=FIDUCIALS(1);


cam= CAMERA(5);
cam = cam.Connect;

enfoque = FOCUS(gantry, cam);
