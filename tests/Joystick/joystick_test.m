%% JOYSTICK IMPLEMENTATION EXAMPLE %%

% Create the timer object %

t = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0);
t.period=0.001;
t.BusyMode='queue';
t.TimerFcn = @joyControl;
t.UserData = struct('Flag',zeros(21,1));
% t.UserData = struct('counter_2',0);
% starting the timer %

start(t)

% stop the timer %

stop(t);

% deleting the timer %

delete(t);