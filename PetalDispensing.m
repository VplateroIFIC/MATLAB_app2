classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        robot;
        NumPetals;
        dispenser;
    end
    
    properties (Constant, Access = public)
        % All units in mm
        Pitch = 3.4;
        OffGlueStarX = 5;
        OffGlueStarY = 5;
        glueOffX = 0;
        glueoffY = 0;
    end
    
    
    methods
        function this = PetalDispensing(dispense_obj, robot_obj,num_petals)
            % Constructor function.
            % Arguments: dispense_obj, robot_obj (Gantry or OWIS), PetalNum: 1 or 2
            % present on the setup.
            % Returns: this object
            switch nargin
                case 3
                    this.NumPetals = num_petals
                case 2
                    this.NumPetals = 1;
            end
            if dispense_obj.Connected ~= 1
                fprintf ('Error -> dispenser is not connected')
            else
                this.dispenser = dispense_obj;
            end
            
            if num_petals < 0 || num_petals > 2
                fprintf ('Error -> inproper number of petals defined: %d',num_petals);
            end
            if this.robot_obj.Connected ~= 1
                fprintf ('Error -> robot object is not connected');
            else
                this.robot = robot_obj;
            end
        end
        
        function DispenseTest()
            % DispenseTest function
            % Just dispense few dropplets in order to check everything is
            % OK
            % Return 0 if everything is OK
            
            OK = dispenser.SetUltimus('E--02');      % Set dispenser units in KPA
            if OK ~= 0
                fprintf('Error: ', OK);
                break;
            end
            dispenser.SetUltimus('PS-4000');    % Set dispenser pressure to 40 KPA = 0.4 BAR
            if OK ~= 0
                fprintf('Error: ', OK);
                break;
            end
            dispenser.SetUltimus('E7-00');      % Set dispenser Vacuum unit KPA
            if OK ~= 0
                fprintf('Error: ', OK);
                break;
            end
            dispenser.SetUltimus('VS-0017');    % Set dispenser Vacuum to 0.17KPA = 0.7 incH20
            if OK ~= 0
                fprintf('Error: ', OK);
                break;
            end
            
            dispenser.SetUltimus('DS-T10000');    % Set dispenser Time to 1 second.
            if OK ~= 0
                fprintf('Error: ', OK);
                break;
            end
            dispenser.SetUltimus('DI--');
            if OK ~= 0
                fprintf('Error: ', OK);
                break;
            end
            return 0
            robot.MoveBy(robot.yAxis,2,1);        % Move yAxis 2mm at 1mm/sec
            robot.WaitEndMovement(2);             % Wait end of movement
            dispenser.SetUltimus('DI--');
            robot.MoveBy(robot.xAxis,(xAxis,2,1) % Move xAxis 2mm at 1mm/sec
        end
    end
end

