 %% CAMERA CLASS DEBUG %%
 
 %% creating  CAMERA object %%
 
 cap=CAMERA;

 %% connecting camera %%
 
 cap=cap.Connect;
 
 %% asking one frame %%
 
 frame=cap.OneFrame;
 
 %% display one frame %%
 
 cap.DispFrame;
 
 %% save frame %%
 
 cap.SaveFrame('image',1)
 
 %% display camara %%
 
 cap.DispCam;
 
 %% stopping camera showing %%
 
  cap.DispCamOff;
  
  %% disconnecting camera %%
  
  cap.Disconnect;