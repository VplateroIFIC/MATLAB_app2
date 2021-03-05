%Cacharreando


for i= 1:4
x(i) = modulePosition.R0{i}(1);
y(i) = modulePosition.R0{i}(2);
end

lowerLineX = [x(1),x(4)];
lowerLineY = [y(1),y(4)];
upperLineX = [x(2),x(3)];
upperLineY = [y(2),y(3)];

lowerLine = polyfit(lowerLineX,lowerLineY,1);
alfa.R0LowerLine = atand(lowerLine(1));

upperLine = polyfit(upperLineX,upperLineY,1);
alfa.R0UpperLine = atand(upperLine(1));
alfa

% Loading Fiducials position on gantry coordinates
fiducialsOnPetal{1} = transpose(petal.fiducials_gantry.R0{1})
fiducialsOnPetal{2} = transpose(petal.fiducials_gantry.R0{2})
fiducialsOnPetal{3} = transpose(petal.fiducials_gantry.R0{3})
fiducialsOnPetal{4} = transpose(petal.fiducials_gantry.R0{4})


for i= 1:4
x(i) = fiducialsOnPetal{i}(1);
y(i) = fiducialsOnPetal{i}(2);
end

% Loading Fiducials position on gantry coordinates
for i=1:4
    fiducialsOnSensor{i} = transpose(petal.fiducials_sensors.R0{i});
    fiducialsOnSensor{i}(4) = -28;
end

for i= 1:4
x(i) = fiducialsOnSensor{i}(1);
y(i) = fiducialsOnSensor{i}(2);
end
