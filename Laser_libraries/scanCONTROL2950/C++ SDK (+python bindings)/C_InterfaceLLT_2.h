//  c_InterfaceLLT_2.cpp: import class for LLT.dll
//
//   Copyright 2010
//
//   Sebastian Lueth
//   MICRO-EPSILON Optronic GmbH
//   Lessingstrasse 14
//   01465 Dresden OT Langebrueck
//   Germany

#pragma once
#include "windows.h"
#include "scanControlDataTypes.h"

// declare the old functions as deprecated
#ifdef DEPRECATED
#  undef DEPRECATED
#endif

#if defined _MSC_VER
#  define DEPRECATED __declspec(deprecated)
#else
#  define DEPRECATED
#endif

#ifdef __cplusplus
extern "C"
{
#endif

  // Instance functions
  // Please use the return value from this three functions as pLLT - parameter
  extern long __cdecl c_CreateLLTDevice(TInterfaceType iInterfaceType);
  DEPRECATED extern long __cdecl c_CreateLLTFirewire();
  DEPRECATED extern long __cdecl c_CreateLLTSerial();
  extern int __cdecl c_GetInterfaceType(long pLLT);
  extern int __cdecl c_DelDevice(long pLLT);

  // Connect functions
  extern int __cdecl c_Connect(long pLLT);
  extern int __cdecl c_Disconnect(long pLLT);

  // Read/Write config functions
  extern int __cdecl c_ExportLLTConfig(long pLLT, const char* pFileName);
  extern int __cdecl c_ExportLLTConfigString(long pLLT, char* configData, int configDataSize);
  extern int __cdecl c_ImportLLTConfig(long pLLT, const char* pFileName, bool ignoreCalibration);
  extern int __cdecl c_ImportLLTConfigString(long pLLT, const char* configData, int configDataSize, bool ignoreCalibration);

  // Device interface functions
  extern int __cdecl c_GetDeviceInterfaces(long pLLT, unsigned int* pInterfaces, unsigned int nSize);
  extern int __cdecl c_GetDeviceInterfacesFast(long pLLT, unsigned int* pInterfaces, unsigned int nSize);
  extern int __cdecl c_SetDeviceInterface(long pLLT, unsigned int nInterface, int nAdditional);
  extern unsigned __cdecl c_GetDiscoveryBroadcastTarget(long pLLT);
  extern int __cdecl c_SetDiscoveryBroadcastTarget(long pLLT, unsigned int nNetworkAddress, unsigned int nSubnetMask);

  // scanCONTROL indentification functions
  extern int __cdecl c_GetDeviceName(long pLLT, char* pDevName, unsigned int nDevNameSize, char* pVenName, unsigned int nVenNameSize);
  extern int __cdecl c_GetSerialNumber(long pLLT, char* pSerialNumber, unsigned int nSerialNumberSize);
  extern int __cdecl c_GetLLTVersions(long pLLT, unsigned int* pDSP, unsigned int* pFPGA1, unsigned int* pFPGA2);
  extern int __cdecl c_GetLLTType(long pLLT, TScannerType* pScannerType);

  // Get functions
  extern int __cdecl c_GetMinMaxPacketSize(long pLLT, unsigned long* pMinPacketSize, unsigned long* pMaxPacketSize);
  extern int __cdecl c_GetResolutions(long pLLT, DWORD* pValue, unsigned int nSize);

  extern int __cdecl c_GetFeature(long pLLT, DWORD Function, DWORD* pValue);
  extern int __cdecl c_GetBufferCount(long pLLT, DWORD* pValue);
  extern int __cdecl c_GetMainReflection(long pLLT, DWORD* pValue);
  extern int __cdecl c_GetMaxFileSize(long pLLT, DWORD* pValue);
  extern int __cdecl c_GetPacketSize(long pLLT, DWORD* pValue);
  extern int __cdecl c_GetFirewireConnectionSpeed(long pLLT, DWORD* pValue);
  extern int __cdecl c_GetProfileConfig(long pLLT, TProfileConfig* pValue);
  extern int __cdecl c_GetResolution(long pLLT, DWORD* pValue);
  extern int __cdecl c_GetProfileContainerSize(long pLLT, unsigned int* pWidth, unsigned int* pHeight);
  extern int __cdecl c_GetMaxProfileContainerSize(long pLLT, unsigned int* pMaxWidth, unsigned int* pMaxHeight);
  extern int __cdecl c_GetEthernetHeartbeatTimeout(long pLLT, DWORD* pValue);

  // Set functions
  extern int __cdecl c_SetFeature(long pLLT, DWORD Function, DWORD Value);
  extern int __cdecl c_SetFeatureGroup(long pLLT, const DWORD* FeatureAddresses, const DWORD* FeatureValues, DWORD FeatureCount);
  extern int __cdecl c_SetBufferCount(long pLLT, DWORD Value);
  extern int __cdecl c_SetMainReflection(long pLLT, DWORD Value);
  extern int __cdecl c_SetMaxFileSize(long pLLT, DWORD Value);
  extern int __cdecl c_SetPacketSize(long pLLT, DWORD Value);
  extern int __cdecl c_SetFirewireConnectionSpeed(long pLLT, DWORD Value);
  extern int __cdecl c_SetProfileConfig(long pLLT, TProfileConfig Value);
  extern int __cdecl c_SetResolution(long pLLT, DWORD Value);
  extern int __cdecl c_SetProfileContainerSize(long pLLT, unsigned int nWidth, unsigned int nHeight);
  extern int __cdecl c_SetEthernetHeartbeatTimeout(long pLLT, DWORD Value);

  // Register functions
  extern int __cdecl c_RegisterCallback(long pLLT, TCallbackType CallbackType, void* pLLTProfileCallback_3, void* pUserData);
  extern int __cdecl c_RegisterErrorMsg(long pLLT, UINT Msg, HWND hWnd, WPARAM WParam);

  // Profile transfer functions
  extern int __cdecl c_TransferProfiles(long pLLT, TTransferProfileType TransferProfileType, int nEnable);
  extern int __cdecl c_TransferVideoStream(long pLLT, int TransferVideoType, int nEnable, unsigned int* pWidth, unsigned int* pHeight);

  extern int __cdecl c_GetProfile(long pLLT);
  extern int __cdecl c_MultiShot(long pLLT, unsigned int Count);
  extern int __cdecl c_GetActualProfile(long pLLT, unsigned char* pBuffer, unsigned int nBuffersize, TProfileConfig ProfileConfig,
                                        unsigned int* pLostProfiles);
  extern int __cdecl c_ConvertProfile2Values(long pLLT, const unsigned char* pProfile, unsigned int nResolution,
                                             TProfileConfig ProfileConfig, TScannerType ScannerType, unsigned int nReflection,
                                             int nConvertToMM, unsigned short* pWidth, unsigned short* pMaximum, unsigned short* pThreshold,
                                             double* pX, double* pZ, unsigned int* pM0, unsigned int* pM1);
  extern int __cdecl c_ConvertPartProfile2Values(long pLLT, const unsigned char* pProfile, TPartialProfile* pPartialProfile,
                                                 TScannerType ScannerType, unsigned int nReflection, int nConvertToMM,
                                                 unsigned short* pWidth, unsigned short* pMaximum, unsigned short* pThreshold, double* pX,
                                                 double* pZ, unsigned int* pM0, unsigned int* pM1);

  extern int __cdecl c_SetHoldBuffersForPolling(long pLLT, unsigned int uiHoldBuffersForPolling);
  extern int __cdecl c_GetHoldBuffersForPolling(long pLLT, unsigned int* puiHoldBuffersForPolling);

  // Is functions
  extern int __cdecl c_IsInterfaceType(long pLLT, int iInterfaceType);
  DEPRECATED extern int __cdecl c_IsFirewire(long pLLT);
  DEPRECATED extern int __cdecl c_IsSerial(long pLLT);
  extern int __cdecl c_IsTransferingProfiles(long pLLT);

  // PartialProfile functions
  extern int __cdecl c_GetPartialProfileUnitSize(long pLLT, unsigned int* pUnitSizePoint, unsigned int* pUnitSizePointData);
  extern int __cdecl c_GetPartialProfile(long pLLT, TPartialProfile* pPartialProfile);
  extern int __cdecl c_SetPartialProfile(long pLLT, TPartialProfile* pPartialProfile);

  // Timestamp convert functions
  extern void __cdecl c_Timestamp2CmmTriggerAndInCounter(const unsigned char* pTimestamp, unsigned int* pInCounter, int* pCmmTrigger,
                                                         int* pCmmActive, unsigned int* pCmmCount);
  extern void __cdecl c_Timestamp2TimeAndCount(const unsigned char* pTimestamp, double* pTimeShutterOpen, double* pTimeShutterClose,
                                               unsigned int* pProfileCount);

  // PostProcessing functions
  extern int __cdecl c_ReadPostProcessingParameter(long pLLT, DWORD* pParameter, unsigned int nSize);
  extern int __cdecl c_WritePostProcessingParameter(long pLLT, DWORD* pParameter, unsigned int nSize);
  extern int __cdecl c_ConvertProfile2ModuleResult(long pLLT, const unsigned char* pProfileBuffer, unsigned int nProfileBufferSize,
                                                   unsigned char* pModuleResultBuffer, unsigned int nResultBufferSize,
                                                   TPartialProfile* pPartialProfile);

  // Load/Save functions
  extern int __cdecl c_SaveProfiles(long pLLT, const char* pFilename, TFileType FileType);
  extern int __cdecl c_LoadProfiles(long pLLT, const char* pFilename, TPartialProfile* pPartialProfile, TProfileConfig* pProfileConfig,
                                    TScannerType* pScannerType, DWORD* pRearrengementProfile);
  extern int __cdecl c_LoadProfilesGetPos(long pLLT, unsigned int* pActualPosition, unsigned int* pMaxPosition);
  extern int __cdecl c_LoadProfilesSetPos(long pLLT, unsigned int nNewPosition);

  // Special CMM trigger functions
  extern int __cdecl c_StartTransmissionAndCmmTrigger(long pLLT, DWORD nCmmTrigger, TTransferProfileType TransferProfileType,
                                                      unsigned int nProfilesForerun, const char* pFilename, TFileType FileType,
                                                      unsigned int nTimeout);
  extern int __cdecl c_StopTransmissionAndCmmTrigger(long pLLT, int nCmmTriggerPolarity, unsigned int nTimeout);

  // Converts a error-value in a string
  extern int __cdecl c_TranslateErrorValue(long pLLT, int ErrorValue, char* pString, unsigned int nStringSize);

  // User Mode
  extern int __cdecl c_GetActualUserMode(long pLLT, unsigned int* pActualUserMode, unsigned int* pUserModeCount);
  extern int __cdecl c_ReadWriteUserModes(long pLLT, int nWrite, unsigned int nUserMode);
  extern int __cdecl c_SaveGlobalParameter(long pLLT);
  extern int __cdecl c_TriggerProfile(long pLLT);
  extern int __cdecl c_TriggerContainer(long pLLT);
  extern int __cdecl c_ContainerTriggerEnable(long pLLT);
  extern int __cdecl c_ContainerTriggerDisable(long pLLT);
  extern int __cdecl c_FlushContainer(long pLLT);
  extern int __cdecl c_SensorReset(long pLLT);

#ifdef __cplusplus
}
#endif
