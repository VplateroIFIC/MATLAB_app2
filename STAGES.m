

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
% 4 --> GANTRY VANCOUVER

% GANTRY TYPE 0 --> AEROTECH
% GANTRY TYPE 1 --> ALIO

% This class in under development, in case of bug or other question, please contact to Pablo León (pablo.leon@cern.ch)


    properties (Access=private)
     
     IsConnected;
     GantryType;
     GantryObj;
     
     xAxis;
     yAxis;
     z1Axis;
     z2Axis;
     uAxis;
     
     HomeVelocity;
     Acceleration;
 
    end
    
    methods
  %% CONSTRUCTOR %%
        % Arguments: site Number %
        % Returns: object %
        function  this = STAGES(Nsite)
            switch Nsite
                case 0 || 1 || 4
                this.GantryType=0;
                %insert here properties setting foe AEROTECH gantry %
                case 3
                 this.GantryType=1;   
                    
                 this.xAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_0;
                 this.yAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_1;
                 this.z1Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_4;
                 this.z2Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_5;
                 this.uAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_6;
                 this.HomeVelocity=15;
                 this.Acceleration=20;

                NET.addAssembly('D:\Code\MATLAB_app\ACS.SPiiPlusNET.dll'); %loading .NET assembly
                this.GantryObj=ACS.SPiiPlusNET.Api;   % obj from class ACS.SPiiPlusNET.Api (where methods are)
            end
        end

        %% Connect  %%
        % Arguments: object STAGES %
        % Returns: none %
        function  Connect(this)
            switch this.GantryType
                case 0
                %insert here connection con AEROTECH gantry %
                case 1
                Port = 701;
                Address=("10.0.0.100");  
                OpenCommEthernetTCP(this.GantryObj,Address,Port); 
            end
        end
        
        %% Disconnect  %%
        % Arguments: object STAGES %
        % Returns: none %
        function  Disconnect(this)
            switch this.GantryType
                case 0
                %insert here disconnection with AEROTECH gantry %
                case 1
                CloseComm(this.GantryObj); 
            end
        end
        
        
         %% GetPosition. %%
        % Arguments: object ALIO (this),axis int%
        % Returns: double %
        function  value = GetPosition(this,axis) 
            switch this.GantryType
                case 0
                %insert here getPosition with AEROTECH gantry %
                case 1
                 switch axis
                   case 2
                     value=GetFPosition(this.gantry,this.xAxis);
                   case 0
                     value=GetFPosition(this.gantry,this.yAxis);
                   case 3
                     value=GetFPosition(this.gantry,this.z1Axis);  
                   case 4
                     value=GetFPosition(this.gantry,this.uAxis);
                 end
            end
        end

         
         %% GetVelocity %%
        % Arguments: object ALIO (this),axis int%
        % Returns: double %
        function  value = GetVelocity(this,axis) 
            switch this.GantryType
                case 0
                %insert here getVelocity with AEROTECH gantry %
                case 1
                 switch axis
                   case 2
                     value=GetFVelocity(this.gantry,this.xAxis);
                   case 0
                     value=GetFVelocity(this.gantry,this.yAxis);
                   case 3
                     value=GetFVelocity(this.gantry,this.z1Axis);  
                   case 4
                     value=GetFVelocity(this.gantry,this.uAxis);
                 end
            end
        end
        
        
          %% GetCurrentFeedback %%
        % Arguments: object ALIO (this),axis int%
        % Returns: double %
        function  value = GetCurrentFeedback(this,axis) 
            switch this.GantryType
                case 0
                %insert here GetCurrentFeedback with AEROTECH gantry %
                case 1
                 switch axis
                   case 2
                     value=ReadVariable(this.gantry,'RMS',this.xAxis,this.xAxis); % if error, tray send 0 (or ACSC_NONE) after gantry pointer
                   case 0
                     value=ReadVariable(this.gantry,'RMS',this.yAxis,this.yAxis);
                   case 3
                     value=ReadVariable(this.gantry,'RMS',this.z1Axis,this.z1Axis);  
                   case 4
                     value=ReadVariable(this.gantry,'RMS',this.uAxis,this.uAxis);
                 end
            end
        end


        
        
          %% Home %%
        % Arguments: object ALIO (this), axis int,%
        % Returns: none % 
        function  Home(this,axis)
            switch this.GantryType
                case 0
                   %insert here Home with AEROTECH gantry %
                   
                case 1
           SetVelocity(this.gantry,this.xAxis,this.homeVelocity);
           SetVelocity(this.gantry,this.yAxis,this.homeVelocity);
           SetVelocity(this.gantry,this.z1Axis,this.homeVelocity);
           SetVelocity(this.gantry,this.uAxis,this.homeVelocity);
           target=0;
            switch axis
               case 2
                 ToPoint(this.gantry,this.absolute,this.xAxis,target);
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.xAxis,0);                         
               case 0
                 ToPoint(this.gantry,this.absolute,this.yAxis,target);
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.yAxis,0);                        
               case 3
                 ToPoint(this.gantry,this.absolute,this.z1Axis,target); 
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.z1Axis,0);                        
               case 4
                 ToPoint(this.gantry,this.absolute,this.uAxis,target);
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.uAxis,0);                           
            end  
            end
        end
            
        
          %% MoveTo %% Absolute movements %%
        % Arguments: object ALIO (this), axis int, target double, velocity double%
        % Returns: none % 
        function  MoveTo(this,axis,target,velocity)
           switch this.GantryType
                case 0
                   %insert here MoveTo with AEROTECH gantry % 
                case 1
            switch axis
               case 2
                 SetVelocity(this.gantry,this.xAxis,velocity); 
                 ToPoint(this.gantry,this.xAxis,target);
               case 0
                 SetVelocity(this.gantry,this.yAxis,velocity);  
                 ToPoint(this.gantry,this.yAxis,target);
               case 3
                 SetVelocity(this.gantry,this.z1Axis,velocity);  
                 ToPoint(this.gantry,this.z1Axis,target);  
               case 4
                 SetVelocity(this.gantry,this.uAxis,velocity);  
                 ToPoint(this.gantry,this.uAxis,target);
            end  
           end
        end
        
        
           %% MoveBy %% Relative movement %%
        % Arguments: object ALIO (this), axis int, delta double, velocity double%
        % Returns: none % 
        function  MoveBy(this,axis,delta,velocity)
             switch this.GantryType
                case 0
                   %insert here MoveBy with AEROTECH gantry % 
                case 1
            switch axis
               case 2
                 SetVelocity(this.gantry,this.xAxis,velocity); 
                 ToPoint(this.gantry,this.relative,this.xAxis,delta);
               case 0
                 SetVelocity(this.gantry,this.yAxis,velocity);  
                 ToPoint(this.gantry,this.relative,this.yAxis,delta);
               case 3
                 SetVelocity(this.gantry,this.z1Axis,velocity);  
                 ToPoint(this.gantry,this.relative,this.z1Axis,delta);  
               case 4
                 SetVelocity(this.gantry,this.uAxis,velocity);  
                 ToPoint(this.gantry,this.relative,this.uAxis,delta);
             end  
            end
        end
        
          %% SetAcc%%
        % Arguments: object ALIO (this),axis int, acceleration double%
        % Returns: none % 
        function  SetAcc(this,axis,acceleration)
            switch this.GantryType
                case 0
                   %insert here SetAcc with AEROTECH gantry % 
                case 1
              switch axis
               case 2
                 SetAcceleration(this.gantry,this.xAxis,acceleration); 
               case 0
                 SetAcceleration(this.gantry,this.yAxis,acceleration);  
               case 3
                 SetAcceleration(this.gantry,this.z1Axis,acceleration);  
               case 4
                 SetAcceleration(this.gantry,this.uAxis,acceleration);  
               end 
            end
        end
        
        
          %% MotorEnable %% Enable 1 motor %%
        % Arguments: object ALIO (this), axis int%
        % Returns: none % 
        function  MotorEnable(this,axis)
           switch this.GantryType
                case 0
                   %insert here MotorEnable with AEROTECH gantry % 
                case 1
            switch axis
               case 2
                 Enable(this.gantry,this.xAxis);
               case 0
                 Enable(this.gantry,this.yAxis);
               case 3
                 Enable(this.gantry,this.z1Axis);  
               case 4
                 Enable(this.gantry,this.uAxis);
            end
           end
        end
        
                 %% MotorEnableS %% Enable several motors
        % Arguments: object ALIO (this), axis int array%
        % Returns: none % 
        function  MotorEnableS(this,axis)
           switch this.GantryType
                case 0
                   %insert here MotorEnableS with AEROTECH gantry % 
                case 1
            switch axis
               case 2
                 Enable(this.gantry,this.xAxis);
               case 0
                 Enable(this.gantry,this.yAxis);
               case 3
                 Enable(this.gantry,this.z1Axis);  
               case 4
                 Enable(this.gantry,this.uAxis);
            end
           end
        end

           %% MotorDisable %% Disable 1 motor
        % Arguments: object ALIO (this), axis int,%
        % Returns: none % 
        
        function  MotorDisable(this,axis)
           switch this.GantryType
                case 0
                   %insert here MotorDisable with AEROTECH gantry % 
                case 1
             switch axis
               case 2
                 Disable(this.gantry,this.xAxis);
               case 0
                 Disable(this.gantry,this.yAxis);
               case 3
                 Disable(this.gantry,this.z1Axis);  
               case 4
                 Disable(this.gantry,this.uAxis);
              end
            end
        end
        
        
              %% MotorDisableAll %% Disable all motor
        % Arguments: object ALIO (this), axis int,%
        % Returns: none % 
        
        function  MotorDisableAll(this,axis)
            switch this.GantryType
                case 0
                   %insert here MotorDisableAll with AEROTECH gantry % 
                case 1
             switch axis
               case 2
                 DisableAll(this.gantry,this.xAxis);
               case 0
                 DisableAll(this.gantry,this.yAxis);
               case 3
                 DisableAll(this.gantry,this.z1Axis);  
               case 4
                 DisableAll(this.gantry,this.uAxis);
             end  
            end
        end

        
        %% WaitForMotion %% wait until movement is complete%%
        % Arguments: object ALIO (this), axis int,time inn (if -1, wait infinite)%
        % Returns: none % 
        
        function  WaitForMotion(this,axis,time)
            switch this.GantryType
                case 0
                   %insert here WaitForMotion with AEROTECH gantry % 
                case 1
              switch axis
               case 2
                 WaitMotionEnd(this.gantry,this.xAxis,time);
               case 0
                 WaitMotionEnd(this.gantry,this.yAxis,time);
               case 3
                 WaitMotionEnd(this.gantry,this.z1Axis,time);  
               case 4
                 WaitMotionEnd(this.gantry,this.uAxis,time);
              end 
            end 
        end  

       %% MotionAbort %%
        % Arguments: object ALIO (this),array int Axes%
        % Returns: none %
        function  MotionAbort(this,axis)
           switch this.GantryType
                case 0
                   %insert here MotionAbort with AEROTECH gantry % 
                case 1
            
            n=length(axis);
            if n>1
            KillAll(this.gantry);
            else
              switch axis
               case 2
                 Kill(this.gantry,this.xAxis);
               case 0
                 Kill(this.gantry,this.yAxis);
               case 3
                 Kill(this.gantry,this.z1Axis);  
               case 4
                 Kill(this.gantry,this.uAxis);
              end 
            end
            end

        end
        end

end
        
        
        
        
        
        
        