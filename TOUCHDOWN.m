classdef TOUCHDOWN
    %TOUCHDOWN This class manage the contact between the Z axis and the pick up tool. 
    %   I order to identify when the pick up platform of the gantry is in contact with the corresponding tool, the current of the Z stage is controled. This class
    % Provide the methods that manage the contact.
    
    properties
        Property1
    end
    
    methods
        function obj = untitled(inputArg1,inputArg2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

