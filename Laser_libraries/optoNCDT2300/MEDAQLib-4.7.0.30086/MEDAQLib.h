#pragma once
/* Copyright (C) Micro-Epsilon Messtechnik GmbH & Co. KG
 *
 * This file is part of MEDAQLib Software Development Kit.
 * All Rights Reserved.
 *
 * THIS SOURCE FILE IS THE PROPERTY OF MICRO-EPSILON MESSTECHNIK AND
 * IS NOT TO BE RE-DISTRIBUTED BY ANY MEANS WHATSOEVER WITHOUT THE
 * EXPRESSED WRITTEN CONSENT OF MICRO-EPSILON MESSTECHNIK.
 *
 * Contact information:
 *    mailto:info@micro-epsilon.de
 *    http://www.micro-epsilon.de
 *
 */

#if defined(_MSC_VER) && _MSC_VER<=1500
// VS2008 and older does not have stdint.h
typedef unsigned char uint8_t;
typedef int           int32_t;
typedef unsigned int  uint32_t;
#else
#include <stdint.h> // standard data types
#endif

typedef void *ptr_t;

#if defined(_WIN32)

#if !defined(WINAPI)
#define WINAPI __stdcall
#endif
#if !defined(WINAPIV)
#define WINAPIV __cdecl
#endif

#if defined(MEDAQLIB_EXPORTS)
#define MEDAQLIB_API __declspec(dllexport)
#else
#define MEDAQLIB_API __declspec(dllimport)
#endif // MEDAQLIB_EXPORTS

#elif defined(__linux__)

#if defined(MEDAQLIB_EXPORTS)
#define MEDAQLIB_API __attribute__ ((visibility ("default")))
#else
#define MEDAQLIB_API
#endif // MEDAQLIB_EXPORTS
#define WINAPI
#define WINAPIV

#endif // __linux__

/******************************************************************************
                            Data type declaration
ME_SENSOR is an enumeration of supported sensors (int32_t)
ERR_CODE  is an enumeration of error codes (int32_t)
int32_t   is a four byte signed integer type
uint32_t  is a four byte unsigned integer type
double    is an eight byte floating point type
*         function parameters with * are pointers to the type. They are used to 
          return information from the function. In some languages it is called
          "call by reference"
ptr_t     is a pointer (four byte on 32 bit systems, eight byte at 64 bit systems)
uint8_t * is a one binary unsigned buffer type
char *    is a string (pointer to char)
wchar_t * is a unicode string (pointer to wchar_t)

MEDAQLIB_API is defined as __declspec(dllimport) when using the
driver. When linking with MEDAQLib.lib all funktions with this
specifier are found in the library.

WINAPI defines the calling convention. On windows systems, it is defined 
as __stdcall on other systems it is defined empty.
WINAPIV defines a special calling convention. On windows systems, it is defined
as __cdecl on other systems it is defined empty.

For __stdcall, the arguments are submitted from right to left to the function. 
They are written as value (call by value) onto the stack (unless they 
are referenced as a pointer). The called function reads the arguments 
from the stack.
For __cdecl it is the same, but the caller has to clean up the stack.
******************************************************************************/

/******************************************************************************
                              Enumerations
In function calls enumerations can be used textual or as number
******************************************************************************/
typedef enum
	{
	NO_SENSOR=            0, // Dummy, only for internal use
	SENSOR_ILR110x_115x= 19, // optoNCDT ILR
	SENSOR_ILR118x=      20, // optoNCDT ILR
	SENSOR_ILR1191=      21, // optoNCDT ILR
	SENSOR_ILD1220=      56, // optoNCDT
	SENSOR_ILD1302=      24, // optoNCDT
	SENSOR_ILD1320=      41, // optoNCDT
	SENSOR_ILD1401=       1, // optoNCDT
	SENSOR_ILD1402=      23, // optoNCDT
	SENSOR_ILD1420=      42, // optoNCDT
	SENSOR_ILD1700=       2, // optoNCDT
	SENSOR_ILD1750=      51, // optoNCDT
	SENSOR_ILD2200=       5, // optoNCDT
	SENSOR_ILD2300=      29, // optoNCDT
	SENSOR_IFD2401=      12, // confocalDT
	SENSOR_IFD2421=      46, // confocalDT
	SENSOR_IFD2422=      47, // confocalDT
	SENSOR_IFD2431=      13, // confocalDT
	SENSOR_IFD2445=      39, // confocalDT
	SENSOR_IFD2451=      30, // confocalDT
	SENSOR_IFD2461=      44, // confocalDT
	SENSOR_IFD2471=      26, // confocalDT
	SENSOR_ODC1202=      25, // optoCONTROL
	SENSOR_ODC2500=       8, // optoCONTROL
	SENSOR_ODC2520=      37, // optoCONTROL
	SENSOR_ODC2600=       9, // optoCONTROL
	SENSOR_LLT27xx=      31, // scanCONTROL+gapCONTROL, only for SensorFinder functionality, OpenSensor will fail
	SENSOR_DT3060=       50, // eddyNCDT for whole DT306x and DT307x family
	SENSOR_DT3100=       28, // eddyNCDT
	SENSOR_DT6100=       16, // capaNCDT
	SENSOR_DT6120=       40, // capaNCDT
	CONTROLLER_DT6200=   33, // capaNCDT
	CONTROLLER_KSS6380=  18, // combiSENSOR
	CONTROLLER_KSS64xx=  45, // combiSENSOR
	CONTROLLER_DT6500=   15, // capaNCDT
	CONTROLLER_DT6536=   54, // capaNCDT
	SENSOR_ON_MEBUS=     43, // Generic sensor with MEbus protocol support
	ENCODER_IF2004=      10, // deprecated, use PCI_CARD_IF2004 instead
	PCI_CARD_IF2004=     10, // PCI card IF2004
	PCI_CARD_IF2008=     22, // PCI(e) card IF2008
	ETH_ADAPTER_IF2008=  52, // IF2008 ethernet adapter
	CONTROLLER_CSP2008=  32, // Universal controller
	ETH_IF1032=          34, // Interface module Ethernet/EtherCAT
	USB_ADAPTER_IF2004=  36, // IF2004 USB adapter (4 x RS422)
	CONTROLLER_CBOX=     38, // External C-Box controller
	THICKNESS_SENSOR=    48, // thicknessSENSOR
	SENSOR_ACS7000=      35, // colorCONTROL
	SENSOR_CFO=          53, // colorCONTROL
	SENSOR_GENERIC=      49, // Generic sensor, only for internal use
	NUMBER_OF_SENSORS=   58,
	} ME_SENSOR;

typedef enum
	{
	ERR_NOERROR= 0,
	ERR_FUNCTION_NOT_SUPPORTED= -1,
	ERR_CANNOT_OPEN= -2,
	ERR_NOT_OPEN= -3,
	ERR_APPLYING_PARAMS= -4,
	ERR_SEND_CMD_TO_SENSOR= -5,
	ERR_CLEARING_BUFFER= -6,
	ERR_HW_COMMUNICATION= -7,
	ERR_TIMEOUT_READING_FROM_SENSOR= -8,
	ERR_READING_SENSOR_DATA= -9,
	ERR_INTERFACE_NOT_SUPPORTED= -10,
	ERR_ALREADY_OPEN= -11,
	ERR_CANNOT_CREATE_INTERFACE= -12,
	ERR_NO_SENSORDATA_AVAILABLE= -13,
	ERR_UNKNOWN_SENSOR_COMMAND= -14,
	ERR_UNKNOWN_SENSOR_ANSWER= -15,
	ERR_SENSOR_ANSWER_ERROR= -16,
	ERR_SENSOR_ANSWER_TOO_SHORT= -17,
	ERR_WRONG_PARAMETER= -18,
	ERR_NOMEMORY= -19,
	ERR_NO_ANSWER_RECEIVED= -20,
	ERR_SENSOR_ANSWER_DOES_NOT_MATCH_COMMAND= -21,
	ERR_BAUDRATE_TOO_LOW= -22,
	ERR_OVERFLOW= -23,
	ERR_INSTANCE_NOT_EXIST= -24,
	ERR_NOT_FOUND= -25,
	ERR_WARNING= -26,
	ERR_SENSOR_ANSWER_WARNING= -27,
	} ERR_CODE;

/******************************************************************************
                              Function declaration
******************************************************************************/
#if defined(__cplusplus)
extern "C"	// all functions are exported with "C" linkage (C decorated)
	{
#endif // __cplusplus
/* CreateSensorInstance
   Create an instance of the specified sensor driver and returns an index
   greater 0. If the function fails, 0 is returned.                          */
	MEDAQLIB_API uint32_t WINAPI CreateSensorInstance    (ME_SENSOR sensorType);
	MEDAQLIB_API uint32_t WINAPI CreateSensorInstByName  (const char *   sensorName);
#if defined(_WIN32)
	MEDAQLIB_API uint32_t WINAPI CreateSensorInstByNameU (const wchar_t *sensorName);
#endif

/* ReleaseSensorInstance
   Frees the sensor driver instance previously created by CreateSensorInstance.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI ReleaseSensorInstance (uint32_t instanceHandle);

/* SetParameter
   Many different parameters can be specified for the sensors and interfaces.
   For normalisation purpose they can be set and buffered with SetParameter
   functions. All other functions use the parameters to operate.
   If binary data containing binary zero "\0" should be written, the
   function SetParameterBinary must be used and the complete length
   of the binary data (in bytes) must be set.
   See the manual for a list of parameters used in which function and for which
   sensor or interface.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI SetParameterInt        (uint32_t instanceHandle, const char *paramName, int32_t        paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterDWORD_PTR  (uint32_t instanceHandle, const char *paramName, ptr_t          paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterDouble     (uint32_t instanceHandle, const char *paramName, double         paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterString     (uint32_t instanceHandle, const char *paramName, const char *   paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterBinary     (uint32_t instanceHandle, const char *paramName, const uint8_t *paramValue, uint32_t len);
	MEDAQLIB_API ERR_CODE WINAPI SetParameters          (uint32_t instanceHandle, const char *parameterList);

#if defined(_WIN32)
	// Unicode versions
	MEDAQLIB_API ERR_CODE WINAPI SetParameterIntU       (uint32_t instanceHandle, const wchar_t *paramName, int32_t        paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterDWORD_PTRU (uint32_t instanceHandle, const wchar_t *paramName, ptr_t          paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterDoubleU    (uint32_t instanceHandle, const wchar_t *paramName, double         paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterStringU    (uint32_t instanceHandle, const wchar_t *paramName, const wchar_t *paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetParameterBinaryU    (uint32_t instanceHandle, const wchar_t *paramName, const uint8_t *paramValue, uint32_t len);
	MEDAQLIB_API ERR_CODE WINAPI SetParametersU         (uint32_t instanceHandle, const wchar_t *parameterList);
#endif // _WIN32

/* GetParameter
   Results from any functions are stored and can be retrieved with GetParameter.
   Values are stored in the second parameter (call by reference). When
   retrieving a string value, a string with enough space to hold the result
   must be passed. The length of the string must be specified in the length
   parameter. The length of the result string is returned in the length
   parameter too. If the string parameter is not specified (null pointer) the
   required length is returned in the parameter length.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI GetParameterInt        (uint32_t instanceHandle, const char *paramName, int32_t *paramValue);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterDWORD_PTR  (uint32_t instanceHandle, const char *paramName, ptr_t *  paramValue);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterDouble     (uint32_t instanceHandle, const char *paramName, double * paramValue);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterString     (uint32_t instanceHandle, const char *paramName, char *   paramValue, uint32_t *maxLen);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterBinary     (uint32_t instanceHandle, const char *paramName, uint8_t *paramValue, uint32_t *maxLen);
	MEDAQLIB_API ERR_CODE WINAPI GetParameters          (uint32_t instanceHandle,                        char *   parameterList, uint32_t *maxLen);

#if defined(_WIN32)
	// Unicode versions
	MEDAQLIB_API ERR_CODE WINAPI GetParameterIntU       (uint32_t instanceHandle, const wchar_t *paramName, int32_t *paramValue);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterDWORD_PTRU (uint32_t instanceHandle, const wchar_t *paramName, ptr_t *  paramValue);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterDoubleU    (uint32_t instanceHandle, const wchar_t *paramName, double * paramValue);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterStringU    (uint32_t instanceHandle, const wchar_t *paramName, wchar_t *paramValue, uint32_t *maxLen);
	MEDAQLIB_API ERR_CODE WINAPI GetParameterBinaryU    (uint32_t instanceHandle, const wchar_t *paramName, uint8_t *paramValue, uint32_t *maxLen);
	MEDAQLIB_API ERR_CODE WINAPI GetParametersU         (uint32_t instanceHandle,                           wchar_t *parameterList, uint32_t *maxLen);
#endif // _WIN32

/* ClearAllParameters
   Before building a new sensor command the internal buffer can be cleared to ensure
   that no old parameters affects the new command.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI ClearAllParameters (uint32_t instanceHandle);

/* OpenSensor
   Establish a connection to the sensor using the interface and parameters
   specified at SetParameter.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI OpenSensor (uint32_t instanceHandle);

/* CloseSensor
   Close the connection to the connected sensor.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI CloseSensor (uint32_t instanceHandle);

/* SensorCommand
   Send a command to the sensor and retrievs the answer. Both, command and
   answer can be set/read with Set- and GetParameter.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI SensorCommand (uint32_t instanceHandle);

/* DataAvail
   Check if data from Sensor is available and returns the number of values.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI DataAvail (uint32_t instanceHandle, int32_t *avail);

/* TransferData
   Retrievs specified amount of values from sensor and return the raw data
   in rawData (if not null) and the scaled data in scaledData (if not null).
   The first data in the buffer is returned and then removed from the buffer.
   The actual data read is stored in variable read (if not null).
   The second version stores the a timestamp of the first (oldest) value in the
   array (if not null). It is in milli seconds starting at 01.01.1970 01:00.
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI TransferData   (uint32_t instanceHandle, int32_t *rawData, double *scaledData, int32_t maxValues, int32_t *read);
	MEDAQLIB_API ERR_CODE WINAPI TransferDataTS (uint32_t instanceHandle, int32_t *rawData, double *scaledData, int32_t maxValues, int32_t *read, double *timestamp);

/* Poll
   Retrievs specified amount of values from sensor (max. one frame) and
   return the raw data in rawData (if not null) and the scaled data in
   scaledData (if not null). The latest values are returned, but no data is
   discarded in the sensor instance class (TransferData can be called
   independently from this).
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI Poll (uint32_t instanceHandle, int32_t *rawData, double *scaledData, int32_t maxValues);

/* GetError
   If an error had occured, the error text can be retrieved with GetError. The
   text is stored in errText limited to length of maxLen.
   Returns the number of the error returned in errText.                      */
	MEDAQLIB_API ERR_CODE WINAPI GetError  (uint32_t instanceHandle, char *   errText, uint32_t maxLen);
#if defined(_WIN32)
	// Unicode version
	MEDAQLIB_API ERR_CODE WINAPI GetErrorU (uint32_t instanceHandle, wchar_t *errText, uint32_t maxLen);
#endif // _WIN32

/* GetDLLVersion
   Retrievs the version of the MEDAQLib dll. The version is stored in
   versionStr and is limited to length of maxLen (should be at least 64 bytes).
   Returns ERR_NOERROR on success, otherwise an error return value.          */
	MEDAQLIB_API ERR_CODE WINAPI GetDLLVersion  (char *   versionStr, uint32_t maxLen);
#if defined(_WIN32)
	// Unicode version
	MEDAQLIB_API ERR_CODE WINAPI GetDLLVersionU (wchar_t *versionStr, uint32_t maxLen);
#endif // _WIN32

/* EnableLogging
   Wrapper functions for a set of SetParameterXXX to enable logging.
   This usage of this functions makes the code shorter and more readable.    */
	MEDAQLIB_API ERR_CODE WINAPI EnableLogging  (uint32_t instanceHandle, int32_t enableLogging, int32_t logTypes, int32_t logLevels, const char *   logFile, int32_t logAppend, int32_t logFlush, int32_t logSplitSize);
#if defined(_WIN32)
	// Unicode version
	MEDAQLIB_API ERR_CODE WINAPI EnableLoggingU (uint32_t instanceHandle, int32_t enableLogging, int32_t logTypes, int32_t logLevels, const wchar_t *logFile, int32_t logAppend, int32_t logFlush, int32_t logSplitSize);
#endif // _WIN32

/* LogToFile
   User function to allow an application to add lines to MEDAQLib log file.
   Because of variable argument list, only calling convention __cdecl is possible.*/
	MEDAQLIB_API ERR_CODE WINAPIV LogToFile  (uint32_t instanceHandle, int32_t logLevel, const char *   location, const char *   message, ...);
#if defined(_WIN32)
	// Unicode version
	MEDAQLIB_API ERR_CODE WINAPIV LogToFileU (uint32_t instanceHandle, int32_t logLevel, const wchar_t *location, const wchar_t *message, ...);
#endif

/* OpenSensorXXX
   Wrapper functions for a set of SetParameterXXX and OpenSensor.
   This usage of this functions makes the code shorter and more readable.    */
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorRS232       (uint32_t instanceHandle, const char *port);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorIF2004      (uint32_t instanceHandle, int32_t cardInstance, int32_t channelNumber);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorIF2004_USB  (uint32_t instanceHandle, int32_t deviceInstance, const char *serialNumber, const char *port, int32_t channelNumber);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorIF2008      (uint32_t instanceHandle, int32_t cardInstance, int32_t channelNumber);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorIF2008_ETH  (uint32_t instanceHandle, const char *remoteAddr, int32_t channelNumber);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorTCPIP       (uint32_t instanceHandle, const char *remoteAddr);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorWinUSB      (uint32_t instanceHandle, int32_t deviceInstance);
#if defined(_WIN32)
	// Unicode version
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorRS232U      (uint32_t instanceHandle, const wchar_t *port);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorIF2004_USBU (uint32_t instanceHandle, int32_t deviceInstance, const wchar_t *serialNumber, const wchar_t *port, int32_t channelNumber);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorIF2008_ETHU (uint32_t instanceHandle, const wchar_t *remoteAddr, int32_t channelNumber);
	MEDAQLIB_API ERR_CODE WINAPI OpenSensorTCPIPU      (uint32_t instanceHandle, const wchar_t *remoteAddr);
#endif // _WIN32

/* ExecSCmd
   Wrapper functions for a set of Set/GetParameterXXX and SensorCommand.
   This usage of this functions makes the code shorter and more readable.    */
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmd          (uint32_t instanceHandle, const char *sensorCommand);
	MEDAQLIB_API ERR_CODE WINAPI SetIntExecSCmd    (uint32_t instanceHandle, const char *sensorCommand, const char *paramName, int32_t     paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetDoubleExecSCmd (uint32_t instanceHandle, const char *sensorCommand, const char *paramName, double      paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetStringExecSCmd (uint32_t instanceHandle, const char *sensorCommand, const char *paramName, const char *paramValue);
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdGetInt    (uint32_t instanceHandle, const char *sensorCommand, const char *paramName, int32_t *   paramValue);
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdGetDouble (uint32_t instanceHandle, const char *sensorCommand, const char *paramName, double *    paramValue);
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdGetString (uint32_t instanceHandle, const char *sensorCommand, const char *paramName, char *      paramValue, uint32_t *maxLen);
#if defined(_WIN32)
	// Unicode version
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdU          (uint32_t instanceHandle, const wchar_t *sensorCommand);
	MEDAQLIB_API ERR_CODE WINAPI SetIntExecSCmdU    (uint32_t instanceHandle, const wchar_t *sensorCommand, const wchar_t *paramName, int32_t        paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetDoubleExecSCmdU (uint32_t instanceHandle, const wchar_t *sensorCommand, const wchar_t *paramName, double         paramValue);
	MEDAQLIB_API ERR_CODE WINAPI SetStringExecSCmdU (uint32_t instanceHandle, const wchar_t *sensorCommand, const wchar_t *paramName, const wchar_t *paramValue);
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdGetIntU    (uint32_t instanceHandle, const wchar_t *sensorCommand, const wchar_t *paramName, int32_t *      paramValue);
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdGetDoubleU (uint32_t instanceHandle, const wchar_t *sensorCommand, const wchar_t *paramName, double *       paramValue);
	MEDAQLIB_API ERR_CODE WINAPI ExecSCmdGetStringU (uint32_t instanceHandle, const wchar_t *sensorCommand, const wchar_t *paramName, wchar_t *      paramValue, uint32_t *maxLen);
#endif // _WIN32

#if defined(__cplusplus)
	}
#endif // __cplusplus
