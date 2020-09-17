function linearSetImages(gantry,camera,direction, nImages, gap)
%UNTITLED2 take a set of images in a line and save them into output file
%   Detailed explanation goes here
% gantry=gantry object
% camera=camera objetc
% direction = 0 X, 1 Y
% nImages=Number of images to be taken
% gap=separation between images


path='C:\Users\Pablo\Desktop\output_images_results_Gantry\';
nametxt=[path,'coordenates.txt'];
fCor=fopen(nametxt,'wt');
for i=1:nImages
   name=['image_',num2str(i)];
   %saving frame into output camera folder 
   camera.SaveFrame(name,2);
   %getting current position of the gantry
   coordinates=gantry.GetPositionAll;
   %saving current position into txt
   fprintf(fCor,'%d %d \n',coordinates(1),coordinates(2));
%    fprintf(fCor,'\n');
   %moving gantry to next position
   if direction==0
       gantry.MoveBy(1,gap,0.5,1)
   elseif direction==1
       gantry.MoveBy(0,gap,0.5,1)
   end
end
fclose('all');

end

