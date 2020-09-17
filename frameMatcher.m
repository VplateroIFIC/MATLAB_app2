
function match = frameMatcher(fid,cam,gantry)
% método que extrae una imagen de la cámara y aplica pattern matching de la F %
% argumenos
% inputs:
%     fid: objeto clase FIDUCIALS
%     cam: objeto clase CAMERA
% outputs:
%     match: informacion sobre le match
    
    
image=cam.OneFrame;
currentPos=gantry.GetPositionAll;
match=fid.FmatchSURF(image,currentPos(1:2));
% match=fid.CalibrationFidFinder(image);

% match.Center

% figure, imshow(match.Images{6})
figure, imshow(match{1}.Images{6})

end

