%% CLASS TO USE VANCOUVER MATLAB APP WITH VALENCIA GANTRY %%



% File with set of functions used to adapt the Matlab app made in Vancouver be used by ALIO Gantry %
% Please, in order to add this set of fucntions follow the instructions in aero2alio.txt file %


classdef ALIO
    
    properties (Access=private)
     
     debug=0;
     IsConnected;   
     % loading the NET assembly (pointer to de library) %
     assembly = NET.addAssembly('D:\Code\MATLAB_app\ACS.SPiiPlusNET.dll');
     %methodsview('ACS.SPiiPlusNET.Api'); % sacar por pantalla la información de los métodos
     gantry=ACS.SPiiPlusNET.Api;  % objeto que representa al gantry (ACS.SPiiPlusNET.Api)
  
     
     xAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_0;
     yAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_1;
     z1Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_4;
     z2Axis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_5;
     uAxis=ACS.SPiiPlusNET.Axis.ACSC_AXIS_6;
     
     PositionFeedback=1;  % label for StatusGetItem fuction properties
     VelocityFeedback=2;
     CurrentFeedbackAverage=3;
     % FLAGS %
     
     relative=ACS.SPiiPlusNET.MotionFlags.ACSC_AMF_RELATIVE;
     absolute=ACS.SPiiPlusNET.MotionFlags.ACSC_NONE;
     
     homeVelocity=15;
     
    end
    
    methods
        
        %% Connect function. Original name A3200Connect. Used to open comunication with Gantry%%
        % Arguments: object ASCS %
        % Returns: pointer to the gantry %
        function  ASCSConnect(this)
            Port = 701;
            Address=("10.0.0.100");
            OpenCommEthernetTCP(this.gantry,Address,Port); 
            this.gantry;
            this.IsConnected=1;
%             if(gantry.debug)
%             sprintf('gantry pointer:\n');
%             disp(gantry)
%             end
        end
        
        %% Disconnect function. Original name A3200Disconnect. close the communication %%
        % Arguments: none %
        % Returns: none %
        function  ASCSDisconnect(this)
            CloseComm(this.gantry); 
%             if(gantry.debug)
%             sprintf('gantry pointer:\n');
%             disp(gantry)
%             end
        end

            
        %% StatusGetItem. Original name A3200StatusGetItem. Get different proterties of the gantry%%
        % Arguments: object ALIO (this),axis int, property, int (unused)%
        % Returns: double %
           function  value = ASCSStatusGetItem(this,axis,property) 
            switch property
                case this.PositionFeedback
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
                 case this.VelocityFeedback
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
                   case this.CurrentFeedback
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
            
          %% MotionAdvancedHomeAsync. Original name A3200MotionAdvancedHomeAsync. Home the selected axis%%
        % Arguments: object ALIO (this),task int (unused), axis int,%
        % Returns: none % 
        function  ASCSMotionAdvancedHomeAsync(this,axis)
           SetVelocity(this.gantry,this.xAxis,this.homeVelocity);
           SetVelocity(this.gantry,this.yAxis,this.homeVelocity);
           SetVelocity(this.gantry,this.z1Axis,this.homeVelocity);
           SetVelocity(this.gantry,this.uAxis,this.homeVelocity);
           target=0;
            switch axis
               case 2
                 ToPoint(this.gantry,this.absolute,this.xAxis,target);
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.xAxis,0);                          %pongo la coordenada del eje a 0 una vez ha hecho casa
               case 0
                 ToPoint(this.gantry,this.absolute,this.yAxis,target);
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.yAxis,0);                          %pongo la coordenada del eje a 0 una vez ha hecho casa
               case 3
                 ToPoint(this.gantry,this.absolute,this.z1Axis,target); 
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.z1Axis,0);                         %pongo la coordenada del eje a 0 una vez ha hecho casa
               case 4
                 ToPoint(this.gantry,this.absolute,this.uAxis,target);
                 MotionWaitForMotionDone(this,axis,0,-1);
                 SetFPosition(this.gantry,this.uAxis,0);                           %pongo la coordenada del eje a 0 una vez ha hecho casa
            end  
        end
            
        
          %% MotionMoveAbs. Original name A3200MotionMoveAbs. Absolute movement%%
        % Arguments: object ALIO (this),task int (unused), axis int, target double, velocity double%
        % Returns: none % 
        function  ASCSMotionMoveAbs(this,axis,target,velocity)
            switch axis
               case 2
                 SetVelocity(this.gantry,this.xAxis,velocity); 
                 ToPoint(this.gantry,this.absolute,this.xAxis,target);
               case 0
                 SetVelocity(this.gantry,this.yAxis,velocity);  
                 ToPoint(this.gantry,this.absolute,this.yAxis,target);
               case 3
                 SetVelocity(this.gantry,this.z1Axis,velocity);  
                 ToPoint(this.gantry,this.absolute,this.z1Axis,target);  
               case 4
                 SetVelocity(this.gantry,this.uAxis,velocity);  
                 ToPoint(this.gantry,this.absolute,this.uAxis,target);
            end  
        end
        
        
           %% MotionMoveInc. Original name A3200MotionMoveInc. Relative movement%%
        % Arguments: object ALIO (this),task int (unused), axis int, delta double, velocity double%
        % Returns: none % 
        function  ASCSMotionMoveInc(this,axis,delta,velocity)
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
        
          %% MotionSetupRampTimeAxis. Original name A3200MotionSetupRampTimeAxis. Set acceleration of the movement ramp%%
        % Arguments: object ALIO (this),task int (unused), axis int, acceleration double%
        % Returns: none % 
        function  ASCSMotionSetupRampTimeAxis(this,axis,acceleration)
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
        
        
          %% MotionEnable. Original name A3200MotionEnable. Enable motor axis%%
        % Arguments: object ALIO (this),task int (unused), axis int,%
        % Returns: none % 
        function  ASCSMotionEnable(this,axis)
            n=length(axis);
            for i=1:n
            switch axis(i)
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
        
           %% MotionDisable. Original name A3200MotionDisable. Disable motor axis%%
        % Arguments: object ALIO (this),task int (unused), axis int,%
        % Returns: none % 
        
        function  ASCSMotionDisable(this,axis)
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
        

        
                 %% MotionWaitForMotionDone. Original name A3200MotionWaitForMotionDone. wait until movement is complete%%
        % Arguments: object ALIO (this), axis int,inposition label(unused),time inn (if -1, wait infinite)%
        % Returns: none % 
        
        function  ASCSMotionWaitForMotionDone(this,axis,time)
            n=length(axis);
            for i=1:n
            switch axis(i)
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

               %% MotionAbort. Original name A3200MotionAbort. Kill all the current movements of the system%%
        % Arguments: object ALIO (this),array int Axes%
        % Returns: none %
        function  ASCSMotionAbort(this,axis)
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
%            if(this.debug)
%             sprintf('gantry pointer: KillAll\n');
%             disp(gantry)
%             end
        end
        

        end

end
        
        
        
        
        
        
        