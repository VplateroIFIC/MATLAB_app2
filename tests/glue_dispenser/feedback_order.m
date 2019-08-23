%% PROTOTYPE OF THE FEEDBACK ORDER SENDER FOR ULTIMUS V %%

%Process of feedback order:     
% ENQ--->    
% ACK<---
% FEEDBACK ORDER(STX+COMMAND+ETX)--->
% A0/A2<---
% ACK--->
% FEEDBACK<---
% EOT--->


    %% PROTOTYPE OF THE DOWNLOAD ORDER SENDER FOR ULTIMUS V %%
%Process of download order:     
% ENQ--->    
% ACK<---
% DOWNLOAD ORDER(STX+COMMAND+ETX)--->
% A0/A2<---
% EOT--->

clear all
clc
delete(instrfindall);   %closing all ports 

% basic communication values %

ENQ=5;
STX=2;
ETX=3;
EOT=4;
ACK=6;

% Defining order to be exectuted: adding number of bytes and calculating checksum %

command=['E5  '];

ByteNumer=length(command);        % number of bytes to be sent

if ByteNumer<10
    order=['0',num2str(ByteNumer),command];
else
    order=[num2str(ByteNumer),command];
end

orderDec=double(order);
checkSum=-sum(orderDec);
checkSumBin=dec2bin(typecast(int16(checkSum),'uint8'));
CSbinChar=checkSumBin(1,:);
CSBinNum=zeros(1,length(CSbinChar(1,:)));
for i=1:length(CSbinChar)
    CSBinNum(i)=str2double(CSbinChar(i));
end
CShex=binaryVectorToHex(CSBinNum);

OrderComplete=[order CShex];

% creating serial port object % 

s1 = serial('COM4','BaudRate',115200,'DataBits',8,'Terminator','CR','BytesAvailableFcnMode','byte'); %creating serial port object
set(s1, 'BaudRate', 115200);          % set BaudRate to 115200
set(s1, 'Parity','none');             % set Parity Bit to None
set(s1, 'DataBits', 8);               % set DataBits to 8
set(s1, 'StopBit', 1);                % set StopBit to 1
out1 = instrfind('Port','COM4');

% opening serial port %

fopen (s1); 

% Sending ENQ %

fwrite(s1,5)

% reading ACK %

input1=fread(s1,1);

% Sending order %

package=[STX double(OrderComplete) ETX];
for i=1:length(package)
    fwrite(s1,package(i));
end

% Reading confirmation A0-->ok  A2-->error %

confirmation=readPort(s1);               % reading ETX

% sending ACK %

fwrite(s1,6)

% Reading feedback %

feedback=readPort(s1); 
disp('feedback value is:\n');
disp(feedback);

% Sending EOT %
fwrite(s1,4)

%%




