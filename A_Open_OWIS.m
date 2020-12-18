% faddpath('owis_lib\x64')
gantry = OWIS_STAGES;
gantry.INIT;
joy = JOYSTICK(gantry);
joy.Connect;
cam=CAMERA(4);
cam.Connect;
cam.DispCam
focus=FOCUS(gantry,cam,2);
fid=FIDUCIALS(2);