%% testing searching methods for optimus focus %%


clc
clear all

%% loading results %%

resultsPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\Static_Images\focusMethodsResults_Aluminio');
load ([resultsPath,'\','FocusResults.mat'])

methodUsed=21;

Nsamples=length(Z);
Nmethods=length(methods);

focus=focusValue(:,methodUsed);
ZMax=Z(find(focus==max(focus))); % máximo valor de enfoque medido


% preliminary plotting

fig=figure('Visible','on','Position', get(0, 'Screensize'));
plot(Z,focus,'LineWidth', 2,'color','r')
legend('Real data','2nd poly fit')
title(strcat('Fit VS real:--','method:',methods{methodUsed},'--Time:',num2str(timeFocusMethod(methodUsed)),' ZoptimMax:',num2str(ZMax),'FontSize', 15))
xlabel('Z','FontSize', 25)
ylabel('Focus Value','FontSize', 25)
set(gca,'FontSize',25)

%% fitting %%
X=Z;
Y=focus;

p=polyfit(X,Y,6);
degree=length(p);
Zeval=X(1):0.001:X(length(X));
Yfit=polyval(p,Zeval);
ZMaxFit=Zeval(find(Yfit==max(Yfit)));
    

fig=figure('Visible','on');
plot(X,Y,'LineWidth', 2,'color','r')
hold on
plot(Zeval,Yfit,'LineWidth', 2,'color','b')
legend('Real data','2nd poly fit')
title(strcat('Fit VS real:--','method:',methods{methodUsed},'--Time:',num2str(timeFocusMethod(methodUsed)),' ZMax:',num2str(ZMax),' ZMaxFit:',num2str(ZMaxFit),'FontSize', 15))
xlabel('Z','FontSize', 25)
ylabel('Focus Value','FontSize', 25)
set(gca,'FontSize',25)

clearvars X Y


%% searching method: fitting in real window %%

clearvars -except Z focus methodUsed ZMax

range=[ZMax-0.2,ZMax+0.2];

cont=1;
for d=1:length(Z)
    if Z(d)>13.5 && Z(d)<13.9
        X(cont)=Z(d);
        Y(cont)=focus(d);
        cont=cont+1;
    end
end

p=polyfit(X,Y,6);
degree=length(p);
Zeval=X(1):0.001:X(length(X));
Yfit=polyval(p,Zeval);
ZMaxFit=Zeval(find(Yfit==max(Yfit)));

fig=figure('Visible','on');
plot(X,Y,'LineWidth', 2,'color','r')
hold on
plot(Zeval,Yfit,'LineWidth', 2,'color','b')
legend('Real data','2nd poly fit')
title(strcat('Fit VS real:--','method:',methods{methodUsed},'--Time:',num2str(timeFocusMethod(methodUsed)),' ZMax:',num2str(ZMax),' ZMaxFit:',num2str(ZMaxFit),'FontSize', 15))
xlabel('Z','FontSize', 25)
ylabel('Focus Value','FontSize', 25)
set(gca,'FontSize',25)

clearvars X Y


%% searching method: fitting in real window with realistic number of samples %%

clearvars -except Z focus ZMax

range=[ZMax-0.2,ZMax+0.2];
cont=1;
for d=1:length(Z)
    if Z(d)>range(1) && Z(d)<range(2) 
        Xall(cont)=Z(d);
        Yall(cont)=focus(d);
        cont=cont+1;
    end
end

cont=1;
Nsamples=40;
delta=floor(length(Xall)/(Nsamples-1));

for i=1:length(Xall)
    if i==1 || mod(i,delta)==0
        X(cont)=Xall(i);
        Y(cont)=Yall(i);
        cont=cont+1;
    end
end
     
p=polyfit(X,Y,6);
degree=length(p);
Zeval=X(1):0.001:X(length(X));
Yfit=polyval(p,Zeval);
ZMaxFit=Zeval(find(Yfit==max(Yfit)));

fig=figure('Visible','on');
plot(X,Y,'LineWidth', 2,'color','r')
hold on
plot(Zeval,Yfit,'LineWidth', 2,'color','b')
legend('Real data','2nd poly fit')
title(strcat('Fit VS real:--','method:',methods{methodUsed},'--Time:',num2str(timeFocusMethod(methodUsed)),' ZMax:',num2str(ZMax),' ZMaxFit:',num2str(ZMaxFit),'FontSize', 15))
xlabel('Z','FontSize', 25)
ylabel('Focus Value','FontSize', 25)
set(gca,'FontSize',25)

clearvars X Y


%% searching method: testing fit grade 6, N fit points, range +- 200 um, just 1 focus loop %%

clc
clear all
resultsPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\Static_Images\focusMethodsResults_sensorStrips');
load ([resultsPath,'\','FocusResults.mat'])

methodUsed=21;
focus=focusValue(:,methodUsed);
ZMax=Z(find(focus==max(focus)));

Zoptimo=ZMax;
Nsamples=10;
iterations = 5000;
delta=0.2;

for k=1:iterations
    
    centerOfRange(k)=Zoptimo+delta*((rand-0.5)*2);   %centro de mi ventana de medidas virtual
    range(k,:)=[centerOfRange(k)-delta,centerOfRange(k)+delta];
    
cont=1;
for d=1:length(Z)
    if Z(d)>range(k,1) && Z(d)<range(k,2) 
        Xall(cont)=Z(d);
        Yall(cont)=focus(d);
        cont=cont+1;
    end
end

cont=1;

delta=floor(length(Xall)/(Nsamples-1));

for i=1:length(Xall)
    if i==1 || mod(i,delta)==0
        X(cont)=Xall(i);
        Y(cont)=Yall(i);
        cont=cont+1;
    end
end
     
p=polyfit(X,Y,6);
degree=length(p);
Zeval=X(1):0.001:X(length(X));
Yfit=polyval(p,Zeval);
ZMaxFit(k)=Zeval(find(Yfit==max(Yfit),1));

clearvars X Y

end
pause(0.1)

% ZMaxFit = rmoutliers(ZMaxFit,'mean');

error=ZMaxFit-Zoptimo;
MaxError=max(abs(ZMaxFit-Zoptimo));
clc
MaxError
mean(error)
var(error)

averageZoptim=mean(ZMaxFit)
varianzaZoptim=var(ZMaxFit)
desviacionZoptim=std(ZMaxFit)
repeatibility=[averageZoptim-min(ZMaxFit),max(ZMaxFit)-averageZoptim]
histfit(ZMaxFit')
Nerrors=find(abs(averageZoptim-ZMaxFit)>0.01)

clearvars X Y




%% searching method: testing fit grade 6, N fit points, range +- 200 um, 2 loops %%
clc
clear all
resultsPath=('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Focus_test\Focus_optimization_OE_camera\Static_Images\focusMethodsResults_sensorStrips');
load ([resultsPath,'\','FocusResults.mat'])

methodUsed=21;
focus=focusValue(:,methodUsed);
ZMax=Z(find(focus==max(focus)));

Zoptimo=ZMax;
Nsamples=10;
Nsamples2=10;
iterations =5000;
loops=2;
focusWindow=0.1;
scaling=1/3;

for k=1:iterations
    
 Zoptimo=ZMax;   
 Nsamples=10;  
 Nsamples2=10;
 focusWindow=0.4;
 
for s=1:loops

    centerOfRange(k)=Zoptimo+focusWindow*((rand-0.5)*2);   %centro de mi ventana de medidas virtual
    range(k,:)=[centerOfRange(k)-focusWindow,centerOfRange(k)+focusWindow];
    
cont=1;
for d=1:length(Z)
    if Z(d)>range(k,1) && Z(d)<range(k,2) 
        Xall(cont)=Z(d);
        Yall(cont)=focus(d);
        cont=cont+1;
    end
end

cont=1;
delta=floor(length(Xall)/(Nsamples-1));

for i=1:length(Xall)
    if i==1 || mod(i,delta)==0
        X(cont)=Xall(i);
        Y(cont)=Yall(i);
        cont=cont+1;
    end
end
     
p=polyfit(X,Y,6);
degree=length(p);
Zeval=X(1):0.0001:X(length(X));
Yfit=polyval(p,Zeval);
ZMaxFit(k)=Zeval(find(Yfit==max(Yfit),1));

diferenciaOptimosLoops(k)=ZMaxFit(k)-Zoptimo;


Nsamples=Nsamples2;
focusWindow=scaling*focusWindow;
Zoptimo=ZMaxFit(k);

clearvars Yfit Zeval
end

end

ZMaxFit = rmoutliers(ZMaxFit);

pause(0.1)
error=ZMaxFit-Zoptimo;
MaxError=max(abs(ZMaxFit-Zoptimo));
clc
MaxError
mean(error)
var(error)
averageZoptim=mean(ZMaxFit)
varianzaZoptim=var(ZMaxFit)
desviacionZoptim=std(ZMaxFit)
repeatibility=[averageZoptim-min(ZMaxFit),max(ZMaxFit)-averageZoptim]

pd = fitdist(ZMaxFit','Normal')
x_values = 13.55:0.01:13.59;
y = pdf(pd,x_values);
figure, plot(x_values,y,'LineWidth',2)

rng default;
histfit(ZMaxFit')

pd = fitdist(ZMaxFit','Normal')
Nerrors=find(abs(averageZoptim-ZMaxFit)>0.01)
clearvars X Y
