' Wrapper module for Visual Basic 6 (VB6) and Visual Basic for Applications (VBA)
' It simplifies usage of MEDAQLib DLL

Attribute VB_Name = "MEDAQLib"
Option Explicit

Public Enum ME_SENSOR
    SENSOR_ILR110x_115x = 19 'optoNCDT ILR
    SENSOR_ILR118x = 20 'optoNCDT ILR
    SENSOR_ILR1191 = 21 'optoNCDT ILR
    SENSOR_ILD1220 = 56 'optoNCDT
    SENSOR_ILD1302 = 24 'optoNCDT
    SENSOR_ILD1320 = 41 'optoNCDT
    SENSOR_ILD1401 = 1 'optoNCDT
    SENSOR_ILD1402 = 23 'optoNCDT
    SENSOR_ILD1420 = 42 'optoNCDT
    SENSOR_ILD1700 = 2 'optoNCDT
    SENSOR_ILD1750 = 51 'optoNCDT
    SENSOR_ILD1900 = 58 'optoNCDT
    SENSOR_ILD2200 = 5 'optoNCDT
    SENSOR_ILD2300 = 29 'optoNCDT
    SENSOR_IFD2401 = 12 'confocalDT
    SENSOR_IFD2421 = 46 'confocalDT
    SENSOR_IFD2422 = 47 'confocalDT
    SENSOR_IFD2431 = 13 'confocalDT
    SENSOR_IFD2445 = 39 'confocalDT
    SENSOR_IFD2451 = 30 'confocalDT
    SENSOR_IFD2461 = 44 'confocalDT
    SENSOR_IFD2471 = 26 'confocalDT
    SENSOR_ODC1202 = 25 'optoCONTROL
    SENSOR_ODC2500 = 8 'optoCONTROL
    SENSOR_ODC2520 = 37 'optoCONTROL
    SENSOR_ODC2600 = 9 'optoCONTROL
    SENSOR_LLT27xx = 31 'scanCONTROL+gapCONTROL only for SensorFinder functionality OpenSensor will fail
    SENSOR_DT3060 = 50 'eddyNCDT
    SENSOR_DT3100 = 28 'eddyNCDT
    SENSOR_IMC5400 = 55 'interferoMETER
    SENSOR_DT6100 = 16 'capaNCDT
    SENSOR_DT6120 = 40 'capaNCDT
    CONTROLLER_DT6200 = 33 'capaNCDT
    CONTROLLER_KSS6380 = 18 'capaNCDT
    CONTROLLER_KSS64xx = 45 'capaNCDT
    CONTROLLER_DT6500 = 15 'capaNCDT
    CONTROLLER_DT6536 = 54 'capaNCDT
    SENSOR_ON_MEBUS = 43 'Generic sensor with MEbus protocol support, only for internal use
    ENCODER_IF2004 = 10 'deprecated use PCI_CARD_IF2004 instead
    PCI_CARD_IF2004 = 10 'PCI card IF2004
    PCI_CARD_IF2008 = 22 'PCI card IF2008
    ETH_ADAPTER_IF2008 = 52 'IF2008 ethernet adapter
    CONTROLLER_CSP2008 = 32 'Universal controller
    ETH_IF1032 = 34 'Interface module Ethernet/EtherCAT
    USB_ADAPTER_IF2004 = 36 'IF2004 USB adapter (4 x RS422)
    CONTROLLER_CBOX = 38 'External C-Box controller
    THICKNESS_SENSOR = 48 'thicknessSENSOR
    SENSOR_ACS7000 = 35 'colorCONTROL
    SENSOR_CFO = 53 'colorCONTROL
    SENSOR_GENERIC = 49 'Generic sensor, only for internal use
    MULTI_SENSOR = 57 'Container for synchronized data aquisition of multiple sensors
End Enum

Enum ERR_CODE
    ERR_NOERROR = 0
    ERR_FUNCTION_NOT_SUPPORTED = -1
    ERR_CANNOT_OPEN = -2
    ERR_NOT_OPEN = -3
    ERR_APPLYING_PARAMS = -4
    ERR_SEND_CMD_TO_SENSOR = -5
    ERR_CLEARING_BUFFER = -6
    ERR_HW_COMMUNICATION = -7
    ERR_TIMEOUT_READING_FROM_SENSOR = -8
    ERR_READING_SENSOR_DATA = -9
    ERR_INTERFACE_NOT_SUPPORTED = -10
    ERR_ALREADY_OPEN = -11
    ERR_CANNOT_CREATE_INTERFACE = -12
    ERR_NO_SENSORDATA_AVAILABLE = -13
    ERR_UNKNOWN_SENSOR_COMMAND = -14
    ERR_UNKNOWN_SENSOR_ANSWER = -15
    ERR_SENSOR_ANSWER_ERROR = -16
    ERR_SENSOR_ANSWER_TOO_SHORT = -17
    ERR_WRONG_PARAMETER = -18
    ERR_NOMEMORY = -19
    ERR_NO_ANSWER_RECEIVED = -20
    ERR_SENSOR_ANSWER_DOES_NOT_MATCH_COMMAND = -21
    ERR_BAUDRATE_TOO_LOW = -22
    ERR_OVERFLOW = -23
    ERR_INSTANCE_NOT_EXIST = -24
    ERR_NOT_FOUND = -25
    ERR_WARNING = -26
    ERR_SENSOR_ANSWER_WARNING = -27
End Enum

Public Declare Function CreateSensorInstance Lib "MEDAQLib.dll" (ByVal sensor As ME_SENSOR) As Long
Public Declare Function CreateSensorInstByName Lib "MEDAQLib.dll" (ByVal sensorName As String) As Long
Public Declare Function CreateSensorInstByNameU Lib "MEDAQLib.dll" (ByVal sensorName As String) As Long
Public Declare Function ReleaseSensorInstance Lib "MEDAQLib.dll" (ByVal instanceHandle As Long) As ERR_CODE
Public Declare Function SetParameterInt Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As Long) As ERR_CODE
#If PLATFORM = "x64" Then
Public Declare Function SetParameterDWORD_PTR Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As LongLong) As ERR_CODE
#Else
Public Declare Function SetParameterDWORD_PTR Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As Long) As ERR_CODE
#End If
Public Declare Function SetParameterDouble Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As Double) As ERR_CODE
Public Declare Function SetParameterString Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As String) As ERR_CODE
' Following function expects an array. At VB you have to pass the first value of array as reference.
Public Declare Function SetParameterBinary Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Byte, ByVal length As Long) As ERR_CODE
Public Declare Function SetParameters Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal parameterList As String) As ERR_CODE
Public Declare Function SetParameterIntU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As Long) As ERR_CODE
#If PLATFORM = "x64" Then
Public Declare Function SetParameterDWORD_PTRU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As LongLong) As ERR_CODE
#Else
Public Declare Function SetParameterDWORD_PTRU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As Long) As ERR_CODE
#End If
Public Declare Function SetParameterDoubleU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As Double) As ERR_CODE
Public Declare Function SetParameterStringU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As String) As ERR_CODE
' Following function expects an array. At VB you have to pass the first value of array as reference.
Public Declare Function SetParameterBinaryU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Byte, ByVal length As Long) As ERR_CODE
Public Declare Function SetParametersU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal parameterList As String) As ERR_CODE
Public Declare Function GetParameterInt Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Long) As ERR_CODE
#If PLATFORM = "x64" Then
Public Declare Function GetParameterDWORD_PTR Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As LongLong) As ERR_CODE
#Else
Public Declare Function GetParameterDWORD_PTR Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Long) As ERR_CODE
#End If
Public Declare Function GetParameterDouble Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Double) As ERR_CODE
Public Declare Function GetParameterString Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As String, ByRef maxLen As Long) As ERR_CODE
' Following function expects an array. At VB you have to pass the first value of array as reference.
Public Declare Function GetParameterBinary Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Byte, ByRef maxLen As Long) As ERR_CODE
' Preceding function is able to return the requested length of paramValue in maxLen (if it is called with a NULL pointer at paramValue).
' But VB does not support this. As a work around, use following function to retrieve length and pass 0&.
Public Declare Function GetParameterBinaryLen Lib "MEDAQLib.dll" Alias "GetParameterBinary" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal nullPtr As Long, ByRef maxLen As Long) As ERR_CODE
Public Declare Function GetParameters Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal parameterList As String, ByRef maxLen As Long) As ERR_CODE
Public Declare Function GetParameterIntU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Long) As ERR_CODE
#If PLATFORM = "x64" Then
Public Declare Function GetParameterDWORD_PTRU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As LongLong) As ERR_CODE
#Else
Public Declare Function GetParameterDWORD_PTRU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Long) As ERR_CODE
#End If
Public Declare Function GetParameterDoubleU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Double) As ERR_CODE
Public Declare Function GetParameterStringU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal paramValue As String, ByRef maxLen As Long) As ERR_CODE
' Following function expects an array. At VB you have to pass the first value of array as reference.
Public Declare Function GetParameterBinaryU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal paramName As String, ByRef paramValue As Byte, ByRef maxLen As Long) As ERR_CODE
' Preceding function is able to return the requested length of paramValue in maxLen (if it is called with a NULL pointer at paramValue).
' But VB does not support this. As a work around, use following function to retrieve length and pass 0&.
Public Declare Function GetParameterBinaryLenU Lib "MEDAQLib.dll" Alias "GetParameterBinaryU" (ByVal instanceHandle As Long, ByVal paramName As String, ByVal nullPtr As Long, ByRef maxLen As Long) As ERR_CODE
Public Declare Function GetParametersU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal parameterList As String, ByRef maxLen As Long) As ERR_CODE
Public Declare Function ClearAllParameters Lib "MEDAQLib.dll" (ByVal instanceHandle As Long) As ERR_CODE
Public Declare Function OpenSensor Lib "MEDAQLib.dll" (ByVal instanceHandle As Long) As ERR_CODE
Public Declare Function CloseSensor Lib "MEDAQLib.dll" (ByVal instanceHandle As Long) As ERR_CODE
Public Declare Function SensorCommand Lib "MEDAQLib.dll" (ByVal instanceHandle As Long) As ERR_CODE
Public Declare Function DataAvail Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByRef avail As Long) As ERR_CODE
' Following functions (TransferData, TransferDataTS and Poll) expects an array (for rawData and scaledData). At VB you have to pass the first value of array as reference.
' A null pointer is supported, too. But VB does not support this. As a work around, declare the desired parameter as ByVal ... As Long and pass 0&
Public Declare Function TransferData Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByRef rawData As Long, ByRef scaledData As Double, ByVal maxValues As Long, ByRef read As Long) As ERR_CODE
Public Declare Function TransferDataTS Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByRef rawData As Long, ByRef scaledData As Double, ByVal maxValues As Long, ByRef read As Long, ByRef timestamp As Double) As ERR_CODE
Public Declare Function Poll Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByRef rawData As Long, ByRef scaledData As Double, ByVal maxValues As Long) As ERR_CODE
Public Declare Function GetError Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal errText As String, ByVal maxLen As Long) As ERR_CODE
Public Declare Function GetErrorU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal errText As String, ByVal maxLen As Long) As ERR_CODE
Public Declare Function GetDLLVersion Lib "MEDAQLib.dll" (ByVal versionStr As String, ByVal maxLen As Long) As ERR_CODE
Public Declare Function GetDLLVersionU Lib "MEDAQLib.dll" (ByVal versionStr As String, ByVal maxLen As Long) As ERR_CODE
Public Declare Function EnableLogging Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal enable As Long, ByVal logType As Long, ByVal logLevel As Long, ByVal logFile As String, ByVal logAppend As Long, ByVal logFlush As Long, ByVal logSplitSize As Long) As ERR_CODE
Public Declare Function EnableLoggingU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal enable As Long, ByVal logType As Long, ByVal logLevel As Long, ByVal logFile As String, ByVal logAppend As Long, ByVal logFlush As Long, ByVal logSplitSize As Long) As ERR_CODE
Public Declare Function OpenSensorRS232 Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal port As String) As ERR_CODE
Public Declare Function OpenSensorIF2004 Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal cardInstance As Long, ByVal channelNumber As Long) As ERR_CODE
Public Declare Function OpenSensorIF2004_USB Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal deviceInstance As Long, ByVal serialNumber As String, ByVal port As String, ByVal channelNumber As Long) As ERR_CODE
Public Declare Function OpenSensorIF2008 Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal cardInstance As Long, ByVal channelNumber As Long) As ERR_CODE
Public Declare Function OpenSensorIF2008_ETH Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal remoteAddr As String, ByVal channelNumber As Long) As ERR_CODE
Public Declare Function OpenSensorTCPIP Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal remoteAddr As String) As ERR_CODE
Public Declare Function OpenSensorWinUSB Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal deviceInstance As Long) As ERR_CODE
Public Declare Function OpenSensorRS232U Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal port As String) As ERR_CODE
Public Declare Function OpenSensorIF2004_USBU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal deviceInstance As Long, ByVal serialNumber As String, ByVal port As String, ByVal channelNumber As Long) As ERR_CODE
Public Declare Function OpenSensorTCPIPU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal remoteAddr As String) As ERR_CODE
Public Declare Function ExecSCmd Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String) As ERR_CODE
Public Declare Function SetIntExecSCmd Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As Long) As ERR_CODE
Public Declare Function SetDoubleExecSCmd Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As Double) As ERR_CODE
Public Declare Function SetStringExecSCmd Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As String) As ERR_CODE
Public Declare Function ExecSCmdGetInt Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByRef paramValue As Long) As ERR_CODE
Public Declare Function ExecSCmdGetDouble Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByRef paramValue As Double) As ERR_CODE
Public Declare Function ExecSCmdGetString Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As String, ByRef maxLen As Long) As ERR_CODE
Public Declare Function ExecSCmdU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String) As ERR_CODE
Public Declare Function SetIntExecSCmdU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As Long) As ERR_CODE
Public Declare Function SetDoubleExecSCmdU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As Double) As ERR_CODE
Public Declare Function SetStringExecSCmdU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As String) As ERR_CODE
Public Declare Function ExecSCmdGetIntU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByRef paramValue As Long) As ERR_CODE
Public Declare Function ExecSCmdGetDoubleU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByRef paramValue As Double) As ERR_CODE
Public Declare Function ExecSCmdGetStringU Lib "MEDAQLib.dll" (ByVal instanceHandle As Long, ByVal SensorCommand As String, ByVal paramName As String, ByVal paramValue As String, ByRef maxLen As Long) As ERR_CODE
' Following helper function allows to call EnableLogging with Boolean arguments (enable, logAppend, logFlush)
Public Function EnableLoggingBool(ByVal instanceHandle As Long, ByVal enable As Boolean, ByVal logType As Long, ByVal logLevel As Long, ByVal logFile As String, ByVal logAppend As Boolean, ByVal logFlush As Boolean, ByVal logSplitSize As Long) As ERR_CODE
    Dim enable__ As Long, logAppend__ As Long, logFlush__ As Long
    enable__ = IIf(enable, 1, 0)
    logAppend__ = IIf(logAppend, 1, 0)
    logFlush__ = IIf(logFlush, 1, 0)
    EnableLoggingBool = EnableLogging(instanceHandle, enable__, logType, logLevel, logFile, logAppend__, logFlush__, logSplitSize)
End Function

