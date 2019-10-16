// ps90tool.c : Definiert den Einsprungpunkt für die Konsolenanwendung.
//

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include "ps90.h"


int main(int argc, char* argv[])
{
	// parameters from the command line
	// parameter 1 (COM port)
	long nComPort=3; //argv[1]
	// parameter 2 (axis number)
	long nAxis=1; //argv[2]
	// parameter 3 (positioning velocity in Hz)
	double dPosF=30000.0; //argv[3]
	// parameter 4 (distance for positioning in mm, distance=0 - reference run)
	double dDistance=10.0; //argv[4]

	if( argc != 5 ) {
		printf( _T("ps90tool <COM port> <axis no.> <velocity> <distance>\n") );
		printf( _T("e.g. ps90tool 3 1 30000 10\n") );
		exit(255);
	};

	// set parameters *************
	nComPort=atol(argv[1]);
	nAxis=atol(argv[2]);
	dPosF=atof(argv[3]);
	dDistance=atof(argv[4]);
	// ****************************

	// open virtual serial interface
	//if(nComPort==0) PS90_Connect(1, 1, 172, 16, 1, 67, 502, 100); // Ethernet !!!
	//else PS90_Connect(1, 0, nComPort, 9600, 0, 0, 8, 0);	
	PS90_Connect(1, 0, nComPort, 9600, 0, 0, 8, 0);	

	// define constants for calculation Inc -> mm
	//PS90_SetStageAttributes(1,nAxis,1.0,200,1.0);

	// initialize axis
	PS90_MotorInit(1,nAxis);

	// set target mode (0 - relative)
	PS90_SetTargetMode(1,nAxis,0);

	// set velocity
	PS90_SetPosF(1,nAxis,dPosF);

	// check position
	printf(_T("Position=%.3f\n"), PS90_GetPositionEx(1,nAxis));

	// start positioning
	if(dDistance==0.0) // go home (to start position)
	{
		PS90_GoRef(1,nAxis,4);
	}
	else // move to target position (+ positive direction, - negative direction)
	{
		PS90_MoveEx(1,nAxis,dDistance,1);
	}

	// check move state of the axis
	printf(_T("Axis is moving...\n"));
	while(PS90_GetMoveState(1,nAxis)) {;}
	printf(_T("Axis is in position.\n"));

	// check position
	printf(_T("Position=%.3f\n"), PS90_GetPositionEx(1,nAxis));

	// close interface
	PS90_Disconnect(1);

	return 0;
}
