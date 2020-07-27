////////////////////////////////////////////////////////////////////////////////////////////////////
/// \file
///
/// \brief  Declares the scan control data types class.
////////////////////////////////////////////////////////////////////////////////////////////////////
//_______________________________________________________________________
// Data types, Defines for ScanControl
//
// $Source$
// $Id$
//
// Sven Ackermann
// (c) 2008 MICRO-EPSILON Optronic GmbH
//_________________________________________________________________________
//

#ifndef _SCANCONTROLDATATYPES_H_
#define _SCANCONTROLDATATYPES_H_

const unsigned int GIGE_SERIALNUMBER_SIZE = 16U;

// message values
#define ERROR_OK 0
#define ERROR_SERIAL_COMM 1
#define ERROR_SERIAL_LLT 7
#define ERROR_CONNECTIONLOST 10
#define ERROR_STOPSAVING 100

// specify the type for the RS422-multiplexer
#define RS422_INTERFACE_FUNCTION_AUTO 0
#define RS422_INTERFACE_FUNCTION_SERIALPORT_115200 1
#define RS422_INTERFACE_FUNCTION_TRIGGER 2
#define RS422_INTERFACE_FUNCTION_CMM_TRIGGER 3
#define RS422_INTERFACE_FUNCTION_ENCODER 4
#define RS422_INTERFACE_FUNCTION_DIGITAL_OUTPUT 6
#define RS422_INTERFACE_FUNCTION_TRIGGER_LASER_PULSE 7
#define RS422_INTERFACE_FUNCTION_SERIALPORT_57600 8
#define RS422_INTERFACE_FUNCTION_SERIALPORT_38400 9
#define RS422_INTERFACE_FUNCTION_SERIALPORT_19200 10
#define RS422_INTERFACE_FUNCTION_SERIALPORT_9600 11

// return values for the is-functions
#define IS_FUNC_NO 0
#define IS_FUNC_YES 1

// general return values for all functions
#define GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED 4
#define GENERAL_FUNCTION_PACKET_SIZE_CHANGED 3
#define GENERAL_FUNCTION_CONTAINER_MODE_HEIGHT_CHANGED 2
#define GENERAL_FUNCTION_OK 1
#define GENERAL_FUNCTION_NOT_AVAILABLE 0

#define ERROR_GENERAL_WHILE_LOAD_PROFILE -1000
#define ERROR_GENERAL_NOT_CONNECTED -1001
#define ERROR_GENERAL_DEVICE_BUSY -1002
#define ERROR_GENERAL_WHILE_LOAD_PROFILE_OR_GET_PROFILES -1003
#define ERROR_GENERAL_WHILE_GET_PROFILES -1004
#define ERROR_GENERAL_GET_SET_ADDRESS -1005
#define ERROR_GENERAL_POINTER_MISSING -1006
#define ERROR_GENERAL_WHILE_SAVE_PROFILES -1007
#define ERROR_GENERAL_SECOND_CONNECTION_TO_LLT -1008

// return values for GetDeviceName
#define ERROR_GETDEVICENAME_SIZE_TOO_LOW -1
#define ERROR_GETDEVICENAME_NO_BUFFER -2

// return values for Load/SaveProfiles
#define ERROR_LOADSAVE_WRITING_LAST_BUFFER -50
#define ERROR_LOADSAVE_WHILE_SAVE_PROFILE -51
#define ERROR_LOADSAVE_NO_PROFILELENGTH_POINTER -52
#define ERROR_LOADSAVE_NO_LOAD_PROFILE -53
#define ERROR_LOADSAVE_STOP_ALREADY_LOAD -54
#define ERROR_LOADSAVE_CANT_OPEN_FILE -55
#define ERROR_LOADSAVE_INVALID_FILE_HEADER -56
#define ERROR_LOADSAVE_FILE_POSITION_TOO_HIGH -57
#define ERROR_LOADSAVE_AVI_NOT_SUPPORTED -58
#define ERROR_LOADSAVE_NO_REARRANGEMENT_POINTER -59
#define ERROR_LOADSAVE_WRONG_PROFILE_CONFIG -60
#define ERROR_LOADSAVE_NOT_TRANSFERING -61

// return values for profile transfer functions
#define ERROR_PROFTRANS_SHOTS_NOT_ACTIVE -100
#define ERROR_PROFTRANS_SHOTS_COUNT_TOO_HIGH -101
#define ERROR_PROFTRANS_WRONG_PROFILE_CONFIG -102
#define ERROR_PROFTRANS_FILE_EOF -103
#define ERROR_PROFTRANS_NO_NEW_PROFILE -104
#define ERROR_PROFTRANS_BUFFER_SIZE_TOO_LOW -105
#define ERROR_PROFTRANS_NO_PROFILE_TRANSFER -106
#define ERROR_PROFTRANS_PACKET_SIZE_TOO_HIGH -107
#define ERROR_PROFTRANS_CREATE_BUFFERS -108
#define ERROR_PROFTRANS_WRONG_PACKET_SIZE_FOR_CONTAINER -109
#define ERROR_PROFTRANS_REFLECTION_NUMBER_TOO_HIGH -110
#define ERROR_PROFTRANS_MULTIPLE_SHOTS_ACTIV -111
#define ERROR_PROFTRANS_BUFFER_HANDOUT -112
#define ERROR_PROFTRANS_WRONG_BUFFER_POINTER -113
#define ERROR_PROFTRANS_WRONG_TRANSFER_CONFIG -114

// return values for Set/GetFunctions
#define ERROR_SETGETFUNCTIONS_WRONG_BUFFER_COUNT -150
#define ERROR_SETGETFUNCTIONS_PACKET_SIZE -151
#define ERROR_SETGETFUNCTIONS_WRONG_PROFILE_CONFIG -152
#define ERROR_SETGETFUNCTIONS_NOT_SUPPORTED_RESOLUTION -153
#define ERROR_SETGETFUNCTIONS_REFLECTION_NUMBER_TOO_HIGH -154
#define ERROR_SETGETFUNCTIONS_WRONG_FEATURE_ADRESS -155
#define ERROR_SETGETFUNCTIONS_SIZE_TOO_LOW -156
#define ERROR_SETGETFUNCTIONS_WRONG_PROFILE_SIZE -157
#define ERROR_SETGETFUNCTIONS_MOD_4 -158
#define ERROR_SETGETFUNCTIONS_REARRANGEMENT_PROFILE -159
#define ERROR_SETGETFUNCTIONS_USER_MODE_TOO_HIGH -160
#define ERROR_SETGETFUNCTIONS_USER_MODE_FACTORY_DEFAULT -161
#define ERROR_SETGETFUNCTIONS_HEARTBEAT_TOO_HIGH -162

// return values PostProcessingParameter
#define ERROR_POSTPROCESSING_NO_PROF_BUFFER -200
#define ERROR_POSTPROCESSING_MOD_4 -201
#define ERROR_POSTPROCESSING_NO_RESULT -202
#define ERROR_POSTPROCESSING_LOW_BUFFERSIZE -203
#define ERROR_POSTPROCESSING_WRONG_RESULT_SIZE -204

// return values for GetDeviceInterfaces
#define ERROR_GETDEVINTERFACES_WIN_NOT_SUPPORTED -250
#define ERROR_GETDEVINTERFACES_REQUEST_COUNT -251
#define ERROR_GETDEVINTERFACES_CONNECTED -252
#define ERROR_GETDEVINTERFACES_INTERNAL -253

// return values for Connect
#define ERROR_CONNECT_LLT_COUNT -300
#define ERROR_CONNECT_SELECTED_LLT -301
#define ERROR_CONNECT_ALREADY_CONNECTED -302
#define ERROR_CONNECT_LLT_NUMBER_ALREADY_USED -303
#define ERROR_CONNECT_SERIAL_CONNECTION -304
#define ERROR_CONNECT_INVALID_IP -305

// return values for SetPartialProfile
#define ERROR_PARTPROFILE_NO_PART_PROF -350
#define ERROR_PARTPROFILE_TOO_MUCH_BYTES -351
#define ERROR_PARTPROFILE_TOO_MUCH_POINTS -352
#define ERROR_PARTPROFILE_NO_POINT_COUNT -353
#define ERROR_PARTPROFILE_NOT_MOD_UNITSIZE_POINT -354
#define ERROR_PARTPROFILE_NOT_MOD_UNITSIZE_DATA -355

// return values for Start/StopTransmissionAndCmmTrigger
#define ERROR_CMMTRIGGER_NO_DIVISOR -400
#define ERROR_CMMTRIGGER_TIMEOUT_AFTER_TRANSFERPROFILES -401
#define ERROR_CMMTRIGGER_TIMEOUT_AFTER_SETCMMTRIGGER -402

// return values for TranslateErrorValue
#define ERROR_TRANSERRORVALUE_WRONG_ERROR_VALUE -450
#define ERROR_TRANSERRORVALUE_BUFFER_SIZE_TOO_LOW -451

// read/write config functions
#define ERROR_READWRITECONFIG_CANT_CREATE_FILE -500
#define ERROR_READWRITECONFIG_CANT_OPEN_FILE -501
#define ERROR_READWRITECONFIG_QUEUE_TO_SMALL -502
#define ERROR_READWRITECONFIG_FILE_EMPTY -503
#define ERROR_READWRITECONFIG_UNKNOW_FILE -504

// function Defines for the Get/SetFeature function
#define FEATURE_FUNCTION_SERIAL_NUMBER 0xf0000410
#define FEATURE_FUNCTION_CALIBRATION_SCALE 0xf0a00000
#define FEATURE_FUNCTION_CALIBRATION_OFFSET 0xf0a00004
#define FEATURE_FUNCTION_PEAKFILTER_WIDTH 0xf0b02000
#define FEATURE_FUNCTION_PEAKFILTER_HEIGHT 0xf0b02004
#define FEATURE_FUNCTION_ROI1_DISTANCE 0xf0b02008
#define FEATURE_FUNCTION_ROI1_POSITION 0xf0b0200c
#define FEATURE_FUNCTION_ROI1_TRACKING_DIVISOR 0xf0b02010
#define FEATURE_FUNCTION_ROI1_TRACKING_FACTOR 0xf0b02014
#define FEATURE_FUNCTION_CALIBRATION_0 0xf0b02020
#define FEATURE_FUNCTION_CALIBRATION_1 0xf0b02024
#define FEATURE_FUNCTION_CALIBRATION_2 0xf0b02028
#define FEATURE_FUNCTION_CALIBRATION_3 0xf0b0202c
#define FEATURE_FUNCTION_CALIBRATION_4 0xf0b02030
#define FEATURE_FUNCTION_CALIBRATION_5 0xf0b02034
#define FEATURE_FUNCTION_CALIBRATION_6 0xf0b02038
#define FEATURE_FUNCTION_CALIBRATION_7 0xf0b0203c
#define FEATURE_FUNCTION_IMAGE_FEATURES 0xf0b02100
#define FEATURE_FUNCTION_ROI2_DISTANCE 0xf0b02104
#define FEATURE_FUNCTION_ROI2_POSITION 0xf0b02108
#define FEATURE_FUNCTION_RONI_DISTANCE 0xf0b0210c
#define FEATURE_FUNCTION_RONI_POSITION 0xf0b02110
#define FEATURE_FUNCTION_EA_REFERENCE_REGION_DISTANCE 0xf0b02114
#define FEATURE_FUNCTION_EA_REFERENCE_REGION_POSITION 0xf0b02118
#define FEATURE_FUNCTION_LASER 0xf0f00824
#define INQUIRY_FUNCTION_LASER 0xf0f00524
#define FEATURE_FUNCTION_ROI1_PRESET 0xf0f00880
#define INQUIRY_FUNCTION_ROI1_PRESET 0xf0f00580
#define FEATURE_FUNCTION_TRIGGER 0xf0f00830
#define INQUIRY_FUNCTION_TRIGGER 0xf0f00530
#define FEATURE_FUNCTION_EXPOSURE_AUTOMATIC_LIMITS 0xf0f00834
#define INQUIRY_FUNCTION_EXPOSURE_AUTOMATIC_LIMITS 0xf0f00534
#define FEATURE_FUNCTION_EXPOSURE_TIME 0xf0f0081c
#define INQUIRY_FUNCTION_EXPOSURE_TIME 0xf0f0051c
#define FEATURE_FUNCTION_IDLE_TIME 0xf0f00800
#define INQUIRY_FUNCTION_IDLE_TIME 0xf0f00500
#define FEATURE_FUNCTION_PROFILE_PROCESSING 0xf0f00804
#define INQUIRY_FUNCTION_PROFILE_PROCESSING 0xf0f00504
#define FEATURE_FUNCTION_THRESHOLD 0xf0f00810
#define INQUIRY_FUNCTION_THRESHOLD 0xf0f00510
#define FEATURE_FUNCTION_MAINTENANCE 0xf0f0088c
#define INQUIRY_FUNCTION_MAINTENANCE 0xf0f0058c
#define FEATURE_FUNCTION_CMM_TRIGGER 0xf0f00888
#define INQUIRY_FUNCTION_CMM_TRIGGER 0xf0f00588
#define FEATURE_FUNCTION_PROFILE_REARRANGEMENT 0xf0f0080c
#define INQUIRY_FUNCTION_PROFILE_REARRANGEMENT 0xf0f0050c
#define FEATURE_FUNCTION_PROFILE_FILTER 0xf0f00818
#define INQUIRY_FUNCTION_PROFILE_FILTER 0xf0f00518
#define FEATURE_FUNCTION_DIGITAL_IO 0xf0f008c0
#define INQUIRY_FUNCTION_DIGITAL_IO 0xf0f005c0
#define FEATURE_FUNCTION_TEMPERATURE 0xf0f0082c
#define INQUIRY_FUNCTION_TEMPERATURE 0xf0f0052c
#define FEATURE_FUNCTION_EXTRA_PARAMETER 0xf0f00808
#define INQUIRY_FUNCTION_EXTRA_PARAMETER 0xf0f00508

#define FEATURE_FUNCTION_PACKET_DELAY 0x00000d08
#define FEATURE_FUNCTION_CONNECTION_SPEED 0x00000670

// function Defines for the Get/SetFeature function (deprecated names)
#define FEATURE_FUNCTION_SERIAL 0xf0000410
#define FEATURE_FUNCTION_FREE_MEASURINGFIELD_Z 0xf0b02008
#define FEATURE_FUNCTION_FREE_MEASURINGFIELD_X 0xf0b0200c
#define FEATURE_FUNCTION_DYNAMIC_TRACK_DIVISOR 0xf0b02010
#define FEATURE_FUNCTION_DYNAMIC_TRACK_FACTOR 0xf0b02014
#define FEATURE_FUNCTION_LASERPOWER 0xf0f00824
#define INQUIRY_FUNCTION_LASERPOWER 0xf0f00524
#define FEATURE_FUNCTION_MEASURINGFIELD 0xf0f00880
#define INQUIRY_FUNCTION_MEASURINGFIELD 0xf0f00580
#define FEATURE_FUNCTION_SHUTTERTIME 0xf0f0081c
#define INQUIRY_FUNCTION_SHUTTERTIME 0xf0f0051c
#define FEATURE_FUNCTION_IDLETIME 0xf0f00800
#define INQUIRY_FUNCTION_IDLETIME 0xf0f00500
#define FEATURE_FUNCTION_PROCESSING_PROFILEDATA 0xf0f00804
#define INQUIRY_FUNCTION_PROCESSING_PROFILEDATA 0xf0f00504
#define FEATURE_FUNCTION_MAINTENANCEFUNCTIONS 0xf0f0088c
#define INQUIRY_FUNCTION_MAINTENANCEFUNCTIONS 0xf0f0058c
#define FEATURE_FUNCTION_ANALOGFREQUENCY 0xf0f00828
#define INQUIRY_FUNCTION_ANALOGFREQUENCY 0xf0f00528
#define FEATURE_FUNCTION_ANALOGOUTPUTMODES 0xf0f00820
#define INQUIRY_FUNCTION_ANALOGOUTPUTMODES 0xf0f00520
#define FEATURE_FUNCTION_CMMTRIGGER 0xf0f00888
#define INQUIRY_FUNCTION_CMMTRIGGER 0xf0f00588
#define FEATURE_FUNCTION_REARRANGEMENT_PROFILE 0xf0f0080c
#define INQUIRY_FUNCTION_REARRANGEMENT_PROFILE 0xf0f0050c
#define FEATURE_FUNCTION_RS422_INTERFACE_FUNCTION 0xf0f008c0
#define INQUIRY_FUNCTION_RS422_INTERFACE_FUNCTION 0xf0f005c0
#define FEATURE_FUNCTION_SATURATION 0xf0f00814
#define INQUIRY_FUNCTION_SATURATION 0xf0f00514
#define FEATURE_FUNCTION_CAPTURE_QUALITY 0xf0f008c4
#define INQUIRY_FUNCTION_CAPTURE_QUALITY 0xf0f005c4
#define FEATURE_FUNCTION_SHARPNESS 0xf0f00808
#define INQUIRY_FUNCTION_SHARPNESS 0xf0f00508

// Defines for the return values of the ConvertProfile2Values and
// ConvertPartProfile2Values functions
#define CONVERT_WIDTH 0x00000100
#define CONVERT_MAXIMUM 0x00000200
#define CONVERT_THRESHOLD 0x00000400
#define CONVERT_X 0x00000800
#define CONVERT_Z 0x00001000
#define CONVERT_M0 0x00002000
#define CONVERT_M1 0x00004000

// Processing flags
#define PROC_HIGH_RESOLUTION 1
#define PROC_CALIBRATION (1 << 1)
#define PROC_MULTIREFL_ALL (0 << 2)
#define PROC_MULITREFL_FIRST (1 << 2)
#define PROC_MULITREFL_LAST (2 << 2)
#define PROC_MULITREFL_LARGESTAREA (3 << 2)
#define PROC_MULITREFL_MAXINTENS (4 << 2)
#define PROC_MULITREFL_SINGLE (5 << 2)
#define PROC_POSTPROCESSING_ON (1 << 5)
#define PROC_FLIP_DISTANCE (1 << 6)
#define PROC_FLIP_POSITION (1 << 7)
#define PROC_AUTOSHUTTER_DELAY (1 << 8)
#define PROC_SHUTTERALIGN_CENTER (0 << 9)
#define PROC_SHUTTERALIGN_RIGHT (1 << 9)
#define PROC_SHUTTERALIGN_LEFT (2 << 9)
#define PROC_SHUTTERALIGN_OFF (3 << 9)
#define PROC_AUTOSHUTTER_ADVANCED (1 << 11)

// Threshold flags
#define THRESHOLD_AUTOMATIC (1 << 24)
#define THRESHOLD_VIDEO_FILTER (1 << 11)
#define THRESHOLD_AMBIENT_LIGHT_SUPPRESSION (1 << 10)
// Threshold flags (deprecated names)
#define THRESHOLD_DYNAMIC (1 << 24)
#define THRESHOLD_BACKGROUND_FILTER (1 << 10)

// Exposure flags
#define EXPOSURE_AUTOMATIC (1 << 24)
// Shutter flags (deprecated names)
#define SHUTTER_AUTOMATIC (1 << 24)

// Laser Power flags
#define LASER_OFF 0
#define LASER_REDUCED_POWER 1
#define LASER_FULL_POWER 2
#define LASER_PULSE_MODE (1 << 11)

// Temperature register
#define TEMP_PREPARE_VALUE 0x86000000

// Trigger flags
#define TRIG_MODE_EDGE (0 << 16)
#define TRIG_MODE_PULSE (1 << 16)
#define TRIG_MODE_GATE (2 << 16)
#define TRIG_MODE_ENCODER (3 << 16)
#define TRIG_INPUT_RS422 (0 << 21)
#define TRIG_INPUT_DIGIN (1 << 21)
#define TRIG_POLARITY_LOW (0 << 24)
#define TRIG_POLARITY_HIGH (1 << 24)
#define TRIG_EXT_ACTIVE (1 << 25)
#define TRIG_INTERNAL (0 << 25)

// Region Of Interest 1 flags
#define ROI1_FREE_REGION (1 << 11)
// Measuring Field flags (deprecated names)
#define MEASFIELD_ACTIVATE_FREE (1 << 11)

// Image Features flags
#define ROI2_ENABLE (1 << 0)
#define RONI_ENABLE (1 << 1)
#define EA_REF_REGION_ENABLE (1 << 2)
#define HIGH_SPEED_MODE_ENABLE (1 << 30)
#define HDR_ENABLE (1 << 31)

// Maintenance flags
#define MAINTENANCE_COMPRESS_DATA 1
#define MAINTENANCE_LOOPBACK (1 << 1)
#define MAINTENANCE_ENCODER_ACTIVE (1 << 3)
#define MAINTENANCE_SUPPRESS_REGISTER_RESET (1 << 5)
#define MAINTENANCE_UM_LOAD_VIA_DIGIN (0 << 6)
#define MAINTENANCE_UM_SUPPRESS_UNTIL_REBOOT (1 << 6)
#define MAINTENANCE_UM_SUPPRESS_UNTIL_GVCP_CLOSE (2 << 6)
#define MAINTENANCE_UM_SUPPRESS_UNTIL_REBOOT_GVCP_CLOSE (3 << 6)

// Multiport flags (DigitalIO)
#define MULTI_LEVEL_5V (0 << 11)
#define MULTI_LEVEL_24V (1 << 11)
#define MULTI_RS422_TERM_ON (0 << 10)
#define MULTI_RS422_TERM_OFF (1 << 10)
#define MULTI_ENCODER_BIDIRECT (0 << 9)
#define MULTI_ENCODER_UNIDIRECT (1 << 9)
#define MULTI_INPUT_PULLUP (0 << 8)
#define MULTI_INPUT_PULLDOWN (1 << 8)
#define MULTI_DIGIN_ENC_INDEX (0 << 4)
#define MULTI_DIGIN_ENC_TRIG (1 << 4)
#define MULTI_DIGIN_TRIG_ONLY (2 << 4)
#define MULTI_DIGIN_TRIG_UM (3 << 4)
#define MULTI_DIGIN_UM (4 << 4)
#define MULTI_DIGIN_TS (5 << 4)
#define MULTI_DIGIN_FRAMETRIG_BI (6 << 4)
#define MULTI_DIGIN_FRAMETRIG_UNI (7 << 4)
#define MULTI_DIGIN_GATED_ENCODER (8 << 4)
#define MULTI_DIGIN_TRIG_UM2_TS1 (9 << 4)
#define MULTI_DIGIN_UM3_TS1 (10 << 4)
#define MULTI_DIGIN_UM2_TS2 (11 << 4)
#define MULTI_RS422_115200 0
#define MULTI_RS422_57600 1
#define MULTI_RS422_38400 2
#define MULTI_RS422_19200 3
#define MULTI_RS422_9600 4
#define MULTI_RS422_TRIG_IN 5
#define MULTI_RS422_TRIG_OUT 6
#define MULTI_RS422_CMM 7

// Profile Filter flags
#define FILTER_RESAMPLE_EXTRAPOLATE_POINTS (1 << 11)
#define FILTER_RESAMPLE_ALL_INFO (1 << 10)
#define FILTER_RESAMPLE_DISABLED (0 << 4)
#define FILTER_RESAMPLE_TINY (1 << 4)
#define FILTER_RESAMPLE_VERYSMALL (2 << 4)
#define FILTER_RESAMPLE_SMALL (3 << 4)
#define FILTER_RESAMPLE_MEDIUM (4 << 4)
#define FILTER_RESAMPLE_LARGE (5 << 4)
#define FILTER_RESAMPLE_VERYLARGE (6 << 4)
#define FILTER_RESAMPLE_HUGE (7 << 4)
#define FILTER_MEDIAN_DISABLED (0 << 2)
#define FILTER_MEDIAN_3 (1 << 2)
#define FILTER_MEDIAN_5 (2 << 2)
#define FILTER_MEDIAN_7 (3 << 2)
#define FILTER_AVG_DISABLED 0
#define FILTER_AVG_3 1
#define FILTER_AVG_5 2
#define FILTER_AVG_7 3

// Container flags
#define CONTAINER_STRIPE_4 (1 << 23)
#define CONTAINER_STRIPE_3 (1 << 22)
#define CONTAINER_STRIPE_2 (1 << 21)
#define CONTAINER_STRIPE_1 (1 << 20)
#define CONTAINER_JOIN (1 << 19)
#define CONTAINER_DATA_SIGNED (1 << 18)
#define CONTAINER_DATA_LSBF (1 << 17)
#define CONTAINER_DATA_TS (1 << 11)
#define CONTAINER_DATA_EMPTYFIELD4TS (1 << 10)
#define CONTAINER_DATA_LOOPBACK (1 << 9)
#define CONTAINER_DATA_MOM1U (1 << 8)
#define CONTAINER_DATA_MOM1L (1 << 7)
#define CONTAINER_DATA_MOM0U (1 << 6)
#define CONTAINER_DATA_MOM0L (1 << 5)
#define CONTAINER_DATA_WIDTH (1 << 4)
#define CONTAINER_DATA_INTENS (1 << 3)
#define CONTAINER_DATA_THRES (1 << 2)
#define CONTAINER_DATA_X (1 << 1)
#define CONTAINER_DATA_Z (1 << 0)
typedef void(_stdcall* TNewProfile)(const unsigned char* pData, unsigned int nSize);
typedef void(_stdcall* TNewProfile_s)(const unsigned char* pData, unsigned int nSize,
                                      void* pUserData);
typedef void(_cdecl* TNewProfile_c)(const unsigned char* pData, unsigned int nSize,
                                    void* pUserData);

// specify the type of the scanner
// if your programming language does not support enums, you can use a signed int
typedef enum TScannerType
{
  StandardType = -1, // can't decode scanCONTROL name, use standard measurement range
  LLT25 = 0,         // scanCONTROL28xx with 25mm measurement range
  LLT100 = 1,        // scanCONTROL28xx with 100mm measurement range

  scanCONTROL28xx_25 = 0,    // scanCONTROL28xx with 25mm measurement range
  scanCONTROL28xx_100 = 1,   // scanCONTROL28xx with 100mm measurement range
  scanCONTROL28xx_10 = 2,    // scanCONTROL28xx with 10mm measurement range
  scanCONTROL28xx_xxx = 999, // scanCONTROL28xx with no measurement range

  scanCONTROL27xx_25 = 1000,  // scanCONTROL27xx with 25mm measurement range
  scanCONTROL27xx_100 = 1001, // scanCONTROL27xx with 100mm measurement range
  scanCONTROL27xx_50 = 1002,  // scanCONTROL27xx with 50mm measurement range
  scanCONTROL2751_25 = 1020,  // scanCONTROL27xx with 25mm measurement range
  scanCONTROL2751_100 = 1021, // scanCONTROL27xx with 100mm measurement range
  scanCONTROL2702_50 = 1032,  // scanCONTROL2702 with 50mm measurement range
  scanCONTROL27xx_xxx = 1999, // scanCONTROL27xx with no measurement range

  scanCONTROL26xx_25 = 2000,  // scanCONTROL26xx with 25mm measurement range
  scanCONTROL26xx_100 = 2001, // scanCONTROL26xx with 100mm measurement range
  scanCONTROL26xx_50 = 2002,  // scanCONTROL26xx with 50mm measurement range
  scanCONTROL26xx_10 = 2003,  // scanCONTROL26xx with 10mm measurement range
  scanCONTROL26xx_xxx = 2999, // scanCONTROL26xx with no measurement range

  scanCONTROL29xx_25 = 3000,  // scanCONTROL29xx with 25mm measurement range
  scanCONTROL29xx_100 = 3001, // scanCONTROL29xx with 100mm measurement range
  scanCONTROL29xx_50 = 3002,  // scanCONTROL29xx with 50mm measurement range
  scanCONTROL29xx_10 = 3003,  // scanCONTROL29xx with 10mm measurement range
  scanCONTROL2905_50 = 3010,  // scanCONTROL2905 with 50mm measurement range
  scanCONTROL2905_100 = 3011, // scanCONTROL2905 with 100mm measurement range
  scanCONTROL2953_30 = 3033,  // scanCONTROL2953 with 30mm measurement range
  scanCONTROL2954_10 = 3034,  // scanCONTROL2954 with 10mm measurement range
  scanCONTROL2954_25 = 3035,  // scanCONTROL2954 with 25mm measurement range
  scanCONTROL2954_50 = 3036,  // scanCONTROL2954 with 50mm measurement range
  scanCONTROL2954_100 = 3037, // scanCONTROL2954 with 100mm measurement range
  scanCONTROL2954_xxx = 3038, // scanCONTROL2954 with 30mm measurement range
  scanCONTROL2968_10 = 3040,  // scanCONTROL2968 with 10mm measurement range
  scanCONTROL2968_25 = 3041,  // scanCONTROL2968 with 25mm measurement range
  scanCONTROL2968_50 = 3042,  // scanCONTROL2968 with 50mm measurement range
  scanCONTROL2968_100 = 3043, // scanCONTROL2968 with 100mm measurement range
  scanCONTROL2968_xxx = 3044, // scanCONTROL2968 with unknown measurement range
  scanCONTROL29xx_xxx = 3999, // scanCONTROL29xx with no measurement range

  scanCONTROL30xx_25 = 4000,  // scanCONTROL30xx with 25mm measurement range
  scanCONTROL30xx_50 = 4001,  // scanCONTROL30xx with 50mm measurement range
  scanCONTROL30xx_200 = 4002, // scanCONTROL30xx with 200mm measurement range
  scanCONTROL30xx_xxx = 4999, // scanCONTROL30xx with no measurement range

  scanCONTROL25xx_25 = 5000,           // scanCONTROL25xx with 25mm measurement range
  scanCONTROL25xx_100 = 5001,           // scanCONTROL25xx with 100mm measurement range
  scanCONTROL25xx_50 = 5002,           // scanCONTROL25xx with 50mm measurement range
  scanCONTROL25xx_10 = 5003,           // scanCONTROL25xx with 10mm measurement range
  scanCONTROL25xx_xxx = 5999,          // scanCONTROL25xx with no measurement range

  scanCONTROL2xxx = 6000,     // dummy
} TScannerType;

// specify the profile configuration
// if your programming language does not support enums, you can use a signed int
typedef enum TProfileConfig
{
  NONE = 0,
  PROFILE = 1,
  CONTAINER = 1,
  VIDEO_IMAGE = 1,
  PURE_PROFILE = 2,
  QUARTER_PROFILE = 3,
  CSV_PROFILE = 4,
  PARTIAL_PROFILE = 5,
} TProfileConfig;

// specify the callback type
// if you programming language does not support enums, you can use a signed int
typedef enum TCallbackType
{
  STD_CALL = 0,
  C_DECL = 1,
} TCallbackType;

// specify the file type for saving
// if you programming language does not support enums, you can use a signed int
typedef enum TFileType
{
  AVI = 0,
  LLT = 1,
  CSV = 2,
  BMP = 3,
  CSV_NEG = 4,
} TFileType;

// structure for the partial profile parameters
typedef struct TPartialProfile
{
  unsigned int nStartPoint;
  unsigned int nStartPointData;
  unsigned int nPointCount;
  unsigned int nPointDataWidth;
} TPartialProfile;

typedef struct TConvertProfileParameter
{
  unsigned short* Width;
  unsigned short* pMaximum;
  unsigned short* pThreshold;
  double* pX;
  double* pZ;
  unsigned int* pM0;
  unsigned int* pM1;
} TConvertProfileParameter;

typedef enum TTransferProfileType
{
  NORMAL_TRANSFER = 0,
  SHOT_TRANSFER = 1,
  NORMAL_CONTAINER_MODE = 2,
  SHOT_CONTAINER_MODE = 3,
  NONE_TRANSFER = 4,
} TTransferProfileType;

typedef enum TTransferVideoType
{
  VIDEO_MODE_0 = 0,
  VIDEO_MODE_1 = 1,
  NONE_VIDEOMODE = 2,
} TTransferVideoType;

typedef enum TInterfaceType
{
  INTF_TYPE_UNKNOWN = 0,
  INTF_TYPE_SERIAL = 1,
  INTF_TYPE_FIREWIRE = 2,
  INTF_TYPE_ETHERNET = 3
} TInterfaceType;

#endif // _SCANCONTROLDATATYPES_H_
