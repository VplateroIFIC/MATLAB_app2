 
% Script prepared to begin main gantry setup functions
reposo = [-44.9425, 448.7509 , nan, -15.9923, -99.9, 0.0120];
% % fiducial_1 = [133.4717, -359.2647];
% fiducial_2 = [277.3340, 224.2251];
fiducial_1 = [133.1885 -358.8875         nan   13.3203         nan         nan];
% fiducial_2 = [277.2958  224.2069         nan   13.8901         nan         nan];
fiducial_2 = [277.2484  224.5027       NaN   13.8901         nan         nan];
 
gantry = STAGES(2);
gantry.Connect;
% gantry.MotorEnableAll;
% gantry.HomeAll;

joy = JOYSTICK (gantry);
joy.Connect;
% return
fid=FIDUCIALS(1);
petal = PETALCS(0, fiducial_1, fiducial_2);

% dispenser = DISPENSER;
% gluing = PetalDispensing(dispenser,gantry,petal);
% Feedback = dispenser.GetUltimus('AU---')

imaqreset;
cam = CAMERA(5);
cam.Connect;
% cam.DispCam(10);
% cam.PlotCenter(10);

focus = FOCUS(gantry, cam,1);

% loading = LOADING(gantry,cam);

% scanner = SCANCONTROL2950;
% scanner.Connect;
% scanner.SetLaser(2);

laser = OPTONCDT2300;
laser.SetupConnect;
laser.LoadParameters(1);
