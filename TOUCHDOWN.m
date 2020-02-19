classdef TOUCHDOWN < handle
    %TOUCHDOWN This class manages the contact between the Z axis and the pick up tool.
    % In order to identify when the pick up platform of the gantry is in contact with the
    % corresponding tool, the current of the Z stage is controlled. This class provides
    % the methods that manage the contact.
    
    properties (Access=protected)
        gantry;
        timerLogging;
        currentVector;
        positionVector;
        timeVector;
        slopeVector;
        sampleSize=0.1;
        principalTrigger=0;
        secondaryTrigger=0;
        thresholdSlope=0.0005;

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
         this.slopeVector=0;
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
            
            %asking current and position values
            currentValue=this.gantry.GetCurrentFeedback(tobj.UserData.axis);
            positionValue=this.gantry.GetPosition(tobj.UserData.axis);
            timeValue=tobj.UserData.counter/this.sampleSize;
            
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

            %principal trigger: based on the slope of the last 5 measured points
            if tobj.UserData.counter>5
            y=this.currentVector(end-5+1:end);
            x=this.timeVector(end-5+1:end);
            P = polyfit(x,y,1);
            
            % saving slope in the corresponding vector
            deltaSlope = 0;
            tobj.UserData.counter
            if tobj.UserData.counter~=1
             this.slopeVector=[this.slopeVector P(1)];
            else
                disp("fill slope...")
              this.slopeVector=P(1);
              deltaSlope=P(1)
            end
            %disp("deltaSlope")
            %deltaSlope
            
            
            if P(1)>this.thresholdSlope
                this.principalTrigger=1;
                disp('principal Trigger');
            else
                this.principalTrigger=0;
            end
            end
            
               % secondary trigger: based in the absolute value of the RMS
             if currentValue>1.5
                 this.secondaryTrigger=1;
                 disp('secondary trigger');
             else
                 this.secondaryTrigger=0;
             end

            % ploting in live figure current value if necessary
            if tobj.UserData.plotFlag==1
                hold on

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
                plot(timeValue,P(1),'*');
                hold on
                subplot(4,1,4)
                title('triggers')
                plot(timeValue,this.principalTrigger,'*');
                %hold on
                %subplot(4,1,5)
                %title('triggers')
                %plot(timeValue,this.principalTrigger,'*');
                end

            end
            % increment counter
            tobj.UserData.counter=tobj.UserData.counter+1;  
            
        end       

%% stopLogging

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
            %runTouchdown this methods move the corresponding Z axis in negative direction until contact
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
            
            %maximum searching time(s)
            maxSearchingTime=60;
            
            %setting velocity for the movement
            lowVelocity=-0.05;
            highVelocity=-5;
            
            %moving fast velocity if expected contact position provided 
            if nargin==3
                gap=1; %1 mm over expected contact height
                finalPosition=expectedContactPosition+gap;
                this.gantry.MoveTo(axis,finalPosition,highVelocity);
                this.gantry.WaitForMotion(axis,-1);
            end
            
            % this.gantry.MoveBy(axis,1,5)
            
            % setting the initial Z position. We start movement upwards from here.
            Zini=this.gantry.GetPosition(axis)
            
            %calculating the security distance (vertical movement previous to the downwards movement)
            deltaPositive=lowVelocity*timePermanent
            
            %Moving to starting point. We start moving downwards from here.
            this.gantry.MoveBy(axis,deltaPositive,highVelocity);
            this.gantry.WaitForMotion(axis,-1);
            this.gantry.GetPosition(axis)
            
            % launch current logging
            this.startLogging(axis,1);
            pause(1)
            
            %Starting aproach
            this.gantry.FreeRunZ1(lowVelocity);

            %waiting until current position = initial position. Then start search.
            while(this.gantry.GetPosition(axis)>Zini)
             pause(0.01)   
            end
            
            %starting counter 
            disp("start timer...")
            searchingTime=tic;
            
            % searching loop
            while (toc(searchingTime)<maxSearchingTime)
                if this.principalTrigger==1 || this.secondaryTrigger==1
                    break
                end
                pause(0.01)
            end
            this.gantry.MotionStop(axis)
           if toc(searchingTime)>maxSearchingTime
               disp('Maximum time reached')
           else
               fprintf( 'Contact reached --> Trig1=%d, Trig2=%d', this.principalTrigger, this.secondaryTrigger);
           end
            
            
            % stopping logging
            [info.current,info.position] = this.stopLogging;
            
            % total time
            info.time=toc;
            
            
  end 

    end
end

