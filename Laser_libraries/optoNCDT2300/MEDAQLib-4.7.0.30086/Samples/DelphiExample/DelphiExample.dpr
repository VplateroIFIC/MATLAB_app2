program DelphiExample;

{$APPTYPE CONSOLE}

uses
  SysUtils, WinTypes, Math;

function CreateSensorInstance   (sensor: Integer):       Integer; stdcall; external 'MEDAQLib.dll';
function CreateSensorInstByName (sensorName: PAnsiChar): Integer; stdcall; external 'MEDAQLib.dll';
function ReleaseSensorInstance  (instanceHandle: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function SetParameterInt        (instanceHandle: Integer; paramName: PAnsiChar; paramValue: Integer):                        Integer; stdcall; external 'MEDAQLib.dll';
function SetParameterDWORD_PTR  (instanceHandle: Integer; paramName: PAnsiChar; paramValue: DWORD):                          Integer; stdcall; external 'MEDAQLib.dll';
function SetParameterDouble     (instanceHandle: Integer; paramName: PAnsiChar; paramValue: Double):                         Integer; stdcall; external 'MEDAQLib.dll';
function SetParameterString     (instanceHandle: Integer; paramName: PAnsiChar; paramValue: PAnsiChar):                      Integer; stdcall; external 'MEDAQLib.dll';
function SetParameterBinary     (instanceHandle: Integer; paramName: PAnsiChar; paramValue: PAnsiChar; maxLen: Integer):     Integer; stdcall; external 'MEDAQLib.dll';
function SetParameters          (instanceHandle: Integer; paramList: PAnsiChar):                                             Integer; stdcall; external 'MEDAQLib.dll';
function GetParameterInt        (instanceHandle: Integer; paramName: PAnsiChar; var paramValue: Integer):                    Integer; stdcall; external 'MEDAQLib.dll';
function GetParameterDWORD_PTR  (instanceHandle: Integer; paramName: PAnsiChar; var paramValue: DWORD):                      Integer; stdcall; external 'MEDAQLib.dll';
function GetParameterDouble     (instanceHandle: Integer; paramName: PAnsiChar; var paramValue: Double):                     Integer; stdcall; external 'MEDAQLib.dll';
function GetParameterString     (instanceHandle: Integer; paramName: PAnsiChar; paramValue: PAnsiChar; var maxLen: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function GetParameterBinary     (instanceHandle: Integer; paramName: PAnsiChar; paramValue: PAnsiChar; var maxLen: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function GetParameters          (instanceHandle: Integer;                    parameterList: PAnsiChar; var maxLen: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function ClearAllParameters     (instanceHandle: Integer):                                                                   Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensor             (instanceHandle: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function CloseSensor            (instanceHandle: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function SensorCommand          (instanceHandle: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function DataAvail              (instanceHandle: Integer; var avail: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function TransferData           (instanceHandle: Integer; rawData: PInteger; scaledData: PDouble; maxValues: Integer; var read: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function TransferDataTS         (instanceHandle: Integer; rawData: PInteger; scaledData: PDouble; maxValues: Integer; var read: Integer, timestamp: PDouble): Integer; stdcall; external 'MEDAQLib.dll';
function Poll                   (instanceHandle: Integer; rawData: PInteger; scaledData: PDouble; maxValues: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function GetError               (instanceHandle: Integer; errText: PAnsiChar; maxLen: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function GetDLLVersion          (versionStr: PAnsiChar; maxLen: Integer):                       Integer; stdcall; external 'MEDAQLib.dll';
function EnableLogging          (instanceHandle: Integer; enableLogging: Integer; logType: Integer; logLevel: Integer; logFile: PAnsiChar; logAppend: Integer; logFlush: Integer; logSplitSize: Integer): Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorRS232        (instanceHandle: Integer; port: PAnsiChar):                                                                                 Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorIF2004       (instanceHandle: Integer; cardInstance: Integer; channelNumber: Integer):                                                   Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorIF2004_USB   (instanceHandle: Integer; deviceInstance: Integer; serialNumber: PAnsiChar; port: PAnsiChar; channelNumber: Integer):       Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorIF2008       (instanceHandle: Integer; cardInstance: Integer; channelNumber: Integer):                                                   Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorIF2008_ETH   (instanceHandle: Integer; remoteAddr: PAnsiChar; channelNumber: Integer):                                                   Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorTCPIP        (instanceHandle: Integer; remoteAddr: PAnsiChar):                                                                           Integer; stdcall; external 'MEDAQLib.dll';
function OpenSensorWinUSB       (instanceHandle: Integer; deviceInstance: Integer):                                                                         Integer; stdcall; external 'MEDAQLib.dll';
function ExecSCmd               (instanceHandle: Integer; sensorCommand: PAnsiChar):                                                                        Integer; stdcall; external 'MEDAQLib.dll';
function SetIntExecSCmd         (instanceHandle: Integer; sensorCommand: PAnsiChar; paramName: PAnsiChar;     paramValue: Integer):                         Integer; stdcall; external 'MEDAQLib.dll';
function SetDoubleExecSCmd      (instanceHandle: Integer; sensorCommand: PAnsiChar; paramName: PAnsiChar;     paramValue: Double):                          Integer; stdcall; external 'MEDAQLib.dll';
function SetStringExecSCmd      (instanceHandle: Integer; sensorCommand: PAnsiChar; paramName: PAnsiChar;     paramValue: PAnsiChar):                       Integer; stdcall; external 'MEDAQLib.dll';
function ExecSCmdGetInt         (instanceHandle: Integer; sensorCommand: PAnsiChar; paramName: PAnsiChar; var paramValue: Integer):                         Integer; stdcall; external 'MEDAQLib.dll';
function ExecSCmdGetDouble      (instanceHandle: Integer; sensorCommand: PAnsiChar; paramName: PAnsiChar; var paramValue: Double):                          Integer; stdcall; external 'MEDAQLib.dll';
function ExecSCmdGetString      (instanceHandle: Integer; sensorCommand: PAnsiChar; paramName: PAnsiChar;     paramValue: PAnsiChar; var maxLen: Integer):  Integer; stdcall; external 'MEDAQLib.dll';

const ERR_NOERROR= 0; ERR_NOT_FOUND= -25;
const CRLF= #10#13;

procedure Error (err: PAnsiChar);
begin
  Write (err);
end;

procedure ErrorMsgGetErr (err: PAnsiChar; sensor: Integer);
var buf: array [0..1023] of char;
begin
	buf[0]:= #0;
	GetError (sensor, buf, SizeOf (buf));
	Error (PAnsiChar (Format ('Error in %s%s%s', [err, CRLF, buf])));
end;

function Open (sensor: Integer): Boolean;
var err: Integer;
begin
	err:= OpenSensorRS232 (sensor, 'COM1');
	if (err<>ERR_NOERROR) then
  begin
		ErrorMsgGetErr ('OpenSensorRS232 (, COM1)', sensor);
    Open:= False;
    exit;
  end;

  Open:= True;
end;

function GetInfo (sensor: Integer): Boolean;
var err, iErr, len: Integer; cErr: array [0..1023] of char; range: Double;
begin
	err:= ExecSCmd (sensor, 'Get_Info');
	if (err<>ERR_NOERROR) then
  begin
		ErrorMsgGetErr ('ExecSCmd (Get_Info)', sensor);
  	GetInfo:= False;
    exit;
  end;

  iErr:= 0;
	err:= GetParameterInt (sensor, 'SA_ErrorNumber', iErr);
	if ((err<>ERR_NOERROR) and (err<>ERR_NOT_FOUND)) then
  begin
		ErrorMsgGetErr ('GetParameterInt (SA_ErrorNumber)', sensor);
  	GetInfo:= False;
    exit;
  end;

	if (iErr<>0) then
	begin
		len:= sizeof (cErr);
		GetParameterString (sensor, 'SA_ErrorText', cErr, len);
		ErrorMsgGetErr (PAnsiChar (Format ('Sensor returned error code after command Get_Info%s%d: %s', [CRLF, iErr, cErr])), sensor);
  	GetInfo:= False;
    exit;
  end;

	err:= GetParameterDouble (sensor, 'SA_Range', range);
	if (err<>ERR_NOERROR) then
  begin
		ErrorMsgGetErr ('GetParameterDouble (SA_Range)', sensor);
  	GetInfo:= False;
    exit;
  end;

  writeLn (PAnsiChar (Format ('Sensor range: %.0f mm', [range])));

	GetInfo:= True;
end;

function Process (sensor: Integer): Boolean;
var err, i, j, avail, read: Integer; data: array [0..10000] of double;
begin
	for i:=0 to 10 do	// 10 cycles
  begin
		err:= DataAvail (sensor, avail);
		if (err<>ERR_NOERROR) then
			ErrorMsgGetErr ('DataAvail', sensor);
		writeLn (PAnsiChar (Format ('Values avail: %04d', [avail])));

    if (avail>10000) then avail:= 10000;

		err:= TransferData (sensor, NIL, @data, avail, read);
		if (err<>ERR_NOERROR) then
			ErrorMsgGetErr ('TransferData', sensor);
		write ('Few values: ');
		for j:=0 to Min (5, read) do
			write (PAnsiChar (Format ('%.3f ', [data[j]])));
		writeLn ('');

		Sleep (500);	// wait for new data
  end;
  Process:= True;
end;

var sensor: Integer; err: Integer;

begin
  sensor:= CreateSensorInstByName ('ILD1420');
  if (sensor=0) then
  begin
    Error ('Cannot create driver instance!');
    exit;
  end;

	if (Open (sensor)=False) then
  begin
		ReleaseSensorInstance (sensor);
    exit;
  end;

	if (GetInfo (sensor)=False) then
  begin
		CloseSensor (sensor);
		ReleaseSensorInstance (sensor);
    exit;
  end;

	if (Process (sensor)=False) then
  begin
		CloseSensor (sensor);
		ReleaseSensorInstance (sensor);
    exit;
  end;

	err:= CloseSensor (sensor);
	if (err<>ERR_NOERROR) then
  begin
		ErrorMsgGetErr ('CloseSensor', sensor);
		ReleaseSensorInstance (sensor);
    exit;
  end;

	err:= ReleaseSensorInstance (sensor);
	if (err<>ERR_NOERROR) then
  begin
		ErrorMsgGetErr ('ReleaseSensorInstance', sensor);
    exit;
  end;

end.
