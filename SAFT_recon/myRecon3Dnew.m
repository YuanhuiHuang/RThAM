function R = myRecon3Dnew(SS,fileParams, reconParams, transducerParams)
    
    %% Show off :) and start diary
    if exist([fileParams.main 'Reconstruction_Log' fileParams.dataName '.txt'],'file')
        delete([fileParams.main 'Reconstruction_Log' fileParams.dataName '.txt'])
    end
    diary([fileParams.main 'Reconstruction_Log' fileParams.dataName '.txt']);	% Write screen output to log file
    
    fprintf('      RRRRRRRRR  SSSSSSSSS  OOOOOOOOO  MMMM    MMMM  333333333  DDDDDDDD  \n');
    fprintf('     RR     RR  SS         OO     OO  MM MM  MM MM         33  DD     DD  \n');
    fprintf('    RR     RR  SS         OO     OO  MM  MMMM  MM         33  DD      DD  \n');
    fprintf('   RRRRRRRRR  SSSSSSSSS  OO     OO  MM   MM   MM  333333333  DD      DD   \n');
    fprintf('  RR RR             SS  OO     OO  MM        MM         33  DD      DD    \n');
    fprintf(' RR   RR           SS  OO     OO  MM        MM         33  DD     DD      \n');
    fprintf('RR     RR  SSSSSSSSS  OOOOOOOOO  MM        MM  333333333  DDDDDDDD        \n');    
    fprintf('\n*************************************************************************');
    fprintf('\n*                        3D GPU Reconstruction                          *');
    fprintf('\n*                        %s                          *', datestr(now, 'dd-mmm-yyyy  /  HH:MM'));
    fprintf('\n*************************************************************************');
    
    fprintf('\n\n--------------------- Start Signal Conditioning ------------------------\n\n');
    
    
    %% Load data file
    fprintf('++ Loading file [%s]', fileParams.dataName);
    tStart = tic;                                                          % Start timer
    load([fileParams.data fileParams.dataName '.mat'], 'dx', 'dy', 'dz', 'trigDelay', 'xLim', 'yLim', 'positionXY');                           % Load data file for reconstruction
    S = SS;
    MaxConserve=max(abs(S(:)));
    clear SS;
    fprintf(': %.2f seconds\n\n', toc(tStart)); tPart = tic;
    tPart = tic;
    
    
    %% Reconstruction parameters
    genPos   = reconParams.genPos;                                         % generate transducer positions 0) off, 1) on
    SpatFilt = reconParams.SpatFilt;                                       % 0: no filter; 1: Chebychev filter; 2: FFT filter
    MethodBP = reconParams.MethodBP;                                       % BP mode: 1) delay & sum, 2) filtered BP, 3) *t 4), full
    f_BP     = reconParams.f_BP;                                           % Bandpath of filter [Hz]
    BPFilter = reconParams.BPFilter;                                       % BP filtering 1) GPU (FFT), 2) CPU (FFT), 3) CPU (Butterworth)
    FocusRec = reconParams.FocusRec;                                       % Focal region: 0) pointlike, 1) hyperbolic Olympus, 2) hyperbolic Khokhlova
    SF_Model = reconParams.SF_Model;                                       % Sensitivity Field: 0) on/off, 1) frequency dependent weigthing
    cutBound = reconParams.cutBound;                                       % cut away data where the stage is not moving linearly: 1) on, 0) off
    
    v_s      = reconParams.v_s;                                            % Speed of sound [m/s]
    if ~exist('Fs','var')
        Fs       = 500e6;
    end
    if exist('Fs','var')
        dt       = 1/Fs;                                                       % Time per sample (= 2ns @ 500MHz) [s]
    end
    
    relWidth = reconParams.relWidth;                                        % What is this?
    relHeight = reconParams.relHeight;                                      % What is this?
    BlockSize = reconParams.BLOCK_SIZE;
    DS = reconParams.GRID_DS;
    DZ = reconParams.GRID_DZ;
    
    
    %% Transducer Parameters:
    t_foc   = transducerParams.t_foc;                                      % Delay Time (F/v_s + t_delay) [s]
%     t_delay   = transducerParams.t_delay;                                  % Delay Time (F/v_s + t_delay) [s]
    F_TD    = transducerParams.F_TD;                                       % Focal length of TD [m]
    D_TD    = transducerParams.D_TD;                                       % Diameter of TD active element [m]
    f_c     = transducerParams.f_c;                                        % Central frequency [Hz]
%     t_foc   = F_TD/v_s + t_delay;                                          % Delay Time (F/v_s + t_delay) [s]
    
    alpha = atan(D_TD/(2*F_TD));                                           % Half-Angle of view [rad]
   
    % Model for focus region (hyperbolic model)
    switch FocusRec        
        case 0
            a = 0.1;                                                       % Pointlike Focal zone[um]            
        otherwise            
            switch FocusRec
                case 1
                    D_foc = 1.02*v_s/mean(f_BP)*F_TD/D_TD*1e6;             % Width of focal zone (Olympus) [um] % In Endnote: Olympus, 2006, Ultrasnoic Transducers Technical Notes
                case 2
                    D_foc = 0.5*v_s/(mean(f_BP)*sin(alpha))*1e6;           % Width of focal zone [um]
            end            
            a = D_foc/2;
    end
    
    f_hyp = a/cos(pi/2-alpha);
    b = sqrt(f_hyp^2 - a^2);                                               % a and b are hyperbel parameters
    
    
    %% Time definition
    Ntime = size(S,2);                                                     % number of time samples
    t_0 = 0:dt:(Ntime-1)*dt;                                               % define time vector
    if exist('trigDelay', 'var')
        t_0 = t_0 + trigDelay*dt;                                          % Add trigger delay offset to the time vector
    end
    t_sp = (t_0 - t_foc) * v_s * 1e6;                                      % Time transformed to space with respect to the focus point by speed of sound [um]
    
    
    %% Reconstruction grid    
    % !!! Note x and y are switched in the acquisition code !!!
    % change to: y-axis == fast-scanning axis
    if reconParams.XYswitch
        intermediate = xLim;
        xLim = yLim;
        yLim = intermediate;
        intermediate2 = dx;
        dx = dy;
        dy = intermediate2;
        positionXY = positionXY(:,2:-1:1);
    end
    
    % Define reconstructed ROI
    xBound(1) = (xLim(1) + diff(xLim) * relWidth(1)/100)*1e3;              % lower xLim of recon grid [um]
    xBound(2) = (xLim(1) + diff(xLim) * relWidth(2)/100)*1e3;              % upper xLim of recon grid [um]
    yBound(1) = (yLim(1) + diff(yLim) * relWidth(1)/100)*1e3;              % lower xLim of recon grid [um]
    yBound(2) = (yLim(1) + diff(yLim) * relWidth(2)/100)*1e3;              % upper xLim of recon grid [um]        
    zBound(1) = min(t_sp) + (max(t_sp)-min(t_sp)) * relHeight(1)/100;      % lower zLim of recon grid [um]
    zBound(2) = min(t_sp) + (max(t_sp)-min(t_sp)) * relHeight(2)/100;      % upper zLim of recon grid [um]
    
    % Fit lateral recon grid to block size of 3D recon
    NBx = round(diff(xBound)/(BlockSize*DS));
    NBx = max(NBx,1);
    xGrid(1) = mean(xBound) - (NBx/2*BlockSize-1/2)*DS;
    xGrid(2) = mean(xBound) + (NBx/2*BlockSize-1/2)*DS;        
    NBy = round(diff(yBound)/(BlockSize*DS));
    yGrid(1) = mean(yBound) - (NBy/2*BlockSize-1/2)*DS;
    yGrid(2) = mean(yBound) + (NBy/2*BlockSize-1/2)*DS;
    
    % Along the depth dimension the reconstruction grid is split up due to
    % memory and time restraints of the GPU. The slab thickness depends on DZ
    LimSlab = 1e12*(1.5e3)^2*DZ/3;
    if (diff(xBound)/dx*diff(yBound)/dy*(zBound(2))^2 < LimSlab) 
        Nslab = 3;
    else
        Nslab = 1;
    end
    % Fit vertical recon grid to block size of 3D recon
    NBz = round(diff(zBound)/(BlockSize*DZ*Nslab));
    zGrid(1) = round(mean(zBound) - (NBz/2*BlockSize*Nslab-1/2)*DZ);
    zGrid(2) = zGrid(1) + (NBz*BlockSize*Nslab-1)*DZ;
  
    % The whole z-range is split up into zSlices slices covering a slab thickness of zRange
    zRange = DZ * BlockSize* Nslab;
    zSlices = (diff(zGrid)+DZ)/zRange;
    
    
    %% filter signal matrix
    % filter out vertical stripes in the b-scan by removing low frequency 
    % components of the central slice (along y) in the FFT2 image
    S = single(S);
    switch SpatFilt 
        case 1
            fprintf('++ Spatial filtering (FFT filter):');
            S = filtS(S,dt,dx,3);
%             NaScan = 40000;                                                % define the maximum number of measurements that should be filtered at once (to prevent excessive use of memory)
%             nSplit = ceil(size(S,1)/NaScan);                               % dataset is split up into nSpilt smaller packages
%             filtPat = ones(NaScan,size(S,2),'single');
%             if Fs > 850e9                                                  % the larger the filter width the broader are the stripes that are removed
%                 FiltWidth = 75;                                            % Be aware, that large (low-frequency) structures are biased if the filter is too broad
%             elseif Fs < 550e6
%                 FiltWidth = 37.5;
%             else
%                 FiltWidth = 50;
%             end
% 
%             % note that without ifftshift the low frequency components
%             % are located at the edges. the central slice is the first
%             % line which is very convenient
%             filtPat(1,:) = max(exp(-Ntime.^2./(2*(length(Ntime)/FiltWidth)^2)),...
%                 exp(-(Ntime-length(Ntime)).^2./(2*(length(Ntime)/FiltWidth)^2)));
% 
%             % run through the nSplit packages and filter the data
%             for iSplit = 1:nSplit
%                 if iSplit == nSplit                                        % filter size has to be redefined for the last package                    
%                     nRest = size(S(max((nSplit-1)*NaScan,1):end,:));
%                     filtPat = ones(nRest,'single');
%                     filtPat(1,:) = exp(-Ntime.^2./(2*(length(Ntime)/FiltWidth)^2))...
%                         + exp(-(Ntime-length(Ntime)).^2./(2*(length(Ntime)/FiltWidth)^2));
%                     fftImage = fft2(S(max((nSplit-1)*NaScan,1):end,:)).*filtPat;
%                     ifftImage = ifft2(fftImage);
%                     S(max((nSplit-1)*NaScan,1):end,:) = real(ifftImage);
%                 else
%                     fftImage = fft2(S((iSplit-1)*NaScan+[1:NaScan],:)).*filtPat;
%                     ifftImage = ifft2(fftImage);
%                     S((iSplit-1)*NaScan+[1:NaScan],:) = real(ifftImage);
%                 end
%             end
% 
%             % clear memory and stop time
%             clear filtPat fftImage ifftImage
            fprintf(' %.2f seconds \n\n', toc(tPart)); tPart = tic;
    end
            
        
    %% Bandpass-Filter data and choose reconstruction method:

    % Design bandpass filter
    f = linspace(-Fs/2, Fs/2, Ntime)';                                     % Freqeuncies of FFT data
    switch BPFilter                                                        % Frequency-Window-Filtering on the CPU
        case 0 
            fprintf('++ No bandpass filter\n');
        case 1                                                             % exponential filter (Murad)
            fprintf('++ Bandpass filtering - Murad Exp');
            filtOrder = 4;
            filt =     (exp(-(f/f_BP(2)).^filtOrder)) ...
                      .* (1-(exp(-(f/f_BP(1)).^filtOrder)));             

        case 2                                                             % Butterworth filter (Mathias)
            fprintf('++ Bandpass filtering - Butterworth Order 2');                
            filtOrder = 2;
            [bb,aa] = butter(filtOrder, f_BP/(Fs/2));
            [h,w] = freqz(bb, aa, length(f), 'whole');
            filt  = (fftshift(abs(h), 1)).^2;              
    end

    % Perform bandpass filter
    if BPFilter > 0
        
        S = S';                                                                % flip dimensions: space x t --> t x space
        NRows  = 40000;                                                         % Number of signals to be filtered simultaneously
        NIterations = ceil(size(S,2)/NRows);                                   % Number of iterations necessaty to filter the whole data
        filtArray = repmat(filt, 1, NRows);                                    % replicate filter to right size

        % apodization of time signal (sigmoid function)
        % this is necessary to succesfully bandpass filter the signal
        % the low frequency passive ultrasound signal  will only be filtered
        % properly if it is not cut in the middle of a low freq bump.
        tSig = 1:Ntime;
%         Ap = single(1-(1./(1+exp(-(tSig-0.9*max(tSig))./10))))';               % suppress the last 10% of the time signal of each A-scan
%         Ap = repmat(Ap,[1, size(S,2)]);
%         S = S.*Ap;
%         Ap = single(1-(1./(1+exp(-(tSig-0.9*max(tSig))./10))))';               % suppress the last 10% of the time signal of each A-scan
        Ap = 1;
        S = S.*Ap;
        clear Ap
        
        % Perform bandpass filter for each data package
        for ii = 1:NIterations
            SS = S(:,(ii-1)*NRows+1:min(ii*NRows, size(S,2)));
            SS = fftshift(fft(ifftshift(SS, 1), [], 1), 1);                     % Take fourier transform of the signals (FFT)
            if NIterations == ii
                filtArray = filtArray(:, 1:size(SS, 2));
            end
            SS = real(fftshift(ifft(ifftshift(SS.*filtArray, 1),[],1),1));      % Multiply with f-window and transform back to time domain (iFFT)
            S(:,(ii-1)*NRows+1:min(ii*NRows, size(S,2))) = SS;
        end

        S = S';                                                                % flip dimensions: space t x --> x t space

        % clear unnecessary variables
        clear filtArray SS;
        fprintf(': %.2f seconds \n\n', toc(tPart)); tPart = tic;
    end
    
    
    %% Cut unnecessary part of signal matrix
    % Find upper and lower boundary of time signal
    if zGrid(1) > 0                                                        % lower bound below focus
        zMin = zGrid(1) - 5*DZ;
    else                                                                   % lower bound above focus
        rad = a/b * sqrt( zGrid(1)^2 + b^2 ) + DS;                       % in the 3D recon voxels lying within rad are updated
        zMin = sign(zGrid(1))*sqrt(rad^2+zGrid(1)^2) - 5*DZ;
    end
    if zGrid(2) < 0                                                        % upper bound below focus
        zMax = zGrid(2) + 5*DZ;
    else                                                                   % upper bound above focus
        rad = a/b * sqrt( zGrid(2)^2 + b^2 ) + DS;                       % in the 3D recon voxels lying within rad are updated
        zMax = sign(zGrid(2))*sqrt(rad^2+zGrid(2)^2) + 5*DZ;
    end
    
    % cut the signal to the needed length
    tInd(1) = dsearchn(t_sp',zMin);
    tInd(2) = dsearchn(t_sp',zMax);
    t_sp = t_sp(tInd(1):tInd(2));
    S = S(:,tInd(1):tInd(2));
    Ntime = size(S,2);
    
    
    %% Define and correct transducer positions
    
    % get the number of acquisitions in one line-scan
    if strcmpi(getenv('username'),'murad.omar')
        NxSens = length(xLim(1):dx:xLim(2));
        NySens = size(S,1)/NxSens;
    else
        NySens = length(yLim(1):dy:yLim(2));
        NxSens = length(xLim(1):dx:xLim(2));
    end
    if (NxSens*NySens ~= size(S,1))
        NySens = round(diff(yLim)/dy);
        NxSens = round(diff(xLim)/dx);
        if (NxSens*NySens ~= size(S,1))
            NxSens = NxSens-1;
            NySens = NySens-1;
            
            if (NxSens*NySens ~= size(S,1))
                disp('error in the number of acqusition per line!!!')
            end
        end
        x = linspace(xLim(1), xLim(2), NxSens);
        dx = x(2)-x(1);
    end
    
    % The stage needs some time to accelerate. Thus, there is a more or
    % less constant offset between the two scanning directions that we want
    % to get rid off by co-registration.
	if genPos > 0	
        
		% calculate shift using coregistration of subsequent line-scans
		if genPos == 2
            
            % get MAP image of both scanning directions
			S3Dshape = reshape(S,[NySens,NxSens,Ntime]);
			Samp1 = single(squeeze(max(S3Dshape(:,1:2:NxSens,:),[],2)));
			Samp2 = single(squeeze(max(S3Dshape(:,2:2:NxSens,:),[],2)));
			clear S3Dshape    
            
            % filter out vertical/reflection stripes
            filtPat = ones(size(Samp1,1), size(Samp1,2));
			filtPat(1,:) = 0;
			fftImage = fft2(Samp1).*filtPat;
			Samp1fft = real(ifft2(fftImage));
			fftImage = fft2(Samp2).*filtPat;
			Samp2fft = real(ifft2(fftImage));
            figure(1), imagesc(Samp1fft)
            figure(2), imagesc(Samp2fft)
            
            % find highest correlation between images
            Noffset = 50;
            template = Samp1fft(Noffset:end,10:end-10);
            cc = normxcorr2(template,Samp1fft);                            % calibrate the offset by self-coregistration
            [max_cc, imax] = max(cc(:));
            [yCal, xCal] = ind2sub(size(cc),imax(1));
            cc = normxcorr2(template,Samp2fft);
            [max_cc, imax] = max(cc(:));
            [yShift, xShift] = ind2sub(size(cc),imax(1));
            
            % calibrate offset
            dir1shift = mean(positionXY(1:2*NySens:end,2));                % take into account the initial position of scanning direction 1
            dir2shift = mean(positionXY(NySens+1:2*NySens:end,2));         % take into account the final position of scanning direction 2
            shiftInd = ((yCal - yShift) + (dir1shift-dir2shift)/dy )/2;
            shiftIndT = xCal - xShift;
           
        elseif genPos == 1 % added by M.O. on 13th Aug 2015
            if dx == 0.015 && vAct == 30
                shiftInd = 81;  % 15;   % 11;
            elseif dx == 0.02 && vAct == 40
                shiftInd = 24;%32.5;%24;%13;
            elseif dx == 0.018
                shiftInd = 24.44;
            elseif dx == 0.01 && vAct == 10
                shiftInd = 2;   
            elseif dx == 0.01 && vAct == 20
                shiftInd = 10.75;  % 8;    
            elseif dx == 0.01 && vAct == 15
                shiftInd = 3;  
            elseif dx == 0.008
                shiftInd = 7.25;   
            elseif dx == 0.005
                shiftInd = 6;
            elseif dx == 0.004
                shiftInd = 5;
            elseif dx == 0.0025
                shiftInd = 3;
            elseif dx == 0.003
                shiftInd = 3; 
            elseif dx == 0.0025
                shiftInd = 3;
            else
                shiftInd = 0;
            end
        end
		
        % shift sensor position by shiftInd*dx each!
        for i = 1:NxSens
            if mod(i,2)
                positionXY(NySens*(i-1)+[1:NySens],2) ...
                    = positionXY(NySens*(i-1)+[1:NySens],2) - shiftInd*dy;
            else
                positionXY(NySens*(i-1)+[1:NySens],2) ...
                    = positionXY(NySens*(i-1)+[1:NySens],2) + shiftInd*dy;           
            end
        end
        
        % cut away shifted data
        [user sys] = memory;
        if sys.PhysicalMemory.Available < 2/3*sys.PhysicalMemory.Total
            cutBound = 0;
        end
        if cutBound == 1
            S = reshape(S,NySens,NxSens,Ntime);
            positionXY = reshape (positionXY,NySens,NxSens,2);
            shiftInd2 = round(shiftInd);
            if shiftInd2 > 0
                Scut = zeros([NySens-shiftInd2,NxSens,Ntime],'single');
                Scut(:,1:2:NxSens,:) = S(1+shiftInd2:end,1:2:NxSens,:);
                Scut(:,2:2:NxSens,:) = S(1:end-shiftInd2,2:2:NxSens,:);
                posCut = zeros([NySens-shiftInd2,NxSens,2]);
                posCut(:,1:2:NxSens,:) = positionXY(1+shiftInd2:end,1:2:NxSens,:);
                posCut(:,2:2:NxSens,:) = positionXY(1:end-shiftInd2,2:2:NxSens,:);    
            else
                shiftInd2 = abs(shiftInd2);
                Scut = zeros([NySens-shiftInd2,NxSens,Ntime],'single');
                Scut(:,2:2:NxSens,:) = S(1+shiftInd2:end,2:2:NxSens,:);
                Scut(:,1:2:NxSens,:) = S(1:end-shiftInd2,1:2:NxSens,:);
                posCut = zeros([NySens-shiftInd2,NxSens,2]);
                posCut(:,2:2:NxSens,:) = positionXY(1+shiftInd2:end,2:2:NxSens,:);
                posCut(:,1:2:NxSens,:) = positionXY(1:end-shiftInd2,1:2:NxSens,:);  
            end
            NySens = NySens - shiftInd2;
            S = reshape(Scut,NySens*NxSens,Ntime);
            positionXY = reshape (posCut,NySens*NxSens,2);
        end
		
    else
        shiftInd = 0;
    end
    
    % change Unit to um!!!
    xs = positionXY(:,1)*1e3;                                              % define x-positions of scan-lines (slow axis)
    ys = (positionXY(:,2) - mean(positionXY(:,2)))*1e3 + mean(yGrid);      % define y-positions of transducer (fast axis)
    dx = dx*1e3;
    dy = dy*1e3;
    dt_sp = dt * v_s * 1e6;
    
    
    %% shift reconstruction and sensor grid: recongrid -> (0,0,0) till (width,width,depth)
    xRecon = xGrid - min(xGrid);
    yRecon = yGrid - min(yGrid);
    xs = xs - min(xGrid);
    ys = ys - min(yGrid);
    
    fprintf('Shifted Reconstruction grid (zxy): [%d %d]x[%d %d]x[%d %d]\n',...
        zGrid(1), zGrid(2), xRecon(1), xRecon(2), yRecon(1), yRecon(2));
    
    
    %% Interpolate sensor grid to homogeneous y-grid (x-grid is homogeneous already!)
    S = single(S);
    
    xSens = [min(xs) max(xs)];                                             % shifted x-grid
    
    % create shifted y-grid centered around yMed
    yMed = mean(ys);
    ySens(1) = round(yMed - (NySens-1)/2*dy);
    ySens(2) = ySens(1) + (NySens-1)*dy;
    yHelp = linspace(ySens(1),ySens(2),NySens)';
    [XI,YI] = meshgrid(1:Ntime,yHelp);                          
        
    fprintf('Shifted Sensor grid (xy): [%.1f %.1f]x[%.1f %.1f]\n\n',...
        xSens(1), xSens(2), ySens(1), ySens(2));
    
    fprintf('Interpolate sensor position to new sensor grid\n   ');
    
    % interpolate each B-scan data set to the homogeneous y-grid
    for i = 1:NxSens
        if mod(i,100) == 0
            fprintf('... %d%% ',round(i/NxSens*100));
        end
        slice = squeeze(S((i-1)*NySens + [1:NySens],:));
        try
            ySlice = ys((i-1)*NySens + [1:NySens]);
            [X,Y] = meshgrid(1:Ntime,ySlice);
            ZI = interp2(X,Y,slice,XI,YI,'linear',0);
            S((i-1)*NySens + [1:NySens],:) = ZI;
        catch
            disp(' .err. - %%% TODO !!! Irregular time stamp !!! TODO %%% ');
%             ySlice = linspace(ys((i-1)*NySens+1),ys(i*NySens),NySens);
%             [X,Y] = meshgrid(1:Ntime,ySlice);
%             ZI = interp2(X,Y,slice,XI,YI,'linear',0);
%             S((i-1)*NySens + [1:NySens],:) = ZI;
        end
    end    
    
    fprintf('\n\n++ Interpolation: %.2f seconds\n\n', toc(tPart)); tPart = tic;
    
    clear XI YI X Y ZI
    
    
    %% sensitivity field modelling
    if SF_Model == 1
        
        fprintf('Initialize FieldII for modelling of sensitivity field\n\n');
        
        % !!! NOTE: Field II works in units of [m] !!!
        % initialize FieldII
        addpath('C:\Users\Chucheng\Documents\MATLAB\TAM\SAFT_recon\FieldII\Field_II_PC7')
        field_init(0);
        FsFieldII = 2e9;
        set_sampling(FsFieldII);
        set_field('c',v_s);
        set_field('use_att',0);

        % transducer modelling
        diameter = D_TD;
        focalRadius = F_TD;
        eleSize = diameter/50;
        Th = xdc_concave(diameter/2, focalRadius, eleSize);

        % generate N-shape in the frequency range given by f_BP
        Ts = 1/FsFieldII;                                                  % Sampling period
        rSphere = 0.8*v_s/(2*mean(f_BP));                                  % r = 0.8*v_s/(2*fc) (Eq. 10, thesis Buehler, page 7)
        t = 0:Ts:200/Fs;                                                   % sampling points of N-shape
        tau = v_s/rSphere*(t-(max(t)/2-rSphere/v_s));               
        nShape = rSphere*(1-tau).*heaviside(1-abs(tau-1));
        
    end
    
    
    %% Reconstruct slab volumes and merge them
    
    % initialize recon volume
    NxGrid = round(diff(xRecon)/DS + 1);
    NyGrid = round(diff(yRecon)/DS + 1);
    NzGridFull = diff(zGrid)/DZ + 1;
    R = zeros(NzGridFull,NxGrid,NyGrid,'single');                          % total size of Recon matrix
    Rslab = zeros(zRange/DZ,NxGrid,NyGrid,'single');                       % size of slab reconstructed at once on GPU
    
    % run through all recon slabs and stack them
    for j = 1:zSlices
        
        % calculate z-range to be reconstructed
        zRecon = [(zGrid(1) + (j-1)*zRange) (zGrid(1) + j*(zRange) - DZ) ];
        NzGrid = diff(zRecon)/DZ + 1;
        
        fprintf('\n************************************************************************\n');
        fprintf('Reconstruct z-Range: [%d %d]\n',zRecon(1), zRecon(2));
        
        % cut signal matrix to needed range
        if zRecon(1) > 0
            zMin = zRecon(1) - 10*DZ;
        else
            rad = a/b * sqrt( zRecon(1)^2 + b^2 ) + DS;
            zMin = sign(zRecon(1))*sqrt(rad^2+zRecon(1)^2) - 10*DZ;
        end
        if zRecon(2) < 0
            zMax = zRecon(2) + 10*DZ;
        else
            rad = a/b * sqrt( zRecon(2)^2 + b^2 ) + DS;
            zMax = sign(zRecon(2))*sqrt(rad^2+zRecon(2)^2) + 10*DZ;
        end
        tInd(1) = dsearchn(t_sp',zMin);
        tInd(2) = dsearchn(t_sp',zMax);
        tCut = t_sp(tInd(1):tInd(2));
        Scut = S(:,tInd(1):tInd(2));
        
        % define time vector
        timeVec = [tCut(1) dt_sp length(tCut)];
        timeVec = single(timeVec);
        fprintf('timeVec: (%.2f, %.2f, %d)\n',...
            timeVec(1), timeVec(2), timeVec(3));       
        
        % define sensor vector
        sensorVec = [NxSens xSens(1) NySens ySens(1) dx dy];
        sensorVec = single(sensorVec);
        fprintf('sensorVec: (%d, %.1f, %d, %.1f, %.1f, %.1f)\n',...
            sensorVec(1), sensorVec(2), sensorVec(3),...
            sensorVec(4), sensorVec(5), sensorVec(6)); 
        
        % define grid vector
        gridVec = [NzGrid NxGrid NyGrid zRecon(1) DZ DS];
        gridVec = int32(gridVec);
        fprintf('gridVec: (%d, %d, %d, %.1f)\n',...
            gridVec(1), gridVec(2), gridVec(3),gridVec(4)); 
        
        % define transducer parameters alpha and focus region
        % numerical aperture angle alpha
        alpha = single(alpha);
        fprintf('alpha: (%.2f)\n\n', alpha);
        transducerVec = [alpha a b];
        transducerVec = single(transducerVec);
            
        
        %% Choose reconstruction method:        
        Scut = Scut';                                                                       % flip dimensions: space x t --> t x space
        switch MethodBP
            case 2                                                                          % Filtered BP (derivative term only)
                Scut = -[diff(Scut,1,1); zeros(1,size(Scut,2))];
            case 3                                                                          % Filtered BP * t
                tWeight = repmat((abs(tCut)./(tCut(2)-tCut(1)))',[1 size(Scut,2)]);
                Scut = -tWeight.* [diff(Scut,1,1); zeros(1,size(Scut,2))];
            case 4                                                                          % Filtered BP (full term)
                tWeight = repmat((abs(tCut)./(tCut(2)-tCut(1)))',[1 size(Scut,2)]);
                if strcmp(transducerParams.transducer,'50')
                    Scut = 10*Scut - (tWeight .* [diff(Scut,1,1); zeros(1,size(Scut,2))]);
                elseif strcmp(transducerParams.transducer,'50Juan')
                    Scut = 10*Scut - (tWeight .* [diff(Scut,1,1); zeros(1,size(Scut,2))]);
                else
                    Scut = 15*Scut - (tWeight .* [diff(Scut,1,1); zeros(1,size(Scut,2))]);
                end
        end
        
        
        %% Define signal matrix and perform reconstruction
        Scut = single(Scut);
        
        
        %% sensitivity field modelling
        switch SF_Model
            case 0
                Rslab = SAFT3D(Scut, sensorVec, gridVec, timeVec, transducerVec );           
            case 1
                fprintf('++ Sensitivity field modelling');
                depthMin = zRecon(1);                                      % reconstruction range in [um]
                depthMax = zRecon(2);                                      % reconstruction range in [um]
                zVec = depthMin:DZ:depthMax;

                radMax = 7*DS + a/b * sqrt( b^2 + max(abs(depthMin),abs(depthMax))^2 );
                xVec = 0:floor(DS/3):radMax;

                SF_matrix = zeros(length(zVec),length(xVec));
                for Nz = 1:length(zVec)
                    for Nx = 1:length(xVec)
                        x = xVec(Nx)*1e-6;
                        y = 0;
                        z = focalRadius + zVec(Nz)*1e-6;
                        point = [x y z];
                        [p1,t_temp] = calc_hp(Th,double(point));
                        nShapeConv = conv(nShape,p1);
                        SF_matrix(Nz,Nx) = max(nShapeConv)-min(nShapeConv);                    
                    end
                end
                
                SF_matrix = single(SF_matrix);
                fprintf(': %.2f seconds \n\n', toc(tPart)); tPart = tic;
                
                Rslab = SIRSAFT3D(Scut, sensorVec, gridVec, timeVec, transducerVec, SF_matrix );
                               
        end
          
        % Stack reconstructions
        if strcmp(transducerParams.transducer,'50')
            R((j-1)*NzGrid+1:j*NzGrid,:,:) = -Rslab;
        elseif strcmp(transducerParams.transducer,'50Juan')
            R((j-1)*NzGrid+1:j*NzGrid,:,:) = -Rslab;
        elseif strcmp(transducerParams.transducer,'100Juan')
            R((j-1)*NzGrid+1:j*NzGrid,:,:) = -Rslab;
        elseif strcmp(transducerParams.transducer,'100oldJuan')
            R((j-1)*NzGrid+1:j*NzGrid,:,:) = Rslab;
        else
            R((j-1)*NzGrid+1:j*NzGrid,:,:) = Rslab;
        end
        
        fprintf('\n\n++ Reconstruction: %.2f seconds \n', toc(tPart)); tPart = tic;
        
    end    
%     R = R1;
    R = permute(R,[3 2 1]);
    R = R./max(abs(R(:))) .* MaxConserve; % recover the value
    % define output for plot and save
    xr = xRecon;
    yr = yRecon;
    zr = zGrid;
    
    %% plot results
    ShowFig=0;
if ShowFig
%     figure('units', 'normalized', 'position', [0.13, 0.1, 0.71, 0.83]);
%     figure('units','normalized','position',[0 0 0.47 1]),
    figure('units','normalized','position',[0.47 0 1/2 1]);
    Siz_Ax  = 18;
    Siz_Ti  = 16;
    Siz_Tit = 12;
    subplot(2, 2, 1);
    imagesc(xr,yr,squeeze(max(R,[],3))), daspect([1 1 1]), h_cbar=colorbar, colormap jet, xlabel(h_cbar,'/mVolt');
%     tit1 = [fileParams.dataName fileParams.reconExt];
%     title(tit1, 'FontWeight', 'bold', 'FontSize', Siz_Tit, 'interpreter', 'none');
    xlabel('x (µm)', 'FontWeight', 'bold', 'FontSize', Siz_Ax);
    ylabel('y (µm)', 'FontWeight', 'bold', 'FontSize', Siz_Ax);
    set(gca, 'units', 'normalized', 'FontSize', Siz_Ti);

    subplot(2, 2, 2);
    imagesc(yr,zr,squeeze(max(R,[],2))'), daspect([1 1 1]), h_cbar=colorbar, colormap jet, xlabel(h_cbar,'/mVolt');
    xlabel('y (µm)', 'FontWeight', 'bold', 'FontSize', Siz_Ax);
    ylabel('z (µm)', 'FontWeight', 'bold', 'FontSize', Siz_Ax);
    set(gca, 'units', 'normalized', 'FontSize', Siz_Ti);

    subplot(2, 2, 3);
    imagesc(xr,zr,squeeze(max(R,[],1))'), daspect([1 1 1]), h_cbar=colorbar, colormap jet, xlabel(h_cbar,'/mVolt');
    xlabel('x (µm)', 'FontWeight', 'bold', 'FontSize', Siz_Ax);
    ylabel('z (µm)', 'FontWeight', 'bold', 'FontSize', Siz_Ax);
    set(gca, 'units', 'normalized', 'FontSize', Siz_Ti);
    
    pause(0.1)
end    
    
    %% save data
    fprintf('\n Saving ...');
    R_Info = whos('R');

    if R_Info.bytes/(1024^3) >= 1.9
        save([fileParams.recon 'R_' fileParams.dataName fileParams.reconExt '.mat'], ...
             'R', 'xr', 'yr', 'zr', 'reconParams','transducerParams', 'shiftInd', '-v7.3');
    else
        save([fileParams.recon 'R_' fileParams.dataName fileParams.reconExt '.mat'], ...
             'R', 'xr', 'yr', 'zr', 'shiftInd', 'reconParams','transducerParams');
    end
    fprintf('\n\n++ Save data: %.2f seconds \n', toc(tPart)); tPart = tic;
    
    fprintf('\n\nTotal time: %.2f seconds \n', toc(tStart));
    
    diary off;
 
end

