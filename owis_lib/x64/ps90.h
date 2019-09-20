/*
*
* ps90.h
* created:      12.06.2006  alex
* last change:  07.02.2014  alex
*
*/

#ifndef __MYPS90	// Schutz vor Mehrfacheinbindung
#define __MYPS90


#ifdef __cplusplus
extern "C" {
#endif

// System
long    __stdcall PS90_Connect (long,long,long,long,long,long,long,long);
long    __stdcall PS90_SimpleConnect (long,const char*);
long    __stdcall PS90_Disconnect (long);
long    __stdcall PS90_GetConnectInfo (long,char*,long);
long    __stdcall PS90_GetMessage (long,char*,long);
long    __stdcall PS90_GetTerminal (long);
long    __stdcall PS90_SetTerminal (long,long);
long    __stdcall PS90_GetBoardVersion (long,char*,long);
long    __stdcall PS90_GetDriveVersion (long,long,char*,long);
long    __stdcall PS90_GetSerNumber (long,char*,long);
long    __stdcall PS90_GetError (long);
long    __stdcall PS90_CheckMem (long);
long    __stdcall PS90_ResetBoard (long);
long    __stdcall PS90_ResetDrives (long);
long    __stdcall PS90_ClearError (long);
long    __stdcall PS90_GetVersionNumber (long); // only for OWISoft

// Operate
long    __stdcall PS90_MotorInit (long,long);
long    __stdcall PS90_MotorOn (long,long);
long    __stdcall PS90_MotorOff (long,long);
long    __stdcall PS90_GetTargetMode (long,long);
long    __stdcall PS90_SetTargetMode (long,long,long);
long    __stdcall PS90_GetPosMode (long,long);
long    __stdcall PS90_SetPosMode (long,long,long);
long    __stdcall PS90_GetPosition (long,long);
long    __stdcall PS90_SetPosition (long,long,long);
long    __stdcall PS90_ResetCounter (long,long);
long    __stdcall PS90_GetTarget (long,long);
long    __stdcall PS90_SetTarget (long,long,long);
long    __stdcall PS90_GoTarget (long,long);
long    __stdcall PS90_GoRef (long,long,long);
long    __stdcall PS90_FreeSwitch (long,long);
long    __stdcall PS90_Stop (long,long);
long    __stdcall PS90_GoVel (long,long);
long    __stdcall PS90_StopVel (long,long);
long    __stdcall PS90_GetMotorType (long,long);
long    __stdcall PS90_SetMotorType (long,long,long);
long    __stdcall PS90_GetAxisActive (long,long);
long    __stdcall PS90_SetAxisActive (long,long,long);
long    __stdcall PS90_GetMotorCommMode (long,long);
long    __stdcall PS90_SetMotorCommMode (long,long,long);
long    __stdcall PS90_GetMotorCommCounts (long,long);
long    __stdcall PS90_SetMotorCommCounts (long,long,long);
long    __stdcall PS90_GetEncLines (long,long);
long    __stdcall PS90_SetEncLines (long,long,long);
long    __stdcall PS90_GetMotorPoles (long,long);
long    __stdcall PS90_SetMotorPoles (long,long,long);
long    __stdcall PS90_GetAxisMonitor (long,long);
long    __stdcall PS90_SetAxisMonitor (long,long,long);
long    __stdcall PS90_GetAxisState (long,long);
long    __stdcall PS90_GetMoveState (long,long);
long    __stdcall PS90_GetVelState (long,long);
long    __stdcall PS90_GetErrorState (long,long);
long    __stdcall PS90_GetRefReady (long,long);
long    __stdcall PS90_GetActVel (long,long);
long    __stdcall PS90_GetMsysPos (long,long);
long    __stdcall PS90_SetMsysPos (long,long,long);
long    __stdcall PS90_ResetMsysCounter (long,long);
long    __stdcall PS90_GetEncPos (long,long);
long    __stdcall PS90_GetPosError (long,long);
long    __stdcall PS90_GetMaxPosError (long,long);
long    __stdcall PS90_SetMaxPosError (long,long,long);
long    __stdcall PS90_GetMsysTarget (long,long);
long    __stdcall PS90_SetMsysTarget (long,long,long);
long    __stdcall PS90_GoMsysTarget (long,long);
long    __stdcall PS90_StopMsys (long,long);
long    __stdcall PS90_GetMsysPosState (long,long);
long    __stdcall PS90_GetMsysPosError (long,long);
long    __stdcall PS90_GetMsysPosRange (long,long);
long    __stdcall PS90_GetMsysDir (long,long);
long    __stdcall PS90_SetMsysDir (long,long,long);
long    __stdcall PS90_MultiGoTarget (long,long,long);
long    __stdcall PS90_MultiGoVel (long,long);
long    __stdcall PS90_MultiStop (long,long);
long    __stdcall PS90_GetVectorTabRow (long,long,char*,long);
long    __stdcall PS90_SetVectorTabRow (long,long,const char*);
long    __stdcall PS90_CopyVectorTab (long,long,long,long);
long    __stdcall PS90_ClearVectorTab (long,long,long);
long    __stdcall PS90_GoVectorTab (long,long,long);
long    __stdcall PS90_StopVectorTab (long);
long    __stdcall PS90_CheckVectorTab (long,long,long);
long    __stdcall PS90_CircleToVectorTab (long,long,const char*);
long    __stdcall PS90_ChangeTarget (long,long,long);
long    __stdcall PS90_GetPIDTarget (long,long);
long    __stdcall PS90_GetPosRange (long,long);
double  __stdcall PS90_GetActF (long,long);

// Adjustments
long    __stdcall PS90_SaveGlobParams (long);
long    __stdcall PS90_LoadGlobParams (long);
long    __stdcall PS90_SaveAxisParams (long,long);
long    __stdcall PS90_LoadAxisParams (long,long);
long    __stdcall PS90_GetAccel (long,long);
long    __stdcall PS90_SetAccel (long,long,long);
long    __stdcall PS90_GetDecel (long,long);
long    __stdcall PS90_SetDecel (long,long,long);
long    __stdcall PS90_GetJerk (long,long);
long    __stdcall PS90_SetJerk (long,long,long);
long    __stdcall PS90_GetBrakeDecel (long,long);
long    __stdcall PS90_SetBrakeDecel (long,long,long);
long    __stdcall PS90_GetRefDecel (long,long);
long    __stdcall PS90_SetRefDecel (long,long,long);
long    __stdcall PS90_GetPosVel (long,long);
long    __stdcall PS90_SetPosVel (long,long,long);
long    __stdcall PS90_GetVel (long,long);
long    __stdcall PS90_SetVel (long,long,long);
long    __stdcall PS90_GetSlowRefVel (long,long);
long    __stdcall PS90_SetSlowRefVel (long,long,long);
long    __stdcall PS90_GetFastRefVel (long,long);
long    __stdcall PS90_SetFastRefVel (long,long,long);
long    __stdcall PS90_GetFreeVel (long,long);
long    __stdcall PS90_SetFreeVel (long,long,long);
long    __stdcall PS90_GetStepWidth (long,long);
long    __stdcall PS90_SetStepWidth (long,long,long);
long    __stdcall PS90_GetDriveCurrent (long,long);
long    __stdcall PS90_SetDriveCurrent (long,long,long);
long    __stdcall PS90_GetHoldCurrent (long,long);
long    __stdcall PS90_SetHoldCurrent (long,long,long);
long    __stdcall PS90_GetPhaseInitTime (long,long);
long    __stdcall PS90_SetPhaseInitTime (long,long,long);
long    __stdcall PS90_GetPhaseInitAmp (long,long);
long    __stdcall PS90_SetPhaseInitAmp (long,long,long);
long    __stdcall PS90_GetPhasePwmFreq (long,long);
long    __stdcall PS90_SetPhasePwmFreq (long,long,long);
long    __stdcall PS90_GetCurrentLevel (long,long);
long    __stdcall PS90_SetCurrentLevel (long,long,long);
long    __stdcall PS90_GetServoLoopMax (long,long);
long    __stdcall PS90_SetServoLoopMax (long,long,long);
long    __stdcall PS90_GetMsysVel (long,long);
long    __stdcall PS90_SetMsysVel (long,long,long);
long    __stdcall PS90_GetVectorVel (long,long);
long    __stdcall PS90_SetVectorVel (long,long,long);
long    __stdcall PS90_GetVectorAccel (long,long);
long    __stdcall PS90_SetVectorAccel (long,long,long);
double  __stdcall PS90_GetPosF (long,long);
long    __stdcall PS90_SetPosF (long,long,double);
double  __stdcall PS90_GetF (long,long);
long    __stdcall PS90_SetF (long,long,double);
double  __stdcall PS90_GetSlowRefF (long,long);
long    __stdcall PS90_SetSlowRefF (long,long,double);
double  __stdcall PS90_GetFastRefF (long,long);
long    __stdcall PS90_SetFastRefF (long,long,double);
double  __stdcall PS90_GetFreeF (long,long);
long    __stdcall PS90_SetFreeF (long,long,double);
double  __stdcall PS90_GetMsysF (long,long);
long    __stdcall PS90_SetMsysF (long,long,double);
double  __stdcall PS90_GetVectorF (long,long);
long    __stdcall PS90_SetVectorF (long,long,double);

// Software/hardware regulator
long    __stdcall PS90_GetSampleTime (long,long);
long    __stdcall PS90_SetSampleTime (long,long,long);
long    __stdcall PS90_GetKP (long,long);
long    __stdcall PS90_SetKP (long,long,long);
long    __stdcall PS90_GetKI (long,long);
long    __stdcall PS90_SetKI (long,long,long);
long    __stdcall PS90_GetKD (long,long);
long    __stdcall PS90_SetKD (long,long,long);
long    __stdcall PS90_GetDTime (long,long);
long    __stdcall PS90_SetDTime (long,long,long);
long    __stdcall PS90_GetILimit (long,long);
long    __stdcall PS90_SetILimit (long,long,long);
long    __stdcall PS90_GetInPosMode (long,long);
long    __stdcall PS90_SetInPosMode (long,long,long);
long    __stdcall PS90_GetInPosTime (long,long);
long    __stdcall PS90_SetInPosTime (long,long,long);
long    __stdcall PS90_GetTargetWindow (long,long);
long    __stdcall PS90_SetTargetWindow (long,long,long);
long    __stdcall PS90_GetMsysFacZ (long,long);
long    __stdcall PS90_SetMsysFacZ (long,long,long);
long    __stdcall PS90_GetMsysFacN (long,long);
long    __stdcall PS90_SetMsysFacN (long,long,long);
long    __stdcall PS90_GetMsysPosMode (long,long);
long    __stdcall PS90_SetMsysPosMode (long,long,long);
long    __stdcall PS90_GetMsysTargetWnd (long,long);
long    __stdcall PS90_SetMsysTargetWnd (long,long,long);
long    __stdcall PS90_GetHybridTargetOffset (long,long);
long    __stdcall PS90_SetHybridTargetOffset (long,long,long);
long    __stdcall PS90_GetHybridTargetWnd (long,long);
long    __stdcall PS90_SetHybridTargetWnd (long,long,long);

// Hardware/software switches
long    __stdcall PS90_GetLimitSwitch (long,long);
long    __stdcall PS90_SetLimitSwitch (long,long,long);
long    __stdcall PS90_GetLimitSwitchMode (long,long);
long    __stdcall PS90_SetLimitSwitchMode (long,long,long);
long    __stdcall PS90_GetRefSwitch (long,long);
long    __stdcall PS90_SetRefSwitch (long,long,long);
long    __stdcall PS90_GetRefSwitchMode (long,long);
long    __stdcall PS90_SetRefSwitchMode (long,long,long);
long    __stdcall PS90_SetLimitSwitchLevel (long,long,long);
long    __stdcall PS90_GetSwitchState (long,long);
long    __stdcall PS90_GetSwitchHyst (long,long);
long    __stdcall PS90_GetLimitControl (long,long);
long    __stdcall PS90_SetLimitControl (long,long,long);
long    __stdcall PS90_GetLimitMin (long,long);
long    __stdcall PS90_SetLimitMin (long,long,long);
long    __stdcall PS90_GetLimitMax (long,long);
long    __stdcall PS90_SetLimitMax (long,long,long);
long    __stdcall PS90_GetLimitState (long,long);

// Joystick
long    __stdcall PS90_GetJoyX (long);
long    __stdcall PS90_SetJoyX (long,long);
long    __stdcall PS90_GetJoyY (long);
long    __stdcall PS90_SetJoyY (long,long);
long    __stdcall PS90_GetJoyZ (long);
long    __stdcall PS90_SetJoyZ (long,long);
long    __stdcall PS90_JoystickOn (long);
long    __stdcall PS90_JoystickOff (long);
long    __stdcall PS90_GetJoyVel (long,long);
long    __stdcall PS90_SetJoyVel (long,long,long);
long    __stdcall PS90_GetJoyAccel (long,long);
long    __stdcall PS90_SetJoyAccel (long,long,long);
long    __stdcall PS90_GetServoJoyOff (long,long);
long    __stdcall PS90_SetServoJoyOff (long,long,long);
long    __stdcall PS90_GetJoyZone (long);
long    __stdcall PS90_SetJoyZone (long,long);
long    __stdcall PS90_GetJoyZeroX (long);
long    __stdcall PS90_SetJoyZeroX (long,long);
long    __stdcall PS90_GetJoyZeroY (long);
long    __stdcall PS90_SetJoyZeroY (long,long);
long    __stdcall PS90_GetJoyZeroZ (long);
long    __stdcall PS90_SetJoyZeroZ (long,long);
long    __stdcall PS90_GetJoyButton (long);
long    __stdcall PS90_SetJoyButton (long,long);
double  __stdcall PS90_GetJoyF (long,long);
long    __stdcall PS90_SetJoyF (long,long,double);

// Analog & digital I/O
long    __stdcall PS90_GetAxisSignals (long,long);
long    __stdcall PS90_GetAxisIn (long,long);
long    __stdcall PS90_GetAxisOut (long,long);
long    __stdcall PS90_SetAxisOut (long,long,long);
long    __stdcall PS90_GetInOutConfig (long,long);
long    __stdcall PS90_GetDigitalInput (long,long);
long    __stdcall PS90_GetDigInTTL (long,long);
long    __stdcall PS90_GetDigInSPS (long,long);
long    __stdcall PS90_GetDigitalOutput (long,long);
long    __stdcall PS90_SetDigitalOutput (long,long,long);
long    __stdcall PS90_GetDigOutTTL (long,long);
long    __stdcall PS90_SetDigOutTTL (long,long,long);
long    __stdcall PS90_GetDigOutSPS (long,long);
long    __stdcall PS90_SetDigOutSPS (long,long,long);
long    __stdcall PS90_GetInputMode (long);
long    __stdcall PS90_SetInputMode (long,long);
long    __stdcall PS90_GetAnalogInput (long,long);
long    __stdcall PS90_GetAnalogOutput (long,long);
long    __stdcall PS90_SetAnalogOutput (long,long,long);
long    __stdcall PS90_GetPwmOutput (long,long);
long    __stdcall PS90_SetPwmOutput (long,long,long);
long    __stdcall PS90_GetPwmBrake (long,long);
long    __stdcall PS90_SetPwmBrake (long,long,long);
long    __stdcall PS90_GetPwmBrakeValue1 (long,long);
long    __stdcall PS90_SetPwmBrakeValue1 (long,long,long);
long    __stdcall PS90_GetPwmBrakeValue2 (long,long);
long    __stdcall PS90_SetPwmBrakeValue2 (long,long,long);
long    __stdcall PS90_GetPwmBrakeTime (long,long);
long    __stdcall PS90_SetPwmBrakeTime (long,long,long);
long    __stdcall PS90_GetPowerInput (long,long);
long    __stdcall PS90_SetPowerOutput (long,long,long);
long    __stdcall PS90_ResetPowerOutput (long,long,long);
long    __stdcall PS90_GetHybridOutput (long,long);
long    __stdcall PS90_GetMaxHybridOutput (long,long);
long    __stdcall PS90_SetMaxHybridOutput (long,long,long);
long    __stdcall PS90_GetHybridOutputTime (long,long);
long    __stdcall PS90_SetHybridOutputTime (long,long,long);
long    __stdcall PS90_GetHybridErrorState (long);
long    __stdcall PS90_GetPowerState (long,long);
long    __stdcall PS90_GetEmergencyInput (long);
long	__stdcall PS90_GetStepperPowerControl (long,long,long,char*,long);
long	__stdcall PS90_SetStepperPowerControl (long,long,long,long,long,long);

// Stand-Alone-Compiler/Memory
long    __stdcall PS90_GetMem (long,long); // 1 byte
long    __stdcall PS90_SetMem (long,long,long); // 1 byte
long    __stdcall PS90_GetMem16 (long,long); // 2 bytes
long    __stdcall PS90_SetMem16 (long,long,long); // 2 bytes
long    __stdcall PS90_GetMem32 (long,long); // 4 bytes
long    __stdcall PS90_SetMem32 (long,long,long); // 4 bytes

// Extended functions
long    __stdcall PS90_SetStageAttributes (long,long,double,long,double);
long    __stdcall PS90_SetCalcResol (long,long,double);
long    __stdcall PS90_SetMsysResol (long,long,double);
double  __stdcall PS90_GetPositionEx (long,long);
long    __stdcall PS90_SetPositionEx (long,long,double);
double  __stdcall PS90_GetTargetEx (long,long);
long    __stdcall PS90_SetTargetEx (long,long,double);
long    __stdcall PS90_ChangeTargetEx (long,long,double);
double  __stdcall PS90_GetPIDTargetEx (long,long);
double  __stdcall PS90_GetMsysPosEx (long,long);
long    __stdcall PS90_SetMsysPosEx (long,long,double);
double  __stdcall PS90_GetMsysTargetEx (long,long);
long    __stdcall PS90_SetMsysTargetEx (long,long,double);
double  __stdcall PS90_GetMsysPosRangeEx (long,long);
double  __stdcall PS90_GetPosRangeEx (long,long);
double  __stdcall PS90_GetEncPosEx (long,long);
double  __stdcall PS90_GetLimitMinEx (long,long);
long    __stdcall PS90_SetLimitMinEx (long,long,double);
double  __stdcall PS90_GetLimitMaxEx (long,long);
long    __stdcall PS90_SetLimitMaxEx (long,long,double);
long    __stdcall PS90_MoveEx (long,long,double,long);
double  __stdcall PS90_GetPosFEx (long,long);
long    __stdcall PS90_SetPosFEx (long,long,double);
double  __stdcall PS90_GetFEx (long,long);
long    __stdcall PS90_SetFEx (long,long,double);
double  __stdcall PS90_GetSlowRefFEx (long,long);
long    __stdcall PS90_SetSlowRefFEx (long,long,double);
double  __stdcall PS90_GetFastRefFEx (long,long);
long    __stdcall PS90_SetFastRefFEx (long,long,double);
double  __stdcall PS90_GetFreeFEx (long,long);
long    __stdcall PS90_SetFreeFEx (long,long,double);
double  __stdcall PS90_GetJoyFEx (long,long);
long    __stdcall PS90_SetJoyFEx (long,long,double);
double  __stdcall PS90_GetActFEx (long,long);
double  __stdcall PS90_GetMsysFEx (long,long);
long    __stdcall PS90_SetMsysFEx (long,long,double);
double  __stdcall PS90_GetVectorFEx (long,long);
long    __stdcall PS90_SetVectorFEx (long,long,double);
double  __stdcall PS90_GetAccelEx (long,long);
long    __stdcall PS90_SetAccelEx (long,long,double);
double  __stdcall PS90_GetDecelEx (long,long);
long    __stdcall PS90_SetDecelEx (long,long,double);
double  __stdcall PS90_GetBrakeDecelEx (long,long);
long    __stdcall PS90_SetBrakeDecelEx (long,long,double);
double  __stdcall PS90_GetRefDecelEx (long,long);
long    __stdcall PS90_SetRefDecelEx (long,long,double);
double  __stdcall PS90_GetJoyAccelEx (long,long);
long    __stdcall PS90_SetJoyAccelEx (long,long,double);
double  __stdcall PS90_GetVectorAccelEx (long,long);
long    __stdcall PS90_SetVectorAccelEx (long,long,double);
long    __stdcall PS90_SetDEC (long, long, const char*, const char*, long, double);
long    __stdcall PS90_GetDEC (long, long, char*, long);

// Communication
long    __stdcall PS90_LogFile (long, long, const char*, long, long);
long	__stdcall PS90_CmdAns (long, const char*, char*, long, long);
long	__stdcall PS90_CmdAnsEx (long, const char*, char*, long, long, long);
long	__stdcall PS90_GetOWISidData (long, long, long, char*, long);
long    __stdcall PS90_GetReadError (long);

#ifdef __cplusplus
};
#endif

#endif	//__MYPS90
