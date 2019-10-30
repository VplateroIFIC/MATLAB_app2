
function match = frameMatcher(fid,cam)
% método que extrae una imagen de la cámara y aplica pattern matching de la F %
% argumenos
% inputs:
%     fid: objeto clase FIDUCIALS
%     cam: objeto clase CAMERA
% outputs:
%     match: informacion sobre le match
    
    
image=cam.OneFrame;
% match=fid.FmatchSURF(image);
match=fid.CalibrationFidFinder(image);

match.Center

% figure, imshow(match.Images{5})
figure, imshow(match.Images{2})

end

