classdef FOCUS
    %FOCUS focusing tools
    
    
    properties (Access=private)
        
        %AutoFocus
        maxIter=10;
        FocusRange=0.2;
        velocity=2;
        threshold=0.02;
        splits=5;   
        RoiSize=500;
        ReadyToFocus=0;
        FocusType='BREN';
        zAxis=4;
        gantry;
        cam;  
    end
    
    methods
        
        function this = FOCUS(gantry_obj,camera_obj)
            %FOCUS Construct an instance of this class
            % Inputs 1: STAGES object. Object has to be connected and the axis enabled
            % Input 2: CAMERA obj. Camera has to be connected.
            this.gantry=gantry_obj;
            this.cam=camera_obj;
            if (this.gantry.IsConnected==1) && (this.cam.IsConnected==1)
                this.ReadyToFocus=1;
                disp('System is ready to perform autofocus')
                warningID='imaq:getdata:infFramesPerTrigger';
                warning('off',warningID);
            else
                if (gantry.IsConnected==0)
                    disp('Autofocus can not be performed: gantry is not connected')
                end
                if (cam.IsConnected==0)
                    disp('Autofocus can not be performed: Camera is not connected')
                end
            end
        end
        
        
        
        function info=AutoFocus(this)
            %This function launch the autofocus procedure.
            %   info=AutoFocus(this)
            %Where
            %   this,  instance of the class
            %   info,   struct array with the focus information
            
            % Setting basic parameters for the focus loop %
            total=tic;
            
            %starting adquisition
            this.cam.startAdquisition;
            
            %setting image properties
            this.cam.ResetAdquisitionBuffer;
            [data,~,~]=this.cam.retrieveDataOneFrame;
            [dimy,dimx]=size(data);
            ImageSize(1)=dimx;
            ImageSize(2)=dimy;
            
            % Setting initial values
            Zini=this.gantry.GetPosition(this.zAxis);
            R=this.FocusRange;
            div=this.splits;
            x0=round(ImageSize(1)/2);
            y0=round(ImageSize(2)/2);
            RoiWidth=this.RoiSize;
            RoiHeight=this.RoiSize;
            Z0=Zini;
            image=cell(1,20);
            
            % Setting counters and empty vector for the general loop%
            zCont=1;
            fCont=1;
            Fopt=zeros(1,100);
            ImCont=1;
            iteration=1;
            
            while iteration<20
                % Setting counters and empty vector for the sampling loop%
                P0=Z0-R/2;
                Pn=Z0+R/2;
                z=P0;
                FocusValue=zeros(1,20);
                Z=zeros(1,20);
                delta=R/div;
                samples=1;
                while (samples<=div+1)
                    % moving gantry at new position %
                    this.gantry.MoveTo(this.zAxis,z,this.velocity);
                    this.gantry.WaitForMotion(this.zAxis,-1);
                    Z(zCont)=this.gantry.GetPosition(this.zAxis);
                    % taking picture %
                    this.cam.ResetAdquisitionBuffer;
                    [data,~,~]=this.cam.retrieveDataOneFrame;
                    image{ImCont}=data;
                    % Asking focus parameter %
                    FocusValue(fCont)=this.fmeasure(image{ImCont},this.FocusType,[x0,y0,RoiWidth,RoiHeight]);
                    % Updating counters %
                    zCont=zCont+1;
                    ImCont=ImCont+1;
                    fCont=fCont+1;
                    z=z+delta;
                    samples=samples+1;
                end
                %  Finding local optimal %
                Z(Z==0)=[];
                FocusValue(FocusValue==0)=[];
                focusAll{iteration}=FocusValue;
                zAll{iteration}=Z;
                Fopt(iteration)=max(FocusValue);
                index=find(FocusValue==max(FocusValue));
                Zopt(iteration)=Z(index);
                if iteration>1 && abs(Zopt(iteration)-Zopt(iteration-1))<this.threshold
                    break
                end
                div=3;
                R=max([abs(Zopt(iteration)-P0),abs(Zopt(iteration)-Pn)]);
                Z0=Zopt(iteration);
                iteration=iteration+1;
            end
            
            this.cam.stopAdquisition;
            
            if (iteration<10)
                % Fitting results to a quadratic polynomial (last 4 points) %
                zAll=cell2mat(zAll);
                FocusAll=cell2mat(focusAll);
                X=Z;
                Y=FocusValue;
                p=polyfit(X,Y,2);
                Zfinal=-(p(2)/(2*p(1)));
                if (Zfinal>=Zini-this.FocusRange/2 || Zfinal<=Zini+this.FocusRange/2)
                    % Moving to Zfinal  %
                    this.gantry.MoveTo(this.zAxis,Zfinal,this.velocity);
                    this.gantry.WaitForMotion(this.zAxis,-1);
                else
                    disp('Optimal focus point is out of range');
                end
            else
                disp('Maximum iterations number reached');
                Zfinal=0;
                FocusAll=0;
                zAll=0;
                TotalTime=0;
               
            end
            
            TotalTime=toc(total);
            disp('Optimal focus point reached');
            
            % returning info %
            image=image(~cellfun('isempty',image));
            info.Zoptim=Zfinal;
            info.Foptim=max(FocusAll);
            info.Zvalues=zAll;
            info.Fvalues=FocusAll;
            info.time=TotalTime;
            info.Images=image;
        end
        
        
        function info=AutoFocusNew(this)
            %This function launch the autofocus procedure (optimized script).
            %
            %   info=AutoFocus(this)
            %Where
            %   this,  instance of the class
            %   info,   struct array with the focus information
            
            % Setting basic parameters for the focus loop %
            
            %starting clock to log the total execution time
            total=tic;
            
            maxIterations=10;
            samplesPerIteration=5;
            range=0.4;
            thresh=0.005;
            
            % Setting counters to 1 and trigger to 0
            loopsCounter=1;
            focusValidFlag=0;
            
            % logging initial z and setting useful window
            Zinitial=this.gantry.GetPosition(this.zAxis);
            usefulWindow=[Zinitial-range/2,Zinitial+range/2];
            
            % setting initial properties
            Z0=Zinitial;
            scaling=1/3;
            deltaWindow=range/2;
            
            % Starting camera adquisition
            this.cam.startAdquisition;
            
            % getting 1 image and setting matrix size
            this.cam.ResetAdquisitionBuffer;
            [data,~,~]=this.cam.retrieveDataOneFrame;
            [resy,resx]=size(data);
            
            % Starting measurement loops
            localWindow=[Z0-deltaWindow,Z0+deltaWindow];
            
            while (focusValidFlag==0) && (loopsCounter<maxIterations)
                
                deltaPerSample=(localWindow(2)-localWindow(1))/(samplesPerIteration-1);
                image=zeros(resy,resx,samplesPerIteration);
                
                %going to the starting point
                this.gantry.MoveTo(this.zAxis,localWindow(1),this.velocity);
                this.gantry.WaitForMotion(this.zAxis,-1);
                
                for i=1:samplesPerIteration
                    % logging current position
                    Z(loopsCounter,i)=this.gantry.GetPosition(this.zAxis);
                    
                    % reset camera buffer and taking 1 frame
                    this.cam.ResetAdquisitionBuffer;
                    [data,~,~]=this.cam.retrieveDataOneFrame;
                    image(:,:,i)=data;
                    disp(['loop: ',int2str(loopsCounter),' image', int2str(i),' taken']);
                    
                    % moving to next point
                    this.gantry.MoveBy(this.zAxis,deltaPerSample,this.velocity);
                    this.gantry.WaitForMotion(this.zAxis,-1);
                end
                
                % Processing images
                for i=1:samplesPerIteration
                    F(loopsCounter,i)=this.fmeasure(mat2gray(image(:,:,i)),this.FocusType,[0,0,resx,resy]);
                end
                
                % fitting
                p=polyfit(Z(loopsCounter,:),F(loopsCounter,:),6);
                Zeval=localWindow(1):0.0001:localWindow(2);
                Yfit=polyval(p,Zeval);
                ZMaxFit=Zeval(find(Yfit==max(Yfit)));
                ZMax(loopsCounter)=mean(ZMaxFit);
                
                % checking if max value is leaving the useful window
                if (ZMax(loopsCounter) > usefulWindow(2)) || ZMax(loopsCounter) < usefulWindow(1)
                    focusValidFlag=1;
                else
                    
                % checking if threshold condition is met
                    if loopsCounter>1
                        if abs(ZMax(loopsCounter)-Z0)<thresh
                            focusValidFlag=1;
                        end
                    end
                end
                Z0=ZMax(loopsCounter);
                loopsCounter=loopsCounter+1;
                deltaWindow=abs(localWindow(2)-localWindow(1))*scaling/2;
                localWindow=[Z0-deltaWindow,Z0+deltaWindow]; 
            end
            
            % stopping images adquisition
            this.cam.stopAdquisition;
            
            % setting the optimal value found
            Zoptimo=Z0;
            TotalTime=toc(total);
            % solving depending if the optimal value is within or out of the useful window
            if (Zoptimo > usefulWindow(2)) || Zoptimo < usefulWindow(1)
                disp('Focus out of range')
                info.Zoptim=Zoptimo;
                info.Zinit=Zinitial;
                info.Foptim=polyval(p,Zoptimo);
                info.Zvalues=Z;
                info.Fvalues=F;
                info.time=TotalTime;
                info.focusWindow=usefulWindow;
            else
                disp('Optimal focus point reached');
                info.Zoptim=Zoptimo;
                info.Zinit=Zinitial;
                info.Foptim=polyval(p,Zoptimo);
                info.Zvalues=Z;
                info.Fvalues=F;
                info.time=TotalTime;
                info.focusWindow=usefulWindow;
                info
                % moving to the optimal value
                this.gantry.MoveTo(this.zAxis,Zoptimo,this.velocity);
                this.gantry.WaitForMotion(this.zAxis,-1);
                
            end
        end
        
        
        function FM = fmeasure(this,Image, Measure, ROI)
            %This function measures the relative degree of focus of
            %an image. It may be invoked as:
            %
            %   FM = fmeasure(IMAGE, METHOD, ROI)
            %
            %Where
            %   IMAGE,  is a grayscale image and FM is the computed
            %           focus value.
            %   METHOD, is the focus measure algorithm as a string.
            %           see 'operators.txt' for a list of focus
            %           measure methods.
            %   ROI,    Image ROI as a rectangle [xo yo width heigth].
            %           if an empty argument is passed, the whole
            %           image is processed.
            %
            if nargin>2 && ~isempty(ROI)
                Image = imcrop(Image, ROI);
            end
            
            WSize = 15; % Size of local window (only some operators)
            
            switch upper(Measure)
                case 'ACMO' % Absolute Central Moment (Shirvaikar2004)
                    if ~isinteger(Image), Image = im2uint8(Image);
                    end
                    FM = AcMomentum(Image);
                    
                case 'BREN' % Brenner's (Santos97)
                    [M, N] = size(Image);
                    DH = zeros(M, N);
                    DV = zeros(M, N);
                    DV(1:M-2,:) = Image(3:end,:)-Image(1:end-2,:);
                    DH(:,1:N-2) = Image(:,3:end)-Image(:,1:end-2);
                    FM = max(DH, DV);
                    FM = FM.^2;
                    FM = mean2(FM);
                    
                case 'CONT' % Image contrast (Nanda2001)
                    ImContrast = @(x) sum(abs(x(:)-x(5)));
                    FM = nlfilter(Image, [3 3], ImContrast);
                    FM = mean2(FM);
                    
                case 'CURV' % Image Curvature (Helmli2001)
                    if ~isinteger(Image), Image = im2uint8(Image);
                    end
                    M1 = [-1 0 1;-1 0 1;-1 0 1];
                    M2 = [1 0 1;1 0 1;1 0 1];
                    P0 = imfilter(Image, M1, 'replicate', 'conv')/6;
                    P1 = imfilter(Image, M1', 'replicate', 'conv')/6;
                    P2 = 3*imfilter(Image, M2, 'replicate', 'conv')/10 ...
                        -imfilter(Image, M2', 'replicate', 'conv')/5;
                    P3 = -imfilter(Image, M2, 'replicate', 'conv')/5 ...
                        +3*imfilter(Image, M2, 'replicate', 'conv')/10;
                    FM = abs(P0) + abs(P1) + abs(P2) + abs(P3);
                    FM = mean2(FM);
                    
                case 'DCTE' % DCT energy ratio (Shen2006)
                    FM = nlfilter(Image, [8 8], @DctRatio);
                    FM = mean2(FM);
                    
                case 'DCTR' % DCT reduced energy ratio (Lee2009)
                    FM = nlfilter(Image, [8 8], @ReRatio);
                    FM = mean2(FM);
                    
                case 'GDER' % Gaussian derivative (Geusebroek2000)
                    N = floor(WSize/2);
                    sig = N/2.5;
                    [x,y] = meshgrid(-N:N, -N:N);
                    G = exp(-(x.^2+y.^2)/(2*sig^2))/(2*pi*sig);
                    Gx = -x.*G/(sig^2);
                    Gx = Gx/sum(abs(Gx(:)));
                    Gy = -y.*G/(sig^2);
                    Gy = Gy/sum(abs(Gy(:)));
                    Rx = imfilter(double(Image), Gx, 'conv', 'replicate');
                    Ry = imfilter(double(Image), Gy, 'conv', 'replicate');
                    FM = Rx.^2+Ry.^2;
                    FM = mean2(FM);
                    
                case 'GLVA' % Graylevel variance (Krotkov86)
                    FM = std2(Image);
                    
                case 'GLLV' %Graylevel local variance (Pech2000)
                    LVar = stdfilt(Image, ones(WSize,WSize)).^2;
                    FM = std2(LVar)^2;
                    
                case 'GLVN' % Normalized GLV (Santos97)
                    FM = std2(Image)^2/mean2(Image);
                    
                case 'GRAE' % Energy of gradient (Subbarao92a)
                    Ix = Image;
                    Iy = Image;
                    Iy(1:end-1,:) = diff(Image, 1, 1);
                    Ix(:,1:end-1) = diff(Image, 1, 2);
                    FM = Ix.^2 + Iy.^2;
                    FM = mean2(FM);
                    
                case 'GRAT' % Thresholded gradient (Snatos97)
                    Th = 0; %Threshold
                    Ix = Image;
                    Iy = Image;
                    Iy(1:end-1,:) = diff(Image, 1, 1);
                    Ix(:,1:end-1) = diff(Image, 1, 2);
                    FM = max(abs(Ix), abs(Iy));
                    FM(FM<Th)=0;
                    FM = sum(FM(:))/sum(sum(FM~=0));
                    
                case 'GRAS' % Squared gradient (Eskicioglu95)
                    Ix = diff(Image, 1, 2);
                    FM = Ix.^2;
                    FM = mean2(FM);
                    
                case 'HELM' %Helmli's mean method (Helmli2001)
                    MEANF = fspecial('average',[WSize WSize]);
                    U = imfilter(Image, MEANF, 'replicate');
                    R1 = U./Image;
                    R1(Image==0)=1;
                    index = (U>Image);
                    FM = 1./R1;
                    FM(index) = R1(index);
                    FM = mean2(FM);
                    
                case 'HISE' % Histogram entropy (Krotkov86)
                    FM = entropy(Image);
                    
                case 'HISR' % Histogram range (Firestone91)
                    FM = max(Image(:))-min(Image(:));
                    
                    
                case 'LAPE' % Energy of laplacian (Subbarao92a)
                    LAP = fspecial('laplacian');
                    FM = imfilter(Image, LAP, 'replicate', 'conv');
                    FM = mean2(FM.^2);
                    
                case 'LAPM' % Modified Laplacian (Nayar89)
                    M = [-1 2 -1];
                    Lx = imfilter(Image, M, 'replicate', 'conv');
                    Ly = imfilter(Image, M', 'replicate', 'conv');
                    FM = abs(Lx) + abs(Ly);
                    FM = mean2(FM);
                    
                case 'LAPV' % Variance of laplacian (Pech2000)
                    LAP = fspecial('laplacian');
                    ILAP = imfilter(Image, LAP, 'replicate', 'conv');
                    FM = std2(ILAP)^2;
                    
                case 'LAPD' % Diagonal laplacian (Thelen2009)
                    M1 = [-1 2 -1];
                    M2 = [0 0 -1;0 2 0;-1 0 0]/sqrt(2);
                    M3 = [-1 0 0;0 2 0;0 0 -1]/sqrt(2);
                    F1 = imfilter(Image, M1, 'replicate', 'conv');
                    F2 = imfilter(Image, M2, 'replicate', 'conv');
                    F3 = imfilter(Image, M3, 'replicate', 'conv');
                    F4 = imfilter(Image, M1', 'replicate', 'conv');
                    FM = abs(F1) + abs(F2) + abs(F3) + abs(F4);
                    FM = mean2(FM);
                    
                case 'SFIL' %Steerable filters (Minhas2009)
                    % Angles = [0 45 90 135 180 225 270 315];
                    N = floor(WSize/2);
                    sig = N/2.5;
                    [x,y] = meshgrid(-N:N, -N:N);
                    G = exp(-(x.^2+y.^2)/(2*sig^2))/(2*pi*sig);
                    Gx = -x.*G/(sig^2);Gx = Gx/sum(Gx(:));
                    Gy = -y.*G/(sig^2);Gy = Gy/sum(Gy(:));
                    R(:,:,1) = imfilter(double(Image), Gx, 'conv', 'replicate');
                    R(:,:,2) = imfilter(double(Image), Gy, 'conv', 'replicate');
                    R(:,:,3) = cosd(45)*R(:,:,1)+sind(45)*R(:,:,2);
                    R(:,:,4) = cosd(135)*R(:,:,1)+sind(135)*R(:,:,2);
                    R(:,:,5) = cosd(180)*R(:,:,1)+sind(180)*R(:,:,2);
                    R(:,:,6) = cosd(225)*R(:,:,1)+sind(225)*R(:,:,2);
                    R(:,:,7) = cosd(270)*R(:,:,1)+sind(270)*R(:,:,2);
                    R(:,:,8) = cosd(315)*R(:,:,1)+sind(315)*R(:,:,2);
                    FM = max(R,[],3);
                    FM = mean2(FM);
                    
                case 'SFRQ' % Spatial frequency (Eskicioglu95)
                    Ix = Image;
                    Iy = Image;
                    Ix(:,1:end-1) = diff(Image, 1, 2);
                    Iy(1:end-1,:) = diff(Image, 1, 1);
                    FM = mean2(sqrt(double(Iy.^2+Ix.^2)));
                    
                case 'TENG'% Tenengrad (Krotkov86)
                    Sx = fspecial('sobel');
                    Gx = imfilter(double(Image), Sx, 'replicate', 'conv');
                    Gy = imfilter(double(Image), Sx', 'replicate', 'conv');
                    FM = Gx.^2 + Gy.^2;
                    FM = mean2(FM);
                    
                case 'TENV' % Tenengrad variance (Pech2000)
                    Sx = fspecial('sobel');
                    Gx = imfilter(double(Image), Sx, 'replicate', 'conv');
                    Gy = imfilter(double(Image), Sx', 'replicate', 'conv');
                    G = Gx.^2 + Gy.^2;
                    FM = std2(G)^2;
                    
                case 'VOLA' % Vollath's correlation (Santos97)
                    Image = double(Image);
                    I1 = Image; I1(1:end-1,:) = Image(2:end,:);
                    I2 = Image; I2(1:end-2,:) = Image(3:end,:);
                    Image = Image.*(I1-I2);
                    FM = mean2(Image);
                    
                case 'WAVS' %Sum of Wavelet coeffs (Yang2003)
                    [C,S] = wavedec2(Image, 1, 'db6');
                    H = wrcoef2('h', C, S, 'db6', 1);
                    V = wrcoef2('v', C, S, 'db6', 1);
                    D = wrcoef2('d', C, S, 'db6', 1);
                    FM = abs(H) + abs(V) + abs(D);
                    FM = mean2(FM);
                    
                case 'WAVV' %Variance of  Wav...(Yang2003)
                    [C,S] = wavedec2(Image, 1, 'db6');
                    H = abs(wrcoef2('h', C, S, 'db6', 1));
                    V = abs(wrcoef2('v', C, S, 'db6', 1));
                    D = abs(wrcoef2('d', C, S, 'db6', 1));
                    FM = std2(H)^2+std2(V)+std2(D);
                    
                case 'WAVR'
                    [C,S] = wavedec2(Image, 3, 'db6');
                    H = abs(wrcoef2('h', C, S, 'db6', 1));
                    V = abs(wrcoef2('v', C, S, 'db6', 1));
                    D = abs(wrcoef2('d', C, S, 'db6', 1));
                    A1 = abs(wrcoef2('a', C, S, 'db6', 1));
                    A2 = abs(wrcoef2('a', C, S, 'db6', 2));
                    A3 = abs(wrcoef2('a', C, S, 'db6', 3));
                    A = A1 + A2 + A3;
                    WH = H.^2 + V.^2 + D.^2;
                    WH = mean2(WH);
                    WL = mean2(A);
                    FM = WH/WL;
                otherwise
                    error('Unknown measure %s',upper(Measure))
            end
        end
        %************************************************************************
        function fm = AcMomentum(Image)
            [M, N] = size(Image);
            Hist = imhist(Image)/(M*N);
            Hist = abs((0:255)-mean2(Image))'.*Hist;
            fm = sum(Hist);
        end
        
        %******************************************************************
        function fm = DctRatio(M)
            MT = dct2(M).^2;
            fm = (sum(MT(:))-MT(1,1))/MT(1,1);
        end
        
        %************************************************************************
        function fm = ReRatio(M)
            M = dct2(M);
            fm = (M(1,2)^2+M(1,3)^2+M(2,1)^2+M(2,2)^2+M(3,1)^2)/(M(1,1)^2);
        end
        %******************************************************************
        
        
        
    end
end
