classdef CAMERA
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = CAMERA(inputArg1,inputArg2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function value = Connect(obj,inputArg)
            %METHOD1 Camera connection
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        function value = Disconnect(obj,inputArg)
            %METHOD1 Camera connection
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        function value = OneFrame(obj,inputArg)
            %METHOD1 return current frame of the camera
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        function value = DispFrame(obj,inputArg)
            %METHOD1 Camera connection
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        function value = DispCam(obj,inputArg)
            %METHOD1 display camera video in a independent windows
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end

        end
        end
    
end

