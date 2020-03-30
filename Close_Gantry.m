
%Script prepared to shutdown main gantry Setup functions

joy = joy.Disconnect;

gantry.MotorDisableAll;
gantry.Disconnect;

cam = cam.Disconnect;

imaqreset