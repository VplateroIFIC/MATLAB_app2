#include "S_interfaceLLT_2.h"
#include "scanControlDataTypes.h"
#include <math.h>
#include <iostream>
#include <conio.h>
#include <vector>
#include <string>
#include <list>
#include <map>
#include <deque>
#include <sstream>
#include <fstream>
#include <ostream>
#include <istream>
#include <iomanip>
#include <algorithm>

using namespace std;

int main(){

    vector<unsigned int> Interfaces(5);
    bool loadError;
    loadError = s_CreateLLTDevice(INTF_TYPE_ETHERNET);

    s_GetDeviceInterfacesFast(loadError, Interfaces, 5);

    cout << Interfaces[1] << Interfaces[2] << Interfaces[3];

    return 0;
}
