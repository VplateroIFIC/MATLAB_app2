classdef SCANCONTROL2950 < handle
    %SCANCONTROL2950 is a handle class for working with microepsilon laser triangulation
    %line scaners. Suported models are:
    %   SCANCONTROL29xx-xx
    
    %General error codes:
        %ERROR_OK=0
        %ERROR_SERIAL_COMM=1
        %ERROR_SERIAL_LLT=7
        %ERROR_CONNECTIONLOST=10
        %ERROR_STOPSAVING=100
        
        %GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED=4
        %GENERAL_FUNCTION_PACKET_SIZE_CHANGED=3
        %GENERAL_FUNCTION_CONTAINER_MODE_HEIGHT_CHANGED=2
        %GENERAL_FUNCTION_OK=1
        %GENERAL_FUNCTION_NOT_AVAILABLE=0

        %ERROR_GENERAL_WHILE_LOAD_PROFILE=-1000
        %ERROR_GENERAL_NOT_CONNECTED=-1001
        %ERROR_GENERAL_DEVICE_BUSY=-1002
        %ERROR_GENERAL_WHILE_LOAD_PROFILE_OR_GET_PROFILES=-1003
        %ERROR_GENERAL_WHILE_GET_PROFILES=-1004
        %ERROR_GENERAL_GET_SET_ADDRESS=-1005
        %ERROR_GENERAL_POINTER_MISSING=-1006
        %ERROR_GENERAL_WHILE_SAVE_PROFILES=-1007
        %ERROR_GENERAL_SECOND_CONNECTION_TO_LLT=-1008
        
    properties (Constant = true, Access = private)
        temperatureAsk = 0x86000000; 
    end
    properties (Access=protected)
        interfacesCount = 5;
        interfaces;
        pLLT int32;
        resolutionsCount = 4
    end
    properties (SetAccess=protected, GetAccess=public)
        scannerType;
        isConnected = 0;
        bytesPerProfile = 0;
        isTransfering = 0;
        resolutions;
        currentResolution = 0;
        exposureTime = 0;
        idleTime = 0;
        frecuency = 0;
        lostProfiles = 0;
        laser = 0;
        lastTemperature = 0;
    end
    properties (Access = public)
        interfaceType;
        transferMode;
        profileType;
    end
    
    methods
        
        function this = SCANCONTROL2950(interface)
            %SCANCONTROL2950 constructor. 
            %   First imports the clib.LLT library and the necessary
            %   enumerations.
            %   Then assigns the interface type to
            %   this.interfaceType if desired and creates a device handle
            %   (s_CreateLLTDevice) of the selected interface, and sets the
            %   default properties that need clib.LLT members.
            %   Sets:
            %       interfaceType = interface (default: INTF_TYPE_ETHERNET),
            %       scannerType = clib.LLT.TScannerType.scanCONTROL29xx_50,
            %       transferMode = clib.LLT.TTransferProfileType.NORMAL_TRANSFER,
            %       profileType = clib.LLT.TProfileConfig.PROFILE,
            
            %Parameters:
            %   interface (clib.LLT.TInterfaceType) is the desired
            %       interface, via which the sensor will be controlled, if
            %       it is left blank, this.interfaceType is used (default: INTF_TYPE_ETHERNET).
            
            addpath('Laser_libraries\scanCONTROL2950\');
            addpath('Laser_libraries\scanCONTROL2950\LLT\') %Add the compiled .dll to the MATLAB search Path
            err = setPath('Laser_libraries\scanCONTROL2950\C++ SDK (+python bindings)\lib\x64'); %Add the original library to the System PATH
            if err
                try
                    clib.LLT.TInterfaceType;
                catch
                    fprintf("clib.LLT library was imported successfully\n");
                end
            end
            
            if exist('interface','var') 
                this.interfaceType = interface;
            else
                this.interfaceType = clib.LLT.TInterfaceType.INTF_TYPE_ETHERNET;
            end
            
            retValue = clib.LLT.s_CreateLLTDevice(this.interfaceType);
            if retValue < 1
                warning('Could not create LLT device, error code: %d',retValue);
            else
                this.pLLT = retValue;
            end
            
            this.scannerType = clib.LLT.TScannerType.scanCONTROL29xx_50;
            this.transferMode = clib.LLT.TTransferProfileType.NORMAL_TRANSFER;
            this.profileType = clib.LLT.TProfileConfig.PROFILE;
            
            fprintf('Scaner handle created successfully. Number: %d\n',this.pLLT);
            
        end
        
        function delete(this)
            %Destructor for SCANCONTROL2950, deletes de device handle befor
            %   deleting the object
            
            %Parameters:
            %   this (SCANCONTROL2950) is the object to delete
            err = clib.LLT.s_DelDevice(this.pLLT);
            if err < 0
                warning('While deleting the handle device, something occurred, code: %d',err);
            end
            delete(this);
        end
        
        function errorCode = Connect(this, iNum, iCount)
            %Connect starts connection with the scaner
            %   This functions creates a LLT device handle (s_CreateLLTDevice) 
            %   to connect with the scanCONTROL device via iType interface, 
            %   obtains the firsts iCount available scanners 
            %   (s_GetDeviceInterfacesFast), chooses the iNum-th scanner  
            %   (s_SetInterface) and stablishes connection (s_Connect).
            
            %Parameters:
            %   this (SCANCONTROL2950) is the scanCONTROL object
            %   iNum (int) is the number of the device you want to connect with (default: 1)
            %   iCount (int) is the maximum number of connected devices you look for (default: 5)
            
            if exist('iCount','var')
                this.interfacesCount = iCount;
            end
            if ~exist('iNum','var')
                iNum=1;
            end
            
            this.interfaces =clibArray('clib.LLT.UnsignedInt',this.interfacesCount);
            
            errorCode = clib.LLT.s_GetDeviceInterfacesFast(this.pLLT,this.interfaces);
            if errorCode > this.interfacesCount
                warning('There are more devices than expected. We have found %d and we expected %d', errorCode, this.interfacesCount);
            else
                if errorCode < 1
                    warning('There was an unexpected error while getting available interfaces, code: %d', errorCode);
                end
            end
            
            errorCode = clib.LLT.s_SetDeviceInterface(this.pLLT,this.interfaces(iNum),0);
            if errorCode > 1
                warning('While setting the interface, something occurred, code: %d',errorCode);
            else
                if errorCode < 1
                    warning('There was an unexpected error while setting the interfaces, code %d',errorCode);
                end
            end
            
            errorCode = clib.LLT.s_Connect(this.pLLT);
            if errorCode > 1
                warning('While connecting to the sensor, something occurred, code: %d',errorCode);
                this.isConnected = 1;
            else
                if errorCode < 1
                    this.isConnected = 0;
                    warning('There was an unexpected error while connecting to the sensor, code %d',errorCode);
                else
                    this.isConnected = 1;
                    fprintf('Connection stablished successfully!\n');
                end
            end
        end
        
        function errorCode = Disconnect(this) 
            %Diconnect terminates connection to the sensor.
            
            %Parameters:
            %   this (SCANCONTROL2950) is the object
            
            errorCode = clib.LLT.s_Disconnect(this.pLLT);
            if errorCode > 1
                warning('While disconnecting the sensor, something occurred, code: %d',errorCode);
                this.isConnected = 1;
            else
                if errorCode < 1
                    this.isConnected = 0;
                    warning('There was an unexpected error while disconnecting the sensor, code %d',errorCode);
                else
                    this.isConnected = 1;
                     fprintf('Disconnection done successfully!\n');
                end
            end
            
        end
        
        function GetConfiguration(this)
            this.GetResolutions;
            this.GetCurrentResolution;
            this.GetLaser;
            this.GetIsTransfering;
            this.GetIdleTime;
            this.GetExposureTime;
            this.GetProfileFrecuency;
        end
        
        function resolutions = GetResolutions(this)
            %Get the available resolutions and store them in
            %this.resolutions
            
            %Parameters
            %   this (SCANCONTROL2950) is the current object
            
            resolutions = clibArray('clib.LLT.UnsignedLong',this.resolutionsCount);
            
            errorCode = clib.LLT.s_GetResolutions(this.pLLT,resolutions);
            if errorCode == -156
                warning('Resolutions size is too small, please update it in the class definition');
            else
                if errorCode < 1
                    warning('There was an unexpected error while querying for the available resolutions, code %d',errorCode);
                end
            end
            fprintf('There are %d available resolutions: \n',errorCode);
            
            resolutions = uint32(resolutions);
            this.resolutions = resolutions;
        end
        
        function resolution = GetCurrentResolution(this)
            %Get the current resolution of the sensor and store it in
            %this.currentResolution.
            
            %   this (SCANCONTROL2950) is the current object.
            
            resolution = clibArray('clib.LLT.UnsignedLong',1);
            errorCode = clib.LLT.s_GetResolution(this.pLLT,resolution);
            if errorCode > 1
                warning('While querying for the current resolution, something occurred, code: %d',errorCode);
            else
                if errorCode < 1
                    warning('There was an unexpected error while querying for the current resolution, code %d',errorCode);
                end
            end
            this.currentResolution = resolution(1);
            resolution = this.currentResolution;
        end
        
        function lsr = GetLaser(this)
            %GetLaser gets the current laserPower and stores it int
            %this.laser
            
            %   this (SCANCONTROL2950) is the current object.
            
            las = clibArray('clib.LLT.UnsignedLong',1);
            
            errorCode = clib.LLT.s_GetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_LASER),las);
            if errorCode > 1
                warning('While getting the laser power, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while getting the laser power, code %d',errorCode);
                    end
                end
            end
            
            lsr = laserPow(las(1));
            this.laser=lsr;
        end
        
        function bol = GetIsTransfering(this)
            %Asks the sensor wether it is transferring profiles or not.
            
            %   this (SCANCONTROL2950) is the current object
            
            bol = boolean(clib.LLT.s_IsTransferingProfiles(this.pLLT));
            this.isTransfering=bol;
        end
        
        function temperature = GetTemperature(this)
            %GetTemperature first asks for the temperature to be written in
            %the FEATURE_FUNCTION_TEMPERATURE register setting it to
            %this.temperature and then reads it and stores it in
            %this.lastTemperature
            
            %   this (SCANCONTROL2950) is the current object
            
            errorCode = clib.LLT.s_SetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_TEMPERATURE),uint32(this.temperatureAsk));
            if errorCode > 1
                warning('While asking for the temperature, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while asking for the temperature, code %d',errorCode);
                    end
                end
            end
            
            temperature = clibArray('clib.LLT.UnsignedLong',1);
            errorCode = clib.LLT.s_GetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_TEMPERATURE),temperature);
            if errorCode > 1
                warning('While reading the temperature, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while reading the temperature, code %d',errorCode);
                    end
                end
            end
            
            this.lastTemperature = temperature(1);
            temperature = this.lastTemperature;
        end
        
        function eTime = GetExposureTime(this)
            %GetExposureTime asks for the exposure time and stores it in
            %this.exposureTime (in ns)
            
            %   this (SCANCONTROL2950) is the current object
           
            eTime = clibArray('clib.LLT.UnsignedLong',1);
            errorCode = clib.LLT.s_GetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_EXPOSURE_TIME),eTime);
            if errorCode > 1
                warning('While asking for the exposure time, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while asking for the exposure time, code %d',errorCode);
                    end
                end
            end
            
            this.exposureTime = eTime(1)*10;
            eTime = this.exposureTime;
            
        end
        
        function iTime = GetIdleTime(this)
            %GetExposureTime aks for the idle time and stores it in
            %this.idleTime (in ns)
            
            %   this (SCANCONTROL2950) is the current object
           
            iTime = clibArray('clib.LLT.UnsignedLong',1);
            errorCode = clib.LLT.s_GetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_EXPOSURE_TIME),iTime);
            if errorCode > 1
                warning('While asking for the exposure time, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while asking for the exposure time, code %d',errorCode);
                    end
                end
            end
            
            this.idleTime = iTime(1)*10;
            iTime = this.idleTime;
            
        end
        
        function frecuency = GetProfileFrecuency(this)
            this.GetExposureTime();
            this.GetIdleTime();
            this.frecuency = 10^6/(this.exposureTime + this.idleTime);
            frecuency = this.frecuency;
        end
        
        function errorCode = SetProfileType(this,profile)
            %SetProfileType sets the profile configuration for
            %transmition and stores it in this.profileType
            
            %   this (SCANCONTROL2950) is the current object,
            %   profile (clib.LLT.TProfileConfig) is the profile
            %       configuration:
            %       PROFILE: all the info is gathered
            %       PURE_PROFILE: just the X/Z info is gathered
            %       QUARTER_PROFILE: just the first stripe of the data is
            %           gathered (first reflection).
            %       CONTAINER: more than one profile is sent at once
            
            errorCode = clib.LLT.s_SetProfileConfig(this.pLLT,profile);
            if errorCode > 1
                warning('While setting the profile configuration, something occurred, code: %d',errorCode);
            else
                if errorCode == -152
                    warning('Profile configuration not available');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while setting the profile configuration, code %d',errorCode);
                    end
                end
            end
            
            this.profileType = profile;
            
        end
        
        function errorCode = SetLaser(this,laser)
            %SetLaser sets the laser power of the sensor and stores it in
            %this.laser
            
            %   this (SCANCONTROL2950) is the current object,
            %   laser (laser) is the laser power to set, it can be:
            %       OFF
            %       REDUCED
            %       FULL
            
            if exist('laser','var')
                this.laser = laser;
            end
            
            errorCode = clib.LLT.s_SetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_LASER),uint32(this.laser));
            if errorCode > 1
                warning('While setting the laser, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while setting the laser power, code %d',errorCode);
                    end
                end
            end
        end
        
        function errorCode = SetExposureTime(this,exposureTime)
            %SetExposureTime sets the exposure time and stores it in
            %this.exposureTime (in ns)
            
            %   this (SCANCONTROL2950) is the current object
            %   exposureTime (uint16) is the exposure time to be set, in
            %   ns, divisible by 10, [10,40950]
           
            eTime = exposureTime/10;
            errorCode = clib.LLT.s_SetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_EXPOSURE_TIME),eTime);
            if errorCode > 1
                warning('While setting the exposure time, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while setting the exposure time, code %d',errorCode);
                    end
                end
            end
            
            this.exposureTime = exposureTime;
            
        end
        
        function errorCode = SetIdleTime(this,idleTime)
            %SetExposureTime sets the idle time and stores it in
            %this.idleTime (in ns)
            
            %   this (SCANCONTROL2950) is the current object
            %   idleTime (uint16) is the exposure time to be set, in
            %   ns, divisible by 10, [10,40950]
           
            iTime = idleTime/10;
            errorCode = clib.LLT.s_SetFeature(this.pLLT,uint32(features.FEATURE_FUNCTION_EXPOSURE_TIME),iTime);
            if errorCode > 1
                warning('While setting the exposure time, something occurred, code: %d',errorCode);
            else
                if errorCode == -155
                    warning('Wrong address');
                else
                    if errorCode < 1
                        warning('There was an unexpected error while setting the exposure time, code %d',errorCode);
                    end
                end
            end
            
            this.idleTime = idleTime;
            
        end
        
        function retValue = StartTransmision(this, transferMode)
            %StartTransmision enables profile data transmision
            %(s_TransferProfiles) with the profileType configuration
            
            %   this (SCANCONTROL2950) is the current object
            %   transferMode establishes the way profiles are transferred (default: NORMAL_TRANSFER):
            %       NORMAL_TRANSFER: continous transfer of profiles
            %       SHOT_TRANSFER: demand-based transfer of profiles (not supported)
            %       NORMAL_CONTAINER_MODE: continuous transfer in the container mode (more than one profile is transferred at once) 
            %       SHOT_CONTAINER_MODE: demand-based container mode (not supported)
            
            if exist('transferMode','var')
                this.transferMode = transferMode;
            end
            
            retValue = clib.LLT.s_TransferProfiles(this.pLLT,this.transferMode,true);
            if retValue > 1
                this.bytesPerProfile = retValue;
                fprintf('Transferring %d bytes per profile',this.bytesPerProfile);
                this.isTransfering = 1;
            else
                if retValue < 1
                    this.isTransfering = 0;
                    warning('There was an unexpected error while asking for transmition, code %d',retValue);
                end
            end
        end
        
        function retValue = EndTransmision(this)
            %EndTransmision stops profile data transmision
            %(s_TransferProfiles).
            
            %this (SCANCONTROL2950) is the current object
            
            retValue = clib.LLT.s_TransferProfiles(this.pLLT,this.transferMode,false);
            if retValue < 0
                this.isTransfering = 1;
                warning('There was an unexpected error while ending transmition, code %d',retValue);
            else
                this.isTransfering = 0;
                fprintf('Transmition stopped successfully');
            end
        end
        
        function retValue = GetProfileData(this, nReflection, pX, pZ, pWidth, pMaximum, pThreshold, pM0, pM1, profileType, nResolution)
            %getProfileData gets the last profile measured and process it.
            %It obtains the raw data with s_GetActualProfile, based on the
            %profileType and keps it on pBuffer, for evaluating it with
            %s_ConverProfile2Values, which obtains the well ordered data
            %from the stripe nº nReflection (1,2,3) and stores it in
            %pWidth, pMaximum, pThreshold...
            
            
            %   this (SCANCONTROL2950) is the current object,
            %   nReflection (uint32) the nº of the stripe from which it  
            %        will evaluate the data,
            %   pX is the array of resolution doubles which contains X
            %       coordinates of the measured points,
            %   pZ is the array of resolution doubles which contains Z
            %       coordinates of the measured points,
            %   pWidth is the array of resolution
            %   profileType (clib.LLT.TProfileConfig) is the profile
            %   configuration for the data transmision (default: PROFILE):
            %       PROFILE: complete profile data (three reflection stripes
            %       (3*16 bytes) plus a timestamp (16 bytes) for each point
            %       (=64 bytes per point = 64*resolution bytes transmited)
            %       QUARTER_PROFILE: transmit one single stripe (16 bytes) 
            %       per point plus a 16 byte timestamp (=16*resolution + 16
            %       bytes transmited)
            %       PURE_PROFILE: just transmit the XZ data (2+2 bytes per
            %       point) + 16 byte timestamp (=4*resolution + 16 bytes
            %       transmited).
            %       PARTIAL_PROFILE: a custom cropped profile. For more
            %       info see the C++_InterfaceDocumentation
            %   nResolution is the position in the this.resolutions array
            %       of the resolution the device should work with
            
            %for getting the data you should use
            % pX = clibArray('clib.LLT.Double',obj.currentResolution); pZ = clibArray('clib.LLT.Double',obj.currentResolution);
            % pWidth = clibArray('clib.LLT.UnsignedShort',obj.currentResolution); pMaximum = clibArray('clib.LLT.UnsignedShort',obj.currentResolution); pThreshold = clibArray('clib.LLT.UnsignedShort',obj.currentResolution);
            % pM0 = clibArray('clib.LLT.UnsignedInt',obj.currentResolution); pM1 = clibArray('clib.LLT.UnsignedInt',obj.currentResolution);
            
            if exist('nResolution','var')
                this.currentResolution = this.resolutions(nResolution);
                
                errorCode = clib.LLT.s_SetResolution(this.pLLT,this.currentResolution);
                if errorCode > 1
                    warning('While setting the resolution, something occurred, code: %d', errorCode);
                else 
                    if errorCode < 1
                        warning('There was an unexpected error while setting the resolution, code: %d', errorCode);
                    end
                end
            end
            if exist('profileType','var')
                this.profileType = profileType;
            else
                this.profileType = clib.LLT.TProfileConfig.PROFILE;
            end
            
            pBuffer = clibArray('clib.LLT.UnsignedChar',this.currentResolution*64);
            
            lProfiles = clibArray('clib.LLT.UnsignedInt',1);
            transferredBytes = clib.LLT.s_GetActualProfile(this.pLLT,pBuffer,this.profileType,lProfiles);
            if transferredBytes < 1
                warning('There was an unexpected error while reading the profile, code: %d', transferredBytes);
            else
                fprintf('Profile reading completed successfully, %d bytes transferred\n',transferredBytes);
            end
            this.lostProfiles = lProfiles(1);
            
            retValue = clib.LLT.s_ConvertProfile2Values(this.pLLT,pBuffer,this.profileType,this.scannerType,nReflection,true,pWidth,pMaximum,pThreshold,pX,pZ,pM0,pM1);
            if retValue > 1 && retValue < 5
                warning('While processing the profiles, something occurred, code: %d',retValue);
            else
                if retValue < 1
                    warning('There was an unexpected error while processing the profile, code: %d', retValue);
                else
                    fprintf('Profile processing completed successfully');
                end
            end
            
        end
            
    end
end
