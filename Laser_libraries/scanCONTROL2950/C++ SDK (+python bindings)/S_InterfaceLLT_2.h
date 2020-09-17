//  s_InterfaceLLT_2.cpp: import class for LLT.dll
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
  extern long __stdcall s_CreateLLTDevice(TInterfaceType iInterfaceType);
  DEPRECATED extern long __stdcall s_CreateLLTFirewire();
  DEPRECATED extern long __stdcall s_CreateLLTSerial();
  extern int __stdcall s_GetInterfaceType(long pLLT);
  extern int __stdcall s_DelDevice(long pLLT);

  // Connect functions
  extern int __stdcall s_Connect(long pLLT);
  extern int __stdcall s_Disconnect(long pLLT);

  // Read/Write config functions
  extern int __stdcall s_ExportLLTConfig(long pLLT, const char* pFileName);
  extern int __stdcall s_ExportLLTConfigString(long pLLT, char* configData, int configDataSize);
  extern int __stdcall s_ImportLLTConfig(long pLLT, const char* pFileName, bool ignoreCalibration);
  extern int __stdcall s_ImportLLTConfigString(long pLLT, const char* configData, int configDataSize, bool ignoreCalibration);

  // Device interface functions
  extern int __stdcall s_GetDeviceInterfaces(long pLLT, unsigned int* pInterfaces, unsigned int nSize);
  extern int __stdcall s_GetDeviceInterfacesFast(long pLLT, unsigned int* pInterfaces, unsigned int nSize);
  extern int __stdcall s_SetDeviceInterface(long pLLT, unsigned int nInterface, int nAdditional);
  extern unsigned __stdcall s_GetDiscoveryBroadcastTarget(long pLLT);
  extern int __stdcall s_SetDiscoveryBroadcastTarget(long pLLT, unsigned int nNetworkAddress, unsigned int nSubnetMask);

  // scanCONTROL indentification functions
  extern int __stdcall s_GetDeviceName(long pLLT, char* pDevName, unsigned int nDevNameSize, char* pVenName, unsigned int nVenNameSize);
  extern int __stdcall s_GetSerialNumber(long pLLT, char* pSerialNumber, unsigned int nSerialNumberSize);
  extern int __stdcall s_GetLLTVersions(long pLLT, unsigned int* pDSP, unsigned int* pFPGA1, unsigned int* pFPGA2);
  extern int __stdcall s_GetLLTType(long pLLT, TScannerType* pScannerType);

  // Get functions
  extern int __stdcall s_GetMinMaxPacketSize(long pLLT, unsigned long* pMinPacketSize, unsigned long* pMaxPacketSize);
  extern int __stdcall s_GetResolutions(long pLLT, DWORD* pValue, unsigned int nSize);

  extern int __stdcall s_GetFeature(long pLLT, DWORD Function, DWORD* pValue);
  extern int __stdcall s_GetBufferCount(long pLLT, DWORD* pValue);
  extern int __stdcall s_GetMainReflection(long pLLT, DWORD* pValue);
  extern int __stdcall s_GetMaxFileSize(long pLLT, DWORD* pValue);
  extern int __stdcall s_GetPacketSize(long pLLT, DWORD* pValue);
  extern int __stdcall s_GetFirewireConnectionSpeed(long pLLT, DWORD* pValue);
  extern int __stdcall s_GetProfileConfig(long pLLT, TProfileConfig* pValue);
  extern int __stdcall s_GetResolution(long pLLT, DWORD* pValue);
  extern int __stdcall s_GetProfileContainerSize(long pLLT, unsigned int* pWidth, unsigned int* pHeight);
  extern int __stdcall s_GetMaxProfileContainerSize(long pLLT, unsigned int* pMaxWidth, unsigned int* pMaxHeight);
  extern int __stdcall s_GetEthernetHeartbeatTimeout(long pLLT, DWORD* pValue);

  // Set functions
  extern int __stdcall s_SetFeature(long pLLT, DWORD Function, DWORD Value);
  extern int __stdcall s_SetFeatureGroup(long pLLT, const DWORD* FeatureAddresses, const DWORD* FeatureValues, DWORD FeatureCount);
  extern int __stdcall s_SetBufferCount(long pLLT, DWORD Value);
  extern int __stdcall s_SetMainReflection(long pLLT, DWORD Value);
  extern int __stdcall s_SetMaxFileSize(long pLLT, DWORD Value);
  extern int __stdcall s_SetPacketSize(long pLLT, DWORD Value);
  extern int __stdcall s_SetFirewireConnectionSpeed(long pLLT, DWORD Value);
  extern int __stdcall s_SetProfileConfig(long pLLT, TProfileConfig Value);
  extern int __stdcall s_SetResolution(long pLLT, DWORD Value);
  extern int __stdcall s_SetProfileContainerSize(long pLLT, unsigned int nWidth, unsigned int nHeight);
  extern int __stdcall s_SetEthernetHeartbeatTimeout(long pLLT, DWORD Value);

  // Register functions
  extern int __stdcall s_RegisterCallback(long pLLT, TCallbackType CallbackType, void* pLLTProfileCallback_3, void* pUserData);
  extern int __stdcall s_RegisterErrorMsg(long pLLT, UINT Msg, HWND hWnd, WPARAM WParam);

  // Profile transfer functions
  extern int __stdcall s_TransferProfiles(long pLLT, TTransferProfileType TransferProfileType, int nEnable);
  extern int __stdcall s_TransferVideoStream(long pLLT, int TransferVideoType, int nEnable, unsigned int* pWidth, unsigned int* pHeight);

  extern int __stdcall s_GetProfile(long pLLT);
  extern int __stdcall s_MultiShot(long pLLT, unsigned int Count);
  extern int __stdcall s_GetActualProfile(long pLLT, unsigned char* pBuffer, unsigned int nBuffersize, TProfileConfig ProfileConfig,
                                          unsigned int* pLostProfiles);
  extern int __stdcall s_ConvertProfile2Values(long pLLT, const unsigned char* pProfile, unsigned int nResolution,
                                               TProfileConfig ProfileConfig, TScannerType ScannerType, unsigned int nReflection,
                                               int nConvertToMM, unsigned short* pWidth, unsigned short* pMaximum,
                                               unsigned short* pThreshold, double* pX, double* pZ, unsigned int* pM0, unsigned int* pM1);
  extern int __stdcall s_ConvertPartProfile2Values(long pLLT, const unsigned char* pProfile, TPartialProfile* pPartialProfile,
                                                   TScannerType ScannerType, unsigned int nReflection, int nConvertToMM,
                                                   unsigned short* pWidth, unsigned short* pMaximum, unsigned short* pThreshold, double* pX,
                                                   double* pZ, unsigned int* pM0, unsigned int* pM1);

  extern int __stdcall s_SetHoldBuffersForPolling(long pLLT, unsigned int uiHoldBuffersForPolling);
  extern int __stdcall s_GetHoldBuffersForPolling(long pLLT, unsigned int* puiHoldBuffersForPolling);

  // Is functions
  extern int __stdcall s_IsInterfaceType(long pLLT, int iInterfaceType);
  DEPRECATED extern int __stdcall s_IsFirewire(long pLLT);
  DEPRECATED extern int __stdcall s_IsSerial(long pLLT);
  extern int __stdcall s_IsTransferingProfiles(long pLLT);

  // PartialProfile functions
  extern int __stdcall s_GetPartialProfileUnitSize(long pLLT, unsigned int* pUnitSizePoint, unsigned int* pUnitSizePointData);
  extern int __stdcall s_GetPartialProfile(long pLLT, TPartialProfile* pPartialProfile);
  extern int __stdcall s_SetPartialProfile(long pLLT, TPartialProfile* pPartialProfile);

  // Timestamp convert functions
  extern void __stdcall s_Timestamp2CmmTriggerAndInCounter(const unsigned char* pTimestamp, unsigned int* pInCounter, int* pCmmTrigger,
                                                           int* pCmmActive, unsigned int* pCmmCount);
  extern void __stdcall s_Timestamp2TimeAndCount(const unsigned char* pTimestamp, double* pTimeShutterOpen, double* pTimeShutterClose,
                                                 unsigned int* pProfileCount);

  // PostProcessing functions
  extern int __stdcall s_ReadPostProcessingParameter(long pLLT, DWORD* pParameter, unsigned int nSize);
  extern int __stdcall s_WritePostProcessingParameter(long pLLT, DWORD* pParameter, unsigned int nSize);
  extern int __stdcall s_ConvertProfile2ModuleResult(long pLLT, const unsigned char* pProfileBuffer, unsigned int nProfileBufferSize,
                                                     unsigned char* pModuleResultBuffer, unsigned int nResultBufferSize,
                                                     TPartialProfile* pPartialProfile);

  // Load/Save functions
  extern int __stdcall s_SaveProfiles(long pLLT, const char* pFilename, TFileType FileType);
  extern int __stdcall s_LoadProfiles(long pLLT, const char* pFilename, TPartialProfile* pPartialProfile, TProfileConfig* pProfileConfig,
                                      TScannerType* pScannerType, DWORD* pRearrengementProfile);
  extern int __stdcall s_LoadProfilesGetPos(long pLLT, unsigned int* pActualPosition, unsigned int* pMaxPosition);
  extern int __stdcall s_LoadProfilesSetPos(long pLLT, unsigned int nNewPosition);

  // Special CMM trigger functions
  extern int __stdcall s_StartTransmissionAndCmmTrigger(long pLLT, DWORD nCmmTrigger, TTransferProfileType TransferProfileType,
                                                        unsigned int nProfilesForerun, const char* pFilename, TFileType FileType,
                                                        unsigned int nTimeout);
  extern int __stdcall s_StopTransmissionAndCmmTrigger(long pLLT, int nCmmTriggerPolarity, unsigned int nTimeout);

  // Converts a error-value in a string
  extern int __stdcall s_TranslateErrorValue(long pLLT, int ErrorValue, char* pString, unsigned int nStringSize);

  // User Mode
  extern int __stdcall s_GetActualUserMode(long pLLT, unsigned int* pActualUserMode, unsigned int* pUserModeCount);
  extern int __stdcall s_ReadWriteUserModes(long pLLT, int nWrite, unsigned int nUserMode);
  extern int __stdcall s_SaveGlobalParameter(long pLLT);
  extern int __stdcall s_TriggerProfile(long pLLT);
  extern int __stdcall s_TriggerContainer(long pLLT);
  extern int __stdcall s_ContainerTriggerEnable(long pLLT);
  extern int __stdcall s_ContainerTriggerDisable(long pLLT);
  extern int __stdcall s_FlushContainer(long pLLT);

#ifdef __cplusplus
}
#endif
