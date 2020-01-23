
function match = frameMatcher(fid,cam)
% m�todo que extrae una imagen de la c�mara y aplica pattern matching de la F %
% argumenos
% inputs:
%     fid: objeto clase FIDUCIALS
%     cam: objeto clase CAMERA
% outputs:
%     match: informacion sobre le match
    
    
image=cam.OneFrame;
% match=fid.FmatchSURF(image);
match=fid.CalibrationFidFinder(image);

% match.Center

figure, imshow(match.Images{6})
% figure, imshow(match{1}.Images{6})

end

