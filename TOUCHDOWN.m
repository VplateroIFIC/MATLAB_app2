classdef TOUCHDOWN < handle
    %TOUCHDOWN This class manage the contact between the Z axis and the pick up tool.
    %   I order to identify when the pick up platform of the gantry is in contact with the corresponding tool, the current of the Z stage is controled. This class
    % Provide the methods that manage the contact.
    
    properties (Access=protected)
        gantry;
        timerLogging;
        currentVector;
        positionVector;
<<<<<<< HEAD
=======
%         lowVelocity;
%         highVelocity;
>>>>>>> da6dd96b1aecd2669eca0d6c007f0f30f7433779
    end
    
    methods
        
 %% TOUCHDOWN   
        function this = TOUCHDOWN(gantry)
            %TOUCHDOWN Construct an instance of this class
            %   receive and copy in local property the ganry object
            % input:
            % gantry: STAGES object
            % output:
            % this: instance of this class
            this.gantry=gantry;
            if (this.gantry.IsConnected==1)
                disp('Touchdown is ready to be used')
            else
                disp('touchdown can not be used: gantry is not connected');  
            end
        end
        
 %%  getCurrentValue
        function currentValue = getCurrentValue(this,axis)
            % getCurrentValue get the current value of the Z axis of the gantry
            % input:
            % this: instance of the class
            % axis: int, axis to control the current [X,Y,Z1,Z2,U]=[0 1 4 5 6];
            % Output:
            % currentValue: RMS value of the current of the Z axis of the gantry
            currentValue = this.gantry.GetCurrentFeedback(axis);
        end
        
%% startLogging
        function startLogging(this, axis, plot)
            %startLogging Start logging the current value of the Z axis
            % input:
            % this: instance of the class
            % axis: int, axis to control the current [X,Y,Z1,Z2,U]=[0 1 4 5 6];
            % plot: show a live plot with the current value (1 for on, 0 for off)
         this.currentVector=0;
         this.positionVector=0;
         timerCounter=1;
         if (plot==1)
             close(gcf)
             figure(1);
             title('CURRENT VALUE Z AXIS');
         end
         this.timerLogging = timer('Name','logCurrent','ExecutionMode','fixedSpacing','StartDelay', 0,'Period',0.1);
         this.timerLogging.UserData = struct('counter',timerCounter,'axis',stage,'plotFlag',plot);
         this.timerLogging.TimerFcn = {@this.logCurrent};
         this.timerLogging.ErrorFcn = {@this.stopLogging};
         this.timerLogging.StopFcn = {@this.stopLogging};
         start(this.timerLogging);
        end
        
%%  logCurrent
        function logCurrent(this,tobj,event)
            %startLogging Logging the current of the Z axis
            % input:
            %this: instance of the class
            
            %asking current value
<<<<<<< HEAD
            currentValue=this.getCurrentValue;
            positionValue=this.gantry.GetPosition(this.z1Axis);
            
=======
            currentValue=this.getCurrentValue(tobj.UserData.counter);
            positionValue=this.gantry.GetPosition(tobj.UserData.axis);
>>>>>>> da6dd96b1aecd2669eca0d6c007f0f30f7433779
            % saving value in the corresponding vector
            if tobj.UserData.counter~=1
             this.currentVector=[this.currentVector currentValue];
             this.positionVector=[this.positionVector positionValue];
            else
              this.currentVector=currentValue;
              this.positionVector=positionValue;
            end

            % ploting in live figure current value if necessary
            if tobj.UserData.plotFlag==1
                hold on
<<<<<<< HEAD
                subplot(2,1,1) 
                plot(tobj.UserData.counter,currentValue,'*');
                hold on
                subplot(2,1,2)
                plot(tobj.UserData.counter,positionValue,'*');
=======
                plot(positionValue,currentValue,'*');
>>>>>>> da6dd96b1aecd2669eca0d6c007f0f30f7433779
            end
            
            

            % increment counter
            tobj.UserData.counter=tobj.UserData.counter+1;
        end       

%% stopLogging
<<<<<<< HEAD

  function [current,position] = stopLogging(this,tobj,event)
=======
  function currentLog = stopLogging(this,tobj,event)
>>>>>>> da6dd96b1aecd2669eca0d6c007f0f30f7433779
            %stopLogging finish the logging of the Z axis current
            % input:
            % this: instance of the class
            % output:
            % currentLog: vector with the current values logged
        stop(this.timerLogging);
        current=this.currentVector;
        position=this.positionVector;
  end        

%% runTouchdown
 function info = runTouchdown(this,axis, expectedContactPosition)
            %runTouchdown this methods move the corresponding z axis in negative direction until contact
            % input
            % this: instance of the class
            % axis: axis to perform touchdown [Z1,Z2]=[4,5]
            % expectedContactPosition: expectev value of the height where contact will happen. If no argument, the full movement will be done at low velocity.
            % output
            % info: structure with information [time, currentLog]
            
            % launch counter
            tic
            
            %setting velocity for the movement
            lowVelocity=0.05;
            highVelocity=5;
            
            % getting current position of the axis
            currentPosition=this.gantry.GetPosition(axis);
            
            %moving fast velocity if expected contact position provided 
            if nargin==3
                gap=1; %1 mm over expected contact height
                finalPosition=expectedContactPosition+gap;
                this.gantry.MoveTo(axis,finalPosition,highVelocity);
            end
            
            
                
            
  end 

  
 
    end
end

