classdef OPTONCDT2300 < handle
    %OPTONCDT2300 is a handle class for working with microepsilon laser triangulation
    %sensors. Suported models are:
    %   optoNCDT2300-xx (ILD2300),
    
    %Start with the constructor:
    %   laser = OPTONCDT2300(sensorType) %Where sensor type is a clib.MEDAQLib.ME_SENSOR enumeration member (if not set, SENSOR_ILD2300 is used)
    %The comunication with the sensor is done via writing and reading
    %   parameters (with the clib.MEDAQLib.setParameter or clib.MEDAQLib.getParameter 
    %   functions) and sending commands (with clib.MEDAQLib.SensorCommand).
    %
    %There are three types of parameters:
    %   IP_PARAMETERS are the interface parameters (set up when connecting with
    %       the sensor)
    %   SA_PARAMETERS are the sensor answer parameters (where the sensor
    %       writes answers to our inquiries)
    %   SP_PARAMETERS are the sensor parameters (to comunicate with the
    %       sensor)
    %
    %For ethernet connection (only interface currently supported),
    %   modify the IP public properties and call SetupConnect (which sets the
    %   IP_PARAMETERS before connection)
    %
    %All methods form OPTONCDT2300 class return an error code (clib.MEDAQLib.ERR_CODE),
    %   returning clib.MEDAQLib.ERR_CODE.ERR_NOERROR at success. For
    %   detailed info of the error, call this.GetError, which returns a
    %   string of max size this.errTextSize
    %
    %For updating the sensor settings, SP_PARAMETERS properties may be changed and
    %   then 'Set' functions can be called, storing the SP_PARAMETERS in the
    %   sensor.
    %
    %For getting the current settings, 'Get' functions may be called, which
    %   will store the current settings into the SP_PARAMETERS properties.
    %
    %In order to retrieve data from the sensor, you can call
    %   this.PollData and get the last trasnferred data or you can set up
    %   trigger mode (this.SetTriggerMode) then trigger and get values with
    %   this.TriggerValuesAndPoll
    
    properties (Constant)
        UINT32_MAX = 4294967295; %just for some parameter values
        TRIGGERCOUNT_MAX = 16383;
    end
    
    properties (Access=protected)
        hSensor uint32; %sensor handle instance
    end
    
    properties (SetAccess=protected, GetAccess=public)
        sensorType;  %sensor model in use
        IP_LogFile = "C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\LogFile\Laser-log.txt"; %Path of the debugging file
        IP_interface = "TCP/IP"; %Connection interface (currently supported TCP/IP)
        IP_EnableLogging = 0; %Enables (1) or not (0) logging to the debugging log file
        IP_LogAppend = 0; %0=Clear the log file when connecting, 1=Append info to the log file
        IP_RemotePort = 23; %Default, not changed
        IP_AutomaticMode = 3; %A bit combination of: first bit (1)=Retrieve sensor information for setup the library, second bit (2)=Activate data output
        SP_TriggerTermination = 0; %Enables termination resistance (if 1) for hardware trigger
    end
    
    properties (Access = public)
        IP_RemoteAddr = "169.254.168.150";
        IP_RingBufferSize = 104857600; % Byte capacity of the buffer from which data is retrieved. MAX = 1073741824 (1GB)
        bufferValueSize; %Value capacity of the buffer (IP_RingBufferSize/4, updated when called this.SetupConnect) (This is not accurate)
        IP_ScaleErrorValues = 3; % 1=Last valid value, 2=Fixed Value, 3=Negative error value
        SP_MeasureMode = 1; %0=Diffuse reflection, 1=Direct reflexion
        SP_MeasurePeak = 0; %0=Greatest amplitude, 1=Greatest area, 2=First peak
        SP_LaserPower = 0; %0=Full, 1=Reduced, 2=Off
        SP_Measrate = 20; %kHz, accepted values are 1.5, 2.5, 5, 10, 20, 30, 49
        dataSize = 1000; %Data size to read
        rawData; %Raw data stored here
        scaledData; %Scaled data stored here
        meanDistance; %When only z values are transferred, the values can be averaged with this.AverageValues
        SP_MeasureValueCnt = 4294967295 %Number of values to be output, if set to this.UINT32_MAX, continous output must be expected.
        errTextSize = 200; %Max Size of errText for method GetError
        SP_TriggerMode = 0; %0=No triggering, 3=Software trigger (1 & 2 are not suported)
        SP_TriggerCount = 1000; %Number of values to be output when triggering, TRIGGERCOUNT_MAX is the max number and means continous output
    end
    
    methods
        
        function this = OPTONCDT2300(sensor)
            %Constructor for OPTONCDT2300. 
            %   First imports the clib.MEDAQLib library.
            %   Then creates a sensor interface device
            %   (CreateSensorInstance) with the MEDAQLib library for the
            %   specified sensor (default: clib.MEDAQLib.ME_SENSOR.SENSOR_ILD2300)
            
            %Parameters:
            %   sensor (clib.MEDAQLib.ME_SENSOR) is the sensor model.
            %       This class currently supports sensor optoNCDT2300 (clib.MEDAQLib.ME_SENSOR.SENSOR_ILD2300).
            
            addpath('C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app');    %add the class folder to the matlab path
            addpath('C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\optoNCDT2300');       %add the setPath forlder to the matlab path
            addpath('C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\optoNCDT2300\MEDAQLib') %Add the compiled .dll to the MATLAB search Path
            err = setPath('C:\Users\GantryUser\Desktop\GantryGit\MATLAB_app\Laser_libraries\optoNCDT2300\MEDAQLib-4.7.0.30086\Release-x64'); %Add the original library to the System PATH
            if err
                try
                    clib.LLT.TInterfaceType;
                catch
                    fprintf("clib.MEDAQLib library was imported successfully\n");
                end
            end
            
            if exist('sensor','var')
               this.sensorType=sensor;
            else
               this.sensorType = clib.MEDAQLib.ME_SENSOR.SENSOR_ILD2300; 
            end
            
            this.hSensor = clib.MEDAQLib.CreateSensorInstance(this.sensorType);
            fprintf('Handle instance: %d\n',this.hSensor);
        end
        
        function delete(this)
            %Destructor for OPTONCDT2300
            clib.MEDAQLib.ReleaseSensorInstance(this.hSensor);
            delete(this);
        end
        
        function err = SetupConnect(this)
            %Connect to the sensor with the selected initial setup (with
            %   set values for IP_PARAMETERS) and calculates the buffer
            %   value capacity
            
            %Sets (see properties for more info):
            %   IP_Interface
            %   IP_RemoteAddr
            %   IP_EnableLogging
            %   IP_LogFile
            %   IP_LogAppend
            %   IP_ScaleErrorValues
            %   IP_AutomaticMode
            %   IP_RingBufferSize
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "IP_Interface", this.IP_interface);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_Interface, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "IP_RemoteAddr", this.IP_RemoteAddr);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_RemoteAddr, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterInt (this.hSensor, "IP_EnableLogging", this.IP_EnableLogging);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_EnableLogging, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "IP_LogFile", this.IP_LogFile);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_LogFile, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterInt (this.hSensor, "IP_LogAppend", this.IP_LogAppend);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_LogAppend, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterInt (this.hSensor, "IP_ScaleErrorValues", this.IP_ScaleErrorValues);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_ScaleErrorValues, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterInt (this.hSensor, "IP_AutomaticMode", this.IP_AutomaticMode);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_AutomaticMode, something occurred: %s',string(err));
            end
            
            err = clib.MEDAQLib.SetParameterInt (this.hSensor, "IP_RingBufferSize", this.IP_RingBufferSize);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting IP_RingBufferSize, something occurred: %s',string(err));
            end
            
            this.bufferValueSize = this.IP_RingBufferSize/4;
            
            err = clib.MEDAQLib.OpenSensor(this.hSensor);
            if err == clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                fprintf("Connection stablished succesfully\n");
            else
                warning("'While connecting to the sensor, something occurred: %s\n",string(err));
            end
                        
        end
        
        function err = Disconnect(this)
            %Disconnect the sensor. Call it before deleting the
            %   OPTONCDT2300 object
            err = clib.MEDAQLib.CloseSensor(this.hSensor);
        end
        
        function this = GetConfiguration(this)
            this.GetMeasurementConfig;
            this.GetOutputConfig;
            this.GetTriggerMode;
        end
        
        function [err, err1, err2] = SetMeasurementConfig(this)
            %Set the measurement configuration based on the set
            %   SP_PARAMETERS.
            
            %Sets:
            %   SP_MeasureMode = measuring mode,
            %   SP_MeasurePeak = measured reflection peak,
            %   SP_LaserPower = laser power, 
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_MeasureMode");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_MeasureMode", this.SP_MeasureMode);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_MeasureMode, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
            
            err1 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_MeasurePeak");
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_MeasurePeak", this.SP_MeasurePeak);
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_MeasureMode, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SensorCommand(this.hSensor);
            
            err2 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_LaserPower");
            if err2 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err2));
            end
            err2 = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_LaserPower", this.SP_LaserPower);
            if err2 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_LaserPower, something occurred: %s',string(err2));
            end
            err2 = clib.MEDAQLib.SensorCommand(this.hSensor);
            
        end
        
        function [err1, err2, err3] = GetMeasurementConfig(this)
            %Gets current measurement cofiguration stored in the sensor and
            %   stores them in the SP measurement parameters
            
            %Gets:
            %   SP_MeasureMode = measuring mode,
            %   SP_MeasurePeak = measured reflection peak,
            %   SP_LaserPower = laser power,         
            
            measure = clibArray('clib.MEDAQLib.Int',1);
            err1 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_MeasureMode");
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SensorCommand(this.hSensor);
            err2 = clib.MEDAQLib.GetParameterInt(this.hSensor, "SA_MeasureMode", measure);
            if err2 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While reading SA_MeasureMode, something occurred: %s',string(err2));
            end
            this.SP_MeasureMode = measure(1);
            
            err2 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_MeasurePeak");
            if err2 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err2));
            end
            err2 = clib.MEDAQLib.SensorCommand(this.hSensor);
            err = clib.MEDAQLib.GetParameterInt(this.hSensor, "SA_MeasurePeak", measure);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While reading SA_MeasurePeak, something occurred: %s',string(err));
            end
            this.SP_MeasurePeak = measure(1);
            
            err3 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_LaserPower");
            if err3 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err3));
            end
            err3 = clib.MEDAQLib.SensorCommand(this.hSensor);
            err = clib.MEDAQLib.GetParameterInt(this.hSensor, "SA_LaserPower", measure);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While reading SA_LaserPower, something occurred: %s',string(err));
            end
            this.SP_LaserPower = measure(1);
            
        end
        
        function err = PollData(this)
            %Gets lasts (this.dataSize) mesurements from ring buffer without
            %   deleting the data form the buffer. The function stores de
            %   polled data in:
            %       this.rawData: raw data from the sensor
            %       this.scaledData: scaled data with sensor scaling factors
            %           and corrected error values
            
            this.rawData = clibArray('clib.MEDAQLib.Int', this.dataSize);
            this.scaledData = clibArray('clib.MEDAQLib.Double', this.dataSize);
            err = clib.MEDAQLib.Poll(this.hSensor, this.rawData, this.scaledData);
            
            this.rawData = int32(this.rawData);
            this.scaledData = double(this.scaledData);
        end
        
        function mean = AverageValues(this)
            %Averages the last (this.dataSize) measurements made (from
            %   scaledData) and store the computed mean in this.meanDistance
           
            lastError=0;
            mean = 0;
            n = 0;
            for i=1:this.dataSize
                if(this.scaledData(i)>-1)
                    mean = mean + this.scaledData(i);
                    n = n + 1;
                else
                    if lastError == 0 || this.scaledData(i) ~= lastError
                        warning("Error value found in scaledValues, position: %d, error code: %d",i,this.scaledData(i));
                    end
                    lastError = this.scaledData(i);
                end
            end
            if n ~= 0
                mean = mean/n;
            end
            this.meanDistance = mean;
        end
        
        function err = ClearBuffer(this)
            %Clears the ring buffer
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Clear_Buffers");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting Clear_Buffers, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
        end
        
        function [avail,err] = AvailableValues(this)
            %Gets the number of values stored in the ring buffer
            
            avail = clibArray('clib.MEDAQLib.Int',1);
            err = clib.MEDAQLib.DataAvail(this.hSensor, avail);
            avail = avail(1);
        end
        
        function errString = GetError(this)
            %Gets detailed info about the last error
            
            errText = clibArray('clib.MEDAQLib.Char',this.errTextSize);
            clib.MEDAQLib.GetError(this.hSensor,errText)
            errString=string(char(uint8(errText)));
        end
        
        function [err, err1] = SetOutputConfig(this)
            %Sets output configuration parameters.
            
            %Sets:
            %   SP_MeasureValueCnt = max number of transferred values in
            %       each measurement,
            %   SP_Measrate = measuring frequency   
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_MeasureValueCnt");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SetParameterDouble(this.hSensor, "SP_MeasureValueCnt", this.SP_MeasureValueCnt);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_MeasureValueCnt, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
            
            err1 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_Samplerate");
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SetParameterDouble(this.hSensor, "SP_Measrate", this.SP_Measrate);
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_Measrate, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SensorCommand(this.hSensor);
            
        end
        
        function [err,err1] = GetOutputConfig(this)
            %Gets current output configuration and stores it in the SP
            %output configuration parameters.
            
            %Gets:
            %   SP_MeasureValueCnt = max number of transferred values in
            %       each measurement,
            %   SP_Measrate = measuring frequency 
            
            measure = clibArray('clib.MEDAQLib.Double',1);
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_MeasureValueCnt");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
            err1 = clib.MEDAQLib.GetParameterDouble(this.hSensor, "SA_MeasureValueCnt", measure);
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While getting SA_MeasureValueCnt, something occurred: %s',string(err1));
            end
            this.SP_MeasureValueCnt = measure(1);
            
            err1 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_Samplerate");
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SensorCommand(this.hSensor);
            err2 = clib.MEDAQLib.GetParameterDouble(this.hSensor, "SA_Measrate", measure);
            if err2 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While reading SA_Measrate, something occurred: %s',string(err2));
            end
            this.SP_Measrate = measure(1);
        end
        
        function [err,err1] = SetTriggerMode(this)
            %Sets up the measurement configuration in trigger mode
            
            %Sets:
            %   SP_TriggerCount = number of triggerd values in each trigger
            %       signal
            %   SP_TriggerMode = trigerring mode (default: software
            %       triggering)
            %   SP_TriggerTermination (see properties)
           
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_TriggerCount");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_TriggerCount", this.SP_TriggerCount);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_TriggerCount, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
            
            err1 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Set_TriggerMode");
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_TriggerMode", this.SP_TriggerMode);
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_TriggerMode, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_TriggerTermination", this.SP_TriggerTermination);
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_TriggerTermination, something occurred: %s',string(err1));
            end
            err1 = clib.MEDAQLib.SensorCommand(this.hSensor);
        end
        
        function [triggerMode,triggerCount,err,err1] = GetTriggerMode(this)
            %Gets current trigger configuration stored in the sensor and
            %   stores it in the SP trigger properties
            
            %Gets:
            %   SP_TriggerMode
            %   SP_TriggerCount
            
            triggerMode = clibArray('clib.MEDAQLib.Int',1);
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_TriggerMode");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
            err1 = clib.MEDAQLib.GetParameterInt(this.hSensor, "SA_TriggerMode", triggerMode);
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While getting SA_TriggerMode, something occurred: %s',string(err1));
            end
            triggerMode = triggerMode(1);
            this.SP_TriggerMode = triggerMode;
            
            triggerCount = clibArray('clib.MEDAQLib.Int',1);
            err1 = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Get_TriggerCount");
            if err1 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err1 = clib.MEDAQLib.SensorCommand(this.hSensor);
            err2 = clib.MEDAQLib.GetParameterInt(this.hSensor, "SA_TriggerCount", triggerCount);
            if err2 ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While getting SA_TriggerCount, something occurred: %s',string(err1));
            end
            triggerCount = triggerCount(1);
            this.SP_TriggerCount = triggerCount;
        end
        
        function err = SoftwareTrigger(this)
            %Execute a software trigger
            
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Software_Trigger");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While triggering the sensor, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
        end
        
        function err = TriggerValuesAndPoll(this)
            %Clear the buffer, trigger (this.SP_TriggerCount) values, waits
            %for them and stores them in rawData and scaledData with
            %this.PollData
            
            
            err = this.ClearBuffer;
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While clearing the buffer, something occurred: %s',string(err));
            end
            
            this.SoftwareTrigger;
            this.dataSize = this.SP_TriggerCount;            
            while this.AvailableValues < this.SP_TriggerCount     %Wait for values to be available (maybe there's a better way to do this)
            end
            this.PollData;
        end
        
        function err = SaveParameters(this,number)
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Save_Parameters");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_ParameterSet", number);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_ParameterSet, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
        end
        
        function err = LoadParameters(this,number) %1=Continous sending, 2=Trigger continous sending, 3=Trigger 1000 values
            err = clib.MEDAQLib.SetParameterString(this.hSensor, "S_Command", "Load_Parameters");
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting S_Command, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_ParameterSet", number);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_ParameterSet, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SetParameterInt(this.hSensor, "SP_ParameterType", 0);
            if err ~= clib.MEDAQLib.ERR_CODE.ERR_NOERROR
                warning('While setting SP_ParameterType, something occurred: %s',string(err));
            end
            err = clib.MEDAQLib.SensorCommand(this.hSensor);
        end
        
        %Some set functions to assure a correct parameter selection ---------------------------------
        function set.IP_ScaleErrorValues(this,value)
            if value > 0 && value < 4
                this.IP_ScaleErrorValues = value;
            else
                warning('%d is not a valid IP_ScaleErrorValues value, valid values are:\n\t1 = Last valid value,\n\t2 = Fixed Value,\n\t3 = Negative error value\n',value);
            end
        end
        
        function set.SP_MeasureMode(this,value)
            if value >= 0 && value < 3
                this.SP_MeasureMode = value;
            else
                warning('%d is not a valid SP_MeasureMode value, valid values are:\n\t0 = Diffuse reflection,\n\t1 = Direct reflection,\n\t2 = Thickness\n',value);
            end
        end
        
        function set.SP_MeasurePeak(this,value)
            if value >= 0 && value < 3
                this.SP_MeasurePeak = value;
            else
                warning('%d is not a valid SP_MeasureMode value, valid values are:\n\t0 = Greatest amplitude,\n\t1 = Greatest area,\n\t2 = First peak\n',value);
            end
        end
        
        function set.SP_LaserPower(this,value)
            if value >= 0 && value < 3
                this.SP_LaserPower = value;
            else
                warning('%d is not a valid SP_LaserPower value, valid values are:\n\t0 = full,\n\t1 = reduced,\n\t2 = off',value);
            end
        end
        
        function set.SP_TriggerMode(this,value)
            if value == 0 || value == 3
                this.SP_TriggerMode = value;
            else
                warning('%d is not a valid SP_TriggerMode value, valid values are:\n\t0 = No triggering,\n\t3 = Software trigger,\n\t1 and 2 are not supported.',value);
            end
        end
        
        function set.SP_Measrate(this,value)
           switch value
               case {1.5,5,10,20,30,49}
                   this.SP_Measrate = value;
               otherwise
                   warning("Unaccepted measuring rate value. Possible values are: 1.5,5.0,10.0,20.0,30.0,49.0 kHz.\n");
           end
        end
        
        function set.IP_RingBufferSize(this,value)
            if ~mod(value,4)
                this.IP_RingBufferSize = value;
            else
                warning("This RingBufferSize value will cut off the last value, please use a value divisible by 4");
            end
        end
            
    end
end

