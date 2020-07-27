 
% Script prepared to begin main gantry setup functions
gantry = STAGES(2);
gantry = gantry.Connect;

joy = JOYSTICK (gantry);
joy = joy.Connect;

% gantry.MotorEnableAll

fid=FIDUCIALS(1);

cam= CAMERA(5);
cam = cam.Connect;
cam.DispCam

focus = FOCUS(gantry, cam,1);

importLaserLibraries;       %Libraries for laser integration
scaner = SCANCONTROL2950;
scaner.Connect;
laser = OPTOPNCDT2300;
laser.SetupConnect;
