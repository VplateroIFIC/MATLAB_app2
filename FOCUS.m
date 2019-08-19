classdef FOCUS
    %FOCUS focusing tools
  
    
    properties (Access=private)
       maxIter=5;
       FocusRange=0.5;
       velocity=2;
       threshold=0.05;
       
    end
    
    methods
        function obj = untitled7(inputArg1,inputArg2)
            %UNTITLED7 Construct an instance of this class
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

