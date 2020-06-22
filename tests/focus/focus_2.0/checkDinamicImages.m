%% check set of images static focus set of images %%

clc
clear all

%% Loading results %%

imagesPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\dinamic_Images\focusMethodsResults_2');
addpath(imagesPath);
load ([imagesPath,'\results.mat'])


%% matching Ztime with frames time %%

Z=resultsImages.Z;

Nsamples=length(resultsImages.time);
for i=1:Nsamples
FramesTime(i)=resultsImages.time(i);
end
Ztime=resultsImages.ZtimeAfter;


for i=1:Nsamples
error=abs(Ztime-FramesTime(i));
index=find(error==min(error));
Zmatched(i)=Z(index);
end

%% calculating Focus Value %%

methods={'ACMO','BREN','CURV','GDER','GLVA','GLLV','GLVN','GRAE','GRAT','GRAS','HELM',...
    'HISE','HISR','LAPE','LAPM','LAPV','LAPD','SFRQ','TENG','TENV','VOLA'};
focusValue=zeros(length(Nsamples),length(methods));
for m=1:length(methods)
tic
for k = 1:Nsamples
 focusValue(k,m)=fmeasure(mat2gray(resultsImages.images(:,:,1,k)),methods{m});
end
timeFocusMethod(m)=toc;
end
filename=strcat(imagesPath,'\FocusResults.mat');
save(filename,'Zmatched','focusValue','methods','timeFocusMethod')

%% fitting curves and plotting %%

clc
clear all

resultsPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\dinamic_Images\focusMethodsResults_2');
load ([resultsPath,'\','FocusResults.mat'])

for m=1:length(methods)
X=Zmatched';
Y=focusValue(:,m);
p=polyfit(X,Y,12);
degree=length(p);
Yfit=0;
for j=1:degree
Yfit=Yfit+p(j)*Zmatched.^(degree-j);
end
indexMaximumValue=find(Yfit==max(Yfit));
Zoptm=Zmatched(indexMaximumValue);

% plotting fit vs real data %

fig=figure('Visible','off','Position', get(0, 'Screensize'));
plot(Zmatched,focusValue(:,m),'LineWidth', 2,'color','r')
hold on
plot(Zmatched,Yfit,'LineWidth', 2,'color','b')
legend('Real data','2nd poly fit')
title(strcat('Fit VS real:--','method:',methods(m),'--Time:',num2str(timeFocusMethod(m)),'--Zoptim:',num2str(Zoptm)),'FontSize', 25)
xlabel('Z','FontSize', 25)
ylabel('Focus Value','FontSize', 25)
filename=strcat(resultsPath,'\RealvsFit_',methods{m},'.png');
set(gca,'FontSize',25)
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












