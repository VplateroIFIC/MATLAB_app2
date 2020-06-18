

classdef STAGES < handle
    
%   CLASS TO CONTROL STAGES
% 
% this class provides calls to the functions that control de stages of the gantry.
%
% It is adapted to be used for both, ALIO and AEROTECh Gantry.
%
% The kind of gantry will be done as input to the connect method:

% 0 --> GANTRY FREIBURG
% 1 --> GANTRY HAMBURG
% 2 --> GANTRY VALENCIA
% 3 --> GANTRY VANCOUVER

% GANTRY TYPE 0 --> AEROTECH
% GANTRY TYPE 1 --> ALIO


% This class in under development, in case of bug or other question, please contact to Pablo León (pablo.leon@cern.ch)



 % 0 --> GANTRY FREIBURG
    % 1 --> GANTRY HAMBURG
    % 2 --> GANTRY VALENCIA
    % 3 --> GANTRY VANCOUVER
    
    % GANTRY TYPE 0 --> AEROTECH
    % GANTRY TYPE 1 --> ALIO
    
    
    % This class in under development, in case of bug or other question, please contact to Pablo León (pablo.leon@cern.ch)
    
    
    properties (Access=public,Constant)
        X=1;
        Y=0;
        Z1=4;
        Z2=5;
        U=6;
    end
    
    properties (Access=public)
        
        % General Properties %
        
        GantryType;
        xAxis;
        yAxis;
        z1Axis;
        z2Axis;
        uAxis;
        nullAxis;
        
        % ALIO properties %
        
        motorX;finish
        MotorY;
        MotorZ1;
        MotorZ2;
        HomeVelocity;
        Acceleration;
        Absolute;
        Relative;
        GantryObj;
        JogVFlag;
        
        % AEROTECH properties %
        
        zAxis;
        yyAxis;
        
        % Other movements
        
        zSecureHeigh = 20;              % Min Z height for fast movements
        zNominalHeigh = 0;              % Nominal height
        zHighSpeed = 10;
        zNominalSpeed = 5;
        xyHighSpeed = 30;
        xyNominalSpeed = 10;
        DefaultTimeOut = 30000;         %Default time out 60 sec      
    end
    properties (Access=public)
        IsConnected;
    end
    
    
    methods
        
        %% CONSTRUCTOR %%
        
        function this = STAGES(Nsite)
            %function this = STAGES(Nsite)
            % Arguments: site Number %
            % Returns: object %
            switch Nsite
                case 0 || 1 || 3
                    
                    this.GantryType=0;
                    addpath('Vancouver\Matlab_lib\Matlab\x64');
                    this.xAxis=2;
                    this.yAxis=0;
                    this.yyAxis=1;
                    this.zAxis=3;
                    this.uAxis=4;
                    
                case 2
                    
                    this.GantryType=1;
                    %                  NET.addAssembly('F:\Gantry_code\Matlab_app\ACS.SPiiPlusNET.dll'); %loading .NET assembly
                    %                     NET.addAssembly('D:\Code\Matlab_app\ACS.SPiiPlusNET.dll'); %loading .NET assembly
                    NET.addAssembly(fullfile(pwd, '.\ACS.SPiiPlusNET.dll')); %loading .NET assembly
                    stream1 = "ACS.SPiiPlusNET.Axis.ACSC_AXIS_";
                    this.xAxis = eval(stream1 + this.X);
                    this.yAxis = eval(stream1 + this.Y);
                    this.z1Axis = eval(stream1 + this.Z1);
                    this.z2Axis = eval(stream1 + this.Z2);
                    this.uAxis = eval(stream1 + this.U);
%                     this.xAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_0;
%                     this.yAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_1;
%                     this.z1Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_4;
%                     this.z2Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_5;
%                     this.uAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_6;
                    this.nullAxis=ACS.SPiiPlusNET.Axis.ACSC_NONE;
                    this.HomeVelocity=15;
                    this.Acceleration=20;
                    this.Relative=ACS.SPiiPlusNET.MotionFlags.ACSC_AMF_RELATIVE;
                    this.Absolute=ACS.SPiiPlusNET.MotionFlags.ACSC_NONE;
                    this.JogVFlag=ACS.SPiiPlusNET.MotionFlags.ACSC_AMF_VELOCITY; 
            end
        end
        
        %% Connect  %%
        
        function  this = Connect(this)
            % function  this = Connect(this)
            % Arguments: object STAGES %
            % Returns: none %
            switch this.GantryType
                case 0
                    this.GantryObj=A3200Connect;
                    this.IsConnected=1;
                    disp('Stages conections done');
                case 1
                    Port = 701;
                    Address=("10.0.0.100");
                    this.GantryObj=ACS.SPiiPlusNET.Api;
                    OpenCommEthernetTCP(this.GantryObj,Address,Port);
                    this.IsConnected=1;
                    disp('Stages conections done');
            end
        end
        
        %% Disconnect  %%
        
        function  this = Disconnect(this)
            % function  this = Disconnect(this)
            % Arguments: object STAGES %
            % Returns: none %
            switch this.GantryType
                case 0
                    A3200Disconnect(this.GantryObj);
                    this.IsConnected=0;
                    disp('Stages disconnected');
                case 1
                    CloseComm(this.GantryObj);
                    this.IsConnected=0;
                    disp('Stages disconnected');
            end
        end
        
        %% HomeAll %%
        
        function  HomeAll(this)
            % function  HomeAll(this) This function run the buffer 10 with the initialization homing routine provided by ALIO
            % Arguments: object STAGES %
            % Returns: none %
            RunBuffer(this.GantryObj,ACS.SPiiPlusNET.ProgramBuffer.ACSC_BUFFER_20,[]);
            WaitProgramEnd(this.GantryObj,ACS.SPiiPlusNET.ProgramBuffer.ACSC_BUFFER_20,inf);
            
            SetVelocity(this.GantryObj,this.xAxis,this.HomeVelocity);
            SetVelocity(this.GantryObj,this.yAxis,this.HomeVelocity);
            SetVelocity(this.GantryObj,this.z1Axis,this.HomeVelocity);
            SetVelocity(this.GantryObj,this.z2Axis,this.HomeVelocity);
            SetVelocity(this.GantryObj,this.uAxis,this.HomeVelocity);
        end
        
        
        %% loadBuffer %%
        
        function  loadBuffer(this)
            % function  runBuffer(this)
            % Arguments: object STAGES %
            % Returns: none %
            
            LoadBuffersFromFile(this.GantryObj,'D:\Code\MATLAB_app\ALIO_buffers\Buffer_11_homing_routines.txt');
            
        end
        
        
        %% getting assembly info in display (just for ALIO gantry) %%
        
        function  AssemblyMethodsInfo(this)
            % function  this = Disconnect(this)
            % Arguments: object STAGES %
            % Returns: none %
            methodsview('ACS.SPiiPlusNET.Api');
        end
        
        
        
        %% GetFPosition. %%
        
        function  value = GetFPosition(this,axis)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
            switch axis
                case 0
                    value=GetFPosition(this.GantryObj,this.xAxis);
                case 1
                    value=GetFPosition(this.GantryObj,this.yAxis);
                case 4
                    value=GetFPosition(this.GantryObj,this.z1Axis);
                case 5
                    value=GetFPosition(this.GantryObj,this.z2Axis);
                case 6
                    value=GetFPosition(this.GantryObj,this.uAxis);
            end
        end
        
        %% GetRPosition. %%
        
        function  value = GetRPosition(this,axis)
            % function  value = GetRposition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
            switch axis
                case 0
                    value=GetRPosition(this.GantryObj,this.xAxis);
                case 1
                    value=GetRPosition(this.GantryObj,this.yAxis);
                case 4
                    value=GetRPosition(this.GantryObj,this.z1Axis);
                case 5
                    value=GetRPosition(this.GantryObj,this.z2Axis);
                case 6
                    value=GetRPosition(this.GantryObj,this.uAxis);
            end
        end
        
        %% GetPosition. %%
        
        function  value = GetPosition(this,axis)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
            
            positionVector=ReadVariableAsVector(this.GantryObj,'APOS', ACS.SPiiPlusNET.ProgramBuffer.ACSC_NONE, ACS.SPiiPlusNET.Api.ACSC_NONE, ACS.SPiiPlusNET.Api.ACSC_NONE, ACS.SPiiPlusNET.Api.ACSC_NONE, ACS.SPiiPlusNET.Api.ACSC_NONE);
            % index position in positionVector array does not fit with the oficial number assigned to the stages. Take care!
            switch axis
                case 0
                    value=positionVector(1);
                case 1
                    value=positionVector(2);
                case 4
                    value=positionVector(5);
                case 5
                    value=positionVector(6);
                case 6
                    value=positionVector(7);
            end
        end
        
        function  value = GetPositionAll(this)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double array (x,y,rot,z1,z2)%
            
            value (1) = this.GetPosition(0);
            value (2) = this.GetPosition(1);
%             value (3) = this.GetPosition(2);
            value (4) = this.GetPosition(4);
            value (5) = this.GetPosition(5);
        end
        
        
        %% GetVelocity %%
        
        function  value = GetVelocity(this,axis)
            % function  value = GetVelocity(this,axis)
            % Arguments: object ALIO (this),axis int%
            % Returns: double %
            switch this.GantryType
                case 0
                    %insert here getVelocity with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            value=GetFVelocity(this.GantryObj,this.xAxis);
                        case 1
                            value=GetFVelocity(this.GantryObj,this.yAxis);
                        case 4
                            value=GetFVelocity(this.GantryObj,this.z1Axis);
                        case 5
                            value=GetFVelocity(this.GantryObj,this.z2Axis);
                        case 6
                            value=GetFVelocity(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        
        %% GetCurrentFeedback %%
        
        function  value = GetCurrentFeedback(this,axis)
            % function  value = GetCurrentFeedback(this,axis)
            % Arguments: object ALIO (this),axis int%
            % Returns: double %
            switch this.GantryType
                case 0
                    %insert here GetCurrentFeedback with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            value=ReadVariable(this.GantryObj,'RMS',this.xAxis,this.xAxis); % if error, tray send 0 (or ACSC_NONE) after GantryObj pointer
                        case 1
                            value=ReadVariable(this.GantryObj,'RMS',this.yAxis,this.yAxis);
                        case 4
                            value=ReadVariable(this.GantryObj,'RMS',this.z1Axis,this.z1Axis);
                        case 5
                            value=ReadVariable(this.GantryObj,'RMS',this.z1Axis,this.z2Axis);
                        case 6
                            value=ReadVariable(this.GantryObj,'RMS',this.uAxis,this.uAxis);
                    end
            end
        end
        
        
        
        
        %% Home %%
        
        function  Home(this,axis)
            % function  Home(this,axis)
            % Arguments: object ALIO (this), axis int,%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here Home with AEROTECH gantry %
                    
                case 1
                    SetVelocity(this.GantryObj,this.xAxis,this.HomeVelocity);
                    SetVelocity(this.GantryObj,this.yAxis,this.HomeVelocity);
                    SetVelocity(this.GantryObj,this.z1Axis,this.HomeVelocity);
                    SetVelocity(this.GantryObj,this.z2Axis,this.HomeVelocity);
                    SetVelocity(this.GantryObj,this.uAxis,this.HomeVelocity);
                    target=0;
                    switch axis
                        case 0
                            ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.xAxis,0);
                        case 1
                            ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
                            WaitForMotion(this,axis,0,-1);
                            SetFPosition(this.GantryObj,this.yAxis,0);
                        case 4
                            ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.z1Axis,0);
                        case 5
                            ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.z2Axis,0);
                        case 6
                            ToPoint(this.GantryObj,this.Absolute,this.uAxis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.uAxis,0);
                    end
            end
        end
        
        
        %% MoveTo %% Absolute movements %%
        function  MoveTo(this,axis,target,velocity, wait)
            % function  MoveTo(this,axis,target,velocity, wait)
            % Arguments: object ALIO (this), axis int, target double, velocity double, wait int
            % (0-> Wait until movement finishes, 1-> No wait
            % Returns: none %
            %
            switch nargin
                case 5
                    
                case 4
                    wait = 0;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            
            switch this.GantryType
                case 0
                    %insert here MoveTo with AEROTECH gantry %
                case 1
                    switch axis
                        case this.X
                            SetVelocity(this.GantryObj,this.xAxis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
                        case this.Y
                            SetVelocity(this.GantryObj,this.yAxis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
                        case this.Z1
                            SetVelocity(this.GantryObj,this.z1Axis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target);
                        case this.Z2
                            SetVelocity(this.GantryObj,this.z2Axis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target);
                        case this.U
                            SetVelocity(this.GantryObj,this.uAxis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.uAxis,target);
                    end
                    
                    if wait > 0
                        this.WaitForMotion(axis, this.DefaultTimeOut);
                    end
            end
        end
        
        %% MoveToLinear %% Absolute movements %%
        
        function  MoveToLinear(this,xtarget,ytarget,velocity, wait)
            % function  MoveTo(this,xtarget,ytarget,velocity, wait)
            % Arguments: object ALIO (this), axis int, target double, velocity double, wait int
            % (0-> Wait until movement finishes, 1-> No wait
            % Returns: none %
            %
            switch nargin
                case 5
                case 4
                    wait = 0;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            % array = NET.createArray(typeName,[m,n,p,...]);
            % array.Set(m, object);
            axis = NET.createArray('ACS.SPiiPlusNET.Axis',3); axis.Set(0, this.xAxis); axis.Set(1, this.yAxis); axis.Set(2, this.nullAxis);  %d2 = NET.createArray('System.String',3); d2(1) = 'one'; d2(2) = 'two'; d2(3) = 'zero';
            points = [xtarget,ytarget];
            
            SetVelocity(this.GantryObj,this.xAxis,velocity)
            ToPointM(this.GantryObj,this.Absolute,axis,points);
            %
            if wait > 0
                this.WaitForMotion(0, -1);
                this.WaitForMotion(1, -1);
            end
        end
        
        
        %% MoveBy %% Relative movement %%
        
        function  MoveBy(this,axis,delta,velocity, wait)
            % function  MoveBy(this,axis,delta,velocity, wait)
            % Arguments: object ALIO (this), axis int, delta double, velocity double, int wait%
            % (0-> Wait until movement finishes, 1-> No wait
            % Returns: none %
            
            switch nargin
                case 5
                    
                case 4
                    wait = 0;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            
            
            switch this.GantryType
                case 0
                    %insert here MoveBy with AEROTECH gantry %
                case 1
                    switch axis
                        case this.X
                            SetVelocity(this.GantryObj,this.xAxis,velocity);
                            ToPoint(this.GantryObj,this.Relative,this.xAxis,delta);
                        case this.Y
                            SetVelocity(this.GantryObj,this.yAxis,velocity);
                            ToPoint(this.GantryObj,this.Relative,this.yAxis,delta);
                        case this.Z1
                            SetVelocity(this.GantryObj,this.z1Axis,velocity);
                            ToPoint(this.GantryObj,this.Relative,this.z1Axis,delta);
                        case this.Z2
                            SetVelocity(this.GantryObj,this.z2Axis,velocity);
                            ToPoint(this.GantryObj,this.Relative,this.z2Axis,delta);
                        case this.U
                            SetVelocity(this.GantryObj,this.uAxis,velocity);
                            ToPoint(this.GantryObj,this.Relative,this.uAxis,delta);
                    end
                    if wait > 0
                        this.WaitForMotion(axis, this.DefaultTimeOut);
                    end
            end
        end
        
        %% SetAcc%%
        function  SetAcc(this,axis,acceleration)
            % function  SetAcc(this,axis,acceleration)
            % Arguments: object ALIO (this),axis int, acceleration double%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here SetAcc with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            SetAcceleration(this.GantryObj,this.xAxis,acceleration);
                        case 1
                            SetAcceleration(this.GantryObj,this.yAxis,acceleration);
                        case 4
                            SetAcceleration(this.GantryObj,this.z1Axis,acceleration);
                        case 5
                            SetAcceleration(this.GantryObj,this.z2Axis,acceleration);
                        case 6
                            SetAcceleration(this.GantryObj,this.uAxis,acceleration);
                    end
            end
        end
        
        
        %% MotorEnable %% Enable 1 motor %%
        
        function  MotorEnable(this,axis)
            % function  MotorEnable(this,axis)
            % Arguments: object ALIO (this), axis int%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotorEnable with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            Enable(this.GantryObj,this.xAxis);
                        case 1
                            Enable(this.GantryObj,this.yAxis);
                        case 4
                            Enable(this.GantryObj,this.z1Axis);
                        case 5
                            Enable(this.GantryObj,this.z2Axis);
                        case 6
                            Enable(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        %% MotorEnableS %% Enable all motors
        
        function  MotorEnableAll(this)
            % function  MotorEnableAll(this)
            % Arguments: object ALIO (this), axis int array%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotorEnableS with AEROTECH gantry %
                case 1
                    Enable(this.GantryObj,this.xAxis);
                    Enable(this.GantryObj,this.yAxis);
                    Enable(this.GantryObj,this.z1Axis);
                    Enable(this.GantryObj,this.z2Axis);
                    Enable(this.GantryObj,this.uAxis);
            end
        end
        %% MotorDisable %% Disable 1 motor
        
        function  MotorDisable(this,axis)
            %function  MotorDisable(this,axis)
            % Arguments: object ALIO (this), axis int,%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotorDisable with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            Disable(this.GantryObj,this.xAxis);
                        case 1
                            Disable(this.GantryObj,this.yAxis);
                        case 4
                            Disable(this.GantryObj,this.z1Axis);
                        case 5
                            Disable(this.GantryObj,this.z2Axis);
                        case 6
                            Disable(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        
        %% MotorDisableAll %% Disable all motor
        
        function  MotorDisableAll(this)
            %function  MotorDisableAll(this)
            % Arguments: object ALIO (this), axis int,%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotorDisableAll with AEROTECH gantry %
                case 1
                    DisableAll(this.GantryObj);
                    disp('Motors have been disabled')
            end
        end
        
        
        %% WaitForMotion %% wait until movement is complete%%
        
        function  WaitForMotion(this,axis,time)
            %function  WaitForMotion(this,axis,time)
            % Arguments: object ALIO (this), axis int,time inn (if -1, wait infinite)%
            % Returns: none %
            
            switch nargin
                case 3
                    
                case 2
                    time = this.DefaultTimeOut;
                otherwise
                    disp('Improper number of arguments ');
                    return
            end
            
            switch this.GantryType
                case 0
                    %insert here WaitForMotion with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            WaitMotionEnd(this.GantryObj,this.xAxis,time);
                        case 1
                            WaitMotionEnd(this.GantryObj,this.yAxis,time);
                        case 4
                            WaitMotionEnd(this.GantryObj,this.z1Axis,time);
                        case 5
                            WaitMotionEnd(this.GantryObj,this.z2Axis,time);
                        case 6
                            WaitMotionEnd(this.GantryObj,this.uAxis,time);
                    end
            end
        end
        
        function  WaitForMotionAll(this,time)
            %function  WaitForMotionAll(this,axis,time)
            % Arguments: object ALIO (this),time inn (if -1, wait infinite)%
            % Returns: none %
            
            switch nargin
                case 2
                    
                case 1
                    time = this.DefaultTimeOut;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            
            switch this.GantryType
                case 0
                    %insert here WaitForMotion with AEROTECH gantry %
                case 1
                    WaitMotionEnd(this.GantryObj,this.xAxis,time);
                    WaitMotionEnd(this.GantryObj,this.yAxis,time);
                    WaitMotionEnd(this.GantryObj,this.z1Axis,time);
                    WaitMotionEnd(this.GantryObj,this.z2Axis,time);
                    WaitMotionEnd(this.GantryObj,this.uAxis,time);
            end
        end
        
        
        %% MotionStop %%
        function  MotionStop(this,axis)
            %function  MotionAbort(this,axis)
            % stop motion with full decceleration profile
            % Arguments: object ALIO (this),int Axis%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            Halt(this.GantryObj,this.xAxis);
                        case 1
                            Halt(this.GantryObj,this.yAxis);
                        case 4
                            Halt(this.GantryObj,this.z1Axis);
                        case 5
                            Halt(this.GantryObj,this.z2Axis);
                        case 6
                            Halt(this.GantryObj,this.uAxis);
                    end
            end
            
        end
        
        %% MotionAbort %%
        function  MotionAbort(this,axis)
            %function  MotionAbort(this,axis)
            % stop motion with reduced decceleration profile
            % Arguments: object ALIO (this),array int Axes%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    
                    n=length(axis);
                    if n>1
                        KillAll(this.GantryObj);
                    else
                        switch axis
                            case 0
                                Kill(this.GantryObj,this.xAxis);
                            case 1
                                Kill(this.GantryObj,this.yAxis);
                            case 4
                                Kill(this.GantryObj,this.z1Axis);
                            case 5
                                Kill(this.GantryObj,this.z2Axis);
                            case 6
                                Kill(this.GantryObj,this.uAxis);
                        end
                    end
            end
        end
        
        %% MotionAbortAll %%
        function  MotionAbortAll(this)
            %function  MotionAbortAll(this)
            % stop all motion with reduced decceleration profile
            % Arguments: object ALIO (this)%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    KillAll(this.GantryObj);
            end
        end
        
        
        %% FreeRunX %%
        
        function  FreeRunX(this,velocity)
            %function  FreeRunX(this,velocity)
            % Arguments: object ALIO (this),double velocity%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    Jog(this.GantryObj,this.JogVFlag,this.xAxis,velocity);
            end
        end
        
        %% FreeRunY %%
        
        function  FreeRunY(this,velocity)
            %function  FreeRunY(this,velocity)
            % Arguments: object ALIO (this),double velocity%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    Jog(this.GantryObj,this.JogVFlag,this.yAxis,velocity);
            end
        end
        
        %% FreeRunZ1 %%
        
        function  FreeRunZ1(this,velocity)
            %function  FreeRunZ1(this,velocity)
            % Arguments: object ALIO (this),double velocity%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    Jog(this.GantryObj,this.JogVFlag,this.z1Axis,velocity);
            end
        end
        
        %% FreeRunZ2 %%
        
        function  FreeRunZ2(this,velocity)
            %function  FreeRunZ2(this,velocity)
            % Arguments: object ALIO (this),double velocity%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    Jog(this.GantryObj,this.JogVFlag,this.z2Axis,velocity);
            end
        end
        
        %% FreeRunU %%
        
        function  FreeRunU(this,velocity)
            %function  FreeRunU(this,velocity)
            % Arguments: object ALIO (this),double velocity%
            % Returns: none %
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    Jog(this.GantryObj,this.JogVFlag,this.uAxis,velocity);
            end
        end
        
        %% MotorState %%
        
        function  State=MotorState(this,axis)
            %The method retrieves the current motor state.
            %function  MotorState(this,axis)
            % Arguments: object ALIO (this),int Axis%
            % Returns: array with the current state of the motor %
            %ACSC_MST_ENABLE 0x00000001 - a motor is enabled
            %ACSC_MST_INPOS 0x00000010 - a motor has reached a target position
            %ACSC_MST_MOVE 0x00000020 - a motor is moving
            %ACSC_MST_ACC 0x00000040 - a motor is accelerating
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            State=GetMotorState(this.GantryObj,this.xAxis);
                        case 1
                            State=GetMotorState(this.GantryObj,this.yAxis);
                        case 4
                            State=GetMotorState(this.GantryObj,this.z1Axis);
                        case 5
                            State=GetMotorState(this.GantryObj,this.z2Axis);
                        case 6
                            State=GetMotorState(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        %% AxisState %%
        
        function  State=AxisState(this,axis)
            %The method retrieves the current axis state.
            %function  MotorState(this,axis)
            % Arguments: object ALIO (this),int Axis%
            % Returns: array with the current state of the motor %
            %         ACSC_NONE 0 Disables all axis state flags
            %         ACSC_ALL -1 Enables all axis state flags
            %         ACSC_AST_LEAD 0x00000001 Axis is leading in a group.
            %         ACSC_AST_DC 0x00000002 Axis data collection is in progress.
            %         ACSC_AST_PEG 0x00000004 PEG for the specified axis is in progress.
            %         ACSC_AST_MOVE 0x00000020 Axis is moving.
            %         ACSC_AST_ACC 0x00000040 Axis is accelerating.
            %         ACSC_AST_VELLOCK 0x00000100Slave motion for the specified axis is synchronized tomaster in velocity lock mode.
            %         ACSC_AST_POSLOCK 0x00000200Slave motion for the specified axis is synchronized tomaster in position lock mode.
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    switch axis
                        case 0
                            State=GetAxisState(this.GantryObj,this.xAxis);
                        case 1
                            State=GetAxisState(this.GantryObj,this.yAxis);
                        case 4
                            State=GetAxisState(this.GantryObj,this.z1Axis);
                        case 5
                            State=GetAxisState(this.GantryObj,this.z2Axis);
                        case 6
                            State=GetAxisState(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        %% Moving improvements %%
        
        function zSecurityPosition(this)
            % function zSecurityPosition (this)
            % Arguments: none
            % Return: none
            % 1- Move all Z axis to the defined safe height
            % 2- Wait until movement finishes
            
            if (this.GetPosition(this.Z1) <= this.zSecureHeigh)
                this.MoveTo(this.Z1, this.zSecureHeigh,this.zHighSpeed);
            end
            if (this.GetPosition(this.Z2) <= this.zSecureHeigh)
                this.MoveTo(this.Z2, this.zSecureHeigh,this.zHighSpeed);
            end
            this.WaitForMotionAll(this.DefaultTimeOut);
        end
        
        function MoveToFast(this, X, Y, wait)
            % function MoveToFast (this, X, Y)
            % Arguments: X double, Y double, wait int
            % (0-> Wait until movement finishes, 1-> No wait
            % Return: none
            % Operation:   1- Move all Z axis to a safe height and wait finished
            %              2- Then move X and Y axis to the desired zone
            
            switch nargin
                case 4
                    
                case 3
                    wait = 0;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            
            this.zSecurityPosition();
            this.MoveTo(this.X, X, this.xyHighSpeed);
            this.MoveTo(this.Y, Y, this.xyHighSpeed);
            if wait == 1
                this.WaitForMotionAll();
            end
        end
    end
end






