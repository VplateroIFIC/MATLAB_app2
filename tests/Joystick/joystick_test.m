%% JOYSTICK IMPLEMENTATION EXAMPLE %%

% Create the timer object %

t = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0,'TasksToExecute', 2);
t.period=0.001;
t.BusyMode='queue';
t.TimerFcn = @joyControl;

% starting the timer %

start(t)

% stop the timer %

stop(t);

% deleting the timer %

delete(t);