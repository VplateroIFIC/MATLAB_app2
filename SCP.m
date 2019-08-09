classdef SCP
    %SCP SYSTEM COORDINATE CLASS
    %   This class regulate the changes between different coordinate system during loading procedure
    
    properties
        Property1
    end
    
    methods
        function obj = untitled5(inputArg1,inputArg2)
            %UNTITLED5 Construct an instance of this class
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

