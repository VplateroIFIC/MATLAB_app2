
%Script prepared to shutdown main gantry Setup functions

joy.Disconnect;

% gantry.MotorDisableAll;
gantry.Disconnect;

cam.Disconnect;

laser.SP_LaserPower=2;
laser.SetMeasurementConfig;
laser.Disconnect;
laser.delete;

scanner.SetLaser(0);
scaner.Disconnect;
scaner.delete;

imaqreset