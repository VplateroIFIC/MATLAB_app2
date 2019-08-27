function feedBack=readPort(serialObj)
trigger=0;
ETX=3;
cont=1;
while(trigger==0)  
input(cont)=fread(serialObj,1);
if input(cont)==ETX
    trigger=1;
end
cont=cont+1;
end
fullInput=char(input);
n=length(fullInput);
feedBack=fullInput(4:n-3);
end