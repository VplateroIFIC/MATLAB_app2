
function imageOut = prepareImage (imageIn,kernel,threshold)
% function to perform prepocessing to images before feature detection %
% in this function the image is going through the next processing:
% 1. Median filter: (median blur) kernel = 5 (standard)
% 2. Binary filter: Otsu+Binary, max value = 255 (standard)
% 3. Adaptative local threshold: Gaussian, binary inverted, blocksize =5 C=2 (standard)
% 4. Removing particles
%
% in order to try a better performing, change the parameters


medianFilter=cv.medianBlur(imageIn,'KSize',kernel);
BinaryFilter=cv.threshold(medianFilter,'Otsu','Type','Binary','MaxValue',255);
% adapLocalThres=edge(BinaryFilter);
adapLocalThres=cv.adaptiveThreshold(BinaryFilter,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',threshold,'C',2);
particlesRemoved=bwareaopen(adapLocalThres,9500);
imuint8=im2uint8(particlesRemoved);
resizeIm=imresize(imuint8,1);
imageOut=resizeIm;
end