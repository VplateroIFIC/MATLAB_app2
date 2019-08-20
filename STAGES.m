

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
     
     
     GantryType;
   
     % valencia properties %
     
     xAxis;
     yAxis;
     z1Axis;
     z2Axis;
     uAxis;
     motorX;
     MotorY;
     MotorZ1;
     MotorZ2;
     HomeVelocity;
     Acceleration;
     Absolute;
     Relative;
     IsConnected=0;
     GantryObj;
     jogVFlag;
     
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
                %insert here properties setting foe AEROTECH gantry %
                case 2
                 this.GantryType=1;   
                NET.addAssembly('D:\Code\MATLAB_app\ACS.SPiiPlusNET.dll'); %loading .NET assembly
                this.GantryObj=ACS.SPiiPlusNET.Api;
                
                 this.xAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_0;
                 this.yAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_1;
                 this.z1Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_4;
                 this.z2Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_5;
                 this.uAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_6;
                 this.HomeVelocity=15;
                 this.Acceleration=20;
                 this.Relative=ACS.SPiiPlusNET.MotionFlags.ACSC_AMF_RELATIVE;
                 this.Absolute=ACS.SPiiPlusNET.MotionFlags.ACSC_NONE;
                 this.jogVFlag=ACS.SPiiPlusNET.MotionFlags.ACSC_AMF_VELOCITY;

            end
        end

        %% Connect  %%
       
        function  this = Connect(this)
        % function  this = Connect(this)   
        % Arguments: object STAGES %
        % Returns: none %
            switch this.GantryType
                case 0
                %insert here connection con AEROTECH gantry %
                case 1
                Port = 701;
                Address=("10.0.0.100");  
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
                %insert here disconnection with AEROTECH gantry %
                case 1
                CloseComm(this.GantryObj); 
                this.IsConnected=0;
            end
        end
        
        
         %% GetPosition. %%
        
        function  value = GetPosition(this,axis) 
        % function  value = GetPosition(this,axis)   
        % Arguments: object ALIO (this),axis int%
        % Returns: double %
            switch this.GantryType
                case 0
                %insert here getPosition with AEROTECH gantry %
                case 1
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
        function  MoveTo(this,axis,target,velocity)
        % function  MoveTo(this,axis,target,velocity)
        % Arguments: object ALIO (this), axis int, target double, velocity double%
        % Returns: none % 
           switch this.GantryType
                case 0
                   %insert here MoveTo with AEROTECH gantry % 
                case 1
            switch axis
               case 0
                 SetVelocity(this.GantryObj,this.xAxis,velocity); 
                 ToPoint(this.GantryObj,this.Absolute,this.xAxis,target);
               case 1
                 SetVelocity(this.GantryObj,this.yAxis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.yAxis,target);
               case 4
                 SetVelocity(this.GantryObj,this.z1Axis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.z1Axis,target);
               case 5
                 SetVelocity(this.GantryObj,this.z2Axis,velocity);  
                 ToPoint(this.GantryObj,this.Absolute,this.z2Axis,target);  
               case 6
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
               case 0
                 SetVelocity(this.GantryObj,this.xAxis,velocity); 
                 ToPoint(this.GantryObj,this.Relative,this.xAxis,delta);
               case 1
                 SetVelocity(this.GantryObj,this.yAxis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.yAxis,delta);
               case 4
                 SetVelocity(this.GantryObj,this.z1Axis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.z1Axis,delta);  
               case 5
                 SetVelocity(this.GantryObj,this.z2Axis,velocity);  
                 ToPoint(this.GantryObj,this.Relative,this.z2Axis,delta);   
               case 6
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
         %% FreeRunX %%
         
        function  FreeRunX(this,velocity)
        %function  FreeRunX(this,velocity)    
        % Arguments: object ALIO (this),double velocity%
        % Returns: none % 
        Jog(this.GantryObj,this.JogVFlag,this.xAxis,velocity);
        end
        
        %% FreeRunY %%
         
        function  FreeRunY(this,velocity)
        %function  FreeRunY(this,velocity)    
        % Arguments: object ALIO (this),double velocity%
        % Returns: none % 
        Jog(this.GantryObj,this.JogVFlag,this.yAxis,velocity);
        end
        
        %% FreeRunZ1 %%
         
        function  FreeRunZ1(this,velocity)
        %function  FreeRunZ1(this,velocity)    
        % Arguments: object ALIO (this),double velocity%
        % Returns: none % 
        Jog(this.GantryObj,this.JogVFlag,this.z1Axis,velocity);
        end
        
        %% FreeRunZ2 %%
         
        function  FreeRunZ2(this,velocity)
        %function  FreeRunZ2(this,velocity)    
        % Arguments: object ALIO (this),double velocity%
        % Returns: none % 
        Jog(this.GantryObj,this.JogVFlag,this.z2Axis,velocity);
        end
        
        %% FreeRunU %%
         
        function  FreeRunU(this,velocity)
        %function  FreeRunU(this,velocity)    
        % Arguments: object ALIO (this),double velocity%
        % Returns: none % 
        Jog(this.GantryObj,this.JogVFlag,this.uAxis,velocity);
        end  
    end
end
        
        
        
        
        
        
        