%% check set of images static focus set of images %%

clc
clear all

%% saving data into workspace %%

dataPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\Static_Images\\focusMethodsResults_sensorStrips');
addpath(dataPath);
data=load('results.mat');

%% calculating focus measure value of the images %%
methods={'ACMO','BREN','CURV','GDER','GLVA','GLLV','GLVN','GRAE','GRAT','GRAS','HELM',...
    'HISE','HISR','LAPE','LAPM','LAPV','LAPD','SFRQ','TENG','TENV','VOLA'};

images=data.results.Images;
Z=data.results.Zvalues;
focusValue=zeros(length(Z),length(methods));
[a,b,c]=size(images);
roi=500;
for m=1:length(methods)
tic
flag=0;
for k = 1:length(Z)
    
image_gray=mat2gray(images(:,:,k)); 
focusValue(k,m)=fmeasure(image_gray,methods{m});
end
timeFocusMethod(m)=toc;
end
filename=strcat(dataPath,'\FocusResults.mat');
save(filename,'Z','focusValue','methods','timeFocusMethod')

%% fitting curves and plotting %%

clc
clear all

resultsPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\Static_Images\\focusMethodsResults_sensorStrips');
load ([resultsPath,'\','FocusResults.mat'])

for m=1:length(methods)
X=Z;
Y=focusValue(:,m);
   
p=polyfit(X,Y,12);
degree=length(p);
Yfit=0;
for j=1:degree
Yfit=Yfit+p(j)*Z.^(degree-j);
end
indexMaximumValue=find(Yfit==max(Yfit),1);
indexMinimumValue=find(Yfit==min(Yfit),1);
ZoptmMax=Z(indexMaximumValue);
ZoptmMin=Z(indexMinimumValue);
f = fit(X,Y,'gauss2');

Zeval=Z(1):0.001:Z(length(Z));
for w=1:length(Zeval)
y(w) = feval(f,Zeval(w));
end

indexMaxGauss=find(y==max(y));
indexMinGauss=find(y==min(y));

maxGauss=Zeval(indexMaxGauss);
minGauss=Zeval(indexMinGauss);

% plotting fit vs real data %

fig=figure('Visible','off','Position', get(0, 'Screensize'));
plot(Z,focusValue(:,m),'LineWidth', 2,'color','r')
% hold on
% plot(Z,Yfit,'LineWidth', 2,'color','b')
% hold on
% plot(f,X,Y)
legend('Real data','2nd poly fit')
title(strcat('Fit VS real:--','method:',methods(m),'--Time:',num2str(timeFocusMethod(m)),' ZoptimMax:',num2str(ZoptmMax),'--ZoptimMin:',num2str(ZoptmMin),...
    '--maxGauss:',num2str(maxGauss),'--minGauss:',num2str(minGauss)),'FontSize', 15)
xlabel('Z','FontSize', 25)
ylabel('Focus Value','FontSize', 25)
filename=strcat(resultsPath,'\RealvsFit_',methods{m},'.png');
set(gca,'FontSize',15)
saveas(fig,filename)

end

% plotting focus curve

% fig=figure('Visible','off','Position', get(0, 'Screensize'));
% plot(Z,focusValue,'LineWidth', 2)
% title([methods(m),' ',num2str(timeFocusMethod(m))],'FontSize', 25)
% xlabel('Z','FontSize', 25)
% ylabel('Focus Value','FontSize', 25)
% filename=strcat(imagesPath,'\',methods{m},'.png');
% set(gca,'FontSize',25)
% saveas(fig,filename)
% clearvars focusValue

% plotting focus fits












