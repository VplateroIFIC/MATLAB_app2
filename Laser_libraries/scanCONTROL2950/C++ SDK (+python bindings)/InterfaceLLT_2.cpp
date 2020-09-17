//  InterfaceLLT.cpp: CInterfaceLLT class.
//
//   Copyright 2010
//
//   Sebastian Lueth
//   MICRO-EPSILON Optronic GmbH
//   Lessingstrasse 14
//   01465 Dresden OT Langebrueck
//   Germany

#include "stdafx.h"
#include "InterfaceLLT_2.h"
#include "DllLoader.h"

// constructor of the InterfaceLLT class
// the constructor loads the LLT.dll and request all now supported
// function-pointers so you can easy us the function of the dll
CInterfaceLLT::CFunctions::CFunctions(const char* pDLLName /*= "LLT.dll"*/, bool* pLoadError /*=NULL*/)
{
  if (pLoadError)
    *pLoadError = false;

  m_pDllLoader = new CDllLoader(pDLLName, pLoadError);

  // Instance functions
  CreateLLTDevice = reinterpret_cast<decltype(&s_CreateLLTDevice)>(m_pDllLoader->GetFunction("s_CreateLLTDevice"));
  CreateLLTFirewire = reinterpret_cast<decltype(&s_CreateLLTFirewire)>(m_pDllLoader->GetFunction("s_CreateLLTFirewire"));

  CreateLLTSerial = reinterpret_cast<decltype(&s_CreateLLTSerial)>(m_pDllLoader->GetFunction("s_CreateLLTSerial"));
  GetInterfaceType = reinterpret_cast<decltype(&s_GetInterfaceType)>(m_pDllLoader->GetFunction("s_GetInterfaceType"));
  DelDevice = reinterpret_cast<decltype(&s_DelDevice)>(m_pDllLoader->GetFunction("s_DelDevice"));

  // Connect functions
  Connect = reinterpret_cast<decltype(&s_Connect)>(m_pDllLoader->GetFunction("s_Connect"));
  Disconnect = reinterpret_cast<decltype(&s_Disconnect)>(m_pDllLoader->GetFunction("s_Disconnect"));

  // Read/Write config functions
  ExportLLTConfig = reinterpret_cast<decltype(&s_ExportLLTConfig)>(m_pDllLoader->GetFunction("s_ExportLLTConfig"));
  ExportLLTConfigString = reinterpret_cast<decltype(&s_ExportLLTConfigString)>(m_pDllLoader->GetFunction("s_ExportLLTConfigString"));
  ImportLLTConfig = reinterpret_cast<decltype(&s_ImportLLTConfig)>(m_pDllLoader->GetFunction("s_ImportLLTConfig"));
  ImportLLTConfigString = reinterpret_cast<decltype(&s_ImportLLTConfigString)>(m_pDllLoader->GetFunction("s_ImportLLTConfigString"));

  // Device interface functions
  GetDeviceInterfaces = reinterpret_cast<decltype(&s_GetDeviceInterfaces)>(m_pDllLoader->GetFunction("s_GetDeviceInterfaces"));

  GetDeviceInterfacesFast = reinterpret_cast<decltype(&s_GetDeviceInterfacesFast)>(m_pDllLoader->GetFunction("s_GetDeviceInterfacesFast"));
  SetDeviceInterface = reinterpret_cast<decltype(&s_SetDeviceInterface)>(m_pDllLoader->GetFunction("s_SetDeviceInterface"));
  GetDiscoveryBroadcastTarget
      = reinterpret_cast<decltype(&s_GetDiscoveryBroadcastTarget)>(m_pDllLoader->GetFunction("s_GetDiscoveryBroadcastTarget"));
  SetDiscoveryBroadcastTarget
      = reinterpret_cast<decltype(&s_SetDiscoveryBroadcastTarget)>(m_pDllLoader->GetFunction("s_SetDiscoveryBroadcastTarget"));

  // scanCONTROL indentification functions
  GetDeviceName = reinterpret_cast<decltype(&s_GetDeviceName)>(m_pDllLoader->GetFunction("s_GetDeviceName"));
  GetSerialNumber = reinterpret_cast<decltype(&s_GetSerialNumber)>(m_pDllLoader->GetFunction("s_GetSerialNumber"));
  GetLLTVersions = reinterpret_cast<decltype(&s_GetLLTVersions)>(m_pDllLoader->GetFunction("s_GetLLTVersions"));
  GetLLTType = reinterpret_cast<decltype(&s_GetLLTType)>(m_pDllLoader->GetFunction("s_GetLLTType"));

  // Get functions
  GetMinMaxPacketSize = reinterpret_cast<decltype(&s_GetMinMaxPacketSize)>(m_pDllLoader->GetFunction("s_GetMinMaxPacketSize"));
  GetResolutions = reinterpret_cast<decltype(&s_GetResolutions)>(m_pDllLoader->GetFunction("s_GetResolutions"));

  GetFeature = reinterpret_cast<decltype(&s_GetFeature)>(m_pDllLoader->GetFunction("s_GetFeature"));
  GetBufferCount = reinterpret_cast<decltype(&s_GetBufferCount)>(m_pDllLoader->GetFunction("s_GetBufferCount"));
  GetMainReflection = reinterpret_cast<decltype(&s_GetMainReflection)>(m_pDllLoader->GetFunction("s_GetMainReflection"));
  GetMaxFileSize = reinterpret_cast<decltype(&s_GetMaxFileSize)>(m_pDllLoader->GetFunction("s_GetMaxFileSize"));
  GetPacketSize = reinterpret_cast<decltype(&s_GetPacketSize)>(m_pDllLoader->GetFunction("s_GetPacketSize"));
  GetFirewireConnectionSpeed
      = reinterpret_cast<decltype(&s_GetFirewireConnectionSpeed)>(m_pDllLoader->GetFunction("s_GetFirewireConnectionSpeed"));
  GetProfileConfig = reinterpret_cast<decltype(&s_GetProfileConfig)>(m_pDllLoader->GetFunction("s_GetProfileConfig"));
  GetResolution = reinterpret_cast<decltype(&s_GetResolution)>(m_pDllLoader->GetFunction("s_GetResolution"));
  GetProfileContainerSize = reinterpret_cast<decltype(&s_GetProfileContainerSize)>(m_pDllLoader->GetFunction("s_GetProfileContainerSize"));
  GetMaxProfileContainerSize
      = reinterpret_cast<decltype(&s_GetMaxProfileContainerSize)>(m_pDllLoader->GetFunction("s_GetMaxProfileContainerSize"));
  GetEthernetHeartbeatTimeout
      = reinterpret_cast<decltype(&s_GetEthernetHeartbeatTimeout)>(m_pDllLoader->GetFunction("s_GetEthernetHeartbeatTimeout"));

  // Set functions
  SetFeature = reinterpret_cast<decltype(&s_SetFeature)>(m_pDllLoader->GetFunction("s_SetFeature"));
  SetFeatureGroup = reinterpret_cast<decltype(&s_SetFeatureGroup)>(m_pDllLoader->GetFunction("s_SetFeatureGroup"));
  SetBufferCount = reinterpret_cast<decltype(&s_SetBufferCount)>(m_pDllLoader->GetFunction("s_SetBufferCount"));
  SetMainReflection = reinterpret_cast<decltype(&s_SetMainReflection)>(m_pDllLoader->GetFunction("s_SetMainReflection"));
  SetMaxFileSize = reinterpret_cast<decltype(&s_SetMaxFileSize)>(m_pDllLoader->GetFunction("s_SetMaxFileSize"));
  SetPacketSize = reinterpret_cast<decltype(&s_SetPacketSize)>(m_pDllLoader->GetFunction("s_SetPacketSize"));
  SetFirewireConnectionSpeed
      = reinterpret_cast<decltype(&s_SetFirewireConnectionSpeed)>(m_pDllLoader->GetFunction("s_SetFirewireConnectionSpeed"));
  SetProfileConfig = reinterpret_cast<decltype(&s_SetProfileConfig)>(m_pDllLoader->GetFunction("s_SetProfileConfig"));
  SetResolution = reinterpret_cast<decltype(&s_SetResolution)>(m_pDllLoader->GetFunction("s_SetResolution"));
  SetProfileContainerSize = reinterpret_cast<decltype(&s_SetProfileContainerSize)>(m_pDllLoader->GetFunction("s_SetProfileContainerSize"));
  SetEthernetHeartbeatTimeout
      = reinterpret_cast<decltype(&s_SetEthernetHeartbeatTimeout)>(m_pDllLoader->GetFunction("s_SetEthernetHeartbeatTimeout"));

  // Register functions
  RegisterCallback = reinterpret_cast<decltype(&s_RegisterCallback)>(m_pDllLoader->GetFunction("s_RegisterCallback"));
  RegisterErrorMsg = reinterpret_cast<decltype(&s_RegisterErrorMsg)>(m_pDllLoader->GetFunction("s_RegisterErrorMsg"));

  // Profile transfer functions
  TransferProfiles = reinterpret_cast<decltype(&s_TransferProfiles)>(m_pDllLoader->GetFunction("s_TransferProfiles"));
  TransferVideoStream = reinterpret_cast<decltype(&s_TransferVideoStream)>(m_pDllLoader->GetFunction("s_TransferVideoStream"));
  GetProfile = reinterpret_cast<decltype(&s_GetProfile)>(m_pDllLoader->GetFunction("s_GetProfile"));
  MultiShot = reinterpret_cast<decltype(&s_MultiShot)>(m_pDllLoader->GetFunction("s_MultiShot"));
  GetActualProfile = reinterpret_cast<decltype(&s_GetActualProfile)>(m_pDllLoader->GetFunction("s_GetActualProfile"));
  ConvertProfile2Values = reinterpret_cast<decltype(&s_ConvertProfile2Values)>(m_pDllLoader->GetFunction("s_ConvertProfile2Values"));
  ConvertPartProfile2Values
      = reinterpret_cast<decltype(&s_ConvertPartProfile2Values)>(m_pDllLoader->GetFunction("s_ConvertPartProfile2Values"));
  SetHoldBuffersForPolling
      = reinterpret_cast<decltype(&s_SetHoldBuffersForPolling)>(m_pDllLoader->GetFunction("s_SetHoldBuffersForPolling"));
  GetHoldBuffersForPolling
      = reinterpret_cast<decltype(&s_GetHoldBuffersForPolling)>(m_pDllLoader->GetFunction("s_GetHoldBuffersForPolling"));
  TriggerProfile = reinterpret_cast<decltype(&s_TriggerProfile)>(m_pDllLoader->GetFunction("s_TriggerProfile"));
  TriggerContainer = reinterpret_cast<decltype(&s_TriggerContainer)>(m_pDllLoader->GetFunction("s_TriggerContainer"));
  ContainerTriggerEnable = reinterpret_cast<decltype(&s_ContainerTriggerEnable)>(m_pDllLoader->GetFunction("s_ContainerTriggerEnable"));
  ContainerTriggerDisable = reinterpret_cast<decltype(&s_ContainerTriggerDisable)>(m_pDllLoader->GetFunction("s_ContainerTriggerDisable"));
  FlushContainer = reinterpret_cast<decltype(&s_FlushContainer)>(m_pDllLoader->GetFunction("s_FlushContainer"));

  // Is functions
  IsInterfaceType = reinterpret_cast<decltype(&s_IsInterfaceType)>(m_pDllLoader->GetFunction("s_IsInterfaceType"));
  IsFirewire = reinterpret_cast<decltype(&s_IsFirewire)>(m_pDllLoader->GetFunction("s_IsFirewire"));
  IsSerial = reinterpret_cast<decltype(&s_IsSerial)>(m_pDllLoader->GetFunction("s_IsSerial"));
  IsTransferingProfiles = reinterpret_cast<decltype(&s_IsTransferingProfiles)>(m_pDllLoader->GetFunction("s_IsTransferingProfiles"));

  // PartialProfile functions
  GetPartialProfileUnitSize
      = reinterpret_cast<decltype(&s_GetPartialProfileUnitSize)>(m_pDllLoader->GetFunction("s_GetPartialProfileUnitSize"));
  GetPartialProfile = reinterpret_cast<decltype(&s_GetPartialProfile)>(m_pDllLoader->GetFunction("s_GetPartialProfile"));
  SetPartialProfile = reinterpret_cast<decltype(&s_SetPartialProfile)>(m_pDllLoader->GetFunction("s_SetPartialProfile"));

  // Timestamp convert functions
  Timestamp2CmmTriggerAndInCounter
      = reinterpret_cast<decltype(&s_Timestamp2CmmTriggerAndInCounter)>(m_pDllLoader->GetFunction("s_Timestamp2CmmTriggerAndInCounter"));
  Timestamp2TimeAndCount = reinterpret_cast<decltype(&s_Timestamp2TimeAndCount)>(m_pDllLoader->GetFunction("s_Timestamp2TimeAndCount"));

  // PostProcessing functions
  ReadPostProcessingParameter
      = reinterpret_cast<decltype(&s_ReadPostProcessingParameter)>(m_pDllLoader->GetFunction("s_ReadPostProcessingParameter"));
  WritePostProcessingParameter
      = reinterpret_cast<decltype(&s_WritePostProcessingParameter)>(m_pDllLoader->GetFunction("s_WritePostProcessingParameter"));
  ConvertProfile2ModuleResult
      = reinterpret_cast<decltype(&s_ConvertProfile2ModuleResult)>(m_pDllLoader->GetFunction("s_ConvertProfile2ModuleResult"));

  // Load/Save functions
  LoadProfiles = reinterpret_cast<decltype(&s_LoadProfiles)>(m_pDllLoader->GetFunction("s_LoadProfiles"));
  SaveProfiles = reinterpret_cast<decltype(&s_SaveProfiles)>(m_pDllLoader->GetFunction("s_SaveProfiles"));
  LoadProfilesGetPos = reinterpret_cast<decltype(&s_LoadProfilesGetPos)>(m_pDllLoader->GetFunction("s_LoadProfilesGetPos"));
  LoadProfilesSetPos = reinterpret_cast<decltype(&s_LoadProfilesSetPos)>(m_pDllLoader->GetFunction("s_LoadProfilesSetPos"));

  // Special CMM trigger functions
  StartTransmissionAndCmmTrigger
      = reinterpret_cast<decltype(&s_StartTransmissionAndCmmTrigger)>(m_pDllLoader->GetFunction("s_StartTransmissionAndCmmTrigger"));
  StopTransmissionAndCmmTrigger
      = reinterpret_cast<decltype(&s_StopTransmissionAndCmmTrigger)>(m_pDllLoader->GetFunction("s_StopTransmissionAndCmmTrigger"));

  // Converts a error-value in a string
  TranslateErrorValue = reinterpret_cast<decltype(&s_TranslateErrorValue)>(m_pDllLoader->GetFunction("s_TranslateErrorValue"));

  // User mode
  GetActualUserMode = reinterpret_cast<decltype(&s_GetActualUserMode)>(m_pDllLoader->GetFunction("s_GetActualUserMode"));
  ReadWriteUserModes = reinterpret_cast<decltype(&s_ReadWriteUserModes)>(m_pDllLoader->GetFunction("s_ReadWriteUserModes"));
  SaveGlobalParameter = reinterpret_cast<decltype(&s_SaveGlobalParameter)>(m_pDllLoader->GetFunction("s_SaveGlobalParameter"));
}

// destructor of the InterfaceLLT class
// the destructor also unload the dll
CInterfaceLLT::CFunctions::~CFunctions()
{
  delete m_pDllLoader;
  Sleep(100);
  // the sleep in nessecary, because windows  needs a littel bit time to unload the dll
  // and if you unload and load the dll in a short time there were errors
}

CInterfaceLLT::CInterfaceLLT(const char* pDLLName /* = "LLT.dll"*/, bool* pLoadError /*=NULL*/)
{
  m_pFunctions = new CFunctions(pDLLName, pLoadError);
}

CInterfaceLLT::~CInterfaceLLT()
{
  if (m_pFunctions->DelDevice != nullptr)
    m_pFunctions->DelDevice(m_DeviceHandle);
  delete m_pFunctions;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// Instance functions

int
CInterfaceLLT::CreateLLTDevice(TInterfaceType iInterfaceType)
{
  if (m_pFunctions->CreateLLTDevice != nullptr)
  {
    m_DeviceHandle = m_pFunctions->CreateLLTDevice(iInterfaceType);
    if (m_DeviceHandle != 0 || m_DeviceHandle != 0xffffffff)
      return GENERAL_FUNCTION_OK;
  }
  return GENERAL_FUNCTION_NOT_AVAILABLE;
}

int
CInterfaceLLT::CreateLLTFirewire()
{
  if (m_pFunctions->CreateLLTFirewire != nullptr)
  {
    m_DeviceHandle = m_pFunctions->CreateLLTFirewire();
    if (m_DeviceHandle != 0 || m_DeviceHandle != 0xffffffff)
      return GENERAL_FUNCTION_OK;
  }
  return GENERAL_FUNCTION_NOT_AVAILABLE;
}

int
CInterfaceLLT::CreateLLTSerial()
{
  if (m_pFunctions->CreateLLTSerial != nullptr)
  {
    m_DeviceHandle = m_pFunctions->CreateLLTSerial();
    if (m_DeviceHandle != 0 || m_DeviceHandle != 0xffffffff)
      return GENERAL_FUNCTION_OK;
  }
  return GENERAL_FUNCTION_NOT_AVAILABLE;
}

int
CInterfaceLLT::GetInterfaceType()
{
  if (m_pFunctions->GetInterfaceType != nullptr)
    return m_pFunctions->GetInterfaceType(m_DeviceHandle);

  return GENERAL_FUNCTION_NOT_AVAILABLE;
}

int
CInterfaceLLT::DelDevice()
{
  return m_pFunctions->DelDevice(m_DeviceHandle);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Connect functions

int
CInterfaceLLT::Connect()
{
  return m_pFunctions->Connect(m_DeviceHandle);
}

int
CInterfaceLLT::Disconnect()
{
  return m_pFunctions->Disconnect(m_DeviceHandle);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Read/Write config functions
int
CInterfaceLLT::ExportLLTConfig(const char* pFileName)
{
  return m_pFunctions->ExportLLTConfig(m_DeviceHandle, pFileName);
}

int
CInterfaceLLT::ExportLLTConfigString(char* configData, int configDataSize)
{
  return m_pFunctions->ExportLLTConfigString(m_DeviceHandle, configData, configDataSize);
}

int
CInterfaceLLT::ImportLLTConfig(const char* pFileName, bool ignoreCalibration)
{
  return m_pFunctions->ImportLLTConfig(m_DeviceHandle, pFileName, ignoreCalibration);
}

int
CInterfaceLLT::ImportLLTConfigString(const char* configData, int configDataSize, bool ignoreCalibration)
{
  return m_pFunctions->ImportLLTConfigString(m_DeviceHandle, configData, configDataSize, ignoreCalibration);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Device interface functions

int
CInterfaceLLT::GetDeviceInterfaces(unsigned int* pInterfaces, unsigned int nSize)
{
  return m_pFunctions->GetDeviceInterfaces(m_DeviceHandle, pInterfaces, nSize);
}

int
CInterfaceLLT::GetDeviceInterfacesFast(unsigned int* pInterfaces, unsigned int nSize)
{
  return m_pFunctions->GetDeviceInterfacesFast(m_DeviceHandle, pInterfaces, nSize);
}

int
CInterfaceLLT::SetDeviceInterface(unsigned int nInterface, int nAdditional)
{
  return m_pFunctions->SetDeviceInterface(m_DeviceHandle, nInterface, nAdditional);
}

unsigned
CInterfaceLLT::GetDiscoveryBroadcastTarget()
{
  if (m_pFunctions->GetDiscoveryBroadcastTarget != nullptr)
  {
    return m_pFunctions->GetDiscoveryBroadcastTarget(m_DeviceHandle);
  }
  return 0;
}

int
CInterfaceLLT::SetDiscoveryBroadcastTarget(unsigned int nNetworkAddress, unsigned int nSubnetMask)
{
  if (m_pFunctions->SetDiscoveryBroadcastTarget != nullptr)
  {
    return m_pFunctions->SetDiscoveryBroadcastTarget(m_DeviceHandle, nNetworkAddress, nSubnetMask);
  }
  return GENERAL_FUNCTION_NOT_AVAILABLE;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// LLT indentification functions

int
CInterfaceLLT::GetDeviceName(char* pDevName, unsigned int nDevNameSize, char* pVenName, unsigned int nVenNameSize)
{
  return m_pFunctions->GetDeviceName(m_DeviceHandle, pDevName, nDevNameSize, pVenName, nVenNameSize);
}

int
CInterfaceLLT::GetSerialNumber(char* pSerialNumber, unsigned int nSerialNumberSize)
{
  return m_pFunctions->GetSerialNumber(m_DeviceHandle, pSerialNumber, nSerialNumberSize);
}

int
CInterfaceLLT::GetLLTVersions(unsigned int* pDSP, unsigned int* pFPGA1, unsigned int* pFPGA2)
{
  return m_pFunctions->GetLLTVersions(m_DeviceHandle, pDSP, pFPGA1, pFPGA2);
}

int
CInterfaceLLT::GetLLTType(TScannerType* pScannerType)
{
  return m_pFunctions->GetLLTType(m_DeviceHandle, pScannerType);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// Get functions

int
CInterfaceLLT::GetMinMaxPacketSize(unsigned long* pMinPacketSize, unsigned long* pMaxPacketSize)
{
  return m_pFunctions->GetMinMaxPacketSize(m_DeviceHandle, pMinPacketSize, pMaxPacketSize);
}

int
CInterfaceLLT::GetResolutions(DWORD* pValue, unsigned int nSize)
{
  return m_pFunctions->GetResolutions(m_DeviceHandle, pValue, nSize);
}

int
CInterfaceLLT::GetFeature(DWORD Function, DWORD* pValue)
{
  return m_pFunctions->GetFeature(m_DeviceHandle, Function, pValue);
}

int
CInterfaceLLT::GetBufferCount(DWORD* pValue)
{
  return m_pFunctions->GetBufferCount(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetMainReflection(DWORD* pValue)
{
  return m_pFunctions->GetMainReflection(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetMaxFileSize(DWORD* pValue)
{
  return m_pFunctions->GetMaxFileSize(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetPacketSize(DWORD* pValue)
{
  return m_pFunctions->GetPacketSize(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetFirewireConnectionSpeed(DWORD* pValue)
{
  return m_pFunctions->GetFirewireConnectionSpeed(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetProfileConfig(TProfileConfig* pValue)
{
  return m_pFunctions->GetProfileConfig(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetResolution(DWORD* pValue)
{
  return m_pFunctions->GetResolution(m_DeviceHandle, pValue);
}

int
CInterfaceLLT::GetProfileContainerSize(unsigned int* pWidth, unsigned int* pHeight)
{
  return m_pFunctions->GetProfileContainerSize(m_DeviceHandle, pWidth, pHeight);
}

int
CInterfaceLLT::GetMaxProfileContainerSize(unsigned int* pMaxWidth, unsigned int* pMaxHeight)
{
  return m_pFunctions->GetMaxProfileContainerSize(m_DeviceHandle, pMaxWidth, pMaxHeight);
}

int
CInterfaceLLT::GetEthernetHeartbeatTimeout(DWORD* pValue)
{
  return m_pFunctions->GetEthernetHeartbeatTimeout(m_DeviceHandle, pValue);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Set functions

int
CInterfaceLLT::SetFeature(DWORD Function, DWORD Value)
{
  return m_pFunctions->SetFeature(m_DeviceHandle, Function, Value);
}

int
CInterfaceLLT::SetFeatureGroup(const DWORD* FeatureAddresses, const DWORD* FeatureValues, DWORD FeatureCount)
{
  return m_pFunctions->SetFeatureGroup(m_DeviceHandle, FeatureAddresses, FeatureValues, FeatureCount);
}

int
CInterfaceLLT::SetBufferCount(DWORD Value)
{
  return m_pFunctions->SetBufferCount(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetMainReflection(DWORD Value)
{
  return m_pFunctions->SetMainReflection(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetMaxFileSize(DWORD Value)
{
  return m_pFunctions->SetMaxFileSize(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetPacketSize(DWORD Value)
{
  return m_pFunctions->SetPacketSize(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetFirewireConnectionSpeed(DWORD Value)
{
  return m_pFunctions->SetFirewireConnectionSpeed(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetProfileConfig(TProfileConfig Value)
{
  return m_pFunctions->SetProfileConfig(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetResolution(DWORD Value)
{
  return m_pFunctions->SetResolution(m_DeviceHandle, Value);
}

int
CInterfaceLLT::SetProfileContainerSize(unsigned int nWidth, unsigned int nHeight)
{
  return m_pFunctions->SetProfileContainerSize(m_DeviceHandle, nWidth, nHeight);
}

int
CInterfaceLLT::SetEthernetHeartbeatTimeout(DWORD Value)
{
  return m_pFunctions->SetEthernetHeartbeatTimeout(m_DeviceHandle, Value);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Register functions

int
CInterfaceLLT::RegisterCallback(TCallbackType CallbackType, void* pLLTProfileCallback, void* pUserData)
{
  return m_pFunctions->RegisterCallback(m_DeviceHandle, CallbackType, pLLTProfileCallback, pUserData);
}

int
CInterfaceLLT::RegisterErrorMsg(UINT Msg, HWND hWnd, WPARAM WParam)
{
  return m_pFunctions->RegisterErrorMsg(m_DeviceHandle, Msg, hWnd, WParam);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Profile transfer functions

int
CInterfaceLLT::GetProfile()
{
  return m_pFunctions->GetProfile(m_DeviceHandle);
}

int
CInterfaceLLT::TransferProfiles(TTransferProfileType TransferProfileType, int nEnable)
{
  return m_pFunctions->TransferProfiles(m_DeviceHandle, TransferProfileType, nEnable);
}

int
CInterfaceLLT::TransferVideoStream(int TransferVideoType, int nEnable, unsigned int* pWidth, unsigned int* pHeight)
{
  return m_pFunctions->TransferVideoStream(m_DeviceHandle, TransferVideoType, nEnable, pWidth, pHeight);
}

int
CInterfaceLLT::MultiShot(unsigned int nCount)
{
  return m_pFunctions->MultiShot(m_DeviceHandle, nCount);
}

int
CInterfaceLLT::GetActualProfile(unsigned char* pBuffer, unsigned int nBuffersize, TProfileConfig ProfileConfig, unsigned int* pLostProfiles)
{
  return m_pFunctions->GetActualProfile(m_DeviceHandle, pBuffer, nBuffersize, ProfileConfig, pLostProfiles);
}

int
CInterfaceLLT::ConvertProfile2Values(const unsigned char* pProfile, unsigned int nResolution, TProfileConfig ProfileConfig,
                                     TScannerType ScannerType, unsigned int nReflection, int nConvertToMM, unsigned short* pWidth,
                                     unsigned short* pMaximum, unsigned short* pThreshold, double* pX, double* pZ, unsigned int* pM0,
                                     unsigned int* pM1)
{
  return m_pFunctions->ConvertProfile2Values(m_DeviceHandle, pProfile, nResolution, ProfileConfig, ScannerType, nReflection, nConvertToMM,
                                             pWidth, pMaximum, pThreshold, pX, pZ, pM0, pM1);
}

int
CInterfaceLLT::ConvertPartProfile2Values(const unsigned char* pProfile, TPartialProfile* pPartialProfile, TScannerType ScannerType,
                                         unsigned int nReflection, int nConvertToMM, unsigned short* pWidth, unsigned short* pMaximum,
                                         unsigned short* pThreshold, double* pX, double* pZ, unsigned int* pM0, unsigned int* pM1)
{
  return m_pFunctions->ConvertPartProfile2Values(m_DeviceHandle, pProfile, pPartialProfile, ScannerType, nReflection, nConvertToMM, pWidth,
                                                 pMaximum, pThreshold, pX, pZ, pM0, pM1);
}

int
CInterfaceLLT::SetHoldBuffersForPolling(unsigned int uiHoldBuffersForPolling)
{
  return m_pFunctions->SetHoldBuffersForPolling(m_DeviceHandle, uiHoldBuffersForPolling);
}

int
CInterfaceLLT::GetHoldBuffersForPolling(unsigned int* puiHoldBuffersForPolling)
{
  return m_pFunctions->GetHoldBuffersForPolling(m_DeviceHandle, puiHoldBuffersForPolling);
}

int
CInterfaceLLT::TriggerProfile(void)
{
  return m_pFunctions->TriggerProfile(m_DeviceHandle);
}

int
CInterfaceLLT::TriggerContainer()
{
  return m_pFunctions->TriggerContainer(m_DeviceHandle);
}

int
CInterfaceLLT::ContainerTriggerEnable()
{
  return m_pFunctions->ContainerTriggerEnable(m_DeviceHandle);
}

int
CInterfaceLLT::ContainerTriggerDisable()
{
  return m_pFunctions->ContainerTriggerDisable(m_DeviceHandle);
}

int
CInterfaceLLT::FlushContainer()
{
  return m_pFunctions->FlushContainer(m_DeviceHandle);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Is functions

int
CInterfaceLLT::IsInterfaceType(int iInterfaceType)
{
  if (m_pFunctions->IsInterfaceType)
  {
    return m_pFunctions->IsInterfaceType(m_DeviceHandle, iInterfaceType);
  }
  return 0;
}

int
CInterfaceLLT::IsFirewire()
{
  return m_pFunctions->IsFirewire(m_DeviceHandle);
}

int
CInterfaceLLT::IsSerial()
{
  return m_pFunctions->IsSerial(m_DeviceHandle);
}

int
CInterfaceLLT::IsTransferingProfiles()
{
  return m_pFunctions->IsTransferingProfiles(m_DeviceHandle);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// PartialProfile functions

int
CInterfaceLLT::GetPartialProfileUnitSize(unsigned int* pUnitSizePoint, unsigned int* pUnitSizePointData)
{
  return m_pFunctions->GetPartialProfileUnitSize(m_DeviceHandle, pUnitSizePoint, pUnitSizePointData);
}

int
CInterfaceLLT::GetPartialProfile(TPartialProfile* pPartialProfile)
{
  return m_pFunctions->GetPartialProfile(m_DeviceHandle, pPartialProfile);
}

int
CInterfaceLLT::SetPartialProfile(TPartialProfile* pPartialProfile)
{
  return m_pFunctions->SetPartialProfile(m_DeviceHandle, pPartialProfile);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Timestamp convert functions

void
CInterfaceLLT::Timestamp2CmmTriggerAndInCounter(const unsigned char* pTimestamp, unsigned int* pInCounter, int* pCmmTrigger,
                                                int* pCmmActive, unsigned int* pCmmCount)
{
  m_pFunctions->Timestamp2CmmTriggerAndInCounter(pTimestamp, pInCounter, pCmmTrigger, pCmmActive, pCmmCount);
}

void
CInterfaceLLT::Timestamp2TimeAndCount(const unsigned char* pTimestamp, double* pTimeShutterOpen, double* pTimeShutterClose,
                                      unsigned int* pProfileCount)
{
  m_pFunctions->Timestamp2TimeAndCount(pTimestamp, pTimeShutterOpen, pTimeShutterClose, pProfileCount);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// PostProcessing functions

int
CInterfaceLLT::ReadPostProcessingParameter(DWORD* pParameter, unsigned int nSize)
{
  return m_pFunctions->ReadPostProcessingParameter(m_DeviceHandle, pParameter, nSize);
}

int
CInterfaceLLT::WritePostProcessingParameter(DWORD* pParameter, unsigned int nSize)
{
  return m_pFunctions->WritePostProcessingParameter(m_DeviceHandle, pParameter, nSize);
}

int
CInterfaceLLT::ConvertProfile2ModuleResult(const unsigned char* pProfileBuffer, unsigned int nProfileBufferSize,
                                           unsigned char* pModuleResultBuffer, unsigned int nResultBufferSize,
                                           TPartialProfile* pPartialProfile /* = NULL*/)
{
  return m_pFunctions->ConvertProfile2ModuleResult(m_DeviceHandle, pProfileBuffer, nProfileBufferSize, pModuleResultBuffer,
                                                   nResultBufferSize, pPartialProfile);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// File functions

int
CInterfaceLLT::LoadProfiles(const char* pFilename, TPartialProfile* pPartialProfile, TProfileConfig* pProfileConfig,
                            TScannerType* pScannerType, DWORD* pRearrengementProfile)
{
  return m_pFunctions->LoadProfiles(m_DeviceHandle, pFilename, pPartialProfile, pProfileConfig, pScannerType, pRearrengementProfile);
}

int
CInterfaceLLT::SaveProfiles(const char* pFilename, TFileType FileType)
{
  return m_pFunctions->SaveProfiles(m_DeviceHandle, pFilename, FileType);
}

int
CInterfaceLLT::LoadProfilesGetPos(unsigned int* pActualPosition, unsigned int* pMaxPosition)
{
  return m_pFunctions->LoadProfilesGetPos(m_DeviceHandle, pActualPosition, pMaxPosition);
}

int
CInterfaceLLT::LoadProfilesSetPos(unsigned int nNewPosition)
{
  return m_pFunctions->LoadProfilesSetPos(m_DeviceHandle, nNewPosition);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Special CMM trigger functions

int
CInterfaceLLT::StartTransmissionAndCmmTrigger(DWORD nCmmTrigger, TTransferProfileType TransferProfileType, unsigned int nProfilesForerun,
                                              const char* pFilename, TFileType FileType, unsigned int nTimeout)
{
  return m_pFunctions->StartTransmissionAndCmmTrigger(m_DeviceHandle, nCmmTrigger, TransferProfileType, nProfilesForerun, pFilename,
                                                      FileType, nTimeout);
}

int
CInterfaceLLT::StopTransmissionAndCmmTrigger(int nCmmTriggerPolarity, unsigned int nTimeout)
{
  return m_pFunctions->StopTransmissionAndCmmTrigger(m_DeviceHandle, nCmmTriggerPolarity, nTimeout);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Converts a error-value in a string

int
CInterfaceLLT::TranslateErrorValue(int ErrorValue, char* pString, unsigned int nStringSize)
{
  return m_pFunctions->TranslateErrorValue(m_DeviceHandle, ErrorValue, pString, nStringSize);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// User Mode
int
CInterfaceLLT::GetActualUserMode(unsigned int* pActualUserMode, unsigned int* pUserModeCount)
{
  return m_pFunctions->GetActualUserMode(m_DeviceHandle, pActualUserMode, pUserModeCount);
}

int
CInterfaceLLT::ReadWriteUserModes(int nWrite, unsigned int nUserMode)
{
  return m_pFunctions->ReadWriteUserModes(m_DeviceHandle, nWrite, nUserMode);
}

int
CInterfaceLLT::SaveGlobalParameter(void)
{
  return m_pFunctions->SaveGlobalParameter(m_DeviceHandle);
}
