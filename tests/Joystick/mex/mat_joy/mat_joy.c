//
// mat_joy.c
// MATLAB Interface for Joysticks
// Author: Stanislaw Adaszewski, 2012
//

#include <mex.h>
#define WIN32_LEAN_AND_MEAN
#define WINVER 0x0500
#include <windows.h>
#include <mmsystem.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    int joyId;
    JOYINFO joyInfo;
    mwSize sizePos[] = {3,1};
    mwSize sizeBut[] = {16,1};
    double *pos;
    double *but;
    int i;
    
    if (nlhs != 2 || nrhs != 1 || mxIsEmpty(prhs[0]) || mxGetNumberOfElements(prhs[0]) != 1 || (joyId = (int) mxGetPr(prhs[0])[0]) < 0 || joyId > 15) {
        mexErrMsgTxt("Usage: [position, buttons] = mat_job(joystick_id), where:\n\njoystick_id - joystick identifier (0-15),\nposition - list of joystick position in X, Y and Z axis,\nbuttons - list of 16 joystick button states (missing buttons are always zeros)");
    }
    
    joyGetPos(joyId, &joyInfo);
    
    plhs[0] = mxCreateNumericArray(2, sizePos, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, sizeBut, mxDOUBLE_CLASS, mxREAL);
    
    pos = mxGetPr(plhs[0]);
    but = mxGetPr(plhs[1]);
    
    pos[0] = ((double) joyInfo.wXpos - 32767) / 32767;
    pos[1] = ((double) joyInfo.wYpos - 32767) / 32767;
    pos[2] = ((double) joyInfo.wZpos - 32767) / 32767;
    
    for(i = 0; i < 16; i++) {
        but[i] = (joyInfo.wButtons >> i) & 1;
    }
}