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
        timeVector;
        sampleSize=0.1;
        principalTrigger=0;
        secondaryTrigger=0;
        thresholdSlope=0.6;
>>>>>>> e3abd2fafc28252ce4fdda480968af39ea86e03f
%         lowVelocity;
%         highVelocity;

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
         this.timerLogging = timer('Name','logCurrent','ExecutionMode','fixedSpacing','StartDelay', 0,'Period',this.sampleSize);
         this.timerLogging.UserData = struct('counter',timerCounter,'axis',axis,'plotFlag',plot);
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
            
<<<<<<< HEAD
            %asking current value
            currentValue=this.getCurrentValue(tobj.UserData.counter);
            positionValue=this.gantry.GetPosition(tobj.UserData.axis);

=======
            %asking current and position values
            currentValue=this.gantry.GetCurrentFeedback(tobj.UserData.axis);
            positionValue=this.gantry.GetPosition(tobj.UserData.axis);
            timeValue=tobj.UserData.counter/this.sampleSize;
            
            
>>>>>>> e3abd2fafc28252ce4fdda480968af39ea86e03f
            % saving value in the corresponding vector
            if tobj.UserData.counter~=1
             this.currentVector=[this.currentVector currentValue];
             this.positionVector=[this.positionVector positionValue];
             this.timeVector=[this.timeVector timeValue];
            else
              this.currentVector=currentValue;
              this.positionVector=positionValue;
              this.timeVector=timeValue;
            end

             %principal trigger: based in the slope of the last 5 measured points
            if tobj.UserData.counter>5
            y=this.currentVector(end-5+1:end);
            x=this.timeVector(end-5+1:end);
            P = polyfit(x,y,1);
            if P(1)>this.thresholdSlope
                this.principalTrigger=1;
                disp('principal Trigger');
            else
                this.principalTrigger=0;
            end
            end
            
               % secondary trigger: based in the absolute value of the RMS
             if currentValue>5
                 this.secondaryTrigger=1;
                 disp('secondary trigger');
             else
                 this.secondaryTrigger=0;
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

            end
            
            
=======
                subplot(4,1,1)
                title('RMS Current')
                plot(timeValue,currentValue,'*');
                hold on
                subplot(4,1,2)
                title('Z position')
                plot(timeValue,positionValue,'*');
                hold on
                if tobj.UserData.counter>5
                subplot(4,1,3)
                title('slope 5 last points')
                plot(timeValue,atan(P(1))*180/pi,'*');
                hold on
                subplot(4,1,4)
                title('triggers')
                plot(timeValue,this.principalTrigger,timeValue,this.secondaryTrigger,'*');
                end
>>>>>>> e3abd2fafc28252ce4fdda480968af39ea86e03f

            end
            % increment counter
            tobj.UserData.counter=tobj.UserData.counter+1;
            
           
            
            
            
         
            
        end       

%% stopLogging
<<<<<<< HEAD


=======
>>>>>>> e3abd2fafc28252ce4fdda480968af39ea86e03f
  function [current,position] = stopLogging(this,tobj,event)

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
 function info = runTouchdown(this,axis,expectedContactPosition)
            %runTouchdown this methods move the corresponding z axis in negative direction until contact
            % input
            % this: instance of the class
            % axis: axis to perform touchdown [Z1,Z2]=[4,5]
            % expectedContactPosition: expected value of the height where contact will happen. If no argument, the full movement will be done at low velocity.
            % output
            % info: structure with information [time, currentLog]
            
            % launch timer
            tic
            
            % time (s) to get the permanent in current response after launch movement
            timePermanent=3;
            
            %setting velocity for the movement
            lowVelocity=-0.05;
            highVelocity=-5;
            
            % getting current position of the axis
            currentPosition=this.gantry.GetPosition(axis);
            
            %moving fast velocity if expected contact position provided 
            if nargin==3
                gap=1; %1 mm over expected contact height
                finalPosition=expectedContactPosition+gap;
                this.gantry.MoveTo(axis,finalPosition,highVelocity);
                this.gantry.WaitForMotion(axis,-1);
            end
            
            % setting the initial Z position. We start movement upwards from here.
            Zini=this.gantry.GetPosition(axis);
            
            %calculating the security distance (vertical movement previous to the down movement)
            deltaPositive=lowVelocity*timePermanent;
            
            %Moving to starting point. We start moving downwards from here.
            this.gantry.MoveBy(axis,deltaPositive,highVelocity);
            this.gantry.WaitForMotion(axis,-1);
            
            % launch current logging
            this.startLogging(axis,1);
            
            %Starting aproach
            this.gantry.FreeRunX(axis,lowVelocity);
            
            % Activation of secondary trigger
            this.secondaryTrigger=1;
            
            %waiting until current position = initial position
            while(1)
                Zposition=this.gantry.GetPosition(axis);
                if (Zposition<Zini)
                    break
                end
            end
            
            % activation of principal trigger
            this.secondaryTrigger=1;    
            
  end 

  
 
    end
end

