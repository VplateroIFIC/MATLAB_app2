//  InterfaceLLT.h: interface for the CInterfaceLLT class.
//
//   Copyright 2010
//
//   Sebastian Lueth
//   MICRO-EPSILON Optronic GmbH
//   Lessingstrasse 14
//   01465 Dresden OT Langebrueck
//   Germany

#pragma once
#include "S_InterfaceLLT_2.h"

class CDllLoader;

// LLT-Interface class
class CInterfaceLLT
{
public:
  CInterfaceLLT(const char* pDLLName = ".\\LLT.dll", bool* pLoadError = nullptr);
  ~CInterfaceLLT();

  class CFunctions
  {
  public:
    CFunctions(const char* pDLLName, bool* pLoadError = nullptr);
    ~CFunctions();

    // Instance functions
    decltype(&s_CreateLLTDevice) CreateLLTDevice;
    decltype(&s_CreateLLTFirewire) CreateLLTFirewire;

    decltype(&s_CreateLLTSerial) CreateLLTSerial;
    decltype(&s_GetInterfaceType) GetInterfaceType;
    decltype(&s_DelDevice) DelDevice;

    // Connect functions
    decltype(&s_Connect) Connect;
    decltype(&s_Disconnect) Disconnect;

    // Read/Write config functions
    decltype(&s_ExportLLTConfig) ExportLLTConfig;
    decltype(&s_ExportLLTConfigString) ExportLLTConfigString;
    decltype(&s_ImportLLTConfig) ImportLLTConfig;
    decltype(&s_ImportLLTConfigString) ImportLLTConfigString;

    // Device interface functions
    decltype(&s_GetDeviceInterfaces) GetDeviceInterfaces;
    decltype(&s_GetDeviceInterfacesFast) GetDeviceInterfacesFast;
    decltype(&s_SetDeviceInterface) SetDeviceInterface;
    decltype(&s_GetDiscoveryBroadcastTarget) GetDiscoveryBroadcastTarget;
    decltype(&s_SetDiscoveryBroadcastTarget) SetDiscoveryBroadcastTarget;

    // LLT indentification functions
    decltype(&s_GetDeviceName) GetDeviceName;
    decltype(&s_GetSerialNumber) GetSerialNumber;
    decltype(&s_GetLLTVersions) GetLLTVersions;
    decltype(&s_GetLLTType) GetLLTType;

    // Get functions
    decltype(&s_GetMinMaxPacketSize) GetMinMaxPacketSize;
    decltype(&s_GetResolutions) GetResolutions;

    decltype(&s_GetFeature) GetFeature;
    decltype(&s_GetBufferCount) GetBufferCount;
    decltype(&s_GetMainReflection) GetMainReflection;
    decltype(&s_GetMaxFileSize) GetMaxFileSize;
    decltype(&s_GetPacketSize) GetPacketSize;
    decltype(&s_GetFirewireConnectionSpeed) GetFirewireConnectionSpeed;
    decltype(&s_GetResolution) GetResolution;
    decltype(&s_GetProfileConfig) GetProfileConfig;

    decltype(&s_GetProfileContainerSize) GetProfileContainerSize;
    decltype(&s_GetMaxProfileContainerSize) GetMaxProfileContainerSize;
    decltype(&s_GetEthernetHeartbeatTimeout) GetEthernetHeartbeatTimeout;

    // Set functions
    decltype(&s_SetFeature) SetFeature;
    decltype(&s_SetFeatureGroup) SetFeatureGroup;
    decltype(&s_SetBufferCount) SetBufferCount;
    decltype(&s_SetMainReflection) SetMainReflection;
    decltype(&s_SetMaxFileSize) SetMaxFileSize;
    decltype(&s_SetPacketSize) SetPacketSize;
    decltype(&s_SetFirewireConnectionSpeed) SetFirewireConnectionSpeed;
    decltype(&s_SetResolution) SetResolution;
    decltype(&s_SetProfileConfig) SetProfileConfig;
    decltype(&s_SetProfileContainerSize) SetProfileContainerSize;
    decltype(&s_SetEthernetHeartbeatTimeout) SetEthernetHeartbeatTimeout;

    // Register functions
    decltype(&s_RegisterCallback) RegisterCallback;
    decltype(&s_RegisterErrorMsg) RegisterErrorMsg;

    // Profile transfer functions
    decltype(&s_GetProfile) GetProfile;
    decltype(&s_TransferProfiles) TransferProfiles;
    decltype(&s_TransferVideoStream) TransferVideoStream;
    decltype(&s_MultiShot) MultiShot;
    decltype(&s_GetActualProfile) GetActualProfile;
    decltype(&s_ConvertProfile2Values) ConvertProfile2Values;
    decltype(&s_ConvertPartProfile2Values) ConvertPartProfile2Values;
    decltype(&s_SetHoldBuffersForPolling) SetHoldBuffersForPolling;
    decltype(&s_GetHoldBuffersForPolling) GetHoldBuffersForPolling;
    decltype(&s_TriggerProfile) TriggerProfile;

    decltype(&s_TriggerContainer) TriggerContainer;
    decltype(&s_ContainerTriggerEnable) ContainerTriggerEnable;
    decltype(&s_ContainerTriggerDisable) ContainerTriggerDisable;
    decltype(&s_FlushContainer) FlushContainer;

    // Is functions
    decltype(&s_IsInterfaceType) IsInterfaceType;
    decltype(&s_IsSerial) IsSerial;
    decltype(&s_IsFirewire) IsFirewire;
    decltype(&s_IsTransferingProfiles) IsTransferingProfiles;

    // PartialProfile functions
    decltype(&s_GetPartialProfileUnitSize) GetPartialProfileUnitSize;
    decltype(&s_GetPartialProfile) GetPartialProfile;
    decltype(&s_SetPartialProfile) SetPartialProfile;

    // Timestamp convert functions
    decltype(&s_Timestamp2CmmTriggerAndInCounter) Timestamp2CmmTriggerAndInCounter;
    decltype(&s_Timestamp2TimeAndCount) Timestamp2TimeAndCount;

    // PostProcessing functions
    decltype(&s_ReadPostProcessingParameter) ReadPostProcessingParameter;
    decltype(&s_WritePostProcessingParameter) WritePostProcessingParameter;
    decltype(&s_ConvertProfile2ModuleResult) ConvertProfile2ModuleResult;

    // Load/Save functions
    decltype(&s_LoadProfiles) LoadProfiles;
    decltype(&s_SaveProfiles) SaveProfiles;
    decltype(&s_LoadProfilesGetPos) LoadProfilesGetPos;
    decltype(&s_LoadProfilesSetPos) LoadProfilesSetPos;

    // Special CMM trigger functions
    decltype(&s_StartTransmissionAndCmmTrigger) StartTransmissionAndCmmTrigger;
    decltype(&s_StopTransmissionAndCmmTrigger) StopTransmissionAndCmmTrigger;

    // Converts a error-value in a string
    decltype(&s_TranslateErrorValue) TranslateErrorValue;

    // User Mode
    decltype(&s_GetActualUserMode) GetActualUserMode;
    decltype(&s_ReadWriteUserModes) ReadWriteUserModes;
    decltype(&s_SaveGlobalParameter) SaveGlobalParameter;

  protected:
    CDllLoader* m_pDllLoader;
  };

  // Instance functions
  int CreateLLTDevice(TInterfaceType iInterfaceType);
  DEPRECATED int CreateLLTFirewire();
  DEPRECATED int CreateLLTSerial();
  int GetInterfaceType();
  int DelDevice();

  // Connect functions
  int Connect();
  int Disconnect();

  // Read/Write config functions
  int ImportLLTConfig(const char* pFileName, bool ignoreCalibration);
  int ImportLLTConfigString(const char* configData, int configDataSize, bool ignoreCalibration);
  int ExportLLTConfig(const char* pFileName);
  int ExportLLTConfigString(char* configData, int configDataSize);

  // Device interface functions
  int GetDeviceInterfaces(unsigned int* pInterfaces, unsigned int nSize);
  int GetDeviceInterfacesFast(unsigned int* pInterfaces, unsigned int nSize);
  int SetDeviceInterface(unsigned int nInterface, int nAdditional);
  unsigned GetDiscoveryBroadcastTarget();
  int SetDiscoveryBroadcastTarget(unsigned int nNetworkAddress, unsigned int nSubnetMask);

  // LLT indentification functions
  int GetDeviceName(char* pDevName, unsigned int nDevNameSize, char* pVenName, unsigned int nVenNameSize);
  int GetSerialNumber(char* pSerialNumber, unsigned int nSerialNumberSize);
  int GetLLTVersions(unsigned int* pDSP, unsigned int* pFPGA1, unsigned int* pFPGA2);
  int GetLLTType(TScannerType* pScannerType);

  // Get functions
  int GetMinMaxPacketSize(unsigned long* pMinPacketSize, unsigned long* pMaxPacketSize);
  int GetResolutions(DWORD* pValue, unsigned int nSize);

  int GetFeature(DWORD Function, DWORD* pValue);
  int GetBufferCount(DWORD* pValue);
  int GetMainReflection(DWORD* pValue);
  int GetMaxFileSize(DWORD* pValue);
  int GetPacketSize(DWORD* pValue);
  int GetFirewireConnectionSpeed(DWORD* pValue);
  int GetProfileConfig(TProfileConfig* pValue);
  int GetResolution(DWORD* pValue);
  int GetProfileContainerSize(unsigned int* pWidth, unsigned int* pHeight);
  int GetMaxProfileContainerSize(unsigned int* pMaxWidth, unsigned int* pMaxHeight);
  int GetEthernetHeartbeatTimeout(DWORD* pValue);

  int SetFeature(DWORD Function, DWORD Value);
  int SetFeatureGroup(const DWORD* FeatureAddresses, const DWORD* FeatureValues, DWORD FeatureCount);
  int SetBufferCount(DWORD Value);
  int SetMainReflection(DWORD Value);
  int SetMaxFileSize(DWORD Value);
  int SetPacketSize(DWORD Value);
  int SetFirewireConnectionSpeed(DWORD Value);
  int SetProfileConfig(TProfileConfig Value);
  int SetResolution(DWORD Value);
  int SetProfileContainerSize(unsigned int nWidth, unsigned int nHeight);
  int SetEthernetHeartbeatTimeout(DWORD Value);

  // Register functions
  int RegisterErrorMsg(UINT Msg, HWND hWnd, WPARAM WParam);
  int RegisterCallback(TCallbackType CallbackType, void* pLLTProfileCallback, void* pUserData);

  // Profile transfer functions
  int GetProfile();
  int TransferProfiles(TTransferProfileType TransferProfileType, int nEnable);
  int TransferVideoStream(int TransferVideoType, int nEnable, unsigned int* pWidth, unsigned int* pHeight);
  int MultiShot(unsigned int nCount);
  int GetActualProfile(unsigned char* pBuffer, unsigned int nBuffersize, TProfileConfig ProfileConfig, unsigned int* pLostProfiles);
  int ConvertProfile2Values(const unsigned char* pProfile, unsigned int nResolution, TProfileConfig ProfileConfig, TScannerType ScannerType,
                            unsigned int nReflection, int nConvertToMM, unsigned short* pWidth, unsigned short* pMaximum,
                            unsigned short* pThreshold, double* pX, double* pZ, unsigned int* pM0, unsigned int* pM1);
  int ConvertPartProfile2Values(const unsigned char* pProfile, TPartialProfile* pPartialProfile, TScannerType ScannerType,
                                unsigned int nReflection, int nConvertToMM, unsigned short* pWidth, unsigned short* pMaximum,
                                unsigned short* pThreshold, double* pX, double* pZ, unsigned int* pM0, unsigned int* pM1);
  int SetHoldBuffersForPolling(unsigned int uiHoldBuffersForPolling);
  int GetHoldBuffersForPolling(unsigned int* puiHoldBuffersForPolling);
  int TriggerProfile();
  int TriggerContainer();
  int ContainerTriggerEnable();
  int ContainerTriggerDisable();
  int FlushContainer();

  // Is functions
  int IsInterfaceType(int iInterfaceType);
  DEPRECATED int IsFirewire();
  DEPRECATED int IsSerial();
  int IsTransferingProfiles();

  // PartialProfile functions
  int GetPartialProfileUnitSize(unsigned int* pUnitSizePoint, unsigned int* pUnitSizePointData);
  int GetPartialProfile(TPartialProfile* pPartialProfile);
  int SetPartialProfile(TPartialProfile* pPartialProfile);

  // Timestamp convert functions
  void Timestamp2CmmTriggerAndInCounter(const unsigned char* pTimestamp, unsigned int* pInCounter, int* pCmmTrigger, int* pCmmActive,
                                        unsigned int* pCmmCount);
  void Timestamp2TimeAndCount(const unsigned char* pTimestamp, double* pTimeShutterOpen, double* pTimeShutterClose,
                              unsigned int* pProfileCount);

  // PostProcessing functions
  int ReadPostProcessingParameter(DWORD* pParameter, unsigned int nSize);
  int WritePostProcessingParameter(DWORD* pParameter, unsigned int nSize);
  int ConvertProfile2ModuleResult(const unsigned char* pProfileBuffer, unsigned int nProfileBufferSize, unsigned char* pModuleResultBuffer,
                                  unsigned int nResultBufferSize, TPartialProfile* pPartialProfile = nullptr);

  // File functions
  int LoadProfiles(const char* pFilename, TPartialProfile* pPartialProfile, TProfileConfig* pProfileConfig, TScannerType* pScannerType,
                   DWORD* pRearrengementProfile);
  int SaveProfiles(const char* pFilename, TFileType FileType);
  int LoadProfilesGetPos(unsigned int* pActualPosition, unsigned int* pMaxPosition);
  int LoadProfilesSetPos(unsigned int nNewPosition);

  // Special CMM trigger functions
  int StartTransmissionAndCmmTrigger(DWORD nCmmTrigger, TTransferProfileType TransferProfileType, unsigned int nProfilesForerun,
                                     const char* pFilename, TFileType FileType, unsigned int nTimeout);
  int StopTransmissionAndCmmTrigger(int nCmmTriggerPolarity, unsigned int nTimeout);

  // Converts a error-value in a string
  int TranslateErrorValue(int ErrorValue, char* pString, unsigned int nStringSize);

  // User Mode
  int GetActualUserMode(unsigned int* pActualUserMode, unsigned int* pUserModeCount);
  int ReadWriteUserModes(int nWrite, unsigned int nUserMode);
  int SaveGlobalParameter();

  CFunctions* m_pFunctions;

protected:
  long m_DeviceHandle{0};
};
