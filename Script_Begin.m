
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry = gantry.Connect;

joy = JOYSTICK (gantry);
joy = joy.Connect;

% gantry.MotorEnableAll

cam= CAMERA(1);
cam = cam.Connect;

enfoque = FOCUS(gantry, cam);
