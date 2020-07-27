#include "stdafx.h"
#include <windows.h>
#include <stdio.h> // printf
// MEDAQLib.h must be included to know it's functions
#include "../../MEDAQLib.h"

// MEDAQLib.lib must be imported to call it's functions
#pragma comment (lib, "../../Release/MEDAQLib.lib")

/* The quintessence of this program is:

	DWORD sensor= CreateSensorInstance (SENSOR_ILD1750);

	OpenSensorRS232 (sensor, "COM9");
	
	SetIntExecSCmd (sensor, "Get_AllParameters", "SP_Additional", 1);
	double range;
	GetParameterDouble (sensor, "SA_Range", &range);
	double measrate;
	GetParameterDouble (sensor, "SA_Measrate", &measrate);

	for (int i=0 ; i<10 ; i++)
		{
		int avail, read;
		double data[10000];

		DataAvail (sensor, &avail);
		TransferData (sensor, NULL, data, sizeof (data), &read);
		Sleep (500);
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

int PrintError (LPCSTR err)
	{
	printf ("Error!\n%s", err);
	return -1;
	}

int Error (LPCSTR err, int sensor)
	{
	char out[1024], buf[1024];
	GetError (sensor, buf, sizeof (buf));

	sprintf (out, "Error in %s\n%s", err, buf);
	return PrintError (out);
	}

int Open (DWORD sensor)
	{
	CHECK_ERROR (OpenSensorRS232 (sensor, "COM9"));	// also valid for RS422 to USB Converter (with RS232 driver emulation)
	return ERR_NOERROR;
	}

int GetInfo (DWORD sensor)
	{
	CHECK_ERROR (SetIntExecSCmd (sensor, "Get_AllParameters", "SP_Additional", 1));

	int iErr= 0;
	ERR_CODE err= GetParameterInt (sensor, "SA_ErrorNumber", &iErr);
	if (err!=ERR_NOERROR && err!=ERR_NOT_FOUND)
		return Error ("GetParameterInt (SA_ErrorNumber)", sensor);
	if (iErr!=0)
		{
		char cErr[1024], buf[1024];
		DWORD len= sizeof (cErr);
		CHECK_ERROR (GetParameterString (sensor, "SA_ErrorText", cErr, &len));
		sprintf (buf, "Sensor returned error code after command Get_AllParameters\n%d: %s", iErr, cErr);
		return PrintError (buf);
		}

	double range;
	CHECK_ERROR (GetParameterDouble (sensor, "SA_Range", &range));
	printf ("Sensor range: %.0f mm\n", range);

	double measrate;
	CHECK_ERROR (GetParameterDouble (sensor, "SA_Measrate", &measrate));
	printf ("Sensor measrate: %.0f kHz\n", measrate);

	return ERR_NOERROR;
	}

int Process (int sensor)
	{
	for (int i=0 ; i<10 ; i++)	// 10 cycles
		{
		int avail, read;
		double data[10000];

		CHECK_ERROR (DataAvail (sensor, &avail));
		printf ("Values avail: %04d\n", avail);

		CHECK_ERROR (TransferData (sensor, NULL, data, sizeof (data), &read));
		printf ("Few values: ");
		for (int j=0 ; j<min (5, read) ; j++)
			printf ("%.1f ", data[j]);
		printf ("\n");

		Sleep (500);	// wait for new data
		}
	return 0;
	}

void Cleanup (int sensor)
	{
	if (CloseSensor (sensor)!=ERR_NOERROR)
		PrintError ("Cannot close sensor!");
	if (ReleaseSensorInstance (sensor)!=ERR_NOERROR)
		PrintError ("Cannot release driver instance!");
	}

int main(int /*argc*/, char* /*argv*/[])
	{
	int err= 0;
	DWORD sensor= CreateSensorInstance (SENSOR_ILD1750);
	if (!sensor)
		return PrintError("Cannot create driver instance!");

	if ((err= Open (sensor))<0)
		goto end;

	if ((err= GetInfo (sensor))<0)
		goto end;

	if ((err= Process (sensor))<0)
		goto end;

end:
	Cleanup (sensor);
	return err;
	}
