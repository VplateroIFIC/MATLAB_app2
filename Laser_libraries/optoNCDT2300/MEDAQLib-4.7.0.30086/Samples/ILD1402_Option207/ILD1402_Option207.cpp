#include "stdafx.h"
#include <windows.h>
#include <stdlib.h> // strtod, strtol
#include <conio.h> // _kbhit
#include <tchar.h> // _T, _tprintf
#include "../../MEDAQLib.h" // MEDAQLib.h must be included to know it's functions
#ifdef _WIN64
#pragma comment (lib, "../../Release-x64/MEDAQLib.lib") // MEDAQLib.lib must be imported to call it's functions
#else
#pragma comment (lib, "../../Release/MEDAQLib.lib") // MEDAQLib.lib must be imported to call it's functions
#endif

/** Helper function to set cursor at start of current line in console.
*/
void ClearLine()
	{
	_tprintf (_T("\r")); // Jump at start of line, next printf will overwrite old content
	}

/** Check if key was pressed, read character in case of.
*/
bool KeyPressed()
	{
	if (!_kbhit())
		return false;
	getch();
	return true;
	}

/** Close and release sensor instance, wait for a key pressed
*/
void Cleanup (DWORD sensorInstance)
	{
	if (sensorInstance)
		{
		::CloseSensor (sensorInstance);
		::ReleaseSensorInstance (sensorInstance);
		}
	_tprintf (_T("Press any key to exit"));
	while (!KeyPressed())
		Sleep (50);
	}

/** Retrieve error message after any MEDAQLib function returned an error
*/
void ShowLastError (DWORD sensorInstance, LPCTSTR location)
	{
	char lastError[2048]= "\0";
	::GetError (sensorInstance, lastError, _countof (lastError));
	_tprintf (_T("\nError at '%s'\n"), location);
	_tprintf (_T("%s\n"), lastError);

	int errNumber;
	if (::GetParameterInt (sensorInstance, _T("SA_ErrorNumber"), &errNumber)==ERR_NOERROR)
		_tprintf (_T("Sensor error number: %d\n"), errNumber);

	TCHAR errText[1024];
	DWORD tmp= _countof (errText);
	if (::GetParameterString (sensorInstance, _T("SA_ErrorText"), errText, &tmp)==ERR_NOERROR)
		_tprintf (_T("Sensor error text: '%s'\n"), errText);
	}

/** Macro to encapsulate error handling when calling MEDAQLib functions.
* Can only be used if variable sensorInstance exists.
*/
#define CHECK_ERROR(expr) \
	{ \
	ERR_CODE ret= expr; \
	if (ret!=ERR_NOERROR) \
		{ \
		ShowLastError (sensorInstance, #expr); \
		if (ret!=ERR_WARNING && ret!=ERR_SENSOR_ANSWER_WARNING) \
			{ \
			Cleanup (sensorInstance); \
			return false; \
			} \
		} \
	}

/** Print short help on console
*/
int Usage()
	{
	_tprintf (_T("Usage:\nILD1042_Option207 <COM-Port>\n"));
	_tprintf (_T("COM-Port is a string in form of COMx, e.g. COM4\n"));
	_tprintf (_T("Example:\n"));
	_tprintf (_T("ILD1042_Option207 COM4\n"));
	Cleanup (0);
	return 0;
	}

/** Connect to sensor
*/
bool Open (DWORD sensorInstance, LPCTSTR port)
	{
	_tprintf (_T("Connecting to sensor\n"));
	::SetParameterInt (sensorInstance, _T("IP_EnableLogging"), 1);
	CHECK_ERROR (::OpenSensorRS232 (sensorInstance, port));
	return true;
	}

/** Call sensor command Get_Info, show relevant output
*/
bool ILD1402_GetInfo (DWORD sensorInstance)
	{
	TCHAR sBuf[1024];
	DWORD len;
	double dBuf;
	CHECK_ERROR (::ExecSCmd (sensorInstance, _T("Get_Info")));

	len= _countof (sBuf); 
	CHECK_ERROR (::GetParameterString (sensorInstance, _T("SA_SerialNumber"), sBuf, &len)); 
	_tprintf (_T("\nSA_SerialNumber: %s\n"), sBuf);

	CHECK_ERROR (::GetParameterDouble (sensorInstance, _T("SA_Range"), &dBuf)); 
	_tprintf (_T("SA_Range: %.3f\n"), dBuf);

	len= _countof (sBuf); 
	CHECK_ERROR (::GetParameterString (sensorInstance, _T("SA_Softwareversion"), sBuf, &len)); 
	_tprintf (_T("SA_Softwareversion: %s\n"), sBuf);

	return true;
	}

/** Call sensor commands ...
*/
bool Option207_Commands (DWORD sensorInstance)
	{
	int iVal;
	_tprintf (_T("\n"));

	_tprintf (_T("Call Set_OperationMode (User mode)\n"));
	CHECK_ERROR (::SetIntExecSCmd (sensorInstance, _T("Set_OperationMode"), _T("SP_OperationMode"), 2/*User mode*/));
	Sleep (1000); // Now the sensor should be off while this sleep time
	iVal= 0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, _T("Get_LaserDiodeError"), _T("SA_LaserDiodeError"), &iVal));
	_tprintf (_T("SA_LaserDiodeError when both are off: 0x%02x\n"), iVal);
	iVal= 0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, _T("Get_CurrentOfMonitor"), _T("SA_CurrentOfMonitor"), &iVal));
	_tprintf (_T("SA_CurrentOfMonitor [nA] when both are off: 0x%02x\n"), iVal);

	_tprintf (_T("Call Set_LaserDiode1 (4.0 mW)\n"));
	CHECK_ERROR (::SetIntExecSCmd (sensorInstance, _T("Set_LaserDiode1"), _T("SP_LaserDiode1"), 20/*4.0 mW*/));
	Sleep (1000); // Now sensor diode 1 should be on while this sleep time
	iVal= 0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, _T("Get_LaserDiodeError"), _T("SA_LaserDiodeError"), &iVal));
	_tprintf (_T("SA_LaserDiodeError when first one is on: 0x%02x\n"), iVal);
	iVal= 0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, _T("Get_CurrentOfMonitor"), _T("SA_CurrentOfMonitor"), &iVal));
	_tprintf (_T("SA_CurrentOfMonitor [nA] when first one is on: 0x%02x\n"), iVal);

	_tprintf (_T("Call Set_LaserDiode2 (4.4 mW)\n"));
	CHECK_ERROR (::SetIntExecSCmd (sensorInstance, _T("Set_LaserDiode2"), _T("SP_LaserDiode2"), 22/*4.4 mW*/));
	Sleep (1000); // Now sensor diode 2 should be on while this sleep time (first one is switched of automatically)
	iVal= 0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, _T("Get_LaserDiodeError"), _T("SA_LaserDiodeError"), &iVal));
	_tprintf (_T("SA_LaserDiodeError when second one is on: 0x%02x\n"), iVal);
	iVal= 0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, _T("Get_CurrentOfMonitor"), _T("SA_CurrentOfMonitor"), &iVal));
	_tprintf (_T("SA_CurrentOfMonitor [nA] when second one is on: 0x%02x\n"), iVal);

	_tprintf (_T("Call Set_OperationMode (Measure mode)\n"));
	CHECK_ERROR (::SetIntExecSCmd (sensorInstance, _T("Set_OperationMode"), _T("SP_OperationMode"), 1/*Measure mode*/));
	return true;
	}

/** Retrieve information about transmitted data from sensor and show it at console
*/
bool GetTransmittedDataInfo (DWORD sensorInstance, int &valsPerFrame)
	{
	DWORD maxLen;
	int maxValsPerFrame, index;
	char sName[64], rawName[256], scaledName[256], rawUnit[256], scaledUnit[256];
	double rawRangeMin, rawRangeMax, scaledRangeMin, scaledRangeMax, rawDatarate, scaledDatarate;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, "Get_TransmittedDataInfo", "IA_ValuesPerFrame", &valsPerFrame));
	CHECK_ERROR (::GetParameterInt (sensorInstance, "IA_MaxValuesPerFrame", &maxValsPerFrame));

	_tprintf (_T("\nSensor transmits %d of %d possible values\n"), valsPerFrame, maxValsPerFrame);
	for (int i=0 ; i<valsPerFrame ; i++)
		{
		sprintf (sName, "IA_Index%d", i+1);
		CHECK_ERROR (::GetParameterInt (sensorInstance, sName, &index));

		sprintf (sName, "IA_Raw_Name%d", i+1);
		maxLen= _countof (rawName);
		CHECK_ERROR (::GetParameterString (sensorInstance, sName, rawName, &maxLen));

		sprintf (sName, "IA_Scaled_Name%d", i+1);
		maxLen= _countof (scaledName);
		CHECK_ERROR (::GetParameterString (sensorInstance, sName, scaledName, &maxLen));

		sprintf (sName, "IA_Raw_RangeMin%d", i+1);
		CHECK_ERROR (::GetParameterDouble (sensorInstance, sName, &rawRangeMin));

		sprintf (sName, "IA_Scaled_RangeMin%d", i+1);
		CHECK_ERROR (::GetParameterDouble (sensorInstance, sName, &scaledRangeMin));

		sprintf (sName, "IA_Raw_RangeMax%d", i+1);
		CHECK_ERROR (::GetParameterDouble (sensorInstance, sName, &rawRangeMax));

		sprintf (sName, "IA_Scaled_RangeMax%d", i+1);
		CHECK_ERROR (::GetParameterDouble (sensorInstance, sName, &scaledRangeMax));

		sprintf (sName, "IA_Raw_Unit%d", i+1);
		maxLen= _countof (rawUnit);
		CHECK_ERROR (::GetParameterString (sensorInstance, sName, rawUnit, &maxLen));

		sprintf (sName, "IA_Scaled_Unit%d", i+1);
		maxLen= _countof (scaledUnit);
		CHECK_ERROR (::GetParameterString (sensorInstance, sName, scaledUnit, &maxLen));

		sprintf (sName, "IA_Raw_Datarate%d", i+1);
		CHECK_ERROR (::GetParameterDouble (sensorInstance, sName, &rawDatarate));

		sprintf (sName, "IA_Scaled_Datarate%d", i+1);
		CHECK_ERROR (::GetParameterDouble (sensorInstance, sName, &scaledDatarate));

		_tprintf (_T("  %d: %s [%.1f .. %.1f %s] @ %.1f Hz, %s [%.1f .. %.1f %s] @ %.1f Hz\n"), index, rawName, rawRangeMin, rawRangeMax, rawUnit, rawDatarate, scaledName, scaledRangeMin, scaledRangeMax, scaledUnit, scaledDatarate);
		}
	return true;
	}

/** Read continuous data from sensor and show each first frame at console
*/
bool GetData (DWORD sensorInstance, int valsPerFrame)
	{
	_tprintf (_T("\nReading data continuous (press any key to abort)\n"));
	int avail= 0, read;
	int rawData[100];
	double scaledData[100];
	while (!KeyPressed())
		{
		Sleep (50);
		CHECK_ERROR (::DataAvail (sensorInstance, &avail));
		if (avail<valsPerFrame)
			continue;
		CHECK_ERROR (::TransferData (sensorInstance, rawData, scaledData, _countof (rawData), &read)); // Read up to 100 values
		if (read<valsPerFrame)
			{
			_tprintf (_T("Error at '::TransferData (sensorInstance, rawData, scaledData, _countof (rawData), &read)'\nTo less values (%d) was read."), read);
			return false;
			}
		ClearLine();
		for (int i=0 ; i<valsPerFrame ; i++)
			{
			_tprintf (_T("%d (%-1f)"), rawData[i], scaledData[i]);
			if (i<valsPerFrame-1)
				_tprintf (_T(", "));
			}
		CHECK_ERROR (ExecSCmd (sensorInstance, "Clear_Buffers")); // To avoid buffer overflows
		}
	_tprintf (_T("\n"));
	return true;
	}

/** Main ILD1042_Option207 program
*/
int main (int argc, char *argv[])
	{
	if (argc!=2)
		return Usage();

	_tprintf (_T("ILD1042_Option207 %s\n"), argv[1]);
	DWORD sensorInstance= ::CreateSensorInstByName (_T("ILD1402"));
	if (!sensorInstance)
		{
		_tprintf (_T("Cannot create driver instance of sensor ILD1402!\n"));
		Cleanup (sensorInstance);
		return -1;
		}

	if (!Open (sensorInstance, argv[1]))
		return -1;

	if (!ILD1402_GetInfo (sensorInstance))
		return -1;

	int valsPerFrame;
	if (!GetTransmittedDataInfo (sensorInstance, valsPerFrame))
		return -1;

	if (!Option207_Commands (sensorInstance))
		return -1;

	if (!GetData (sensorInstance, valsPerFrame))
		return -1;
	Cleanup (sensorInstance);
	return 0;
	}
