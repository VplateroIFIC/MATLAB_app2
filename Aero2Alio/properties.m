%%%% PROPERTIES: ALL CHANGES DONE IN PROPERTIES OF ModulePlacement_MATLAB APP %%%%

%% ORIGINAL PROPERTIES %%

  properties (Access = public)
        ModulePlacementUIFigure    matlab.ui.Figure
        FileMenu                   matlab.ui.container.Menu
        SaveStateMenu              matlab.ui.container.Menu
        LoadStateMenu              matlab.ui.container.Menu
        CameraMenu                 matlab.ui.container.Menu
        SaveImageMenu              matlab.ui.container.Menu
        FormatMenu                 matlab.ui.container.Menu
        EmergencyStateMenu         matlab.ui.container.Menu
        SafeMoveMenu               matlab.ui.container.Menu
        ExitMenu                   matlab.ui.container.Menu
        AccountMenu                matlab.ui.container.Menu
        LoginMenu                  matlab.ui.container.Menu
        PetalPic                   matlab.ui.control.UIAxes
        Label                      matlab.ui.control.Label
        MovementPanel              matlab.ui.container.Panel
        StopMotionButton           matlab.ui.control.Button
        TabGroup                   matlab.ui.container.TabGroup
        AbsoluteTab                matlab.ui.container.Tab
        AbsStepSize_X              matlab.ui.control.NumericEditField
        AbsStepSize_Y              matlab.ui.control.NumericEditField
        AbsStepSize_Z              matlab.ui.control.NumericEditField
        AbsStepSize_U              matlab.ui.control.NumericEditField
        PositionmmLabel            matlab.ui.control.Label
        AbsButton_X                matlab.ui.control.Button
        AbsButton_Y                matlab.ui.control.Button
        AbsButton_Z                matlab.ui.control.Button
        AbsButton_U                matlab.ui.control.Button
        PositiondegLabel           matlab.ui.control.Label
        VelocitymmsEditFieldLabel  matlab.ui.control.Label
        VelocitymmsEditField       matlab.ui.control.NumericEditField
        IncrementalTab             matlab.ui.container.Tab
        IncStepSize_X              matlab.ui.control.NumericEditField
        IncStepSize_Y              matlab.ui.control.NumericEditField
        IncStepSize_Z              matlab.ui.control.NumericEditField
        IncStepSize_U              matlab.ui.control.NumericEditField
        StepSizemmLabel            matlab.ui.control.Label
        IncButton_Xp               matlab.ui.control.Button
        IncButton_Yp               matlab.ui.control.Button
        IncButton_Zp               matlab.ui.control.Button
        CWButton                   matlab.ui.control.Button
        IncButton_Xn               matlab.ui.control.Button
        IncButton_Yn               matlab.ui.control.Button
        IncButton_Zn               matlab.ui.control.Button
        CCWButton                  matlab.ui.control.Button
        StepSizedegLabel           matlab.ui.control.Label
        GraphicalTab               matlab.ui.container.Tab
        gantryViewButton           matlab.ui.control.Button
        TabGroup2                  matlab.ui.container.TabGroup
        ModuleLoadingTab           matlab.ui.container.Tab
        PetalButton                matlab.ui.control.Button
        ModuleDropDownLabel        matlab.ui.control.Label
        ModuleDropDown             matlab.ui.control.DropDown
        PlaceButton                matlab.ui.control.Button
        PetalLamp                  matlab.ui.control.Lamp
        GlueButton                 matlab.ui.control.Button
        CalibrateButton            matlab.ui.control.Button
        ModuleSurveyingTab         matlab.ui.container.Tab
        ModuleDropDown_2Label      matlab.ui.control.Label
        ModuleDropDown_2           matlab.ui.control.DropDown
        MoveButton                 matlab.ui.control.StateButton
        NextButton                 matlab.ui.control.StateButton
        ManualDAQTab               matlab.ui.container.Tab
        AXISButton                 matlab.ui.control.Button
        LED1Button                 matlab.ui.control.Button
        LED2Button                 matlab.ui.control.Button
        LED3Button                 matlab.ui.control.Button
        GantryVACButton            matlab.ui.control.Button
        ControlCheckBox            matlab.ui.control.CheckBox
        ChuckVACButton             matlab.ui.control.Button
        AxisPanel                  matlab.ui.container.Panel
        XLabel                     matlab.ui.control.Label
        YLabel                     matlab.ui.control.Label
        ZLabel                     matlab.ui.control.Label
        ULabel                     matlab.ui.control.Label
        U_Home                     matlab.ui.control.Button
        Z_Home                     matlab.ui.control.Button
        Y_Home                     matlab.ui.control.Button
        X_Home                     matlab.ui.control.Button
        U_Enable                   matlab.ui.control.Button
        Z_Enable                   matlab.ui.control.Button
        Y_Enable                   matlab.ui.control.Button
        X_Enable                   matlab.ui.control.Button
        VelocityFeedbackPanel      matlab.ui.container.Panel
        TextArea_XV                matlab.ui.control.TextArea
        TextArea_YV                matlab.ui.control.TextArea
        TextArea_ZV                matlab.ui.control.TextArea
        TextArea_UV                matlab.ui.control.TextArea
        mmsLabel                   matlab.ui.control.Label
        mmsLabel_2                 matlab.ui.control.Label
        mmsLabel_3                 matlab.ui.control.Label
        degsLabel                  matlab.ui.control.Label
        PositionFeedbackPanel      matlab.ui.container.Panel
        TextArea_XP                matlab.ui.control.TextArea
        TextArea_YP                matlab.ui.control.TextArea
        TextArea_ZP                matlab.ui.control.TextArea
        TextArea_UP                matlab.ui.control.TextArea
        mmLabel                    matlab.ui.control.Label
        mmLabel_2                  matlab.ui.control.Label
        mmLabel_3                  matlab.ui.control.Label
        degLabel                   matlab.ui.control.Label
        HomeAllButton              matlab.ui.control.Button
        Switch                     matlab.ui.control.Switch
        PetalIDLabel               matlab.ui.control.Label
        PetalIDEditField           matlab.ui.control.EditField
        SaveButton                 matlab.ui.control.Button
        TabGroup3                  matlab.ui.container.TabGroup
        OutputTab                  matlab.ui.container.Tab
        OutputTextArea             matlab.ui.control.TextArea
    end

    %%----------------------------------------------------------------------------------------------------------------------------------------------------%%
    properties (Access = private)
        % Variables for DAQ
        s % signal
        num = 30; % number of control signals
        port % array of control signals
        daqFlag = 0; % Flag to record state of ni-DAQ
        
        % Port definitions for DAQ
        % (design circuit based on these values or change these values to match the circuit built)
        VAC1 = 1; % Vacuum port definitions:
        VAC2 = 2; % Festo valve terminal has 16 ports
        VAC3 = 3;
        % ...
        VAC16 = 16;
        
        LED1 = 17; % LED lights for shining under the inner frame
        LED2 = 18; % circular locators/fiducials
        LED3 = 19;
        AXIS = 20; % Camera through-lens light
        %---------------------------------------------------%
        % Gantry declarations
        gantryFlag = 0; % Flag to record state of gantry
        handle; % = A3200Connect;
        Y = 0;  % Y-Axis
        YY = 1; % YY-Axis
        X = 2;  % X-Axis
        Z = 3;  % Z-Axis
        U = 4;  % U-Axis
        allAxes = [0 1 2 3 4];
        task = 1;   % taskID
        
        % Flags not implemented yet
        homeFlag = zeros(1,4); 
        enableFlag = zeros(1,4);
        modulePlaced = zeros(2,9);
        
        velocity = 100;     % velocity when moving
        glueVelocity = 20;  % velocity when gluing
        accelTime = 5;      % time taken to reach set speed
        delay = 1;          % amount of seconds to wait after moving (buffer time for gantry movement)
        store = [0 0];      % pair of values used in calibration of camera offset during placement
        Lock = 0;           % flag for locking user control during certain movement/procedures
        %---------------------------------------------------%
        % Program Variable Declaration
        folder = ''; % Global variable for storing parent folder of all files used within code
        outputFile = '\Output\'; % Base filename used for accessing most files throughout code
        outputFileTmp = '\Output\GantryLog.txt'; % Overwritten filename for use throughout code while keeping above directory constant
        surveyResultsFile = 'surveyResults.xlsx'; % File for outputting survey results after surveying (used for plotting/statistics)
        
        imageOutDirectory = '\Output_Images\'; % Directory where all camera images are saved
        imageDirectory = '\Reference_Images\'; % Directory where all reference images are stored
        fiducialDirectory = '\Fiducials\'; % Directory where all fiducial files are stored
        
        lockFile = '\Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}'; % Folder path for when folder is locked
        unlockFile = '\AdminFolder'; % Folder path for when folder is open (editing)
        gantryFile = '\gantryValues.xlsx'; % File with hard-coded values of positions and module distance relationships
        surveyFile = 'surveyValues.xlsx'; % File with hard-coded values of where 'F' fiducials should be (relative to petal fiducials)
        glueFile = 'glueValues.xlsx'; % File with hard-coded distances of glue pattern (relative to petal fiducials)
        userFile = '\Users.xlsx'; % Locked file name of user/password information
        username = ''; % Placeholder for which user is logged in
        
        petalImg; % gloabal variable for editing the petal image during placement
        
        petalXYZ1;  % Variable for storing the coordinates of the INNER petal fiducial
        petalXYZ2;  % Variable for storing the coordinates of the OUTER petal fiducial
        petalAngle = 0;  % value of measured angle of petal (after measuring fiducial locations)
        
        sensorXYZ1; % Variable for storing the coordinates of the 'first' module fiducial
        sensorXYZ2; % Variable for storing the coordinates of the 'second' module fiducial
        sensorAngle;% Variable for storing the angle between the above locations
        
        toolXYZ;  % Variable for storing the coordinates of the pick-up tool(s)
        %---------------------------------------------------%
        % Offset lengths between glue tip and camera
        glueX = 231.1553;
        glueY = -0.1076;
        glueZ = -20.5000;
        
        % variable used for relating gantry, modules, and petal
        % (stored in external excel file - DO NOT MODIFY)
        endLength;
        endAngle;
        offLength;
        offAngle;
        holdAngle;
        petalEnd;
        
        camera; % x,y,z offset of camera location relative to gantry axis (in mm) - imported from excel
        cameraName = ''; % Name of camera used
        cameraID = 0; % Device ID for selecting which camera to use
        cameraAdaptor = ''; % Type of camera used
        cameraFormat = ''; % Resolution of camera used
        
        strMod1 = '';
        strMod2 = '';
        strOth = '';
        
        fid = ''; % Placeholder for which fiducial to fit - WILL CHANGE
        startAngle = 0; % Starting angle when searching for fiducials ('Fit' function)
        %---------------------------------------------------%
        % Camera variables
        gantryCam;
        corrVal = 0;
        threshold = 0.1;
        proceed = 0;
        refit = 0;
        cam;
        motionStop = 0;
        foc = 0;
        screen;
        scale = 50; % image is too big ot fit in figure, must reduce to '50%'
        tabView;
    end



%% MODIFIED PROPERTIES %%








