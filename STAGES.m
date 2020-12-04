

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
    
    % This class in under development, in case of bug or other question, please contact to Pablo León (pablo.leon@cern.ch)
    
    
    properties (Access=public,Constant)
        X=1;
        Y=0;
        Z1=4;
        Z2=5;
        U=6;
        
        % The order of the axes in the position vector.
        % [X,Y,null,Z1,Z2,U]
        vectorX = 1;
        vectorY = 2;
        vectorZ1 = 4;
        vectorZ2 = 5;
        vectorU = 6;
        
        %Defining movement limits to the gantry table
        % [X,Y,nan,Z1,Z2,U]
        MoveLimitsH = [500, 500, nan, 100, 100, nan]
        MoveLimitsL = [-500, -500, nan, -100, -100, nan]
    end
    
    properties (Access=protected)
        
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
        bufferNoneLabel;
        apiNoneLabel;
        
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
        IsConnected = 0;
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
                    this.bufferNoneLabel=ACS.SPiiPlusNET.ProgramBuffer.ACSC_NONE;
                    this.apiNoneLabel=ACS.SPiiPlusNET.Api.ACSC_NONE;
                    
            end
        end
        
        %% Connect  %%
        
        function  Connect(this)
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
        
        function  Disconnect(this)
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
                case this.X
                    value=GetFPosition(this.GantryObj,this.xAxis);
                case this.Y
                    value=GetFPosition(this.GantryObj,this.yAxis);
                case this.Z1
                    value=GetFPosition(this.GantryObj,this.z1Axis);
                case this.Z2
                    value=GetFPosition(this.GantryObj,this.z2Axis);
                case this.U
                    value=GetFPosition(this.GantryObj,this.uAxis);
            end
        end
        
        %% GetRPosition. %%
        
        function  value = GetRPosition(this,axis)
            % function  value = GetRposition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
            switch axis
                case this.X
                    value=GetRPosition(this.GantryObj,this.xAxis);
                case this.Y
                    value=GetRPosition(this.GantryObj,this.yAxis);
                case this.Z1
                    value=GetRPosition(this.GantryObj,this.z1Axis);
                case this.Z2
                    value=GetRPosition(this.GantryObj,this.z2Axis);
                case this.U
                    value=GetRPosition(this.GantryObj,this.uAxis);
            end
        end
        
        %% GetPosition. %%
        
        function  value = GetPosition(this,axis)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
            
            positionVector=ReadVariableAsVector(this.GantryObj,'APOS',this.bufferNoneLabel, this.apiNoneLabel, this.apiNoneLabel, this.apiNoneLabel,this.apiNoneLabel);
            % index position in positionVector array does not fit with the oficial number assigned to the stages. Take care!
            switch axis
                case this.X
                    value=positionVector(this.vectorX);
                case this.Y
                    value=positionVector(this.vectorY);
                case this.Z1
                    value=positionVector(this.vectorZ1);
                case this.Z2
                    value=positionVector(this.vectorZ2);
                case this.U
                    value=positionVector(this.vectorU);
            end
        end
        
        function  value = GetPositionAll(this)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double array (x,y,rot,z1,z2,U)%
            
            value (this.vectorX) = this.GetPosition(this.X);
            value (this.vectorY) = this.GetPosition(this.Y);
            value (3) = nan;
            value (this.vectorZ1) = this.GetPosition(this.Z1);
            value (this.vectorZ2) = this.GetPosition(this.Z2);
            value (this.vectorU) = this.GetPosition(this.U);
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
                        case this.X
                            value=GetFVelocity(this.GantryObj,this.xAxis);
                        case this.Y
                            value=GetFVelocity(this.GantryObj,this.yAxis);
                        case this.Z1
                            value=GetFVelocity(this.GantryObj,this.z1Axis);
                        case this.Z2
                            value=GetFVelocity(this.GantryObj,this.z2Axis);
                        case this.U
                            value=GetFVelocity(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        
        %% GetCurrentFeedback %%
        
        function  value = GetCurrentFeedback(this,axis)
            % function  value = GetCurrentFeedback(this,axis)
            % Arguments: object ALIO (this),axis int%
            % Returns: double %
            RMS=ReadVariable(this.GantryObj,'RMS',this.bufferNoneLabel, this.apiNoneLabel, this.apiNoneLabel, this.apiNoneLabel,this.apiNoneLabel);
            switch axis
                case this.X
                    value=RMS(this.vectorX);
%                     value=ReadVariable(this.GantryObj,'RMS',this.xAxis,this.xAxis); % if error, tray send 0 (or ACSC_NONE) after GantryObj pointer
                case this.Y
                    value=RMS(this.vectorY);
%                     value=ReadVariable(this.GantryObj,'RMS',this.yAxis,this.yAxis);
                case this.Z1
                    value=RMS(this.vectorZ1);
%                     value=ReadVariable(this.GantryObj,'RMS',this.z1Axis,this.z1Axis);
                case this.Z2
                    value=RMS(this.vectorZ2);
%                     value=ReadVariable(this.GantryObj,'RMS',this.z1Axis,this.z2Axis);
                case this.U
                    value=RMS(this.vectorU);
%                     value=ReadVariable(this.GantryObj,'RMS',this.uAxis,this.uAxis);
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
                        case this.X
                            ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.xAxis,0);
                        case this.Y
                            ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
                            WaitForMotion(this,axis,0,-1);
                            SetFPosition(this.GantryObj,this.yAxis,0);
                        case this.Z1
                            ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.z1Axis,0);
                        case this.Z2
                            ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target);
                            WaitForMotion(this,axis,-1);
                            SetFPosition(this.GantryObj,this.z2Axis,0);
                        case this.U
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
            
            if isnan(target)
                return
            end
            
            switch this.GantryType
                case 0
                    %insert here MoveTo with AEROTECH gantry %
                case 1
                    switch axis
                        case this.X
                            if target > this.MoveLimitsH(this.vectorX) || target < this.MoveLimitsL(this.vectorX)
                                fprintf ("\n\t ¡¡ Target position: %d out of gantry limmits !!\n", target);
                                return
                            end
                            SetVelocity(this.GantryObj,this.xAxis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
                        case this.Y
                            if target > this.MoveLimitsH(this.vectorY) || target < this.MoveLimitsL(this.vectorY)
                                fprintf ("\n\t ¡¡ Target position: %d out of gantry limmits !!\n", target);
                                return
                            end
                            SetVelocity(this.GantryObj,this.yAxis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
                        case this.Z1
                            if target > this.MoveLimitsH(this.vectorZ1) || target < this.MoveLimitsL(this.vectorZ1)
                                fprintf ("\n\t ¡¡ Target position: %d out of gantry limmits !!\n", target);
                                return
                            end
                            SetVelocity(this.GantryObj,this.z1Axis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target);
                        case this.Z2
                            if target > this.MoveLimitsH(this.vectorZ2) || target < this.MoveLimitsL(this.vectorZ2)
                                fprintf ("\n\t ¡¡ Target position: %d out of gantry limmits !!\n", target);
                                return
                            end
                            SetVelocity(this.GantryObj,this.z2Axis,velocity);
                            ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target);
                        case this.U
                            if target > this.MoveLimitsH(this.vectorU) || target < this.MoveLimitsL(this.vectorU)
                                fprintf ("\n\t ¡¡ Target position: %d out of gantry limmits !!\n", target);
                                return
                            end
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
            
            if delta == 0
                return;
            end
            if velocity == 0
                return;
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
                        case this.X
                            SetAcceleration(this.GantryObj,this.xAxis,acceleration);
                        case this.Y
                            SetAcceleration(this.GantryObj,this.yAxis,acceleration);
                        case this.Z1
                            SetAcceleration(this.GantryObj,this.z1Axis,acceleration);
                        case this.Z2
                            SetAcceleration(this.GantryObj,this.z2Axis,acceleration);
                        case this.U
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
                        case this.X
                            Enable(this.GantryObj,this.xAxis);
                        case this.Y
                            Enable(this.GantryObj,this.yAxis);
                        case this.Z1
                            Enable(this.GantryObj,this.z1Axis);
                        case this.Z2
                            Enable(this.GantryObj,this.z2Axis);
                        case this.U
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
                        case this.X
                            Disable(this.GantryObj,this.xAxis);
                        case this.Y
                            Disable(this.GantryObj,this.yAxis);
                        case this.Z1
                            Disable(this.GantryObj,this.z1Axis);
                        case this.Z2
                            Disable(this.GantryObj,this.z2Axis);
                        case this.U
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
                        case this.X
                            WaitMotionEnd(this.GantryObj,this.xAxis,time);
                        case this.Y
                            WaitMotionEnd(this.GantryObj,this.yAxis,time);
                        case this.Z1
                            WaitMotionEnd(this.GantryObj,this.z1Axis,time);
                        case this.Z2
                            WaitMotionEnd(this.GantryObj,this.z2Axis,time);
                        case this.U
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
                        case this.X
                            Halt(this.GantryObj,this.xAxis);
                        case this.Y
                            Halt(this.GantryObj,this.yAxis);
                        case this.Z1
                            Halt(this.GantryObj,this.z1Axis);
                        case this.Z2
                            Halt(this.GantryObj,this.z2Axis);
                        case this.U
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
                            case this.X
                                Kill(this.GantryObj,this.xAxis);
                            case this.Y
                                Kill(this.GantryObj,this.yAxis);
                            case this.Z1
                                Kill(this.GantryObj,this.z1Axis);
                            case this.Z2
                                Kill(this.GantryObj,this.z2Axis);
                            case this.U
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
            
% Trying to read and understand and compare MotorStates return
% unsatisfactory for now.
%             NET.Assembly('ACS.SPiiPlusNET.MotorStates')

 %           compare = NET.createArray('ACS.SPiiPlusNET.MotorState',3); axis.Set(0, this.xAxis); axis.Set(1, this.yAxis); axis.Set(2, this.nullAxis);  %d2 = NET.createArray('System.String',3); d2(1) = 'one'; d2(2) = 'two'; d2(3) = 'zero';
%              State = ACS.SPiiPlusNET.MotorStates.ACSC_MST_INP;
%             ACS.SPiiPlusNET.MotorState State;
%             disp (state);
%             State2 = ACS.SPiiPlusNET.MotorStates.ACSC_MST_ENABLE
            switch this.GantryType
                case 0
                    %insert here MotionAbort with AEROTECH gantry %
                case 1
                    switch axis
                        case this.X
                            State=GetMotorState(this.GantryObj,this.xAxis);
                        case this.Y
                            State=GetMotorState(this.GantryObj,this.yAxis);
                        case this.Z1
                            State=GetMotorState(this.GantryObj,this.z1Axis);
                        case this.Z2
                            State=GetMotorState(this.GantryObj,this.z2Axis);
                        case this.U
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
                        case this.X
                            State=GetAxisState(this.GantryObj,this.xAxis);
                        case this.Y
                            State=GetAxisState(this.GantryObj,this.yAxis);
                        case this.Z1
                            State=GetAxisState(this.GantryObj,this.z1Axis);
                        case this.Z2
                            State=GetAxisState(this.GantryObj,this.z2Axis);
                        case this.U
                            State=GetAxisState(this.GantryObj,this.uAxis);
                    end
            end
        end
        
        %% Moving improvements %%
        
        function zSecurityPosition(this, velocity)
            % function zSecurityPosition (this)
            % Arguments: none
            % Return: none
            % 1- Move all Z axis to the defined safe height
            % 2- Wait until movement finishes
            if nargin ==1
                velocity = this.zHighSpeed;
            end
            
            if (this.GetPosition(this.Z1) <= this.zSecureHeigh)
                this.MoveTo(this.Z1, this.zSecureHeigh,velocity);
            end
            if (this.GetPosition(this.Z2) <= this.zSecureHeigh)
                this.MoveTo(this.Z2, this.zSecureHeigh,velocity);
            end
            this.WaitForMotionAll(this.DefaultTimeOut);
        end
        
        function MoveToFast(this, X, Y, wait)
            % function MoveToFast (this, X, Y) % Old function. Use Move2Fast.
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
        
        function ip = Move2Fast(this, Position, varargin)
            % function Move2Fast (this, Position)
            % Arguments: Position double (vector or scalar)
            % Optional Arguments: Velocity, ZVelocity, Height, Wait, X, Y,
            % Z1, Z2, U
            % Optional Arguments override position and default settings
            % Return: Selected arguments
            % Operation:   1- Move all Z axis to a safe height and wait finished
            %              2- Then move to the desired Position
            
            %Check if Position is a numeric
            if ~isnumeric(Position)
                fprintf("\n\t Invalid destination: %s\n", Position)
                return
            end
            
            %Parsing variable inputs
            p = inputParser();
            p.KeepUnmatched = true;
            p.CaseSensitive = false;
            p.StructExpand  = false;
            p.PartialMatching = true;
            
            addParameter (p, 'Position' , [nan, nan, nan, nan, nan, nan])
            addParameter (p, 'Velocity' , this.xyHighSpeed)
            addParameter (p, 'ZVelocity' , this.zHighSpeed)
            addParameter (p, 'Height'   , this.zSecureHeigh)
            addParameter (p, 'Wait'     , false)
            addParameter (p, 'X'        , nan)
            addParameter (p, 'Y'        , nan)
            addParameter (p, 'Z1'       , nan)
            addParameter (p, 'Z2'       , nan)
            addParameter (p, 'U'        , nan)
            
            
            parse( p, varargin{:} )
            ip = p.Results;
            
            % Check if target position is vector or scalar
            % If target position is scalar it will be X axis

            if isscalar(Position)
                ip.Position(this.vectorX) = Position;
            else 
                check = size(Position);
                ip.Position = Position;
                if ~(check(1) == 1 && check(2) <= 6) 
                    % If position vector is larger than 1x6
                    fprintf("\n ¡¡Invalid destination!! --> %d %d %d %d %d %d\n", ip.Position)
                else
                    % Fill the position vector with nan values
                    % until size 1x6
                    ip.Position(check(2)+1:6) = nan; 
                end
            end
            
            if (~isnan(ip.X))
                ip.Position(this.vectorZ1) = ip.X;
            end
            if (~isnan(ip.Y))
                ip.Position(this.vectorY) = ip.Y;
            end
            if (~isnan(ip.Z1))
                ip.Position(this.vectorZ1) = ip.Z1;
            end
            if (~isnan(ip.Z2))
                ip.Position(this.vectorZ2) = ip.Z2;
            end
            if (~isnan(ip.U))
                ip.Position(this.vectorU) = ip.U;
            end      
 
            fprintf("\n Posicición de destino -->(%d %d %d %d %d %d)\n", ip.Position(1), ip.Position(2), ip.Position(3), ip.Position(4), ip.Position(5), ip.Position(6))
                
            this.zSecurityPosition(ip.ZVelocity);
            this.MoveTo(this.U,ip.Position(this.vectorU),ip.ZVelocity)
            this.MoveTo(this.X,ip.Position(this.vectorX),ip.Velocity)
            this.MoveTo(this.Y,ip.Position(this.vectorY),ip.Velocity)
            this.WaitForMotionAll();
            
            this.MoveTo(this.Z1,ip.Position(this.vectorZ1),this.zNominalSpeed)
            this.MoveTo(this.Z2,ip.Position(this.vectorZ2),this.zNominalSpeed)
            
            if ip.Wait 
                disp("Waiting for motion finish")
                this.WaitForMotionAll();
            end
        end
    end
end






