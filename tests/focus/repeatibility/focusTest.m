%% repeatibility Focus Aluminum %%

function results=focusTest(focus,gantry,iterations,name)
% before starting this function the image has to be in a focused point
Zref=gantry.GetPosition(4);


for i=1:iterations
delta=0.09-0.18*rand;
gantry.MoveBy(4,delta,1);    
info=focus.AutoFocus_test;
infoCell=struct2cell(info);
results(i,1)=infoCell{1};
results(i,2)=infoCell{2};
results(i,3)=infoCell{5};
results(i,4)=delta;
gantry.MoveTo(4,Zref,1);
end
path=['C:\Users\Pablo\Desktop\output_images_results_Gantry\',name,'.mat'];
save(path,'results');
end