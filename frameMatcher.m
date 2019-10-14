
function [match] = frameMatcher(fid,cam)
% m�todo que extrae una imagen de la c�mara y aplica pattern matching de la F %
% argumenos
% inputs:
%     fid: objeto clase FIDUCIALS
%     cam: objeto clase CAMERA
% outputs:
%     match: informacion sobre le match
    
    
image=cam.OneFrame;
match=fid.FmatchSURF(image);

match.Center

figure(1), imshow(match.Images{3})
figure(2), imshow(match.Images{5})

end

