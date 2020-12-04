 
% Script prepared to begin main gantry setup functions
reposo = [-44.9425, 448.7509 , nan, -15.9923, -100.0164, 0.0120];
fiducial_1 = [133.4717, -359.2647];
fiducial_2 = [277.3340, 224.2251];
 
gantry = STAGES(2);
gantry.Connect;
gantry.MotorEnableAll;
% gantry.HomeAll;

joy = JOYSTICK (gantry);
joy.Connect;
% return
fid=FIDUCIALS(1);
petal = PETALCS(0, fiducial_1, fiducial_2);

dispenser = DISPENSER;
gluing = PetalDispensing(dispenser,gantry,petal);
Feedback = dispenser.GetUltimus('AU---')

imaqreset;
cam= CAMERA(5);
cam.Connect;
cam.DispCam(10);
cam.PlotCenter(10);

focus = FOCUS(gantry, cam,1);

% scanner = SCANCONTROL2950;
% scanner.Connect;
% laser = OPTONCDT2300;
% laser.SetupConnect;
