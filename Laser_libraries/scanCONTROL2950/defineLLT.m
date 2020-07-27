%% About defineLLT.mlx
% This file defines the MATLAB interface to the library |LLT|.
%
% Commented sections represent C++ functionality that MATLAB cannot automatically define. To include
% functionality, uncomment a section and provide values for &lt;SHAPE&gt;, &lt;DIRECTION&gt;, etc. For more
% information, see <matlab:helpview(fullfile(docroot,'matlab','helptargets.map'),'cpp_define_interface') Define MATLAB Interface for C++ Library>.



%% Setup. Do not edit this section.
function libDef = defineLLT()
libDef = clibgen.LibraryDefinition("LLTData.xml");
%% OutputFolder and Libraries 
libDef.OutputFolder = "C:\Users\max\Desktop\Microepsilon sensors\MATLAB\scanCONTROL";
libDef.Libraries = "C:\Users\max\Desktop\Microepsilon sensors\MATLAB\scanCONTROL\C++ SDK (+python bindings)\lib\x64\LLT.lib";

%% C++ enumeration |TScannerType| with MATLAB name |clib.LLT.TScannerType| 
addEnumeration(libDef, "TScannerType", "int32",...
    [...
      "StandardType",...  % -1
      "LLT25",...  % 0
      "LLT100",...  % 1
      "scanCONTROL28xx_25",...  % 0
      "scanCONTROL28xx_100",...  % 1
      "scanCONTROL28xx_10",...  % 2
      "scanCONTROL28xx_xxx",...  % 999
      "scanCONTROL27xx_25",...  % 1000
      "scanCONTROL27xx_100",...  % 1001
      "scanCONTROL27xx_50",...  % 1002
      "scanCONTROL2751_25",...  % 1020
      "scanCONTROL2751_100",...  % 1021
      "scanCONTROL2702_50",...  % 1032
      "scanCONTROL27xx_xxx",...  % 1999
      "scanCONTROL26xx_25",...  % 2000
      "scanCONTROL26xx_100",...  % 2001
      "scanCONTROL26xx_50",...  % 2002
      "scanCONTROL26xx_10",...  % 2003
      "scanCONTROL26xx_xxx",...  % 2999
      "scanCONTROL29xx_25",...  % 3000
      "scanCONTROL29xx_100",...  % 3001
      "scanCONTROL29xx_50",...  % 3002
      "scanCONTROL29xx_10",...  % 3003
      "scanCONTROL2905_50",...  % 3010
      "scanCONTROL2905_100",...  % 3011
      "scanCONTROL2953_30",...  % 3033
      "scanCONTROL2954_10",...  % 3034
      "scanCONTROL2954_25",...  % 3035
      "scanCONTROL2954_50",...  % 3036
      "scanCONTROL2954_100",...  % 3037
      "scanCONTROL2954_xxx",...  % 3038
      "scanCONTROL2968_10",...  % 3040
      "scanCONTROL2968_25",...  % 3041
      "scanCONTROL2968_50",...  % 3042
      "scanCONTROL2968_100",...  % 3043
      "scanCONTROL2968_xxx",...  % 3044
      "scanCONTROL29xx_xxx",...  % 3999
      "scanCONTROL30xx_25",...  % 4000
      "scanCONTROL30xx_50",...  % 4001
      "scanCONTROL30xx_200",...  % 4002
      "scanCONTROL30xx_xxx",...  % 4999
      "scanCONTROL25xx_25",...  % 5000
      "scanCONTROL25xx_100",...  % 5001
      "scanCONTROL25xx_50",...  % 5002
      "scanCONTROL25xx_10",...  % 5003
      "scanCONTROL25xx_xxx",...  % 5999
      "scanCONTROL2xxx",...  % 6000
    ],...
    "MATLABName", "clib.LLT.TScannerType", ...
    "Description", "clib.LLT.TScannerType    Representation of C++ enumeration TScannerType."); % Modify help description values as needed.

%% C++ enumeration |TProfileConfig| with MATLAB name |clib.LLT.TProfileConfig| 
addEnumeration(libDef, "TProfileConfig", "int32",...
    [...
      "NONE",...  % 0
      "PROFILE",...  % 1
      "CONTAINER",...  % 1
      "VIDEO_IMAGE",...  % 1
      "PURE_PROFILE",...  % 2
      "QUARTER_PROFILE",...  % 3
      "CSV_PROFILE",...  % 4
      "PARTIAL_PROFILE",...  % 5
    ],...
    "MATLABName", "clib.LLT.TProfileConfig", ...
    "Description", "clib.LLT.TProfileConfig    Representation of C++ enumeration TProfileConfig."); % Modify help description values as needed.

%% C++ enumeration |TCallbackType| with MATLAB name |clib.LLT.TCallbackType| 
addEnumeration(libDef, "TCallbackType", "int32",...
    [...
      "STD_CALL",...  % 0
      "C_DECL",...  % 1
    ],...
    "MATLABName", "clib.LLT.TCallbackType", ...
    "Description", "clib.LLT.TCallbackType    Representation of C++ enumeration TCallbackType."); % Modify help description values as needed.

%% C++ enumeration |TFileType| with MATLAB name |clib.LLT.TFileType| 
addEnumeration(libDef, "TFileType", "int32",...
    [...
      "AVI",...  % 0
      "LLT",...  % 1
      "CSV",...  % 2
      "BMP",...  % 3
      "CSV_NEG",...  % 4
    ],...
    "MATLABName", "clib.LLT.TFileType", ...
    "Description", "clib.LLT.TFileType    Representation of C++ enumeration TFileType."); % Modify help description values as needed.

%% C++ class |TPartialProfile| with MATLAB name |clib.LLT.TPartialProfile| 
TPartialProfileDefinition = addClass(libDef, "TPartialProfile", "MATLABName", "clib.LLT.TPartialProfile", ...
    "Description", "clib.LLT.TPartialProfile    Representation of C++ class TPartialProfile."); % Modify help description values as needed.

%% C++ class constructor for C++ class |TPartialProfile| 
% C++ Signature: TPartialProfile::TPartialProfile()
TPartialProfileConstructor1Definition = addConstructor(TPartialProfileDefinition, ...
    "TPartialProfile::TPartialProfile()", ...
    "Description", "clib.LLT.TPartialProfile.TPartialProfile    Constructor of C++ class TPartialProfile."); % Modify help description values as needed.
validate(TPartialProfileConstructor1Definition);

%% C++ class constructor for C++ class |TPartialProfile| 
% C++ Signature: TPartialProfile::TPartialProfile(TPartialProfile const & input1)
TPartialProfileConstructor2Definition = addConstructor(TPartialProfileDefinition, ...
    "TPartialProfile::TPartialProfile(TPartialProfile const & input1)", ...
    "Description", "clib.LLT.TPartialProfile.TPartialProfile    Constructor of C++ class TPartialProfile."); % Modify help description values as needed.
defineArgument(TPartialProfileConstructor2Definition, "input1", "clib.LLT.TPartialProfile", "input");
validate(TPartialProfileConstructor2Definition);

%% C++ class public data member |nStartPoint| for C++ class |TPartialProfile| 
% C++ Signature: unsigned int TPartialProfile::nStartPoint
addProperty(TPartialProfileDefinition, "nStartPoint", "uint32", ...
    "Description", "uint32    Data member of C++ class TPartialProfile."); % Modify help description values as needed.

%% C++ class public data member |nStartPointData| for C++ class |TPartialProfile| 
% C++ Signature: unsigned int TPartialProfile::nStartPointData
addProperty(TPartialProfileDefinition, "nStartPointData", "uint32", ...
    "Description", "uint32    Data member of C++ class TPartialProfile."); % Modify help description values as needed.

%% C++ class public data member |nPointCount| for C++ class |TPartialProfile| 
% C++ Signature: unsigned int TPartialProfile::nPointCount
addProperty(TPartialProfileDefinition, "nPointCount", "uint32", ...
    "Description", "uint32    Data member of C++ class TPartialProfile."); % Modify help description values as needed.

%% C++ class public data member |nPointDataWidth| for C++ class |TPartialProfile| 
% C++ Signature: unsigned int TPartialProfile::nPointDataWidth
addProperty(TPartialProfileDefinition, "nPointDataWidth", "uint32", ...
    "Description", "uint32    Data member of C++ class TPartialProfile."); % Modify help description values as needed.

%% C++ enumeration |TTransferProfileType| with MATLAB name |clib.LLT.TTransferProfileType| 
addEnumeration(libDef, "TTransferProfileType", "int32",...
    [...
      "NORMAL_TRANSFER",...  % 0
      "SHOT_TRANSFER",...  % 1
      "NORMAL_CONTAINER_MODE",...  % 2
      "SHOT_CONTAINER_MODE",...  % 3
      "NONE_TRANSFER",...  % 4
    ],...
    "MATLABName", "clib.LLT.TTransferProfileType", ...
    "Description", "clib.LLT.TTransferProfileType    Representation of C++ enumeration TTransferProfileType."); % Modify help description values as needed.

%% C++ enumeration |TInterfaceType| with MATLAB name |clib.LLT.TInterfaceType| 
addEnumeration(libDef, "TInterfaceType", "int32",...
    [...
      "INTF_TYPE_UNKNOWN",...  % 0
      "INTF_TYPE_SERIAL",...  % 1
      "INTF_TYPE_FIREWIRE",...  % 2
      "INTF_TYPE_ETHERNET",...  % 3
    ],...
    "MATLABName", "clib.LLT.TInterfaceType", ...
    "Description", "clib.LLT.TInterfaceType    Representation of C++ enumeration TInterfaceType."); % Modify help description values as needed.

%% C++ function |s_CreateLLTDevice| with MATLAB name |clib.LLT.s_CreateLLTDevice|
% C++ Signature: long s_CreateLLTDevice(TInterfaceType iInterfaceType)
s_CreateLLTDeviceDefinition = addFunction(libDef, ...
    "long s_CreateLLTDevice(TInterfaceType iInterfaceType)", ...
    "MATLABName", "clib.LLT.s_CreateLLTDevice", ...
    "Description", "clib.LLT.s_CreateLLTDevice    Representation of C++ function s_CreateLLTDevice."); % Modify help description values as needed.
defineArgument(s_CreateLLTDeviceDefinition, "iInterfaceType", "clib.LLT.TInterfaceType");
defineOutput(s_CreateLLTDeviceDefinition, "RetVal", "int32");
validate(s_CreateLLTDeviceDefinition);

%% C++ function |s_CreateLLTFirewire| with MATLAB name |clib.LLT.s_CreateLLTFirewire|
% C++ Signature: long s_CreateLLTFirewire()
s_CreateLLTFirewireDefinition = addFunction(libDef, ...
    "long s_CreateLLTFirewire()", ...
    "MATLABName", "clib.LLT.s_CreateLLTFirewire", ...
    "Description", "clib.LLT.s_CreateLLTFirewire    Representation of C++ function s_CreateLLTFirewire."); % Modify help description values as needed.
defineOutput(s_CreateLLTFirewireDefinition, "RetVal", "int32");
validate(s_CreateLLTFirewireDefinition);

%% C++ function |s_CreateLLTSerial| with MATLAB name |clib.LLT.s_CreateLLTSerial|
% C++ Signature: long s_CreateLLTSerial()
s_CreateLLTSerialDefinition = addFunction(libDef, ...
    "long s_CreateLLTSerial()", ...
    "MATLABName", "clib.LLT.s_CreateLLTSerial", ...
    "Description", "clib.LLT.s_CreateLLTSerial    Representation of C++ function s_CreateLLTSerial."); % Modify help description values as needed.
defineOutput(s_CreateLLTSerialDefinition, "RetVal", "int32");
validate(s_CreateLLTSerialDefinition);

%% C++ function |s_GetInterfaceType| with MATLAB name |clib.LLT.s_GetInterfaceType|
% C++ Signature: int s_GetInterfaceType(long pLLT)
s_GetInterfaceTypeDefinition = addFunction(libDef, ...
    "int s_GetInterfaceType(long pLLT)", ...
    "MATLABName", "clib.LLT.s_GetInterfaceType", ...
    "Description", "clib.LLT.s_GetInterfaceType    Representation of C++ function s_GetInterfaceType."); % Modify help description values as needed.
defineArgument(s_GetInterfaceTypeDefinition, "pLLT", "int32");
defineOutput(s_GetInterfaceTypeDefinition, "RetVal", "int32");
validate(s_GetInterfaceTypeDefinition);

%% C++ function |s_DelDevice| with MATLAB name |clib.LLT.s_DelDevice|
% C++ Signature: int s_DelDevice(long pLLT)
s_DelDeviceDefinition = addFunction(libDef, ...
    "int s_DelDevice(long pLLT)", ...
    "MATLABName", "clib.LLT.s_DelDevice", ...
    "Description", "clib.LLT.s_DelDevice    Representation of C++ function s_DelDevice."); % Modify help description values as needed.
defineArgument(s_DelDeviceDefinition, "pLLT", "int32");
defineOutput(s_DelDeviceDefinition, "RetVal", "int32");
validate(s_DelDeviceDefinition);

%% C++ function |s_Connect| with MATLAB name |clib.LLT.s_Connect|
% C++ Signature: int s_Connect(long pLLT)
s_ConnectDefinition = addFunction(libDef, ...
    "int s_Connect(long pLLT)", ...
    "MATLABName", "clib.LLT.s_Connect", ...
    "Description", "clib.LLT.s_Connect    Representation of C++ function s_Connect."); % Modify help description values as needed.
defineArgument(s_ConnectDefinition, "pLLT", "int32");
defineOutput(s_ConnectDefinition, "RetVal", "int32");
validate(s_ConnectDefinition);

%% C++ function |s_Disconnect| with MATLAB name |clib.LLT.s_Disconnect|
% C++ Signature: int s_Disconnect(long pLLT)
s_DisconnectDefinition = addFunction(libDef, ...
    "int s_Disconnect(long pLLT)", ...
    "MATLABName", "clib.LLT.s_Disconnect", ...
    "Description", "clib.LLT.s_Disconnect    Representation of C++ function s_Disconnect."); % Modify help description values as needed.
defineArgument(s_DisconnectDefinition, "pLLT", "int32");
defineOutput(s_DisconnectDefinition, "RetVal", "int32");
validate(s_DisconnectDefinition);

%% C++ function |s_ExportLLTConfig| with MATLAB name |clib.LLT.s_ExportLLTConfig|
% C++ Signature: int s_ExportLLTConfig(long pLLT,char const * pFileName)
%s_ExportLLTConfigDefinition = addFunction(libDef, ...
%    "int s_ExportLLTConfig(long pLLT,char const * pFileName)", ...
%    "MATLABName", "clib.LLT.s_ExportLLTConfig", ...
%    "Description", "clib.LLT.s_ExportLLTConfig    Representation of C++ function s_ExportLLTConfig."); % Modify help description values as needed.
%defineArgument(s_ExportLLTConfigDefinition, "pLLT", "int32");
%defineArgument(s_ExportLLTConfigDefinition, "pFileName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineOutput(s_ExportLLTConfigDefinition, "RetVal", "int32");
%validate(s_ExportLLTConfigDefinition);

%% C++ function |s_ExportLLTConfigString| with MATLAB name |clib.LLT.s_ExportLLTConfigString|
% C++ Signature: int s_ExportLLTConfigString(long pLLT,char * configData,int configDataSize)
%s_ExportLLTConfigStringDefinition = addFunction(libDef, ...
%    "int s_ExportLLTConfigString(long pLLT,char * configData,int configDataSize)", ...
%    "MATLABName", "clib.LLT.s_ExportLLTConfigString", ...
%    "Description", "clib.LLT.s_ExportLLTConfigString    Representation of C++ function s_ExportLLTConfigString."); % Modify help description values as needed.
%defineArgument(s_ExportLLTConfigStringDefinition, "pLLT", "int32");
%defineArgument(s_ExportLLTConfigStringDefinition, "configData", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_ExportLLTConfigStringDefinition, "configDataSize", "int32");
%defineOutput(s_ExportLLTConfigStringDefinition, "RetVal", "int32");
%validate(s_ExportLLTConfigStringDefinition);

%% C++ function |s_ImportLLTConfig| with MATLAB name |clib.LLT.s_ImportLLTConfig|
% C++ Signature: int s_ImportLLTConfig(long pLLT,char const * pFileName,bool ignoreCalibration)
%s_ImportLLTConfigDefinition = addFunction(libDef, ...
%    "int s_ImportLLTConfig(long pLLT,char const * pFileName,bool ignoreCalibration)", ...
%    "MATLABName", "clib.LLT.s_ImportLLTConfig", ...
%    "Description", "clib.LLT.s_ImportLLTConfig    Representation of C++ function s_ImportLLTConfig."); % Modify help description values as needed.
%defineArgument(s_ImportLLTConfigDefinition, "pLLT", "int32");
%defineArgument(s_ImportLLTConfigDefinition, "pFileName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_ImportLLTConfigDefinition, "ignoreCalibration", "logical");
%defineOutput(s_ImportLLTConfigDefinition, "RetVal", "int32");
%validate(s_ImportLLTConfigDefinition);

%% C++ function |s_ImportLLTConfigString| with MATLAB name |clib.LLT.s_ImportLLTConfigString|
% C++ Signature: int s_ImportLLTConfigString(long pLLT,char const * configData,int configDataSize,bool ignoreCalibration)
%s_ImportLLTConfigStringDefinition = addFunction(libDef, ...
%    "int s_ImportLLTConfigString(long pLLT,char const * configData,int configDataSize,bool ignoreCalibration)", ...
%    "MATLABName", "clib.LLT.s_ImportLLTConfigString", ...
%    "Description", "clib.LLT.s_ImportLLTConfigString    Representation of C++ function s_ImportLLTConfigString."); % Modify help description values as needed.
%defineArgument(s_ImportLLTConfigStringDefinition, "pLLT", "int32");
%defineArgument(s_ImportLLTConfigStringDefinition, "configData", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_ImportLLTConfigStringDefinition, "configDataSize", "int32");
%defineArgument(s_ImportLLTConfigStringDefinition, "ignoreCalibration", "logical");
%defineOutput(s_ImportLLTConfigStringDefinition, "RetVal", "int32");
%validate(s_ImportLLTConfigStringDefinition);

%% C++ function |s_GetDeviceInterfaces| with MATLAB name |clib.LLT.s_GetDeviceInterfaces|
% C++ Signature: int s_GetDeviceInterfaces(long pLLT,unsigned int * pInterfaces,unsigned int nSize)
%s_GetDeviceInterfacesDefinition = addFunction(libDef, ...
%    "int s_GetDeviceInterfaces(long pLLT,unsigned int * pInterfaces,unsigned int nSize)", ...
%    "MATLABName", "clib.LLT.s_GetDeviceInterfaces", ...
%    "Description", "clib.LLT.s_GetDeviceInterfaces    Representation of C++ function s_GetDeviceInterfaces."); % Modify help description values as needed.
%defineArgument(s_GetDeviceInterfacesDefinition, "pLLT", "int32");
%defineArgument(s_GetDeviceInterfacesDefinition, "pInterfaces", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetDeviceInterfacesDefinition, "nSize", "uint32");
%defineOutput(s_GetDeviceInterfacesDefinition, "RetVal", "int32");
%validate(s_GetDeviceInterfacesDefinition);

%% C++ function |s_GetDeviceInterfacesFast| with MATLAB name |clib.LLT.s_GetDeviceInterfacesFast|
% C++ Signature: int s_GetDeviceInterfacesFast(long pLLT,unsigned int * pInterfaces,unsigned int nSize)
%s_GetDeviceInterfacesFastDefinition = addFunction(libDef, ...
%    "int s_GetDeviceInterfacesFast(long pLLT,unsigned int * pInterfaces,unsigned int nSize)", ...
%    "MATLABName", "clib.LLT.s_GetDeviceInterfacesFast", ...
%    "Description", "clib.LLT.s_GetDeviceInterfacesFast    Representation of C++ function s_GetDeviceInterfacesFast."); % Modify help description values as needed.
%defineArgument(s_GetDeviceInterfacesFastDefinition, "pLLT", "int32");
%defineArgument(s_GetDeviceInterfacesFastDefinition, "pInterfaces", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetDeviceInterfacesFastDefinition, "nSize", "uint32");
%defineOutput(s_GetDeviceInterfacesFastDefinition, "RetVal", "int32");
%validate(s_GetDeviceInterfacesFastDefinition);

%% C++ function |s_SetDeviceInterface| with MATLAB name |clib.LLT.s_SetDeviceInterface|
% C++ Signature: int s_SetDeviceInterface(long pLLT,unsigned int nInterface,int nAdditional)
s_SetDeviceInterfaceDefinition = addFunction(libDef, ...
    "int s_SetDeviceInterface(long pLLT,unsigned int nInterface,int nAdditional)", ...
    "MATLABName", "clib.LLT.s_SetDeviceInterface", ...
    "Description", "clib.LLT.s_SetDeviceInterface    Representation of C++ function s_SetDeviceInterface."); % Modify help description values as needed.
defineArgument(s_SetDeviceInterfaceDefinition, "pLLT", "int32");
defineArgument(s_SetDeviceInterfaceDefinition, "nInterface", "uint32");
defineArgument(s_SetDeviceInterfaceDefinition, "nAdditional", "int32");
defineOutput(s_SetDeviceInterfaceDefinition, "RetVal", "int32");
validate(s_SetDeviceInterfaceDefinition);

%% C++ function |s_GetDiscoveryBroadcastTarget| with MATLAB name |clib.LLT.s_GetDiscoveryBroadcastTarget|
% C++ Signature: unsigned int s_GetDiscoveryBroadcastTarget(long pLLT)
s_GetDiscoveryBroadcastTargetDefinition = addFunction(libDef, ...
    "unsigned int s_GetDiscoveryBroadcastTarget(long pLLT)", ...
    "MATLABName", "clib.LLT.s_GetDiscoveryBroadcastTarget", ...
    "Description", "clib.LLT.s_GetDiscoveryBroadcastTarget    Representation of C++ function s_GetDiscoveryBroadcastTarget."); % Modify help description values as needed.
defineArgument(s_GetDiscoveryBroadcastTargetDefinition, "pLLT", "int32");
defineOutput(s_GetDiscoveryBroadcastTargetDefinition, "RetVal", "uint32");
validate(s_GetDiscoveryBroadcastTargetDefinition);

%% C++ function |s_SetDiscoveryBroadcastTarget| with MATLAB name |clib.LLT.s_SetDiscoveryBroadcastTarget|
% C++ Signature: int s_SetDiscoveryBroadcastTarget(long pLLT,unsigned int nNetworkAddress,unsigned int nSubnetMask)
s_SetDiscoveryBroadcastTargetDefinition = addFunction(libDef, ...
    "int s_SetDiscoveryBroadcastTarget(long pLLT,unsigned int nNetworkAddress,unsigned int nSubnetMask)", ...
    "MATLABName", "clib.LLT.s_SetDiscoveryBroadcastTarget", ...
    "Description", "clib.LLT.s_SetDiscoveryBroadcastTarget    Representation of C++ function s_SetDiscoveryBroadcastTarget."); % Modify help description values as needed.
defineArgument(s_SetDiscoveryBroadcastTargetDefinition, "pLLT", "int32");
defineArgument(s_SetDiscoveryBroadcastTargetDefinition, "nNetworkAddress", "uint32");
defineArgument(s_SetDiscoveryBroadcastTargetDefinition, "nSubnetMask", "uint32");
defineOutput(s_SetDiscoveryBroadcastTargetDefinition, "RetVal", "int32");
validate(s_SetDiscoveryBroadcastTargetDefinition);

%% C++ function |s_GetDeviceName| with MATLAB name |clib.LLT.s_GetDeviceName|
% C++ Signature: int s_GetDeviceName(long pLLT,char * pDevName,unsigned int nDevNameSize,char * pVenName,unsigned int nVenNameSize)
%s_GetDeviceNameDefinition = addFunction(libDef, ...
%    "int s_GetDeviceName(long pLLT,char * pDevName,unsigned int nDevNameSize,char * pVenName,unsigned int nVenNameSize)", ...
%    "MATLABName", "clib.LLT.s_GetDeviceName", ...
%    "Description", "clib.LLT.s_GetDeviceName    Representation of C++ function s_GetDeviceName."); % Modify help description values as needed.
%defineArgument(s_GetDeviceNameDefinition, "pLLT", "int32");
%defineArgument(s_GetDeviceNameDefinition, "pDevName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_GetDeviceNameDefinition, "nDevNameSize", "uint32");
%defineArgument(s_GetDeviceNameDefinition, "pVenName", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_GetDeviceNameDefinition, "nVenNameSize", "uint32");
%defineOutput(s_GetDeviceNameDefinition, "RetVal", "int32");
%validate(s_GetDeviceNameDefinition);

%% C++ function |s_GetSerialNumber| with MATLAB name |clib.LLT.s_GetSerialNumber|
% C++ Signature: int s_GetSerialNumber(long pLLT,char * pSerialNumber,unsigned int nSerialNumberSize)
%s_GetSerialNumberDefinition = addFunction(libDef, ...
%    "int s_GetSerialNumber(long pLLT,char * pSerialNumber,unsigned int nSerialNumberSize)", ...
%    "MATLABName", "clib.LLT.s_GetSerialNumber", ...
%    "Description", "clib.LLT.s_GetSerialNumber    Representation of C++ function s_GetSerialNumber."); % Modify help description values as needed.
%defineArgument(s_GetSerialNumberDefinition, "pLLT", "int32");
%defineArgument(s_GetSerialNumberDefinition, "pSerialNumber", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_GetSerialNumberDefinition, "nSerialNumberSize", "uint32");
%defineOutput(s_GetSerialNumberDefinition, "RetVal", "int32");
%validate(s_GetSerialNumberDefinition);

%% C++ function |s_GetLLTVersions| with MATLAB name |clib.LLT.s_GetLLTVersions|
% C++ Signature: int s_GetLLTVersions(long pLLT,unsigned int * pDSP,unsigned int * pFPGA1,unsigned int * pFPGA2)
%s_GetLLTVersionsDefinition = addFunction(libDef, ...
%    "int s_GetLLTVersions(long pLLT,unsigned int * pDSP,unsigned int * pFPGA1,unsigned int * pFPGA2)", ...
%    "MATLABName", "clib.LLT.s_GetLLTVersions", ...
%    "Description", "clib.LLT.s_GetLLTVersions    Representation of C++ function s_GetLLTVersions."); % Modify help description values as needed.
%defineArgument(s_GetLLTVersionsDefinition, "pLLT", "int32");
%defineArgument(s_GetLLTVersionsDefinition, "pDSP", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetLLTVersionsDefinition, "pFPGA1", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetLLTVersionsDefinition, "pFPGA2", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetLLTVersionsDefinition, "RetVal", "int32");
%validate(s_GetLLTVersionsDefinition);

%% C++ function |s_GetMinMaxPacketSize| with MATLAB name |clib.LLT.s_GetMinMaxPacketSize|
% C++ Signature: int s_GetMinMaxPacketSize(long pLLT,unsigned long * pMinPacketSize,unsigned long * pMaxPacketSize)
%s_GetMinMaxPacketSizeDefinition = addFunction(libDef, ...
%    "int s_GetMinMaxPacketSize(long pLLT,unsigned long * pMinPacketSize,unsigned long * pMaxPacketSize)", ...
%    "MATLABName", "clib.LLT.s_GetMinMaxPacketSize", ...
%    "Description", "clib.LLT.s_GetMinMaxPacketSize    Representation of C++ function s_GetMinMaxPacketSize."); % Modify help description values as needed.
%defineArgument(s_GetMinMaxPacketSizeDefinition, "pLLT", "int32");
%defineArgument(s_GetMinMaxPacketSizeDefinition, "pMinPacketSize", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineArgument(s_GetMinMaxPacketSizeDefinition, "pMaxPacketSize", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetMinMaxPacketSizeDefinition, "RetVal", "int32");
%validate(s_GetMinMaxPacketSizeDefinition);

%% C++ function |s_GetResolutions| with MATLAB name |clib.LLT.s_GetResolutions|
% C++ Signature: int s_GetResolutions(long pLLT,DWORD * pValue,unsigned int nSize)
%s_GetResolutionsDefinition = addFunction(libDef, ...
%    "int s_GetResolutions(long pLLT,DWORD * pValue,unsigned int nSize)", ...
%    "MATLABName", "clib.LLT.s_GetResolutions", ...
%    "Description", "clib.LLT.s_GetResolutions    Representation of C++ function s_GetResolutions."); % Modify help description values as needed.
%defineArgument(s_GetResolutionsDefinition, "pLLT", "int32");
%defineArgument(s_GetResolutionsDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineArgument(s_GetResolutionsDefinition, "nSize", "uint32");
%defineOutput(s_GetResolutionsDefinition, "RetVal", "int32");
%validate(s_GetResolutionsDefinition);

%% C++ function |s_GetFeature| with MATLAB name |clib.LLT.s_GetFeature|
% C++ Signature: int s_GetFeature(long pLLT,DWORD Function,DWORD * pValue)
%s_GetFeatureDefinition = addFunction(libDef, ...
%    "int s_GetFeature(long pLLT,DWORD Function,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetFeature", ...
%    "Description", "clib.LLT.s_GetFeature    Representation of C++ function s_GetFeature."); % Modify help description values as needed.
%defineArgument(s_GetFeatureDefinition, "pLLT", "int32");
%defineArgument(s_GetFeatureDefinition, "Function", "uint32");
%defineArgument(s_GetFeatureDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetFeatureDefinition, "RetVal", "int32");
%validate(s_GetFeatureDefinition);

%% C++ function |s_GetBufferCount| with MATLAB name |clib.LLT.s_GetBufferCount|
% C++ Signature: int s_GetBufferCount(long pLLT,DWORD * pValue)
%s_GetBufferCountDefinition = addFunction(libDef, ...
%    "int s_GetBufferCount(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetBufferCount", ...
%    "Description", "clib.LLT.s_GetBufferCount    Representation of C++ function s_GetBufferCount."); % Modify help description values as needed.
%defineArgument(s_GetBufferCountDefinition, "pLLT", "int32");
%defineArgument(s_GetBufferCountDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetBufferCountDefinition, "RetVal", "int32");
%validate(s_GetBufferCountDefinition);

%% C++ function |s_GetMainReflection| with MATLAB name |clib.LLT.s_GetMainReflection|
% C++ Signature: int s_GetMainReflection(long pLLT,DWORD * pValue)
%s_GetMainReflectionDefinition = addFunction(libDef, ...
%    "int s_GetMainReflection(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetMainReflection", ...
%    "Description", "clib.LLT.s_GetMainReflection    Representation of C++ function s_GetMainReflection."); % Modify help description values as needed.
%defineArgument(s_GetMainReflectionDefinition, "pLLT", "int32");
%defineArgument(s_GetMainReflectionDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetMainReflectionDefinition, "RetVal", "int32");
%validate(s_GetMainReflectionDefinition);

%% C++ function |s_GetMaxFileSize| with MATLAB name |clib.LLT.s_GetMaxFileSize|
% C++ Signature: int s_GetMaxFileSize(long pLLT,DWORD * pValue)
%s_GetMaxFileSizeDefinition = addFunction(libDef, ...
%    "int s_GetMaxFileSize(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetMaxFileSize", ...
%    "Description", "clib.LLT.s_GetMaxFileSize    Representation of C++ function s_GetMaxFileSize."); % Modify help description values as needed.
%defineArgument(s_GetMaxFileSizeDefinition, "pLLT", "int32");
%defineArgument(s_GetMaxFileSizeDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetMaxFileSizeDefinition, "RetVal", "int32");
%validate(s_GetMaxFileSizeDefinition);

%% C++ function |s_GetPacketSize| with MATLAB name |clib.LLT.s_GetPacketSize|
% C++ Signature: int s_GetPacketSize(long pLLT,DWORD * pValue)
%s_GetPacketSizeDefinition = addFunction(libDef, ...
%    "int s_GetPacketSize(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetPacketSize", ...
%    "Description", "clib.LLT.s_GetPacketSize    Representation of C++ function s_GetPacketSize."); % Modify help description values as needed.
%defineArgument(s_GetPacketSizeDefinition, "pLLT", "int32");
%defineArgument(s_GetPacketSizeDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetPacketSizeDefinition, "RetVal", "int32");
%validate(s_GetPacketSizeDefinition);

%% C++ function |s_GetFirewireConnectionSpeed| with MATLAB name |clib.LLT.s_GetFirewireConnectionSpeed|
% C++ Signature: int s_GetFirewireConnectionSpeed(long pLLT,DWORD * pValue)
%s_GetFirewireConnectionSpeedDefinition = addFunction(libDef, ...
%    "int s_GetFirewireConnectionSpeed(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetFirewireConnectionSpeed", ...
%    "Description", "clib.LLT.s_GetFirewireConnectionSpeed    Representation of C++ function s_GetFirewireConnectionSpeed."); % Modify help description values as needed.
%defineArgument(s_GetFirewireConnectionSpeedDefinition, "pLLT", "int32");
%defineArgument(s_GetFirewireConnectionSpeedDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetFirewireConnectionSpeedDefinition, "RetVal", "int32");
%validate(s_GetFirewireConnectionSpeedDefinition);

%% C++ function |s_GetResolution| with MATLAB name |clib.LLT.s_GetResolution|
% C++ Signature: int s_GetResolution(long pLLT,DWORD * pValue)
%s_GetResolutionDefinition = addFunction(libDef, ...
%    "int s_GetResolution(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetResolution", ...
%    "Description", "clib.LLT.s_GetResolution    Representation of C++ function s_GetResolution."); % Modify help description values as needed.
%defineArgument(s_GetResolutionDefinition, "pLLT", "int32");
%defineArgument(s_GetResolutionDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetResolutionDefinition, "RetVal", "int32");
%validate(s_GetResolutionDefinition);

%% C++ function |s_GetProfileContainerSize| with MATLAB name |clib.LLT.s_GetProfileContainerSize|
% C++ Signature: int s_GetProfileContainerSize(long pLLT,unsigned int * pWidth,unsigned int * pHeight)
%s_GetProfileContainerSizeDefinition = addFunction(libDef, ...
%    "int s_GetProfileContainerSize(long pLLT,unsigned int * pWidth,unsigned int * pHeight)", ...
%    "MATLABName", "clib.LLT.s_GetProfileContainerSize", ...
%    "Description", "clib.LLT.s_GetProfileContainerSize    Representation of C++ function s_GetProfileContainerSize."); % Modify help description values as needed.
%defineArgument(s_GetProfileContainerSizeDefinition, "pLLT", "int32");
%defineArgument(s_GetProfileContainerSizeDefinition, "pWidth", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetProfileContainerSizeDefinition, "pHeight", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetProfileContainerSizeDefinition, "RetVal", "int32");
%validate(s_GetProfileContainerSizeDefinition);

%% C++ function |s_GetMaxProfileContainerSize| with MATLAB name |clib.LLT.s_GetMaxProfileContainerSize|
% C++ Signature: int s_GetMaxProfileContainerSize(long pLLT,unsigned int * pMaxWidth,unsigned int * pMaxHeight)
%s_GetMaxProfileContainerSizeDefinition = addFunction(libDef, ...
%    "int s_GetMaxProfileContainerSize(long pLLT,unsigned int * pMaxWidth,unsigned int * pMaxHeight)", ...
%    "MATLABName", "clib.LLT.s_GetMaxProfileContainerSize", ...
%    "Description", "clib.LLT.s_GetMaxProfileContainerSize    Representation of C++ function s_GetMaxProfileContainerSize."); % Modify help description values as needed.
%defineArgument(s_GetMaxProfileContainerSizeDefinition, "pLLT", "int32");
%defineArgument(s_GetMaxProfileContainerSizeDefinition, "pMaxWidth", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetMaxProfileContainerSizeDefinition, "pMaxHeight", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetMaxProfileContainerSizeDefinition, "RetVal", "int32");
%validate(s_GetMaxProfileContainerSizeDefinition);

%% C++ function |s_GetEthernetHeartbeatTimeout| with MATLAB name |clib.LLT.s_GetEthernetHeartbeatTimeout|
% C++ Signature: int s_GetEthernetHeartbeatTimeout(long pLLT,DWORD * pValue)
%s_GetEthernetHeartbeatTimeoutDefinition = addFunction(libDef, ...
%    "int s_GetEthernetHeartbeatTimeout(long pLLT,DWORD * pValue)", ...
%    "MATLABName", "clib.LLT.s_GetEthernetHeartbeatTimeout", ...
%    "Description", "clib.LLT.s_GetEthernetHeartbeatTimeout    Representation of C++ function s_GetEthernetHeartbeatTimeout."); % Modify help description values as needed.
%defineArgument(s_GetEthernetHeartbeatTimeoutDefinition, "pLLT", "int32");
%defineArgument(s_GetEthernetHeartbeatTimeoutDefinition, "pValue", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineOutput(s_GetEthernetHeartbeatTimeoutDefinition, "RetVal", "int32");
%validate(s_GetEthernetHeartbeatTimeoutDefinition);

%% C++ function |s_SetFeature| with MATLAB name |clib.LLT.s_SetFeature|
% C++ Signature: int s_SetFeature(long pLLT,DWORD Function,DWORD Value)
s_SetFeatureDefinition = addFunction(libDef, ...
    "int s_SetFeature(long pLLT,DWORD Function,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetFeature", ...
    "Description", "clib.LLT.s_SetFeature    Representation of C++ function s_SetFeature."); % Modify help description values as needed.
defineArgument(s_SetFeatureDefinition, "pLLT", "int32");
defineArgument(s_SetFeatureDefinition, "Function", "uint32");
defineArgument(s_SetFeatureDefinition, "Value", "uint32");
defineOutput(s_SetFeatureDefinition, "RetVal", "int32");
validate(s_SetFeatureDefinition);

%% C++ function |s_SetFeatureGroup| with MATLAB name |clib.LLT.s_SetFeatureGroup|
% C++ Signature: int s_SetFeatureGroup(long pLLT,DWORD const * FeatureAddresses,DWORD const * FeatureValues,DWORD FeatureCount)
%s_SetFeatureGroupDefinition = addFunction(libDef, ...
%    "int s_SetFeatureGroup(long pLLT,DWORD const * FeatureAddresses,DWORD const * FeatureValues,DWORD FeatureCount)", ...
%    "MATLABName", "clib.LLT.s_SetFeatureGroup", ...
%    "Description", "clib.LLT.s_SetFeatureGroup    Representation of C++ function s_SetFeatureGroup."); % Modify help description values as needed.
%defineArgument(s_SetFeatureGroupDefinition, "pLLT", "int32");
%defineArgument(s_SetFeatureGroupDefinition, "FeatureAddresses", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineArgument(s_SetFeatureGroupDefinition, "FeatureValues", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineArgument(s_SetFeatureGroupDefinition, "FeatureCount", "uint32");
%defineOutput(s_SetFeatureGroupDefinition, "RetVal", "int32");
%validate(s_SetFeatureGroupDefinition);

%% C++ function |s_SetBufferCount| with MATLAB name |clib.LLT.s_SetBufferCount|
% C++ Signature: int s_SetBufferCount(long pLLT,DWORD Value)
s_SetBufferCountDefinition = addFunction(libDef, ...
    "int s_SetBufferCount(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetBufferCount", ...
    "Description", "clib.LLT.s_SetBufferCount    Representation of C++ function s_SetBufferCount."); % Modify help description values as needed.
defineArgument(s_SetBufferCountDefinition, "pLLT", "int32");
defineArgument(s_SetBufferCountDefinition, "Value", "uint32");
defineOutput(s_SetBufferCountDefinition, "RetVal", "int32");
validate(s_SetBufferCountDefinition);

%% C++ function |s_SetMainReflection| with MATLAB name |clib.LLT.s_SetMainReflection|
% C++ Signature: int s_SetMainReflection(long pLLT,DWORD Value)
s_SetMainReflectionDefinition = addFunction(libDef, ...
    "int s_SetMainReflection(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetMainReflection", ...
    "Description", "clib.LLT.s_SetMainReflection    Representation of C++ function s_SetMainReflection."); % Modify help description values as needed.
defineArgument(s_SetMainReflectionDefinition, "pLLT", "int32");
defineArgument(s_SetMainReflectionDefinition, "Value", "uint32");
defineOutput(s_SetMainReflectionDefinition, "RetVal", "int32");
validate(s_SetMainReflectionDefinition);

%% C++ function |s_SetMaxFileSize| with MATLAB name |clib.LLT.s_SetMaxFileSize|
% C++ Signature: int s_SetMaxFileSize(long pLLT,DWORD Value)
s_SetMaxFileSizeDefinition = addFunction(libDef, ...
    "int s_SetMaxFileSize(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetMaxFileSize", ...
    "Description", "clib.LLT.s_SetMaxFileSize    Representation of C++ function s_SetMaxFileSize."); % Modify help description values as needed.
defineArgument(s_SetMaxFileSizeDefinition, "pLLT", "int32");
defineArgument(s_SetMaxFileSizeDefinition, "Value", "uint32");
defineOutput(s_SetMaxFileSizeDefinition, "RetVal", "int32");
validate(s_SetMaxFileSizeDefinition);

%% C++ function |s_SetPacketSize| with MATLAB name |clib.LLT.s_SetPacketSize|
% C++ Signature: int s_SetPacketSize(long pLLT,DWORD Value)
s_SetPacketSizeDefinition = addFunction(libDef, ...
    "int s_SetPacketSize(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetPacketSize", ...
    "Description", "clib.LLT.s_SetPacketSize    Representation of C++ function s_SetPacketSize."); % Modify help description values as needed.
defineArgument(s_SetPacketSizeDefinition, "pLLT", "int32");
defineArgument(s_SetPacketSizeDefinition, "Value", "uint32");
defineOutput(s_SetPacketSizeDefinition, "RetVal", "int32");
validate(s_SetPacketSizeDefinition);

%% C++ function |s_SetFirewireConnectionSpeed| with MATLAB name |clib.LLT.s_SetFirewireConnectionSpeed|
% C++ Signature: int s_SetFirewireConnectionSpeed(long pLLT,DWORD Value)
s_SetFirewireConnectionSpeedDefinition = addFunction(libDef, ...
    "int s_SetFirewireConnectionSpeed(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetFirewireConnectionSpeed", ...
    "Description", "clib.LLT.s_SetFirewireConnectionSpeed    Representation of C++ function s_SetFirewireConnectionSpeed."); % Modify help description values as needed.
defineArgument(s_SetFirewireConnectionSpeedDefinition, "pLLT", "int32");
defineArgument(s_SetFirewireConnectionSpeedDefinition, "Value", "uint32");
defineOutput(s_SetFirewireConnectionSpeedDefinition, "RetVal", "int32");
validate(s_SetFirewireConnectionSpeedDefinition);

%% C++ function |s_SetProfileConfig| with MATLAB name |clib.LLT.s_SetProfileConfig|
% C++ Signature: int s_SetProfileConfig(long pLLT,TProfileConfig Value)
s_SetProfileConfigDefinition = addFunction(libDef, ...
    "int s_SetProfileConfig(long pLLT,TProfileConfig Value)", ...
    "MATLABName", "clib.LLT.s_SetProfileConfig", ...
    "Description", "clib.LLT.s_SetProfileConfig    Representation of C++ function s_SetProfileConfig."); % Modify help description values as needed.
defineArgument(s_SetProfileConfigDefinition, "pLLT", "int32");
defineArgument(s_SetProfileConfigDefinition, "Value", "clib.LLT.TProfileConfig");
defineOutput(s_SetProfileConfigDefinition, "RetVal", "int32");
validate(s_SetProfileConfigDefinition);

%% C++ function |s_SetResolution| with MATLAB name |clib.LLT.s_SetResolution|
% C++ Signature: int s_SetResolution(long pLLT,DWORD Value)
s_SetResolutionDefinition = addFunction(libDef, ...
    "int s_SetResolution(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetResolution", ...
    "Description", "clib.LLT.s_SetResolution    Representation of C++ function s_SetResolution."); % Modify help description values as needed.
defineArgument(s_SetResolutionDefinition, "pLLT", "int32");
defineArgument(s_SetResolutionDefinition, "Value", "uint32");
defineOutput(s_SetResolutionDefinition, "RetVal", "int32");
validate(s_SetResolutionDefinition);

%% C++ function |s_SetProfileContainerSize| with MATLAB name |clib.LLT.s_SetProfileContainerSize|
% C++ Signature: int s_SetProfileContainerSize(long pLLT,unsigned int nWidth,unsigned int nHeight)
s_SetProfileContainerSizeDefinition = addFunction(libDef, ...
    "int s_SetProfileContainerSize(long pLLT,unsigned int nWidth,unsigned int nHeight)", ...
    "MATLABName", "clib.LLT.s_SetProfileContainerSize", ...
    "Description", "clib.LLT.s_SetProfileContainerSize    Representation of C++ function s_SetProfileContainerSize."); % Modify help description values as needed.
defineArgument(s_SetProfileContainerSizeDefinition, "pLLT", "int32");
defineArgument(s_SetProfileContainerSizeDefinition, "nWidth", "uint32");
defineArgument(s_SetProfileContainerSizeDefinition, "nHeight", "uint32");
defineOutput(s_SetProfileContainerSizeDefinition, "RetVal", "int32");
validate(s_SetProfileContainerSizeDefinition);

%% C++ function |s_SetEthernetHeartbeatTimeout| with MATLAB name |clib.LLT.s_SetEthernetHeartbeatTimeout|
% C++ Signature: int s_SetEthernetHeartbeatTimeout(long pLLT,DWORD Value)
s_SetEthernetHeartbeatTimeoutDefinition = addFunction(libDef, ...
    "int s_SetEthernetHeartbeatTimeout(long pLLT,DWORD Value)", ...
    "MATLABName", "clib.LLT.s_SetEthernetHeartbeatTimeout", ...
    "Description", "clib.LLT.s_SetEthernetHeartbeatTimeout    Representation of C++ function s_SetEthernetHeartbeatTimeout."); % Modify help description values as needed.
defineArgument(s_SetEthernetHeartbeatTimeoutDefinition, "pLLT", "int32");
defineArgument(s_SetEthernetHeartbeatTimeoutDefinition, "Value", "uint32");
defineOutput(s_SetEthernetHeartbeatTimeoutDefinition, "RetVal", "int32");
validate(s_SetEthernetHeartbeatTimeoutDefinition);

%% C++ function |s_TransferProfiles| with MATLAB name |clib.LLT.s_TransferProfiles|
% C++ Signature: int s_TransferProfiles(long pLLT,TTransferProfileType TransferProfileType,int nEnable)
s_TransferProfilesDefinition = addFunction(libDef, ...
    "int s_TransferProfiles(long pLLT,TTransferProfileType TransferProfileType,int nEnable)", ...
    "MATLABName", "clib.LLT.s_TransferProfiles", ...
    "Description", "clib.LLT.s_TransferProfiles    Representation of C++ function s_TransferProfiles."); % Modify help description values as needed.
defineArgument(s_TransferProfilesDefinition, "pLLT", "int32");
defineArgument(s_TransferProfilesDefinition, "TransferProfileType", "clib.LLT.TTransferProfileType");
defineArgument(s_TransferProfilesDefinition, "nEnable", "int32");
defineOutput(s_TransferProfilesDefinition, "RetVal", "int32");
validate(s_TransferProfilesDefinition);

%% C++ function |s_TransferVideoStream| with MATLAB name |clib.LLT.s_TransferVideoStream|
% C++ Signature: int s_TransferVideoStream(long pLLT,int TransferVideoType,int nEnable,unsigned int * pWidth,unsigned int * pHeight)
%s_TransferVideoStreamDefinition = addFunction(libDef, ...
%    "int s_TransferVideoStream(long pLLT,int TransferVideoType,int nEnable,unsigned int * pWidth,unsigned int * pHeight)", ...
%    "MATLABName", "clib.LLT.s_TransferVideoStream", ...
%    "Description", "clib.LLT.s_TransferVideoStream    Representation of C++ function s_TransferVideoStream."); % Modify help description values as needed.
%defineArgument(s_TransferVideoStreamDefinition, "pLLT", "int32");
%defineArgument(s_TransferVideoStreamDefinition, "TransferVideoType", "int32");
%defineArgument(s_TransferVideoStreamDefinition, "nEnable", "int32");
%defineArgument(s_TransferVideoStreamDefinition, "pWidth", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_TransferVideoStreamDefinition, "pHeight", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_TransferVideoStreamDefinition, "RetVal", "int32");
%validate(s_TransferVideoStreamDefinition);

%% C++ function |s_GetProfile| with MATLAB name |clib.LLT.s_GetProfile|
% C++ Signature: int s_GetProfile(long pLLT)
s_GetProfileDefinition = addFunction(libDef, ...
    "int s_GetProfile(long pLLT)", ...
    "MATLABName", "clib.LLT.s_GetProfile", ...
    "Description", "clib.LLT.s_GetProfile    Representation of C++ function s_GetProfile."); % Modify help description values as needed.
defineArgument(s_GetProfileDefinition, "pLLT", "int32");
defineOutput(s_GetProfileDefinition, "RetVal", "int32");
validate(s_GetProfileDefinition);

%% C++ function |s_MultiShot| with MATLAB name |clib.LLT.s_MultiShot|
% C++ Signature: int s_MultiShot(long pLLT,unsigned int Count)
s_MultiShotDefinition = addFunction(libDef, ...
    "int s_MultiShot(long pLLT,unsigned int Count)", ...
    "MATLABName", "clib.LLT.s_MultiShot", ...
    "Description", "clib.LLT.s_MultiShot    Representation of C++ function s_MultiShot."); % Modify help description values as needed.
defineArgument(s_MultiShotDefinition, "pLLT", "int32");
defineArgument(s_MultiShotDefinition, "Count", "uint32");
defineOutput(s_MultiShotDefinition, "RetVal", "int32");
validate(s_MultiShotDefinition);

%% C++ function |s_GetActualProfile| with MATLAB name |clib.LLT.s_GetActualProfile|
% C++ Signature: int s_GetActualProfile(long pLLT,unsigned char * pBuffer,unsigned int nBuffersize,TProfileConfig ProfileConfig,unsigned int * pLostProfiles)
%s_GetActualProfileDefinition = addFunction(libDef, ...
%    "int s_GetActualProfile(long pLLT,unsigned char * pBuffer,unsigned int nBuffersize,TProfileConfig ProfileConfig,unsigned int * pLostProfiles)", ...
%    "MATLABName", "clib.LLT.s_GetActualProfile", ...
%    "Description", "clib.LLT.s_GetActualProfile    Representation of C++ function s_GetActualProfile."); % Modify help description values as needed.
%defineArgument(s_GetActualProfileDefinition, "pLLT", "int32");
%defineArgument(s_GetActualProfileDefinition, "pBuffer", "clib.array.LLT.UnsignedChar", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_GetActualProfileDefinition, "nBuffersize", "uint32");
%defineArgument(s_GetActualProfileDefinition, "ProfileConfig", "clib.LLT.TProfileConfig");
%defineArgument(s_GetActualProfileDefinition, "pLostProfiles", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetActualProfileDefinition, "RetVal", "int32");
%validate(s_GetActualProfileDefinition);

%% C++ function |s_ConvertProfile2Values| with MATLAB name |clib.LLT.s_ConvertProfile2Values|
% C++ Signature: int s_ConvertProfile2Values(long pLLT,unsigned char const * pProfile,unsigned int nResolution,TProfileConfig ProfileConfig,TScannerType ScannerType,unsigned int nReflection,int nConvertToMM,unsigned short * pWidth,unsigned short * pMaximum,unsigned short * pThreshold,double * pX,double * pZ,unsigned int * pM0,unsigned int * pM1)
%s_ConvertProfile2ValuesDefinition = addFunction(libDef, ...
%    "int s_ConvertProfile2Values(long pLLT,unsigned char const * pProfile,unsigned int nResolution,TProfileConfig ProfileConfig,TScannerType ScannerType,unsigned int nReflection,int nConvertToMM,unsigned short * pWidth,unsigned short * pMaximum,unsigned short * pThreshold,double * pX,double * pZ,unsigned int * pM0,unsigned int * pM1)", ...
%    "MATLABName", "clib.LLT.s_ConvertProfile2Values", ...
%    "Description", "clib.LLT.s_ConvertProfile2Values    Representation of C++ function s_ConvertProfile2Values."); % Modify help description values as needed.
%defineArgument(s_ConvertProfile2ValuesDefinition, "pLLT", "int32");
%defineArgument(s_ConvertProfile2ValuesDefinition, "pProfile", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_ConvertProfile2ValuesDefinition, "nResolution", "uint32");
%defineArgument(s_ConvertProfile2ValuesDefinition, "ProfileConfig", "clib.LLT.TProfileConfig");
%defineArgument(s_ConvertProfile2ValuesDefinition, "ScannerType", "clib.LLT.TScannerType");
%defineArgument(s_ConvertProfile2ValuesDefinition, "nReflection", "uint32");
%defineArgument(s_ConvertProfile2ValuesDefinition, "nConvertToMM", "int32");
%defineArgument(s_ConvertProfile2ValuesDefinition, "pWidth", "clib.array.LLT.UnsignedShort", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedShort, or uint16
%defineArgument(s_ConvertProfile2ValuesDefinition, "pMaximum", "clib.array.LLT.UnsignedShort", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedShort, or uint16
%defineArgument(s_ConvertProfile2ValuesDefinition, "pThreshold", "clib.array.LLT.UnsignedShort", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedShort, or uint16
%defineArgument(s_ConvertProfile2ValuesDefinition, "pX", "clib.array.LLT.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Double, or double
%defineArgument(s_ConvertProfile2ValuesDefinition, "pZ", "clib.array.LLT.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Double, or double
%defineArgument(s_ConvertProfile2ValuesDefinition, "pM0", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_ConvertProfile2ValuesDefinition, "pM1", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_ConvertProfile2ValuesDefinition, "RetVal", "int32");
%validate(s_ConvertProfile2ValuesDefinition);

%% C++ function |s_ConvertPartProfile2Values| with MATLAB name |clib.LLT.s_ConvertPartProfile2Values|
% C++ Signature: int s_ConvertPartProfile2Values(long pLLT,unsigned char const * pProfile,TPartialProfile * pPartialProfile,TScannerType ScannerType,unsigned int nReflection,int nConvertToMM,unsigned short * pWidth,unsigned short * pMaximum,unsigned short * pThreshold,double * pX,double * pZ,unsigned int * pM0,unsigned int * pM1)
%s_ConvertPartProfile2ValuesDefinition = addFunction(libDef, ...
%    "int s_ConvertPartProfile2Values(long pLLT,unsigned char const * pProfile,TPartialProfile * pPartialProfile,TScannerType ScannerType,unsigned int nReflection,int nConvertToMM,unsigned short * pWidth,unsigned short * pMaximum,unsigned short * pThreshold,double * pX,double * pZ,unsigned int * pM0,unsigned int * pM1)", ...
%    "MATLABName", "clib.LLT.s_ConvertPartProfile2Values", ...
%    "Description", "clib.LLT.s_ConvertPartProfile2Values    Representation of C++ function s_ConvertPartProfile2Values."); % Modify help description values as needed.
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pLLT", "int32");
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pProfile", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pPartialProfile", "clib.LLT.TPartialProfile", "input", <SHAPE>); % '<MLTYPE>' can be clib.LLT.TPartialProfile, or clib.array.LLT.TPartialProfile
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "ScannerType", "clib.LLT.TScannerType");
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "nReflection", "uint32");
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "nConvertToMM", "int32");
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pWidth", "clib.array.LLT.UnsignedShort", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedShort, or uint16
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pMaximum", "clib.array.LLT.UnsignedShort", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedShort, or uint16
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pThreshold", "clib.array.LLT.UnsignedShort", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedShort, or uint16
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pX", "clib.array.LLT.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Double, or double
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pZ", "clib.array.LLT.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Double, or double
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pM0", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_ConvertPartProfile2ValuesDefinition, "pM1", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_ConvertPartProfile2ValuesDefinition, "RetVal", "int32");
%validate(s_ConvertPartProfile2ValuesDefinition);

%% C++ function |s_SetHoldBuffersForPolling| with MATLAB name |clib.LLT.s_SetHoldBuffersForPolling|
% C++ Signature: int s_SetHoldBuffersForPolling(long pLLT,unsigned int uiHoldBuffersForPolling)
s_SetHoldBuffersForPollingDefinition = addFunction(libDef, ...
    "int s_SetHoldBuffersForPolling(long pLLT,unsigned int uiHoldBuffersForPolling)", ...
    "MATLABName", "clib.LLT.s_SetHoldBuffersForPolling", ...
    "Description", "clib.LLT.s_SetHoldBuffersForPolling    Representation of C++ function s_SetHoldBuffersForPolling."); % Modify help description values as needed.
defineArgument(s_SetHoldBuffersForPollingDefinition, "pLLT", "int32");
defineArgument(s_SetHoldBuffersForPollingDefinition, "uiHoldBuffersForPolling", "uint32");
defineOutput(s_SetHoldBuffersForPollingDefinition, "RetVal", "int32");
validate(s_SetHoldBuffersForPollingDefinition);

%% C++ function |s_GetHoldBuffersForPolling| with MATLAB name |clib.LLT.s_GetHoldBuffersForPolling|
% C++ Signature: int s_GetHoldBuffersForPolling(long pLLT,unsigned int * puiHoldBuffersForPolling)
%s_GetHoldBuffersForPollingDefinition = addFunction(libDef, ...
%    "int s_GetHoldBuffersForPolling(long pLLT,unsigned int * puiHoldBuffersForPolling)", ...
%    "MATLABName", "clib.LLT.s_GetHoldBuffersForPolling", ...
%    "Description", "clib.LLT.s_GetHoldBuffersForPolling    Representation of C++ function s_GetHoldBuffersForPolling."); % Modify help description values as needed.
%defineArgument(s_GetHoldBuffersForPollingDefinition, "pLLT", "int32");
%defineArgument(s_GetHoldBuffersForPollingDefinition, "puiHoldBuffersForPolling", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetHoldBuffersForPollingDefinition, "RetVal", "int32");
%validate(s_GetHoldBuffersForPollingDefinition);

%% C++ function |s_IsInterfaceType| with MATLAB name |clib.LLT.s_IsInterfaceType|
% C++ Signature: int s_IsInterfaceType(long pLLT,int iInterfaceType)
s_IsInterfaceTypeDefinition = addFunction(libDef, ...
    "int s_IsInterfaceType(long pLLT,int iInterfaceType)", ...
    "MATLABName", "clib.LLT.s_IsInterfaceType", ...
    "Description", "clib.LLT.s_IsInterfaceType    Representation of C++ function s_IsInterfaceType."); % Modify help description values as needed.
defineArgument(s_IsInterfaceTypeDefinition, "pLLT", "int32");
defineArgument(s_IsInterfaceTypeDefinition, "iInterfaceType", "int32");
defineOutput(s_IsInterfaceTypeDefinition, "RetVal", "int32");
validate(s_IsInterfaceTypeDefinition);

%% C++ function |s_IsFirewire| with MATLAB name |clib.LLT.s_IsFirewire|
% C++ Signature: int s_IsFirewire(long pLLT)
s_IsFirewireDefinition = addFunction(libDef, ...
    "int s_IsFirewire(long pLLT)", ...
    "MATLABName", "clib.LLT.s_IsFirewire", ...
    "Description", "clib.LLT.s_IsFirewire    Representation of C++ function s_IsFirewire."); % Modify help description values as needed.
defineArgument(s_IsFirewireDefinition, "pLLT", "int32");
defineOutput(s_IsFirewireDefinition, "RetVal", "int32");
validate(s_IsFirewireDefinition);

%% C++ function |s_IsSerial| with MATLAB name |clib.LLT.s_IsSerial|
% C++ Signature: int s_IsSerial(long pLLT)
s_IsSerialDefinition = addFunction(libDef, ...
    "int s_IsSerial(long pLLT)", ...
    "MATLABName", "clib.LLT.s_IsSerial", ...
    "Description", "clib.LLT.s_IsSerial    Representation of C++ function s_IsSerial."); % Modify help description values as needed.
defineArgument(s_IsSerialDefinition, "pLLT", "int32");
defineOutput(s_IsSerialDefinition, "RetVal", "int32");
validate(s_IsSerialDefinition);

%% C++ function |s_IsTransferingProfiles| with MATLAB name |clib.LLT.s_IsTransferingProfiles|
% C++ Signature: int s_IsTransferingProfiles(long pLLT)
s_IsTransferingProfilesDefinition = addFunction(libDef, ...
    "int s_IsTransferingProfiles(long pLLT)", ...
    "MATLABName", "clib.LLT.s_IsTransferingProfiles", ...
    "Description", "clib.LLT.s_IsTransferingProfiles    Representation of C++ function s_IsTransferingProfiles."); % Modify help description values as needed.
defineArgument(s_IsTransferingProfilesDefinition, "pLLT", "int32");
defineOutput(s_IsTransferingProfilesDefinition, "RetVal", "int32");
validate(s_IsTransferingProfilesDefinition);

%% C++ function |s_GetPartialProfileUnitSize| with MATLAB name |clib.LLT.s_GetPartialProfileUnitSize|
% C++ Signature: int s_GetPartialProfileUnitSize(long pLLT,unsigned int * pUnitSizePoint,unsigned int * pUnitSizePointData)
%s_GetPartialProfileUnitSizeDefinition = addFunction(libDef, ...
%    "int s_GetPartialProfileUnitSize(long pLLT,unsigned int * pUnitSizePoint,unsigned int * pUnitSizePointData)", ...
%    "MATLABName", "clib.LLT.s_GetPartialProfileUnitSize", ...
%    "Description", "clib.LLT.s_GetPartialProfileUnitSize    Representation of C++ function s_GetPartialProfileUnitSize."); % Modify help description values as needed.
%defineArgument(s_GetPartialProfileUnitSizeDefinition, "pLLT", "int32");
%defineArgument(s_GetPartialProfileUnitSizeDefinition, "pUnitSizePoint", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetPartialProfileUnitSizeDefinition, "pUnitSizePointData", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetPartialProfileUnitSizeDefinition, "RetVal", "int32");
%validate(s_GetPartialProfileUnitSizeDefinition);

%% C++ function |s_GetPartialProfile| with MATLAB name |clib.LLT.s_GetPartialProfile|
% C++ Signature: int s_GetPartialProfile(long pLLT,TPartialProfile * pPartialProfile)
%s_GetPartialProfileDefinition = addFunction(libDef, ...
%    "int s_GetPartialProfile(long pLLT,TPartialProfile * pPartialProfile)", ...
%    "MATLABName", "clib.LLT.s_GetPartialProfile", ...
%    "Description", "clib.LLT.s_GetPartialProfile    Representation of C++ function s_GetPartialProfile."); % Modify help description values as needed.
%defineArgument(s_GetPartialProfileDefinition, "pLLT", "int32");
%defineArgument(s_GetPartialProfileDefinition, "pPartialProfile", "clib.LLT.TPartialProfile", "input", <SHAPE>); % '<MLTYPE>' can be clib.LLT.TPartialProfile, or clib.array.LLT.TPartialProfile
%defineOutput(s_GetPartialProfileDefinition, "RetVal", "int32");
%validate(s_GetPartialProfileDefinition);

%% C++ function |s_SetPartialProfile| with MATLAB name |clib.LLT.s_SetPartialProfile|
% C++ Signature: int s_SetPartialProfile(long pLLT,TPartialProfile * pPartialProfile)
%s_SetPartialProfileDefinition = addFunction(libDef, ...
%    "int s_SetPartialProfile(long pLLT,TPartialProfile * pPartialProfile)", ...
%    "MATLABName", "clib.LLT.s_SetPartialProfile", ...
%    "Description", "clib.LLT.s_SetPartialProfile    Representation of C++ function s_SetPartialProfile."); % Modify help description values as needed.
%defineArgument(s_SetPartialProfileDefinition, "pLLT", "int32");
%defineArgument(s_SetPartialProfileDefinition, "pPartialProfile", "clib.LLT.TPartialProfile", "input", <SHAPE>); % '<MLTYPE>' can be clib.LLT.TPartialProfile, or clib.array.LLT.TPartialProfile
%defineOutput(s_SetPartialProfileDefinition, "RetVal", "int32");
%validate(s_SetPartialProfileDefinition);

%% C++ function |s_Timestamp2CmmTriggerAndInCounter| with MATLAB name |clib.LLT.s_Timestamp2CmmTriggerAndInCounter|
% C++ Signature: void s_Timestamp2CmmTriggerAndInCounter(unsigned char const * pTimestamp,unsigned int * pInCounter,int * pCmmTrigger,int * pCmmActive,unsigned int * pCmmCount)
%s_Timestamp2CmmTriggerAndInCounterDefinition = addFunction(libDef, ...
%    "void s_Timestamp2CmmTriggerAndInCounter(unsigned char const * pTimestamp,unsigned int * pInCounter,int * pCmmTrigger,int * pCmmActive,unsigned int * pCmmCount)", ...
%    "MATLABName", "clib.LLT.s_Timestamp2CmmTriggerAndInCounter", ...
%    "Description", "clib.LLT.s_Timestamp2CmmTriggerAndInCounter    Representation of C++ function s_Timestamp2CmmTriggerAndInCounter."); % Modify help description values as needed.
%defineArgument(s_Timestamp2CmmTriggerAndInCounterDefinition, "pTimestamp", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_Timestamp2CmmTriggerAndInCounterDefinition, "pInCounter", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_Timestamp2CmmTriggerAndInCounterDefinition, "pCmmTrigger", "clib.array.LLT.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Int, or int32
%defineArgument(s_Timestamp2CmmTriggerAndInCounterDefinition, "pCmmActive", "clib.array.LLT.Int", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Int, or int32
%defineArgument(s_Timestamp2CmmTriggerAndInCounterDefinition, "pCmmCount", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%validate(s_Timestamp2CmmTriggerAndInCounterDefinition);

%% C++ function |s_Timestamp2TimeAndCount| with MATLAB name |clib.LLT.s_Timestamp2TimeAndCount|
% C++ Signature: void s_Timestamp2TimeAndCount(unsigned char const * pTimestamp,double * pTimeShutterOpen,double * pTimeShutterClose,unsigned int * pProfileCount)
%s_Timestamp2TimeAndCountDefinition = addFunction(libDef, ...
%    "void s_Timestamp2TimeAndCount(unsigned char const * pTimestamp,double * pTimeShutterOpen,double * pTimeShutterClose,unsigned int * pProfileCount)", ...
%    "MATLABName", "clib.LLT.s_Timestamp2TimeAndCount", ...
%    "Description", "clib.LLT.s_Timestamp2TimeAndCount    Representation of C++ function s_Timestamp2TimeAndCount."); % Modify help description values as needed.
%defineArgument(s_Timestamp2TimeAndCountDefinition, "pTimestamp", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_Timestamp2TimeAndCountDefinition, "pTimeShutterOpen", "clib.array.LLT.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Double, or double
%defineArgument(s_Timestamp2TimeAndCountDefinition, "pTimeShutterClose", "clib.array.LLT.Double", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Double, or double
%defineArgument(s_Timestamp2TimeAndCountDefinition, "pProfileCount", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%validate(s_Timestamp2TimeAndCountDefinition);

%% C++ function |s_ReadPostProcessingParameter| with MATLAB name |clib.LLT.s_ReadPostProcessingParameter|
% C++ Signature: int s_ReadPostProcessingParameter(long pLLT,DWORD * pParameter,unsigned int nSize)
%s_ReadPostProcessingParameterDefinition = addFunction(libDef, ...
%    "int s_ReadPostProcessingParameter(long pLLT,DWORD * pParameter,unsigned int nSize)", ...
%    "MATLABName", "clib.LLT.s_ReadPostProcessingParameter", ...
%    "Description", "clib.LLT.s_ReadPostProcessingParameter    Representation of C++ function s_ReadPostProcessingParameter."); % Modify help description values as needed.
%defineArgument(s_ReadPostProcessingParameterDefinition, "pLLT", "int32");
%defineArgument(s_ReadPostProcessingParameterDefinition, "pParameter", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineArgument(s_ReadPostProcessingParameterDefinition, "nSize", "uint32");
%defineOutput(s_ReadPostProcessingParameterDefinition, "RetVal", "int32");
%validate(s_ReadPostProcessingParameterDefinition);

%% C++ function |s_WritePostProcessingParameter| with MATLAB name |clib.LLT.s_WritePostProcessingParameter|
% C++ Signature: int s_WritePostProcessingParameter(long pLLT,DWORD * pParameter,unsigned int nSize)
%s_WritePostProcessingParameterDefinition = addFunction(libDef, ...
%    "int s_WritePostProcessingParameter(long pLLT,DWORD * pParameter,unsigned int nSize)", ...
%    "MATLABName", "clib.LLT.s_WritePostProcessingParameter", ...
%    "Description", "clib.LLT.s_WritePostProcessingParameter    Representation of C++ function s_WritePostProcessingParameter."); % Modify help description values as needed.
%defineArgument(s_WritePostProcessingParameterDefinition, "pLLT", "int32");
%defineArgument(s_WritePostProcessingParameterDefinition, "pParameter", "clib.array.LLT.UnsignedLong", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedLong, or uint32
%defineArgument(s_WritePostProcessingParameterDefinition, "nSize", "uint32");
%defineOutput(s_WritePostProcessingParameterDefinition, "RetVal", "int32");
%validate(s_WritePostProcessingParameterDefinition);

%% C++ function |s_ConvertProfile2ModuleResult| with MATLAB name |clib.LLT.s_ConvertProfile2ModuleResult|
% C++ Signature: int s_ConvertProfile2ModuleResult(long pLLT,unsigned char const * pProfileBuffer,unsigned int nProfileBufferSize,unsigned char * pModuleResultBuffer,unsigned int nResultBufferSize,TPartialProfile * pPartialProfile)
%s_ConvertProfile2ModuleResultDefinition = addFunction(libDef, ...
%    "int s_ConvertProfile2ModuleResult(long pLLT,unsigned char const * pProfileBuffer,unsigned int nProfileBufferSize,unsigned char * pModuleResultBuffer,unsigned int nResultBufferSize,TPartialProfile * pPartialProfile)", ...
%    "MATLABName", "clib.LLT.s_ConvertProfile2ModuleResult", ...
%    "Description", "clib.LLT.s_ConvertProfile2ModuleResult    Representation of C++ function s_ConvertProfile2ModuleResult."); % Modify help description values as needed.
%defineArgument(s_ConvertProfile2ModuleResultDefinition, "pLLT", "int32");
%defineArgument(s_ConvertProfile2ModuleResultDefinition, "pProfileBuffer", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_ConvertProfile2ModuleResultDefinition, "nProfileBufferSize", "uint32");
%defineArgument(s_ConvertProfile2ModuleResultDefinition, "pModuleResultBuffer", "clib.array.LLT.UnsignedChar", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedChar, or uint8
%defineArgument(s_ConvertProfile2ModuleResultDefinition, "nResultBufferSize", "uint32");
%defineArgument(s_ConvertProfile2ModuleResultDefinition, "pPartialProfile", "clib.LLT.TPartialProfile", "input", <SHAPE>); % '<MLTYPE>' can be clib.LLT.TPartialProfile, or clib.array.LLT.TPartialProfile
%defineOutput(s_ConvertProfile2ModuleResultDefinition, "RetVal", "int32");
%validate(s_ConvertProfile2ModuleResultDefinition);

%% C++ function |s_SaveProfiles| with MATLAB name |clib.LLT.s_SaveProfiles|
% C++ Signature: int s_SaveProfiles(long pLLT,char const * pFilename,TFileType FileType)
%s_SaveProfilesDefinition = addFunction(libDef, ...
%    "int s_SaveProfiles(long pLLT,char const * pFilename,TFileType FileType)", ...
%    "MATLABName", "clib.LLT.s_SaveProfiles", ...
%    "Description", "clib.LLT.s_SaveProfiles    Representation of C++ function s_SaveProfiles."); % Modify help description values as needed.
%defineArgument(s_SaveProfilesDefinition, "pLLT", "int32");
%defineArgument(s_SaveProfilesDefinition, "pFilename", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_SaveProfilesDefinition, "FileType", "clib.LLT.TFileType");
%defineOutput(s_SaveProfilesDefinition, "RetVal", "int32");
%validate(s_SaveProfilesDefinition);

%% C++ function |s_LoadProfilesGetPos| with MATLAB name |clib.LLT.s_LoadProfilesGetPos|
% C++ Signature: int s_LoadProfilesGetPos(long pLLT,unsigned int * pActualPosition,unsigned int * pMaxPosition)
%s_LoadProfilesGetPosDefinition = addFunction(libDef, ...
%    "int s_LoadProfilesGetPos(long pLLT,unsigned int * pActualPosition,unsigned int * pMaxPosition)", ...
%    "MATLABName", "clib.LLT.s_LoadProfilesGetPos", ...
%    "Description", "clib.LLT.s_LoadProfilesGetPos    Representation of C++ function s_LoadProfilesGetPos."); % Modify help description values as needed.
%defineArgument(s_LoadProfilesGetPosDefinition, "pLLT", "int32");
%defineArgument(s_LoadProfilesGetPosDefinition, "pActualPosition", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_LoadProfilesGetPosDefinition, "pMaxPosition", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_LoadProfilesGetPosDefinition, "RetVal", "int32");
%validate(s_LoadProfilesGetPosDefinition);

%% C++ function |s_LoadProfilesSetPos| with MATLAB name |clib.LLT.s_LoadProfilesSetPos|
% C++ Signature: int s_LoadProfilesSetPos(long pLLT,unsigned int nNewPosition)
s_LoadProfilesSetPosDefinition = addFunction(libDef, ...
    "int s_LoadProfilesSetPos(long pLLT,unsigned int nNewPosition)", ...
    "MATLABName", "clib.LLT.s_LoadProfilesSetPos", ...
    "Description", "clib.LLT.s_LoadProfilesSetPos    Representation of C++ function s_LoadProfilesSetPos."); % Modify help description values as needed.
defineArgument(s_LoadProfilesSetPosDefinition, "pLLT", "int32");
defineArgument(s_LoadProfilesSetPosDefinition, "nNewPosition", "uint32");
defineOutput(s_LoadProfilesSetPosDefinition, "RetVal", "int32");
validate(s_LoadProfilesSetPosDefinition);

%% C++ function |s_StartTransmissionAndCmmTrigger| with MATLAB name |clib.LLT.s_StartTransmissionAndCmmTrigger|
% C++ Signature: int s_StartTransmissionAndCmmTrigger(long pLLT,DWORD nCmmTrigger,TTransferProfileType TransferProfileType,unsigned int nProfilesForerun,char const * pFilename,TFileType FileType,unsigned int nTimeout)
%s_StartTransmissionAndCmmTriggerDefinition = addFunction(libDef, ...
%    "int s_StartTransmissionAndCmmTrigger(long pLLT,DWORD nCmmTrigger,TTransferProfileType TransferProfileType,unsigned int nProfilesForerun,char const * pFilename,TFileType FileType,unsigned int nTimeout)", ...
%    "MATLABName", "clib.LLT.s_StartTransmissionAndCmmTrigger", ...
%    "Description", "clib.LLT.s_StartTransmissionAndCmmTrigger    Representation of C++ function s_StartTransmissionAndCmmTrigger."); % Modify help description values as needed.
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "pLLT", "int32");
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "nCmmTrigger", "uint32");
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "TransferProfileType", "clib.LLT.TTransferProfileType");
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "nProfilesForerun", "uint32");
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "pFilename", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "FileType", "clib.LLT.TFileType");
%defineArgument(s_StartTransmissionAndCmmTriggerDefinition, "nTimeout", "uint32");
%defineOutput(s_StartTransmissionAndCmmTriggerDefinition, "RetVal", "int32");
%validate(s_StartTransmissionAndCmmTriggerDefinition);

%% C++ function |s_StopTransmissionAndCmmTrigger| with MATLAB name |clib.LLT.s_StopTransmissionAndCmmTrigger|
% C++ Signature: int s_StopTransmissionAndCmmTrigger(long pLLT,int nCmmTriggerPolarity,unsigned int nTimeout)
s_StopTransmissionAndCmmTriggerDefinition = addFunction(libDef, ...
    "int s_StopTransmissionAndCmmTrigger(long pLLT,int nCmmTriggerPolarity,unsigned int nTimeout)", ...
    "MATLABName", "clib.LLT.s_StopTransmissionAndCmmTrigger", ...
    "Description", "clib.LLT.s_StopTransmissionAndCmmTrigger    Representation of C++ function s_StopTransmissionAndCmmTrigger."); % Modify help description values as needed.
defineArgument(s_StopTransmissionAndCmmTriggerDefinition, "pLLT", "int32");
defineArgument(s_StopTransmissionAndCmmTriggerDefinition, "nCmmTriggerPolarity", "int32");
defineArgument(s_StopTransmissionAndCmmTriggerDefinition, "nTimeout", "uint32");
defineOutput(s_StopTransmissionAndCmmTriggerDefinition, "RetVal", "int32");
validate(s_StopTransmissionAndCmmTriggerDefinition);

%% C++ function |s_TranslateErrorValue| with MATLAB name |clib.LLT.s_TranslateErrorValue|
% C++ Signature: int s_TranslateErrorValue(long pLLT,int ErrorValue,char * pString,unsigned int nStringSize)
%s_TranslateErrorValueDefinition = addFunction(libDef, ...
%    "int s_TranslateErrorValue(long pLLT,int ErrorValue,char * pString,unsigned int nStringSize)", ...
%    "MATLABName", "clib.LLT.s_TranslateErrorValue", ...
%    "Description", "clib.LLT.s_TranslateErrorValue    Representation of C++ function s_TranslateErrorValue."); % Modify help description values as needed.
%defineArgument(s_TranslateErrorValueDefinition, "pLLT", "int32");
%defineArgument(s_TranslateErrorValueDefinition, "ErrorValue", "int32");
%defineArgument(s_TranslateErrorValueDefinition, "pString", <MLTYPE>, "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.Char,int8,string, or char
%defineArgument(s_TranslateErrorValueDefinition, "nStringSize", "uint32");
%defineOutput(s_TranslateErrorValueDefinition, "RetVal", "int32");
%validate(s_TranslateErrorValueDefinition);

%% C++ function |s_GetActualUserMode| with MATLAB name |clib.LLT.s_GetActualUserMode|
% C++ Signature: int s_GetActualUserMode(long pLLT,unsigned int * pActualUserMode,unsigned int * pUserModeCount)
%s_GetActualUserModeDefinition = addFunction(libDef, ...
%    "int s_GetActualUserMode(long pLLT,unsigned int * pActualUserMode,unsigned int * pUserModeCount)", ...
%    "MATLABName", "clib.LLT.s_GetActualUserMode", ...
%    "Description", "clib.LLT.s_GetActualUserMode    Representation of C++ function s_GetActualUserMode."); % Modify help description values as needed.
%defineArgument(s_GetActualUserModeDefinition, "pLLT", "int32");
%defineArgument(s_GetActualUserModeDefinition, "pActualUserMode", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineArgument(s_GetActualUserModeDefinition, "pUserModeCount", "clib.array.LLT.UnsignedInt", "input", <SHAPE>); % '<MLTYPE>' can be clib.array.LLT.UnsignedInt, or uint32
%defineOutput(s_GetActualUserModeDefinition, "RetVal", "int32");
%validate(s_GetActualUserModeDefinition);

%% C++ function |s_ReadWriteUserModes| with MATLAB name |clib.LLT.s_ReadWriteUserModes|
% C++ Signature: int s_ReadWriteUserModes(long pLLT,int nWrite,unsigned int nUserMode)
s_ReadWriteUserModesDefinition = addFunction(libDef, ...
    "int s_ReadWriteUserModes(long pLLT,int nWrite,unsigned int nUserMode)", ...
    "MATLABName", "clib.LLT.s_ReadWriteUserModes", ...
    "Description", "clib.LLT.s_ReadWriteUserModes    Representation of C++ function s_ReadWriteUserModes."); % Modify help description values as needed.
defineArgument(s_ReadWriteUserModesDefinition, "pLLT", "int32");
defineArgument(s_ReadWriteUserModesDefinition, "nWrite", "int32");
defineArgument(s_ReadWriteUserModesDefinition, "nUserMode", "uint32");
defineOutput(s_ReadWriteUserModesDefinition, "RetVal", "int32");
validate(s_ReadWriteUserModesDefinition);

%% C++ function |s_SaveGlobalParameter| with MATLAB name |clib.LLT.s_SaveGlobalParameter|
% C++ Signature: int s_SaveGlobalParameter(long pLLT)
s_SaveGlobalParameterDefinition = addFunction(libDef, ...
    "int s_SaveGlobalParameter(long pLLT)", ...
    "MATLABName", "clib.LLT.s_SaveGlobalParameter", ...
    "Description", "clib.LLT.s_SaveGlobalParameter    Representation of C++ function s_SaveGlobalParameter."); % Modify help description values as needed.
defineArgument(s_SaveGlobalParameterDefinition, "pLLT", "int32");
defineOutput(s_SaveGlobalParameterDefinition, "RetVal", "int32");
validate(s_SaveGlobalParameterDefinition);

%% C++ function |s_TriggerProfile| with MATLAB name |clib.LLT.s_TriggerProfile|
% C++ Signature: int s_TriggerProfile(long pLLT)
s_TriggerProfileDefinition = addFunction(libDef, ...
    "int s_TriggerProfile(long pLLT)", ...
    "MATLABName", "clib.LLT.s_TriggerProfile", ...
    "Description", "clib.LLT.s_TriggerProfile    Representation of C++ function s_TriggerProfile."); % Modify help description values as needed.
defineArgument(s_TriggerProfileDefinition, "pLLT", "int32");
defineOutput(s_TriggerProfileDefinition, "RetVal", "int32");
validate(s_TriggerProfileDefinition);

%% C++ function |s_TriggerContainer| with MATLAB name |clib.LLT.s_TriggerContainer|
% C++ Signature: int s_TriggerContainer(long pLLT)
s_TriggerContainerDefinition = addFunction(libDef, ...
    "int s_TriggerContainer(long pLLT)", ...
    "MATLABName", "clib.LLT.s_TriggerContainer", ...
    "Description", "clib.LLT.s_TriggerContainer    Representation of C++ function s_TriggerContainer."); % Modify help description values as needed.
defineArgument(s_TriggerContainerDefinition, "pLLT", "int32");
defineOutput(s_TriggerContainerDefinition, "RetVal", "int32");
validate(s_TriggerContainerDefinition);

%% C++ function |s_ContainerTriggerEnable| with MATLAB name |clib.LLT.s_ContainerTriggerEnable|
% C++ Signature: int s_ContainerTriggerEnable(long pLLT)
s_ContainerTriggerEnableDefinition = addFunction(libDef, ...
    "int s_ContainerTriggerEnable(long pLLT)", ...
    "MATLABName", "clib.LLT.s_ContainerTriggerEnable", ...
    "Description", "clib.LLT.s_ContainerTriggerEnable    Representation of C++ function s_ContainerTriggerEnable."); % Modify help description values as needed.
defineArgument(s_ContainerTriggerEnableDefinition, "pLLT", "int32");
defineOutput(s_ContainerTriggerEnableDefinition, "RetVal", "int32");
validate(s_ContainerTriggerEnableDefinition);

%% C++ function |s_ContainerTriggerDisable| with MATLAB name |clib.LLT.s_ContainerTriggerDisable|
% C++ Signature: int s_ContainerTriggerDisable(long pLLT)
s_ContainerTriggerDisableDefinition = addFunction(libDef, ...
    "int s_ContainerTriggerDisable(long pLLT)", ...
    "MATLABName", "clib.LLT.s_ContainerTriggerDisable", ...
    "Description", "clib.LLT.s_ContainerTriggerDisable    Representation of C++ function s_ContainerTriggerDisable."); % Modify help description values as needed.
defineArgument(s_ContainerTriggerDisableDefinition, "pLLT", "int32");
defineOutput(s_ContainerTriggerDisableDefinition, "RetVal", "int32");
validate(s_ContainerTriggerDisableDefinition);

%% C++ function |s_FlushContainer| with MATLAB name |clib.LLT.s_FlushContainer|
% C++ Signature: int s_FlushContainer(long pLLT)
s_FlushContainerDefinition = addFunction(libDef, ...
    "int s_FlushContainer(long pLLT)", ...
    "MATLABName", "clib.LLT.s_FlushContainer", ...
    "Description", "clib.LLT.s_FlushContainer    Representation of C++ function s_FlushContainer."); % Modify help description values as needed.
defineArgument(s_FlushContainerDefinition, "pLLT", "int32");
defineOutput(s_FlushContainerDefinition, "RetVal", "int32");
validate(s_FlushContainerDefinition);

%% Validate the library definition
validate(libDef);

end
