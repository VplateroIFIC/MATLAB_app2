addpath('C:\Users\leon0\Documents\Matlab_app\owis_lib\x64')
eje = OWIS_STAGES;
eje = eje.INIT;
joy = JOYSTICK_OWIS(eje);
joy = joy.Connect;
cam=CAMERA(4);
cam=cam.Connect;
cam.DispCam
focus=FOCUS(eje,cam,2);
fid=FIDUCIALS(2);