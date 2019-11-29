
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry = gantry.Connect;

joy = JOYSTICK (gantry);
joy = joy.Connect;

% gantry.MotorEnableAll

<<<<<<< HEAD
cam= CAMERA(1);
cam = cam.Connect;
cam.DispCam;


fid=FIDUCIALS(1);

=======
cam= CAMERA(5);
cam = cam.Connect;

>>>>>>> Camera_update
enfoque = FOCUS(gantry, cam);
