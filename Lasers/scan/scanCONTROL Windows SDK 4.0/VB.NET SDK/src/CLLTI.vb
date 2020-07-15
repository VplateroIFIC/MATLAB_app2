Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Runtime.InteropServices
Imports System.Text

Namespace VB

    Public Class CLLTI

        'Sample interface class with all needed functions for the example
        'Note not all functions of the LLT.dll are in this interface.
        'Please add the needed functions.

#Region "Constant declarations"

        Public Const DRIVER_DLL_NAME As String = "..//LLT.dll"
        Public Const CSHARP_DLL_NAME As String = "..//CSharpWrap.dll"

        Public Const CONVERT_X As UInteger = &H800UI
        Public Const CONVERT_Z As UInteger = &H1000UI
        Public Const CONVERT_WIDTH As UInteger = &H100UI

        Public Const CONVERT_MAXIMUM As UInteger = &H200
        Public Const CONVERT_THRESHOLD As UInteger = &H400UI
        Public Const CONVERT_M0 As UInteger = &H2000UI
        Public Const CONVERT_M1 As UInteger = &H4000UI

        ' specify the type for the RS422-multiplexer (27xx)
        Public Const RS422_INTERFACE_FUNCTION_AUTO_27xx As Integer = 0
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_115200_27xx As Integer = 1
        Public Const RS422_INTERFACE_FUNCTION_TRIGGER_27x As Integer = 2
        Public Const RS422_INTERFACE_FUNCTION_CMM_TRIGGER_27xx As Integer = 3
        Public Const RS422_INTERFACE_FUNCTION_ENCODER_27xx As Integer = 4
        Public Const RS422_INTERFACE_FUNCTION_DIGITAL_OUTPUT_27xx As Integer = 6
        Public Const RS422_INTERFACE_FUNCTION_TRIGGER_LASER_PULSE_27xx As Integer = 7
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_57600_27xx As Integer = 8
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_38400_27xx As Integer = 9
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_19200_27xx As Integer = 10
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_9600_27xx As Integer = 11

        ' specify the type for the RS422-multiplexer (26xx/29xx)
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_115200 As Integer = 0
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_57600 As Integer = 1
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_38400 As Integer = 2
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_19200 As Integer = 3
        Public Const RS422_INTERFACE_FUNCTION_SERIALPORT_9600 As Integer = 4
        Public Const RS422_INTERFACE_FUNCTION_TRIGGER_INPUT As Integer = 5
        Public Const RS422_INTERFACE_FUNCTION_TRIGGER_OUTPUT As Integer = 6
        Public Const RS422_INTERFACE_FUNCTION_CMM_TRIGGER As Integer = 7

        ' Processing flags
        Public Const PROC_HIGH_RESOLUTION As UInteger = 1
        Public Const PROC_CALIBRATION As UInteger = (1 << 1)
        Public Const PROC_MULTIREFL_ALL As UInteger = (0 << 2)
        Public Const PROC_MULITREFL_FIRST As UInteger = (1 << 2)
        Public Const PROC_MULITREFL_LAST As UInteger = (2 << 2)
        Public Const PROC_MULITREFL_LARGESTAREA As UInteger = (3 << 2)
        Public Const PROC_MULITREFL_MAXINTENS As UInteger = (4 << 2)
        Public Const PROC_MULITREFL_SINGLE As UInteger = (5 << 2)
        Public Const PROC_POSTPROCESSING_ON As UInteger = (1 << 5)
        Public Const PROC_FLIP_DISTANCE As UInteger = (1 << 6)
        Public Const PROC_FLIP_POSITION As UInteger = (1 << 7)
        Public Const PROC_AUTOSHUTTER_DELAY As UInteger = (1 << 8)
        Public Const PROC_SHUTTERALIGN_CENTRE As UInteger = (0 << 9)
        Public Const PROC_SHUTTERALIGN_RIGHT As UInteger = (1 << 9)
        Public Const PROC_SHUTTERALIGN_LEFT As UInteger = (2 << 9)
        Public Const PROC_SHUTTERALIGN_OFF As UInteger = (3 << 9)
        Public Const PROC_AUTOSHUTTER_ADVANCED As UInteger = (1 << 11)

        ' Threshold flags
        Public Const THRESHOLD_DYNAMIC As UInteger = (1 << 24)
        Public Const THRESHOLD_VIDEO_FILTER As UInteger = (1 << 11)
        Public Const THRESHOLD_BACKGROUND_FILTER As UInteger = (1 << 10)

        ' Shutter flags
        Public Const SHUTTER_AUTOMATIC As UInteger = (1 << 24)

        ' Laser power flags
        Public Const LASER_OFF As UInteger = 0
        Public Const LASER_REDUCED_POWER As UInteger = 1
        Public Const LASER_FULL_POWER As UInteger = 2
        Public Const LASER_PULSEMODE As UInteger = (1 << 11)

        ' Temperature register
        Public Const TEMP_PREPARE_VALUE As UInteger = &H86000000UI

        ' Trigger flags
        Public Const TRIG_MODE_EDGE As UInteger = (0 << 16)
        Public Const TRIG_MODE_PULSE As UInteger = (1 << 16)
        Public Const TRIG_MODE_GATE As UInteger = (2 << 16)
        Public Const TRIG_MODE_ENCODER As UInteger = (3 << 16)
        Public Const TRIG_INPUT_RS422 As UInteger = (0 << 21)
        Public Const TRIG_INPUT_DIGIN As UInteger = (1 << 21)
        Public Const TRIG_POLARITY_LOW As UInteger = (0 << 24)
        Public Const TRIG_POLARITY_HIGH As UInteger = (1 << 24)
        Public Const TRIG_EXT_ACTIVE As UInteger = (1 << 25)
        Public Const TRIG_INTERNAL As UInteger = (0 << 25)

        'region of Interest 1 flags
        Public Const RO1_FREE_REGION As UInteger = (1 << 11)

        ' Measuring field flags
        Public Const MEASFIELD_ACTIVATE_FREE As UInteger = (1 << 11)

        'Image Features flags
        Public Const ROI2_ENABLE As UInteger = (1 << 0)
        Public Const RONI_ENABLE As UInteger = (1 << 1)
        Public Const EA_REF_REGION_ENABLE As UInteger = (1 << 2)
        Public Const FAST_MODE_ENABLE As UInteger = (1 << 30)
        Public Const HDR_ENABLE As UInteger = 1UI << 31UI

        ' Maintenance flags
        Public Const MAINTENANCE_LOOPBACK As UInteger = (1 << 1)
        Public Const MAINTENANCE_ENCODER_ACTIVE As UInteger = (1 << 3)
        Public Const MAINTENANCE_SUPPRESS_REGISTER_RESET As UInteger = (1 << 5)
        Public Const MAINTENANCE_UM_LOAD_VIA_DIGIN As UInteger = (0 << 6)
        Public Const MAINTENANCE_UM_SUPPRESS_UNTIL_REBOOT As UInteger = (1 << 6)
        Public Const MAINTENANCE_UM_SUPPRESS_UNTIL_GVCP_CLOSE As UInteger = (2 << 6)
        Public Const MAINTENANCE_UM_SUPPRESS_UNTIL_REBOOT_GVCP_CLOSE As UInteger = (3 << 6)

        ' Multiport flags
        Public Const MULTI_LEVEL_5V As UInteger = (0 << 11)
        Public Const MULTI_LEVEL_24V As UInteger = (1 << 11)
        Public Const MULTI_RS422_TERM_ON As UInteger = (0 << 10)
        Public Const MULTI_RS422_TERM_OFF As UInteger = (1 << 10)
        Public Const MULTI_ENCODER_BIDIRECT As UInteger = (0 << 9)
        Public Const MULTI_ENCODER_UNIDIRECT As UInteger = (1 << 9)
        Public Const MULTI_DIGIN_ENC_INDEX As UInteger = (0 << 4)
        Public Const MULTI_DIGIN_ENC_TRIG As UInteger = (1 << 4)
        Public Const MULTI_DIGIN_TRIG_ONLY As UInteger = (2 << 4)
        Public Const MULTI_DIGIN_TRIG_UM As UInteger = (3 << 4)
        Public Const MULTI_DIGIN_UM As UInteger = (4 << 4)
        Public Const MULTI_DIGIN_TS As UInteger = (5 << 4)
        Public Const MULTI_DIGIN_FRAMETRIG_BI As UInteger = (6 << 4)
        Public Const MULTI_DIGIN_FRAMETRIG_UNI As UInteger = (7 << 4)
        Public Const MULTI_RS422_115200 As UInteger = 0
        Public Const MULTI_RS422_57600 As UInteger = 1
        Public Const MULTI_RS422_38400 As UInteger = 2
        Public Const MULTI_RS422_19200 As UInteger = 3
        Public Const MULTI_RS422_9600 As UInteger = 4
        Public Const MULTI_RS422_TRIG_IN As UInteger = 5
        Public Const MULTI_RS422_TRIG_OUT As UInteger = 6
        Public Const MULTI_RS422_CMM As UInteger = 7

        ' Profile filter flags
        Public Const FILTER_RESAMPLE_EXTRAPOLATE_POINTS As UInteger = (1 << 11)
        Public Const FILTER_RESAMPLE_ALL_INFO As UInteger = (1 << 10)
        Public Const FILTER_RESAMPLE_DISABLED As UInteger = (0 << 4)
        Public Const FILTER_RESAMPLE_TINY As UInteger = (1 << 4)
        Public Const FILTER_RESAMPLE_VERYSMALL As UInteger = (2 << 4)
        Public Const FILTER_RESAMPLE_SMALL As UInteger = (3 << 4)
        Public Const FILTER_RESAMPLE_MEDIUM As UInteger = (4 << 4)
        Public Const FILTER_RESAMPLE_LARGE As UInteger = (5 << 4)
        Public Const FILTER_RESAMPLE_VERYLARGE As UInteger = (6 << 4)
        Public Const FILTER_RESAMPLE_HUGE As UInteger = (7 << 4)
        Public Const FILTER_MEDIAN_DISABLED As UInteger = (0 << 2)
        Public Const FILTER_MEDIAN_3 As UInteger = (1 << 2)
        Public Const FILTER_MEDIAN_5 As UInteger = (2 << 2)
        Public Const FILTER_MEDIAN_7 As UInteger = (3 << 2)
        Public Const FILTER_AVG_DISABLED As UInteger = 0
        Public Const FILTER_AVG_3 As UInteger = 1
        Public Const FILTER_AVG_5 As UInteger = 2
        Public Const FILTER_AVG_7 As UInteger = 3

        ' Container flags
        Public Const CONTAINER_STRIPE_4 As UInteger = (1 << 23)
        Public Const CONTAINER_STRIPE_3 As UInteger = (1 << 22)
        Public Const CONTAINER_STRIPE_2 As UInteger = (1 << 21)
        Public Const CONTAINER_STRIPE_1 As UInteger = (1 << 20)
        Public Const CONTAINER_JOIN As UInteger = (1 << 19)
        Public Const CONTAINER_DATA_SIGNED As UInteger = (1 << 18)
        Public Const CONTAINER_DATA_LSBF As UInteger = (1 << 17)
        Public Const CONTAINER_DATA_TS As UInteger = (1 << 11)
        Public Const CONTAINER_DATA_EMPTYFIELD4TS As UInteger = (1 << 10)
        Public Const CONTAINER_DATA_LOOPBACK As UInteger = (1 << 9)
        Public Const CONTAINER_DATA_MOM0U As UInteger = (1 << 8)
        Public Const CONTAINER_DATA_MOM0L As UInteger = (1 << 7)
        Public Const CONTAINER_DATA_MOM1U As UInteger = (1 << 6)
        Public Const CONTAINER_DATA_MOM1L As UInteger = (1 << 5)
        Public Const CONTAINER_DATA_WIDTH As UInteger = (1 << 4)
        Public Const CONTAINER_DATA_INTENS As UInteger = (1 << 3)
        Public Const CONTAINER_DATA_THRES As UInteger = (1 << 2)
        Public Const CONTAINER_DATA_X As UInteger = (1 << 1)
        Public Const CONTAINER_DATA_Z As UInteger = (1 << 0)

#End Region

#Region "Return Values"

        ' Message-Values
        Public Const ERROR_OK As Integer = 0
        Public Const ERROR_SERIAL_COMM As Integer = 1
        Public Const ERROR_SERIAL_LLT As Integer = 7
        Public Const ERROR_CONNECTIONLOST As Integer = 10
        Public Const ERROR_STOPSAVING As Integer = 100

        ' Return-Values for the is-functions
        Public Const IS_FUNC_NO As Integer = 0
        Public Const IS_FUNC_YES As Integer = 1

        ' General return-values for all functions
        Public Const GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED As Integer = 4
        Public Const GENERAL_FUNCTION_PACKET_SIZE_CHANGED As Integer = 3
        Public Const GENERAL_FUNCTION_CONTAINER_MODE_HEIGHT_CHANGED As Integer = 2
        Public Const GENERAL_FUNCTION_OK As Integer = 1
        Public Const GENERAL_FUNCTION_NOT_AVAILABLE As Integer = 0

        Public Const ERROR_GENERAL_WHILE_LOAD_PROFILE As Integer = -1000
        Public Const ERROR_GENERAL_NOT_CONNECTED As Integer = -1001
        Public Const ERROR_GENERAL_DEVICE_BUSY As Integer = -1002
        Public Const ERROR_GENERAL_WHILE_LOAD_PROFILE_OR_GET_PROFILES As Integer = -1003
        Public Const ERROR_GENERAL_WHILE_GET_PROFILES As Integer = -1004
        Public Const ERROR_GENERAL_GET_SET_ADDRESS As Integer = -1005
        Public Const ERROR_GENERAL_POINTER_MISSING As Integer = -1006
        Public Const ERROR_GENERAL_WHILE_SAVE_PROFILES As Integer = -1007
        Public Const ERROR_GENERAL_SECOND_CONNECTION_TO_LLT As Integer = -1008

        ' Return-Values for GetDeviceName
        Public Const ERROR_GETDEVICENAME_SIZE_TOO_LOW As Integer = -1
        Public Const ERROR_GETDEVICENAME_NO_BUFFER As Integer = -2

        ' Return-Values for Load/SaveProfiles
        Public Const ERROR_LOADSAVE_WRITING_LAST_BUFFER As Integer = -50
        Public Const ERROR_LOADSAVE_WHILE_SAVE_PROFILE As Integer = -51
        Public Const ERROR_LOADSAVE_NO_PROFILELENGTH_POINTER As Integer = -52
        Public Const ERROR_LOADSAVE_NO_LOAD_PROFILE As Integer = -53
        Public Const ERROR_LOADSAVE_STOP_ALREADY_LOAD As Integer = -54
        Public Const ERROR_LOADSAVE_CANT_OPEN_FILE As Integer = -55
        Public Const ERROR_LOADSAVE_FILE_POSITION_TOO_HIGH As Integer = -57
        Public Const ERROR_LOADSAVE_AVI_NOT_SUPPORTED As Integer = -58
        Public Const ERROR_LOADSAVE_NO_REARRANGEMENT_POINTER As Integer = -59
        Public Const ERROR_LOADSAVE_WRONG_PROFILE_CONFIG As Integer = -60
        Public Const ERROR_LOADSAVE_NOT_TRANSFERING As Integer = -61

        ' Return-Values for profile transfer functions
        Public Const ERROR_PROFTRANS_SHOTS_NOT_ACTIVE As Integer = -100
        Public Const ERROR_PROFTRANS_SHOTS_COUNT_TOO_HIGH As Integer = -101
        Public Const ERROR_PROFTRANS_WRONG_PROFILE_CONFIG As Integer = -102
        Public Const ERROR_PROFTRANS_FILE_EOF As Integer = -103
        Public Const ERROR_PROFTRANS_NO_NEW_PROFILE As Integer = -104
        Public Const ERROR_PROFTRANS_BUFFER_SIZE_TOO_LOW As Integer = -105
        Public Const ERROR_PROFTRANS_NO_PROFILE_TRANSFER As Integer = -106
        Public Const ERROR_PROFTRANS_PACKET_SIZE_TOO_HIGH As Integer = -107
        Public Const ERROR_PROFTRANS_CREATE_BUFFERS As Integer = -108
        Public Const ERROR_PROFTRANS_WRONG_PACKET_SIZE_FOR_CONTAINER As Integer = -109
        Public Const ERROR_PROFTRANS_REFLECTION_NUMBER_TOO_HIGH As Integer = -110
        Public Const ERROR_PROFTRANS_MULTIPLE_SHOTS_ACTIVE As Integer = -111
        Public Const ERROR_PROFTRANS_BUFFER_HANDOUT As Integer = -112
        Public Const ERROR_PROFTRANS_WRONG_BUFFER_POINTER As Integer = -113
        Public Const ERROR_PROFTRANS_WRONG_TRANSFER_CONFIG As Integer = -114

        ' Return-Values for Set/GetFunctions
        Public Const ERROR_SETGETFUNCTIONS_WRONG_BUFFER_COUNT As Integer = -150
        Public Const ERROR_SETGETFUNCTIONS_PACKET_SIZE As Integer = -151
        Public Const ERROR_SETGETFUNCTIONS_WRONG_PROFILE_CONFIG As Integer = -152
        Public Const ERROR_SETGETFUNCTIONS_NOT_SUPPORTED_RESOLUTION As Integer = -153
        Public Const ERROR_SETGETFUNCTIONS_REFLECTION_NUMBER_TOO_HIGH As Integer = -154
        Public Const ERROR_SETGETFUNCTIONS_WRONG_FEATURE_ADRESS As Integer = -155
        Public Const ERROR_SETGETFUNCTIONS_SIZE_TOO_LOW As Integer = -156
        Public Const ERROR_SETGETFUNCTIONS_WRONG_PROFILE_SIZE As Integer = -157
        Public Const ERROR_SETGETFUNCTIONS_MOD_4 As Integer = -158
        Public Const ERROR_SETGETFUNCTIONS_REARRANGEMENT_PROFILE As Integer = -159
        Public Const ERROR_SETGETFUNCTIONS_USER_MODE_TOO_HIGH As Integer = -160
        Public Const ERROR_SETGETFUNCTIONS_USER_MODE_FACTORY_DEFAULT As Integer = -161
        Public Const ERROR_SETGETFUNCTIONS_HEARTBEAT_TOO_HIGH As Integer = -162


        ' Return-Values PostProcessingParameter
        Public Const ERROR_POSTPROCESSING_NO_PROF_BUFFER As Integer = -200
        Public Const ERROR_POSTPROCESSING_MOD_4 As Integer = -201
        Public Const ERROR_POSTPROCESSING_NO_RESULT As Integer = -202
        Public Const ERROR_POSTPROCESSING_LOW_BUFFERSIZE As Integer = -203
        Public Const ERROR_POSTPROCESSING_WRONG_RESULT_SIZE As Integer = -204

        ' Return-Values for GetDeviceInterfaces
        Public Const ERROR_GETDEVINTERFACES_WIN_NOT_SUPPORTED As Integer = -250
        Public Const ERROR_GETDEVINTERFACES_REQUEST_COUNT As Integer = -251
        Public Const ERROR_GETDEVINTERFACES_CONNECTED As Integer = -252
        Public Const ERROR_GETDEVINTERFACES_INTERNAL As Integer = -253

        ' Return-Values for Connect
        Public Const ERROR_CONNECT_LLT_COUNT As Integer = -300
        Public Const ERROR_CONNECT_SELECTED_LLT As Integer = -301
        Public Const ERROR_CONNECT_ALREADY_CONNECTED As Integer = -302
        Public Const ERROR_CONNECT_LLT_NUMBER_ALREADY_USED As Integer = -303
        Public Const ERROR_CONNECT_SERIAL_CONNECTION As Integer = -304
        Public Const ERROR_CONNECT_INVALID_IP As Integer = -305

        ' Return-Values for SetPartialProfile
        Public Const ERROR_PARTPROFILE_NO_PART_PROF As Integer = -350
        Public Const ERROR_PARTPROFILE_TOO_MUCH_BYTES As Integer = -351
        Public Const ERROR_PARTPROFILE_TOO_MUCH_POINTS As Integer = -352
        Public Const ERROR_PARTPROFILE_NO_POINT_COUNT As Integer = -353
        Public Const ERROR_PARTPROFILE_NOT_MOD_UNITSIZE_POINT As Integer = -354
        Public Const ERROR_PARTPROFILE_NOT_MOD_UNITSIZE_DATA As Integer = -355

        ' Return-Values for Start/StopTransmissionAndCmmTrigger
        Public Const ERROR_CMMTRIGGER_NO_DIVISOR As Integer = -400
        Public Const ERROR_CMMTRIGGER_TIMEOUT_AFTER_TRANSFERPROFILES As Integer = -401
        Public Const ERROR_CMMTRIGGER_TIMEOUT_AFTER_SETCMMTRIGGER As Integer = -402

        ' Return-Values for TranslateErrorValue
        Public Const ERROR_TRANSERRORVALUE_WRONG_ERROR_VALUE As Integer = -450
        Public Const ERROR_TRANSERRORVALUE_BUFFER_SIZE_TOO_LOW As Integer = -451

        ' Read/write config functions
        Public Const ERROR_READWRITECONFIG_CANT_CREATE_FILE As Integer = -500
        Public Const ERROR_READWRITECONFIG_CANT_OPEN_FILE As Integer = -501
        Public Const ERROR_READWRITECONFIG_QUEUE_TO_SMALL As Integer = -502

#End Region

#Region "Registers"
        ' Function defines for the Get/SetFeature function
        Public Const FEATURE_FUNCTION_SERIAL_NUMBER As UInteger = &HF0000410UI
        Public Const FEATURE_FUNCTION_CALIBRATION_SCALE As UInteger = &HF0A00000UI
        Public Const FEATURE_FUNCTION_CALIBRATION_OFFSET As UInteger = &HF0A00004UI
        Public Const FEATURE_FUNCTION_PEAKFILTER_WIDTH As UInteger = &HF0B02000UI
        Public Const FEATURE_FUNCTION_PEAKFILTER_HEIGHT As UInteger = &HF0B02004UI
        Public Const FEATURE_FUNCTION_ROI1_DISTANCE As UInteger = &HF0B02008UI
        Public Const FEATURE_FUNCTION_ROI1_POSITION As UInteger = &HF0B0200CUI
        Public Const FEATURE_FUNCTION_ROI1_TRACKING_DIVISOR As UInteger = &HF0B02010UI
        Public Const FEATURE_FUNCTION_ROI1_TRACKING_FACTOR As UInteger = &HF0B02014UI
        Public Const FEATURE_FUNCTION_CALIBRATION_0 As UInteger = &HF0B02020UI
        Public Const FEATURE_FUNCTION_CALIBRATION_1 As UInteger = &HF0B02024UI
        Public Const FEATURE_FUNCTION_CALIBRATION_2 As UInteger = &HF0B02028UI
        Public Const FEATURE_FUNCTION_CALIBRATION_3 As UInteger = &HF0B0202CUI
        Public Const FEATURE_FUNCTION_CALIBRATION_4 As UInteger = &HF0B02030UI
        Public Const FEATURE_FUNCTION_CALIBRATION_5 As UInteger = &HF0B02034UI
        Public Const FEATURE_FUNCTION_CALIBRATION_6 As UInteger = &HF0B02038UI
        Public Const FEATURE_FUNCTION_CALIBRATION_7 As UInteger = &HF0B0203CUI
        Public Const FEATURE_FUNCTION_IMAGE_FEATURES As UInteger = &HF0B02100UI
        Public Const FEATURE_FUNCTION_ROI2_DISTANCE As UInteger = &HF0B02104UI
        Public Const FEATURE_FUNCTION_ROI2_POSITION As UInteger = &HF0B02108UI
        Public Const FEATURE_FUNCTION_RONI_DISTANCE As UInteger = &HF0B0210CUI
        Public Const FEATURE_FUNCTION_RONI_POSITION As UInteger = &HF0B02110UI
        Public Const FEATURE_FUNCTION_EA_REFERENCE_REGION_DISTANCE As UInteger = &HF0B02114UI
        Public Const FEATURE_FUNCTION_EA_REFERENCE_REGION_POSITION As UInteger = &HF0B02118UI
        Public Const FEATURE_FUNCTION_LASER As UInteger = &HF0F00824UI
        Public Const INQUIRY_FUNCTION_LASER As UInteger = &HF0F00524UI
        Public Const FEATURE_FUNCTION_ROI1_PRESET As UInteger = &HF0F00880UI
        Public Const INQUIRY_FUNCTION_ROI1_PRESET As UInteger = &HF0F00580UI
        Public Const FEATURE_FUNCTION_TRIGGER As UInteger = &HF0F00830UI
        Public Const INQUIRY_FUNCTION_TRIGGER As UInteger = &HF0F00530UI
        Public Const FEATURE_FUNCTION_EXPOSURE_AUTOMATIC_LIMITS As UInteger = &HF0F00834UI
        Public Const INQUIRY_FUNCTION_EXPOSURE_AUTOMATIC_LIMITS As UInteger = &HF0F00534UI
        Public Const FEATURE_FUNCTION_EXPOSURE_TIME As UInteger = &HF0F0081CUI
        Public Const INQUIRY_FUNCTION_EXPOSURE_TIME As UInteger = &HF0F0051CUI
        Public Const FEATURE_FUNCTION_IDLE_TIME As UInteger = &HF0F00800UI
        Public Const INQUIRY_FUNCTION_IDLE_TIME As UInteger = &HF0F00500UI
        Public Const FEATURE_FUNCTION_PROFILE_PROCESSING As UInteger = &HF0F00804UI
        Public Const INQUIRY_FUNCTION_PROFILE_PROCESSING As UInteger = &HF0F00504UI
        Public Const FEATURE_FUNCTION_THRESHOLD As UInteger = &HF0F00810UI
        Public Const INQUIRY_FUNCTION_THRESHOLD As UInteger = &HF0F00510UI
        Public Const FEATURE_FUNCTION_MAINTENANCE As UInteger = &HF0F0088CUI
        Public Const INQUIRY_FUNCTION_MAINTENANCE As UInteger = &HF0F0058CUI
        Public Const FEATURE_FUNCTION_CMM_TRIGGER As UInteger = &HF0F00888UI
        Public Const INQUIRY_FUNCTION_CMM_TRIGGER As UInteger = &HF0F00588UI
        Public Const FEATURE_FUNCTION_PROFILE_REARRANGEMENT As UInteger = &HF0F0080CUI
        Public Const INQUIRY_FUNCTION_PROFILE_REARRANGEMENT As UInteger = &HF0F0050CUI
        Public Const FEATURE_FUNCTION_PROFILE_FILTER As UInteger = &HF0F00818UI
        Public Const INQUIRY_FUNCTION_PROFILE_FILTER As UInteger = &HF0F00518UI
        Public Const FEATURE_FUNCTION_DIGITAL_IO As UInteger = &HF0F008C0UI
        Public Const INQUIRY_FUNCTION_DIGITAL_IO As UInteger = &HF0F005C0UI
        Public Const FEATURE_FUNCTION_TEMPERATURE As UInteger = &HF0F0082CUI
        Public Const INQUIRY_FUNCTION_TEMPERATURE As UInteger = &HF0F0052CUI
        Public Const FEATURE_FUNCTION_EXTRA_PARAMETER As UInteger = &HF0F00808UI
        Public Const INQUIRY_FUNCTION_EXTRA_PARAMETER As UInteger = &HF0F00508UI

        Public Const FEATURE_FUNCTION_PACKET_DELAY As UInteger = &HD08UI
        Public Const FEATURE_FUNCTION_CONNECTION_SPEED As UInteger = &H670UI



        ' Function defines for the Get/SetFeature function (deprecated names)
        Public Const FEATURE_FUNCTION_SERIAL As UInteger = &HF0000410UI
        Public Const FEATURE_FUNCTION_LASERPOWER As UInteger = &HF0F00824UI
        Public Const INQUIRY_FUNCTION_LASERPOWER As UInteger = &HF0F00524UI
        Public Const FEATURE_FUNCTION_MEASURINGFIELD As UInteger = &HF0F00880UI
        Public Const INQUIRY_FUNCTION_MEASURINGFIELD As UInteger = &HF0F00580UI
        Public Const FEATURE_FUNCTION_SHUTTERTIME As UInteger = &HF0F0081CUI
        Public Const INQUIRY_FUNCTION_SHUTTERTIME As UInteger = &HF0F0051CUI
        Public Const FEATURE_FUNCTION_IDLETIME As UInteger = &HF0F00800UI
        Public Const INQUIRY_FUNCTION_IDLETIME As UInteger = &HF0F00500UI
        Public Const FEATURE_FUNCTION_PROCESSING_PROFILEDATA As UInteger = &HF0F00804UI
        Public Const INQUIRY_FUNCTION_PROCESSING_PROFILEDATA As UInteger = &HF0F00504UI
        Public Const FEATURE_FUNCTION_MAINTENANCEFUNCTIONS As UInteger = &HF0F0088CUI
        Public Const INQUIRY_FUNCTION_MAINTENANCEFUNCTIONS As UInteger = &HF0F0058CUI
        Public Const FEATURE_FUNCTION_ANALOGFREQUENCY As UInteger = &HF0F00828UI
        Public Const INQUIRY_FUNCTION_ANALOGFREQUENCY As UInteger = &HF0F00528UI
        Public Const FEATURE_FUNCTION_ANALOGOUTPUTMODES As UInteger = &HF0F00820UI
        Public Const INQUIRY_FUNCTION_ANALOGOUTPUTMODES As UInteger = &HF0F00520UI
        Public Const FEATURE_FUNCTION_CMMTRIGGER As UInteger = &HF0F00888UI
        Public Const INQUIRY_FUNCTION_CMMTRIGGER As UInteger = &HF0F00588UI
        Public Const FEATURE_FUNCTION_REARRANGEMENT_PROFILE As UInteger = &HF0F0080CUI
        Public Const INQUIRY_FUNCTION_REARRANGEMENT_PROFILE As UInteger = &HF0F0050CUI
        Public Const FEATURE_FUNCTION_RS422_INTERFACE_FUNCTION As UInteger = &HF0F008C0UI
        Public Const INQUIRY_FUNCTION_RS422_INTERFACE_FUNCTION As UInteger = &HF0F005C0UI
        Public Const FEATURE_FUNCTION_SATURATION As UInteger = &HF0F00814UI
        Public Const INQUIRY_FUNCTION_SATURATION As UInteger = &HF0F00514UI
        Public Const FEATURE_FUNCTION_CAPTURE_QUALITY As UInteger = &HF0F008C4UI
        Public Const INQUIRY_FUNCTION_CAPTURE_QUALITY As UInteger = &HF0F005C4UI
        Public Const FEATURE_FUNCTION_SHARPNESS As UInteger = &HF0F00808UI
        Public Const INQUIRY_FUNCTION_SHARPNESS As UInteger = &HF0F00508UI



#End Region

#Region "Enums"

        ' specifies the interface type for CreateLLTDevice and IsInterfaceType
        Public Enum TInterfaceType
            INTF_TYPE_UNKNOWN = 0
            INTF_TYPE_SERIAL = 1
            INTF_TYPE_FIREWIRE = 2
            INTF_TYPE_ETHERNET = 3
        End Enum

        ' specify the callback type
        ' if you programming language don't support enums, you can use a signed int
        Public Enum TCallbackType
            STD_CALL = 0
            C_DECL = 1
        End Enum

        ' specify the type of the scanner
        ' if you programming language don't support enums, you can use a signed int
        Public Enum TScannerType

            StandardType = -1                   ' can't decode scanCONTROL name use standard measurement range
            LLT25 = 0                           ' scanCONTROL28xx with 25mm measurmentrange
            LLT100 = 1                          ' scanCONTROL28xx with 100mm measurmentrange

            scanCONTROL28xx_25 = 0              ' scanCONTROL28xx with 25mm measurmentrange
            scanCONTROL28xx_100 = 1             ' scanCONTROL28xx with 100mm measurmentrange
            scanCONTROL28xx_10 = 2              ' scanCONTROL28xx with 10mm measurmentrange
            scanCONTROL28xx_xxx = 999           ' scanCONTROL28xx with no measurmentrange -> use standard measurement range

            scanCONTROL27xx_25 = 1000           ' scanCONTROL27xx with 25mm measurmentrange
            scanCONTROL27xx_100 = 1001          ' scanCONTROL27xx with 100mm measurmentrange
            scanCONTROL27xx_50 = 1002           ' scanCONTROL27xx with 50mm measurmentrange
            scanCONTROL2751_25 = 1020           ' scanCONTROL27xx with 25mm measurmentrange
            scanCONTROL2751_100 = 1021          ' scanCONTROL27xx with 100mm measurmentrange
            scanCONTROL2702_50 = 1032           ' scanCONTROL2702 with 50mm measurement range
            scanCONTROL27xx_xxx = 1999          ' scanCONTROL27xx with no measurmentrange -> use standard measurement range

            scanCONTROL26xx_25 = 2000           ' scanCONTROL26xx with 25mm measurmentrange
            scanCONTROL26xx_100 = 2001          ' scanCONTROL26xx with 100mm measurmentrange
            scanCONTROL26xx_50 = 2002           ' scanCONTROL26xx with 50mm measurmentrange          
            scanCONTROL2651_25 = 2020           ' scanCONTROL26xx with 25mm measurmentrange
            scanCONTROL2651_100 = 2021          ' scanCONTROL26xx with 100mm measurmentrange
            scanCONTROL2602_50 = 2032           ' scanCONTROL2602 with 50mm measurement range
            scanCONTROL26xx_xxx = 2999          ' scanCONTROL26xx with no measurmentrange -> use standard measurement range

            scanCONTROL29xx_25 = 3000           ' scanCONTROL29xx with 25mm measurmentrange
            scanCONTROL29xx_100 = 3001          ' scanCONTROL29xx with 100mm measurmentrange
            scanCONTROL29xx_50 = 3002           ' scanCONTROL29xx with 50mm measurmentrange
            scanCONTROL29xx_10 = 3003           ' scanCONTROL29xx with 10mm measurmentrange
            scanCONTROL2951_25 = 3020           ' scanCONTROL29xx with 25mm measurmentrange
            scanCONTROL2951_100 = 3021          ' scanCONTROL29xx with 100mm measurmentrange
            scanCONTROL2902_50 = 3032           ' scanCONTROL2902 with 50mm measurement range
            scanCONTROL2953_30 = 3033           ' scanCONTROL2953 with 30mm measurement range

            scanCONTROL2954_10 = 3034           ' scanCONTROL2954 with 10mm measurement range
            scanCONTROL2954_25 = 3035           ' scanCONTROL2954 with 25mm measurement range
            scanCONTROL2954_50 = 3036           ' scanCONTROL2954 with 50mm measurement range
            scanCONTROL2954_100 = 3037          ' scanCONTROL2954 with 100mm measurement range
            scanCONTROL2954_xxx = 3038          ' scanCONTROL2954 with 30mm measurement range
            scanCONTROL29xx_xxx = 3999          ' scanCONTROL29xx with no measurmentrange -> use standard measurement range

            scanCONTROL30xx_25 = 4000           'scanCONTROL30xx With 25mm measurement range
            scanCONTROL30xx_50 = 4001           'scanCONTROL30xx With 50mm measurement range
            scanCONTROL30xx_xxx = 4999          'scanCONTROL30xx With no measurement range

            scanCONTROL25xx_25 = 5000           'scanCONTROL25xx With 25mm measurement range
            scanCONTROL25xx_100 = 5001          'scanCONTROL25xx With 100mm measurement range
            scanCONTROL25xx_50 = 5002           'scanCONTROL25xx With 50mm measurement range
            scanCONTROL25xx_10 = 5003           'scanCONTROL25xx With 10mm measurement range
            scanCONTROL25xx_xxx = 5999          'scanCONTROL25xx With no measurement range

            scanCONTROL2xxx = 6000              'dummy

        End Enum

        ' specify the profile configuration
        ' if you programming language don't support enums, you can use a signed int
        Public Enum TProfileConfig
            NONE = 0
            PROFILE = 1
            CONTAINER = 1
            VIDEO_IMAGE = 1
            PURE_PROFILE = 2
            QUARTER_PROFILE = 3
            CSV_PROFILE = 4
            PARTIAL_PROFILE = 5
        End Enum

        Public Enum TTransferProfileType
            NORMAL_TRANSFER = 0
            SHOT_TRANSFER = 1
            NORMAL_CONTAINER_MODE = 2
            SHOT_CONTAINER_MODE = 3
            NONE_TRANSFER = 4
        End Enum

        Public Structure TPartialProfile
            Public nStartPoint As UInteger
            Public nStartPointData As UInteger
            Public nPointCount As UInteger
            Public nPointDataWidth As UInteger
        End Structure

        Public Enum TTransferVideoType
            VIDEO_MODE_0 = 0
            VIDEO_MODE_1 = 1
            NONE_VIDEOMODE = 2
        End Enum

        Public Enum TFileType
            AVI = 0
            LLT = 1
            CSV = 2
            BMP = 3
            CSV_NEG = 4
        End Enum

        Public Delegate Sub ProfileReceiveMethod(data As IntPtr, iSize As UInteger, pUserData As UInteger)



#End Region

#Region "DLL references"


        ' Instance functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_CreateLLTDevice")>
        Shared Function CreateLLTDevice(iInterfaceType As TInterfaceType) As UInteger
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_CreateLLTFirewire")>
        Shared Function CreateLLTFirewire() As UInteger
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_CreateLLTSerial")>
        Shared Function CreateLLTSerial() As UInteger
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetInterfaceType")>
        Shared Function GetInterfaceType(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_DelDevice")>
        Shared Function DelDevice(pLLT As UInteger) As Integer
        End Function

        ' Connect functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_Connect")>
        Shared Function Connect(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_Disconnect")>
        Shared Function Disconnect(pLLT As UInteger) As Integer
        End Function

        ' Write config functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ExportLLTConfig")>
        Shared Function ExportLLTConfig(pLLT As UInteger, pFileName As StringBuilder) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ExportLLTConfigString")>
        Shared Function ExportLLTConfigString(pLLT As UInteger, ByRef bConfigData As Byte, nSize As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ImportLLTConfig")>
        Shared Function ImportLLTConfig(pLLT As UInteger, pFileName As StringBuilder, bIgnoreCalibration As Boolean) As Integer
        End Function




        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetDeviceInterfaces")>
        Shared Function GetDeviceInterfaces(pLLT As UInteger, pInterfaces As UInteger(), nSize As Integer) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetDeviceInterfacesFast")>
        Shared Function GetDeviceInterfacesFast(pLLT As UInteger, pInterfaces As UInteger(), nSize As Integer) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetDeviceInterface")>
        Shared Function SetDeviceInterface(pLLT As UInteger, nInterface As UInteger, nAdditional As Integer) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetDiscoveryBroadcastTarget")>
        Shared Function GetDiscoveryBroadcastTarget(pLLT As UInteger) As UInteger
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetDiscoveryBroadcastTarget")>
        Shared Function SetDiscoveryBroadcastTarget(pLLT As UInteger, nNetworkAddress As UInteger, nSubnetMask As UInteger) As Integer
        End Function

        ' scanControl identification functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetDeviceName")>
        Shared Function GetDeviceName(pLLT As UInteger, sbDevName As StringBuilder, nDevNameSize As Integer, sbVenName As StringBuilder, nVenNameSize As Integer) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetLLTVersions")>
        Shared Function GetLLTVersions(pLLT As UInteger, ByRef pDSP As UInteger, ByRef pFPGA1 As UInteger, ByRef pFPGA2 As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetLLTType")>
        Shared Function GetLLTType(pLLT As UInteger, ByRef ScannerType As TScannerType) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetMinMaxPacketSize")>
        Shared Function GetMinMaxPacketSize(pLLT As UInteger, ByRef pMinPacketSize As ULong, ByRef pMaxPacketSize As ULong) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetResolutions")>
        Shared Function GetResolutions(pLLT As UInteger, pValue As UInteger(), nSize As Integer) As Integer
        End Function

        '  TOCHECK "feature"
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetFeature")>
        Shared Function GetFeature(pLLT As UInteger, feature As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetBufferCount")>
        Shared Function GetBufferCount(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetMainReflection")>
        Shared Function GetMainReflection(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetMaxFileSize")>
        Shared Function GetMaxFileSize(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetPacketSize")>
        Shared Function GetPacketSize(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetFirewireConnectionSpeed")>
        Shared Function GetFirewireConnectionSpeed(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetProfileConfig")>
        Shared Function GetProfileConfig(pLLT As UInteger, ByRef pValue As TProfileConfig) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetResolution")>
        Shared Function GetResolution(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetProfileContainerSize")>
        Shared Function GetProfileContainerSize(pLLT As UInteger, ByRef pWidth As UInteger, ByRef pHeight As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetMaxProfileContainerSize")>
        Shared Function GetMaxProfileContainerSize(pLLT As UInteger, ByRef pMaxWidth As UInteger, ByRef pMaxHeight As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetEthernetHeartbeatTimeout")>
        Shared Function GetEthernetHeartbeatTimeout(pLLT As UInteger, ByRef pValue As UInteger) As Integer
        End Function

        ' Set functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetFeature")>
        Shared Function SetFeature(pLLT As UInteger, Feature As UInteger, Value As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetResolution")>
        Shared Function SetResolution(pLLT As UInteger, Value As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetProfileConfig")>
        Shared Function SetProfileConfig(pLLT As UInteger, Value As TProfileConfig) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetBufferCount")>
        Shared Function SetBufferCount(pLLT As UInteger, pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetMainReflection")>
        Shared Function SetMainReflection(pLLT As UInteger, pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetMaxFileSize")>
        Shared Function SetMaxFileSize(pLLT As UInteger, pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetPacketSize")>
        Shared Function SetPacketSize(pLLT As UInteger, pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetFirewireConnectionSpeed")>
        Shared Function SetFirewireConnectionSpeed(pLLT As UInteger, pValue As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetProfileContainerSize")>
        Shared Function SetProfileContainerSize(pLLT As UInteger, nWidth As UInteger, nHeight As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetEthernetHeartbeatTimeout")>
        Shared Function SetEthernetHeartbeatTimeout(pLLT As UInteger, pValue As UInteger) As Integer
        End Function

        'Register functions
        '<DllImport(CSHARP_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="RegisterCallback")> _
        'shared Function RegisterCallback(pLLT As UInteger, tCallbackType As TCallbackType, tReceiveProfiles As ProfileReceiveMethod, pUserData As UInteger) As Integer
        'End Function

        'Register functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_RegisterCallback")>
        Shared Function RegisterCallback(pLLT As UInteger, tCallbackType As TCallbackType, tReceiveProfiles As ProfileReceiveMethod, pUserData As UInteger) As Integer
        End Function


        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_RegisterErrorMsg")>
        Shared Function RegisterErrorMsg(pLLT As UInteger, Msg As UInteger, hWnd As IntPtr, WParam As UIntPtr) As Integer
        End Function

        ' Profile transfer functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_TransferProfiles")>
        Shared Function TransferProfiles(pLLT As UInteger, TransferProfileType As TTransferProfileType, nEnable As Integer) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetProfile")>
        Shared Function GetProfile(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_TransferVideoStream")>
        Shared Function TransferVideoStream(pLLT As UInteger, TransferVideoType As TTransferVideoType, nEnable As Integer, ByRef pWidth As UInteger, ByRef pHeight As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_MultiShot")>
        Shared Function MultiShot(pLLT As UInteger, nCount As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetActualProfile")>
        Shared Function GetActualProfile(pLLT As UInteger, pBuffer As Byte(), nBuffersize As Integer,
                                                ProfileConfig As TProfileConfig, ByRef pLostProfiles As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ConvertProfile2Values")>
        Shared Function ConvertProfile2Values(pLLT As UInteger, pProfile As Byte(), nResolution As UInteger,
                                                     ProfileConfig As TProfileConfig, ScannerType As TScannerType, nReflection As UInteger, nConvertToMM As Integer,
                                                     pWidth As UShort(), pMaximum As UShort(), pThreshold As UShort(), pX As Double(), pZ As Double(),
                                                     pM0 As UInteger(), pM1 As UInteger()) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ConvertPartProfile2Values")>
        Shared Function ConvertPartProfile2Values(pLLT As UInteger, pProfile As Byte(), ByRef ProfileConfig As TPartialProfile, ScannerType As TScannerType, nReflection As UInteger, nConvertToMM As Integer,
                                                         pWidth As UShort(), pMaximum As UShort(), pThreshold As UShort(), pX As Double(), pZ As Double(),
                                                         pM0 As UInteger(), pM1 As UInteger()) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetHoldBuffersForPolling")>
        Shared Function SetHoldBuffersForPolling(pLLT As UInteger, uiHoldBuffersForPolling As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetMainReflection")>
        Shared Function GetHoldBuffersForPolling(pLLT As UInteger, ByRef puiHoldBuffersForPolling As UInteger) As Integer
        End Function

        ' Is functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_IsInterfaceType")>
        Shared Function IsInterfaceType(pLLT As UInteger, iInterfaceType As Integer) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_IsFirewire")>
        Shared Function IsFirewire(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_IsSerial")>
        Shared Function IsSerial(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_IsTransferingProfiles")>
        Shared Function IsTransferingProfiles(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetPartialProfileUnitSize")>
        Shared Function GetPartialProfileUnitSize(pLLT As UInteger, ByRef pUnitSizePoint As UInteger, ByRef pUnitSizePointData As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetPartialProfile")>
        Shared Function GetPartialProfile(pLLT As UInteger, ByRef pPartialProfile As TPartialProfile) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SetPartialProfile")>
        Shared Function SetPartialProfile(pLLT As UInteger, ByRef pPartialProfile As TPartialProfile) As Integer
        End Function

        ' Timestamp convert functions,
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_Timestamp2CmmTriggerAndInCounter")>
        Shared Function Timestamp2CmmTriggerAndInCounter(pBuffer As Byte(), ByRef pInCounter As UInteger, ByRef pCmmTrigger As Integer, ByRef pCmmActive As Integer, ByRef pCmmCount As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_Timestamp2TimeAndCount")>
        Shared Function Timestamp2TimeAndCount(pBuffer As Byte(), ByRef dTimeShutterOpen As Double, ByRef dTimeShutterClose As Double, ByRef uiProfileCount As UInteger) As Integer
        End Function

        ' PostProcessing functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ReadPostProcessingParameter")>
        Shared Function ReadPostProcessingParameter(pLLT As UInteger, ByRef pParameter As UInteger, nSize As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_WritePostProcessingParameter")>
        Shared Function WritePostProcessingParameter(pLLT As UInteger, ByRef pParameter As UInteger, nSize As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ConvertProfile2ModuleResult")>
        Shared Function ConvertProfile2ModuleResult(pLLT As UInteger, pProfileBuffer As Byte(), nProfileBufferSize As UInteger, pModuleResultBuffer As Byte(), nResultBufferSize As UInteger,
                                                           ByRef pPartialProfile As TPartialProfile) As Integer '/* = NULL*/
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_LoadProfiles")>
        Shared Function LoadProfiles(pLLT As UInteger, pFilename As StringBuilder, ByRef pPartialProfile As TPartialProfile, ByRef pProfileConfig As TProfileConfig,
                                            ByRef pScannerType As TScannerType, ByRef pRearrengementProfile As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SaveProfiles")>
        Shared Function SaveProfiles(pLLT As UInteger, pFilename As StringBuilder, FileType As TFileType) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_LoadProfilesGetPos")>
        Shared Function LoadProfilesGetPos(pLLT As UInteger, ByRef pActualPosition As UInteger, ByRef pMaxPosition As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_LoadProfilesSetPos")>
        Shared Function LoadProfilesSetPos(pLLT As UInteger, nNewPosition As UInteger) As Integer
        End Function

        ' Special CMM trigger functions
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_StartTransmissionAndCmmTrigger")>
        Shared Function StartTransmissionAndCmmTrigger(pLLT As UInteger, nCmmTrigger As UInteger, TransferProfileType As TTransferProfileType, nProfilesForerun As UInteger,
                                                              pFilename As StringBuilder, FileType As TFileType, Timeout As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_StopTransmissionAndCmmTrigger")>
        Shared Function StopTransmissionAndCmmTrigger(pLLT As UInteger, nCmmTriggerPolarity As Integer, nTimeout As UInteger) As Integer
        End Function

        ' Converts a error-value in a string 
        ' ToCheck: ErrorValue
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_TranslateErrorValue")>
        Shared Function TranslateErrorValue(pLLT As UInteger, errValue As Integer, pString As Byte(), nStringSize As Integer) As Integer
        End Function

        ' User mode
        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_GetActualUserMode")>
        Shared Function GetActualUserMode(pLLT As UInteger, ByRef pActualUserMode As UInteger, ByRef pUserModeCount As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ReadWriteUserModes")>
        Shared Function ReadWriteUserModes(pLLT As UInteger, nWrite As Integer, nUserMode As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_TriggerProfile")>
        Shared Function TriggerProfile(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_TriggerContainer")>
        Shared Function TriggerContainer(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ContainerTriggerEnable")>
        Shared Function ContainerTriggerEnable(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_ContainerTriggerDisable")>
        Shared Function ContainerTriggerDisable(pLLT As UInteger) As Integer
        End Function

        <DllImport(DRIVER_DLL_NAME, CallingConvention:=CallingConvention.StdCall, EntryPoint:="s_SaveGlobalParameter")>
        Shared Function SaveGlobalParameter(pLLT As UInteger) As Integer
        End Function

#End Region

        ' constructor
        Public CLLTI()

    End Class

End Namespace