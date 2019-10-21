classdef OWIS_STAGES
    %OWIS_STAGES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
            bool PS90_connected = false;
            bool X_stage_init = false;
            bool Y_stage_init = false;
            bool Z_stage_init = false;
            bool X_stage_on = false;
            bool Y_stage_on = false;
            bool Z_stage_on = false;
            long move_state_X=0;
            long move_state_Y=0;
            long move_state_Z=0;
    end
    
    methods
        function obj = OWIS_STAGES(inputArg1,inputArg2)
            %OWIS_STAGES Construct an instance of this class
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

