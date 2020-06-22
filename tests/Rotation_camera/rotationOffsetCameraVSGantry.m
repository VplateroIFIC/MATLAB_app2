%%% calculating offset of camera rotation wrt the gantry system %%%

clc
clear all

% Adding the ath where results are%
addpath('F:\Users\leon\Documents\SilicioGeneral\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\second measures\Horizontal')
addpath('F:\Gantry_code\Matlab_app')

fiducial=FIDUCIALS(1);

%load txt results
positions=importdata('coordenates.txt');

% setting the size of one image
image=imread('image_1.png');
[Ypix,Xpix]=size(image);
centerImage=[Xpix/2,Ypix/2];

% matching the F for each picture and saving pixel coordenates

[m,n]=size(positions);
% m=7;
name=['image_'];
for i=1:m
    image=imread([name,num2str(i),'.png']);
    match=fiducial.FmatchSURF(image,positions(i,:));
    centro(i,1)=match{1}.Center(1);
    centro(i,2)=match{1}.Center(2);
    
    imageMatched=match{1}.Images{6};
    nameImageMatched=[name,num2str(i),'matched.png'];
    imwrite(imageMatched,['F:\Users\leon\Documents\SilicioGeneral\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\second measures\Horizontal\',nameImageMatched]);
end

%% calculating rect of the movement %%

%fitting the line
P = polyfit(centro(1:10,1),centro(1:10,2),1);

% calculating the angle
angle=atan(P(1));

%% transformation from the image reference system to the center %%
calibration=1.7400; %p/um  calibration fiducial
transformationImage2Center=transform2D();
transformationImage2Center.translate([-centerImage(1),-centerImage(2)]);
for j=1:m
imageCS(j,:)=transformationImage2Center.M*[centro(j,1);Ypix-centro(j,2);1];
end

imageCSum=imageCS/calibration/1000;
save('F:\Users\leon\Documents\SilicioGeneral\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\second measures\Horizontal\fiducialsWRTcenter.txt', 'imageCSum', '-ascii', '-double', '-tabs')


%% transformation from the center to the gantry system %%


for j=1:m
clearvars transformationGantry2Image  transformationImage2Gantry 
transformationGantry2Image=transform2D();
transformationImage2Gantry=transform2D();
transformationGantry2Image.translate([-positions(j,1),-positions(j,2)]); 
transformationGantry2Image.rotate(2*pi-(angle));
transformationImage2Gantry.M=inv(transformationGantry2Image.M);
imageGantry(j,:)=transformationImage2Gantry.M*[imageCSum(j,1);imageCSum(j,2);1];
end


