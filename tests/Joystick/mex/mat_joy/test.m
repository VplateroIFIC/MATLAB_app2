buf_size = 1000;

buf = inf(buf_size,1);
figure;
i = 0;

while true
    [pos, but] = mat_joy(0);
    plot(1:buf_size, buf);
    axis([0 1000 -1 1]);
    buf = [buf(2:buf_size); pos(2)];
    i = i + 1;
    pause(0.01);
end