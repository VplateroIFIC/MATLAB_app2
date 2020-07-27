#include "stdafx.h"
#include <windows.h>
#include <conio.h> // _kbhit
#include <stdlib.h> // _countof
#include <tchar.h> // _T, _tprintf
#include "../../MEDAQLib.h" // MEDAQLib.h must be included to know it's functions
#pragma comment (lib, "../../Release/MEDAQLib.lib") // MEDAQLib.lib must be imported to call it's functions

bool KeyPressed()
	{
	if (_kbhit())
		{
		_getch();
		return true;
		}
	return false;
	}

bool CheckError (int inst, ERR_CODE errorCode)
	{
	if (errorCode==ERR_NOERROR)
		return true;
	TCHAR errText[1024];
	GetError (inst, errText, _countof (errText));
	if (*errText)
		printf (_T("%s\n"), errText);
	else
		printf (_T("Error %d\n"), errorCode);
	return false;
	}

bool WriteError (ERR_CODE errorCode, LPCTSTR paramName)
	{
	if (errorCode==ERR_NOERROR)
		return true;
	_tprintf (_T("Error reading %s: %d\n"), paramName, errorCode);
	return false;
	}

bool ActivateLog (int inst)
	{
	if (!CheckError (inst, EnableLogging (inst, true, 31, 127, _T(".\\SensorLog.txt"), true, false, 0))) return false;
	return true;
	}

LPCTSTR ToString (bool bVal)
	{
	return bVal ? _T("true") : _T("false");
	}

bool GetStringParam (int inst, LPCTSTR paramName, LPTSTR buf, DWORD &len, bool checkErr= true)
	{
	ERR_CODE err= GetParameterString (inst, paramName, buf, &len);
	if (err!=ERR_NOERROR)
		{
		if (checkErr)
			return WriteError (err, paramName);
		else 
			return false;
		}
	return true;
	}

bool PrintStringParam (int inst, LPCTSTR paramName, bool checkErr= true)
	{
	TCHAR sBuf[1024]= _T("");
	DWORD len= _countof (sBuf);
	if (!GetStringParam (inst, paramName, sBuf, len, checkErr))
		return false;
	_tprintf (_T("%s [%d]: '%s', "), paramName, static_cast<int>(len), sBuf);
	return true;
	}

bool GetIntParam (int inst, LPCTSTR paramName, int &value, bool checkErr= true)
	{
	ERR_CODE err= GetParameterInt (inst, paramName, &value);
	if (err!=ERR_NOERROR)
		{
		if (checkErr)
			return WriteError (err, paramName);
		else 
			return false;
		}
	return true;
	}

bool PrintIntParam (int inst, LPCTSTR paramName, bool checkErr= true)
	{
	int iVal= 0;
	if (!GetIntParam (inst, paramName, iVal, checkErr))
		return false;
	_tprintf (_T("%s: %d, "), paramName, iVal);
	return true;
	}

bool SensorFinder (int inst, int sensor, bool findSimilarSensor, LPTSTR firstUUID, DWORD len)
	{
	if (firstUUID)
		*firstUUID= '\0';
	_tprintf (_T("SensorFinder (sensor= %d, findSimilarSensor= %s)\n  "), sensor, ToString (findSimilarSensor));
	if (!CheckError (inst, SetParameterInt (inst, _T("IP_FindSimilarSensor"), findSimilarSensor)))       return false;
	if (!CheckError (inst, SetIntExecSCmd  (inst, _T("Start_FindSensor"), _T("IP_SensorType"), sensor))) return false;
	double progress= 0;
	_tprintf (_T("Progress:   0.0%%"));
	do
		{
		Sleep (100);
		if (!CheckError (inst, ExecSCmdGetDouble (inst, _T("Get_FindSensorProgress"), _T("IA_Progress"), &progress))) return false;
		_tprintf (_T("\x8\x8\x8\x8\x8\x8%5.1f%%"), progress);
		} while (progress<100);
	int found, sensorType, interfaceIdx;
	if (!CheckError (inst, GetParameterInt (inst, _T("IA_Found"), &found)))                        return false;
	_tprintf (_T("\n  "));
	char sTypeName[1024], ifName[1024];
	DWORD sLen;
	for (int i=0 ; i<found ; i++)
		{
		if (!CheckError (inst, SetIntExecSCmd  (inst, _T("Get_FoundSensor"), _T("IP_Index"), i)))    return false;
		if (!CheckError (inst, GetParameterInt (inst, _T("IP_SensorType"),   &sensorType)))          return false;
		sLen= _countof (sTypeName);
		if (!CheckError (inst, GetParameterString (inst, _T("IP_SensorTypeName"), sTypeName, &sLen))) return false;
		if (!CheckError (inst, GetParameterInt (inst, _T("IP_InterfaceIdx"), &interfaceIdx)))        return false;
		sLen= _countof (ifName);
		if (!CheckError (inst, GetParameterString (inst, _T("IP_Interface"), ifName, &sLen)))         return false;
		_tprintf (_T("IP_Index: %d, SensorType: %s (%d), InterfaceIdx: %s (%d)\n  "), i, sTypeName, sensorType, ifName, interfaceIdx);
		switch (interfaceIdx)
			{
			case 1: // HW_RS232
				_tprintf (_T("HW_RS232: "));
				if (!PrintStringParam (inst, _T("IP_Port")))                 return false;
				if (!PrintIntParam    (inst, _T("IP_Baudrate")))             return false;
				if (!PrintIntParam    (inst, _T("IP_StopBits")))             return false;
				if (!PrintIntParam    (inst, _T("IP_Parity")))               return false;
				if (!PrintIntParam    (inst, _T("IP_ByteSize")))             return false;
				break;
			case 2: // HW_IF2004
				_tprintf (_T("HW_IF2004: "));
				if (!PrintIntParam    (inst, _T("IP_CardInstance")))         return false;
				if (!PrintIntParam    (inst, _T("IP_ChannelNumber")))        return false;
				if (!PrintIntParam    (inst, _T("IP_Baudrate")))             return false;
				break;
			case 3: // HW_TCPIP
				_tprintf (_T("HW_TCPIP: "));
				     PrintStringParam (inst, _T("SA_UUID"),                         false);
				     PrintStringParam (inst, _T("SA_MACAddress"),                   false);
				if (!PrintStringParam (inst, _T("IP_RemoteAddr")))            return false;
				_tprintf (_T("\n            "));
				     PrintStringParam (inst, _T("SA_Address"),                      false);
				if (!PrintStringParam (inst, _T("SA_Gateway")))              return false;
				if (!PrintStringParam (inst, _T("SA_SubnetMask")))           return false;
				     PrintIntParam    (inst, _T("SA_AutoIPEnabled"),                false);
				_tprintf (_T("\n            "));
				if (!PrintIntParam    (inst, _T("SA_DHCPEnabled")))          return false;
				     PrintIntParam    (inst, _T("SA_BootPEnabled"),                 false);
				     PrintStringParam (inst, _T("SA_DHCPName"),                     false);
				     PrintStringParam (inst, _T("SA_DNSServer"),                    false);
				     PrintStringParam (inst, _T("SA_DHCPServer"),                   false);
				if (!PrintStringParam (inst, _T("SA_LocalIPAddress")))       return false;
				if (!PrintStringParam (inst, _T("SA_LocalSubnetMask")))      return false;
				_tprintf (_T("\n            "));
				if (!PrintIntParam    (inst, _T("SA_SensorAccessible")))     return false;
				break;
			case 6: // HW_IF2008
				_tprintf (_T("HW_IF2008: "));
				if (!PrintIntParam    (inst, _T("IP_CardInstance")))         return false;
				if (!PrintIntParam    (inst, _T("IP_ChannelNumber")))        return false;
				if (!PrintIntParam    (inst, _T("IP_Baudrate")))             return false;
				if (!PrintIntParam    (inst, _T("IP_Parity")))               return false;
				break;
			case 10: // HW_IF2008_ETH
				_tprintf (_T("HW_IF2008_ETH: "));
				if (!PrintStringParam (inst, _T("IP_RemoteAddr")))           return false;
				if (!PrintIntParam    (inst, _T("IP_ChannelNumber")))        return false;
				if (!PrintIntParam    (inst, _T("IP_Baudrate")))             return false;
				break;
			default:
				_tprintf (_T("Invalid hardware interface!"));
				return false;
			}
		_tprintf (_T("\n  "));
		if (sensorType==sensor && interfaceIdx==3/*HW_TCPIP*/ && firstUUID && !*firstUUID)
			if (!CheckError (inst, GetParameterString (inst, _T("SA_UUID"), firstUUID, &len))) return false;
		}
	_tprintf (_T("\n"));
	return true;
	}

bool SetIPConfigMO (int inst, int sensor, LPCTSTR uuid, LPCTSTR password, LPCTSTR newIPAddress, LPCTSTR gateway, LPCTSTR subnetMask, bool enableDHCP)
	{
	_tprintf (_T("SetIPConfigMO (sensor= %d, uuid= %s, password= %s, newIPAddress= %s,\n               gateway= %s, subnetMask= %s, enableDHCP= %s)\n  "), sensor, uuid, password, newIPAddress, gateway, subnetMask, ToString (enableDHCP));
	if (!CheckError (inst, SetParameterInt    (inst, _T("IP_SensorType"),    sensor)))                  return false;
	if (!CheckError (inst, SetParameterString (inst, _T("IP_UUID"),          uuid)))                    return false;
	if (!CheckError (inst, SetParameterString (inst, _T("IP_Password"),      password)))                return false;
	if (!CheckError (inst, SetParameterString (inst, _T("IP_NewIPAddress"),  newIPAddress)))            return false;
	if (!CheckError (inst, SetParameterString (inst, _T("IP_Gateway"),       gateway)))                 return false;
	if (!CheckError (inst, SetParameterString (inst, _T("IP_SubnetMask"),    subnetMask)))              return false;
	if (!CheckError (inst, SetParameterInt    (inst, _T("IP_DHCPEnabled"),   enableDHCP)))              return false;
	if (!CheckError (inst, SetParameterInt    (inst, _T("IP_AllowReserved"), true)))                    return false;
	int success= 0;
	if (!CheckError (inst, ExecSCmdGetInt     (inst, _T("Set_IPConfig"), _T("IA_Success"), &success))) return false;
	if (success)
		_tprintf (_T("Successful\n  "));
	else
		_tprintf (_T("Failure\n  "));
	_tprintf (_T("\n"));
	return true;
	}

bool ILD2300_SensorFinder_SetIPConfig()
	{
	DWORD inst= CreateSensorInstance (SENSOR_ILD2300);
	if (inst==0) { _tprintf (_T("Cannot create instance!\n")); return false; }
	if (!ActivateLog (inst))
	   { CheckError (inst, ReleaseSensorInstance (inst));      return false; }
	TCHAR firstUUID[64];
	if (!SensorFinder (inst, SENSOR_ILD2300, false, firstUUID, _countof (firstUUID))) 
	   { CheckError (inst, ReleaseSensorInstance (inst));      return false; }
	if (*firstUUID)
		if (!SetIPConfigMO (inst, SENSOR_ILD2300, firstUUID, _T("000"), _T("192.168.1.100"), _T("0.0.0.0"), _T("255.255.255.0"), false))
		 { CheckError (inst, ReleaseSensorInstance (inst));      return false; }
	if (!CheckError (inst, ReleaseSensorInstance (inst)))      return false;
	return true;
	}

int main(int /*argc*/, char* /*argv*/[])
	{
	ILD2300_SensorFinder_SetIPConfig();
	_tprintf (_T("Press any key to close application...\n"));
	while (!KeyPressed())
		Sleep (10);
	return 0;
	}
