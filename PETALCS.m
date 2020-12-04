classdef PETALCS < handle
    %PETALCS this class manage the transformations of the coordinates systems used during the loading process.
    % Gantry coordinate system (GCS) --- petal coordinate system (PCS) --- Sensor Coordinate system (SCS)
    % The petal coordinate system is given by PETAL_SensorFiducial file (folder petalSensorFiducial) Origin in the lowest petal fiducial. Xaxis
    % 12.6 degrees from the line that connect 2 petal fiducials (roughly a line which slice the petal by the center)
    %
    %Sensor coordinate system is given by the F fiducials (top left corner of the fiducial). The origin is the left top F, and the X axis
    % is aligned with the line that connect
    % the 2 fiducials in the top. The top of the sensor is the max radius side with respect to the beam.
    %
    
    properties
        transMat_G2P                        % The transform gantry->petal
        transMat_P2G                        % Inverse of the above petal->gantry
        transMat_S2G                        % Cell array, transformations sensors to gantry
        transMat_G2S                        % Cell array, transformations gantry to sensors
        transMat_P2S                        % Cell array, transformations petal to sensors
        transMat_S2P                        % Cell array, transformations sensors to petal
        upper_petalFid                      % Nominal position of upper petal fiducial (gantry coordinates)
        lower_petalFid                      % Nominal position of lower petal fiducial (gantry coordinates)
        fiducials_petal                     % Positions of fiducials in petal coordinates (a Map)
        fiducials_gantry                    % Positions of fiducials in gantry coordinates (a Map)
        fiducials_sensors                   % Positions of fiducials in sensor coordinates
        anglePetalFiducials=12.6*pi/180;    % angle to be added to the line that connect petal fid to get the X petal axis
        anglePetal;                         % Angle that the petal wrt the gantry
        distancePetalFiducials=601;         % Distance between the 0.3mm fiducials of the petal (mm)
        angleFiducialsPetal;                % Angle of the vector fid1fid2 wrt the horizontal in gantry
        sensorLabel;                        % sensor names
        anglePetal2Sensor;                  % Angles of the transformation petal to sensor
        petalSide;                          % 0 for EoS right, 1 for EoS left. Looking from the beam.
    end
    
    methods
        function this = PETALCS(side,lowerFid,upperFid)
            %PETALCS Construct an instance of this class
            % define the petal coordinate system
            %
            % @param upperFid      Position in Gantry system of the upper
            %                      petal fiducial (farther side wrt the beam)(0.3mm fiducial)
            %                      If empty, upper fiducial will be chosen ramdonly
            % @param lowerFid      Position in Gantry system of the lower
            %                      petal fiducial (lower side wrt the beam)(0.3mm fiducial)
            %                      If empty, upper fiducial will [0 0]
            % @param side                Petal side. 0 for EoS right. 1 for EoS left. (looking the
            %                      with the minimum radius down wrt the beam)
            
            this.petalSide=side;
            
            %position of the petal fiducials in gantry system (0.3mm fiducials)
            if (nargin==1)
                this.lower_petalFid=[0 0];
                randAngle=2*pi*rand;
                this.upper_petalFid(1)=this.lower_petalFid(1)+this.distancePetalFiducials*cos(randAngle);
                this.upper_petalFid(2)=this.lower_petalFid(2)+this.distancePetalFiducials*sin(randAngle);
            elseif (nargin==3)
%                 this.lower_petalFid=flip(lowerFid);
%                 this.upper_petalFid=flip(upperFid);
                this.lower_petalFid=(lowerFid);
                this.upper_petalFid=(upperFid);
            end
            
            %reading nominal position of the fiducials in petal coordinates
            this.readingFiducials();
            
            %getting transformation matrix for gantry to petal
            this.GantryPetalTransMatrix();
            
            % getting transformation matrix from petal to sensor
            this.PetalSensorTransMatrix();
            
            %getting transformation matrix from gantry to sensor
            this.GantrySensorTransMatrix();
            
            % getting fiducials in gantry coordenates
            this.fiducialsInGantry();
            
            % getting fiducials in sensor coordenates
            this.fiducialsInSensor();

        end
        
        %% Methods to calculate transformation matrix %%
        
        function GantryPetalTransMatrix(this)
            % create transformation matrix Gantry to Petal and Petal to Gantry
            
            %transformation matrix definition
            this.transMat_G2P=transform2D();
            this.transMat_P2G=transform2D();
            
            % translation matrix
            origin(1)=-this.lower_petalFid(1);
            origin(2)=-this.lower_petalFid(2);
            this.transMat_G2P.translate(origin);

            
            % rotation matrix (angle between petalsc and gantrysc)
            vector=[this.upper_petalFid(1)-this.lower_petalFid(1),this.upper_petalFid(2)-this.lower_petalFid(2)];
            angle=atan2(vector(2),vector(1));
            this.angleFiducialsPetal=angle*180/pi;
            
            if this.petalSide==1
                this.anglePetal=2*pi-(angle-this.anglePetalFiducials);
                this.transMat_G2P.rotateMirrorY(this.anglePetal);
            else
                this.anglePetal=2*pi-(angle+this.anglePetalFiducials);
                this.transMat_G2P.rotate(this.anglePetal);
            end
            
            %getting transformation matrix from petal to gantry%
            this.transMat_P2G.M=inv(this.transMat_G2P.M);
        end
        
        function PetalSensorTransMatrix(this)
            % create transformation matrix petal to sensor and sensor to petal
            
            %separating fiducials per sensor flavor
            for j=1:length(this.sensorLabel)
                this.transMat_P2S.(this.sensorLabel{j})=transform2D();
                fiducials=this.fiducials_petal.(this.sensorLabel{j});
                fiducial_matrix=cell2mat(fiducials);
                if(this.petalSide==1)
                    fiducial_matrix(2,:)=fiducial_matrix(2,:)*(-1);
                end
                for k=1:2
                    [~,idx]=min(fiducial_matrix(1,:));
                    topFiducials(:,k)=fiducial_matrix(:,idx);
                    fiducial_matrix(:,idx)=[];
                end
                %origin fiducials
                [~,minYfiducialIdx]=min(topFiducials(2,:));
                [~,maxYfiducialIdx]=max(topFiducials(2,:));
                if this.petalSide==0
                    fiducialOrigin=topFiducials(:,minYfiducialIdx);
                    fiducialRight=topFiducials(:,maxYfiducialIdx);
                else
                    fiducialOrigin=topFiducials(:,maxYfiducialIdx);
                    fiducialRight=topFiducials(:,minYfiducialIdx);
                end
                %translation matrix
                if (this.petalSide==0)
                this.transMat_P2S.(this.sensorLabel{j}).translate(-fiducialOrigin);
                else
                this.transMat_P2S.(this.sensorLabel{j}).translateMirrorY(-fiducialOrigin);    
                end
                
                %rotation matrix
                vectorFid=[fiducialRight(1)-fiducialOrigin(1),fiducialRight(2)-fiducialOrigin(2)];
                angleFid=atan2(vectorFid(2),vectorFid(1));
                if this.petalSide==0
                    angleFid=2*pi-angleFid;
                    this.anglePetal2Sensor{j}=angleFid*180/pi;
                    this.transMat_P2S.(this.sensorLabel{j}).rotate(angleFid);
                else
                    angleFid=2*pi+angleFid;
                    this.anglePetal2Sensor{j}=angleFid*180/pi;
                    this.transMat_P2S.(this.sensorLabel{j}).rotate(angleFid);
                end
                
                % getting Sensor to petal transformation matrix
                this.transMat_S2P.(this.sensorLabel{j})=transform2D();
                this.transMat_S2P.(this.sensorLabel{j}).M = inv(this.transMat_P2S.(this.sensorLabel{j}).M);
            end
        end
        
        
        function GantrySensorTransMatrix(this)
            % this method calculate the transformation matrix from Gantry to Sensors and the oposites
            
            n=length(this.sensorLabel);
            for i=1:n
                %definition transformation matrix
                this.transMat_G2S.(this.sensorLabel{i})=transform2D();
                this.transMat_S2G.(this.sensorLabel{i})=transform2D();
                
                %multiply per Gantry to Petal matrix
                this.transMat_G2S.(this.sensorLabel{i}).multiply(this.transMat_P2S.(this.sensorLabel{i}));
                
                %multiply per petal to sensor matrix
                this.transMat_G2S.(this.sensorLabel{i}).multiply(this.transMat_G2P);
                
                %calculatin sensor to Gantry transformation matrix
                this.transMat_S2G.(this.sensorLabel{i}).M=inv(this.transMat_G2S.(this.sensorLabel{i}).M);
            end
            
        end
        
        function readingFiducials(this)
            %this function reads the Fcoordinates file and save the fiducials corrdinates in Petal system into container properties
            addpath ('Petal Coordinate System');
            Fcoordinates
            [n,m]=size(Fmark);
            for i=1:n
                for j=1:m-1
                    this.fiducials_petal.(Fmark{i,end}){j}=[Fmark{i,j}(1);Fmark{i,j}(2);1];
                end
                this.sensorLabel{i}=Fmark{i,end};
            end
        end
        
        function fiducialsInGantry(this)
            %this method calculate the fiducial coordinates into Gantry system
            n=length(this.sensorLabel);
            for i=1:n
                fiducialsInPetal=this.fiducials_petal.(this.sensorLabel{i});
                for j=1:length(fiducialsInPetal)
                  pointPetal=fiducialsInPetal{j};
%                   this.fiducials_gantry.(this.sensorLabel{i}){j}=this.petal_to_gantry(pointPetal);
                  this.fiducials_gantry.(this.sensorLabel{i}){j}=this.transMat_P2G.M*[pointPetal(1);pointPetal(2); 1];
                end
            end
        end
        
        function fiducialsInSensor(this)
            %this method calculate the fiducial coordinates into Sensor system.
            % sensor OX is defined for the 2 lower fiducial of each sensor.
            % Origin is the left sensor looking from the beam.
            
            n=length(this.sensorLabel);
            for i=1:n
                fiducialsPetal=this.fiducials_petal.(this.sensorLabel{i});
                for j=1:length(fiducialsPetal)
                  fiducialCoordinates{j}=this.petal_to_sensor(fiducialsPetal{j},this.sensorLabel{i});
                end
                this.fiducials_sensors.(this.sensorLabel{i})=fiducialCoordinates;
            end
        end
        
        %% auxiliary methods for plotting %%
        
        function plotFiducialsInPetal(this)
            %METHOD1 this method plot the petal fiducials petal Gantry coordinate system
            
            figure(1)
            title('Petal and F fiducials in Petal Coordinate System')
            xlim([-100 700])
            ylim([-200 200])
            %ploting petal fiducials
            hold on
            plot(0,0,'+')
            hold on
            plot(601*cos(12.6*pi/180),-601*sin(12.6*pi/180),'+')
            
            %ploting F ficucials
            n=length(this.sensorLabel);
            for i=1:n
                fiducialsCurrentSensor=this.fiducials_petal.(this.sensorLabel{i});
                for j=1:length(fiducialsCurrentSensor)
                pointPetal=fiducialsCurrentSensor{j};
                hold on
                plot(pointPetal(1),pointPetal(2),'*')
                end
            end
            
        end
        
        function plotFiducialsInGantry(this)
            %METHOD1 this method plot the nominal map of fiducials in gantry coordinates
            
            figure(1)
            title('Petal and F fiducials in Petal Coordinate System')
            xlim([-650 650])
            ylim([-650 650])
            %ploting petal fiducials
            hold on
            plot(this.lower_petalFid(1),this.lower_petalFid(2),'+','Color','k')
            hold on
            plot(this.upper_petalFid(1),this.upper_petalFid(2),'+','Color','k')
            
            %ploting F ficucials
            n=length(this.sensorLabel);
            color=['b','r','g','y','c','m','w','b','r'];
            for i=1:n
                fiducialsCurrentSensor=this.fiducials_gantry.(this.sensorLabel{i});
                for j=1:length(fiducialsCurrentSensor)
                    pointGantry=fiducialsCurrentSensor{j};
                    hold on
                    plot(pointGantry(1),pointGantry(2),'*','Color',color(i))
                end
            end
            hold on
            plot([0 1000 1000 0 0]-500,[0 0 1000 1000 0]-500,'-','Color','k')
        end
        
        function plotSensorInGantry(this, sensorName, color)
            %   This method plot a aproximated sensor (lines that conect the fiducials) in Gantry coordinate system
            %   @SensorName     string with the name of the sensor: [R0 R1 R2 R3S0 R3S1 R4S0 R4S1 R5S0 R5S1]
            if (nargin<3)
               color='r';
            end
            fiducialsCurrentSensor=this.fiducials_gantry.(sensorName);
            F1=fiducialsCurrentSensor{1};
            F2=fiducialsCurrentSensor{2};
            F3=fiducialsCurrentSensor{3};
            F4=fiducialsCurrentSensor{4};
            lowerF=this.lower_petalFid;
            upperF=this.upper_petalFid ;
            X=[F1(1) F2(1) F3(1) F4(1) F1(1)];
            Y=[F1(2) F2(2) F3(2) F4(2) F1(2)];
            figure(1)
            title([sensorName,' in Gantry coordinates'])
            plot([lowerF(1),upperF(1)],[lowerF(2),upperF(2)],'+','Color','k')
            hold on
            plot(X,Y,'-','Color',color)
            xlim([-600 600])
            ylim([-600 600])
            hold on
            plot([0 1000 1000 0 0]-500,[0 0 1000 1000 0]-500,'-','Color','k')
        end
        
        function plotAllSensorsInGantry(this)
         %   This method plot all a aproximated sensors (lines that conect the fiducials) in Gantry coordinate system   
            n=length(this.sensorLabel);
            color=['b','r','g','y','c','m','b','b','r'];
           for i=1:n
           this.plotSensorInGantry(this.sensorLabel{i},color(i));
           end
           title('Petal in Gantry, all sensors')
           hold on
            plot([0 1000 1000 0 0]-500,[0 0 1000 1000 0]-500,'-','Color','k')
        end
    
        %% transformation Methods %%
        
        function pos = gantry_to_petal(this, P)
            % Moves from gantry coordinate to petal coordinates
            % @param P        2 D Vector to be transformated
            pos=this.transMat_G2P.M*[P(1);P(2); 1];
        end
        
        function pos = petal_to_gantry(this, P)
            % Moves from petal coordinate to gantry coordinates
            % @param P        2 D Vector to be transformated
            pos=this.transMat_P2G.M*[P(1);P(2); 1];
        end
        
        function pos = petal_to_sensor(this, P, sensorName)
            % Moves from petal coordinate to sensor coordinates
            % @param P        2 D Vector to be transformated
            % @SensorName     string with the name of the sensor: [R0 R1 R2 R3S0 R3S1 R4S0 R4S1 R5S0 R5S1]
            pos=this.transMat_P2S.(sensorName).M*[P(1);P(2); 1];
        end
        
        function pos = sensor_to_petal(this, P, sensorName)
            % Moves from sensor coordinate to petal coordinates
            % @param P        2 D Vector to be transformated
            % @SensorName     string with the name of the sensor: [R0 R1 R2 R3S0 R3S1 R4S0 R4S1 R5S0 R5S1]
            pos=this.transMat_S2P.(sensorName).M*[P(1);P(2); 1];
        end
        
        function pos = gantry_to_sensor(this, P, sensorName)
            % Moves from gantry coordinate to sensor coordinates
            % @param P        2 D Vector to be transformated
            % @SensorName     string with the name of the sensor: [R0 R1 R2 R3S0 R3S1 R4S0 R4S1 R5S0 R5S1]
          pos=this.transMat_G2S.(sensorName).M*[P(1);P(2); 1];
        end
        
        function pos = sensor_to_gantry(this, P, sensorName)
            % Moves from sensor coordinate to gantry coordinates
            % @param P        2 D Vector to be transformated
            % @SensorName     string with the name of the sensor: [R0 R1 R2 R3S0 R3S1 R4S0 R4S1 R5S0 R5S1]
            pos=this.transMat_S2G.(sensorName).M*[P(1);P(2); 1];
        end
        
    end
    
end
