 %%%% startupFcn: ALL CHANGES DONE IN startupFcn OF ModulePlacement_MATLAB APP %%%%

function OriginalstartupFcn(app)
            % Initialize list
            dialog1 = 'Connecting to DAQ..............';
            dialog2 = 'Retrieving coordinate data...';
            dialog3 = 'Connecting to gantry............';
            dialog4 = 'Setting up camera................';
            
            % Check if the Admin Folder (for locking files) is open/closed
            if (exist('AdminFolder', 'dir') == 7)
                locker = app.unlockFile;
            else
                locker = app.lockFile;
            end
            
            % Determine which folder this file is in, and add it, as well as all other related folders, to the path
            app.folder = fileparts(which(mfilename('fullpath')));
            app.folder = erase(app.folder,locker);
            addpath(genpath(app.folder));
            
            % Setup read/write file locations and directories
            app.outputFile = sprintf('%s%s',app.folder,app.outputFile);
            app.outputFileTmp = sprintf('%s%s',app.folder,app.outputFileTmp);
            app.imageDirectory = sprintf('%s%s',app.folder,app.imageDirectory);
            app.fiducialDirectory = sprintf('%s%s',app.folder,app.fiducialDirectory);
            app.surveyResultsFile = sprintf('%s%s',app.outputFile,app.surveyResultsFile);
            app.imageOutDirectory = sprintf('%s%s',app.folder,app.imageOutDirectory);   
            
            app.gantryFile = sprintf('%s%s%s',app.folder,locker,app.gantryFile);
            app.surveyFile = sprintf('%s%s%s',app.folder,locker,app.surveyFile);
            app.glueFile = sprintf('%s%s%s',app.folder,locker,app.glueFile);
            app.userFile = sprintf('%s%s%s',app.folder,locker,app.userFile);

            % Store petal image and show petal
            app.petalImg = imread('PetalImgA.png');
            imshow(app.petalImg,'Parent',app.PetalPic);
            
            % Show button images
            app.gantryViewButton.Icon = 'GantryTable.png';
            
            icon = 'Home.png';
            app.X_Home.Icon = icon;
            app.Y_Home.Icon = icon;
            app.Z_Home.Icon = icon;
            app.U_Home.Icon = icon;
            
            icon = 'Disable.png';
            app.X_Enable.Icon = icon;
            app.Y_Enable.Icon = icon;
            app.Z_Enable.Icon = icon;
            app.U_Enable.Icon = icon;
            %---------------------------------------------------%
            % add appropriate number of control ports for NI controller
            app.OutputTextArea.Value = sprintf('%s',dialog1);
            portText = sprintf('Port0/Line0:%d',app.num-1);
            app.port = zeros(1,app.num);
            app.s = daq.createSession('ni');
            strDAQ = 'Done.';
            
            try % try/catch to test if DAQ is connected/running
                addDigitalChannel(app.s,'cDAQ1Mod1',portText,'OutputOnly');
            catch
                strDAQ = 'Failed.';
            end
            
            if (strcmp(strDAQ,'Done.'))
                outputSingleScan(app.s,app.port);
                app.daqFlag = 1;
            end
            %---------------------------------------------------%
            % Setup filenames and load program variables from file(s)
            app.surveyFile = sprintf('%s%s',app.outputFile,app.surveyFile);
            app.surveyResultsFile = sprintf('%s%s',app.outputFile,app.surveyResultsFile);
            app.glueFile = sprintf('%s%s',app.outputFile,app.glueFile);
            
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s',dialog1,strDAQ,dialog2);
            
            if (isfile(app.gantryFile))
                [~,~,data] = xlsread(app.gantryFile);
                
                app.petalAngle = 0;  % value of measured angle of petal (after measuring fiducial locations)
                
                str = 'Petal Coordinates';
                com = strcmpi(str, data(:,1));   % Compare user input string with entries in the Excel sheet
                row = find(com == 1); %Get Row number
                app.petalXYZ1 = cell2mat([data(row+1,1) data(row+1,2) data(row+1,3)]);
                app.petalXYZ2 = cell2mat([data(row+2,1) data(row+2,2) data(row+2,3)]);
                
                str = 'Camera';
                com = strcmpi(str, data(:,1));   % Compare user input string with entries in the Excel sheet
                row = find(com == 1); %Get Row number
                app.camera = cell2mat([data(row+1,1) data(row+1,2) data(row+1,3)]);
                app.cameraAdaptor = cell2mat(data(row+2,1));
                app.cameraName = cell2mat(data(row+2,2));
                app.cameraFormat = cell2mat(data(row+2,3));
                app.cameraID = cell2mat(data(row+2,4));
                strData = 'Done.';
            else
                strData = 'Failed.';
            end
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s\t%s\n%s',dialog1,strDAQ,dialog2,strData,dialog3);
            %---------------------------------------------------%
            % Add the gantry conroller Matlab library to path,
            % first checking if directories for Aerotech/A3200 exists
            tmp1 = sprintf('%s%s%s',app.folder,locker,'\AerotechFunctions');
            tmp2 = 'C:\Program Files (x86)\Aerotech\A3200\Matlab';
            
            if (exist(tmp1,'dir') == 7)
                tmp = tmp1;
                tmp1 = 1;  
                tmp2 = 1;
            elseif (exist(tmp2,'dir') == 7)
                tmp = tmp2;
                tmp1 = 1;
                tmp2 = 1;
            end
            if (tmp1 && tmp2)
                arch = computer('arch');
                if(strcmp(arch, 'win32'))
                    addpath(sprintf('%s\\x86',tmp));
                elseif(strcmp(arch, 'win64'))
                    addpath(sprintf('%s\\x64',tmp));
                end
            
                app.handle = A3200Connect;
                
                % Set up acceleration ramp type to SINUSOIDAL
                A3200MotionSetupRampTypeAxis(app.handle, app.task, app.X, 2);
                A3200MotionSetupRampTypeAxis(app.handle, app.task, app.Y, 2);
                A3200MotionSetupRampTypeAxis(app.handle, app.task, app.Z, 2);
                A3200MotionSetupRampTypeAxis(app.handle, app.task, app.U, 2);
                % Set up acceleration ramp mode to TIME
                A3200MotionSetupRampModeAxis(app.handle, app.task, app.X, 1);
                A3200MotionSetupRampModeAxis(app.handle, app.task, app.Y, 1);
                A3200MotionSetupRampModeAxis(app.handle, app.task, app.Z, 1);
                A3200MotionSetupRampModeAxis(app.handle, app.task, app.U, 1);
                % Set up acceleration ramp time to 'accelTime' seconds
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.X, app.accelTime);
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.Y, app.accelTime);
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.Z, app.accelTime);
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.U, app.accelTime);
                
                % Stop motion if any present
                A3200MotionAbort(app.handle, app.allAxes);
                pause(0.1);
                
                app.gantryFlag = 1;
                strGantry = 'Done.';
            else
                strGantry = 'Failed.';
            end
            
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s\t%s\n%s\t%s\n%s',dialog1,strDAQ,dialog2,strData,dialog3,strGantry,dialog4);
            %---------------------------------------------------%
            % Open camera view as separate window
            screenSize = get(0,'ScreenSize');
            app.screen = figure('name', 'Camera View', 'NumberTitle', 'off');
            width = app.screen.Position(3);
            height = app.screen.Position(4);
            app.screen.Position = [(screenSize(3)-width) (screenSize(4)-height)/2 width height];
            %---------------------------------------------------%
            % Open and intitialize camera
            imshow(zeros(1374,1792), 'InitialMagnification',app.scale);
            
            strCamera = 'Failed';
            % Check if video device has been previously found; if not, find it
            out = 1;
            if (~app.cameraID)
                out = formatCamera(app);
            end
            if (out)
                camOn(app,-2);
                strCamera = 'Done.';
            end
            
            % Enable top drop-down menus
            app.FileMenu.Enable = 'on';
            app.AccountMenu.Enable = 'on';
            app.EmergencyStateMenu.Enable = 'on';
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s\t%s\n%s\t%s\n%s\t%s\n\nReady!',dialog1,strDAQ,dialog2,strData,dialog3,strGantry,dialog4,strCamera);
            %%----------------------------------------------------------------------------------------------------------------------------------------------------%%
end
        


%% modified function %%

function ModifiedstartupFcn(app)

%             % Initialize list
%             dialog1 = 'Connecting to DAQ..............';   %% There is no Daq (probably to vaccum valves control)
            dialog1 = '';
            dialog2 = 'Retrieving coordinate data...';
            dialog3 = 'Connecting to gantry............';
            dialog4 = 'Setting up camera................';
            
            % Check if the Admin Folder (for locking files) is open/closed
            if (exist('AdminFolder', 'dir') == 7)
                locker = app.unlockFile;
            else
                locker = app.lockFile;
            end
            
            % Determine which folder this file is in, and add it, as well as all other related folders, to the path
            app.folder = fileparts(which(mfilename('fullpath')));
            app.folder = erase(app.folder,locker);
            addpath(genpath(app.folder));
% %             addpath('D:\Code\MATLAB_app\ALIO.m');   %% adding path ALIo class (necessary?)
            
            % Setup read/write file locations and directories
            app.outputFile = sprintf('%s%s',app.folder,app.outputFile);
            app.outputFileTmp = sprintf('%s%s',app.folder,app.outputFileTmp);
            app.imageDirectory = sprintf('%s%s',app.folder,app.imageDirectory);
            app.fiducialDirectory = sprintf('%s%s',app.folder,app.fiducialDirectory);
            app.surveyResultsFile = sprintf('%s%s',app.outputFile,app.surveyResultsFile);
            app.imageOutDirectory = sprintf('%s%s',app.folder,app.imageOutDirectory);   
            
            app.gantryFile = sprintf('%s%s%s',app.folder,locker,app.gantryFile);
            app.surveyFile = sprintf('%s%s%s',app.folder,locker,app.surveyFile);
            app.glueFile = sprintf('%s%s%s',app.folder,locker,app.glueFile);
            app.userFile = sprintf('%s%s%s',app.folder,locker,app.userFile);

            % Store petal image and show petal
            app.petalImg = imread('PetalImgA.png');
            imshow(app.petalImg,'Parent',app.PetalPic);
            
            % Show button images
            app.gantryViewButton.Icon = 'GantryTable.png';
            
            icon = 'Home.png';
            app.X_Home.Icon = icon;
            app.Y_Home.Icon = icon;
            app.Z_Home.Icon = icon;
            app.U_Home.Icon = icon;
            
            icon = 'Disable.png';
            app.X_Enable.Icon = icon;
            app.Y_Enable.Icon = icon;
            app.Z_Enable.Icon = icon;
            app.U_Enable.Icon = icon;
            %---------------------------------------------------%
            % add appropriate number of control ports for NI controller
            
%             app.OutputTextArea.Value = sprintf('%s',dialog1);     %% we have no Daq
%             portText = sprintf('Port0/Line0:%d',app.num-1);
%             app.port = zeros(1,app.num);
%             app.s = daq.createSession('ni');
            strDAQ = 'Done.';
%             
%             try % try/catch to test if DAQ is connected/running
%                 addDigitalChannel(app.s,'cDAQ1Mod1',portText,'OutputOnly');
%             catch
%                 strDAQ = 'Failed.';
%             end
%             
%             if (strcmp(strDAQ,'Done.'))
%                 outputSingleScan(app.s,app.port);
%                 app.daqFlag = 1;
%             end
            
            %---------------------------------------------------%
            % Setup filenames and load program variables from file(s)
            app.surveyFile = sprintf('%s%s',app.outputFile,app.surveyFile);
            app.surveyResultsFile = sprintf('%s%s',app.outputFile,app.surveyResultsFile);
            app.glueFile = sprintf('%s%s',app.outputFile,app.glueFile);
            
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s',dialog1,strDAQ,dialog2);
            
            if (isfile(app.gantryFile))
                [~,~,data] = xlsread(app.gantryFile);
                
                app.petalAngle = 0;  % value of measured angle of petal (after measuring fiducial locations)
                
                str = 'Petal Coordinates';
                com = strcmpi(str, data(:,1));   % Compare user input string with entries in the Excel sheet
                row = find(com == 1); %Get Row number
                app.petalXYZ1 = cell2mat([data(row+1,1) data(row+1,2) data(row+1,3)]);
                app.petalXYZ2 = cell2mat([data(row+2,1) data(row+2,2) data(row+2,3)]);
                
                str = 'Camera';
                com = strcmpi(str, data(:,1));   % Compare user input string with entries in the Excel sheet
                row = find(com == 1); %Get Row number
                app.camera = cell2mat([data(row+1,1) data(row+1,2) data(row+1,3)]);
                app.cameraAdaptor = cell2mat(data(row+2,1));
                app.cameraName = cell2mat(data(row+2,2));
                app.cameraFormat = cell2mat(data(row+2,3));
                app.cameraID = cell2mat(data(row+2,4));
                strData = 'Done.';
            else
                strData = 'Failed.';
            end
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s\t%s\n%s',dialog1,strDAQ,dialog2,strData,dialog3);
            %---------------------------------------------------%
            % Add the gantry conroller Matlab library to path,
            % first checking if directories for Aerotech/A3200 exists
%             tmp1 = sprintf('%s%s%s',app.folder,locker,'\AerotechFunctions');
%             tmp2 = 'C:\Program Files (x86)\Aerotech\A3200\Matlab';
%             
%             if (exist(tmp1,'dir') == 7)       %% bypass the loading of aerotech functions
%                 tmp = tmp1;
%                 tmp1 = 1;  
%                 tmp2 = 1;
%             elseif (exist(tmp2,'dir') == 7)
%                 tmp = tmp2;
%                 tmp1 = 1;
%                 tmp2 = 1;
%             end

            
%                 arch = computer('arch');
%                 if(strcmp(arch, 'win32'))
%                     addpath(sprintf('%s\\x86',tmp));
%                 elseif(strcmp(arch, 'win64'))
%                     addpath(sprintf('%s\\x64',tmp));
%                 end
            
                app.handle=ALIO;
                ASCSConnect(app.handle);
                
             if (app.handle.gantry.IsConnected)
                
%                 % Set up acceleration ramp type to SINUSOIDAL%% unexisted in ALIO llibrary
%                 A3200MotionSetupRampTypeAxis(app.handle, app.task, app.X, 2);
%                 A3200MotionSetupRampTypeAxis(app.handle, app.task, app.Y, 2);
%                 A3200MotionSetupRampTypeAxis(app.handle, app.task, app.Z, 2);
%                 A3200MotionSetupRampTypeAxis(app.handle, app.task, app.U, 2);
%                 % Set up acceleration ramp mode to TIME
%                 A3200MotionSetupRampModeAxis(app.handle, app.task, app.X, 1);
%                 A3200MotionSetupRampModeAxis(app.handle, app.task, app.Y, 1);
%                 A3200MotionSetupRampModeAxis(app.handle, app.task, app.Z, 1);
%                 A3200MotionSetupRampModeAxis(app.handle, app.task, app.U, 1);
                
                
                % Set up acceleration ramp time to 'accelTime' seconds
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.X, app.accelTime);
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.Y, app.accelTime);
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.Z, app.accelTime);
                A3200MotionSetupRampTimeAxis(app.handle, app.task, app.U, app.accelTime);
                
                % Stop motion if any present
                A3200MotionAbort(app.handle, app.allAxes);
                pause(0.1);
                
                app.gantryFlag = 1;
                strGantry = 'Done.';
            else
                strGantry = 'Failed.';
            end
            
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s\t%s\n%s\t%s\n%s',dialog1,strDAQ,dialog2,strData,dialog3,strGantry,dialog4);
            %---------------------------------------------------%
            % Open camera view as separate window
            screenSize = get(0,'ScreenSize');
            app.screen = figure('name', 'Camera View', 'NumberTitle', 'off');
            width = app.screen.Position(3);
            height = app.screen.Position(4);
            app.screen.Position = [(screenSize(3)-width) (screenSize(4)-height)/2 width height];
            %---------------------------------------------------%
            % Open and intitialize camera
            imshow(zeros(1374,1792), 'InitialMagnification',app.scale);
            
            strCamera = 'Failed';
            
            % Check if video device has been previously found; if not, find it (CHANGED)
%             out = 1;
%             if (~app.cameraID)
%                 out = formatCamera(app);
%             end

             out = formatCamera(app); %% checkear siempre cámara (buscar configuracion)

            if (out)
                camOn(app,-2);
                strCamera = 'Done.';
            end
            
            % Enable top drop-down menus
            app.FileMenu.Enable = 'on';
            app.AccountMenu.Enable = 'on';
            app.EmergencyStateMenu.Enable = 'on';
            app.OutputTextArea.Value = sprintf('%s\t%s\n%s\t%s\n%s\t%s\n%s\t%s\n\nReady!',dialog1,strDAQ,dialog2,strData,dialog3,strGantry,dialog4,strCamera);
            %%----------------------------------------------------------------------------------------------------------------------------------------------------%%
end
