% addpath('C:\Users\leon0\Documents\Matlab_app\owis_lib\x64')
eje = OWIS_STAGES;
eje = eje.INIT;
 joy = JOYSTICK_OWIS(eje);
 joy = joy.Connect;
 cam=CAMERA(4);
 cam=cam.Connect;
 cam.DispCam
 focus=FOCUS(eje,cam,2);
fid=FIDUCIALS(2);

% cmd = '?BAUDRATE';
% pszAns = 'hola';
% len = 50;
% nRequest = 1;  %1-> Read answer; 0-> Just send command
% nBreak = 5;
% 
% tic
% [AnswerLength, A, B] = calllib('ps90', 'PS90_CmdAnsEx', eje.Index, cmd, pszAns, len, nRequest, nBreak)
% toc
% cmd = 'BAUDRATE=115200'
% 
% tic
% eje.MoveBy(2,+2,1)
% toc
% 
% tic
% eje.GetPosition(2)
% toc
% 
% axis = 2
% tic
% value = calllib ('ps90', 'PS90_GetPositionEx', eje.Index, axis)
% toc
% 
% error = calllib('ps90', 'PS90_Connect', eje.Index, eje.Interface, eje.nComPort, 115200, eje.Handshake, eje.Parity, eje.dataBits, eje.stopBits)
% error = calllib ('ps90', 'PS90_Disconnect', eje.Index)
% 
% tic
% eje.GetPosition(3)
% toc
% 
% cmd = 'RESETAC'     %Activate motor driver board Reset. 
% cmd = 'RESETMB'     %Activate main board Reset. 
% 
% unloadlibrary('ps90')
