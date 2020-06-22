%% testing to get the threshold to the touch down function %%

load('position.mat');
load('current.mat');
x=(1:length(position));
time=x/100;

figure (1)
title('Comparison Z Position VS current in Z motor')
subplot(2,1,1)
plot(time,current)
subplot(2,1,2)
plot(time,position)


% ploting gradient %
gradient(1)=0;
for i=1:length(position)-1
    gradient(i+1)=current(i+1)-current(i);
end

figure(2)
title('gradient of current')
subplot(2,1,1)
plot(time,current)
subplot(2,1,2)
plot(time,gradient)