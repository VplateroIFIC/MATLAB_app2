#include "stdafx.h"
#include <windows.h>
#include <tchar.h> // _T, _tprintf
// MEDAQLib.h must be included to know it's functions
#include "..\..\MEDAQLib.h"

/* The quintessence of this program is:

	HMODULE h= LoadLibrary ("MEDAQLib.dll");
	CREATESENSORINSTANCE pCreateSensorInstance=   GetProcAddress (h, "CreateSensorInstance");
	RELEASESENSORINSTANCE pReleaseSensorInstance= GetProcAddress (h, "ReleaseSensorInstance");
	// ... all other functions ...

	DWORD sensor= pCreateSensorInstance (SENSOR_IFD2421);

	OpenSensorTCPIP ("169.254.168.150");
	
	pSetParameterString (sensor, "S_Command", "Get_AllParameters");
	pSetParameterInt (sensor, "SP_Additional", 1);
	pSensorCommand (sensor);
	double range;
	pGetParameterDouble (sensor, "SA_Range", &range);
	double measrate;
	pGetParameterDouble (sensor, "SA_Measrate", &measrate);

	pSetParameterString (sensor, "S_Command", "DataAvail_Event");
	pSetParameterInt (sensor, "IP_EventOnAvailableValues", 1024);
	pSensorCommand (sensor);
	HANDLE event= 0;
	pGetParameterDWORD_PTR (sensor, "IA_DataAvailEvent", &event);

	UINT read;
	for (int i=0 ; i<10 ; i++)
		{
		WaitForSingleObject (event, 1000);
		double data[1024];

		pTransferData (sensor, NULL, &data, 1024, &read);
		}
	
	pCloseSensor (sensor);
	pReleaseSensorInstance (sensor);
*/

#ifndef _countof
#define _countof(x) (sizeof (x)/sizeof (x[0]))
#endif // _countof

#define CHECK_ERROR(errCode) \
	if ((errCode)!=ERR_NOERROR) \
		return Error (_T(#errCode), sensor);

/******************************************************************************
                              C type definitions
Following type definitions can be used, when the MEDAQLib driver is dynamically
loaded (LoadLibrary) and the function pointers retrieved by GetProcAddress must
be assigned to functions, e.g.: 

CREATESENSORINSTANCE pCreateSensorInstance= (CREATESENSORINSTANCE)
  GetProcAddress (LoadLibrary ("MEDAQLib.dll"), "CreateSensorInstance");
******************************************************************************/
typedef DWORD    (WINAPI *CREATESENSORINSTANCE)   (ME_SENSOR sensor);
typedef DWORD    (WINAPI *CREATESENSORINSTBYNAME) (LPCTSTR sensorName); // Suitable for both CreateSensorInstByName(U)
typedef ERR_CODE (WINAPI *RELEASESENSORINSTANCE)  (DWORD instanceHandle);
typedef ERR_CODE (WINAPI *SETPPARAMETERINT)       (DWORD instanceHandle, LPCTSTR paramName, int         paramValue); // Suitable for both SetParameterInt(U)
typedef ERR_CODE (WINAPI *SETPPARAMETERDWORD_PTR) (DWORD instanceHandle, LPCTSTR paramName, DWORD_PTR   paramValue); // Suitable for both SetParameterDWORD_PTR(U)
typedef ERR_CODE (WINAPI *SETPPARAMETERDOUBLE)    (DWORD instanceHandle, LPCTSTR paramName, double      paramValue); // Suitable for both SetParameterDouble(U)
typedef ERR_CODE (WINAPI *SETPPARAMETERSTRING)    (DWORD instanceHandle, LPCTSTR paramName, LPCTSTR     paramValue); // Suitable for both SetParameterString(U)
typedef ERR_CODE (WINAPI *SETPPARAMETERBINARY)    (DWORD instanceHandle, LPCTSTR paramName, const char *paramValue, DWORD len); // Suitable for both SetParameterBinary(U)
typedef ERR_CODE (WINAPI *SETPPARAMETERS)         (DWORD instanceHandle, LPCTSTR parameterList); // Suitable for both SetParameters(U)
typedef ERR_CODE (WINAPI *GETPPARAMETERINT)       (DWORD instanceHandle, LPCTSTR paramName, int       *paramValue); // Suitable for both GetParameterInt(U)
typedef ERR_CODE (WINAPI *GETPPARAMETERDWORD_PTR) (DWORD instanceHandle, LPCTSTR paramName, DWORD_PTR *paramValue); // Suitable for both GetParameterDWORD_PTR(U)
typedef ERR_CODE (WINAPI *GETPPARAMETERDOUBLE)    (DWORD instanceHandle, LPCTSTR paramName, double    *paramValue); // Suitable for both GetParameterDouble(U)
typedef ERR_CODE (WINAPI *GETPPARAMETERSTRING)    (DWORD instanceHandle, LPCTSTR paramName, LPTSTR     paramValue, DWORD *maxLen); // Suitable for both GetParameterString(U)
typedef ERR_CODE (WINAPI *GETPPARAMETERBINARY)    (DWORD instanceHandle, LPCTSTR paramName, const char *paramValue, DWORD *maxLen); // Suitable for both GetParameterBinary(U)
typedef ERR_CODE (WINAPI *GETPPARAMETERS)         (DWORD instanceHandle, LPTSTR parameterList, DWORD *maxLen); // Suitable for both GetParameters(U)

typedef ERR_CODE (WINAPI *CLEARALLPARAMETERS)     (DWORD instanceHandle);
typedef ERR_CODE (WINAPI *OPENSENSOR)             (DWORD instanceHandle);
typedef ERR_CODE (WINAPI *CLOSESENSOR)            (DWORD instanceHandle);
typedef ERR_CODE (WINAPI *SENSORCOMMAND)          (DWORD instanceHandle);
typedef ERR_CODE (WINAPI *DATAAVAIL)              (DWORD instanceHandle, int *avail);
typedef ERR_CODE (WINAPI *TRANSFERDATA)           (DWORD instanceHandle, int *rawData, double *scaledData, int maxValues, int *read);
typedef ERR_CODE (WINAPI *TRANSFERDATATS)         (DWORD instanceHandle, int *rawData, double *scaledData, int maxValues, int *read, double *timestamp);
typedef ERR_CODE (WINAPI *POLL)                   (DWORD instanceHandle, int *rawData, double *scaledData, int maxValues);
typedef ERR_CODE (WINAPI *GETERROR)               (DWORD instanceHandle, LPCTSTR errText, DWORD maxLen); // Suitable for both GetError(U)
typedef ERR_CODE (WINAPI *GETDLLVERSION)          (LPCTSTR versionStr, DWORD maxLen); // Suitable for both GetDLLVersion(U)
typedef ERR_CODE (WINAPI *ENABLELOGGING)          (DWORD instanceHandle, BOOL enableLogging, int logType, int logLevel, LPCTSTR logFile, BOOL logAppend, BOOL logFlush, int logSplitSize); // Suitable for both EnableLogging(U)
typedef ERR_CODE (WINAPI *OPENSENSORRS232)        (DWORD instanceHandle, LPCTSTR port); // Suitable for both OpenSensorRS232(U)
typedef ERR_CODE (WINAPI *OPENSENSORIF2004)       (DWORD instanceHandle, int cardInstance, int channelNumber);
typedef ERR_CODE (WINAPI *OPENSENSORIF2004_USB)   (DWORD instanceHandle, int deviceInstance, LPCTSTR serialNumber, LPCTSTR port, int channelNumber); // Suitable for both OpenSensorIF2004_USB(U)
typedef ERR_CODE (WINAPI *OPENSENSORIF2008)       (DWORD instanceHandle, int cardInstance, int channelNumber);
typedef ERR_CODE (WINAPI *OPENSENSORIF2008_ETH)   (DWORD instanceHandle, LPCTSTR remoteAddr, int channelNumber); // Suitable for both OpenSensorIF2008_ETH(U)
typedef ERR_CODE (WINAPI *OPENSENSORTCPIP)        (DWORD instanceHandle, LPCTSTR remoteAddr); // Suitable for both OpenSensorTCPIP(U)
typedef ERR_CODE (WINAPI *OPENSENSORWINUSB)       (DWORD instanceHandle, int deviceInstance);
typedef ERR_CODE (WINAPI *EXECSCMD)               (DWORD instanceHandle, LPCTSTR sensorCommand); // Suitable for both ExecSCmd(U)
typedef ERR_CODE (WINAPI *SETINTEXECSCMD)         (DWORD instanceHandle, LPCTSTR sensorCommand, LPCTSTR paramName, int     paramValue); // Suitable for both SetIntExecSCmd(U)
typedef ERR_CODE (WINAPI *SETDOUBLEEXECSCMD)      (DWORD instanceHandle, LPCTSTR sensorCommand, LPCTSTR paramName, double  paramValue); // Suitable for both SetDoubleExecSCmd(U)
typedef ERR_CODE (WINAPI *SETSTRINGEXECSCMD)      (DWORD instanceHandle, LPCTSTR sensorCommand, LPCTSTR paramName, LPCTSTR paramValue); // Suitable for both SetStringExecSCmd(U)
typedef ERR_CODE (WINAPI *EXECSCMDGETINT)         (DWORD instanceHandle, LPCTSTR sensorCommand, LPCTSTR paramName, int    *paramValue); // Suitable for both ExecSCmdGetInt(U)
typedef ERR_CODE (WINAPI *EXECSCMDGETDOUBLE)      (DWORD instanceHandle, LPCTSTR sensorCommand, LPCTSTR paramName, double *paramValue); // Suitable for both ExecSCmdGetDouble(U)
typedef ERR_CODE (WINAPI *EXECSCMDGETSTRING)      (DWORD instanceHandle, LPCTSTR sensorCommand, LPCTSTR paramName, LPTSTR  paramValue, DWORD *maxLen); // Suitable for both ExecSCmdGetString(U)

static CREATESENSORINSTANCE   pCreateSensorInstance  = NULL;
static CREATESENSORINSTBYNAME pCreateSensorInstByName= NULL;
static RELEASESENSORINSTANCE  pReleaseSensorInstance = NULL;
static SETPPARAMETERINT       pSetParameterInt       = NULL;
static SETPPARAMETERDWORD_PTR pSetParameterDWORD_PTR = NULL;
static SETPPARAMETERDOUBLE    pSetParameterDouble    = NULL;
static SETPPARAMETERSTRING    pSetParameterString    = NULL;
static SETPPARAMETERBINARY    pSetParameterBinary    = NULL;
static SETPPARAMETERS         pSetParameters         = NULL;
static GETPPARAMETERINT       pGetParameterInt       = NULL;
static GETPPARAMETERDWORD_PTR pGetParameterDWORD_PTR = NULL;
static GETPPARAMETERDOUBLE    pGetParameterDouble    = NULL;
static GETPPARAMETERSTRING    pGetParameterString    = NULL;
static GETPPARAMETERBINARY    pGetParameterBinary    = NULL;
static GETPPARAMETERS         pGetParameters         = NULL;
static CLEARALLPARAMETERS     pClearAllParameters    = NULL;
static OPENSENSOR             pOpenSensor            = NULL;
static CLOSESENSOR            pCloseSensor           = NULL;
static SENSORCOMMAND          pSensorCommand         = NULL;
static DATAAVAIL              pDataAvail             = NULL;
static TRANSFERDATA           pTransferData          = NULL;
static TRANSFERDATATS         pTransferDataTS        = NULL;
static POLL                   pPoll                  = NULL;
static GETERROR               pGetError              = NULL;
static GETDLLVERSION          pGetDLLVersion         = NULL;
static ENABLELOGGING          pEnableLogging         = NULL;
static OPENSENSORRS232        pOpenSensorRS232       = NULL;
static OPENSENSORIF2004       pOpenSensorIF2004      = NULL;
static OPENSENSORIF2004_USB   pOpenSensorIF2004_USB  = NULL;
static OPENSENSORIF2008       pOpenSensorIF2008      = NULL;
static OPENSENSORIF2008_ETH   pOpenSensorIF2008_ETH  = NULL;
static OPENSENSORTCPIP        pOpenSensorTCPIP       = NULL;
static OPENSENSORWINUSB       pOpenSensorWinUSB      = NULL;
static EXECSCMD               pExecSCmd              = NULL;
static SETINTEXECSCMD         pSetIntExecSCmd        = NULL;
static SETDOUBLEEXECSCMD      pSetDoubleExecSCmd     = NULL;
static SETSTRINGEXECSCMD      pSetStringExecSCmd     = NULL;
static EXECSCMDGETINT         pExecSCmdGetInt        = NULL;
static EXECSCMDGETDOUBLE      pExecSCmdGetDouble     = NULL;
static EXECSCMDGETSTRING      pExecSCmdGetString     = NULL;

#ifndef UNICODE
#define MU(fctName) fctName
#else
#define MU(fctName) fctName "U"
#endif

int LoadDLLFunctions()
	{
	static HMODULE h= LoadLibrary (_T("MEDAQLib.dll"));
	if (h==NULL)
		return -1;
	pCreateSensorInstance  = reinterpret_cast<CREATESENSORINSTANCE>   (GetProcAddress (h, "CreateSensorInstance"));
	pCreateSensorInstByName= reinterpret_cast<CREATESENSORINSTBYNAME> (GetProcAddress (h, MU("CreateSensorInstByName")));
	pReleaseSensorInstance = reinterpret_cast<RELEASESENSORINSTANCE>  (GetProcAddress (h, "ReleaseSensorInstance"));
	pSetParameterInt       = reinterpret_cast<SETPPARAMETERINT>       (GetProcAddress (h, MU("SetParameterInt")));
	pSetParameterDWORD_PTR = reinterpret_cast<SETPPARAMETERDWORD_PTR> (GetProcAddress (h, MU("SetParameterDWORD_PTR")));
	pSetParameterDouble    = reinterpret_cast<SETPPARAMETERDOUBLE>    (GetProcAddress (h, MU("SetParameterDouble")));
	pSetParameterString    = reinterpret_cast<SETPPARAMETERSTRING>    (GetProcAddress (h, MU("SetParameterString")));
	pSetParameterBinary    = reinterpret_cast<SETPPARAMETERBINARY>    (GetProcAddress (h, MU("SetParameterBinary")));
	pSetParameters         = reinterpret_cast<SETPPARAMETERS>         (GetProcAddress (h, MU("SetParameters")));
	pGetParameterInt       = reinterpret_cast<GETPPARAMETERINT>       (GetProcAddress (h, MU("GetParameterInt")));
	pGetParameterDWORD_PTR = reinterpret_cast<GETPPARAMETERDWORD_PTR> (GetProcAddress (h, MU("GetParameterDWORD_PTR")));
	pGetParameterDouble    = reinterpret_cast<GETPPARAMETERDOUBLE>    (GetProcAddress (h, MU("GetParameterDouble")));
	pGetParameterString    = reinterpret_cast<GETPPARAMETERSTRING>    (GetProcAddress (h, MU("GetParameterString")));
	pGetParameterBinary    = reinterpret_cast<GETPPARAMETERBINARY>    (GetProcAddress (h, MU("GetParameterBinary")));
	pGetParameters         = reinterpret_cast<GETPPARAMETERS>         (GetProcAddress (h, MU("GetParameters")));
	pClearAllParameters    = reinterpret_cast<CLEARALLPARAMETERS>     (GetProcAddress (h, "ClearAllParameters"));
	pOpenSensor            = reinterpret_cast<OPENSENSOR>             (GetProcAddress (h, "OpenSensor"));
	pCloseSensor           = reinterpret_cast<CLOSESENSOR>            (GetProcAddress (h, "CloseSensor"));
	pSensorCommand         = reinterpret_cast<SENSORCOMMAND>          (GetProcAddress (h, "SensorCommand"));
	pDataAvail             = reinterpret_cast<DATAAVAIL>              (GetProcAddress (h, "DataAvail"));
	pTransferData          = reinterpret_cast<TRANSFERDATA>           (GetProcAddress (h, "TransferData"));
	pTransferDataTS        = reinterpret_cast<TRANSFERDATATS>         (GetProcAddress (h, "TransferDataTS"));
	pPoll                  = reinterpret_cast<POLL>                   (GetProcAddress (h, "Poll"));
	pGetError              = reinterpret_cast<GETERROR>               (GetProcAddress (h, MU("GetError")));
	pGetDLLVersion         = reinterpret_cast<GETDLLVERSION>          (GetProcAddress (h, MU("GetDLLVersion")));
	pEnableLogging         = reinterpret_cast<ENABLELOGGING>          (GetProcAddress (h, MU("EnableLogging")));
	pOpenSensorRS232       = reinterpret_cast<OPENSENSORRS232>        (GetProcAddress (h, MU("OpenSensorRS232")));
	pOpenSensorIF2004      = reinterpret_cast<OPENSENSORIF2004>       (GetProcAddress (h, "OpenSensorIF2004"));
	pOpenSensorIF2004_USB  = reinterpret_cast<OPENSENSORIF2004_USB>   (GetProcAddress (h, MU("OpenSensorIF2004_USB")));
	pOpenSensorIF2008      = reinterpret_cast<OPENSENSORIF2008>       (GetProcAddress (h, "OpenSensorIF2008"));
	pOpenSensorIF2008_ETH  = reinterpret_cast<OPENSENSORIF2008_ETH>   (GetProcAddress (h, MU("OpenSensorIF2008_ETH")));
	pOpenSensorTCPIP       = reinterpret_cast<OPENSENSORTCPIP>        (GetProcAddress (h, MU("OpenSensorTCPIP")));
	pOpenSensorWinUSB      = reinterpret_cast<OPENSENSORWINUSB>       (GetProcAddress (h, "OpenSensorWinUSB"));
	pExecSCmd              = reinterpret_cast<EXECSCMD>               (GetProcAddress (h, MU("ExecSCmd")));
	pSetIntExecSCmd        = reinterpret_cast<SETINTEXECSCMD>         (GetProcAddress (h, MU("SetIntExecSCmd")));
	pSetDoubleExecSCmd     = reinterpret_cast<SETDOUBLEEXECSCMD>      (GetProcAddress (h, MU("SetDoubleExecSCmd")));
	pSetStringExecSCmd     = reinterpret_cast<SETSTRINGEXECSCMD>      (GetProcAddress (h, MU("SetStringExecSCmd")));
	pExecSCmdGetInt        = reinterpret_cast<EXECSCMDGETINT>         (GetProcAddress (h, MU("ExecSCmdGetInt")));
	pExecSCmdGetDouble     = reinterpret_cast<EXECSCMDGETDOUBLE>      (GetProcAddress (h, MU("ExecSCmdGetDouble")));
	pExecSCmdGetString     = reinterpret_cast<EXECSCMDGETSTRING>      (GetProcAddress (h, MU("ExecSCmdGetString")));
	if (!pCreateSensorInstance || !pCreateSensorInstByName || !pReleaseSensorInstance 
		|| !pSetParameterInt     || !pSetParameterDWORD_PTR  || !pSetParameterDouble   || !pSetParameterString || !pSetParameterBinary   || !pSetParameters
		|| !pGetParameterInt     || !pGetParameterDWORD_PTR  || !pGetParameterDouble   || !pGetParameterString || !pGetParameterBinary   || !pGetParameters
		|| !pClearAllParameters  || !pOpenSensor             || !pCloseSensor          || !pSensorCommand
		|| !pDataAvail           || !pTransferData           || !pTransferDataTS       || !pPoll
		|| !pGetError            || !pGetDLLVersion          || !pEnableLogging
		|| !pOpenSensorRS232     || !pOpenSensorIF2004       || !pOpenSensorIF2004_USB || !pOpenSensorIF2008   || !pOpenSensorIF2008_ETH || !pOpenSensorTCPIP || !pOpenSensorWinUSB
		|| !pExecSCmd            || !pSetIntExecSCmd         || !pSetDoubleExecSCmd    || !pSetStringExecSCmd
		|| !pExecSCmdGetInt      || !pExecSCmdGetDouble      || !pExecSCmdGetString)
		{
		FreeLibrary (h);
		return -1;
		}
	return 0;
	}	

int PrintError (LPCTSTR err)
	{
	_tprintf (_T("Error!\n%s\n"), err);
	return -1;
	}

int Error (LPCTSTR err, int sensor= 0)
	{
	TCHAR out[1024], buf[1024]= _T("");
	if (sensor>0)
		pGetError (sensor, buf, _countof (buf));
	_stprintf (out, _T("Error in %s\n%s"), err, buf);
	return PrintError (out);
	}

int Open (DWORD sensor)
	{
	CHECK_ERROR (pOpenSensorTCPIP (sensor, _T("169.254.168.150")));
	return ERR_NOERROR;
	}

int EnableEvent (DWORD sensor, HANDLE &dataAvailEvent)
	{
	CHECK_ERROR (pSetParameterString (sensor, _T("S_Command"), _T("DataAvail_Event")));
	CHECK_ERROR (pSetParameterInt (sensor, _T("IP_EventOnAvailableValues"), 1024));
	CHECK_ERROR (pSensorCommand (sensor));
	CHECK_ERROR (pGetParameterDWORD_PTR (sensor, _T("IA_DataAvailEvent"), (DWORD_PTR *)&dataAvailEvent));
	return 0;
	}

int GetInfo (DWORD sensor)
	{
	CHECK_ERROR (pSetParameterString (sensor, _T("S_Command"), _T("Get_AllParameters")));
	CHECK_ERROR (pSetParameterInt (sensor, _T("SP_Additional"), 1));
	CHECK_ERROR (pSensorCommand (sensor));

	double range;
	CHECK_ERROR (pGetParameterDouble (sensor, _T("SA_Range"), &range));
	_tprintf (_T("Sensor range: %.0f mm\n"), range);

	double measrate;
	CHECK_ERROR (pGetParameterDouble (sensor, _T("SA_Measrate"), &measrate));
	_tprintf (_T("Sensor measrate: %.0f kHz\n"), measrate);
	
	return ERR_NOERROR;
	}

int Process (int sensor, HANDLE dataAvailEvent)
	{
	int read;
	_tprintf (_T("Values: "));
	for (int i=0 ; i<10 ; i++)	// 10 cycles
		{
		double data[1024];

		if (WaitForSingleObject (dataAvailEvent, 1000)!=WAIT_OBJECT_0)
			return PrintError (_T("WaitForSingleObject failed!"));
		CHECK_ERROR (pTransferData (sensor, NULL, data, 1024, &read));
		if (read!=1024)
			return PrintError (_T("Data mismatch"));
		_tprintf (_T("%.1f "), data[0]);
		}
	return 0;
	}

void Cleanup (int sensor)
	{
	if (pCloseSensor (sensor)!=ERR_NOERROR)
		PrintError (_T("Cannot close sensor!"));
	if (pReleaseSensorInstance (sensor)!=ERR_NOERROR)
		PrintError (_T("Cannot release driver instance!"));
	}

int main(int /*argc*/, char* /*argv*/[])
	{
	int err= 0;
	if ((err= LoadDLLFunctions())<0)
		return PrintError(_T("Cannot load MEDAQLib.dll and it's functions!"));
	DWORD sensor= pCreateSensorInstance (SENSOR_IFD2421);
	if (!sensor)
		return PrintError(_T("Cannot create driver instance!"));

	if ((err= Open (sensor))<0)
		goto end;

	if ((err= GetInfo (sensor))<0)
		goto end;

	HANDLE dataAvailEvent= NULL;
	if ((err= EnableEvent (sensor, dataAvailEvent))<0)
		goto end;

	if ((err= Process (sensor, dataAvailEvent))<0)
		goto end;

end:
	Cleanup (sensor);
	return err;
	}
