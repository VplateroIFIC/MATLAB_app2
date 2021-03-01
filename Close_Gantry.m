
%Script prepared to shutdown main gantry Setup functions

joy.Disconnect;
gantry.Move2Fast(reposo)
gantry.MotorDisableAll;
gantry.Disconnect;

cam.Disconnect;

laser.PowerOff;
laser.Disconnect;

% scanner.SetLaser(0);
% scanner.Disconnect;

