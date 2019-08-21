%% JOYSTICK CONTROL CALLBACK FUNCTION %%

function joyControl(obj,event)
% disp('into callback func')
[pos, but] = mat_joy(0);

% Npos=length(pos);
Nbut=length(but);
threshold = 0.01;

% obj.UserData.Flag=obj.UserData.counter+1;
% obj.UserData.counter_2=obj.UserData.counter_2+1;

obj.UserData.Flag
% fprintf('Posicion de eje x es %0.4f\n',pos(1));


if (abs(pos(1))>threshold)
fprintf('X axis is moving %0.4f\n',pos(1));

end
if (abs(pos(2))>threshold)
fprintf('Y axis is moving %0.4f\n',pos(2));
end
if (abs(pos(3))>threshold)
fprintf('Z axis is moving %0.4f\n',pos(3));
end

for i=1:Nbut
    if (but(i)==1)
      fprintf('button %i is clicked\n',i);
    end
end

end