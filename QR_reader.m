

QRreader = serial('COM7','BaudRate',9600,'DataBits',8,'Terminator','CR','BytesAvailableFcnMode','byte') %creating serial port object
fopen(QRreader)
readasync(QRreader)             %Reading in async mode. Read input buffer as soon as new data is available.
out = ' ';
fileID = fopen('QRreaded.txt','a');     % 'w' writting or 'a' append;
% fprintf(fileID,'#################\n', datetime);
fprintf(fileID,'## %s ##\n', datetime);
disp ('Ready to Scan\n');
tic;
while (strcmp(out,'END') == 0) && (toc < TimeOut)
%     out = fscanf(QRreader)
%     out = fgets(QRreader
    out = fgetl(QRreader);
    
    if (isempty(out)) == 0              % If some input arrived:
        tic;                            % Reset timeout timer
        fprintf(fileID,'%s \n', out);   % Print date to the file
        fprintf('Readed QRcode: %s \n', out);
    end  
end
fprintf(fileID,'\n', datetime);

fclose(fileID);
stopasync(QRreader)
fclose(QRreader)
disp ('Finish reading');