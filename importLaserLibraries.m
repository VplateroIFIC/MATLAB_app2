function err = importLaserLibraries
%Function to include and start libraries for sensors scanCONTROL2950 and
%optoNCDT2300, returns TRUE in case of success and FALSE otherwise.

addpath('Laser_libraries\optoNCDT2300\'); %to access function setPath

%% Import MEDAQLib %% (for optoNCDT2300)
addpath('Laser_libraries\optoNCDT2300\MEDAQLib\') %Add the compiled .dll to the MATLAB search Path
err = setPath('Laser_libraries\optoNCDT2300\MEDAQLib-4.7.0.30086\Release-x64');

if err
    try
        clib.MEDAQLib.ME_SENSOR;
        err = false;
    catch
        err = true;
    end
end

%% Import LLT %% (for scanCONTROL2950)
addpath('Laser_libraries\scanCONTROL2950\LLT\') %Add the compiled .dll to the MATLAB search Path
err = err & setPath('Laser_libraries\scanCONTROL2950\C++ SDK (+python bindings)\lib\x64');

if err
    try
        clib.LLT.TInterfaceType;
        err = false;
    catch
        err = true;
    end
end
