

classdef STAGES
    
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


    properties (Access=private)
     
   % General Properties %
        
     GantryType;
     xAxis;
     yAxis;
     z1Axis;
     z2Axis;
     uAxis;
    
    % ALIO properties %
     
     motorX;
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
                 NET.addAssembly('D:\Code\MATLAB_app\ACS.SPiiPlusNET.dll'); %loading .NET assembly
                 this.xAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_0;
                 this.yAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_1;
                 this.z1Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_4;
                 this.z2Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_5;
                 this.uAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_6;
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
        
          %% getting assembly info in display (just for ALIO gantry) %%
        
          function  AssemblyMethodsInfo(this)
        % function  this = Disconnect(this)
        % Arguments: object STAGES %
        % Returns: none %
           methodsview('ACS.SPiiPlusNET.Api');
         end   
        
        
        
         %% GetPosition. %%
        
        function  value = GetPosition(this,axis) 
        % function  value = GetPosition(this,axis)   
        % Arguments: object STAGES (this),axis int ()%
        % Returns: double %
            switch this.GantryType
                case 0
                switch axis
                   case 0
                     value=GetFPosition(this.GantryObj,this.xAxis);
                   case 1
                     value=GetFPosition(this.GantryObj,this.yAxis);
                   case 4
                     value=GetFPosition(this.GantryObj,this.z1Axis); 
                   case 5
                     value=GetFPosition(this.GantryObj,this.uAxis);   
                 end
                case 1
                 switch axis
                   case this.xAxis
                     value=GetFPosition(this.GantryObj,this.xAxis);
                   case this.yAxis
                     value=GetFPosition(this.GantryObj,this.yAxis);
                   case this.z1Axis
                     value=GetFPosition(this.GantryObj,this.z1Axis); 
                   case this.z2Axis
                     value=GetFPosition(this.GantryObj,this.z2Axis);   
                   case this.uAxis
                     value=GetFPosition(this.GantryObj,this.uAxis);
                 end
            end
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
                   case this.xAxis
                     value=GetFVelocity(this.GantryObj,this.xAxis);
                   case this.yAxis
                     value=GetFVelocity(this.GantryObj,this.yAxis);
                   case this.z1Axis
                     value=GetFVelocity(this.GantryObj,this.z1Axis);
                   case this.z2Axis
                     value=GetFVelocity(this.GantryObj,this.z2Axis);
                   case this.uAxis
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
                   case this.xAxis
                     value=ReadVariable(this.GantryObj,'RMS',this.xAxis,this.xAxis); % if error, tray send 0 (or ACSC_NONE) after GantryObj pointer
                   case this.yAxis
                     value=ReadVariable(this.GantryObj,'RMS',this.yAxis,this.yAxis);
                   case this.z1Axis
                     value=ReadVariable(this.GantryObj,'RMS',this.z1Axis,this.z1Axis); 
                   case this.z2Axis
                     value=ReadVariable(this.GantryObj,'RMS',this.z1Axis,this.z2Axis);  
                   case this.uAxis
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
               case this.xAxis
                 ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
                 WaitForMotion(this,axis,-1);
                 SetFPosition(this.GantryObj,this.xAxis,0);                         
               case this.yAxis
                 ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
                 WaitForMotion(this,axis,0,-1);
                 SetFPosition(this.GantryObj,this.yAxis,0);                        
               case this.z1Axis
                 ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target); 
                 WaitForMotion(this,axis,-1);
                 SetFPosition(this.GantryObj,this.z1Axis,0);   
               case this.z2Axis
                 ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target); 
                 WaitForMotion(this,axis,-1);
                 SetFPosition(this.GantryObj,this.z2Axis,0);  
               case this.uAxis
                 ToPoint(this.GantryObj,this.Absolute,this.uAxis,target);
                 WaitForMotion(this,axis,-1);
                 SetFPosition(this.GantryObj,this.uAxis,0);                           
            end  
            end
        end
            
        
          %% MoveTo %% Absolute movements %%
        function  MoveTo(this,axis,target,velocity)
        % function  MoveTo(this,axis,target,velocity)
        % Arguments: object ALIO (this), axis int, target double, velocity double%
        % Returns: none % 
           switch this.GantryType
                case 0
                   %insert here MoveTo with AEROTECH gantry % 
                case 1
            switch axis
               case this.xAxis
                 SetVelocity(this.GantryObj,this.xAxis,velocity); 
                 ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
               case this.yAxis
                 SetVelocity(this.GantryObj,this.yAxis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
               case this.z1Axis
                 SetVelocity(this.GantryObj,this.z1Axis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target);
               case this.z2Axis
                 SetVelocity(this.GantryObj,this.z2Axis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target);  
               case this.uAxis
                 SetVelocity(this.GantryObj,this.uAxis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.uAxis,target);
            end  
           end
        end
        
        
           %% MoveBy %% Relative movement %%
       
        function  MoveBy(this,axis,delta,velocity)
        % function  MoveBy(this,axis,delta,velocity)
        % Arguments: object ALIO (this), axis int, delta double, velocity double%
        % Returns: none % 
             switch this.GantryType
                case 0
                   %insert here MoveBy with AEROTECH gantry % 
                case 1
            switch axis
               case this.xAxis
                 SetVelocity(this.GantryObj,this.xAxis,velocity); 
                 ToPoint(this.GantryObj,this.Relative,this.xAxis,delta);
               case this.yAxis
                 SetVelocity(this.GantryObj,this.yAxis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.yAxis,delta);
               case this.z1Axis
                 SetVelocity(this.GantryObj,this.z1Axis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.z1Axis,delta);  
               case this.z2Axis
                 SetVelocity(this.GantryObj,this.z2Axis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.z2Axis,delta);   
               case this.uAxis
                 SetVelocity(this.GantryObj,this.uAxis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.uAxis,delta);
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
               case this.xAxis
                 SetAcceleration(this.GantryObj,this.xAxis,acceleration); 
               case this.yAxis
                 SetAcceleration(this.GantryObj,this.yAxis,acceleration);  
               case this.z1Axis
                 SetAcceleration(this.GantryObj,this.z1Axis,acceleration);  
               case this.z2Axis
                 SetAcceleration(this.GantryObj,this.z2Axis,acceleration);  
               case this.uAxis
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
               case this.xAxis
                 Enable(this.GantryObj,this.xAxis);
               case this.yAxis
                 Enable(this.GantryObj,this.yAxis);
               case this.z1Axis
                 Enable(this.GantryObj,this.z1Axis);
               case this.z2Axis
                 Enable(this.GantryObj,this.z2Axis);  
               case this.uAxis
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
               case this.xAxis
                 Disable(this.GantryObj,this.xAxis);
               case this.yAxis
                 Disable(this.GantryObj,this.yAxis);
               case this.z1Axis
                 Disable(this.GantryObj,this.z1Axis);  
               case this.z2Axis
                 Disable(this.GantryObj,this.z2Axis);   
               case this.uAxis
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
            switch this.GantryType
                case 0
                   %insert here WaitForMotion with AEROTECH gantry % 
                case 1
              switch axis
               case this.xAxis
                 WaitMotionEnd(this.GantryObj,this.xAxis,time);
               case this.yAxis
                 WaitMotionEnd(this.GantryObj,this.yAxis,time);
               case this.z1Axis
                 WaitMotionEnd(this.GantryObj,this.z1Axis,time);
               case this.z2Axis
                 WaitMotionEnd(this.GantryObj,this.z2Axis,time);  
               case this.uAxis
                 WaitMotionEnd(this.GantryObj,this.uAxis,time);
              end 
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
               case this.xAxis
                 Halt(this.GantryObj,this.xAxis);
               case this.yAxis
                 Halt(this.GantryObj,this.yAxis);
               case this.z1Axis
                 Halt(this.GantryObj,this.z1Axis);  
               case this.z2Axis
                 Halt(this.GantryObj,this.z2Axis);  
               case this.uAxis
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
               case this.xAxis
                 Kill(this.GantryObj,this.xAxis);
               case this.yAxis
                 Kill(this.GantryObj,this.yAxis);
               case this.z1Axis
                 Kill(this.GantryObj,this.z1Axis);  
               case this.z2Axis
                 Kill(this.GantryObj,this.z2Axis);  
               case this.uAxis
                 Kill(this.GantryObj,this.uAxis);
              end 
            end
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
               case this.xAxis
                 State=GetMotorState(this.GantryObj,this.xAxis);
               case this.yAxis
                 State=GetMotorState(this.GantryObj,this.yAxis);
               case this.z1Axis
                 State=GetMotorState(this.GantryObj,this.z1Axis);
               case this.z2Axis
                 State=GetMotorState(this.GantryObj,this.z2Axis);  
               case this.uAxis
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
               case this.xAxis
                 State=GetAxisState(this.GantryObj,this.xAxis);
               case this.yAxis
                 State=GetAxisState(this.GantryObj,this.yAxis);
               case this.z1Axis
                 State=GetAxisState(this.GantryObj,this.z1Axis);
               case this.z2Axis
                 State=GetAxisState(this.GantryObj,this.z2Axis);  
               case this.uAxis
                 State=GetAxisState(this.GantryObj,this.uAxis);
         end
         end 
        end
        
         
    end
end
        
        
        
        
        
        
        