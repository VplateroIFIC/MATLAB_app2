#include "stdafx.h"
#include <windows.h>
#include <conio.h>
// MEDAQLib.h must be included to know it's functions
#include "../../MEDAQLib.h"

// MEDAQLib.lib must be imported to call it's functions
#ifdef _WIN64
#pragma comment (lib, "../../Release-x64/MEDAQLib.lib")
#else
#pragma comment (lib, "../../Release/MEDAQLib.lib")
#endif

/* The quintessence of this program is:

	DWORD sensor= CreateSensorInstance (SENSOR_ILD2300);

	OpenSensorTCPIP (sensor, "10.2.22.149");
	
	SetIntExecSCmd (sensor, "Get_AllParameters", "SP_Additional", 1);
	double range;
	GetParameterDouble (sensor, "SA_Range", &range);
	double measRate;
	GetParameterInt (sensor, "SA_Measrate", &measRate);

	ExecSCmdGetInt (sensor, "S_Command", "Get_TransmittedDataInfo", "IA_ValuesPerFrame", &iCnt);
	// Output the answer

	while (!_kbhit())
		{
		int avail, read, raw[10000];
		double scaled[10000];

		DataAvail (sensor, &avail);
		TransferData (sensor, raw, scaled, read, &read);
		for (int j=0 ; j<iValsPerFrame ; j++)
			// Output raw values
		for (int j=0 ; j<iValsPerFrame ; j++)
			// Output scaled values
		}
	
	CloseSensor (sensor);
	ReleaseSensorInstance (sensor);
*/

#ifndef _countof
#define _countof(x) (sizeof (x)/sizeof (x[0]))
#endif // _countof

#define CHECK_ERROR(errCode) \
	if ((errCode)!=ERR_NOERROR) \
		return Error (#errCode, sensor);

int PrintError (LPCTSTR err)
	{
	_tprintf (_T("Error!\n%s"), err);
	return -1;
	}

int Error (LPCTSTR err, int sensor)
	{
	char out[1024], buf[1024];
	GetError (sensor, buf, sizeof (buf));
	_stprintf (out, _T("Error in %s\n%s"), err, buf);
	return PrintError (out);
	}

int Open (DWORD sensor)
	{
	// If logging should be enabled
	// EnableLogging (sensor, TRUE, 31, 127, _T(".\\Log.txt"), TRUE, FALSE, 0);

	CHECK_ERROR (OpenSensorTCPIP (sensor, _T("10.2.22.155")));
	return ERR_NOERROR;
	}

int GetAllParameters (DWORD sensor)
	{
	CHECK_ERROR (SetIntExecSCmd (sensor, _T("Get_AllParameters"), _T("SP_Additional"), 1));

	int iErr= 0;
	ERR_CODE err= GetParameterInt (sensor, _T("SA_ErrorNumber"), &iErr);
	if (err!=ERR_NOERROR && err!=ERR_NOT_FOUND)
		return Error (_T("GetParameterInt (SA_ErrorNumber)"), sensor);
	if (iErr!=0)
		{
		char cErr[1024], buf[1024];
		DWORD len= sizeof (cErr);
		CHECK_ERROR (GetParameterString (sensor, _T("SA_ErrorText"), cErr, &len));
		_stprintf (buf, _T("Sensor returned error code after command Get_Settings\n%d: %s"), iErr, cErr);
		return PrintError (buf);
		}

	double range;
	CHECK_ERROR (GetParameterDouble (sensor, _T("SA_Range"), &range));
	_tprintf (_T("Sensor range: %.0f mm\n"), range);

	double measRate;
	CHECK_ERROR (GetParameterDouble (sensor, _T("SA_Measrate"), &measRate));
	_tprintf (_T("Sensor speed: %.1f kHz\n"), measRate);

	return ERR_NOERROR;
	}

int GetTransmittedDataInfo (DWORD sensor)
	{
	int iCnt= 0;
	CHECK_ERROR (ExecSCmdGetInt (sensor, _T("Get_TransmittedDataInfo"), _T("IA_ValuesPerFrame"), &iCnt));

	TCHAR name[256], sVal[1024];
	int iVal;
	DWORD iLen;
	double dVal;
	_tprintf (_T("GetTransmittedDataInfo:\r\n"));
	for (int i=0 ; i<iCnt ; i++)
		{
		_stprintf (name, _T("IA_Index%d"), i+1);
		CHECK_ERROR (GetParameterInt (sensor, name, &iVal));
		_tprintf (_T("%2d: "), iVal);

		_stprintf (name, _T("IA_Raw_Name%d"), i+1);
		iLen= sizeof (sVal);
		CHECK_ERROR (GetParameterString (sensor, name, sVal, &iLen));
		_tprintf (_T("%s ["), sVal);

		_stprintf (name, _T("IA_Raw_RangeMin%d"), i+1);
		CHECK_ERROR (GetParameterDouble (sensor, name, &dVal));
		_tprintf (_T("%.1f - "), dVal);

		_stprintf (name, _T("IA_Raw_RangeMax%d"), i+1);
		CHECK_ERROR (GetParameterDouble (sensor, name, &dVal));
		_tprintf (_T("%.1f "), dVal);

		_stprintf (name, _T("IA_Raw_Unit%d"), i+1);
		iLen= sizeof (sVal);
		CHECK_ERROR (GetParameterString (sensor, name, sVal, &iLen));
		_tprintf (_T("%s] @ "), sVal);

		_stprintf (name, _T("IA_Raw_Datarate%d"), i+1);
		CHECK_ERROR (GetParameterDouble (sensor, name, &dVal));
		_tprintf (_T("%.1f Hz\r\n    "), dVal);

		_stprintf (name, _T("IA_Scaled_Name%d"), i+1);
		iLen= sizeof (sVal);
		CHECK_ERROR (GetParameterString (sensor, name, sVal, &iLen));
		_tprintf (_T("%s ["), sVal);

		_stprintf (name, _T("IA_Scaled_RangeMin%d"), i+1);
		CHECK_ERROR (GetParameterDouble (sensor, name, &dVal));
		_tprintf (_T("%.1f - "), dVal);

		_stprintf (name, _T("IA_Scaled_RangeMax%d"), i+1);
		CHECK_ERROR (GetParameterDouble (sensor, name, &dVal));
		_tprintf (_T("%.1f "), dVal);

		_stprintf (name, _T("IA_Scaled_Unit%d"), i+1);
		iLen= sizeof (sVal);
		CHECK_ERROR (GetParameterString (sensor, name, sVal, &iLen));
		_tprintf (_T("%s] @ "), sVal);

		_stprintf (name, _T("IA_Scaled_Datarate%d"), i+1);
		CHECK_ERROR (GetParameterDouble (sensor, name, &dVal));
		_tprintf (_T("%.1f Hz\r\n"), dVal);
		}
	return iCnt;
	}

int Process (int sensor, int iValsPerFrame)
	{
	_tprintf (_T("\r\nPress any key to abort...\r\nAvail, Should read, Really read, Raw values, Scaled values\r\n"));
	while (!_kbhit())
		{
		_tprintf (_T("\015"));
		int avail, read, raw[10000];
		double scaled[10000];

		CHECK_ERROR (DataAvail (sensor, &avail));
		read= min (sizeof (scaled), avail);
		read= read-(read%iValsPerFrame);
		_tprintf (_T("%04d,  %04d, "), avail, read);

		CHECK_ERROR (TransferData (sensor, raw, scaled, read, &read));
		if (read>0)
			{
			_tprintf (_T("       %04d,        "), read);
			for (int j=0 ; j<iValsPerFrame ; j++)
				_tprintf (_T("%d "), raw[read-iValsPerFrame+j]);
			_tprintf (_T(", "));
			for (int j=0 ; j<iValsPerFrame ; j++)
				_tprintf (_T("%.1f "), scaled[read-iValsPerFrame+j]);
			}
		Sleep (50);	// wait for new data
		}
	return 0;
	}

void Cleanup (int sensor)
	{
	if (CloseSensor (sensor)!=ERR_NOERROR)
		PrintError (_T("Cannot close sensor!"));
	if (ReleaseSensorInstance (sensor)!=ERR_NOERROR)
		PrintError (_T("Cannot release driver instance!"));
	}

int _tmain (int /*argc*/, _TCHAR * /*argv*/[])
	{
	int err= 0;
	DWORD sensor= CreateSensorInstance (SENSOR_ILD2300);
	if (!sensor)
		return PrintError (_T("Cannot create driver instance!"));

	if ((err= Open (sensor))<0)
		goto end;

	if ((err= GetAllParameters (sensor))<0)
		goto end;

	if ((err= GetTransmittedDataInfo (sensor))<0)
		goto end;

	if ((err= Process (sensor, err))<0)
		goto end;

end:
	Cleanup (sensor);
	return err;
	}
