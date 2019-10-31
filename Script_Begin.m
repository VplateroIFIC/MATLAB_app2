
% Script prepared to begin main gantry setup functions
gantry = GANTRY(2)
gantry = gantry.Connect

joy = JOYSTICK (gantry)
joy = joy.Connect

% gantry.MotorEnableAll

cam= CAMERA
cam = cam.Connect

enfoque = FOCUS(gantry, cam)
