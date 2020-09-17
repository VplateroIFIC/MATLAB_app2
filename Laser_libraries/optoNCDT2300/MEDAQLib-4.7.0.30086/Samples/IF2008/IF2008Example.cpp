#include "stdafx.h"
#include <windows.h>
#include <stdio.h> // printf
#include <conio.h> // _kbhit
// MEDAQLib.h must be included to know it's functions
#include "../../MEDAQLib.h"

// MEDAQLib.lib must be imported to call it's functions
#pragma comment (lib, "../../Release/MEDAQLib.lib")

/* The quintessence of this program is:
	Create and open several ILD2300 on IF2008 card and an encoder channel
	Retrieve Information from Sensor
	Setup Encoder
	Poll data from all channels
	Synchronize sensors (clear all internal data)
	Transfer data from all channels
	Close and release sensors
*/

#ifndef _countof
#define _countof(x) (sizeof (x)/sizeof (x[0]))
#endif // _countof

#define CHECK_ERROR(errCode) \
	if ((errCode)!=ERR_NOERROR) \
		return Error (#errCode, sensor);

int PrintError (LPCSTR err, DWORD instance)
	{
	printf ("Error!\n%s (instance= %d)", err, static_cast<int>(instance));
	while (!_kbhit ())
		Sleep (10);
	return -1;
	}

int Error (LPCSTR err, int sensor)
	{
	char out[1024], buf[1024];
	GetError (sensor, buf, sizeof (buf));

	sprintf (out, "Error in %s\n%s", err, buf);
	return PrintError (out, sensor);
	}

int Open (DWORD sensor, int ch)
	{
	if (sensor==-1)
		return ERR_NOERROR;
	CHECK_ERROR (OpenSensorIF2008 (sensor, 0, ch));
	return ERR_NOERROR;
	}

int SetupEncoder (int sensor, int encoder, int syncChannel)
	{
	if (sensor==-1)
		return ERR_NOERROR;

	CHECK_ERROR (SetDoubleExecSCmd (sensor, "Use_Defaults", "IP_Encoder1CountFactor", 0.1));

	CHECK_ERROR (SetParameterString (sensor, "S_Command", "Set_EncoderLatchSource"));
	CHECK_ERROR (SetParameterInt (sensor, "SP_EncoderNumber", encoder));
	CHECK_ERROR (SetParameterInt (sensor, "SP_EncoderLatchSource", syncChannel));
	CHECK_ERROR (SensorCommand (sensor));
	return ERR_NOERROR;
	}

int GetInfo (DWORD sensor)
	{
	if (sensor==-1)
		return ERR_NOERROR;
	ERR_CODE err;
	CHECK_ERROR (ExecSCmd (sensor, "Get_Info"));

	int iErr= 0;
	err= GetParameterInt (sensor, "SA_ErrorNumber", &iErr);
	if (err!=ERR_NOERROR && err!=ERR_NOT_FOUND)
		return Error ("GetParameterInt (SA_ErrorNumber)", sensor);
	if (iErr!=0)
		{
		char cErr[1024], buf[1024];
		DWORD len= sizeof (cErr);
		CHECK_ERROR (GetParameterString (sensor, "SA_ErrorText", cErr, &len));
		sprintf (buf, "Sensor returned error code after command Get_Info\n%d: %s", iErr, cErr);
		return PrintError (buf, sensor);
		}

	double range;
	CHECK_ERROR (GetParameterDouble (sensor, "SA_Range", &range));
	printf ("Sensor range: %.0f mm\n", range);

	return ERR_NOERROR;
	}

int Sync (int sensor)
	{
	if (sensor==-1)
		return ERR_NOERROR;
	CHECK_ERROR (SetIntExecSCmd (sensor, "Clear_Buffers", "SP_AllDevices", 1));
	return ERR_NOERROR;
	}

int Poll (int sensor)
	{
	if (sensor==-1)
		return ERR_NOERROR;
	double data;

	CHECK_ERROR (Poll (sensor, NULL, &data, 1));
	printf ("Sensor %d: %.1f, ", sensor, data);

	return ERR_NOERROR;
	}

int WaitDataAvail (int sensor, int values)
	{
	if (sensor==-1)
		return ERR_NOERROR;
	int avail= 0;
	while (avail<values)
		{
		CHECK_ERROR (DataAvail (sensor, &avail));
		if (avail<values)
			Sleep (10);
		}
	return ERR_NOERROR;
	}

int ReadData (int sensor, int values)
	{
	if (sensor==-1)
		return ERR_NOERROR;
	const int MAX_VALUES= 10000;
	int read, raw[MAX_VALUES];
	double scaled[MAX_VALUES];
	if (values>MAX_VALUES)
		values= MAX_VALUES;

	CHECK_ERROR (TransferData (sensor, raw, scaled, values, &read));
	if (read!=values)
		return PrintError ("TransferData returned too less values", sensor);
	printf ("Sensor %d [%d]: %d == %.1f ... %d == %.1f\n", sensor, read, raw[0], scaled[0], raw[read-1], scaled[read-1]);
	return ERR_NOERROR;
	}

void Cleanup (int sensor)
	{
	if (sensor==-1)
		return;
	if (CloseSensor (sensor)!=ERR_NOERROR)
		PrintError ("Cannot close sensor!", sensor);
	if (ReleaseSensorInstance (sensor)!=ERR_NOERROR)
		PrintError ("Cannot release driver instance!", sensor);
	}


int main(int /*argc*/, char* /*argv*/[])
	{
	int err= 0;
	const ME_SENSOR s_Sensor[5]= {SENSOR_ILD2300, NO_SENSOR, NO_SENSOR, NO_SENSOR, PCI_CARD_IF2008};
	const int s_CH[5]= {0, 1, 2, 3, 6};
	int sensor[5]= {-1, -1, -1, -1, -1};
	for (int i=0 ; i<5  ; i++)
		{
		if (s_Sensor[i]==0)
			continue;
		sensor[i]= CreateSensorInstance (s_Sensor[i]);
		if (!sensor[i])
			return PrintError ("Cannot create driver instance!", sensor[i]);
		}
	for (int i=0 ; i<5 ; i++)
		{
		if ((err= Open (sensor[i], s_CH[i]))<0)
			goto end;
		}
	for (int i=0 ; i<4 ; i++)
		{
		if ((err= GetInfo (sensor[i]))<0)
			goto end;
		}
	if ((err= SetupEncoder (sensor[4], s_CH[4], 4/*first sensor channel*/))<0)
		goto end;

	while (!_kbhit())
		{
		for (int i=0 ; i<5 ; i++)
			if ((err= Poll (sensor[i]))<0)
				goto end;
		Sleep (500);
		printf ("\n");
		}
	_getch();

	if ((err= Sync (sensor[0]))<0)
		goto end;
	const int VALCNT= 5000;

	while (!_kbhit())
		{
		for (int i=0 ; i<5 ; i++)
			if ((err= WaitDataAvail (sensor[i], VALCNT))<0)
				goto end;
		for (int i=0 ; i<5 ; i++)
			if ((err= ReadData (sensor[i], VALCNT))<0)
				goto end;
		}
	_getch();

end:
	for (int i=0 ; i<5 ; i++)
		Cleanup (sensor[i]);
	return err;
	}
