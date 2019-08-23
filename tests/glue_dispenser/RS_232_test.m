%%%%% ULTIMUS V SERIAL PORT COMMUNICATION RS 232 %%%%

%% EXAMPLE: SETTING PRESSURE IN 50 PSI %%
%
%
% COMAND LINE TO BE SENT: STX 0 8 P S - - 0 5 0 0 F 0 ETX
% 
% 
%       STX --> STARTING COMMAND (1 BYTE)
%       08 --> Nº DE BYTES (2 BYTES)
%       PS-- --> PRESURE SETTING (4 BYTES)
%       0500 --> 50PSI (4 BYTES)
%       F 0 --> CHECKSUM (2 BYTES)
%       ETX --> ENDING COMMAND (1 BYTE)
% 
% ALL THE DATA IS SENT AS  ASCII DECIMAL VALUES CODED IN N=8 BYTES: https://elcodigoascii.com.ar/
% 
% 
% HOW TO GET CHECKSUM:   
%                       
% 1. PASS THE DATA BYTES TO DECIMAL USING ASCII: 
%
% DB (0 8 P S - - 0 5 0 0)
% DBD (48 56 80 83 32 32 48 53 48 48)
%      
% 2. NEGATIVE SUM DATA BYTES DECIMAL: -SUM(DBD) =-528
% 
%  
% 3. DECIMAL TO BINARY, COMPLEMENT TO 2, 16 BITS -528-->1111110111110000 
% 
% 4. TAKE THE LEAST SIGNIFICANT BYTE (LAST 8 BITS) : 1111110111110000 --> 11110000
% 
% 5. BYNARY TO HEX: 11110000 --> F0
% 
% For more information, please check ULTIMUS V manual, APPENDIX B, RS-232 Protocol
% 
% For comments/questions, contact with pablo.leon@cern.ch
%
% 
% 
% 
% 

    %% PRELIMINARY TESTS TO CLARIFY HOW TO PROCEED WITH RS 232 COM SYSTEM FROM MATLAB %%

clear all
clc
delete(instrfindall);   %closing all ports

ENQ=5;
STX=2;
ETX=3;
EOT=4;
ACK=6;

s1 = serial('COM4','BaudRate',115200,'DataBits',8,'Terminator','CR','BytesAvailableFcnMode','byte'); %creating serial port object
set(s1, 'BaudRate', 115200);          % set BaudRate to 115200
set(s1, 'Parity','none');             % set Parity Bit to None
set(s1, 'DataBits', 8);               % set DataBits to 8
set(s1, 'StopBit', 1);                % set StopBit to 1
out1 = instrfind('Port','COM4');

fopen (s1);     % Opening COM 4
% pause(0.1);

fwrite(s1,5)    % ENQ (CONSULTING, ASCII VALUE 5)
% pause(0.1)      % Wait in order to leave Ultimus send the acknowledge order (ACK, 6 in ASCII)
serialbreak(s1)
input1=fread(s1,1);

code=['08PS  0500F0'];
v=[STX double(code) ETX];
for i=1:length(v)
    fwrite(s1,v(i));
end

inSTX = fread(s1,1);
inNumberBytes= fread(s1,2);

charNumberBytes=char(inNumberBytes);
charVector=strcat(charNumberBytes(1),charNumberBytes(2));
numberBytes=str2double(charVector);

inMessage=fread(s1,numberBytes);
inETX=fread(s1,1);


fwrite(s1,4) % EOT (END COMMUNICATION, ASCII VALUE 4)
fclose (s1);    % Closing COM 1