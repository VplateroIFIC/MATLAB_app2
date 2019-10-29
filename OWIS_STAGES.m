classdef OWIS_STAGES
    %OWIS_STAGES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
%         bool properties
         PS90_connected = false;
         X_stage_init = false;
         Y_stage_init = false;
         Z_stage_init = false;
         X_stage_on = false;
         Y_stage_on = false;
         Z_stage_on = false;
%         long properties
         move_state_X=0;
         move_state_Y=0;
         move_state_Z=0;
%         int properties
        mov_state_X=0;
        mov_state_Y=0;
        mov_state_Z=0;
        
        OWISObj             % Eliminar???
        IsConnected         % Eliminar???
        
%         Connection properties
        nComPort=int32(3); 
        nAxis=int32(1);
        dPosF=30000.0;
        dDistance=10.0;
    end
    
    properties (Constant)
        Index = 1;    %// PS-90 INDEX    %search for reference switch and release switch
        Axisid_X = 1.;
        Axisid_Y = 2.;
        Axisid_Z = 3.;
%       const char* result_window = "Result window";        
    end
    
    properties (Access = private)
        
    end
    
    methods
        function obj = OWIS_STAGES(inputArg1,inputArg2)
            %OWIS_STAGES Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        
        
%       function this = Connect(this, timer, SIGNAL(timeout()), SLOT(updatePositions_X()))
%        end
        
%         function this = initialize (this, AXIS)
%             X_stage_init = true;
%             X_stage_on = true;
%             
% 
%             
%         end


                %% Connect  %%
function OWISobj = ps90tool( in1, in2, in3, in4 )
    
%ps90tool This is a demo application for the PS 90 controller.
%   OWISobj = ps90tool( COM_port, axis_no, velocity, distance ) moves the attached axis...
%   function parameters 
%   parameter 1 - COM port
%   parameter 2 - axis number
%   parameter 3 - positioning velocity in Hz
%   parameter 4 - distance for positioning in mm, distance=0 - reference run

%     nComPort=int32(3); 
%     nAxis=int32(1);
%     dPosF=30000.0;
%     dDistance=10.0;
    
    if nargin ~= 4;     % We're receiving incorrect number of parameters
        fprintf (2, 'ps90tool(COM_port, axis_no, velocity, distance)\n');
        fprintf (2, 'e.g. ps90tool(3,1,30000,10)\n');
    end
    
    % set parameters *************
    if ischar(in1) == 0
        this.nComPort=int32(in1);
    else
        this.nComPort=int32(str2double(in1));
    end
    if ischar(in2) == 0
        this.nAxis=int32(in2);
    else
        this.nAxis=int32(str2double(in2));
    end
    if ischar(in3) == 0
        this.dPosF=int32(in3);
    else
        this.dPosF=str2double(in3);
    end
    if ischar(in4) == 0
        this.dDistance=in4;
    else
        this.dDistance=str2double(in4);
    end
    % ****************************

    loadlibrary('ps90','ps90.h')
    % open virtual serial interface
    calllib('ps90','PS90_Connect', 1, 0, this.nComPort, 9600, 0, 0, 8, 0);
%   [x1,...,xN] = calllib(libname,funcname,arg1,...,argN)

    % define constants for calculation Inc -> mm
    % calllib('ps90','PS90_SetStageAttributes', 1, nAxis, 1.0, 200, 1.0)
    
    % initialize axis
calllib('ps90','PS90_MotorInit', 1, this.nAxis);

% set target mode (0 - relative)
calllib('ps90','PS90_SetTargetMode', 1, this.nAxis, 0);

% set velocity 
calllib('ps90','PS90_SetPosF', 1, this.nAxis, this.dPosF);

% check position
PositionA = calllib('ps90','PS90_GetPositionEx', 1, this.nAxis);
fprintf(1, 'Position=%.3f\n', PositionA);

% start positioning
if(this.dDistance==0.0) % go home (to start position)
	calllib('ps90','PS90_GoRef', 1, this.nAxis, 4);
else % move to target position (+ positive direction, - negative direction)
	calllib('ps90','PS90_MoveEx', 1, this.nAxis, this.dDistance, 1);
end

% check move state of the axis
fprintf(1, 'Axis is moving...\n');
while calllib('ps90','PS90_GetMoveState', 1, this.nAxis) > 0 
end
fprintf(1, 'Axis is in position.\n');

% check position
PositionB = calllib('ps90','PS90_GetPositionEx', 1, this.nAxis);
fprintf(1, 'Position=%.3f\n', PositionB);
OWISobj = PositionB;

% close interface
calllib('ps90','PS90_Disconnect',1);

unloadlibrary ps90
    
end
    

                %% Initialize  Pablo%%
        
            function this = INIT(this)
                error = calllib('ps90', 'PS90_SetMotorType', this.Index, this.Axisid_X,motor_type(0));
%                 if ERROR ~= 0
%                     disp ('Error in PS90_SetMotorType X Axis');
%                 end
            
%                     //X Axis : 1//

        loadlibrary('ps90','ps90.h')
%       calllib('ps90',PS90_SetMotorType, this.Index, Axisid_x, motor_type(0))

%        if PS90_SetMotorType(Index,Axisid_X,motor_type[0]) ~= 0
%        error = calllib('ps90', 'PS90_SetMotorType', this.Index, Axisid_x, motor_type(0));
        if calllib('ps90', 'PS90_SetMotorType', this.Index, Axisid_x, motor_type(0)) ~= 0 
            disp ("Error in PS90_SetMotorType X Axis");
        end
        if (calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.Axisid_X,limit_switch(0)) ~= 0 )
            disp('Error in PS90_SetLimitSwitch X Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.Axisid_X,limit_switch_mode(0)) ~= 0 )
            disp('Error in PS90_SetLimitSwitchMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axisid_X,ref_switch(0)) ~= 0 )
            disp('Error in PS90_SetRefSwitch X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.Axisid_X,ref_switch_mode(0)) ~= 0 )
            disp('Error in SetRefSwitchMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetSampleTime', this.Index, this.Axisid_X,sample_time(0)) ~= 0 )
            disp('Error in SetSampleTime X Axis');
        end
        if (calllib('ps90', 'PS90_SetKP', this.Index, this.Axisid_X,KP(0)) ~= 0 ) 
            disp('Error in PS90_SetKP X Axis');
        end
        if (calllib('ps90', 'PS90_SetKI', this.Index, this.Axisid_X,KI(0)) ~= 0 ) 
            disp('Error in PS90_SetKI X Axis');
        end
        if (calllib('ps90', 'PS90_SetKD', this.Index, this.Axisid_X,KD(0)) ~= 0 )
            disp('Error in PS90_SetKD X Axis');
        end
        if (calllib('ps90', 'PS90_SetDTime', this.Index, this.Axisid_X,DTime(0)) ~= 0 )
            disp('Error in PS90_SetDTime X Axis');
        end
        if (calllib('ps90', 'PS90_SetILimit', this.Index, this.Axisid_X,ILimit(0)) ~= 0 )
            disp('Error in PS90_SetILimit X Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.Axisid_X,target_window(0)) ~= 0 )
            disp('Error in PS90_SetTargetWindow X Axis');
        end
        if (calllib('ps90', 'PS90_SetInPosMode', this.Index, this.Axisid_X,pos_mode(0)) ~= 0 )
            disp('Error in PS90_SetInPosMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.Axisid_X,current_level(0)) ~= 0 )
            disp('Error in SetCurrentLevel X Axis');
        end
        if (calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.Axisid_X,pitch(0),increments_per_rev(0),gear_reduction_ratio(0)) ~= 0 )
            disp('Error in PS90_SetStageAttributes X Axis');
        end
        if (calllib('ps90', 'PS90_SetCalcResol', this.Index, this.Axisid_X,res_motor(0)) ~= 0 )
            disp('Error in PS90_SetCalcResol X Axis');
        end
        if (calllib('ps90', 'PS90_SetMsysResol', this.Index, this.Axisid_X,lin_res(0)) ~= 0 )
            disp('Error in PS90_SetMsysResol X Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetMode', this.Index, this.Axisid_X,ini_target_mode(0)) ~= 0 )
            disp('Error in PS90_SetTargetMode X Axis');
        end
        if (calllib('ps90', 'PS90_SetAccelEx', this.Index, this.Axisid_X,acc(0)) ~= 0 )
            disp('Error in PS90_SetAccelEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetDecelEx', this.Index, this.Axisid_X,dacc(0)) ~= 0 )
            disp('Error in PS90_SetDecelEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetJerk', this.Index, this.Axisid_X,jacc(0)) ~= 0 )
            disp('Error in PS90_SetJerk X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.Axisid_X,ref_dacc(0)) ~= 0 )
            disp('Error in PS90_SetRefDecelEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetVel', this.Index, this.Axisid_X,vel(0)) ~= 0 )
            disp('Error in PS90_SetVel X Axis');
        end
        if (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.Axisid_X,pos_vel(0)) ~= 0 )
            disp('Error in PS90_SetPosFEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.Axisid_X,ref_vel_slow(0)) ~= 0 )
            disp('Error in PS90_SetSlowRefFEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.Axisid_X,ref_vel_fast(0)) ~= 0 )
            disp('Error in PS90_SetFastRefFEx X Axis');
        end
        if (calllib('ps90', 'PS90_SetFreeVel', this.Index, this.Axisid_X,free_vel(0)) ~= 0 ))
            disp('Error in PS90_SetFreeVel X Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axisid_X,ref_switch_x) ~= 0 ))
            disp('Error in PS90_SetRefSwitch X Axis');
        end


        value = calllib('ps90', 'PS90_GetPositionEx', this.Index, this.Axisid_X);
        if (calllib('ps90', 'PS90_GetReadError', this.Index) ~= 0 )
            disp('Error in PS90_GetPositionEx X Axis');
        end
        disp('X_possition: ' value);
        
%         //Y Axis : 2//
 
        if (calllib('ps90', 'PS90_SetMotorType', this.Index, this.Axisid_Y,motor_type(1)) ~= 0 )
            disp('Error in PS90_SetMotorType Y Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.Axisid_Y,limit_switch(1)) ~= 0 )
            disp('Error in PS90_SetLimitSwitch Y Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.Axisid_Y,limit_switch_mode(1)) ~= 0 )
            disp('Error in PS90_SetLimitSwitchMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axisid_Y,ref_switch(1)) ~= 0 )
            disp('Error in PS90_SetRefSwitch Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.Axisid_Y,ref_switch_mode(1)) ~= 0 )
            disp('Error in SetRefSwitchMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetSampleTime', this.Index, this.Axisid_Y,sample_time(1)) ~= 0 )
            disp('Error in SetSampleTime Y Axis');
        end
        if (calllib('ps90', 'PS90_SetKP', this.Index, this.Axisid_Y,KP(1)) ~= 0 )
            disp('Error in PS90_SetKP Y Axis');
        end
        if (calllib('ps90', 'PS90_SetKI', this.Index, this.Axisid_Y,KI(1)) ~= 0 )
            disp('Error in PS90_SetKI Y Axis');
        end
        if (calllib('ps90', 'PS90_SetKD', this.Index, this.Axisid_Y,KD(1)) ~= 0 )
            disp('Error in PS90_SetKD Y Axis');
        end
        if (calllib('ps90', 'PS90_SetDTime', this.Index, this.Axisid_Y,DTime(1)) ~= 0 )
            disp('Error in PS90_SetDTime Y Axis');
        end
        if (calllib('ps90', 'PS90_SetILimit', this.Index, this.Axisid_Y,ILimit(1)) ~= 0 )
            disp('Error in PS90_SetILimit Y Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.Axisid_Y,target_window(1)) ~= 0 )
            disp('Error in PS90_SetTargetWindow Y Axis');
        end
        if (calllib('ps90', 'PS90_SetInPosMode', this.Index, this.Axisid_Y,pos_mode(1)) ~= 0 )
            disp('Error in PS90_SetInPosMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.Axisid_Y,current_level(1)) ~= 0 )
            disp('Error in SetCurrentLevel Y Axis');
        end
        if (calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.Axisid_Y,pitch(1),increments_per_rev(1),gear_reduction_ratio(1)) ~= 0 )
            disp('Error in PS90_SetStageAttributes Y Axis');
        end
        if (calllib('ps90', 'PS90_SetCalcResol', this.Index, this.Axisid_Y,res_motor(1)) ~= 0 )
            disp('Error in PS90_SetCalcResol Y Axis');
        end
        if (calllib('ps90', 'PS90_SetMsysResol', this.Index, this.Axisid_Y,lin_res(1)) ~= 0 )
            disp('Error in PS90_SetMsysResol Y Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetMode', this.Index, this.Axisid_Y,ini_target_mode(1)) ~= 0 )
            disp('Error in PS90_SetTargetMode Y Axis');
        end
        if (calllib('ps90', 'PS90_SetAccelEx', this.Index, this.Axisid_Y,acc(1)) ~= 0 )
            disp('Error in PS90_SetAccelEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetDecelEx', this.Index, this.Axisid_Y,dacc(1)) ~= 0 )
            disp('Error in PS90_SetDecelEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetJerk', this.Index, this.Axisid_Y,jacc(1)) ~= 0 )
            disp('Error in PS90_SetJerk Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.Axisid_Y,ref_dacc(1)) ~= 0 )
            disp('Error in PS90_SetRefDecelEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetVel', this.Index, this.Axisid_Y,vel(1)) ~= 0 )
            disp('Error in PS90_SetVel Y Axis');
        end
        if (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.Axisid_Y,pos_vel(1)) ~= 0 )
            disp('Error in PS90_SetPosFEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.Axisid_Y,ref_vel_slow(1)) ~= 0 )
            disp('Error in PS90_SetSlowRefFEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.Axisid_Y,ref_vel_fast(1)) ~= 0 )
            disp('Error in PS90_SetFastRefFEx Y Axis');
        end
        if (calllib('ps90', 'PS90_SetFreeVel', this.Index, this.Axisid_Y,free_vel(1)) ~= 0 )
            disp('Error in PS90_SetFreeVel Y Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axisid_Y,ref_switch_y) ~= 0 )
            disp('Error in PS90_SetRefSwitch Y Axis');
        end

        value = callib ('ps90', 'PS90_GetPositionEx', this.Index, this.Axisid_Y);
        if (calllib('ps90', 'PS90_GetReadError', this.Index) ~= 0 )
            disp('Error in PS90_GetPositionEx Y Axis');
        end
         disp('Y_possition: ' value);      

%         //Z Axis : 3//

        if (calllib('ps90', 'PS90_SetMotorType', this.Index, this.Axisid_Z,motor_type(2)) ~= 0 ) 
            disp('Error in PS90_SetMotorType Z Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.Axisid_Z,limit_switch(2)) ~= 0 )
            disp('Error in PS90_SetLimitSwitch Z Axis');
        end
        if (calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.Axisid_Z,limit_switch_mode(2)) ~= 0 )
            disp('Error in PS90_SetLimitSwitchMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axisid_Z,ref_switch(2)) ~= 0 )
            disp('Error in PS90_SetRefSwitch Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.Axisid_Z,ref_switch_mode(2)) ~= 0 )
            disp('Error in SetRefSwitchMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetSampleTime', this.Index, this.Axisid_Z,sample_time(2)) ~= 0 )
            disp('Error in SetSampleTime Z Axis');
        end
        if (calllib('ps90', 'PS90_SetKP', this.Index, this.Axisid_Z,KP(2)) ~= 0 )
            disp('Error in PS90_SetKP Z Axis');
        end
        if (calllib('ps90', 'PS90_SetKI', this.Index, this.Axisid_Z,KI(2)) ~= 0 )
            disp('Error in PS90_SetKI Z Axis');
        end
        if (calllib('ps90', 'PS90_SetKD', this.Index, this.Axisid_Z,KD(2)) ~= 0 )
            disp('Error in PS90_SetKD Z Axis');
        end
        if (calllib('ps90', 'PS90_SetDTime', this.Index, this.Axisid_Z,DTime(2)) ~= 0 ) 
            disp('Error in PS90_SetDTime Z Axis');
        end
        if (calllib('ps90', 'PS90_SetILimit', this.Index, this.Axisid_Z,ILimit(2)) ~= 0 )
            disp('Error in PS90_SetILimit Z Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.Axisid_Z,target_window(2)) ~= 0 )
            disp('Error in PS90_SetTargetWindow Z Axis');
        end
        if (calllib('ps90', 'PS90_SetInPosMode', this.Index, this.Axisid_Z,pos_mode(2)) ~= 0 )
            disp('Error in PS90_SetInPosMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.Axisid_Z,current_level(2)) ~= 0 )
            disp('Error in SetCurrentLevel Z Axis');
        end
        if (calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.Axisid_Z,pitch(2),increments_per_rev(2),gear_reduction_ratio(2)) ~= 0 )
            disp('Error in PS90_SetStageAttributes Z Axis');
        end
        if (calllib('ps90', 'PS90_SetCalcResol', this.Index, this.Axisid_Z,res_motor(2)) ~= 0 )
            disp('Error in PS90_SetCalcResol Z Axis');
        end
        if (calllib('ps90', 'PS90_SetMsysResol', this.Index, this.Axisid_Z,lin_res(2)) ~= 0 )
            disp('Error in PS90_SetMsysResol Z Axis');
        end
        if (calllib('ps90', 'PS90_SetTargetMode', this.Index, this.Axisid_Z,ini_target_mode(2)) ~= 0 )
            disp('Error in PS90_SetTargetMode Z Axis');
        end
        if (calllib('ps90', 'PS90_SetAccelEx', this.Index, this.Axisid_Z,acc(2)) ~= 0 )
            disp('Error in PS90_SetAccelEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetDecelEx', this.Index, this.Axisid_Z,dacc(2)) ~= 0 )
            disp('Error in PS90_SetDecelEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetJerk', this.Index, this.Axisid_Z,jacc(2)) ~= 0 )
            disp('Error in PS90_SetJerk Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.Axisid_Z,ref_dacc(2)) ~= 0 )
            disp('Error in PS90_SetRefDecelEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetVel', this.Index, this.Axisid_Z,vel(2)) ~= 0 )
            disp('Error in PS90_SetVel Z Axis');
        end
        if (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.Axisid_Z,pos_vel(2)) ~= 0 )
            disp('Error in PS90_SetPosFEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.Axisid_Z,ref_vel_slow(2)) ~= 0 )
            disp('Error in PS90_SetSlowRefFEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.Axisid_Z,ref_vel_fast(2)) ~= 0 )
            disp('Error in PS90_SetFastRefFEx Z Axis');
        end
        if (calllib('ps90', 'PS90_SetFreeVel', this.Index, this.Axisid_Z,free_vel(2]) ~= 0 )
            disp('Error in PS90_SetFreeVel Z Axis');
        end
        if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axisid_Z,ref_switch_z) ~= 0 )
            disp('Error in PS90_SetRefSwitch Z Axis');
        end

        value = callib ('ps90', 'PS90_GetPositionEx', this.Index, this.Axisid_Z);
        if (calllib('ps90', 'PS90_GetReadError', this.Index) ~= 0 )
            disp('Error in PS90_GetPositionEx Z Axis');
        else
            disp('Z_possition: ' value);
        end
            end
        
        
                   %% Trash  %%
     
        
%             switch this.GantryType
%                 case 0
%                 this.GantryObj=A3200Connect;
%                 this.IsConnected=1;
%                 disp('Stages conections done');
%                 case 1
%                 Port = 701;
%                 Address=("10.0.0.100");
%                 this.GantryObj=ACS.SPiiPlusNET.Api;
%                 OpenCommEthernetTCP(this.GantryObj,Address,Port);
%                 this.IsConnected=1;
%                 disp('Stages conections done');
%             end
        end
        
        %% Disconnect  %%
        
        function  this = Disconnect(this)
        % function  this = Disconnect(this)
        % Arguments: object STAGES %
        % Returns: none %
        
        Disconnect(this.OWISobj)
        Connect(this.OWISobj)
        
            switch this.GantryType
                case 0
                A3200Disconnect(this.OWISObj);
                this.IsConnected=0;
                disp('Stages disconnected');
                case 1
                CloseComm(this.GantryObj); 
                this.IsConnected=0;
                disp('Stages disconnected');
            end
        end
        
        
        
        
        
    end
end

