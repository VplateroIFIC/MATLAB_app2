classdef DISPENSER < handle
    %DISPENSER Class which manage the control of the Ultimus V glue dispenser
    %   This class provides full control over Ultimus V glue dispenser.
    %   Communication is based in RS232 protocol.
    %   Equipment has to be conected to Ultimus V, and set the number of the COM port. (default COM 4)
    %   To set parameters in the dispenser (dowload order) setUltimus function is used.
    %   To get parameters from the dispenser (feedback order) getUltimus function is used.
    %   To change the initialization parameters, please adjust the Connect function.
    
    properties (Constant, Access = public)
        ENQ=5;
        STX=2;
        ETX=3;
        EOT=4;
        ACK=6;
    end
    
    properties (Access=public)
        ComPort = 'COM1';
        IsConnected=0;  
        s1;
    end
    
    methods
        function this = Connect(this)
            %Connect Connection with the dispenser device
            %   this function open the serial port and inizializate the glue dispenser.
            %   Initial parameters are set to:
            %   Pressure Units: psi
            %   Dispenser Mode: Temporized
            %   Dispensing Pressure: 50
            %   Dispensing time window: 1 s
            %   Dispensing vacuum: 0.5
            delete(instrfindall);   %closing all ports
            
            this.s1 = serial(this.ComPort,'BaudRate',115200,'DataBits',8,'Terminator','CR','BytesAvailableFcnMode','byte'); %creating serial port object
            set(this.s1, 'BaudRate', 115200);          % set BaudRate to 115200
            set(this.s1, 'Parity','none');             % set Parity Bit to None
            set(this.s1, 'DataBits', 8);               % set DataBits to 8
            set(this.s1, 'StopBit', 1);                % set StopBit to 1
            out1 = instrfind('Port','COM1');
            this.SetUltimus('E6  00');   %Setting pressure units
            this.SetUltimus('TT  ');   %Setting Temporized mode
            this.SetUltimus('PS  0500');   %Dispensing Pressure: 50 psi
            this.SetUltimus('DS  T10000');   %Dispensing time window: 1 s
            this.SetUltimus('VS  0050');   %Setting vacuum: 0.5
            this.IsConnected=1;
            disp('Conection with Ultimus done')
        end
        
        
        function this=Disconnect(this)
            %   Disconnect Disconnect the dispenser device
            %   this function close the serial port and delete all the serial port objects.
            delete(instrfindall);
            this.IsConnected=0;
            disp('Ultimus disconnected');
        end
        
        
        function error = SetUltimus(this,command)
            
            
            % SetUltimus Download commands to Ultimus
            % input1: DISPENSER object
            % Input 2: char string with command of Ultimus to be executed. '-' is equivalent to space: ' ' .
            %
            % For more information, please check the user manual of Ultimus V dispenser, Apendix B, RS232 conection protocol
            %
            %
            % Memory Change Command  CH--ccc   ccc: The 3-digit memory location from 0–399. The dispenser will automatically limit value to prevent any errors.
            % Timed Mode Command   TT--   This command switches the dispenser into timed mode.
            % Steady Mode Command  MT--   This command switches the dispenser into steady mode.
            % Time / Steady Toggle Command   TM--   This command toggles the dispenser between Timed mode and Steady mode.
            % Pressure Set Command    PS--pppp   pppp: The 4-digit pressure setting excluding the decimal point. This is a unitless value.
            %
            % Memory-Pressure Set Command PH--CHcccPpppp     ccc: The 3-digit memory location from 0–399. pppp: The 4-digit pressure setting, excluding the decimal point.
            % Vacuum Set Command   VS--vvvv    vvvv: The 4-digit vacuum, setting excluding the decimal point.
            % Memory-Vacuum Set Command   VH--CHcccVvvvv   ccc: The 3-digit memory location from 0–399.  vvv: The 4-digit vacuum setting, excluding the decimal point.
            % Time Set Command   DS--Tttttt   ttttt: The 4- or 5-digit dispense time value, excluding the decimal point.
            % Memory-Time Set Command  DH--CHcccTttttt   ccc: The 3-digit memory location from 0–399.  ttttt: The 4- or 5-digit dispense time value, excluding the decimal point.
            % Memory-Time-Pressure-Vacuum Set Command   EM--CHcccTtttttPppppVvvvv    ccc: The 3-digit memory location from 0–399.   ttttt: The 5-digit dispense time value excluding the decimal point.
            % pppp:  The 4-digit dispense pressure value excluding the decimal point.   vvvv: The 4-digit vacuum value excluding the decimal point.
            %
            % Pressure Units Set Command   E6--uu   uu:  The pressure units. 00 = PSI, 01 = BAR, 02 = KPA
            % Vacuum Units Set Command    E7--uu    uu:  The vacuum units. 00 = KPA, 01 = Inches H2O, 02 = Inches Hg, 03 = mmHg, 04 = TORR.
            % Dispense Parameter Memory Clear   CL--    This command will re-initialize the dispensing parameters memory locations by setting them all to 0.
            % Deposit Count Clear Command   EA--     This command will reset the deposit counter on the dispenser to all zeros.
            % Reset Auto Increment Command   SE--    This command resets the Auto Increment functions.
            %
            % Auto Increment On / Off Command    AI--i    i: Enable Command. 0=OFF, 1 = ON
            % Auto Increment Mode Command     AC--SsDdddd    s: Mode Command. 1 = Timer Mode, 2 = Counter Mode, 4 = Auto Sequence Mode.   dddd: Trigger Value. 0001–9999
            %
            % Set Start & End Address Command  SS--SsssEeee   sss: Start Address 000–399   eee: End Address 000–399
            % Set Trigger Value Command  EQ--Tttttt    ttttt: Trigger Value. 00001–99999
            % Set the Real Time Clock Command   EB--HhhMmmAMa   hh: Hours. 0–23 for 24 Hour format, 1–12 for 12 Hour Format   mm:  Minutes. 0–59    a: Hour format. 0 = AM, 1 = PM, 2 = 24 Hour Format
            % Set the Real Time Date Command    EC--MmmDddYyy  mm:  Months. 1–12    dd:Days. 1–31   yy: Years. 00–99
            %
            % Operator Lockout Set Command     EG--PAppppDTtDPpDVvMmDCcDMdAIaARuALbMMePUfVUgLAhCLjCOkAMn
            % pppp:4-digit password. This needs to match the password set on the dispenser. The dispenser will return an error if incorrect.
            % t:Lockout dispense time: “1”=lockout, “0”=enabled (DT)
            % p:Lockout dispense pressure (DP)
            % v:Lockout dispense vacuum (DV)
            % m:Lockout memory cell selection (DM)
            % c:Lockout deposit counter selection (DC)
            % d:Lockout dispense mode change (DM)
            % a:Lockout Auto Increment Mode selection (AI)
            % u:Lockout Auto Increment Reset (AR)
            % b:Lockout Alarms Reset (AL)
            % e:Lockout Main Menu selection (MM)
            % f:Lockout Pressure Unit Menu selection (PU)
            % g:Lockout Vacuum Unit Menu selection (VU)
            % h:Lockout Language Menu selection (LA)
            % j:Lockout Set Clock / Date Menu selection (CL)
            % k:Lockout Set Communications Menu selection (CO)
            % n:Lockout Alarm Options Menu selection (AM)
            %
            % Set Language Command  ED--LI: Language Index
            % 0 = English
            % 1 = French
            % 2 = German
            % 3 = Spanish
            % 4 = Italian
            % 5 = Chinese
            % 6 = Japanese
            % 7 = Korean
            %
            % Alarm Options Set Command     EI--INiIOoILlPOpPLbAEeAOa
            % i:Enable Input Alarm (IN)
            % o:Enable Output of Input Alarm (IO)
            % l:Latch the Input Alarm (IL)
            % p:Enable Output of the Pressure Alarm (PO)
            % b:Latch the Pressure Alarm (PL)
            % e:Enable Auto Increment Alarm (AE)
            % a:Enable Output of the Auto Increment Alarm (AO)
            %
            % Reset Alarms Command  EK--   This command clears any latched alarm in the Ultimus V.
            % Dispense Command    DI-    This command initiates a dispense cycle in the Ultimus V.
            
            
            % Defining order to be exectuted: adding number of bytes and calculating checksum %
            
            error = 0;
            OrderComplete=this.commandBuilder(command);
            
            % opening serial port %
            fclose(this.s1);
            fopen (this.s1);
            
            % Sending ENQ %
            
            fwrite(this.s1,this.ENQ)
            
            % reading ACK %
            
            input1=fread(this.s1,1);
            if (input1~=this.ACK)
                fprintf ('Error in in command "%s": ENQ was not received', command);
                error = -1;
                return
            end
            
            % Sending full order %
            
            package=[this.STX double(OrderComplete) this.ETX];
            for i=1:length(package)
                fwrite(this.s1,package(i));
            end
            
            % Reading confirmation A0-->ok  A2-->error %
            
            input2=this.readPort(this.s1);
            %         if (double(input2)~=double('A0'))
            if (strcmp(input2,'A0') == 0)
                fprintf('\nError in command "%s": A2 was returned\n', command);
                error = -2;
                return
            end
            
            % Sending EOT %
            fwrite(this.s1,this.EOT)
        end
        
        function feedBack=GetUltimus(this,command)
            %   GetUltimus: Get info from Ultimus
            %   input1: DISPENSER object
            %   Input 2: char string with command of Ultimus to be executed. '-' is equivalent to space: ' ' .
            %   For more information, please check the user manual of Ultimus V dispenser, Apendix B, RS232 conection protocol
            %
            % Pressure Time Feedback Command    UCccc    ccc:  The 3-digit memory location from 0–399. The dispenser will automatically limit value to prevent any errors.
            % Return Format: D0PDppppDTtttt
            % pppp:The 4-digit pressure setting excluding the decimal point. This is a unitless value.
            % ttttt: The 4-digit dispense time value excluding the decimal point.
            %
            % Memory Channel, Dispense Pressure, and Dispense Time Feedback Command   UD---
            % Return Format: D0ChcccPDppppDTttttt
            % ccc:The 3-digit memory location from 0–399.
            % pppp:The 4-digit pressure setting excluding the decimal point.
            % ttttt:The 4-digit dispense time value excluding the decimal point.
            %
            % Pressure Time Vacuum Feedback Command   E8ccc   ccc: The 3-digit memory location from 0–399.
            % Return Format: D0PDppppDTtttttVCvvvv
            % pppp: The 4-digit pressure setting excluding the decimal point.
            % ttttt: The 5-digit dispense time value excluding the decimal point.
            % vvvv: The 4-digit vacuum setting excluding the decimal point.
            %
            % Memory Location Feedback Command    UA---
            % Return Format: D0ccc
            % ccc: The 3-digit memory location from 0–399.
            %
            % Pressure Units Feedback Command   E4--
            % Return Format: D0PUuu
            % uu: The pressure units. 00 = PSI, 01 = BAR, 02 = KPA
            %
            % Vacuum Units Feedback Command    E5--
            % Return Format: D0VUuu
            % uu:The vacuum units. 00 = KPA, 01 = Inches H2O, 02 = Inches Hg, 03 = mmHg, 04 = TORR
            %
            % Total Status Feedback Command   AU---
            % Return Format: D0AIiMmSssssDdddddddVIqVvvvvIttttTMxSAaaaEAeee
            % i:Auto Increment mode status. 0 = Off, 1 = Enabled
            % m:Auto Increment mode function. 1 = Timer, 2 = Count, 4=Auto Sequence Mode
            % ssss:Trigger Value. The upper digit is truncated to make this function compatible with the Musashi command
            % ddddddd:Current Timer / Counter value
            % q:Defaulted to 0
            % vvvv:Defaulted to 0001
            % tttt:Defaulted to 0001
            % x:Dispense mode. 0 = Timed, 1 = Steady, 2 = Teach
            % aaa:Auto Increment Start Address. 000–399
            % eee:Auto Increment End Address. 000–399
            %
            % Trigger Value Feedback Command    ER--
            % Return Format: D0TVttttt
            % ttttt: 5-digit trigger value. Range is 00000–99999.
            %
            % Deposit Count Feedback Command     E9--
            % Return Format: D0SCccccccc
            % ccccccc: 7-digit deposit counter. Range is 0000000 to 9999999.
            %
            % Real Time Clock Feedback Command    EE--
            % Return Format: D0HhhMmmAMa
            % hh:Hours. 0–23 for 24 Hour Format, 1–12 for 12 Hour Format
            % mm:Minutes. 0–59
            % a:Hour format. 0 = AM, 1 = PM, 2 = 24 Hour Format
            %
            % Real Time Date Feedback Command    EF--
            % Return Format: D0MmmDddYyy
            % mm:Months. 1–12
            % dd:Days. 1–31
            % yy:Years. 00–99
            %
            % Operator Lockout feedback Command    EH--PApppp    pppp:  4-digit password. This needs to match the password set on the dispenser. The dispenser will return an error if incorrect.
            % Return Format: D0DTtDPpDVvMmDCcDMdAIaARuALbMMePUfVUgLAhCLjCOkAMn
            % t:Lockout dispense time: “1”=lockout, “0”=enabled (DT)
            % p:Lockout dispense pressure (DP)
            % v:Lockout dispense vacuum (DV)
            % m:Lockout memory cell selection (M)
            % c:Lockout deposit counter selection (DC)
            % d:Lockout dispense mode change (DM)
            % a:Lockout Auto Increment Mode selection (AI)
            % u:Lockout Auto Increment Reset (AR)
            % b:Lockout Alarms Reset (AL)
            % e:Lockout Main Menu selection (MM)
            % f:Lockout Pressure Unit Menu selection (PU)
            % g:Lockout Vacuum Unit Menu selection (VU)
            % h:Lockout Language Menu selection (LA)
            % j:Lockout Set Clock / Date Menu selection (CL)
            % k:Lockout Set Communications Menu selection (CO)
            % n:Lockout Alarm Options Menu selection (AM)
            %
            % Alarm Options Feedback Command    EJ--
            % Return Format: D0INiIOoILlPOpPLbAEeAOa
            % i:Enable Input Alarm (IN)
            % o:Enable Output Of Input Alarm (IO)
            % l:Latch the Input Alarm (IL)
            % p:Enable Output of the Pressure Alarm (PO)
            % b:Latch the Pressure Alarm (PL)
            % e:Enable Auto Increment Alarm (AE)
            % a:Enable Output of the Auto Increment Alarm (AO)
            %
            % Alarm Status Feedback Command    EL--
            % Return Format: D0INiPApAIa
            % i:input Alarm Status: 1= Alarm is set, 2= No alarm
            % p:Pressure Alarm Status
            % a:Auto Increment Alarm Status
            
            OrderComplete=this.commandBuilder(command);
            
            % opening serial port %
            fclose(this.s1);
            fopen (this.s1);
            
            % Sending ENQ %
            
            fwrite(this.s1,this.ENQ)
            
            % reading ACK %
            
            input1=fread(this.s1,1);
            if (input1~=this.ACK)
                feedBack = -1;
                fprintf ('Error in in command "%s": ENQ was not received', command);
                return
            end
            
            % Sending order %
            
            package=[this.STX double(OrderComplete) this.ETX];
            for i=1:length(package)
                fwrite(this.s1,package(i))
            end
            
            % Reading confirmation A0-->ok  A2-->error %
            
            input2=this.readPort(this.s1);               % reading ETX
            % if (double(input2)~=double('A0'))
            if (strcmp(input2,'A0') == 0);
                feedBack = -2;
                fprintf ('Error in in command "%s": A2 was returned', command);
                return
            end
            
            % sending ACK %
            
            fwrite(this.s1,this.ACK)
            
            % Reading feedback %
            
            feedBack=this.readPort(this.s1);
            
            % Sending EOT %
            
            fwrite(this.s1,this.EOT)
        end
        
        
        
        function  feedBack=readPort(this,port)
            trigger=0;
            cont=1;
            while(trigger==0)
                input(cont)=fread(port,1);
                if input(cont)==this.ETX
                    trigger=1;
                end
                cont=cont+1;
            end
            fullInput=char(input);
            n=length(fullInput);
            feedBack=fullInput(4:n-3);
        end
        
        
        function fullCommand=commandBuilder(this,command)
            % commandBuilder function add to the basic comand the previous numbers and the checksum
            % input: command to be sent to Ultimus (char string)
            % output: Final command to be sent (char string)
            
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
            
            fullCommand=[order CShex];
        end
    end
end

