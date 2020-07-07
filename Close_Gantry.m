
%Script prepared to shutdown main gantry Setup functions

joy = joy.Disconnect;

gantry.MotorDisableAll;
gantry.Disconnect;

cam = cam.Disconnect;

imaqreset

% gantry.MoveToFast(350,0)
% gantry.MoveTo(gantry.Z1,-25,10)
% gantry.MoveTo(gantry.Z2,-70,10)
