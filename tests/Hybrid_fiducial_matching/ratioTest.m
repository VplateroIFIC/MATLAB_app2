
function goodMatches = ratioTest(matches,keypoints1,keypoints2,sizeThreshold, ratio)
%  function to perform ratio test proposed by David Lowe paper, gettin good matches %
%  input 1: matches: output struct from knn matcher
%  ratio: threshold to be applied in the filter (0.8 normal value, 0.7 tight value)

n=length(matches);
lowRatio=ratio;
cont=1;
for i=1:n
    indexQuery=matches{i}(1).queryIdx+1;
    indexTrain=matches{i}(1).trainIdx+1;
if (matches{i}(1).distance < matches{i}(2).distance*lowRatio) && (keypoints1(indexQuery).size>sizeThreshold) && (keypoints2(indexTrain).size>sizeThreshold)
    goodMatches{cont}(1).queryIdx=matches{i}.queryIdx;
    goodMatches{cont}(1).trainIdx=matches{i}.trainIdx;
    goodMatches{cont}(1).imgIdx=matches{i}.imgIdx;
    goodMatches{cont}(1).distance=matches{i}.distance;
    cont=cont+1;
end
end
end