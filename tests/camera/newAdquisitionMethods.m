%% testing new image adquisition methods %%

cam=CAMERA(5);  % opening gantry camera

cam=cam.Connect;

%% test %%
cam.startAdquisition

pause(0.5)
data=cam.retrieveData;
cam.stopAdquisition



