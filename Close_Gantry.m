
%Script prepared to shutdown main gantry Setup functions

joy = joy.Disconnect;

gantry.MotorDisableAll;
gantry = gantry.Disconnect;

cam = cam.Disconnect;

laser.SP_LaserPower=2;
laser.SetMeasurementConfig;
laser.Disconnect;
laser.delete;

scanner.SetLaser(0);
scaner.Disconnect;
scaner.delete;

imaqreset