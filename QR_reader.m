
TimeOut = 15;
out = ' ';
ExitCommand = 'END';
ComPort = 'COM3';

delete(instrfindall);
QRreader = serial(ComPort,'BaudRate',9600,'DataBits',8,'Terminator','CR','BytesAvailableFcnMode','byte') %creating serial port object
fopen(QRreader)
readasync(QRreader)             %Reading in async mode. Read input buffer as soon as new data is available.
fileID = fopen('QRcodes.txt','a');         % 'w' writting or 'a' append;
fprintf(fileID,'## %s ##\n', datetime);
disp ('Ready to Scan\n');
tic;
while (strcmp(out, ExitCommand) == 0) && (toc < TimeOut)
%     out = fscanf(QRreader);               % Read ASCII data from device, and format as text
%     out = fgets(QRreader);                % Read line of text from device and include terminator
    out = fgetl(QRreader);                  % Read line of ASCII text and discard terminator
    
    if (isempty(out)) == 0                  % If some input arrived:
        tic;                                % Reset timeout timer
        fprintf(fileID,'%s \n', out);       % Write readed code to the file
        fprintf('Readed QRcode: %s \n', out);
    end  
end
fprintf(fileID,'\n');

fclose(fileID);
stopasync(QRreader);
fclose(QRreader);
disp ('Finish reading');