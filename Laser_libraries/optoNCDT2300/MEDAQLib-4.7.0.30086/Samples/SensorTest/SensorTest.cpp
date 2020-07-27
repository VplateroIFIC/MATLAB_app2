#include <stdio.h> // printf, scanf, file IO
#include <string.h> // _stricmp
#if defined(_WIN32)
#include <stdlib.h> // _countof
#include <conio.h> // _kbhit
#else // _WIN32
#include <sys/select.h> // FD_SET, select
#include <unistd.h> // STDIN_FILENO
#define _stricmp strcasecmp
#define _countof(a) (sizeof(a)/sizeof(*(a)))
#endif //ifdef WIN32
#if !defined (MAX_PATH)
#define MAX_PATH	260
#endif

#include <float.h> // DBL_MAX
#include "../../MEDAQLib.h" // MEDAQLib.h must be included to know it's functions

static bool sensorIsMEBUS= false;
static bool videoStreamActive= false;

/** Helper function to set cursor at start of current line in console.
*/
void ClearLine()
	{
	printf ("\r"); // Jump at start of line, next printf will overwrite old content
	}

/** Show current progress in console.
*/
void ShowProgress (double progress)
	{
	printf ("Progress: %5.1f%%", progress);
#if !defined(_WIN32)
	fflush(stdout);
#endif
	}

/** Check if key was pressed, read character in case of.
*/
bool KeyPressed()
	{
#if defined(_WIN32)
	bool keyPressed= false;
	while (_kbhit())
		keyPressed|= _getch()!=0; // Function keys (F..., Ctrl-C, ...) writer two characters into keyboard buffer (first may be 0), so call getch() multiple times
	return keyPressed;
#else // _WIN32
	bool KeyIsPressed = false;
	int* pKeyCode = nullptr;
	struct timeval tv;
	fd_set rdfs;

	tv.tv_sec = tv.tv_usec = 0;

	FD_ZERO(&rdfs);
	FD_SET(STDIN_FILENO, &rdfs);

	select(STDIN_FILENO+1, &rdfs, nullptr, nullptr, &tv);

	if(FD_ISSET(STDIN_FILENO, &rdfs))
	{
		int KeyCode = getchar();
		if(pKeyCode != nullptr)
			*pKeyCode = KeyCode;
		KeyIsPressed = true;
	}

	return KeyIsPressed;
#endif //ifdef WIN32
	}

/** Close and release sensor instance, wait for a key pressed
*/
int32_t Cleanup (uint32_t sensorInstance, int32_t retCode= 0)
	{
	if (sensorInstance)
		{
		::CloseSensor (sensorInstance);
		::ReleaseSensorInstance (sensorInstance);
		}
	printf ("Press any key to exit");
#if !defined(_WIN32)
	fflush(stdout);
#endif // !_WIN32
	while (!KeyPressed())
		; // busy waiting
	return retCode;
	}

/** Retrieve error message after any MEDAQLib function returned an error
*/
void ShowLastError (uint32_t sensorInstance, const char *location)
	{
	char lastError[2048]= "\0";
	::GetError (sensorInstance, lastError, _countof (lastError));
	printf ("\nError at '%s'\n", location);
	printf ("%s\n", lastError);

	int32_t errNumber;
	if (::GetParameterInt (sensorInstance, "SA_ErrorNumber", &errNumber)==ERR_NOERROR)
		printf ("Sensor error number: %d\n", errNumber);

	char errText[1024]= "\0";
	uint32_t tmp= _countof (errText);
	if (::GetParameterString (sensorInstance, "SA_ErrorText", errText, &tmp)==ERR_NOERROR)
		printf ("Sensor error text: '%s'\n", errText);
	}

/** Macro to encapsulate error handling when calling MEDAQLib functions.
* Can only be used if variable sensorInstance exists.
*/
#define CHECK_ERROR(expr) \
	{ \
	const ERR_CODE ceRet= expr; \
	if (ceRet!=ERR_NOERROR) \
		{ \
		ShowLastError (sensorInstance, #expr); \
		if (ceRet!=ERR_WARNING && ceRet!=ERR_SENSOR_ANSWER_WARNING) \
			{ \
			Cleanup (sensorInstance); \
			return false; \
			} \
		} \
	}

/** Print short help on console
*/
int32_t Usage()
	{
	printf ("Usage:\nSensorTest <Sensor name> [InterfaceParam=Value] ...\n");
	printf ("Value can be an integer number (without dot) or a double number (with dot) or a string.\n");
	printf ("If a parameter contains a space, it must be quoted by \"...\".\n");
	printf ("If a command file should be processed after connecting, set parameter Commands=\"<File name>\"\n\n");
	printf ("Examples:\n");
	printf ("SensorTest ILD2300 (will use SensorFinder to detect ILD2300)\n");
	printf ("SensorTest IFD2451 IP_Interface=TCP/IP IP_RemoteAddr=192.168.1.10 (connect to IFD2451 via TCP/IP on a fixed address)\n\n");
	printf ("Format of command file:\n");
	printf ("Each command is at an own line. Command parameters are separated by spaces.\n");
	printf ("A command line is limited to 2048 characters.\n");
	printf ("If parameter S_Command is missing the whole line is skipped.\n");
	printf ("e.g.: S_Command=Set_DataOutInterface SP_DataOutInterface=2\n");
	Cleanup (0);
	return 0;
	}

/** Extracts and processes command line parameters
*/
bool ParseParameters (uint32_t sensorInstance, int32_t argc, const char *const argv[])
	{
	if (!argv)
		return false;
	for (int32_t i=2 ; i<argc ; i++)
		CHECK_ERROR (::SetParameters  (sensorInstance, argv[i]));
	return true;
	}

/** Convert a parity enum to a string
*/
const char *ParityToString (uint32_t parity)
	{
	const char *const strings[]= { "No parity", "Odd parity", "Even parity", "Mark parity", "Space parity", "Invalid parity" };
	return strings[parity<_countof (strings) ? parity : _countof (strings)-1];
	}

/** Convert a stop bit enum to a string
*/
const char *StopbitsToString (uint32_t stopbits)
	{
	const char *const strings[]= { "One stop bit", "One point five stop bits", "Two stop bits", "Invalid stop bits" };
	return strings[stopbits<_countof (strings) ? stopbits : _countof (strings)-1];
	}

/** Print RS232 interface parameters at console
*/
bool PrintRS232 (uint32_t sensorInstance)
	{
	char port[64]= {};
	uint32_t len= _countof (port);
	int32_t baudrate= 0, byteSize= 0, parity= 0, stopbits= 0, sensorAddress= 0;
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_Port", port, &len));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_Baudrate", &baudrate));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_ByteSize", &byteSize));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_Parity", &parity));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_Stopbits", &stopbits));
	const ERR_CODE ret= ::GetParameterInt (sensorInstance, "IP_SensorAddress", &sensorAddress);
	if (ret!=ERR_NOERROR && ret!=ERR_NOT_FOUND)
		CHECK_ERROR (::GetParameterInt (sensorInstance, "IP_SensorAddress", &sensorAddress));
	printf ("%s, %d Baud, %d data bits, %s, %s", port, baudrate, byteSize, ParityToString (parity), StopbitsToString (stopbits));
	if (ret==ERR_NOERROR)
		printf (", RS485 addr: %d", sensorAddress);
	return true;
	}

/** Print IF2004 interface parameters at console
*/
bool PrintIF2004 (uint32_t sensorInstance)
	{
	int32_t cardInstance= 0, channelNumber= 0, baudrate= 0;
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_CardInstance", &cardInstance));
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_ChannelNumber", &channelNumber));
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_Baudrate", &baudrate));
	printf ("Card %d, Channel %d, %d Baud", cardInstance, channelNumber, baudrate);
	return true;
	}

/** Print TCP/IP interface parameters at console
*/
bool PrintTCPIP (uint32_t sensorInstance)
	{
	char ipAddress[64]= {};
	uint32_t len= _countof (ipAddress);
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_RemoteAddr", ipAddress, &len));
	printf ("%s", ipAddress);
	return true;
	}

/** Print USB interface parameters at console
*/
bool PrintUSB (uint32_t sensorInstance)
	{
	int32_t deviceInstance;
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_DeviceInstance", &deviceInstance));
	printf ("Instance %d", deviceInstance);
	return true;
	}

/** Print IF2004_USB parameters at console
*/
bool PrintIF2004_USB (uint32_t sensorInstance)
	{
	int32_t deviceInstance= 0, channelNumber= 0, baudrate= 0;
	char serialNumber[64]= {}, port[64]= {};
	uint32_t len= _countof (port);
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_DeviceInstance", &deviceInstance));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_ChannelNumber", &channelNumber));
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_Port", port, &len));
	len= _countof (serialNumber);
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_SerialNumber", serialNumber, &len));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_Baudrate", &baudrate));
	printf ("Device %d (SN%s, %s), Channel %d, %d Baud", deviceInstance, serialNumber, port, channelNumber, baudrate);
	return true;
	}

/** Print IF2008 interface parameters at console
*/
bool PrintIF2008 (uint32_t sensorInstance)
	{
	int32_t cardInstance= 0, channelNumber= 0, baudrate= 0, parity= 0;
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_CardInstance", &cardInstance));
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_ChannelNumber", &channelNumber));
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_Baudrate", &baudrate));
	CHECK_ERROR (::GetParameterInt  (sensorInstance, "IP_Parity", &parity));
	printf ("Card %d, Channel %d, %d Baud, %s", cardInstance, channelNumber, baudrate, ParityToString (parity));
	return true;
	}

/** Print IF2008_ETH interface parameters at console
*/
bool PrintIF2008_ETH (uint32_t sensorInstance, bool showSensorParam)
	{
	char ipAddress[64]= {};
	int32_t channelNumber= 0, baudrate= 0;
	uint32_t len= _countof (ipAddress);
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_RemoteAddr", ipAddress, &len));
	printf ("%s", ipAddress);
	if (showSensorParam)
		{
		CHECK_ERROR (::GetParameterInt (sensorInstance, "IP_ChannelNumber", &channelNumber));
		CHECK_ERROR (::GetParameterInt (sensorInstance, "IP_Baudrate", &baudrate));
		printf (", Channel %d, %d Baud", channelNumber, baudrate);
		}
	return true;
	}

/** Show one result of SensorFinder at console
*/
bool ShowFoundSensor (uint32_t sensorInstance, int32_t sensorIndex)
	{
	int32_t hardwareInterface= 0, sensorType= 0;
	char sensorTypeName[64]= {}, hwInterfaceName[64]= {}, serialNumber[64]= {};
	uint32_t len= 0;
	CHECK_ERROR (::SetIntExecSCmd     (sensorInstance, "Get_FoundSensor", "IP_Index", sensorIndex));
	len= _countof (sensorTypeName);
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_SensorType", &sensorType));
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_SensorTypeName", sensorTypeName, &len));
	CHECK_ERROR (::GetParameterInt    (sensorInstance, "IP_InterfaceIdx", &hardwareInterface));
	len= _countof (hwInterfaceName);
	CHECK_ERROR (::GetParameterString (sensorInstance, "IP_Interface", hwInterfaceName, &len));
	printf ("%d: %s at %s (", sensorIndex, sensorTypeName, hwInterfaceName);
	switch (hardwareInterface)
		{
		case  1: if (!PrintRS232      (sensorInstance)) return false; break;
		case  2: if (!PrintIF2004     (sensorInstance)) return false; break;
		case  3: if (!PrintTCPIP      (sensorInstance)) return false; break;
		case  4: if (!PrintUSB        (sensorInstance)) return false; break;
		case  5: if (!PrintUSB        (sensorInstance)) return false; break;
		case  6: if (!PrintIF2008     (sensorInstance)) return false; break;
		case  7: if (!PrintUSB        (sensorInstance)) return false; break;
		case  8: if (!PrintIF2004_USB (sensorInstance)) return false; break;
		case 10: if (!PrintIF2008_ETH (sensorInstance, sensorType!=ETH_ADAPTER_IF2008)) return false; break;
		}
	printf (")");
	len= _countof (serialNumber);
	if (::GetParameterString (sensorInstance, "SA_SerialNumber", serialNumber, &len)==ERR_NOERROR)
		printf (", Serial number %s", serialNumber);
	printf ("\n");
	return true;
	}

/** Seach for specified sensor at any interface and selects one sensor
*/
bool SensorFinder (uint32_t &sensorInstance)
	{
	int32_t enableLogging= 0;
	::GetParameterInt (sensorInstance, "IP_EnableLogging", &enableLogging);
	if (enableLogging)
		CHECK_ERROR (::SetIntExecSCmd (sensorInstance, "Enable_Logging", "CP_ClearSendParameters", 0));

	printf ("Scanning for sensors (press any key to abort)\n");
	double progress= 0;
	int32_t found= 0, processed= 0;
	ShowProgress (progress);
	CHECK_ERROR (::ExecSCmd (sensorInstance, "Start_FindSensor"));
	do
		{
		CHECK_ERROR (::SetIntExecSCmd (sensorInstance, "Exec_SleepTime", "IP_SleepTime", 50/*ms*/));
		ClearLine();
		CHECK_ERROR (::ExecSCmdGetDouble (sensorInstance, "Get_FindSensorProgress", "IA_Progress", &progress));
		CHECK_ERROR (::GetParameterInt   (sensorInstance, "IA_Found", &found));
		while (found>processed)
			if (!ShowFoundSensor  (sensorInstance, processed++))
				return false;
		if (KeyPressed())
			CHECK_ERROR (::ExecSCmd (sensorInstance, "Abort_FindSensor"));
		ShowProgress (progress);
		} while (progress<100.0);
	ClearLine();

	int32_t sensorIndex= -1;
	if (found<=0)
		{
		printf ("Specified sensor is not found\n");
		Cleanup (sensorInstance);
		return false;
		}
	else if (found==1)
		sensorIndex= 0;
	else // more sensors found
		{
		printf ("Please type sensor index <CR> to open sensor: ");
		const int32_t cnt= scanf ("%d", &sensorIndex);
		if (cnt!=1 || sensorIndex<0 || sensorIndex>=found)
			{
			printf ("No valid sensor selected\n");
			Cleanup (sensorInstance);
			return false;
			}
		}
	// Following function requests all interface parameters for selected sensor. Now it can be used at OpenSensor.
	CHECK_ERROR (::SetIntExecSCmd (sensorInstance, "Get_FoundSensor", "IP_Index", sensorIndex));
	int32_t similarSensor= false;
	::GetParameterInt (sensorInstance, "IP_SimilarSensor", &similarSensor); // Ignore error if parameter does not exist
	if (similarSensor) // Other sensor as expected was found (if IP_FindSimilarSensors is set)
		{
		char parameterList[4096]= {}; // 4K should be enough
		uint32_t maxLen= _countof (parameterList);
		ME_SENSOR sensorType= NO_SENSOR;
		CHECK_ERROR (::GetParameterInt (sensorInstance, "IP_SensorType", reinterpret_cast<int32_t *>(&sensorType)));
		CHECK_ERROR (::GetParameters (sensorInstance, parameterList, &maxLen));

		const uint32_t oldInstance= sensorInstance;
		sensorInstance= CreateSensorInstance (sensorType); // so create a new one using correct sensor type
		CHECK_ERROR (::SetParameters (sensorInstance, parameterList));
		::ReleaseSensorInstance (oldInstance); // and release old instance
		}
	return true;
	}

/** Connect to sensor
*/
bool Open (uint32_t sensorInstance)
	{
	printf ("Connecting to sensor\n");
	CHECK_ERROR (::OpenSensor (sensorInstance));
	return true;
	}

bool ProcessSensorCommands (uint32_t sensorInstance, const char *cmdFileName)
	{
	enum { CommSize= 65536 };
	FILE *f= fopen (cmdFileName, "rt");
	if (!f)
		{
		printf ("Could not open command file '%s', skip it\n", cmdFileName);
		return true;
		}
	char *cmdLine= new char[CommSize], *answer= new char[CommSize];
	if (!cmdLine || !answer)
		{
		fclose (f);
		if (cmdLine) delete []cmdLine;
		if (answer)  delete []answer;
		printf ("ProcessSensorCommands: Could not allocate buffer\n");
		Cleanup (sensorInstance);
		return false;
		}
	while (fgets (cmdLine, CommSize, f))
		{
		ERR_CODE ret= ::ClearAllParameters (sensorInstance);
		if (ret!=ERR_NOERROR)
			{
			fclose (f);
			delete[]cmdLine;
			delete[]answer;
			ShowLastError (sensorInstance, "ClearAllParameters");
			Cleanup (sensorInstance);
			return false;
			}
		ret= ::SetParameters (sensorInstance, cmdLine);
		if (ret!=ERR_NOERROR)
			{
			fclose (f);
			delete[]cmdLine;
			delete[]answer;
			ShowLastError (sensorInstance, "SetParameters");
			Cleanup (sensorInstance);
			return false;
			}
		uint32_t tmp;
		if (::GetParameterString (sensorInstance, "S_Command", nullptr, &tmp)==ERR_NOT_FOUND) // S_Command not specified
			continue;
		printf ("Executing command line: %s", cmdLine);
		tmp= CommSize;
		ret= ::SensorCommand (sensorInstance);
		if (ret!=ERR_NOERROR)
			ShowLastError (sensorInstance, "SensorCommand");
		else
			printf ("\nSuccess!\n");
		if (ret==ERR_NOERROR || ret==ERR_WARNING || ret==ERR_SENSOR_ANSWER_WARNING)
			{
			ret= ::GetParameters (sensorInstance, answer, &tmp);
			if (ret!=ERR_NOERROR)
				{
				fclose (f);
				delete[]cmdLine;
				delete[]answer;
				ShowLastError (sensorInstance, "SetParameters");
				Cleanup (sensorInstance);
				return false;
				}
			printf ("\nAnswer parameters: %s\n", answer);
			}
		}
	fclose (f);
	delete[]cmdLine;
	delete[]answer;
	return true;
	}

/** Retrieve information about transmitted data from sensor and show it at console
*/
bool GetTransmittedDataInfo (uint32_t sensorInstance, int32_t &valsPerFrame)
	{
	uint32_t maxLen= 0;
	int32_t maxValsPerFrame= 0, index= 0;
	char sName[64]= {}, rawName[256]= {}, scaledName[256]= {}, rawUnit[256]= {}, scaledUnit[256]= {};
	double rawRangeMin= 0.0, rawRangeMax= 0.0, scaledRangeMin= 0.0, scaledRangeMax= 0.0, rawDatarate= 0.0, scaledDatarate= 0.0;
	CHECK_ERROR (::ExecSCmdGetInt (sensorInstance, "Get_TransmittedDataInfo", "IA_ValuesPerFrame", &valsPerFrame));
	CHECK_ERROR (::GetParameterInt (sensorInstance, "IA_MaxValuesPerFrame", &maxValsPerFrame));

	printf ("\nSensor transmits %d of %d possible values\n", valsPerFrame, maxValsPerFrame);
	for (int32_t i=0 ; i<valsPerFrame ; i++)
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

		printf (" %2d: %s [%.1f .. %.1f %s] @ %.1f Hz, %s [%g .. %g %s] @ %.1f Hz\n", index, rawName, rawRangeMin, rawRangeMax, rawUnit, rawDatarate, scaledName, scaledRangeMin, scaledRangeMax, scaledUnit, scaledDatarate);
		}

	int32_t videoSignalsPerFrame= 0, videoSignalPixelCount= 0, videoSignalPixelByteSize= 0;
	char videoSignalName[256]= {};
	::GetParameterInt (sensorInstance, "IA_VideoSignalsPerFrame", &videoSignalsPerFrame); // This parameter may not exist, so ignore errors
	if (videoSignalsPerFrame>0)
		{
		videoStreamActive= true;
		printf ("\nSensor transmits %d video signals\n", videoSignalsPerFrame);
		for (int32_t i=0; i<videoSignalsPerFrame; i++)
			{
			sprintf (sName, "IA_VideoSignalName%d", i+1);
			maxLen= _countof (videoSignalName);
			CHECK_ERROR (::GetParameterString (sensorInstance, sName, videoSignalName, &maxLen));

			sprintf (sName, "IA_VideoSignalPixelCount%d", i+1);
			CHECK_ERROR (::GetParameterInt (sensorInstance, sName, &videoSignalPixelCount));

			sprintf (sName, "IA_VideoSignalPixelByteSize%d", i+1);
			CHECK_ERROR (::GetParameterInt (sensorInstance, sName, &videoSignalPixelByteSize));

			printf (" %s (%d pixel each %d bytes) with length %d bytes\n", videoSignalName, videoSignalPixelCount, videoSignalPixelByteSize, videoSignalPixelCount*videoSignalPixelByteSize);
			}
		}
	return true;
	}

//#define CHECK_MONOTONY // Only possible for counter values
#ifdef CHECK_MONOTONY
void CheckMonotony (int32_t count, const double *values)
	{
	static double sLastVal= -1;
	for (int32_t i=0; i<count; i++)
		{
		if (sLastVal!=-1/*at Start*/ && values[i]!=0/*wrap around after overflow*/ && values[i]-sLastVal!=1)
			printf ("\nMonotony error: %.1f .. %.1f\n", sLastVal, values[i]);
		sLastVal= values[i];
		}
	}
#endif

#define MEAS_FREQUENCY
#ifdef MEAS_FREQUENCY
double MeasureFrequency (uint32_t sensorInstance, int32_t actValues)
	{
	static double sValues= 0, sStart= 0;
	double actual;
	ExecSCmdGetDouble (sensorInstance, "Get_HighResolutionTime", "IA_HighResolutionTime", &actual);
	if (sStart==0) // First time
		{
		sStart= actual;
		return 0;
		}
	sValues+= actValues;
	return sValues / (actual-sStart) * 1000.0 /*[Hz]*/;
	}
#endif

bool OutputTimeReached (uint32_t sensorInstance)
	{
	enum { OutputIntervall= 100/*ms*/ };
	static double sLastTime= 0;
	double actual;
	ExecSCmdGetDouble (sensorInstance, "Get_HighResolutionTime", "IA_HighResolutionTime", &actual);
	if (actual-sLastTime>=OutputIntervall)
		{
		sLastTime= actual;
		return true;
		}
	else
		return false;
	}

/** Read continuous data from sensor and show each first frame at console
*/
bool GetData (uint32_t sensorInstance, int32_t valsPerFrame)
	{
	enum { BufSize= 15000 };
	int32_t sleepTime= 50;
	printf ("\nReading data continuous (press any key to abort)\n");
	int32_t avail= 0;
	int32_t *rawData= new int32_t[BufSize];
	double  *scaledData= new double[BufSize];
	double timestamp= 0.0;
	if (!rawData || !scaledData)
		{
		if (rawData)    { delete []rawData;    rawData=    nullptr;	}
		if (scaledData) { delete []scaledData; scaledData= nullptr;	}
		printf ("GetData: Could not allocate buffer\n");
		}
	while (!KeyPressed())
		{
		if (sleepTime>0)
			CHECK_ERROR (::SetIntExecSCmd (sensorInstance, "Exec_SleepTime", "IP_SleepTime", sleepTime/*ms*/));
		if (sensorIsMEBUS)
			::ExecSCmd (sensorInstance, "Get_Measure");
		if (videoStreamActive)
			{
			::SetParameterInt (sensorInstance, "SP_ReadMode", 2/*Automatic*/);
			::SetParameterInt (sensorInstance, "SP_WaitVideoTimeout", 500/*ms*/);
			::ExecSCmd (sensorInstance, "Get_VideoStreamSignal");
			}
		CHECK_ERROR (::DataAvail (sensorInstance, &avail));
		if (avail<valsPerFrame)
			continue;
		int32_t read= avail;
		if (read>BufSize)
			read= BufSize;
		CHECK_ERROR (::TransferDataTS (sensorInstance, rawData, scaledData, read, &read, &timestamp)); // Read up to [buffer size] values
		if (read<valsPerFrame)
			{
			if (rawData)    { delete[]rawData;    rawData=    nullptr; }
			if (scaledData) { delete[]scaledData; scaledData= nullptr; }
			printf ("Error at '::TransferDataTS (sensorInstance, rawData, scaledData, _countof (rawData), &read)'\nTo less values (%d) was read.\n", read);
			return false;
			}
		if (avail>read) // More data avail?
			CHECK_ERROR (::TransferData (sensorInstance, nullptr, nullptr, avail-read, nullptr)); // Read rest of values without processing to avoid buffer overflows
#ifdef MEAS_FREQUENCY
		const double frequency= valsPerFrame ? MeasureFrequency (sensorInstance, avail)/valsPerFrame : 0;
#endif
#ifdef CHECK_MONOTONY
		CheckMonotony (read, scaledData);
#endif

		if (OutputTimeReached (sensorInstance))
			{
			ClearLine();
			printf ("[%5d/%5d] ", read, avail);
			for (int32_t i=0; i<valsPerFrame; i++)
				{
				if (scaledData[i]==-DBL_MAX) // MEDAQLib default error value
					printf ("%u (error value)", static_cast<uint32_t>(rawData[i]));
				else
					printf ("%u (%-.3f)", static_cast<uint32_t>(rawData[i]), scaledData[i]);
				if (i<valsPerFrame-1)
					printf (", ");
				}
			printf (", TS %.3f", timestamp);
#ifdef MEAS_FREQUENCY
			printf (" @ %.3f Hz", frequency);
#endif
#if !defined(_WIN32)
			fflush( stdout );
#endif //if not def Win32
			} // OutputTimeReached()
		} // while (!KeyPressed());
	if (rawData)    { delete[]rawData;    rawData=    nullptr; }
	if (scaledData) { delete[]scaledData; scaledData= nullptr; }
	printf ("\n");
	return true;
	}

/** Main SensorTest program
*/
int main (int argc, char *argv[])
	{
	if (argc<2 || !argv)
		return Usage();

	printf ("SensorTest %s\n", argv[1]);
	uint32_t sensorInstance= ::CreateSensorInstByName (argv[1]);
	if (!sensorInstance)
		{
		printf ("Cannot create driver instance of sensor '%s'!\n", argv[1]);
		return Cleanup (sensorInstance, -1);
		}

	if ((_stricmp(argv[1], "ME-BUS") == 0) || (_stricmp(argv[1], "MEBUS") == 0)  || (_stricmp (argv[1], "SensorOnMEBus") == 0) || (_stricmp(argv[1], "DT6120") == 0))
		sensorIsMEBUS = true;

	if (!ParseParameters (sensorInstance, argc, argv))
		return Cleanup (sensorInstance, -2);
	char cmdFileName[MAX_PATH]= "\0";
	uint32_t tmp= _countof (cmdFileName);
	::GetParameterString (sensorInstance, "Commands", cmdFileName, &tmp);
	if (::GetParameterString (sensorInstance, "IP_Interface", nullptr, &tmp)==ERR_NOT_FOUND) // Interface not specified, 
		{
		if (!SensorFinder (sensorInstance)) // so start SensorFinder
			return Cleanup (sensorInstance, -3);
		if (!ParseParameters (sensorInstance, argc, argv))
			return Cleanup (sensorInstance, -4);
		}

	if (!Open (sensorInstance))
		return Cleanup (sensorInstance, -5);

	if (*cmdFileName && !ProcessSensorCommands (sensorInstance, cmdFileName))
		return Cleanup (sensorInstance, -6);

	int32_t valsPerFrame;
	if (!GetTransmittedDataInfo (sensorInstance, valsPerFrame))
		return Cleanup (sensorInstance, -7);
	if (!GetData (sensorInstance, valsPerFrame))
		return Cleanup (sensorInstance, -8);
	return Cleanup (sensorInstance);
	}
