% testing calibration plate fiducial matching
clc
clear all

addpath('F:\Gantry_code\Matlab_app');
fid=FIDUCIALS;

set='set_3';

originalImagesFolder='F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Fiducial_images\fiducial_calibration_plate\original_images\';
imageFolder=strcat(originalImagesFolder,set);

matchedImagesFolder='F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Fiducial_images\fiducial_calibration_plate\matched_images\';
matchedFolder=strcat(matchedImagesFolder,set,'\');



if ~isdir(imageFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(imageFolder, '*.jpg');
jpegFiles = dir(filePattern);

for k = 1:length(jpegFiles)
    
 baseFileName = jpegFiles(k).name;
 fullFileName = fullfile(imageFolder, baseFileName);   
    
image=imread(fullFileName);

% comprobacion funcion general

match=fid.CalibrationFidFinder(image);


imagePath=strcat(matchedFolder,'_',int2str(k),'.jpg');
imwrite(match.Images{2},imagePath)
center(k,:)=match.Center;




% comprobacion función ROI builder

% [ROI,vertex,imagesROIbuilder]=fid.CalibrationFiducialROIBuilder(image);
% imagePath=strcat(matchedFolder,'_',int2str(k),'.jpg');
% imwrite(imagesROIbuilder{3},imagePath)
% 
% imagePath2=strcat(matchedFolder,'_ROI',int2str(k),'.jpg');
% imwrite(ROI,imagePath2)


end


