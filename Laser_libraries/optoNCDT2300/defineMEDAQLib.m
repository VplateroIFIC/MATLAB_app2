%% About defineMEDAQLib.mlx
% This file defines the MATLAB interface to the library |MEDAQLib|.
%
% Commented sections represent C++ functionality that MATLAB cannot automatically define. To include
% functionality, uncomment a section and provide values for &lt;SHAPE&gt;, &lt;DIRECTION&gt;, etc. For more
% information, see <matlab:helpview(fullfile(docroot,'matlab','helptargets.map'),'cpp_define_interface') Define MATLAB Interface for C++ Library>.



%% Setup. Do not edit this section.
function libDef = defineMEDAQLib()
libDef = clibgen.LibraryDefinition("MEDAQLibData.xml");
%% OutputFolder and Libraries 
libDef.OutputFolder = "C:\Users\max\Desktop\Microepsilon sensors\MATLAB\optoNCDT";
libDef.Libraries = "C:\Users\max\Desktop\Microepsilon sensors\MATLAB\optoNCDT\MEDAQLib-4.7.0.30086\Release-x64\MEDAQLib.lib";

%% C++ enumeration |ME_SENSOR| with MATLAB name |clib.MEDAQLib.ME_SENSOR| 
addEnumeration(libDef, "ME_SENSOR", "int32",...
    [...
      "NO_SENSOR",...  % 0
      "SENSOR_ILR110x_115x",...  % 19
      "SENSOR_ILR118x",...  % 20
      "SENSOR_ILR1191",...  % 21
      "SENSOR_ILD1220",...  % 56
      "SENSOR_ILD1302",...  % 24
      "SENSOR_ILD1320",...  % 41
      "SENSOR_ILD1401",...  % 1
      "SENSOR_ILD1402",...  % 23
      "SENSOR_ILD1420",...  % 42
      "SENSOR_ILD1700",...  % 2
      "SENSOR_ILD1750",...  % 51
      "SENSOR_ILD2200",...  % 5
      "SENSOR_ILD2300",...  % 29
      "SENSOR_IFD2401",...  % 12
      "SENSOR_IFD2421",...  % 46
      "SENSOR_IFD2422",...  % 47
      "SENSOR_IFD2431",...  % 13
      "SENSOR_IFD2445",...  % 39
      "SENSOR_IFD2451",...  % 30
      "SENSOR_IFD2461",...  % 44
      "SENSOR_IFD2471",...  % 26
      "SENSOR_ODC1202",...  % 25
      "SENSOR_ODC2500",...  % 8
      "SENSOR_ODC2520",...  % 37
      "SENSOR_ODC2600",...  % 9
      "SENSOR_LLT27xx",...  % 31
      "SENSOR_DT3060",...  % 50
      "SENSOR_DT3100",...  % 28
      "SENSOR_DT6100",...  % 16
      "SENSOR_DT6120",...  % 40
      "CONTROLLER_DT6200",...  % 33
      "CONTROLLER_KSS6380",...  % 18
      "CONTROLLER_KSS64xx",...  % 45
      "CONTROLLER_DT6500",...  % 15
      "CONTROLLER_DT6536",...  % 54
      "SENSOR_ON_MEBUS",...  % 43
      "ENCODER_IF2004",...  % 10
      "PCI_CARD_IF2004",...  % 10
      "PCI_CARD_IF2008",...  % 22
      "ETH_ADAPTER_IF2008",...  % 52
      "CONTROLLER_CSP2008",...  % 32
      "ETH_IF1032",...  % 34
      "USB_ADAPTER_IF2004",...  % 36
      "CONTROLLER_CBOX",...  % 38
      "THICKNESS_SENSOR",...  % 48
      "SENSOR_ACS7000",...  % 35
      "SENSOR_CFO",...  % 53
      "SENSOR_GENERIC",...  % 49
      "NUMBER_OF_SENSORS",...  % 58
    ],...
    "MATLABName", "clib.MEDAQLib.ME_SENSOR", ...
    "Description", "clib.MEDAQLib.ME_SENSOR    Representation of C++ enumeration ME_SENSOR."); % Modify help description values as needed.

%% C++ enumeration |ERR_CODE| with MATLAB name |clib.MEDAQLib.ERR_CODE| 
addEnumeration(libDef, "ERR_CODE", "int32",...
    [...
      "ERR_NOERROR",...  % 0
      "ERR_FUNCTION_NOT_SUPPORTED",...  % -1
      "ERR_CANNOT_OPEN",...  % -2
      "ERR_NOT_OPEN",...  % -3
      "ERR_APPLYING_PARAMS",...  % -4
      "ERR_SEND_CMD_TO_SENSOR",...  % -5
      "ERR_CLEARING_BUFFER",...  % -6
      "ERR_HW_COMMUNICATION",...  % -7
      "ERR_TIMEOUT_READING_FROM_SENSOR",...  % -8
      "ERR_READING_SENSOR_DATA",...  % -9
      "ERR_INTERFACE_NOT_SUPPORTED",...  % -10
      "ERR_ALREADY_OPEN",...  % -11
      "ERR_CANNOT_CREATE_INTERFACE",...  % -12
      "ERR_NO_SENSORDATA_AVAILABLE",...  % -13
      "ERR_UNKNOWN_SENSOR_COMMAND",...  % -14
      "ERR_UNKNOWN_SENSOR_ANSWER",...  % -15
      "ERR_SENSOR_ANSWER_ERROR",...  % -16
      "ERR_SENSOR_ANSWER_TOO_SHORT",...  % -17
      "ERR_WRONG_PARAMETER",...  % -18
      "ERR_NOMEMORY",...  % -19
      "ERR_NO_ANSWER_RECEIVED",...  % -20
      "ERR_SENSOR_ANSWER_DOES_NOT_MATCH_COMMAND",...  % -21
      "ERR_BAUDRATE_TOO_LOW",...  % -22
      "ERR_OVERFLOW",...  % -23
      "ERR_INSTANCE_NOT_EXIST",...  % -24
      "ERR_NOT_FOUND",...  % -25
      "ERR_WARNING",...  % -26
      "ERR_SENSOR_ANSWER_WARNING",...  % -27
    ],...
    "MATLABName", "clib.MEDAQLib.ERR_CODE", ...
    "Description", "clib.MEDAQLib.ERR_CODE    Representation of C++ enumeration ERR_CODE."); % Modify help description values as needed.

%% C++ function |CreateSensorInstance| with MATLAB name |clib.MEDAQLib.CreateSensorInstance|
% C++ Signature: uint32_t CreateSensorInstance(ME_SENSOR sensorType)
CreateSensorInstanceDefinition = addFunction(libDef, ...
    "uint32_t CreateSensorInstance(ME_SENSOR sensorType)", ...
    "MATLABName", "clib.MEDAQLib.CreateSensorInstance", ...
    "Description", "clib.MEDAQLib.CreateSensorInstance    Representation of C++ function CreateSensorInstance."); % Modify help description values as needed.
defineArgument(CreateSensorInstanceDefinition, "sensorType", "clib.MEDAQLib.ME_SENSOR");
defineOutput(CreateSensorInstanceDefinition, "RetVal", "uint32");
validate(CreateSensorInstanceDefinition);

%% C++ function |CreateSensorInstByName| with MATLAB name |clib.MEDAQLib.CreateSensorInstByName|
% C++ Signature: uint32_t CreateSensorInstByName(char const * sensorName)
%CreateSensorInstByNameDefinition = addFunction(libDef, ...
%    "uint32_t CreateSensorInstByName(char const * sensorName)", ...
%    "MATLABName", "clib.MEDAQLib.CreateSensorInstByName", ...
%    "Description", "clib.MEDAQLib.CreateSensorInstByName    Representation of C++ function CreateSensorInstByName."); % Modify help description values as needed.
%defineArgument(CreateSensorInstByNameDefinition, "sensorName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(CreateSensorInstByNameDefinition, "RetVal", "uint32");
%validate(CreateSensorInstByNameDefinition);

%% C++ function |CreateSensorInstByNameU| with MATLAB name |clib.MEDAQLib.CreateSensorInstByNameU|
% C++ Signature: uint32_t CreateSensorInstByNameU(wchar_t const * sensorName)
%CreateSensorInstByNameUDefinition = addFunction(libDef, ...
%    "uint32_t CreateSensorInstByNameU(wchar_t const * sensorName)", ...
%    "MATLABName", "clib.MEDAQLib.CreateSensorInstByNameU", ...
%    "Description", "clib.MEDAQLib.CreateSensorInstByNameU    Representation of C++ function CreateSensorInstByNameU."); % Modify help description values as needed.
%defineArgument(CreateSensorInstByNameUDefinition, "sensorName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(CreateSensorInstByNameUDefinition, "RetVal", "uint32");
%validate(CreateSensorInstByNameUDefinition);

%% C++ function |ReleaseSensorInstance| with MATLAB name |clib.MEDAQLib.ReleaseSensorInstance|
% C++ Signature: ERR_CODE ReleaseSensorInstance(uint32_t instanceHandle)
ReleaseSensorInstanceDefinition = addFunction(libDef, ...
    "ERR_CODE ReleaseSensorInstance(uint32_t instanceHandle)", ...
    "MATLABName", "clib.MEDAQLib.ReleaseSensorInstance", ...
    "Description", "clib.MEDAQLib.ReleaseSensorInstance    Representation of C++ function ReleaseSensorInstance."); % Modify help description values as needed.
defineArgument(ReleaseSensorInstanceDefinition, "instanceHandle", "uint32");
defineOutput(ReleaseSensorInstanceDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(ReleaseSensorInstanceDefinition);

%% C++ function |SetParameterInt| with MATLAB name |clib.MEDAQLib.SetParameterInt|
% C++ Signature: ERR_CODE SetParameterInt(uint32_t instanceHandle,char const * paramName,int32_t paramValue)
%SetParameterIntDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterInt(uint32_t instanceHandle,char const * paramName,int32_t paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterInt", ...
%    "Description", "clib.MEDAQLib.SetParameterInt    Representation of C++ function SetParameterInt."); % Modify help description values as needed.
%defineArgument(SetParameterIntDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterIntDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetParameterIntDefinition, "paramValue", "int32");
%defineOutput(SetParameterIntDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterIntDefinition);

%% C++ function |SetParameterDouble| with MATLAB name |clib.MEDAQLib.SetParameterDouble|
% C++ Signature: ERR_CODE SetParameterDouble(uint32_t instanceHandle,char const * paramName,double paramValue)
%SetParameterDoubleDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterDouble(uint32_t instanceHandle,char const * paramName,double paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterDouble", ...
%    "Description", "clib.MEDAQLib.SetParameterDouble    Representation of C++ function SetParameterDouble."); % Modify help description values as needed.
%defineArgument(SetParameterDoubleDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterDoubleDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetParameterDoubleDefinition, "paramValue", "double");
%defineOutput(SetParameterDoubleDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterDoubleDefinition);

%% C++ function |SetParameterString| with MATLAB name |clib.MEDAQLib.SetParameterString|
% C++ Signature: ERR_CODE SetParameterString(uint32_t instanceHandle,char const * paramName,char const * paramValue)
%SetParameterStringDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterString(uint32_t instanceHandle,char const * paramName,char const * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterString", ...
%    "Description", "clib.MEDAQLib.SetParameterString    Representation of C++ function SetParameterString."); % Modify help description values as needed.
%defineArgument(SetParameterStringDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterStringDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetParameterStringDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(SetParameterStringDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterStringDefinition);

%% C++ function |SetParameterBinary| with MATLAB name |clib.MEDAQLib.SetParameterBinary|
% C++ Signature: ERR_CODE SetParameterBinary(uint32_t instanceHandle,char const * paramName,uint8_t const * paramValue,uint32_t len)
%SetParameterBinaryDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterBinary(uint32_t instanceHandle,char const * paramName,uint8_t const * paramValue,uint32_t len)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterBinary", ...
%    "Description", "clib.MEDAQLib.SetParameterBinary    Representation of C++ function SetParameterBinary."); % Modify help description values as needed.
%defineArgument(SetParameterBinaryDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterBinaryDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetParameterBinaryDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedChar, or uint8
%defineArgument(SetParameterBinaryDefinition, "len", "uint32");
%defineOutput(SetParameterBinaryDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterBinaryDefinition);

%% C++ function |SetParameters| with MATLAB name |clib.MEDAQLib.SetParameters|
% C++ Signature: ERR_CODE SetParameters(uint32_t instanceHandle,char const * parameterList)
%SetParametersDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameters(uint32_t instanceHandle,char const * parameterList)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameters", ...
%    "Description", "clib.MEDAQLib.SetParameters    Representation of C++ function SetParameters."); % Modify help description values as needed.
%defineArgument(SetParametersDefinition, "instanceHandle", "uint32");
%defineArgument(SetParametersDefinition, "parameterList", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(SetParametersDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParametersDefinition);

%% C++ function |SetParameterIntU| with MATLAB name |clib.MEDAQLib.SetParameterIntU|
% C++ Signature: ERR_CODE SetParameterIntU(uint32_t instanceHandle,wchar_t const * paramName,int32_t paramValue)
%SetParameterIntUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterIntU(uint32_t instanceHandle,wchar_t const * paramName,int32_t paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterIntU", ...
%    "Description", "clib.MEDAQLib.SetParameterIntU    Representation of C++ function SetParameterIntU."); % Modify help description values as needed.
%defineArgument(SetParameterIntUDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterIntUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetParameterIntUDefinition, "paramValue", "int32");
%defineOutput(SetParameterIntUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterIntUDefinition);

%% C++ function |SetParameterDoubleU| with MATLAB name |clib.MEDAQLib.SetParameterDoubleU|
% C++ Signature: ERR_CODE SetParameterDoubleU(uint32_t instanceHandle,wchar_t const * paramName,double paramValue)
%SetParameterDoubleUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterDoubleU(uint32_t instanceHandle,wchar_t const * paramName,double paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterDoubleU", ...
%    "Description", "clib.MEDAQLib.SetParameterDoubleU    Representation of C++ function SetParameterDoubleU."); % Modify help description values as needed.
%defineArgument(SetParameterDoubleUDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterDoubleUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetParameterDoubleUDefinition, "paramValue", "double");
%defineOutput(SetParameterDoubleUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterDoubleUDefinition);

%% C++ function |SetParameterStringU| with MATLAB name |clib.MEDAQLib.SetParameterStringU|
% C++ Signature: ERR_CODE SetParameterStringU(uint32_t instanceHandle,wchar_t const * paramName,wchar_t const * paramValue)
%SetParameterStringUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterStringU(uint32_t instanceHandle,wchar_t const * paramName,wchar_t const * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterStringU", ...
%    "Description", "clib.MEDAQLib.SetParameterStringU    Representation of C++ function SetParameterStringU."); % Modify help description values as needed.
%defineArgument(SetParameterStringUDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterStringUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetParameterStringUDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(SetParameterStringUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterStringUDefinition);

%% C++ function |SetParameterBinaryU| with MATLAB name |clib.MEDAQLib.SetParameterBinaryU|
% C++ Signature: ERR_CODE SetParameterBinaryU(uint32_t instanceHandle,wchar_t const * paramName,uint8_t const * paramValue,uint32_t len)
%SetParameterBinaryUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParameterBinaryU(uint32_t instanceHandle,wchar_t const * paramName,uint8_t const * paramValue,uint32_t len)", ...
%    "MATLABName", "clib.MEDAQLib.SetParameterBinaryU", ...
%    "Description", "clib.MEDAQLib.SetParameterBinaryU    Representation of C++ function SetParameterBinaryU."); % Modify help description values as needed.
%defineArgument(SetParameterBinaryUDefinition, "instanceHandle", "uint32");
%defineArgument(SetParameterBinaryUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetParameterBinaryUDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedChar, or uint8
%defineArgument(SetParameterBinaryUDefinition, "len", "uint32");
%defineOutput(SetParameterBinaryUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParameterBinaryUDefinition);

%% C++ function |SetParametersU| with MATLAB name |clib.MEDAQLib.SetParametersU|
% C++ Signature: ERR_CODE SetParametersU(uint32_t instanceHandle,wchar_t const * parameterList)
%SetParametersUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetParametersU(uint32_t instanceHandle,wchar_t const * parameterList)", ...
%    "MATLABName", "clib.MEDAQLib.SetParametersU", ...
%    "Description", "clib.MEDAQLib.SetParametersU    Representation of C++ function SetParametersU."); % Modify help description values as needed.
%defineArgument(SetParametersUDefinition, "instanceHandle", "uint32");
%defineArgument(SetParametersUDefinition, "parameterList", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(SetParametersUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetParametersUDefinition);

%% C++ function |GetParameterInt| with MATLAB name |clib.MEDAQLib.GetParameterInt|
% C++ Signature: ERR_CODE GetParameterInt(uint32_t instanceHandle,char const * paramName,int32_t * paramValue)
%GetParameterIntDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterInt(uint32_t instanceHandle,char const * paramName,int32_t * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterInt", ...
%    "Description", "clib.MEDAQLib.GetParameterInt    Representation of C++ function GetParameterInt."); % Modify help description values as needed.
%defineArgument(GetParameterIntDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterIntDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetParameterIntDefinition, "paramValue", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineOutput(GetParameterIntDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterIntDefinition);

%% C++ function |GetParameterDouble| with MATLAB name |clib.MEDAQLib.GetParameterDouble|
% C++ Signature: ERR_CODE GetParameterDouble(uint32_t instanceHandle,char const * paramName,double * paramValue)
%GetParameterDoubleDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterDouble(uint32_t instanceHandle,char const * paramName,double * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterDouble", ...
%    "Description", "clib.MEDAQLib.GetParameterDouble    Representation of C++ function GetParameterDouble."); % Modify help description values as needed.
%defineArgument(GetParameterDoubleDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterDoubleDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetParameterDoubleDefinition, "paramValue", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineOutput(GetParameterDoubleDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterDoubleDefinition);

%% C++ function |GetParameterString| with MATLAB name |clib.MEDAQLib.GetParameterString|
% C++ Signature: ERR_CODE GetParameterString(uint32_t instanceHandle,char const * paramName,char * paramValue,uint32_t * maxLen)
%GetParameterStringDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterString(uint32_t instanceHandle,char const * paramName,char * paramValue,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterString", ...
%    "Description", "clib.MEDAQLib.GetParameterString    Representation of C++ function GetParameterString."); % Modify help description values as needed.
%defineArgument(GetParameterStringDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterStringDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetParameterStringDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetParameterStringDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(GetParameterStringDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterStringDefinition);

%% C++ function |GetParameterBinary| with MATLAB name |clib.MEDAQLib.GetParameterBinary|
% C++ Signature: ERR_CODE GetParameterBinary(uint32_t instanceHandle,char const * paramName,uint8_t * paramValue,uint32_t * maxLen)
%GetParameterBinaryDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterBinary(uint32_t instanceHandle,char const * paramName,uint8_t * paramValue,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterBinary", ...
%    "Description", "clib.MEDAQLib.GetParameterBinary    Representation of C++ function GetParameterBinary."); % Modify help description values as needed.
%defineArgument(GetParameterBinaryDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterBinaryDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetParameterBinaryDefinition, "paramValue", "clib.array.MEDAQLib.UnsignedChar", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedChar, or uint8
%defineArgument(GetParameterBinaryDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(GetParameterBinaryDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterBinaryDefinition);

%% C++ function |GetParameters| with MATLAB name |clib.MEDAQLib.GetParameters|
% C++ Signature: ERR_CODE GetParameters(uint32_t instanceHandle,char * parameterList,uint32_t * maxLen)
%GetParametersDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameters(uint32_t instanceHandle,char * parameterList,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameters", ...
%    "Description", "clib.MEDAQLib.GetParameters    Representation of C++ function GetParameters."); % Modify help description values as needed.
%defineArgument(GetParametersDefinition, "instanceHandle", "uint32");
%defineArgument(GetParametersDefinition, "parameterList", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetParametersDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(GetParametersDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParametersDefinition);

%% C++ function |GetParameterIntU| with MATLAB name |clib.MEDAQLib.GetParameterIntU|
% C++ Signature: ERR_CODE GetParameterIntU(uint32_t instanceHandle,wchar_t const * paramName,int32_t * paramValue)
%GetParameterIntUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterIntU(uint32_t instanceHandle,wchar_t const * paramName,int32_t * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterIntU", ...
%    "Description", "clib.MEDAQLib.GetParameterIntU    Representation of C++ function GetParameterIntU."); % Modify help description values as needed.
%defineArgument(GetParameterIntUDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterIntUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetParameterIntUDefinition, "paramValue", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineOutput(GetParameterIntUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterIntUDefinition);

%% C++ function |GetParameterDoubleU| with MATLAB name |clib.MEDAQLib.GetParameterDoubleU|
% C++ Signature: ERR_CODE GetParameterDoubleU(uint32_t instanceHandle,wchar_t const * paramName,double * paramValue)
%GetParameterDoubleUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterDoubleU(uint32_t instanceHandle,wchar_t const * paramName,double * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterDoubleU", ...
%    "Description", "clib.MEDAQLib.GetParameterDoubleU    Representation of C++ function GetParameterDoubleU."); % Modify help description values as needed.
%defineArgument(GetParameterDoubleUDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterDoubleUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetParameterDoubleUDefinition, "paramValue", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineOutput(GetParameterDoubleUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterDoubleUDefinition);

%% C++ function |GetParameterStringU| with MATLAB name |clib.MEDAQLib.GetParameterStringU|
% C++ Signature: ERR_CODE GetParameterStringU(uint32_t instanceHandle,wchar_t const * paramName,wchar_t * paramValue,uint32_t * maxLen)
%GetParameterStringUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterStringU(uint32_t instanceHandle,wchar_t const * paramName,wchar_t * paramValue,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterStringU", ...
%    "Description", "clib.MEDAQLib.GetParameterStringU    Representation of C++ function GetParameterStringU."); % Modify help description values as needed.
%defineArgument(GetParameterStringUDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterStringUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetParameterStringUDefinition, "paramValue", "char", <DIRECTION>, <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetParameterStringUDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(GetParameterStringUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterStringUDefinition);

%% C++ function |GetParameterBinaryU| with MATLAB name |clib.MEDAQLib.GetParameterBinaryU|
% C++ Signature: ERR_CODE GetParameterBinaryU(uint32_t instanceHandle,wchar_t const * paramName,uint8_t * paramValue,uint32_t * maxLen)
%GetParameterBinaryUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParameterBinaryU(uint32_t instanceHandle,wchar_t const * paramName,uint8_t * paramValue,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetParameterBinaryU", ...
%    "Description", "clib.MEDAQLib.GetParameterBinaryU    Representation of C++ function GetParameterBinaryU."); % Modify help description values as needed.
%defineArgument(GetParameterBinaryUDefinition, "instanceHandle", "uint32");
%defineArgument(GetParameterBinaryUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetParameterBinaryUDefinition, "paramValue", "clib.array.MEDAQLib.UnsignedChar", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedChar, or uint8
%defineArgument(GetParameterBinaryUDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(GetParameterBinaryUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParameterBinaryUDefinition);

%% C++ function |GetParametersU| with MATLAB name |clib.MEDAQLib.GetParametersU|
% C++ Signature: ERR_CODE GetParametersU(uint32_t instanceHandle,wchar_t * parameterList,uint32_t * maxLen)
%GetParametersUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetParametersU(uint32_t instanceHandle,wchar_t * parameterList,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetParametersU", ...
%    "Description", "clib.MEDAQLib.GetParametersU    Representation of C++ function GetParametersU."); % Modify help description values as needed.
%defineArgument(GetParametersUDefinition, "instanceHandle", "uint32");
%defineArgument(GetParametersUDefinition, "parameterList", "char", <DIRECTION>, <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetParametersUDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(GetParametersUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetParametersUDefinition);

%% C++ function |ClearAllParameters| with MATLAB name |clib.MEDAQLib.ClearAllParameters|
% C++ Signature: ERR_CODE ClearAllParameters(uint32_t instanceHandle)
ClearAllParametersDefinition = addFunction(libDef, ...
    "ERR_CODE ClearAllParameters(uint32_t instanceHandle)", ...
    "MATLABName", "clib.MEDAQLib.ClearAllParameters", ...
    "Description", "clib.MEDAQLib.ClearAllParameters    Representation of C++ function ClearAllParameters."); % Modify help description values as needed.
defineArgument(ClearAllParametersDefinition, "instanceHandle", "uint32");
defineOutput(ClearAllParametersDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(ClearAllParametersDefinition);

%% C++ function |OpenSensor| with MATLAB name |clib.MEDAQLib.OpenSensor|
% C++ Signature: ERR_CODE OpenSensor(uint32_t instanceHandle)
OpenSensorDefinition = addFunction(libDef, ...
    "ERR_CODE OpenSensor(uint32_t instanceHandle)", ...
    "MATLABName", "clib.MEDAQLib.OpenSensor", ...
    "Description", "clib.MEDAQLib.OpenSensor    Representation of C++ function OpenSensor."); % Modify help description values as needed.
defineArgument(OpenSensorDefinition, "instanceHandle", "uint32");
defineOutput(OpenSensorDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(OpenSensorDefinition);

%% C++ function |CloseSensor| with MATLAB name |clib.MEDAQLib.CloseSensor|
% C++ Signature: ERR_CODE CloseSensor(uint32_t instanceHandle)
CloseSensorDefinition = addFunction(libDef, ...
    "ERR_CODE CloseSensor(uint32_t instanceHandle)", ...
    "MATLABName", "clib.MEDAQLib.CloseSensor", ...
    "Description", "clib.MEDAQLib.CloseSensor    Representation of C++ function CloseSensor."); % Modify help description values as needed.
defineArgument(CloseSensorDefinition, "instanceHandle", "uint32");
defineOutput(CloseSensorDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(CloseSensorDefinition);

%% C++ function |SensorCommand| with MATLAB name |clib.MEDAQLib.SensorCommand|
% C++ Signature: ERR_CODE SensorCommand(uint32_t instanceHandle)
SensorCommandDefinition = addFunction(libDef, ...
    "ERR_CODE SensorCommand(uint32_t instanceHandle)", ...
    "MATLABName", "clib.MEDAQLib.SensorCommand", ...
    "Description", "clib.MEDAQLib.SensorCommand    Representation of C++ function SensorCommand."); % Modify help description values as needed.
defineArgument(SensorCommandDefinition, "instanceHandle", "uint32");
defineOutput(SensorCommandDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(SensorCommandDefinition);

%% C++ function |DataAvail| with MATLAB name |clib.MEDAQLib.DataAvail|
% C++ Signature: ERR_CODE DataAvail(uint32_t instanceHandle,int32_t * avail)
%DataAvailDefinition = addFunction(libDef, ...
%    "ERR_CODE DataAvail(uint32_t instanceHandle,int32_t * avail)", ...
%    "MATLABName", "clib.MEDAQLib.DataAvail", ...
%    "Description", "clib.MEDAQLib.DataAvail    Representation of C++ function DataAvail."); % Modify help description values as needed.
%defineArgument(DataAvailDefinition, "instanceHandle", "uint32");
%defineArgument(DataAvailDefinition, "avail", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineOutput(DataAvailDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(DataAvailDefinition);

%% C++ function |TransferData| with MATLAB name |clib.MEDAQLib.TransferData|
% C++ Signature: ERR_CODE TransferData(uint32_t instanceHandle,int32_t * rawData,double * scaledData,int32_t maxValues,int32_t * read)
%TransferDataDefinition = addFunction(libDef, ...
%    "ERR_CODE TransferData(uint32_t instanceHandle,int32_t * rawData,double * scaledData,int32_t maxValues,int32_t * read)", ...
%    "MATLABName", "clib.MEDAQLib.TransferData", ...
%    "Description", "clib.MEDAQLib.TransferData    Representation of C++ function TransferData."); % Modify help description values as needed.
%defineArgument(TransferDataDefinition, "instanceHandle", "uint32");
%defineArgument(TransferDataDefinition, "rawData", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineArgument(TransferDataDefinition, "scaledData", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineArgument(TransferDataDefinition, "maxValues", "int32");
%defineArgument(TransferDataDefinition, "read", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineOutput(TransferDataDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(TransferDataDefinition);

%% C++ function |TransferDataTS| with MATLAB name |clib.MEDAQLib.TransferDataTS|
% C++ Signature: ERR_CODE TransferDataTS(uint32_t instanceHandle,int32_t * rawData,double * scaledData,int32_t maxValues,int32_t * read,double * timestamp)
%TransferDataTSDefinition = addFunction(libDef, ...
%    "ERR_CODE TransferDataTS(uint32_t instanceHandle,int32_t * rawData,double * scaledData,int32_t maxValues,int32_t * read,double * timestamp)", ...
%    "MATLABName", "clib.MEDAQLib.TransferDataTS", ...
%    "Description", "clib.MEDAQLib.TransferDataTS    Representation of C++ function TransferDataTS."); % Modify help description values as needed.
%defineArgument(TransferDataTSDefinition, "instanceHandle", "uint32");
%defineArgument(TransferDataTSDefinition, "rawData", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineArgument(TransferDataTSDefinition, "scaledData", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineArgument(TransferDataTSDefinition, "maxValues", "int32");
%defineArgument(TransferDataTSDefinition, "read", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineArgument(TransferDataTSDefinition, "timestamp", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineOutput(TransferDataTSDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(TransferDataTSDefinition);

%% C++ function |Poll| with MATLAB name |clib.MEDAQLib.Poll|
% C++ Signature: ERR_CODE Poll(uint32_t instanceHandle,int32_t * rawData,double * scaledData,int32_t maxValues)
%PollDefinition = addFunction(libDef, ...
%    "ERR_CODE Poll(uint32_t instanceHandle,int32_t * rawData,double * scaledData,int32_t maxValues)", ...
%    "MATLABName", "clib.MEDAQLib.Poll", ...
%    "Description", "clib.MEDAQLib.Poll    Representation of C++ function Poll."); % Modify help description values as needed.
%defineArgument(PollDefinition, "instanceHandle", "uint32");
%defineArgument(PollDefinition, "rawData", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineArgument(PollDefinition, "scaledData", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineArgument(PollDefinition, "maxValues", "int32");
%defineOutput(PollDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(PollDefinition);

%% C++ function |GetError| with MATLAB name |clib.MEDAQLib.GetError|
% C++ Signature: ERR_CODE GetError(uint32_t instanceHandle,char * errText,uint32_t maxLen)
%GetErrorDefinition = addFunction(libDef, ...
%    "ERR_CODE GetError(uint32_t instanceHandle,char * errText,uint32_t maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetError", ...
%    "Description", "clib.MEDAQLib.GetError    Representation of C++ function GetError."); % Modify help description values as needed.
%defineArgument(GetErrorDefinition, "instanceHandle", "uint32");
%defineArgument(GetErrorDefinition, "errText", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetErrorDefinition, "maxLen", "uint32");
%defineOutput(GetErrorDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetErrorDefinition);

%% C++ function |GetErrorU| with MATLAB name |clib.MEDAQLib.GetErrorU|
% C++ Signature: ERR_CODE GetErrorU(uint32_t instanceHandle,wchar_t * errText,uint32_t maxLen)
%GetErrorUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetErrorU(uint32_t instanceHandle,wchar_t * errText,uint32_t maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetErrorU", ...
%    "Description", "clib.MEDAQLib.GetErrorU    Representation of C++ function GetErrorU."); % Modify help description values as needed.
%defineArgument(GetErrorUDefinition, "instanceHandle", "uint32");
%defineArgument(GetErrorUDefinition, "errText", "char", <DIRECTION>, <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetErrorUDefinition, "maxLen", "uint32");
%defineOutput(GetErrorUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetErrorUDefinition);

%% C++ function |GetDLLVersion| with MATLAB name |clib.MEDAQLib.GetDLLVersion|
% C++ Signature: ERR_CODE GetDLLVersion(char * versionStr,uint32_t maxLen)
%GetDLLVersionDefinition = addFunction(libDef, ...
%    "ERR_CODE GetDLLVersion(char * versionStr,uint32_t maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetDLLVersion", ...
%    "Description", "clib.MEDAQLib.GetDLLVersion    Representation of C++ function GetDLLVersion."); % Modify help description values as needed.
%defineArgument(GetDLLVersionDefinition, "versionStr", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(GetDLLVersionDefinition, "maxLen", "uint32");
%defineOutput(GetDLLVersionDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetDLLVersionDefinition);

%% C++ function |GetDLLVersionU| with MATLAB name |clib.MEDAQLib.GetDLLVersionU|
% C++ Signature: ERR_CODE GetDLLVersionU(wchar_t * versionStr,uint32_t maxLen)
%GetDLLVersionUDefinition = addFunction(libDef, ...
%    "ERR_CODE GetDLLVersionU(wchar_t * versionStr,uint32_t maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.GetDLLVersionU", ...
%    "Description", "clib.MEDAQLib.GetDLLVersionU    Representation of C++ function GetDLLVersionU."); % Modify help description values as needed.
%defineArgument(GetDLLVersionUDefinition, "versionStr", "char", <DIRECTION>, <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(GetDLLVersionUDefinition, "maxLen", "uint32");
%defineOutput(GetDLLVersionUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(GetDLLVersionUDefinition);

%% C++ function |EnableLogging| with MATLAB name |clib.MEDAQLib.EnableLogging|
% C++ Signature: ERR_CODE EnableLogging(uint32_t instanceHandle,int32_t enableLogging,int32_t logTypes,int32_t logLevels,char const * logFile,int32_t logAppend,int32_t logFlush,int32_t logSplitSize)
%EnableLoggingDefinition = addFunction(libDef, ...
%    "ERR_CODE EnableLogging(uint32_t instanceHandle,int32_t enableLogging,int32_t logTypes,int32_t logLevels,char const * logFile,int32_t logAppend,int32_t logFlush,int32_t logSplitSize)", ...
%    "MATLABName", "clib.MEDAQLib.EnableLogging", ...
%    "Description", "clib.MEDAQLib.EnableLogging    Representation of C++ function EnableLogging."); % Modify help description values as needed.
%defineArgument(EnableLoggingDefinition, "instanceHandle", "uint32");
%defineArgument(EnableLoggingDefinition, "enableLogging", "int32");
%defineArgument(EnableLoggingDefinition, "logTypes", "int32");
%defineArgument(EnableLoggingDefinition, "logLevels", "int32");
%defineArgument(EnableLoggingDefinition, "logFile", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(EnableLoggingDefinition, "logAppend", "int32");
%defineArgument(EnableLoggingDefinition, "logFlush", "int32");
%defineArgument(EnableLoggingDefinition, "logSplitSize", "int32");
%defineOutput(EnableLoggingDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(EnableLoggingDefinition);

%% C++ function |EnableLoggingU| with MATLAB name |clib.MEDAQLib.EnableLoggingU|
% C++ Signature: ERR_CODE EnableLoggingU(uint32_t instanceHandle,int32_t enableLogging,int32_t logTypes,int32_t logLevels,wchar_t const * logFile,int32_t logAppend,int32_t logFlush,int32_t logSplitSize)
%EnableLoggingUDefinition = addFunction(libDef, ...
%    "ERR_CODE EnableLoggingU(uint32_t instanceHandle,int32_t enableLogging,int32_t logTypes,int32_t logLevels,wchar_t const * logFile,int32_t logAppend,int32_t logFlush,int32_t logSplitSize)", ...
%    "MATLABName", "clib.MEDAQLib.EnableLoggingU", ...
%    "Description", "clib.MEDAQLib.EnableLoggingU    Representation of C++ function EnableLoggingU."); % Modify help description values as needed.
%defineArgument(EnableLoggingUDefinition, "instanceHandle", "uint32");
%defineArgument(EnableLoggingUDefinition, "enableLogging", "int32");
%defineArgument(EnableLoggingUDefinition, "logTypes", "int32");
%defineArgument(EnableLoggingUDefinition, "logLevels", "int32");
%defineArgument(EnableLoggingUDefinition, "logFile", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(EnableLoggingUDefinition, "logAppend", "int32");
%defineArgument(EnableLoggingUDefinition, "logFlush", "int32");
%defineArgument(EnableLoggingUDefinition, "logSplitSize", "int32");
%defineOutput(EnableLoggingUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(EnableLoggingUDefinition);

%% C++ function |OpenSensorRS232| with MATLAB name |clib.MEDAQLib.OpenSensorRS232|
% C++ Signature: ERR_CODE OpenSensorRS232(uint32_t instanceHandle,char const * port)
%OpenSensorRS232Definition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorRS232(uint32_t instanceHandle,char const * port)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorRS232", ...
%    "Description", "clib.MEDAQLib.OpenSensorRS232    Representation of C++ function OpenSensorRS232."); % Modify help description values as needed.
%defineArgument(OpenSensorRS232Definition, "instanceHandle", "uint32");
%defineArgument(OpenSensorRS232Definition, "port", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(OpenSensorRS232Definition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorRS232Definition);

%% C++ function |OpenSensorIF2004| with MATLAB name |clib.MEDAQLib.OpenSensorIF2004|
% C++ Signature: ERR_CODE OpenSensorIF2004(uint32_t instanceHandle,int32_t cardInstance,int32_t channelNumber)
OpenSensorIF2004Definition = addFunction(libDef, ...
    "ERR_CODE OpenSensorIF2004(uint32_t instanceHandle,int32_t cardInstance,int32_t channelNumber)", ...
    "MATLABName", "clib.MEDAQLib.OpenSensorIF2004", ...
    "Description", "clib.MEDAQLib.OpenSensorIF2004    Representation of C++ function OpenSensorIF2004."); % Modify help description values as needed.
defineArgument(OpenSensorIF2004Definition, "instanceHandle", "uint32");
defineArgument(OpenSensorIF2004Definition, "cardInstance", "int32");
defineArgument(OpenSensorIF2004Definition, "channelNumber", "int32");
defineOutput(OpenSensorIF2004Definition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(OpenSensorIF2004Definition);

%% C++ function |OpenSensorIF2004_USB| with MATLAB name |clib.MEDAQLib.OpenSensorIF2004_USB|
% C++ Signature: ERR_CODE OpenSensorIF2004_USB(uint32_t instanceHandle,int32_t deviceInstance,char const * serialNumber,char const * port,int32_t channelNumber)
%OpenSensorIF2004_USBDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorIF2004_USB(uint32_t instanceHandle,int32_t deviceInstance,char const * serialNumber,char const * port,int32_t channelNumber)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorIF2004_USB", ...
%    "Description", "clib.MEDAQLib.OpenSensorIF2004_USB    Representation of C++ function OpenSensorIF2004_USB."); % Modify help description values as needed.
%defineArgument(OpenSensorIF2004_USBDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorIF2004_USBDefinition, "deviceInstance", "int32");
%defineArgument(OpenSensorIF2004_USBDefinition, "serialNumber", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(OpenSensorIF2004_USBDefinition, "port", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(OpenSensorIF2004_USBDefinition, "channelNumber", "int32");
%defineOutput(OpenSensorIF2004_USBDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorIF2004_USBDefinition);

%% C++ function |OpenSensorIF2008| with MATLAB name |clib.MEDAQLib.OpenSensorIF2008|
% C++ Signature: ERR_CODE OpenSensorIF2008(uint32_t instanceHandle,int32_t cardInstance,int32_t channelNumber)
OpenSensorIF2008Definition = addFunction(libDef, ...
    "ERR_CODE OpenSensorIF2008(uint32_t instanceHandle,int32_t cardInstance,int32_t channelNumber)", ...
    "MATLABName", "clib.MEDAQLib.OpenSensorIF2008", ...
    "Description", "clib.MEDAQLib.OpenSensorIF2008    Representation of C++ function OpenSensorIF2008."); % Modify help description values as needed.
defineArgument(OpenSensorIF2008Definition, "instanceHandle", "uint32");
defineArgument(OpenSensorIF2008Definition, "cardInstance", "int32");
defineArgument(OpenSensorIF2008Definition, "channelNumber", "int32");
defineOutput(OpenSensorIF2008Definition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(OpenSensorIF2008Definition);

%% C++ function |OpenSensorIF2008_ETH| with MATLAB name |clib.MEDAQLib.OpenSensorIF2008_ETH|
% C++ Signature: ERR_CODE OpenSensorIF2008_ETH(uint32_t instanceHandle,char const * remoteAddr,int32_t channelNumber)
%OpenSensorIF2008_ETHDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorIF2008_ETH(uint32_t instanceHandle,char const * remoteAddr,int32_t channelNumber)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorIF2008_ETH", ...
%    "Description", "clib.MEDAQLib.OpenSensorIF2008_ETH    Representation of C++ function OpenSensorIF2008_ETH."); % Modify help description values as needed.
%defineArgument(OpenSensorIF2008_ETHDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorIF2008_ETHDefinition, "remoteAddr", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(OpenSensorIF2008_ETHDefinition, "channelNumber", "int32");
%defineOutput(OpenSensorIF2008_ETHDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorIF2008_ETHDefinition);

%% C++ function |OpenSensorTCPIP| with MATLAB name |clib.MEDAQLib.OpenSensorTCPIP|
% C++ Signature: ERR_CODE OpenSensorTCPIP(uint32_t instanceHandle,char const * remoteAddr)
%OpenSensorTCPIPDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorTCPIP(uint32_t instanceHandle,char const * remoteAddr)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorTCPIP", ...
%    "Description", "clib.MEDAQLib.OpenSensorTCPIP    Representation of C++ function OpenSensorTCPIP."); % Modify help description values as needed.
%defineArgument(OpenSensorTCPIPDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorTCPIPDefinition, "remoteAddr", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(OpenSensorTCPIPDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorTCPIPDefinition);

%% C++ function |OpenSensorWinUSB| with MATLAB name |clib.MEDAQLib.OpenSensorWinUSB|
% C++ Signature: ERR_CODE OpenSensorWinUSB(uint32_t instanceHandle,int32_t deviceInstance)
OpenSensorWinUSBDefinition = addFunction(libDef, ...
    "ERR_CODE OpenSensorWinUSB(uint32_t instanceHandle,int32_t deviceInstance)", ...
    "MATLABName", "clib.MEDAQLib.OpenSensorWinUSB", ...
    "Description", "clib.MEDAQLib.OpenSensorWinUSB    Representation of C++ function OpenSensorWinUSB."); % Modify help description values as needed.
defineArgument(OpenSensorWinUSBDefinition, "instanceHandle", "uint32");
defineArgument(OpenSensorWinUSBDefinition, "deviceInstance", "int32");
defineOutput(OpenSensorWinUSBDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
validate(OpenSensorWinUSBDefinition);

%% C++ function |OpenSensorRS232U| with MATLAB name |clib.MEDAQLib.OpenSensorRS232U|
% C++ Signature: ERR_CODE OpenSensorRS232U(uint32_t instanceHandle,wchar_t const * port)
%OpenSensorRS232UDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorRS232U(uint32_t instanceHandle,wchar_t const * port)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorRS232U", ...
%    "Description", "clib.MEDAQLib.OpenSensorRS232U    Representation of C++ function OpenSensorRS232U."); % Modify help description values as needed.
%defineArgument(OpenSensorRS232UDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorRS232UDefinition, "port", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(OpenSensorRS232UDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorRS232UDefinition);

%% C++ function |OpenSensorIF2004_USBU| with MATLAB name |clib.MEDAQLib.OpenSensorIF2004_USBU|
% C++ Signature: ERR_CODE OpenSensorIF2004_USBU(uint32_t instanceHandle,int32_t deviceInstance,wchar_t const * serialNumber,wchar_t const * port,int32_t channelNumber)
%OpenSensorIF2004_USBUDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorIF2004_USBU(uint32_t instanceHandle,int32_t deviceInstance,wchar_t const * serialNumber,wchar_t const * port,int32_t channelNumber)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorIF2004_USBU", ...
%    "Description", "clib.MEDAQLib.OpenSensorIF2004_USBU    Representation of C++ function OpenSensorIF2004_USBU."); % Modify help description values as needed.
%defineArgument(OpenSensorIF2004_USBUDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorIF2004_USBUDefinition, "deviceInstance", "int32");
%defineArgument(OpenSensorIF2004_USBUDefinition, "serialNumber", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(OpenSensorIF2004_USBUDefinition, "port", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(OpenSensorIF2004_USBUDefinition, "channelNumber", "int32");
%defineOutput(OpenSensorIF2004_USBUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorIF2004_USBUDefinition);

%% C++ function |OpenSensorIF2008_ETHU| with MATLAB name |clib.MEDAQLib.OpenSensorIF2008_ETHU|
% C++ Signature: ERR_CODE OpenSensorIF2008_ETHU(uint32_t instanceHandle,wchar_t const * remoteAddr,int32_t channelNumber)
%OpenSensorIF2008_ETHUDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorIF2008_ETHU(uint32_t instanceHandle,wchar_t const * remoteAddr,int32_t channelNumber)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorIF2008_ETHU", ...
%    "Description", "clib.MEDAQLib.OpenSensorIF2008_ETHU    Representation of C++ function OpenSensorIF2008_ETHU."); % Modify help description values as needed.
%defineArgument(OpenSensorIF2008_ETHUDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorIF2008_ETHUDefinition, "remoteAddr", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(OpenSensorIF2008_ETHUDefinition, "channelNumber", "int32");
%defineOutput(OpenSensorIF2008_ETHUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorIF2008_ETHUDefinition);

%% C++ function |OpenSensorTCPIPU| with MATLAB name |clib.MEDAQLib.OpenSensorTCPIPU|
% C++ Signature: ERR_CODE OpenSensorTCPIPU(uint32_t instanceHandle,wchar_t const * remoteAddr)
%OpenSensorTCPIPUDefinition = addFunction(libDef, ...
%    "ERR_CODE OpenSensorTCPIPU(uint32_t instanceHandle,wchar_t const * remoteAddr)", ...
%    "MATLABName", "clib.MEDAQLib.OpenSensorTCPIPU", ...
%    "Description", "clib.MEDAQLib.OpenSensorTCPIPU    Representation of C++ function OpenSensorTCPIPU."); % Modify help description values as needed.
%defineArgument(OpenSensorTCPIPUDefinition, "instanceHandle", "uint32");
%defineArgument(OpenSensorTCPIPUDefinition, "remoteAddr", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(OpenSensorTCPIPUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(OpenSensorTCPIPUDefinition);

%% C++ function |ExecSCmd| with MATLAB name |clib.MEDAQLib.ExecSCmd|
% C++ Signature: ERR_CODE ExecSCmd(uint32_t instanceHandle,char const * sensorCommand)
%ExecSCmdDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmd(uint32_t instanceHandle,char const * sensorCommand)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmd", ...
%    "Description", "clib.MEDAQLib.ExecSCmd    Representation of C++ function ExecSCmd."); % Modify help description values as needed.
%defineArgument(ExecSCmdDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(ExecSCmdDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdDefinition);

%% C++ function |SetIntExecSCmd| with MATLAB name |clib.MEDAQLib.SetIntExecSCmd|
% C++ Signature: ERR_CODE SetIntExecSCmd(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,int32_t paramValue)
%SetIntExecSCmdDefinition = addFunction(libDef, ...
%    "ERR_CODE SetIntExecSCmd(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,int32_t paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetIntExecSCmd", ...
%    "Description", "clib.MEDAQLib.SetIntExecSCmd    Representation of C++ function SetIntExecSCmd."); % Modify help description values as needed.
%defineArgument(SetIntExecSCmdDefinition, "instanceHandle", "uint32");
%defineArgument(SetIntExecSCmdDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetIntExecSCmdDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetIntExecSCmdDefinition, "paramValue", "int32");
%defineOutput(SetIntExecSCmdDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetIntExecSCmdDefinition);

%% C++ function |SetDoubleExecSCmd| with MATLAB name |clib.MEDAQLib.SetDoubleExecSCmd|
% C++ Signature: ERR_CODE SetDoubleExecSCmd(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,double paramValue)
%SetDoubleExecSCmdDefinition = addFunction(libDef, ...
%    "ERR_CODE SetDoubleExecSCmd(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,double paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetDoubleExecSCmd", ...
%    "Description", "clib.MEDAQLib.SetDoubleExecSCmd    Representation of C++ function SetDoubleExecSCmd."); % Modify help description values as needed.
%defineArgument(SetDoubleExecSCmdDefinition, "instanceHandle", "uint32");
%defineArgument(SetDoubleExecSCmdDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetDoubleExecSCmdDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetDoubleExecSCmdDefinition, "paramValue", "double");
%defineOutput(SetDoubleExecSCmdDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetDoubleExecSCmdDefinition);

%% C++ function |SetStringExecSCmd| with MATLAB name |clib.MEDAQLib.SetStringExecSCmd|
% C++ Signature: ERR_CODE SetStringExecSCmd(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,char const * paramValue)
%SetStringExecSCmdDefinition = addFunction(libDef, ...
%    "ERR_CODE SetStringExecSCmd(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,char const * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetStringExecSCmd", ...
%    "Description", "clib.MEDAQLib.SetStringExecSCmd    Representation of C++ function SetStringExecSCmd."); % Modify help description values as needed.
%defineArgument(SetStringExecSCmdDefinition, "instanceHandle", "uint32");
%defineArgument(SetStringExecSCmdDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetStringExecSCmdDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(SetStringExecSCmdDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineOutput(SetStringExecSCmdDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetStringExecSCmdDefinition);

%% C++ function |ExecSCmdGetInt| with MATLAB name |clib.MEDAQLib.ExecSCmdGetInt|
% C++ Signature: ERR_CODE ExecSCmdGetInt(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,int32_t * paramValue)
%ExecSCmdGetIntDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdGetInt(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,int32_t * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdGetInt", ...
%    "Description", "clib.MEDAQLib.ExecSCmdGetInt    Representation of C++ function ExecSCmdGetInt."); % Modify help description values as needed.
%defineArgument(ExecSCmdGetIntDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdGetIntDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetIntDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetIntDefinition, "paramValue", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineOutput(ExecSCmdGetIntDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdGetIntDefinition);

%% C++ function |ExecSCmdGetDouble| with MATLAB name |clib.MEDAQLib.ExecSCmdGetDouble|
% C++ Signature: ERR_CODE ExecSCmdGetDouble(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,double * paramValue)
%ExecSCmdGetDoubleDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdGetDouble(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,double * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdGetDouble", ...
%    "Description", "clib.MEDAQLib.ExecSCmdGetDouble    Representation of C++ function ExecSCmdGetDouble."); % Modify help description values as needed.
%defineArgument(ExecSCmdGetDoubleDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdGetDoubleDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetDoubleDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetDoubleDefinition, "paramValue", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineOutput(ExecSCmdGetDoubleDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdGetDoubleDefinition);

%% C++ function |ExecSCmdGetString| with MATLAB name |clib.MEDAQLib.ExecSCmdGetString|
% C++ Signature: ERR_CODE ExecSCmdGetString(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,char * paramValue,uint32_t * maxLen)
%ExecSCmdGetStringDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdGetString(uint32_t instanceHandle,char const * sensorCommand,char const * paramName,char * paramValue,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdGetString", ...
%    "Description", "clib.MEDAQLib.ExecSCmdGetString    Representation of C++ function ExecSCmdGetString."); % Modify help description values as needed.
%defineArgument(ExecSCmdGetStringDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdGetStringDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetStringDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetStringDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Char,int8,string, or char
%defineArgument(ExecSCmdGetStringDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(ExecSCmdGetStringDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdGetStringDefinition);

%% C++ function |ExecSCmdU| with MATLAB name |clib.MEDAQLib.ExecSCmdU|
% C++ Signature: ERR_CODE ExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand)
%ExecSCmdUDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdU", ...
%    "Description", "clib.MEDAQLib.ExecSCmdU    Representation of C++ function ExecSCmdU."); % Modify help description values as needed.
%defineArgument(ExecSCmdUDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(ExecSCmdUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdUDefinition);

%% C++ function |SetIntExecSCmdU| with MATLAB name |clib.MEDAQLib.SetIntExecSCmdU|
% C++ Signature: ERR_CODE SetIntExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,int32_t paramValue)
%SetIntExecSCmdUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetIntExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,int32_t paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetIntExecSCmdU", ...
%    "Description", "clib.MEDAQLib.SetIntExecSCmdU    Representation of C++ function SetIntExecSCmdU."); % Modify help description values as needed.
%defineArgument(SetIntExecSCmdUDefinition, "instanceHandle", "uint32");
%defineArgument(SetIntExecSCmdUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetIntExecSCmdUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetIntExecSCmdUDefinition, "paramValue", "int32");
%defineOutput(SetIntExecSCmdUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetIntExecSCmdUDefinition);

%% C++ function |SetDoubleExecSCmdU| with MATLAB name |clib.MEDAQLib.SetDoubleExecSCmdU|
% C++ Signature: ERR_CODE SetDoubleExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,double paramValue)
%SetDoubleExecSCmdUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetDoubleExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,double paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetDoubleExecSCmdU", ...
%    "Description", "clib.MEDAQLib.SetDoubleExecSCmdU    Representation of C++ function SetDoubleExecSCmdU."); % Modify help description values as needed.
%defineArgument(SetDoubleExecSCmdUDefinition, "instanceHandle", "uint32");
%defineArgument(SetDoubleExecSCmdUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetDoubleExecSCmdUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetDoubleExecSCmdUDefinition, "paramValue", "double");
%defineOutput(SetDoubleExecSCmdUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetDoubleExecSCmdUDefinition);

%% C++ function |SetStringExecSCmdU| with MATLAB name |clib.MEDAQLib.SetStringExecSCmdU|
% C++ Signature: ERR_CODE SetStringExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,wchar_t const * paramValue)
%SetStringExecSCmdUDefinition = addFunction(libDef, ...
%    "ERR_CODE SetStringExecSCmdU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,wchar_t const * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.SetStringExecSCmdU", ...
%    "Description", "clib.MEDAQLib.SetStringExecSCmdU    Representation of C++ function SetStringExecSCmdU."); % Modify help description values as needed.
%defineArgument(SetStringExecSCmdUDefinition, "instanceHandle", "uint32");
%defineArgument(SetStringExecSCmdUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetStringExecSCmdUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(SetStringExecSCmdUDefinition, "paramValue", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineOutput(SetStringExecSCmdUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(SetStringExecSCmdUDefinition);

%% C++ function |ExecSCmdGetIntU| with MATLAB name |clib.MEDAQLib.ExecSCmdGetIntU|
% C++ Signature: ERR_CODE ExecSCmdGetIntU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,int32_t * paramValue)
%ExecSCmdGetIntUDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdGetIntU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,int32_t * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdGetIntU", ...
%    "Description", "clib.MEDAQLib.ExecSCmdGetIntU    Representation of C++ function ExecSCmdGetIntU."); % Modify help description values as needed.
%defineArgument(ExecSCmdGetIntUDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdGetIntUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetIntUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetIntUDefinition, "paramValue", "clib.array.MEDAQLib.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Int, or int32
%defineOutput(ExecSCmdGetIntUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdGetIntUDefinition);

%% C++ function |ExecSCmdGetDoubleU| with MATLAB name |clib.MEDAQLib.ExecSCmdGetDoubleU|
% C++ Signature: ERR_CODE ExecSCmdGetDoubleU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,double * paramValue)
%ExecSCmdGetDoubleUDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdGetDoubleU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,double * paramValue)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdGetDoubleU", ...
%    "Description", "clib.MEDAQLib.ExecSCmdGetDoubleU    Representation of C++ function ExecSCmdGetDoubleU."); % Modify help description values as needed.
%defineArgument(ExecSCmdGetDoubleUDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdGetDoubleUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetDoubleUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetDoubleUDefinition, "paramValue", "clib.array.MEDAQLib.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.Double, or double
%defineOutput(ExecSCmdGetDoubleUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdGetDoubleUDefinition);

%% C++ function |ExecSCmdGetStringU| with MATLAB name |clib.MEDAQLib.ExecSCmdGetStringU|
% C++ Signature: ERR_CODE ExecSCmdGetStringU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,wchar_t * paramValue,uint32_t * maxLen)
%ExecSCmdGetStringUDefinition = addFunction(libDef, ...
%    "ERR_CODE ExecSCmdGetStringU(uint32_t instanceHandle,wchar_t const * sensorCommand,wchar_t const * paramName,wchar_t * paramValue,uint32_t * maxLen)", ...
%    "MATLABName", "clib.MEDAQLib.ExecSCmdGetStringU", ...
%    "Description", "clib.MEDAQLib.ExecSCmdGetStringU    Representation of C++ function ExecSCmdGetStringU."); % Modify help description values as needed.
%defineArgument(ExecSCmdGetStringUDefinition, "instanceHandle", "uint32");
%defineArgument(ExecSCmdGetStringUDefinition, "sensorCommand", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetStringUDefinition, "paramName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetStringUDefinition, "paramValue", "char", <DIRECTION>, <SHAPE>); % '<MLTYPE>' can be char, or string
%defineArgument(ExecSCmdGetStringUDefinition, "maxLen", "clib.array.MEDAQLib.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.MEDAQLib.UnsignedInt, or uint32
%defineOutput(ExecSCmdGetStringUDefinition, "RetVal", "clib.MEDAQLib.ERR_CODE");
%validate(ExecSCmdGetStringUDefinition);

%% Validate the library definition
validate(libDef);

end
